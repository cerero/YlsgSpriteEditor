package utils.image
{
	import flash.display.Bitmap;
	import flash.utils.Dictionary;
	
	import texture.AnimationDir;
	import texture.AnimationFrame;

	public class AnimationFrameRipper
	{
		private var frames:Vector.<AnimationFrame>;
		private var keyColor:uint = 0;
		private var bmpDict:Dictionary = new Dictionary();
		
		public function AnimationFrameRipper(dir:AnimationDir, keyColor:uint)
		{
			this.frames = dir.frames;
			this.keyColor = keyColor;
		}
		
		public function ridAllAnimationFrame():void
		{ 
			for each(var tframe:AnimationFrame in frames)
			{
				var tbmp:Bitmap = tframe.getDisplayObject();
				var tsr:SimpleRid = new SimpleRid(tbmp.bitmapData, keyColor);
				var tret:RipResult = tsr.rip();
				
				tbmp.bitmapData.dispose();
				tbmp.bitmapData = tret.bitmapData;
				tframe.changeDisplayObject(tbmp);
				tframe.props.rect.x += tret.imageRect.left;
				tframe.props.rect.y += tret.imageRect.top;
				tframe.props.rect.width = tret.bitmapData.width;
				tframe.props.rect.height = tret.bitmapData.height;
			}
		}
			
	}
}
