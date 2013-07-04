package scenes
{
	import com.genome2d.components.renderables.GTextureText;
	import com.genome2d.components.renderables.flash.GFlashText;
	import com.genome2d.context.GBlendMode;
	import com.genome2d.core.GNodeFactory;

	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class TextScene extends Scene
	{
		public function TextScene(p_name : String = "")
		{
			super(p_name);

			var bounds : Rectangle = new Rectangle(0, 0, core.stage.stageWidth, core.stage.stageHeight);
			var offset:int = 10;
			var ttFont:String = "Ubuntu";
			var ttFontSize:int = 19;

			var colorTF : GFlashText = GNodeFactory.createNodeWithComponent(GFlashText) as GFlashText;
			colorTF.blendMode = GBlendMode.NORMAL;
			colorTF.transparent = true;
			colorTF.width = 300;
			colorTF.height = 80;
			colorTF.wordWrap = true;
			colorTF.multiLine = true;
			colorTF.embedFonts = true;
			colorTF.text = "TextFields can have a border and a color. They can be aligned in different ways, ...";
			colorTF.textFormat = new TextFormat(ttFont, ttFontSize, 0x333399);
			colorTF.node.transform.x = 0;
			colorTF.node.transform.y = offset + (-bounds.height + 80) >> 1;
			addChild(colorTF.node);

			var leftTF : GFlashText = GNodeFactory.createNodeWithComponent(GFlashText) as GFlashText;
			leftTF.width = 145; leftTF.height = 80;
			leftTF.text = "... e.g.\ntop-left ...";
			leftTF.textFormat = new TextFormat(ttFont, ttFontSize, 0x993333, null, null, null, null, null, TextFormatAlign.LEFT);
			leftTF.blendMode = GBlendMode.NORMAL;
			leftTF.transparent = true;
			leftTF.wordWrap = true;
			leftTF.multiLine = true;
			leftTF.embedFonts = true;
			leftTF.node.transform.x = offset + (-bounds.width + 145) >> 1;
			leftTF.node.transform.y = colorTF.node.transform.y + colorTF.height + offset;
//			leftTF.hAlign = HAlign.LEFT;
//			leftTF.vAlign = VAlign.TOP;
//			leftTF.border = true;
			addChild(leftTF.node);

			var rightTF : GFlashText = GNodeFactory.createNodeWithComponent(GFlashText) as GFlashText;
			rightTF.width = 145; rightTF.height = 80;
			rightTF.text = "... or\nbottom right ...";
			rightTF.textFormat = new TextFormat(ttFont, ttFontSize, 0x228822, null, null, null, null, null, TextFormatAlign.RIGHT);
			rightTF.blendMode = GBlendMode.NORMAL;
			rightTF.transparent = true;
			rightTF.wordWrap = true;
			rightTF.multiLine = true;
			rightTF.embedFonts = true;
			rightTF.node.transform.x = offset + (145 >> 1);
			rightTF.node.transform.y = leftTF.node.transform.y;
//			rightTF.hAlign = HAlign.RIGHT;
//			rightTF.vAlign = VAlign.BOTTOM;
//			rightTF.border = true;
			addChild(rightTF.node);

			var fontTF : GFlashText = GNodeFactory.createNodeWithComponent(GFlashText) as GFlashText;
			fontTF.width = 300; fontTF.height = 80;
			fontTF.text = "... or centered. Embedded fonts are detected automatically.";
			fontTF.textFormat = new TextFormat(ttFont, ttFontSize, 0x0, true, null, null, null, null, TextFormatAlign.CENTER);
			fontTF.blendMode = GBlendMode.NORMAL;
			fontTF.transparent = true;
			fontTF.wordWrap = true;
			fontTF.multiLine = true;
			fontTF.embedFonts = true;
//			fontTF.x = offset;
//			fontTF.y = leftTF.y + leftTF.height + offset;
//			fontTF.border = true;
			addChild(fontTF.node);

			// tool: www.angelcode.com/products/bmfont/ or one that uses the same
			var bmpFontTF:GTextureText = GNodeFactory.createNodeWithComponent(GTextureText) as GTextureText;
			bmpFontTF.setTextureAtlas(Assets.getFontTexture("font"));
			bmpFontTF.text = "It is not very easy to\nuse Bitmap fonts,\nas well!";
			bmpFontTF.lineSpace = 22;
			bmpFontTF.tracking = -3;
//			bmpFontTF.width = 300;
//			bmpFontTF.height = 150;
//			bmpFontTF.fontSize = BitmapFont.NATIVE_SIZE; // the native bitmap font size, no scaling
//			bmpFontTF.color = Color.WHITE; // use white to use the texture as it is (no tinting)
			bmpFontTF.node.transform.x = offset + (-bounds.width) >> 1;
			bmpFontTF.node.transform.y = fontTF.node.transform.y + fontTF.height + offset;
			addChild(bmpFontTF.node);
		}
	}
}
