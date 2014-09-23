package view
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	
	public class SpritePoint extends Sprite
	{
		private var wasYAxis:Boolean=false; 
		private var textNum:TextField;
		public function SpritePoint(text:int,yAxis:Boolean=false)
		{
			super();
			wasYAxis=yAxis;
			textNum=new TextField();
			textNum.text=text.toString();
			textNum.selectable = false;
			doDraw();
			if(wasYAxis){
				textNum.x=8;
				textNum.y=-10;
				textNum.autoSize = TextFieldAutoSize.LEFT;
			}else{
				textNum.x=-10;
				if(text%2==0)
					textNum.y=4;
				else
					textNum.y=-16;
				textNum.autoSize = TextFieldAutoSize.LEFT;
				
			}
			addChild(textNum);
		}
		private function doDraw():void{
			graphics.lineStyle(1,0xFFFFFF);
			if(wasYAxis){
				graphics.lineTo(5,0);
			}else{
				graphics.lineTo(0,5);
			}
			graphics.endFill();
		}
	}
}