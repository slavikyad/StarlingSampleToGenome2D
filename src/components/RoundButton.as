package components
{
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.components.renderables.GTexturedQuad;
	import com.genome2d.core.GNode;
	import com.genome2d.textures.GTexture;

	import flash.geom.Matrix3D;

	import flash.geom.Vector3D;

	public class RoundButton extends GSprite
	{
		public function RoundButton(p_node : GNode)
		{
			super(p_node);
		}



		override public function hitTestPoint(p_point:Vector3D, p_pixelEnabled:Boolean = false):Boolean {
			var cTexture : GTexture = getTexture();
			var tWidth:Number = cTexture.width;// * cTexture.resampleScale;
			var tHeight:Number = cTexture.height;// * cTexture.resampleScale;
			var transformMatrix:Matrix3D = node.transform.getTransformedWorldTransformMatrix(tWidth, tHeight, 0, true);

			var localPoint:Vector3D = transformMatrix.transformVector(p_point);
			localPoint.x = (localPoint.x+.5);
			localPoint.y = (localPoint.y+.5);


//
//			if (localPoint.x >= -cTexture.nPivotX/tWidth && localPoint.x <= 1-cTexture.nPivotX/tWidth && localPoint.y >= -cTexture.nPivotY/tHeight && localPoint.y <= 1-cTexture.nPivotY/tHeight) {
//				if (mousePixelEnabled && cTexture.getAlphaAtUV(localPoint.x+cTexture.pivotX/tWidth, localPoint.y+cTexture.nPivotY/tHeight) == 0) {
//					return false;
//				}
//				return true;
//			}
//
//			return false;


			var centerX:Number = tWidth / 2;
			var centerY:Number = tHeight / 2;

			// calculate distance of localPoint to center.
			// we keep it squared, since we want to avoid the 'sqrt()'-call.
			var sqDist:Number = Math.pow(localPoint.x - centerX, 2) +
					Math.pow(localPoint.y - centerY, 2);

			// when the squared distance is smaller than the squared radius,
			// the point is inside the circle
			var radius:Number = tWidth / 2 - 8;
			if (sqDist < Math.pow(radius, 2)) return true;
			else return false;

		}

		override public function hitTestObject(p_sprite : GTexturedQuad) : Boolean
		{
			return super.hitTestObject(p_sprite);
		}
	}
}
