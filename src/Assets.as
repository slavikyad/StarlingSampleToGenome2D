package
{
	import com.genome2d.textures.GTexture;
	import com.genome2d.textures.GTextureAtlas;
	import com.genome2d.textures.factories.GTextureAtlasFactory;
	import com.genome2d.textures.factories.GTextureFactory;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.media.Sound;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;

	public class Assets
	{
		[Embed(source="../media/fonts/Ubuntu-R.ttf", embedAsCFF="false", fontFamily="Ubuntu")]
		private static const UbuntuRegular:Class;

		[Embed(source="../media/audio/click.mp3")]
		private static const Click:Class;

		private static var __contentScaleFactor : Number;
		private static var __sounds : Object = {};

		public function Assets()
		{
		}

		public static function get contentScaleFactor() : Number
		{
			return __contentScaleFactor;
		}

		public static function set contentScaleFactor(value : Number) : void
		{
//			for each (var texture:Texture in sTextures)
//				texture.dispose();

//			sTextures = new Dictionary();
			__contentScaleFactor = value < 1.5 ? 1 : 2; // assets are available for factor 1 and 2
		}

		public static function getTexture(name : String) : GTexture
		{
			var texture : GTexture = GTexture.getTextureById(name);

			if(texture == null)
			{
				var data : Object = create(name);

				if(data is Bitmap) {
					texture = GTextureFactory.createFromBitmapData(name, (data as Bitmap).bitmapData);
				}
			}

			return texture;
		}

		public static function prepareAtlas() : void
		{
			var atlas : GTextureAtlas = GTextureAtlas.getTextureAtlasById("atlas");

			if(atlas == null) {
				atlas = GTextureAtlasFactory.createFromAssets("atlas", getAssetClass("AtlasTexture"), getAssetClass("AtlasXml"));
			}
		}

		public static function getAtlas() : GTextureAtlas
		{
			return GTextureAtlas.getTextureAtlasById("atlas");
		}

		public static function create(name : String) : Object
		{
			return new (getAssetClass(name))();
		}

		private static function getAssetClass(name : String) : Class
		{
			var textureClass : Class = __contentScaleFactor == 1 ? AssetEmbeds_1x : AssetEmbeds_2x;
			return textureClass[name];
		}

		public static function getSound(name : String) : Sound
		{
			var sound : Sound = __sounds[name] as Sound;

			if(sound) {
				return sound;
			} else {
				throw new ArgumentError("Sound not found: " + name);
			}
		}

		public static function prepareSounds() : void
		{
			__sounds["Click"] = new Click();
		}

		public static function getFontTexture(name : String) : GTextureAtlas
		{
			return GTextureAtlas.getTextureAtlasById(name);
		}

		public static function loadBitmapFonts() : void
		{
			var atlas : GTextureAtlas = GTextureAtlas.getTextureAtlasById("font");

			if(atlas == null) {
				var bmp : BitmapData = (create("DesyrelTexture") as Bitmap).bitmapData;
				var ba : ByteArray = create("DesyrelXml") as ByteArray; // as XML;
				var xml : XML = new XML(ba.readUTFBytes(ba.length));
				atlas = GTextureAtlasFactory.createFromBitmapDataAndFontXML("font", bmp, xml);
			}

			atlas = GTextureAtlas.getTextureAtlasById("Verdana");

			if(atlas == null) {
				var format : TextFormat = new TextFormat("Ubuntu", 14, 0x000000, false);
				var chars : String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ:0123456789.-=! <";
				atlas = GTextureAtlasFactory.createFromFont("Ubuntu", format, chars, true);
				trace(atlas);
			}
		}
	}
}
