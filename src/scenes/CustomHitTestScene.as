package scenes
{
	import com.genome2d.components.renderables.GTextureText;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.signals.GMouseSignal;
	import com.genome2d.textures.GTextureAlignType;

	import components.RoundButton;

	public class CustomHitTestScene extends Scene
	{
		private var button : RoundButton;
		private static const PAD : Number = 10;

		public function CustomHitTestScene(p_name : String = "")
		{
			super(p_name);

			var description:String =
				"Pushing the bird only works when the touch occurs within a circle." +
				"This can be accomplished by overriding the method hitTest.";

			var infoText : GTextureText = GNodeFactory.createNodeWithComponent(GTextureText) as GTextureText;
			infoText.setTextureAtlas(Assets.getFontTexture("Ubuntu"));
			infoText.text = description;
			infoText.maxWidth = core.stage.stageWidth - 2 * PAD;
			infoText.node.transform.x = PAD - (core.stage.stageWidth >> 1);
			infoText.node.transform.y = 40 - (core.stage.stageHeight >> 1);
			infoText.align = GTextureAlignType.CENTER;
			addChild(infoText.node);

			button = GNodeFactory.createNodeWithComponent(RoundButton) as RoundButton;
			button.setTexture(Assets.getTexture("StarlingRound"));
			button.node.mouseEnabled = true;
			button.node.onMouseDown.add(onDown);
			button.node.onMouseUp.add(onUp);
			addChild(button.node);
		}

		private function onDown(signal : GMouseSignal) : void
		{
			button.node.transform.setScale(0.95, 0.95);
		}

		private function onUp(signal : GMouseSignal) : void
		{
			button.node.transform.setScale(1, 1);
		}
	}
}
