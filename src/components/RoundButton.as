package components
{
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.core.GNode;
	import com.genome2d.textures.GTexture;

	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	public class RoundButton extends GSprite
	{
		public function RoundButton(p_node : GNode)
		{
			super(p_node);
		}

		override public function processMouseEvent(p_captured : Boolean, p_event : MouseEvent, p_position : Vector3D) : Boolean
		{
			var cTexture : GTexture = getTexture();
			var tWidth:Number = cTexture.width;
			var tHeight:Number = cTexture.height;
			var transformMatrix:Matrix3D = node.transform.getTransformedWorldTransformMatrix(tWidth, tHeight, 0, true);
			var localPoint:Vector3D = transformMatrix.transformVector(p_position);
				localPoint.x = (localPoint.x * tWidth);
				localPoint.y = (localPoint.y * tHeight);

			var sqDist : Number = Math.pow(localPoint.x, 2) + Math.pow(localPoint.y, 2);
			var radius : Number = tWidth / 2 - 25;

			if(sqDist < Math.pow(radius, 2)) {
				return super.processMouseEvent(p_captured, p_event, p_position);
			} else {
				return false;
			}
		}
	}
}
