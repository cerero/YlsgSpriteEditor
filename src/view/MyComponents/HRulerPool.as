package view.MyComponents
{
	public class HRulerPool extends RulerPool
	{
		public function HRulerPool()
		{
			super();
		}
		
		protected override function createRulerImpl():Ruler
		{
			var ruler:Ruler = super.createRulerImpl();
			ruler.width = this.width;
			ruler.height = 2;
			ruler.setStyle("backgroundColor", 0xFE12A2);
			return ruler;
		}
		
		public override function moveRuler(ruler:Ruler, mouseX:int, mouseY:int):void
		{
			ruler.y = mouseY;
		}
		
		public override function canRestoreRuler(ruler:Ruler):Boolean
		{
			return ruler.y <= this.height;
		}
	}
}