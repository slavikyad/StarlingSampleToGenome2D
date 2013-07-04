package scenes
{
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.components.renderables.GTextureText;
	import com.genome2d.context.filters.GBrightPassFilter;
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
//			mButton.node.transform.x = int(Constants.CenterX - mButton.width / 2);
			mButton.node.transform.y = -140;
			mButton.node.onMouseClick.add(onButtonTriggered);
			addChild(mButton.node);

			mImage = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
			mImage.setTexture(Assets.getTexture("StarlingRocket"));
//			mImage.x = int(Constants.CenterX - mImage.width / 2);
//			mImage.y = 170;
			addChild(mImage.node);

			mInfoText = GNodeFactory.createNodeWithComponent(GTextureText) as GTextureText;
			mInfoText.setTextureAtlas(Assets.getFontTexture("Ubuntu"));
//			mInfoText.x = 10;
			mInfoText.node.transform.y = 140;
			addChild(mInfoText.node);

//			onButtonTriggered(null);
		}

		private function onButtonTriggered(signal : GMouseSignal) : void
		{
			var filterInfo:Array = mFilterInfos.shift() as Array;
			mFilterInfos.push(filterInfo);

			mInfoText.text = filterInfo[0];
//			mImage.filter  = filterInfo[1];
			mImage.node.postProcess = filterInfo[1];
		}

		private function initFilters():void
		{
//			var pp:GGlowPP=new GGlowPP(2,2,1);
//			pp.color=0xff0000;
//			sprite.node.postProcess=pp;

			mFilterInfos = [
				["Identity", new GFilterPP(Vector.<GFilter>([new GColorMatrixFilter()]))],
				["Blur", new GBlurPP(1, 1)],
				["Drop Shadow", createDropShadow()],
				["Glow", new GGlowPP(2, 2, 1)]
			];

//			var invertFilter:GColorMatrixFilter = new GColorMatrixFilter();
//			invertFilter.invert();
//			mFilterInfos.push(["Invert", invertFilter]);
//
			var grayscaleFilter:GDesaturateFilter = new GDesaturateFilter();
			mFilterInfos.push(["Grayscale", new GFilterPP(Vector.<GFilter>([grayscaleFilter]))]);
//
//			var saturationFilter:ColorMatrixFilter = new ColorMatrixFilter();
//			saturationFilter.adjustSaturation(1);
//			mFilterInfos.push(["Saturation", saturationFilter]);
//
//			var contrastFilter:ColorMatrixFilter = new ColorMatrixFilter();
//			contrastFilter.adjustContrast(0.75);
//			mFilterInfos.push(["Contrast", contrastFilter]);
//
			var brightnessFilter:GBrightPassFilter = new GBrightPassFilter(-0.25);
			mFilterInfos.push(["Brightness", new GFilterPP(Vector.<GFilter>([brightnessFilter]))]);
//
//			var hueFilter:ColorMatrixFilter = new ColorMatrixFilter();
//			hueFilter.adjustHue(1);
//			mFilterInfos.push(["Hue", hueFilter]);

			var pixelateFilter:GPixelateFilter = new GPixelateFilter(4);
			mFilterInfos.push(["Pixelate", new GFilterPP(Vector.<GFilter>([pixelateFilter]))]);
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
