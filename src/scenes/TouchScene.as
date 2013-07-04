package scenes
{
	import com.genome2d.components.renderables.GTextureText;
	import com.genome2d.core.GNodeFactory;

	import components.GTouchSprite;

	import flash.geom.Point;

	import utils.deg2rad;
	import utils.touch.Touch;
	import utils.touch.TouchPhase;
	import utils.touch.TouchSignal;

	public class TouchScene extends Scene
	{
		private var sheet : GTouchSprite;

		public function TouchScene(p_name : String = "")
		{
			super(p_name);

			const description:String = "use Ctrl or Cmd and Shift to simulate multi-touch";
			var infoText:GTextureText = GNodeFactory.createNodeWithComponent(GTextureText) as GTextureText;
			infoText.setTextureAtlas(Assets.getFontTexture("Ubuntu"));
			infoText.text = description;
			infoText.maxWidth = 300;
			infoText.node.transform.x = -150;
			infoText.node.transform.y = -150;
			addChild(infoText.node);

			sheet = GNodeFactory.createNodeWithComponent(GTouchSprite) as GTouchSprite;
			sheet.setTexture(Assets.getTexture("StarlingSheet"));
			sheet.node.transform.rotation = deg2rad(10);
			sheet.onTouch.add(onTouch);
			addChild(sheet.node);
		}

		private function onTouch(signal : TouchSignal) : void
		{
			var touches:Vector.<Touch> = signal.getTouches(this, TouchPhase.MOVED);

			if (touches.length == 1)
			{
				var delta:Point = touches[0].getMovement(parent);
				sheet.node.transform.x += delta.x;
				sheet.node.transform.y += delta.y;
			}
			else if (touches.length == 2)
			{
				var touchA : Touch = touches[0];
				var touchB : Touch = touches[1];

				var currentPosA : Point  = touchA.getLocation(parent);
				var previousPosA : Point = touchA.getPreviousLocation(parent);
				var currentPosB : Point  = touchB.getLocation(parent);
				var previousPosB : Point = touchB.getPreviousLocation(parent);

				var currentVector : Point  = currentPosA.subtract(currentPosB);
				var previousVector : Point = previousPosA.subtract(previousPosB);

				var currentAngle : Number  = Math.atan2(currentVector.y, currentVector.x);
				var previousAngle : Number = Math.atan2(previousVector.y, previousVector.x);
				var deltaAngle : Number = currentAngle - previousAngle;
				var sizeDiff : Number = currentVector.length / previousVector.length;

				sheet.node.transform.x = (currentPosA.x + currentPosB.x) * 0.5;
				sheet.node.transform.y = (currentPosA.y + currentPosB.y) * 0.5;
				sheet.node.transform.rotation += deltaAngle;
				sheet.node.transform.scaleX *= sizeDiff;
				sheet.node.transform.scaleY *= sizeDiff;
			}
		}

		override public function dispose() : void
		{
			sheet.onTouch.remove(onTouch);
			super.dispose();
		}
	}
}
