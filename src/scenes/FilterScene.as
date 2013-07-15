package scenes
{
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.components.renderables.GTextureText;
	import com.genome2d.context.filters.GColorMatrixFilter;
	import com.genome2d.context.filters.GDesaturateFilter;
	import com.genome2d.context.filters.GFilter;
	import com.genome2d.context.filters.GPixelateFilter;
	import com.genome2d.context.postprocesses.GBlurPP;
	import com.genome2d.context.postprocesses.GDropShadowPP;
	import com.genome2d.context.postprocesses.GFilterPP;
	import com.genome2d.context.postprocesses.GGlowPP;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.signals.GMouseSignal;

	import components.GButton;

	public class FilterScene extends Scene
	{
		private var mButton : GButton;
		private var mImage : GSprite;
		private var mInfoText : GTextureText;
		private var mFilterInfos:Array;

		public function FilterScene(p_name : String = "")
		{
			super(p_name);

			initFilters();

			mButton = GNodeFactory.createNodeWithComponent(GButton) as GButton;
			mButton.setTextures(Assets.getTexture("ButtonNormal"));
			mButton.setText("Switch Filter");
			mButton.node.transform.y = 40 + ((mButton.height - core.stage.stageHeight) >> 1);
			mButton.node.onMouseClick.add(onButtonTriggered);
			addChild(mButton.node);

			mImage = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
			mImage.setTexture(Assets.getTexture("StarlingRocket"));
			addChild(mImage.node);

			mInfoText = GNodeFactory.createNodeWithComponent(GTextureText) as GTextureText;
			mInfoText.setTextureAtlas(Assets.getFontTexture("Ubuntu"));
			mInfoText.node.transform.y = mImage.node.transform.y + mImage.getWorldBounds().height;
			addChild(mInfoText.node);
		}

		private function onButtonTriggered(signal : GMouseSignal) : void
		{
			var filterInfo:Array = mFilterInfos.shift() as Array;
			mFilterInfos.push(filterInfo);

			mInfoText.text = filterInfo[0];
			mInfoText.node.transform.x = - mInfoText.width >> 1;
			mImage.node.postProcess = filterInfo[1];
		}

		private function initFilters():void
		{
			mFilterInfos = [
				["Identity", new GFilterPP(Vector.<GFilter>([new GColorMatrixFilter()]))],
				["Blur", new GBlurPP(1, 1)],
				["Drop Shadow", createDropShadow()],
				["Glow", new GGlowPP(2, 2, 1)]
			];

			mFilterInfos.push(["Invert", getInvertPostProcess()]);
			var grayscaleFilter:GDesaturateFilter = new GDesaturateFilter();
			mFilterInfos.push(["Grayscale", new GFilterPP(Vector.<GFilter>([grayscaleFilter]))]);
			mFilterInfos.push(["Saturation", getSaturationPostProcess(1)]);
			mFilterInfos.push(["Contrast", getContrastPostProcess(0.75)]);
			mFilterInfos.push(["Brightness", getBrightnessPostProcess(-0.25)]);
			mFilterInfos.push(["Hue", getHuePostProcess(1)]);
			var pixelateFilter : GPixelateFilter = new GPixelateFilter(4);
			mFilterInfos.push(["Pixelate", new GFilterPP(Vector.<GFilter>([pixelateFilter]))]);
		}

		private function getInvertPostProcess() : GFilterPP
		{
			var matrix : Vector.<Number> = Vector.<Number>([
				-1,  0,  0,  0, 255,
				0, -1,  0,  0, 255,
				0,  0, -1,  0, 255,
				0,  0,  0,  1,   0]);

			return getNewFilterPostProcessFromColorMatrixFilter(matrix);
		}

		private static const LUMA_R : Number = 0.299;
		private static const LUMA_G : Number = 0.587;
		private static const LUMA_B : Number = 0.114;
		private function getSaturationPostProcess(sat : Number) : GFilterPP
		{
			sat += 1;

			var invSat : Number = 1 - sat;
			var invLumR : Number = invSat * LUMA_R;
			var invLumG : Number = invSat * LUMA_G;
			var invLumB : Number = invSat * LUMA_B;

			var matrix : Vector.<Number> = Vector.<Number>([
				(invLumR + sat), invLumG, invLumB, 0, 0,
				invLumR, (invLumG + sat), invLumB, 0, 0,
				invLumR, invLumG, (invLumB + sat), 0, 0,
				0, 0, 0, 1, 0]);

			return getNewFilterPostProcessFromColorMatrixFilter(matrix);
		}

		private function getHuePostProcess(value : Number) : GFilterPP
		{
			value *= Math.PI;

			var cos : Number = Math.cos(value);
			var sin : Number = Math.sin(value);

			var matrix : Vector.<Number> = Vector.<Number>([
					((LUMA_R + (cos * (1 - LUMA_R))) + (sin * -(LUMA_R))), ((LUMA_G + (cos * -(LUMA_G))) + (sin * -(LUMA_G))), ((LUMA_B + (cos * -(LUMA_B))) + (sin * (1 - LUMA_B))), 0, 0,
					((LUMA_R + (cos * -(LUMA_R))) + (sin * 0.143)), ((LUMA_G + (cos * (1 - LUMA_G))) + (sin * 0.14)), ((LUMA_B + (cos * -(LUMA_B))) + (sin * -0.283)), 0, 0,
					((LUMA_R + (cos * -(LUMA_R))) + (sin * -((1 - LUMA_R)))), ((LUMA_G + (cos * -(LUMA_G))) + (sin * LUMA_G)), ((LUMA_B + (cos * (1 - LUMA_B))) + (sin * LUMA_B)), 0, 0,
					0, 0, 0, 1, 0]);

			return getNewFilterPostProcessFromColorMatrixFilter(matrix);
		}

		private function getContrastPostProcess(value : Number) : GFilterPP
		{
			var s : Number = value + 1;
			var o : Number = 128 * (1 - s);

			var matrix : Vector.<Number> = Vector.<Number>([
				s, 0, 0, 0, o,
				0, s, 0, 0, o,
				0, 0, s, 0, o,
				0, 0, 0, 1, 0]);

			return getNewFilterPostProcessFromColorMatrixFilter(matrix);
		}

		private function getBrightnessPostProcess(value : Number) : GFilterPP
		{
			value *= 255;

			var matrix : Vector.<Number> = Vector.<Number>([
				1, 0, 0, 0, value,
				0, 1, 0, 0, value,
				0, 0, 1, 0, value,
				0, 0, 0, 1, 0]);

			return getNewFilterPostProcessFromColorMatrixFilter(matrix);
		}


		private function getNewFilterPostProcessFromColorMatrixFilter(matrix : Vector.<Number>) : GFilterPP
		{
			var filter : GColorMatrixFilter = new GColorMatrixFilter();
				filter.setMatrix(matrix);

			return new GFilterPP(Vector.<GFilter>([filter]));
		}

		public static function createDropShadow(distance:Number=4.0, angle:Number=0.785,
												color:uint=0x0, alpha:Number=0.5, blur:Number=1.0
												):GDropShadowPP
		{
			var dropShadow:GDropShadowPP = new GDropShadowPP(blur, blur);
			dropShadow.offsetX = Math.cos(angle) * distance;
			dropShadow.offsetY = Math.sin(angle) * distance;
			dropShadow.color = color;
			dropShadow.alpha = alpha;

			return dropShadow;
		}
	}
}
