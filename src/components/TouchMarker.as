package components
{
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.core.GNode;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.textures.GTexture;
	import com.genome2d.textures.factories.GTextureFactory;

	import flash.display.BitmapData;

	import flash.display.Shape;

	import flash.geom.Point;

	public class TouchMarker extends GSprite
	{
		private var mCenter : Point;
		private var mTexture : GTexture;
		private var realMarker : GSprite;
		private var mockMarker : GSprite;

		public function get realX() : Number
		{
			return realMarker.node.transform.x;
		}

		public function get realY() : Number
		{
			return realMarker.node.transform.y;
		}

		public function get mockX() : Number
		{
			return mockMarker.node.transform.x;
		}

		public function get mockY() : Number
		{
			return mockMarker.node.transform.y;
		}

		public function TouchMarker(p_node : GNode)
		{
			super(p_node);

			mCenter = new Point();
			mTexture = createTexture();

			realMarker = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
			realMarker.setTexture(mTexture);

			node.addChild(realMarker.node);

			mockMarker = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
			mockMarker.setTexture(mTexture);
			node.addChild(mockMarker.node);
		}

		override public function dispose() : void
		{
			super.dispose();

			mTexture.dispose();
		}

		public function moveMarker(x:Number, y:Number, withCenter:Boolean=false):void
		{
			if (withCenter)
			{
				mCenter.x += x - realMarker.node.transform.x;
				mCenter.y += y - realMarker.node.transform.y;
			}

			realMarker.node.transform.x = x;
			realMarker.node.transform.y = y;
			mockMarker.node.transform.x = 2*mCenter.x - x;
			mockMarker.node.transform.y = 2*mCenter.y - y;
		}

		public function moveCenter(x:Number, y:Number):void
		{
			mCenter.x = x;
			mCenter.y = y;
			moveMarker(realX, realY); // reset mock position
		}

		private function createTexture() : GTexture
		{
			var scale:Number = 1;// todo: Starling.contentScaleFactor;
			var radius:Number = 12 * scale;
			var width:int = 32 * scale;
			var height:int = 32 * scale;
			var thickness:Number = 1.5 * scale;
			var shape:Shape = new Shape();

			shape.graphics.lineStyle(thickness, 0x0, 0.3);
			shape.graphics.drawCircle(width/2, height/2, radius + thickness);

			shape.graphics.beginFill(0xffffff, 0.4);
			shape.graphics.lineStyle(thickness, 0xffffff);
			shape.graphics.drawCircle(width/2, height/2, radius);
			shape.graphics.endFill();

			var bmpData : BitmapData = new BitmapData(width, height, true, 0x0);
				bmpData.draw(shape);

			return GTextureFactory.createFromBitmapData("touchmarker", bmpData);
		}
	}
}
