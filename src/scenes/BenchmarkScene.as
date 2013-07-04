package scenes
{
	import com.genome2d.components.renderables.GTextureText;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.signals.GMouseSignal;

	import components.GButton;

	import flash.system.System;

	public class BenchmarkScene extends Scene
	{
		private var mStartButton : GButton;
		private var mResultText : GTextureText;
		private var mContainer : BenchMarkComponent;


		public function BenchmarkScene(p_name : String = "")
		{
			super(p_name);

			mContainer = GNodeFactory.createNodeWithComponent(BenchMarkComponent, "benchmark") as BenchMarkComponent;
			addChild(mContainer.node);

			mStartButton = GNodeFactory.createNodeWithComponent(GButton) as GButton;
			mStartButton.setTextures(Assets.getTexture("ButtonNormal"));
			mStartButton.setText("Start benchmark");
			mStartButton.node.onMouseClick.add(onStartButtonTriggered);
			mStartButton.node.transform.y = -140;
			addChild(mStartButton.node);
		}

		private function onStartButtonTriggered(signal : GMouseSignal) : void
		{
			trace("Starting benchmark");

			mStartButton.node.transform.visible = false;

			if (mResultText) {
				removeChild(mResultText.node);
				mResultText = null;
			}

			mContainer.complete.addOnce(benchmarkComplete);
			mContainer.start();
		}

		private function benchmarkComplete():void
		{
			mStartButton.node.transform.visible = true;

			mResultText = GNodeFactory.createNodeWithComponent(GTextureText) as GTextureText;
			mResultText.setTextureAtlas(Assets.getFontTexture("Ubuntu"));
			mResultText.text = mContainer.resultString;
//			mResultText.x = Constants.CenterX - mResultText.width / 2;
//			mResultText.y = Constants.CenterY - mResultText.height / 2;
			addChild(mResultText.node);

			mContainer.dispose();
			System.pauseForGCIfCollectionImminent();
		}

		override public function dispose():void
		{
			mStartButton.node.onMouseClick.remove(onStartButtonTriggered);
			super.dispose();
		}
	}
}

import com.genome2d.components.GComponent;
import com.genome2d.components.renderables.GSprite;
import com.genome2d.core.GNode;
import com.genome2d.core.GNodeFactory;
import com.genome2d.core.Genome2D;
import com.genome2d.textures.GTexture;

import org.osflash.signals.Signal;

class BenchMarkComponent extends GComponent
{
	private var mStarted : Boolean;
	private var mElapsed : Number;
	private var mFrameCount : int;
	private var mFailCount : int;
	private var mWaitFrames : int;
	public var complete : Signal;
	public var resultString : String;

	public function BenchMarkComponent(p_node : GNode)
	{
		super(p_node);

		complete = new Signal();
		mStarted = false;
		mElapsed = 0.0;
	}

	public function start() : void
	{
		mStarted = true;
		mFailCount = 0;
		mWaitFrames = 2;
		mFrameCount = 0;

		addTestObjects();
	}

	override public function update(p_deltaTime : Number, p_parentTransformUpdate : Boolean, p_parentColorUpdate : Boolean) : void
	{
		super.update(p_deltaTime, p_parentTransformUpdate, p_parentColorUpdate);

		if (!mStarted) return;
		var delta : Number = p_deltaTime / 1000;

		mElapsed += delta;
		mFrameCount++;

		if(mFrameCount % mWaitFrames == 0)
		{
			var fps : Number = mWaitFrames / mElapsed;
			var targetFps : int = Genome2D.getInstance().stage.frameRate;

			if (Math.ceil(fps) >= targetFps)
			{
				mFailCount = 0;
				addTestObjects();
			}
			else
			{
				mFailCount++;

				if (mFailCount > 20)
					mWaitFrames = 5; // slow down creation process to be more exact
				if (mFailCount > 30)
					mWaitFrames = 10;
				if (mFailCount == 40)
					benchmarkComplete(); // target fps not reached for a while
			}

			mElapsed = mFrameCount = 0;
		}

		for(var tNode : GNode = node.firstChild; tNode; tNode = tNode.next ) {
			tNode.transform.rotation += Math.PI / 2 * delta;
		}
	}

	private function benchmarkComplete() : void
	{
		mStarted = false;

		var fps:int = Genome2D.getInstance().stage.frameRate;

		trace("Benchmark complete!");
		trace("FPS: " + fps);
		trace("Number of objects: " + node.numChildren);

		resultString = "Result:\n"+node.numChildren+" objects\nwith "+fps+" fps";
		node.disposeChildren();
		complete.dispatch();
	}

	private function addTestObjects():void
	{
		var padding:int = 15;
		var numObjects:int = mFailCount > 20 ? 2 : 10;
		var egg : GSprite;
		var tex : GTexture = Assets.getTexture("BenchmarkObject");
			tex.pivotX = -5;
			tex.pivotY = -10;

		for (var i:int = 0; i<numObjects; ++i)
		{
			egg = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
			egg.setTexture(tex);
			egg.node.transform.x = -160 - padding + Math.random() * 320// * (Constants.GameWidth - 2 * padding);
			egg.node.transform.y = -240 - padding + Math.random() * 480// * (Constants.GameHeight - 2 * padding);
			node.addChild(egg.node);
		}
	}
}