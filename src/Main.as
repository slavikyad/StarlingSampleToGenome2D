package
{
	import com.genome2d.core.GConfig;
	import com.genome2d.core.GNode;
	import com.genome2d.core.Genome2D;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DProfile;
	import flash.events.Event;
	import flash.events.StageOrientationEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;

	/**
	 * this is a starling-framework sample ported to genome2d
	 *
	 * @see https://github.com/PrimaryFeather/Starling-Framework/tree/master/samples
	 * @see https://github.com/pshtif/Genome2D
	 */
	[SWF(frameRate="60", backgroundColor="#222222")]
	public class Main extends Sprite
	{
		public function Main()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function onEnterFrame(event : Event) : void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGE, onOrientationChange);

			var config : GConfig = new GConfig(getViewPortRect(), Context3DProfile.BASELINE);
				config.enableStats = config.showExtendedStats = Capabilities.isDebugger;

			Genome2D.getInstance().onInitialized.addOnce(onInitialized);
			Genome2D.getInstance().init(stage, config);
		}

		private function onOrientationChange(event : StageOrientationEvent) : void
		{
			Genome2D.getInstance().config.viewRect = getViewPortRect();
		}

		private function onInitialized() : void
		{
			if(Genome2D.getInstance().driverInfo.toLowerCase().indexOf("software") != -1) {
				trace("// todo: software rendering, we should use 30fps.");
			}

			Assets.contentScaleFactor = contentScaleFactor;

			var center : Point = new Point(stage.stageWidth >> 1, stage.stageHeight >> 1);
			var game : GNode = new Game("game");
				game.transform.setPosition(center.x, center.y);

			Genome2D.getInstance().root.addChild(game);
			multitouchEnabled = true
		}

		private function getViewPortRect() : Rectangle
		{
			return new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
		}

		public function get contentScaleFactor() : Number
		{
			return stage.stageWidth / (isPortrait ? 320 : 480);
		}

		private function get isPortrait() : Boolean
		{
			return stage.stageWidth < stage.stageHeight;
		}

		public static function set multitouchEnabled(value:Boolean):void
		{
			Multitouch.inputMode = value ? MultitouchInputMode.TOUCH_POINT : MultitouchInputMode.NONE;
		}
	}
}
