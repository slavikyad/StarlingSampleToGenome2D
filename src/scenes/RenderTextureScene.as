package scenes
{
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.components.renderables.GTextureText;
	import com.genome2d.context.GBlendMode;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.signals.GMouseSignal;
	import com.genome2d.textures.GTexture;
	import com.genome2d.textures.factories.GTextureFactory;

	import components.GButton;

	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;

	public class RenderTextureScene extends Scene
	{
		private var mRenderTexture : GTexture;
		private var mCanvas : GSprite;
		private var mBrush : GTexture;
		private var mButton:GButton;
		private var mColors:Dictionary;

		public function RenderTextureScene(p_name : String = "")
		{
			super(p_name);

			mRenderTexture = GTextureFactory.createFromBitmapData("custom", new BitmapData(256, 256, true, 0x000000));
			mCanvas = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
			mCanvas.setTexture(mRenderTexture);
			mCanvas.node.mouseEnabled = true;
			mCanvas.node.onMouseMove.add(onMove);
			addChild(mCanvas.node);

			mBrush = Assets.getTexture("Brush");

			var infoText : GTextureText = GNodeFactory.createNodeWithComponent(GTextureText) as GTextureText;
				infoText.setTextureAtlas(Assets.getFontTexture("Ubuntu"));
				infoText.text = "Touch the screen\nto draw!";
//			infoText.x = Constants.CenterX - infoText.width / 2;
//			infoText.y = Constants.CenterY - infoText.height / 2;
			addChild(infoText.node)

			mButton = GNodeFactory.createNodeWithComponent(GButton) as GButton;
			mButton.setTextures(Assets.getTexture("ButtonNormal"));
			mButton.setText("Mode Draw");
//			mButton.x = int(Constants.CenterX - mButton.width / 2);
			mButton.node.transform.y = -140;
			mButton.node.onMouseClick.add(onButtonTriggered);
			addChild(mButton.node);
		}

		private function onButtonTriggered(signal : GMouseSignal) : void
		{
			if(mCanvas.blendMode == GBlendMode.NORMAL)
			{
				mCanvas.blendMode = GBlendMode.ERASE;
				mButton.text = "Mode Erase";
			}
			else
			{
				mCanvas.blendMode = GBlendMode.NORMAL;
				mButton.text = "Mode Draw";
			}
		}

		private function onMove(signal:GMouseSignal) : void
		{
			if(!signal.buttonDown) {
				return;
			}

			var bmp : BitmapData = mBrush.bitmapData;
			var matrix : Matrix = new Matrix();
				matrix.translate(signal.localX,signal.localY);

			mRenderTexture.bitmapData.draw(bmp,matrix);
			mRenderTexture.invalidate();
		}


		override public function dispose() : void
		{
			super.dispose();
			mRenderTexture.dispose();
		}
	}
}
