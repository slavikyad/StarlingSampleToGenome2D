package
{
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.core.GNode;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.signals.GMouseSignal;
	import com.genome2d.textures.GTexture;

	import components.GButton;

	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	import scenes.AnimationScene;
	import scenes.BenchmarkScene;
	import scenes.BlendModeScene;
	import scenes.CustomHitTestScene;
	import scenes.FilterScene;
	import scenes.MovieScene;
	import scenes.RenderTextureScene;
	import scenes.Scene;
	import scenes.TextScene;
	import scenes.TextureScene;
	import scenes.TouchScene;

	public class Game extends GNode
	{
		private var mBackground : GSprite;
		private var mLogo : GSprite;
		private var mMainMenu : GNode;
		private var mCurrentScene : Scene;

		public function Game(p_name : String = "")
		{
			super(p_name);

			Assets.prepareSounds();
			Assets.loadBitmapFonts();
			Assets.prepareAtlas();
			
			mBackground = GNodeFactory.createNodeWithComponent(GSprite, "background") as GSprite;
			mBackground.setTexture(Assets.getTexture("Background"));

			mLogo = GNodeFactory.createNodeWithComponent(GSprite, "logo") as GSprite;
			mLogo.node.mouseEnabled = true;
			mLogo.setTexture(Assets.getTexture("Logo"));//getAtlasTexture("logo"));
			mLogo.node.onMouseClick.add(onLogoTouched);
			mLogo.node.transform.y = -160;

			mMainMenu = GNodeFactory.createNode("menu");

			var scenesToCreate:Array = [
				["Textures", TextureScene],
				["Multitouch", TouchScene],
				["TextFields", TextScene],
				["Animations", AnimationScene],
				["Custom hit-test", CustomHitTestScene],
				["Movie Clip", MovieScene],
				["Filters", FilterScene],
				["Blend Modes", BlendModeScene],
				["Render Texture", RenderTextureScene],
				["Benchmark", BenchmarkScene]
			];

			var count:int = 0;
			var buttonTexture : GTexture = Assets.getTexture("ButtonBig");
			var button : GButton;

			for each (var sceneToCreate : Array in scenesToCreate)
			{
				var sceneTitle : String = sceneToCreate[0];
				var sceneClass : Class  = sceneToCreate[1];

				button = GNodeFactory.createNodeWithComponent(GButton, "button_"+count) as GButton;
				button.setTextures(buttonTexture);
				button.setText(sceneTitle);
				button.node.transform.x = count % 2 == 0 ? -80 : 80;
				button.node.transform.y = -50 + int(count / 2) * 52;
				button.node.name = getQualifiedClassName(sceneClass);
				button.node.onMouseClick.add(onButtonTriggerd);

				mMainMenu.addChild(button.node);
				++count;
			}

			addChild(mBackground.node);
			addChild(mLogo.node);
			addChild(mMainMenu);
		}

		private function onButtonTriggerd(signal : GMouseSignal) : void
		{
			showScene(signal.dispatcher.parent.name); // because bubbling
		}

		private function onLogoTouched(signal : GMouseSignal) : void
		{
			Assets.getSound("Click").play();
		}

		private function onSceneClosing() : void
		{
			removeChild(mCurrentScene);
			mCurrentScene.dispose();
			mCurrentScene = null;
			mLogo.node.transform.visible = true;
			mMainMenu.transform.visible = true;
		}

		private function showScene(name:String):void
		{
			if(mCurrentScene) {
				return;
			}

			var sceneClass : Class = getDefinitionByName(name) as Class;
			mCurrentScene = new sceneClass() as Scene;
			mCurrentScene.backSignal.addOnce(onSceneClosing);
			mLogo.node.transform.visible = false;
			mMainMenu.transform.visible = false;
			addChild(mCurrentScene);
		}
	}
}