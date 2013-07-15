package scenes
{
	import com.genome2d.components.renderables.GTextureText;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.signals.GMouseSignal;
	import com.genome2d.textures.GTexture;

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

			var tex : GTexture = Assets.getTexture("ButtonNormal");
			mStartButton = GNodeFactory.createNodeWithComponent(GButton) as GButton;
			mStartButton.setTextures(tex);
			mStartButton.setText("Start benchmark");
			mStartButton.node.onMouseClick.add(onStartButtonTriggered);
			mStartButton.node.transform.y = 40 + ((tex.height - core.stage.stageHeight) >> 1);
			addChild(mStartButton.node);
		}

		private function onStartButtonTriggered(signal : GMouseSignal) : void
		{
			mStartButton.node.transform.visible = false;

			if (mResultText) {
				removeChild(mResultText.node);
				mResultText = null;
			}

			mContainer.complete.addOnce(benchmarkComplete);
			mContainer.start();
		}

		private function benchmarkComplete() : void
		{
			mStartButton.node.transform.visible = true;

			mResultText = GNodeFactory.createNodeWithComponent(GTextureText) as GTextureText;
			mResultText.setTextureAtlas(Assets.getFontTexture("Ubuntu"));
			mResultText.text = mContainer.resultString;
			mResultText.node.transform.x = - mResultText.width >> 1;
			addChild(mResultText.node);

			mContainer.dispose();
			System.pauseForGCIfCollectionImminent();
		}

		override public function dispose() : void
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

import flash.geom.Rectangle;

import org.osflash.signals.Signal;

class BenchMarkComponent extends GComponent
{
	private var mStarted : Boolean;
	private var mElapsed : Number;
	private var mFrameCount : int;
	private var mFailCount : int;
	private var mWaitFrames : int;
	private var mWorldBounds : Rectangle;
	public var complete : Signal;
	public var resultString : String;

	public function BenchMarkComponent(p_node : GNode)
	{
		super(p_node);

		complete = new Signal();
		mStarted = false;
		mElapsed = 0.0;
		mWorldBounds = new Rectangle();
		mWorldBounds.width = node.core.stage.stageWidth;
		mWorldBounds.height = node.core.stage.stageHeight;
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

		resultString = "Result:\n"+node.numChildren+" objects\nwith "+fps+" fps";
		node.disposeChildren();
		complete.dispatch();
	}

	private function addTestObjects() : void
	{
		var padding:int = 15;
		var numObjects:int = mFailCount > 20 ? 2 : 10;
		var egg : GSprite;
		var tex : GTexture = Assets.getTexture("BenchmarkObject");
			tex.pivotX = -tex.width/4;
			tex.pivotY = -tex.height/4;

		for (var i:int = 0; i<numObjects; ++i)
		{
			egg = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
			egg.setTexture(tex);
			egg.node.transform.x = -(mWorldBounds.width >> 1) - padding + Math.random() * mWorldBounds.width;
			egg.node.transform.y = -(mWorldBounds.height >> 1) - padding + Math.random() * mWorldBounds.height;
			node.addChild(egg.node);
		}
	}
}