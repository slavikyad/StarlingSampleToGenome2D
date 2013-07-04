package scenes
{
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.components.renderables.GTextureText;
	import com.genome2d.context.GBlendMode;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.signals.GMouseSignal;

	import components.GButton;

	public class BlendModeScene extends Scene
	{
		private var mButton : GButton;
		private var mImage : GSprite;
		private var mInfoText : GTextureText;

		private var mBlendModes:Array = [
			GBlendMode.NORMAL,
			GBlendMode.MULTIPLY,
			GBlendMode.SCREEN,
			GBlendMode.ADD,
			GBlendMode.ERASE,
			GBlendMode.NONE
		];

		public function BlendModeScene(p_name : String = "")
		{
			super(p_name);

			mButton = GNodeFactory.createNodeWithComponent(GButton) as GButton;
			mButton.setTextures(Assets.getTexture("ButtonNormal"));
			mButton.setText("Switch Mode");
			mButton.node.transform.y = -140;
			mButton.node.onMouseClick.add(onButtonTriggered);
			addChild(mButton.node);

			mImage = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
			mImage.setTexture(Assets.getTexture("StarlingRocket"));
			addChild(mImage.node);

			mInfoText = GNodeFactory.createNodeWithComponent(GTextureText) as GTextureText;
			mInfoText.setTextureAtlas(Assets.getFontTexture("Ubuntu"));
			mInfoText.node.transform.y = 140;
			addChild(mInfoText.node);

			onButtonTriggered(null);
		}

		private function onButtonTriggered(signal : GMouseSignal) : void
		{
			var blendMode : int = mBlendModes.shift();
			mBlendModes.push(blendMode);

			mInfoText.text = String(blendMode);
			mImage.blendMode = blendMode;
		}
	}
}