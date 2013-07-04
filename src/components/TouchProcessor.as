package components
{
	import com.genome2d.components.GComponent;
	import com.genome2d.core.GNode;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.core.Genome2D;

	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.ui.Mouse;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.getDefinitionByName;

	import utils.touch.Touch;
	import utils.touch.TouchPhase;
	import utils.touch.TouchSignal;

	public class TouchProcessor extends GComponent
	{
		private static const MULTITAP_TIME:Number = 0.3;
		private static const MULTITAP_DISTANCE:Number = 25;

		private var mStage : Stage;
		private var mViewPort : Rectangle;
		private var mElapsedTime:Number;
		private var mTouchMarker:TouchMarker;

		private var mCurrentTouches:Vector.<Touch>;
		private var mQueue:Vector.<Array>;
		private var mLastTaps:Vector.<Touch>;

		private var mShiftDown:Boolean = false;
		private var mCtrlDown:Boolean = false;
		private var mLeftMouseDown:Boolean;

		private static var sProcessedTouchIDs:Vector.<int> = new <int>[];
		private static var sHoveringTouchData:Vector.<Object> = new <Object>[];

		public function TouchProcessor(p_node : GNode)
		{
			super(p_node);

			mStage = Genome2D.getInstance().stage;
			mElapsedTime = 0.0;
			mCurrentTouches = new <Touch>[];
			mQueue = new <Array>[];
			mLastTaps = new <Touch>[];
			mViewPort = new Rectangle(0, 0, mStage.stageWidth, mStage.stageHeight);
			mStage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
			mStage.addEventListener(KeyboardEvent.KEY_UP,   onKey);

			// register touch/mouse event handlers
			for each (var touchEventType:String in touchEventTypes) {
				mStage.addEventListener(touchEventType, onTouch); // todo: also dispose
			}

			monitorInterruptions(true);
			simulateMultitouch = true;
		}

		private function get touchEventTypes() : Array
		{
			var multitouchEnabled : Boolean = Multitouch.inputMode == MultitouchInputMode.TOUCH_POINT;

			return Mouse.supportsCursor || !multitouchEnabled ?
					[ MouseEvent.MOUSE_DOWN,  MouseEvent.MOUSE_MOVE, MouseEvent.MOUSE_UP ] :
					[ TouchEvent.TOUCH_BEGIN, TouchEvent.TOUCH_MOVE, TouchEvent.TOUCH_END ];
		}

		override public function dispose():void
		{
			monitorInterruptions(false);
			mStage.removeEventListener(KeyboardEvent.KEY_DOWN, onKey);
			mStage.removeEventListener(KeyboardEvent.KEY_UP,   onKey);
			if (mTouchMarker) mTouchMarker.dispose();
		}

		private function onTouch(event : Event):void
		{
//			if (!mStarted) return;

			var globalX:Number;
			var globalY:Number;
			var touchID:int;
			var phase:String;
			var pressure:Number = 1.0;
			var width:Number = 1.0;
			var height:Number = 1.0;

			// figure out general touch properties
			if (event is MouseEvent)
			{
				var mouseEvent:MouseEvent = event as MouseEvent;
				globalX = mouseEvent.stageX;
				globalY = mouseEvent.stageY;
				touchID = 0;

				// MouseEvent.buttonDown returns true for both left and right button (AIR supports
				// the right mouse button). We only want to react on the left button for now,
				// so we have to save the state for the left button manually.
				if (event.type == MouseEvent.MOUSE_DOWN)    mLeftMouseDown = true;
				else if (event.type == MouseEvent.MOUSE_UP) mLeftMouseDown = false;
			}
			else
			{
				var touchEvent:TouchEvent = event as TouchEvent;
				globalX = touchEvent.stageX;
				globalY = touchEvent.stageY;
				touchID = touchEvent.touchPointID;
				pressure = touchEvent.pressure;
				width = touchEvent.sizeX;
				height = touchEvent.sizeY;
			}

			// figure out touch phase
			switch (event.type)
			{
				case TouchEvent.TOUCH_BEGIN: phase = TouchPhase.BEGAN; break;
				case TouchEvent.TOUCH_MOVE:  phase = TouchPhase.MOVED; break;
				case TouchEvent.TOUCH_END:   phase = TouchPhase.ENDED; break;
				case MouseEvent.MOUSE_DOWN:  phase = TouchPhase.BEGAN; break;
				case MouseEvent.MOUSE_UP:    phase = TouchPhase.ENDED; break;
				case MouseEvent.MOUSE_MOVE:
					phase = (mLeftMouseDown ? TouchPhase.MOVED : TouchPhase.HOVER); break;
			}

			// move position into viewport bounds
			globalX = mStage.stageWidth  * (globalX - mViewPort.x) / mViewPort.width;
			globalY = mStage.stageHeight * (globalY - mViewPort.y) / mViewPort.height;

			// enqueue touch in touch processor
			enqueue(touchID, phase, globalX, globalY, pressure, width, height);
		}

		public function enqueue(touchID:int, phase:String, globalX:Number, globalY:Number,
								pressure:Number=1.0, width:Number=1.0, height:Number=1.0):void
		{
			mQueue.unshift(arguments);

			// multitouch simulation (only with mouse)
			if (mCtrlDown && simulateMultitouch && touchID == 0)
			{
				mTouchMarker.moveMarker(globalX, globalY, mShiftDown);
				mQueue.unshift([1, phase, mTouchMarker.mockX, mTouchMarker.mockY]);
			}
		}

		override public function update(passedTime : Number, p_parentTransformUpdate : Boolean, p_parentColorUpdate : Boolean) : void
		{
			var i:int;
			var touchID:int;
			var touch:Touch;

			mElapsedTime += passedTime / 1000; // todo: g2d specific?

			// remove old taps
			if (mLastTaps.length > 0)
			{
				for (i=mLastTaps.length-1; i>=0; --i)
					if (mElapsedTime - mLastTaps[i].timestamp > MULTITAP_TIME)
						mLastTaps.splice(i, 1);
			}

			while (mQueue.length > 0)
			{
				sProcessedTouchIDs.length = sHoveringTouchData.length = 0;

				// set touches that were new or moving to phase 'stationary'
				for each (touch in mCurrentTouches)
					if (touch.phase == TouchPhase.BEGAN || touch.phase == TouchPhase.MOVED)
						touch.setPhase(TouchPhase.STATIONARY);

				// process new touches, but each ID only once
				while (mQueue.length > 0 &&
						sProcessedTouchIDs.indexOf(mQueue[mQueue.length-1][0]) == -1)
				{
					var touchArgs:Array = mQueue.pop();
					touchID = touchArgs[0] as int;
					touch = getCurrentTouch(touchID);

					// hovering touches need special handling (see below)
					if (touch && touch.phase == TouchPhase.HOVER && touch.target)
						sHoveringTouchData.push({
							touch: touch,
							target: touch.target/*,
							bubbleChain: touch.bubbleChain*/
						});

					processTouch.apply(this, touchArgs);
					sProcessedTouchIDs.push(touchID);
				}

				var target : GTouchSprite = node.getComponent(GTouchSprite) as GTouchSprite;
					target.onTouch.dispatch(new TouchSignal(mCurrentTouches, mShiftDown, mCtrlDown));

				// remove ended touches
				for (i=mCurrentTouches.length-1; i>=0; --i)
					if (mCurrentTouches[i].phase == TouchPhase.ENDED)
						mCurrentTouches.splice(i, 1);
			}
		}

		public function enqueueMouseLeftStage():void
		{
			var mouse:Touch = getCurrentTouch(0);
			if (mouse == null || mouse.phase != TouchPhase.HOVER) return;

			// On OS X, we get mouse events from outside the stage; on Windows, we do not.
			// This method enqueues an artifial hover point that is just outside the stage.
			// That way, objects listening for HOVERs over them will get notified everywhere.

			var offset:int = 1;
			var exitX:Number = mouse.globalX;
			var exitY:Number = mouse.globalY;
			var distLeft:Number = mouse.globalX;
			var distRight:Number = mStage.stageWidth - distLeft;
			var distTop:Number = mouse.globalY;
			var distBottom:Number = mStage.stageHeight - distTop;
			var minDist:Number = Math.min(distLeft, distRight, distTop, distBottom);

			// the new hover point should be just outside the stage, near the point where
			// the mouse point was last to be seen.

			if (minDist == distLeft)       exitX = -offset;
			else if (minDist == distRight) exitX = mStage.stageWidth + offset;
			else if (minDist == distTop)   exitY = -offset;
			else                           exitY = mStage.stageHeight + offset;

			enqueue(0, TouchPhase.HOVER, exitX, exitY);
		}

		private function processTouch(touchID:int, phase:String, globalX:Number, globalY:Number,
									  pressure:Number=1.0, width:Number=1.0, height:Number=1.0):void
		{
			var position:Point = new Point(globalX, globalY);
			var touch:Touch = getCurrentTouch(touchID);

			if (touch == null)
			{
				touch = new Touch(touchID, globalX, globalY, phase, null);
				addCurrentTouch(touch);
			}

			touch.setPosition(globalX, globalY);
			touch.setPhase(phase);
			touch.setTimestamp(mElapsedTime);
			touch.setPressure(pressure);
			touch.setSize(width, height);

			if (phase == TouchPhase.HOVER || phase == TouchPhase.BEGAN) {
//				touch.setTarget(mStage.hitTest(position, true));
				var target : GTouchSprite = node.getComponent(GTouchSprite) as GTouchSprite;
				var vec : Vector3D = new Vector3D(position.x, position.y);
				if(target.hitTestPoint(vec)) {
					touch.setTarget(target.node); // is node anyway
				}
			}

			if (phase == TouchPhase.BEGAN)
				processTap(touch);
		}


		private function onKey(event:KeyboardEvent):void
		{
			if (event.keyCode == 17 || event.keyCode == 15) // ctrl or cmd key
			{
				var wasCtrlDown:Boolean = mCtrlDown;
				mCtrlDown = event.type == KeyboardEvent.KEY_DOWN;

				if (simulateMultitouch && wasCtrlDown != mCtrlDown)
				{
					mTouchMarker.node.transform.visible = mCtrlDown;
					mTouchMarker.moveCenter(mStage.stageWidth/2, mStage.stageHeight/2);

					var mouseTouch:Touch = getCurrentTouch(0);
					var mockedTouch:Touch = getCurrentTouch(1);

					if (mouseTouch)
						mTouchMarker.moveMarker(mouseTouch.globalX, mouseTouch.globalY);

					// end active touch ...
					if (wasCtrlDown && mockedTouch && mockedTouch.phase != TouchPhase.ENDED)
						mQueue.unshift([1, TouchPhase.ENDED, mockedTouch.globalX, mockedTouch.globalY]);
					// ... or start new one
					else if (mCtrlDown && mouseTouch)
					{
						if (mouseTouch.phase == TouchPhase.HOVER || mouseTouch.phase == TouchPhase.ENDED)
							mQueue.unshift([1, TouchPhase.HOVER, mTouchMarker.mockX, mTouchMarker.mockY]);
						else
							mQueue.unshift([1, TouchPhase.BEGAN, mTouchMarker.mockX, mTouchMarker.mockY]);
					}
				}
			}
			else if (event.keyCode == 16) // shift key
			{
				mShiftDown = event.type == KeyboardEvent.KEY_DOWN;
			}
		}

		private function processTap(touch:Touch):void
		{
			var nearbyTap:Touch = null;
			var minSqDist:Number = MULTITAP_DISTANCE * MULTITAP_DISTANCE;

			for each (var tap:Touch in mLastTaps)
			{
				var sqDist:Number = Math.pow(tap.globalX - touch.globalX, 2) +
						Math.pow(tap.globalY - touch.globalY, 2);
				if (sqDist <= minSqDist)
				{
					nearbyTap = tap;
					break;
				}
			}

			if (nearbyTap)
			{
				touch.setTapCount(nearbyTap.tapCount + 1);
				mLastTaps.splice(mLastTaps.indexOf(nearbyTap), 1);
			}
			else
			{
				touch.setTapCount(1);
			}

			mLastTaps.push(touch.clone());
		}

		private function addCurrentTouch(touch:Touch):void
		{
			for (var i:int=mCurrentTouches.length-1; i>=0; --i)
				if (mCurrentTouches[i].id == touch.id)
					mCurrentTouches.splice(i, 1);

			mCurrentTouches.push(touch);
		}

		private function getCurrentTouch(touchID:int):Touch
		{
			for each (var touch:Touch in mCurrentTouches)
				if (touch.id == touchID) return touch;
			return null;
		}

		public function get simulateMultitouch():Boolean
		{
			return mTouchMarker != null;
		}

		public function set simulateMultitouch(value:Boolean):void
		{
			if (simulateMultitouch == value) return; // no change
			if (value)
			{
				mTouchMarker = GNodeFactory.createNodeWithComponent(TouchMarker) as TouchMarker;//new TouchMarker(node);
				mTouchMarker.node.transform.visible = false;
				Genome2D.getInstance().root.addChild(mTouchMarker.node);
				//mStage.addChild(mTouchMarker.node);
			}
			else
			{
//				mTouchMarker.removeFromParent(true);
				Genome2D.getInstance().root.removeChild(mTouchMarker.node)// mTouchMarker.removeFromParent(true);
				mTouchMarker = null;
			}
		}

		// interruption handling

		private function monitorInterruptions(enable:Boolean):void
		{
			// if the application moves into the background or is interrupted (e.g. through
			// an incoming phone call), we need to abort all touches.

			try
			{
				var nativeAppClass:Object = getDefinitionByName("flash.desktop::NativeApplication");
				var nativeApp:Object = nativeAppClass["nativeApplication"];

				if (enable)
					nativeApp.addEventListener("deactivate", onInterruption, false, 0, true);
				else
					nativeApp.removeEventListener("activate", onInterruption);
			}
			catch (e:Error) {} // we're not running in AIR
		}

		private function onInterruption(event:Object):void
		{
			// todo: ...
//			var touch:Touch;
//
//			// abort touches
//			for each (touch in mCurrentTouches)
//			{
//				if (touch.phase == TouchPhase.BEGAN || touch.phase == TouchPhase.MOVED ||
//						touch.phase == TouchPhase.STATIONARY)
//				{
//					touch.setPhase(TouchPhase.ENDED);
//				}
//			}
//
//			// dispatch events
//			var touchEvent:TouchEvent =
//					new TouchEvent(TouchEvent.TOUCH, mCurrentTouches, mShiftDown, mCtrlDown);
//
//			for each (touch in mCurrentTouches)
//				touch.dispatchEvent(touchEvent);
//
//			// purge touches
//			mCurrentTouches.length = 0;
		}
	}
}