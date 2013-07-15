package scenes
{
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.components.renderables.GTextureText;
	import com.genome2d.context.GBlendMode;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.signals.GMouseSignal;
	import com.genome2d.textures.GTexture;

	import components.GButton;

	public class BlendModeScene extends Scene
	{
		private var mButton : GButton;
		private var mImage : GSprite;
		private var mInfoText : GTextureText;

		private var mBlendModes:Array = [
			[GBlendMode.NORMAL, "NORMAL"],
			[GBlendMode.MULTIPLY, "MULTIPLY"],
			[GBlendMode.SCREEN, "SCREEN"],
			[GBlendMode.ADD, "ADD"],
			[GBlendMode.ERASE, "ERASE"],
			[GBlendMode.NONE, "NONE"]
		];

		public function BlendModeScene(p_name : String = "")
		{
			super(p_name);

			var tex : GTexture = Assets.getTexture("ButtonNormal");
			mButton = GNodeFactory.createNodeWithComponent(GButton) as GButton;
			mButton.setTextures(tex);
			mButton.setText("Switch Mode");
			mButton.node.transform.y = 40 + ((tex.height - core.stage.stageHeight) >> 1);
			mButton.node.onMouseClick.add(onButtonTriggered);
			addChild(mButton.node);

			tex = Assets.getTexture("StarlingRocket");
			mImage = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
			mImage.setTexture(tex);
			addChild(mImage.node);

			mInfoText = GNodeFactory.createNodeWithComponent(GTextureText) as GTextureText;
			mInfoText.setTextureAtlas(Assets.getFontTexture("Ubuntu"));
			mInfoText.node.transform.y = mImage.node.transform.y + tex.height;
			addChild(mInfoText.node);

			onButtonTriggered(null);
		}

		private function onButtonTriggered(signal : GMouseSignal) : void
		{
			var blendMode : Array = mBlendModes.shift();
			mBlendModes.push(blendMode);

			mInfoText.text = String(blendMode[1]);
			mInfoText.node.transform.x = - mInfoText.width >> 1;
			mImage.blendMode = blendMode[0];
		}
	}
}