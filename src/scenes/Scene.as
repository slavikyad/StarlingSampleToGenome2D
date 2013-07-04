package scenes
{
	import com.genome2d.core.GNode;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.signals.GMouseSignal;
	import com.genome2d.textures.GTexture;

	import components.GButton;

	import org.osflash.signals.Signal;

	public class Scene extends GNode
	{
		private var __backButton : GButton;
		public var backSignal : Signal;

		public function Scene(p_name : String = "")
		{
			super(p_name);

			var upTexture : GTexture = Assets.getTexture("ButtonBack");
			__backButton = GNodeFactory.createNodeWithComponent(GButton) as GButton;
			__backButton.setTextures(upTexture);
			__backButton.setText("Back");
			__backButton.node.onMouseClick.add(onBackButtonTriggered);
			__backButton.node.transform.y = -upTexture.height + core.stage.stageHeight >> 1;

			addChild(__backButton.node);
			backSignal = new Signal();
		}

		private function onBackButtonTriggered(signal : GMouseSignal):void
		{
			__backButton.node.onMouseClick.remove(onBackButtonTriggered);
			backSignal.dispatch();
		}
	}
}