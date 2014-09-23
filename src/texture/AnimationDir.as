package texture
{
	import config.ConfigData;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	/** 代表某个方向 */	
	public class AnimationDir implements IAnimation
	{
		public var bitmapData:BitmapData, x:Number, y:Number,synBitmapData:BitmapData;
		public var props:DirProperties;
		public var frames:Vector.<AnimationFrame> = new Vector.<AnimationFrame>();
		
		public function AnimationDir()
		{
			props = new DirProperties();
		}		
		
		/** 从源方向数据复制 */
		public function copyProps(src:AnimationDir):void
		{
			props.firePoint = src.props.firePoint.clone();
			props.wingPoint = src.props.wingPoint.clone();
			props.ttEffectPoint = src.props.ttEffectPoint.clone();
			props.ttEffectStartFrame = src.props.ttEffectStartFrame;
			props.currFrame = src.props.currFrame;
		}
		
		/** 添加帧数据 */
		public function addFrame(frame:AnimationFrame):void
		{
			frames.push(frame);
			frame.act = props.act;
		}
		
		/** 移除帧数据 */
		public function removeFrame(frame:AnimationFrame):void
		{
			var idx:int = frames.indexOf(frame);
			if(idx != -1)
			{
				frames.splice(idx, 1);
				if(frame.parent){
					frame.parent.removeChild(frame);
				}
			}
		}
		
		public function updateFrame2(frame:int):void
		{
			if( frames.length>frame ){
				var tframe:AnimationFrame = frames[frame];
				x = tframe.props.rect.x;
				y = tframe.props.rect.y;
				
				/*if( props.act.props.symmetry == AnimationAct.SYNMMETRY_LR || props.act.props.symmetry == AnimationAct.SYNMMETRY_UD){
					//设置镜像图片
					var gapW:int = tframe.getSynmmetryDisplayObject().width;
					var gapH:int = tframe.getSynmmetryDisplayObject().height;
					var synX:Number = 0;
					var synY:Number = 0;
					if( props.act.props.symmetry == AnimationAct.SYNMMETRY_LR ){
						synX = gapW;
						bitmapData = new BitmapData(2*gapW,gapH,true,0x00000000);
					}else{
						synY = gapH;
						bitmapData = new BitmapData(gapW,2*gapH,true,0x00000000);
					}
					
					bitmapData.draw(tframe.getDisplayObject().bitmapData);
					bitmapData.draw(tframe.getSynmmetryDisplayObject().bitmapData,new Matrix(1,0,0,1,synX,synY));
				}else{*/
					bitmapData = tframe.getDisplayObject().bitmapData;	
				//}
				
				/*bitmapData = tframe.getDisplayObject().bitmapData;
				if( tframe.getSynmmetryDisplayObject() )
					synBitmapData = tframe.getSynmmetryDisplayObject().bitmapData;*/
			}else{
				bitmapData = null;
				synBitmapData = null;
			}
			
		}
		
		/** 更新动画 */
		public function updateFrame():void
		{
			var tframe:AnimationFrame = frames[props.currFrame];
			if(tframe != null && tframe.getDisplayObject() != null)
			{
				x = tframe.props.rect.x;
				y = tframe.props.rect.y;
				bitmapData = tframe.getDisplayObject().bitmapData;
				findNextFrame(0);
			}
			else
			{
				props.currFrame = 0;
			}
		}
		
		private function findNextFrame(recurCount:int):void
		{
			if(recurCount > frames.length || frames.length == 0)
			{
				return;
			}
			
			if(++props.currFrame >= frames.length)
			{
				props.currFrame = 0;
			}
			
			var tframe:AnimationFrame = frames[props.currFrame];
			if(!tframe.props.visible)
			{
				findNextFrame(recurCount+1);
			}
		}
		
		/** 保存方向数据 */
		public function save(byte:ByteArray):int
		{
			var start:int = byte.position;
			var tlen:int = frames.length;
			//写帧
			byte.writeByte(props.dir);
			byte.writeShort(props.rect.x);
			byte.writeShort(props.rect.y);
			byte.writeShort(props.rect.width);
			byte.writeShort(props.rect.height);
			byte.writeShort(props.firePoint.x);
			byte.writeShort(props.firePoint.y);
			for(var i:int = 0; i < tlen; i++)
			{
				frames[i].save(byte);
			}
			//返回写入长度
			return byte.position - start;
		}
		
		/** 加载ByteArray */
		public function load(byte:ByteArray):int
		{
			var start:int = byte.position;
			//公共数据
			props.dir = byte.readByte();
			props.rect.x = byte.readShort();
			props.rect.y = byte.readShort();
			props.rect.width = byte.readShort();
			props.rect.height = byte.readShort();
			props.firePoint.x = byte.readShort();
			props.firePoint.y = byte.readShort();	
			//帧
			for(var i:int = 0; i < props.act.props.frameCount; ++i)
			{
				var tframe:AnimationFrame = new AnimationFrame();
				tframe.load(byte);
				addFrame(tframe);
			}
			//方向名字
			props.dirName = ConfigData.JTA_DIRECTION_MAP_INV[props.dir];
			//返回读取长度
			return byte.position - start;
		}
		
		/** ByteArray转化为bitmapData */
		public function draw():void
		{
			for each(var tf:AnimationFrame in frames){
				tf.draw();
			}
		}
		
		/** 内存清理 */
		public function unload():void
		{
			bitmapData = null;
			for each(var tf:AnimationFrame in frames){
				tf.unload();
				if(tf.parent != null){
					tf.parent.removeChild(tf);
				}
			}
			frames.length = 0;
		}
		
		/** 数据复制 */
		public function duplicate():IAnimation
		{
			var tlen:int = frames.length;
			var tao:AnimationDir = new AnimationDir();
			tao.props = props;
			//复制帧
			for(var i:int = 0; i < tlen; ++i)
			{
				tao.addFrame(frames[i].duplicate() as AnimationFrame);
			}
			return tao;
		}
	}
}

