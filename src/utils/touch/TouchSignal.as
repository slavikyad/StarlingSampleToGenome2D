package utils.touch
{
	import com.genome2d.core.GNode;

	import org.osflash.signals.Signal;

	import utils.touch.Touch;
	import utils.touch.TouchPhase;

	public class TouchSignal extends Signal
	{
		private var mShiftKey : Boolean;
		private var mCtrlKey : Boolean;
		private var mTimestamp : Number;
		private var mVisitedObjects : Vector.<GNode>;
		private var mTouches : Vector.<Touch>;

		private static var sTouches : Vector.<Touch> = new <Touch>[]; // ?

		public function TouchSignal(touches : Vector.<Touch>, shiftKey : Boolean=false, ctrlKey:Boolean=false)
		{
			//super(rest);

			mShiftKey = shiftKey;
			mCtrlKey = ctrlKey;
			mTimestamp = -1.0;
			mVisitedObjects = new <GNode>[];
			mTouches = touches;

			var numTouches:int=mTouches.length;
			for (var i:int=0; i<numTouches; ++i)
				if (mTouches[i].timestamp > mTimestamp)
					mTimestamp = mTouches[i].timestamp;
		}

		public function getTouches(target:GNode, phase:String=null,
								   result:Vector.<Touch>=null):Vector.<Touch>
		{
			if (result == null) result = new <Touch>[];
			var allTouches:Vector.<Touch> = mTouches;
			var numTouches:int = allTouches.length;

			for (var i:int=0; i<numTouches; ++i)
			{
				var touch:Touch = allTouches[i];
				var correctTarget:Boolean = touch.isTouching(target);
				var correctPhase:Boolean = (phase == null || phase == touch.phase);

				if (correctTarget && correctPhase)
					result.push(touch);
			}

			return result;
		}

		public function getTouch(target:GNode, phase:String=null):Touch
		{
			getTouches(target, phase, sTouches);

			if (sTouches.length)
			{
				var touch:Touch = sTouches[0];
				sTouches.length = 0;
				return touch;
			}
			else return null;
		}

		public function interactsWith(target:GNode):Boolean
		{
			if (getTouch(target) == null)
				return false;
			else
			{
				var touches:Vector.<Touch> = getTouches(target);

				for (var i:int=touches.length-1; i>=0; --i)
					if (touches[i].phase != TouchPhase.ENDED)
						return true;

				return false;
			}
		}


//		override public function dispatch(...rest) : void
//		{
////			super.dispatch(rest);
//
////			if (chain && chain.length)
////			{
//				var chainLength:int = /*bubbles ? chain.length :*/ 1;
//				var previousTarget:GNode = target;
//				setTarget(chain[0] as EventDispatcher);
//
//				for (var i:int=0; i<chainLength; ++i)
//				{
//					var chainElement:EventDispatcher = chain[i] as EventDispatcher;
//					if (mVisitedObjects.indexOf(chainElement) == -1)
//					{
//						var stopPropagation:Boolean = chainElement.invokeEvent(this);
//						mVisitedObjects.push(chainElement);
//						if (stopPropagation) break;
//					}
//				}
//
//				setTarget(previousTarget);
////			}
//		}

		/** The time the event occurred (in seconds since application launch). */
		public function get timestamp():Number { return mTimestamp; }

		/** All touches that are currently available. */
		public function get touches():Vector.<Touch> { return mTouches.concat(); }

		/** Indicates if the shift key was pressed when the event occurred. */
		public function get shiftKey():Boolean { return mShiftKey; }

		/** Indicates if the ctrl key was pressed when the event occurred. (Mac OS: Cmd or Ctrl) */
		public function get ctrlKey():Boolean { return mCtrlKey; }
	}
}
