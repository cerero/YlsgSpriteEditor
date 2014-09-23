package editor
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	import texture.AnimationAct;
	import texture.AnimationDir;
	import texture.AnimationImporter;
	
	public class AnimationWrapper
	{
		/** 动画载入器 */
		public var anmImporter:AnimationImporter;
		
		/** 当前动作 */
		public var currAS:AnimationAct;
		
		/** 当前方向 */
		public var currAO:AnimationDir;
		
		/** bitmap */
		public var bitmap:Bitmap = new Bitmap();
		
		public var container:Sprite = new Sprite(); 
	}
}