import flash.geom.Point;

import texture.AnimationAct;
import texture.AnimationFrame;
import texture.Rect;

class DirProperties
{	
	/**方向名称**/
	public var dirName:String;
	/**方向类型 如 3-右 7-左**/
	public var dir:int;
	/**方向起始帧(在SWF中从第几帧开始至第几帧结束)**/
	public var swf_frame:Array;
	/**攻击点坐标**/
	public var firePoint:Point = new Point();
	/**翅膀安装位置**/
	public var wingPoint:Point = new Point();
	/**动作效果点**/
	public var ttEffectPoint:Point = new Point();
	/**动作效果开始帧**/
	public var ttEffectStartFrame:uint;
	/**帧坐标大小定义**/
	public var rect:Rect = new Rect();	
	public var currFrame:int = 0;
	public var act:AnimationAct;  //冗余数据
	
	public function DirProperties()
	{
		rect.width = 100;
		rect.height = 100;
	}
	
	/**解释方向数据**/
	public function parseObject(obj:Object):void
	{
		rect.x = obj.rect.x;
		rect.y = obj.rect.y;
		rect.width = obj.rect.width;
		rect.height = obj.rect.height;
		
		firePoint.x = int(obj.firePoint.x);
		firePoint.y = int(obj.firePoint.y);
		
		if(obj.hasOwnProperty("wingPoint")){
			wingPoint.x = int(obj.wingPoint.x);
			wingPoint.y = int(obj.wingPoint.y);
		}
		if(obj.hasOwnProperty("ttEffectPoint")){
			ttEffectPoint.x = int(obj.ttEffectPoint.x);
			ttEffectPoint.y = int(obj.ttEffectPoint.y);
		}
		
		if( obj.ttEffectStartFrame )
			ttEffectStartFrame = obj.ttEffectStartFrame;
		
		dir = obj.dir;
		dirName = obj.dirName;
		
		if(obj.hasOwnProperty("swf_frame") && obj.swf_frame is Array){
			swf_frame = obj.swf_frame;
		}
		else{
			swf_frame = null;
		}
	}
	
	public function toObject():Object
	{
		var tobj:Object = {
			"rect":rect.toObject(),
			"dir":dir,
			"firePoint":{x:firePoint.x, y:firePoint.y},
			"wingPoint":{x:wingPoint.x, y:wingPoint.y},
			"ttEffectPoint":{x:ttEffectPoint.x, y:ttEffectPoint.y},
			"ttEffectStartFrame":ttEffectStartFrame,
			"dirName":dirName,
			"frames":[]
		};
		
		if(swf_frame is Array){
			tobj["swf_frame"] = swf_frame.concat();
		}
		return tobj;
	}
}


