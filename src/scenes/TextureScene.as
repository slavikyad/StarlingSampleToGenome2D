package scenes
{
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.textures.GTexture;
	import com.genome2d.textures.GTextureAtlas;
	import com.genome2d.textures.factories.GTextureFactory;

	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	public class TextureScene extends Scene
	{
		private var compressedTex : GTexture;

		public function TextureScene(p_name : String = "")
		{
			super(p_name);

			var bounds : Rectangle = new Rectangle(0, 0, core.stage.stageWidth, core.stage.stageHeight);
			var atlas : GTextureAtlas = Assets.getAtlas();

			var tex : GTexture = atlas.getTexture("flight_00");
			var image1 : GSprite = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
			image1.setTexture(tex);
			image1.node.transform.x = (-bounds.width + tex.width) >> 1;
			image1.node.transform.y = (-bounds.height + tex.height) >> 1;
			addChild(image1.node);

			tex = atlas.getTexture("flight_04");
			var image2 : GSprite = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
			image2.setTexture(tex);
			image2.node.transform.x = (bounds.width - tex.width) >> 1;
			image2.node.transform.y = (-bounds.height + tex.width) >> 1;
			addChild(image2.node);

			tex = atlas.getTexture("flight_08");
			var image3 : GSprite = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
			image3.setTexture(tex);
			addChild(image3.node);

			compressedTex = GTextureFactory.createFromATF("compresseed", Assets.create("CompressedTexture") as ByteArray) as GTexture;
			var image : GSprite = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
			image.setTexture(compressedTex);
			image.node.transform.y = tex.height;
			addChild(image.node);
		}

		override public function dispose() : void
		{
			super.dispose();
			compressedTex.dispose();
		}
	}
}
