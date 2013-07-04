package scenes
{
	import com.genome2d.components.renderables.GTextureText;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.signals.GMouseSignal;

	import components.RoundButton;

	public class CustomHitTestScene extends Scene
	{
		private var button : RoundButton;

		public function CustomHitTestScene(p_name : String = "")
		{
			super(p_name);

			var description:String =
				"Pushing the bird only works when the touch occurs within a circle." +
				"This can be accomplished by overriding the method hitTest.";


			var infoText : GTextureText = GNodeFactory.createNodeWithComponent(GTextureText) as GTextureText;
			infoText.setTextureAtlas(Assets.getFontTexture("Ubuntu"));
			infoText.text = description;
//			infoText.x = infoText.y = 10;
//			infoText.vAlign = VAlign.TOP;
//			infoText.hAlign = HAlign.CENTER;
			addChild(infoText.node);

			// 'RoundButton' is a helper class of the Demo, not a part of Starling!
			// Have a look at its code to understand this sample.

			button = GNodeFactory.createNodeWithComponent(RoundButton) as RoundButton;
			button.setTexture(Assets.getTexture("StarlingRound"));
			button.node.mouseEnabled = true;
			button.node.onMouseDown.add(onDown);
			button.node.onMouseUp.add(onUp);
//			button.x = Constants.CenterX - int(button.width / 2);
//			button.y = 150;
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
