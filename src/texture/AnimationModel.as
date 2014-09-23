package texture
{
	import flash.utils.ByteArray;
	
	public class AnimationModel implements IAnimation
	{
		public var setList:Vector.<AnimationAct>;
		public var kind:int=0;
		public var headerFlag:String = "Flag";
		
		public function AnimationModel(animSets:Vector.<AnimationAct>)
		{
			setList = animSets;
		}
		
		public function save(byte:ByteArray):int
		{
			var start:int = byte.position;
			//写入头部
			byte.writeUTF(headerFlag);
			byte.writeInt(kind);
			//写入动作
			for each(var tas:AnimationAct in setList)
			{
				tas.kind = kind;
				tas.save(byte);
			}
			return byte.position - start;
		}
		
		public function load(ba:ByteArray):int
		{
			return 0;
		}
		
		public function draw():void{}
		public function duplicate():IAnimation
		{
			return null;
		}
		public function unload():void{}
	}
}