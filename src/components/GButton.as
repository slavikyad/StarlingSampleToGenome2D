package components
{
	import com.genome2d.components.GComponent;
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.components.renderables.flash.GFlashText;
	import com.genome2d.context.GBlendMode;
	import com.genome2d.core.GNode;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.textures.GTexture;

	import flash.geom.Rectangle;
	import flash.text.TextFormat;

	public class GButton extends GComponent
	{
		private var upSprite : GSprite;
		private var downSprite : GSprite;
		private var textField : GFlashText;
		private var bounds : Rectangle;
		private var __dirty : Boolean;
		private var __enabled : Boolean;

		private const PAD : Number = 10;

		public function set text(value : String) : void
		{
			createTextField();
			textField.text = value;
			__dirty = true;
		}

		public function set enabled(value : Boolean) : void
		{
			__enabled = value;
			__dirty = true;
		}

		public function get enabled() : Boolean
		{
			return __enabled;
		}

		public function GButton(p_node : GNode)
		{
			super(p_node);

			node.mouseEnabled = true;
			__enabled = true;
			bounds = new Rectangle(0, 0, 100, 100);
		}

		protected function createTextField() : void
		{
			if(textField == null)
			{
				textField = GNodeFactory.createNodeWithComponent(GFlashText) as GFlashText;
				textField.width = bounds.width;
				textField.height = bounds.height;
				textField.embedFonts = true;
				textField.transparent = true;
				textField.blendMode = GBlendMode.NORMAL;
				textField.textFormat = new TextFormat("Ubuntu", 14, 0x0);
				node.addChild(textField.node);
			}
		}

		public function setTextures(upState : GTexture, downState : GTexture = null) : void
		{
			if(upSprite == null) {
				upSprite = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
				upSprite.setTexture(upState);
				upSprite.node.mouseEnabled = true;
				node.addChild(upSprite.node);
				bounds = new Rectangle(0, 0, upState.width, upState.height);
				__dirty = true;
			}

			if(downSprite) {
				downSprite = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
				downSprite.setTexture(downState || upState);
				downSprite.node.transform.visible = false;
				downSprite.node.mouseEnabled = true;
				node.addChild(downSprite.node);
			}
		}

		public function setText(title : String) : void
		{
			if(title && title.length != 0) {
				this.text = title;
			}
		}

		override public function update(p_deltaTime : Number, p_parentTransformUpdate : Boolean, p_parentColorUpdate : Boolean) : void
		{
			if(__dirty)
			{
				node.mouseEnabled = __enabled;
				node.transform.alpha = __enabled ? 1 : 0.5;

				textField.width = bounds.width;
				textField.height = bounds.height;
				textField.node.transform.setPosition(PAD, PAD);

				__dirty = false;
			}
		}
	}
}
