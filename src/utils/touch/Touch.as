package utils.touch
{
	import utils.*;
	import components.*;
	import com.genome2d.core.GNode;

	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Vector3D;

	public class Touch
	{
		private var mID:int;
		private var mGlobalX:Number;
		private var mGlobalY:Number;
		private var mPreviousGlobalX:Number;
		private var mPreviousGlobalY:Number;
		private var mTapCount:int;
		private var mPhase:String;
		private var mTarget:GNode;
		private var mTimestamp:Number;
		private var mPressure:Number;
		private var mWidth:Number;
		private var mHeight:Number;
		private var mBubbleChain:Vector.<GNode>;

		/** Helper object. */
		private static var sHelperMatrix:Matrix = new Matrix();

		/** Creates a new Touch object. */
		public function Touch(id:int, globalX:Number, globalY:Number, phase:String, target:GNode)
		{
			mID = id;
			mGlobalX = mPreviousGlobalX = globalX;
			mGlobalY = mPreviousGlobalY = globalY;
			mTapCount = 0;
			mPhase = phase;
			mTarget = target;
			mPressure = mWidth = mHeight = 1.0;
			mBubbleChain = new <GNode>[];
			updateBubbleChain();
		}

		/** Converts the current location of a touch to the local coordinate system of a display
		 *  object. If you pass a 'resultPoint', the result will be stored in this point instead
		 *  of creating a new object.*/
		public function getLocation(space:GNode, resultPoint:Point=null):Point
		{
			if (resultPoint == null) resultPoint = new Point();
//			space.base.getTransformationMatrix(space, sHelperMatrix);
//			return transformCoords(sHelperMatrix, mGlobalX, mGlobalY, resultPoint);
			var localVec : Vector3D = space.transform.worldToLocal(new Vector3D(mGlobalX, mGlobalY));
			resultPoint.x = localVec.x;
			resultPoint.y = localVec.y;
			return resultPoint;
		}

		/** Converts the previous location of a touch to the local coordinate system of a display
		 *  object. If you pass a 'resultPoint', the result will be stored in this point instead
		 *  of creating a new object.*/
		public function getPreviousLocation(space:GNode, resultPoint:Point=null):Point
		{
			if (resultPoint == null) resultPoint = new Point();
//			space.base.getTransformationMatrix(space, sHelperMatrix);
//			return transformCoords(sHelperMatrix, mPreviousGlobalX, mPreviousGlobalY, resultPoint);
			var localVec : Vector3D = space.transform.worldToLocal(new Vector3D(mPreviousGlobalX, mPreviousGlobalY));
			resultPoint.x = localVec.x;
			resultPoint.y = localVec.y;
			return resultPoint;
		}

//		public static function transformCoords(matrix:Matrix, x:Number, y:Number,
//											   resultPoint:Point=null):Point
//		{
//			if (resultPoint == null) resultPoint = new Point();
//
//			resultPoint.x = matrix.a * x + matrix.c * y + matrix.tx;
//			resultPoint.y = matrix.d * y + matrix.b * x + matrix.ty;
//
//			return resultPoint;
//		}

		/** Returns the movement of the touch between the current and previous location.
		 *  If you pass a 'resultPoint', the result will be stored in this point instead
		 *  of creating a new object. */
		public function getMovement(space:GNode, resultPoint:Point=null):Point
		{
			if (resultPoint == null) resultPoint = new Point();
			getLocation(space, resultPoint);
			var x:Number = resultPoint.x;
			var y:Number = resultPoint.y;
			getPreviousLocation(space, resultPoint);
			resultPoint.setTo(x - resultPoint.x, y - resultPoint.y);
			return resultPoint;
		}

		/** Indicates if the target or one of its children is touched. */
		public function isTouching(target:GNode):Boolean
		{
			return mBubbleChain.indexOf(target) != -1;
		}

		/** Returns a description of the object. */
		public function toString():String
		{
			return "Touch "+mID+": globalX="+mGlobalX+", globalY="+mGlobalY+", phase="+mPhase;
		}

		/** Creates a clone of the Touch object. */
		public function clone():Touch
		{
			var clone:Touch = new Touch(mID, mGlobalX, mGlobalY, mPhase, mTarget);
			clone.mPreviousGlobalX = mPreviousGlobalX;
			clone.mPreviousGlobalY = mPreviousGlobalY;
			clone.mTapCount = mTapCount;
			clone.mTimestamp = mTimestamp;
			clone.mPressure = mPressure;
			clone.mWidth = mWidth;
			clone.mHeight = mHeight;
			return clone;
		}

		// helper methods

		private function updateBubbleChain():void
		{
			if (mTarget)
			{
				var length:int = 1;
				var element:GNode = mTarget;

				mBubbleChain.length = 1;
				mBubbleChain[0] = element;

				while ((element = element.parent) != null)
					mBubbleChain[int(length++)] = element;
			}
			else
			{
				mBubbleChain.length = 0;
			}
		}

		// properties

		/** The identifier of a touch. '0' for mouse events, an increasing number for touches. */
		public function get id():int { return mID; }

		/** The x-position of the touch in stage coordinates. */
		public function get globalX():Number { return mGlobalX; }

		/** The y-position of the touch in stage coordinates. */
		public function get globalY():Number { return mGlobalY; }

		/** The previous x-position of the touch in stage coordinates. */
		public function get previousGlobalX():Number { return mPreviousGlobalX; }

		/** The previous y-position of the touch in stage coordinates. */
		public function get previousGlobalY():Number { return mPreviousGlobalY; }

		/** The number of taps the finger made in a short amount of time. Use this to detect
		 *  double-taps / double-clicks, etc. */
		public function get tapCount():int { return mTapCount; }

		/** The current phase the touch is in. @see utils.touch.TouchPhase */
		public function get phase():String { return mPhase; }

		/** The display object at which the touch occurred. */
		public function get target():GNode { return mTarget; }

		/** The moment the touch occurred (in seconds since application start). */
		public function get timestamp():Number { return mTimestamp; }

		/** A value between 0.0 and 1.0 indicating force of the contact with the device.
		 *  If the device does not support detecting the pressure, the value is 1.0. */
		public function get pressure():Number { return mPressure; }

		/** Width of the contact area.
		 *  If the device does not support detecting the pressure, the value is 1.0. */
		public function get width():Number { return mWidth; }

		/** Height of the contact area.
		 *  If the device does not support detecting the pressure, the value is 1.0. */
		public function get height():Number { return mHeight; }

		// internal methods

		/** @private
		 *  Dispatches a touch event along the current bubble chain (which is updated each time
		 *  a target is set). */
//		starling_internal function dispatchEvent(event:TouchEvent):void
//		{
//			if (mTarget) event.dispatch(mBubbleChain);
//		}
//
//		/** @private */
//		starling_internal function get bubbleChain():Vector.<EventDispatcher>
//		{
//			return mBubbleChain.concat();
//		}
//
		/** @private */
		public function setTarget(value:GNode):void
		{
			mTarget = value;
			updateBubbleChain();
		}

		/** @private */
		public function setPosition(globalX:Number, globalY:Number):void
		{
			mPreviousGlobalX = mGlobalX;
			mPreviousGlobalY = mGlobalY;
			mGlobalX = globalX;
			mGlobalY = globalY;
		}

		/** @private */
		public function setSize(width:Number, height:Number):void
		{
			mWidth = width;
			mHeight = height;
		}

		/** @private */
		public function setPhase(value:String):void { mPhase = value; }

		/** @private */
		public function setTapCount(value:int):void { mTapCount = value; }

		/** @private */
		public function setTimestamp(value:Number):void { mTimestamp = value; }

		/** @private */
		public function setPressure(value:Number):void { mPressure = value; }
	}
}
