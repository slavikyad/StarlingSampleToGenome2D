package components
{
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.core.GNode;

	import org.osflash.signals.Signal;

	public class GTouchSprite extends GSprite
	{
		public var onTouch : Signal;

		public function GTouchSprite(p_node : GNode)
		{
			super(p_node);

			onTouch = new Signal();
			node.addComponent(TouchProcessor);
			node.mouseEnabled = true;
		}
	}
}
