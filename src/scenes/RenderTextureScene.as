package scenes
{
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.components.renderables.GTextureText;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.signals.GMouseSignal;
	import com.genome2d.textures.GTexture;
	import com.genome2d.textures.factories.GTextureFactory;

	import components.GButton;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;

	public class RenderTextureScene extends Scene
	{
		private var mRenderTexture : GTexture;
		private var mCanvas : GSprite;
		private var mBrush : GTexture;
		private var mButton:GButton;
		private var mColors:Dictionary;
		private var mBmp : Bitmap;
		private var mCurrentBlendMode : String = BlendMode.NORMAL;
		private var mCurrentColor : uint = 0xffffff;

		public function RenderTextureScene(p_name : String = "")
		{
			super(p_name);

			mRenderTexture = GTextureFactory.createFromBitmapData("custom", new BitmapData(256, 256, true, 0x000000));
			mCanvas = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
			mCanvas.setTexture(mRenderTexture);
			mCanvas.node.mouseEnabled = true;
			mCanvas.node.onMouseDown.add(onDown);
			mCanvas.node.onMouseMove.add(onMove);
			addChild(mCanvas.node);

			mBrush = Assets.getTexture("Brush");

			var infoText : GTextureText = GNodeFactory.createNodeWithComponent(GTextureText) as GTextureText;
				infoText.setTextureAtlas(Assets.getFontTexture("Ubuntu"));
				infoText.text = "Touch the screen\nto draw!\nNot real blendMode\nfakeing through Bitmap!";
				infoText.node.transform.x = ((core.stage.stageWidth - infoText.width)>>1) + (-core.stage.stageWidth>>1);
			addChild(infoText.node);

			var tex : GTexture = Assets.getTexture("ButtonNormal");
			mButton = GNodeFactory.createNodeWithComponent(GButton) as GButton;
			mButton.setTextures(tex);
			mButton.setText("Mode Draw");
			mButton.node.transform.y = 40 + ((tex.height - core.stage.stageHeight) >> 1);
			mButton.node.onMouseClick.add(onButtonTriggered);
			addChild(mButton.node);

			mBmp = new Bitmap();
		}

		private function onButtonTriggered(signal : GMouseSignal) : void
		{
			if(mCurrentBlendMode == BlendMode.NORMAL)
			{
				mCurrentBlendMode = BlendMode.ERASE;
				mButton.text = "Mode Erase";
			}
			else
			{
				mCurrentBlendMode = BlendMode.NORMAL;
				mButton.text = "Mode Draw";
			}
		}

		private function onDown(signal : GMouseSignal) : void
		{
			mCurrentColor = Math.random() * uint.MAX_VALUE;
		}

		private function onMove(signal : GMouseSignal) : void
		{
			if(!signal.buttonDown) {
				return;
			}

			mBmp.bitmapData = mBrush.bitmapData;

			var matrix : Matrix = new Matrix();
				matrix.translate(-32, -32);
				matrix.rotate(Math.random() * Math.PI * 2.0);
				matrix.translate(signal.localX, signal.localY);

			var colorTransform : ColorTransform = new ColorTransform();
				colorTransform.color = mCurrentColor;

			mRenderTexture.bitmapData.draw(mBmp, matrix, colorTransform, mCurrentBlendMode);
			mRenderTexture.invalidate();
		}

		override public function dispose() : void
		{
			super.dispose();
			mRenderTexture.dispose();
		}
	}
}
