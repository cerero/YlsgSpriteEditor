package view.MyComponents
{
	public class VRulerPool extends RulerPool
	{
		public function VRulerPool()
		{
			super();
		}
		
		protected override function createRulerImpl():Ruler
		{
			var ruler:Ruler = super.createRulerImpl();
			ruler.width = 2;
			ruler.height = this.height;
			ruler.setStyle("backgroundColor", 0xFE12A2);
			return ruler;
		}
		
		public override function moveRuler(ruler:Ruler, mouseX:int, mouseY:int):void
		{
			ruler.x = mouseX-1;
		}
		
		public override function canRestoreRuler(ruler:Ruler):Boolean
		{
			return ruler.x <= this.width;
		}
	}
}