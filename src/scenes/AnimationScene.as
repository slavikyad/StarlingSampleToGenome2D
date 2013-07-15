package scenes
{
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.components.renderables.GTextureText;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.signals.GMouseSignal;
	import com.genome2d.textures.GTexture;
	import com.greensock.TweenLite;
	import com.greensock.easing.EaseLookup;
	import com.greensock.easing.Linear;

	import components.GButton;

	import flash.geom.Rectangle;

	import utils.deg2rad;

	public class AnimationScene extends Scene
	{
		private var mTransitions : Array;
		private var mStartButton : GButton;
		private var mDelayButton : GButton;
		private var mEgg : GSprite;
		private var mEggBounds : Rectangle;
		private var mTransitionLabel: GTextureText;


		public function AnimationScene(p_name : String = "")
		{
			super(p_name);

			mTransitions = [
				"Linear.easeNone",
				"Linear.easeInOut",
				"Back.easeOut",
				"Bounce.easeOut",
				"Elastic.easeOut"];

			var tex : GTexture = Assets.getTexture("ButtonNormal");

			mStartButton = GNodeFactory.createNodeWithComponent(GButton) as GButton;
			mStartButton.setTextures(tex);
			mStartButton.setText("Start animation");
			mStartButton.node.onMouseClick.add(onStartButtonTriggered);
			mStartButton.node.transform.y = 40 + ((tex.height - core.stage.stageHeight) >> 1);
			addChild(mStartButton.node);

			mDelayButton = GNodeFactory.createNodeWithComponent(GButton) as GButton;
			mDelayButton.setTextures(tex);
			mDelayButton.setText("Delayed call");
			mDelayButton.node.onMouseClick.add(onDelayButtonTriggered);
			mDelayButton.node.transform.y = mStartButton.node.transform.y + 40;
			addChild(mDelayButton.node);

			tex = Assets.getTexture("StarlingFront");
			mEgg = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
			mEgg.setTexture(tex);
			addChild(mEgg.node);

			mEggBounds = new Rectangle(0, 0, tex.width, tex.height);
			resetEgg();

			mTransitionLabel = GNodeFactory.createNodeWithComponent(GTextureText) as GTextureText;
			mTransitionLabel.setTextureAtlas(Assets.getFontTexture("Ubuntu"));
			mTransitionLabel.node.transform.y = mDelayButton.node.transform.y + 40;
			mTransitionLabel.node.transform.alpha = 0.0;
			addChild(mTransitionLabel.node);
		}

		private function resetEgg() : void
		{
			mEgg.node.transform.x = 20 + ((mEggBounds.width - core.stage.stageWidth) >> 1);
			mEgg.node.transform.y = 120 + ((mEggBounds.height - core.stage.stageHeight) >> 1);
			mEgg.node.transform.scaleX = mEgg.node.transform.scaleY = 1.0;
			mEgg.node.transform.rotation = 0.0;
		}

		private function onStartButtonTriggered(signal : GMouseSignal) : void
		{
			mStartButton.enabled = false;
			resetEgg();

			var tweenSettings : Object = {};
			var transition : String = mTransitions.shift();
			tweenSettings['ease'] = EaseLookup.find(transition);
			mTransitions.push(transition);

			tweenSettings['rotation'] = deg2rad(90);
			tweenSettings['x'] = 300 - (mEggBounds.width/4) - (core.stage.stageWidth >> 1);
			tweenSettings['y'] = 360 +(mEggBounds.height/4) - (core.stage.stageHeight >> 1);
			tweenSettings['scaleX'] = 0.5;
			tweenSettings['scaleY'] = 0.5;
			tweenSettings['onComplete'] = function() : void {
				mStartButton.enabled = true;
			};

			TweenLite.to(mEgg.node.transform, 2.0, tweenSettings);

			mTransitionLabel.text = transition;
			mTransitionLabel.node.transform.x = -mTransitionLabel.width >> 1;
			mTransitionLabel.node.transform.alpha = 1.0;

			TweenLite.to(mTransitionLabel.node.transform, 2.0, {ease : Linear.easeIn, 'alpha' : 0.0});
		}

		private function onDelayButtonTriggered(signal : GMouseSignal) : void
		{
			mDelayButton.enabled = false;

			TweenLite.delayedCall(1.0, colorizeEgg, [true]);
			TweenLite.delayedCall(2.0, colorizeEgg, [false]);
			TweenLite.delayedCall(2.0, function() : void {
				mDelayButton.enabled = true;
			});
		}

		private function colorizeEgg(colorize : Boolean) : void
		{
			mEgg.node.transform.color = colorize ? 0xff0000 : 0xffffff;
		}

		override public function dispose() : void
		{
			TweenLite.killDelayedCallsTo(colorizeEgg);
			TweenLite.killTweensOf(mEgg.node.transform);
			TweenLite.killTweensOf(mTransitionLabel.node.transform);

			mStartButton.node.onMouseClick.remove(onStartButtonTriggered);
			mDelayButton.node.onMouseClick.remove(onDelayButtonTriggered);

			super.dispose();
		}
	}
}