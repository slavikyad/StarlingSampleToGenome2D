package scenes
{
	import com.genome2d.components.renderables.GMovieClip;
	import com.genome2d.core.GNodeFactory;

	public class MovieScene extends Scene
	{
		private var mMovie : GMovieClip

		public function MovieScene(p_name : String = "")
		{
			super(p_name);

			mMovie = GNodeFactory.createNodeWithComponent(GMovieClip) as GMovieClip;
			mMovie.setTextureAtlas(Assets.getAtlas());
			mMovie.frames = [
					"flight_00", "flight_01", "flight_02", "flight_03", "flight_04",
					"flight_05", "flight_06", "flight_07", "flight_08", "flight_09",
					"flight_10", "flight_11", "flight_12", "flight_13"];
			mMovie.frameRate = 15;
			addChild(mMovie.node);
		}

		override public function dispose() : void
		{
			super.dispose();
		}
	}
}
