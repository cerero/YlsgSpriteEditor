package texture
{
	import config.ConfigData;
	
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	
	
	/** 保存一个动作，例如站立 */
	public class AnimationAct implements IAnimation
	{
		/**很定速度**/
		public static const CONST_SPEED_MODE:int = 0;
		/**变度**/
		public static const VAR_SPEED_MODE:int = 1;
		
		/**无对称方式**/
		public static const SYNMMETRY_NONE:int = 0;
		/**左右对称方式**/
		public static const SYNMMETRY_LR:int = 1;
		/**上下对称方式**/
		public static const SYNMMETRY_UD:int = 2;
		public var props:ActProperties;
		public var kind:int = 0;  //冗余字段
		
		public function AnimationAct()
		{
			props = new ActProperties();
		}
		
		/** 复制动作 */
		public function copyProps(src:AnimationAct):void
		{
			var i:int;
			this.props.speed = src.props.speed;
			this.props.repeatCount = src.props.repeatCount;
			this.props.swing = src.props.swing;//未定义
			this.props.speedMode = src.props.speedMode;
			for( i=0;i<this.props.frameCount;i++ ){
				if( i<src.props.framesSpeed.length ){
					this.props.framesSpeed[i] = src.props.framesSpeed[i];
				}else{
					break;
				}
			}
			//this.props.framesSpeed = src.props.framesSpeed.slice(0);
			this.props.fireFrame = src.props.fireFrame;
			this.props.yinchangFrame = src.props.yinchangFrame;
			this.props.attackFrame = src.props.attackFrame;
			this.props.baseDunDelay = src.props.baseDunDelay;
			/*for( i=0;i<this.props.frameCount;i++ ){
				if( i<src.props.hurtAngles.length ){
					this.props.hurtAngles[i] = src.props.hurtAngles[i];
				}else{
					break;
				}
			}*/
			this.props.frameCount = src.props.frameCount;
			//this.props.hurtAngles = src.props.hurtAngles.slice(0);
			//this.props.hurtScaleX = src.props.hurtScaleX;
			//this.props.hurtScaleY = src.props.hurtScaleY;
			this.props.loopStart = src.props.loopStart;
			this.props.loopEnd = src.props.loopEnd;
			this.props.loops = src.props.loops;
			this.props.symmetry = src.props.symmetry;
			this.props.playeType = src.props.playeType;
			//this.props.isTTEffect = src.props.isTTEffect;
			
			for each(var sao:AnimationDir in src.props.dirList)
			{
				for each(var tao:AnimationDir in props.dirList)
				{
					if(sao.props.dir == tao.props.dir)
					{
						tao.copyProps(sao);
					}
				}
			}
		}
		
		/** 添加一个方向 */
		public function addDir(anim:AnimationDir):void
		{
			anim.props.act = this;
			props.dirList.push(anim);
		}
		
		/** 移除一个动作 */
		public function removeDir(anim:AnimationDir):void
		{
			var idx:int = props.dirList.indexOf(anim);
			if(idx != -1)
			{
				props.dirList.splice(idx, 1);
			}
			else
			{
				for(var i:int = 0; i < props.dirList.length; ++i)
				{
					var tar:AnimationDir = props.dirList[i];
					if(tar.props == anim.props)
					{
						idx = i;
						break;
					}
				}
				if(idx != -1)
				{
					props.dirList.splice(idx, 1);
				}
			}
		}
		
		/** 保存byteArray */
		public function save(byte:ByteArray):int
		{
			var position:int;
			var start:int = byte.position;
			//写入公共数据
			byte.writeByte(props.type);
			position = byte.position;
			byte.writeInt(100);
			byte.writeByte(props.frameCount);
			byte.writeShort(props.rect.x);
			byte.writeShort(props.rect.y);
			byte.writeShort(props.rect.width);
			byte.writeShort(props.rect.height);
			byte.writeByte(props.speed);
			if(kind >= 5)
			{
				/**未知作用域  fireFrame**/
				byte.writeByte(0);
				byte.writeByte(0);
				byte.writeByte(0);
				/*****/
				/**未知作用域  secondFireEndFrame**/
				byte.writeByte(0);
			}
			else
			{
				/**未知作用域  fireFrame**/
				byte.writeByte(props.fireFrame);
			}
			byte.writeByte(props.repeatCount);
			if(kind == 7 || kind == 3)
			{
				byte.writeByte(0);
			}
			if(kind >= 6)
			{
				/**未知作用域  swing**/
				byte.writeByte(0);
			}
			//写入速度模式和可变速度数组			
			byte.writeByte(props.speedMode);
			for(var i:int = 0; i < props.frameCount; ++i)
			{
				byte.writeByte(props.framesSpeed[i]);
			}
			//写入方向数据
			var tsize:int = byte.position, curpos:int;
			for each(var tao:AnimationDir in props.dirList)
			{
				tao.save(byte);
			}
			curpos = byte.position;
			byte.position = position;
			byte.writeInt(curpos - tsize);
			byte.position = curpos;
			//返回写入字节
			return curpos - start;
		}
		
		/** 加载JTA */
		public function load(byte:ByteArray):int
		{
			var start:int = byte.position;
			props.type = byte.readByte();
			var len:int = byte.readInt();
			var position:int = byte.position;
			props.frameCount = byte.readByte();
			props.rect.x = byte.readShort();
			props.rect.y = byte.readShort();
			props.rect.width = byte.readShort();
			props.rect.height = byte.readShort();
			props.speed = byte.readByte();
			if(kind >= 5)
			{
				/**未知作用域  fireFrame**/
				byte.readByte();
				byte.readByte();
				byte.readByte();
				/*****/
				/**未知作用域  secondFireEndFrame**/
				byte.readByte();
			}
			else
			{
				/**未知作用域  fireFrame**/
				props.fireFrame = byte.readByte();
			}
			
			props.repeatCount = byte.readByte();
			if(kind == 7 || kind == 3)
			{
				byte.readByte();
			}
			if(kind >= 6)
			{
				/**未知作用域  swing**/
				byte.readByte();
			}
			//读取速度模式和速度数组
			props.speedMode = byte.readByte();
			props.framesSpeed = [];
			for(var i:int = 0; i < props.frameCount; ++i)
			{
				props.framesSpeed[i] = byte.readByte();
			}
			//方向数据
			var tdir:AnimationDir;
			while(byte.position < len + position)
			{
				tdir = new AnimationDir();
				addDir(tdir);
				tdir.load(byte);
			}
			//动作名称
			props.typeName = ConfigData.JTA_TYPES_MAP_INV[String(props.type)];
			//读取长度
			return byte.position - start;
		}
		
		/** ByteArray转化为BitmapData */
		public function draw():void
		{
			for each(var tao:AnimationDir in props.dirList){
				tao.draw();
			}
		}
		
		/** 内存清理 */
		public function unload():void
		{
			for each(var tao:AnimationDir in props.dirList){
				tao.unload();
			}
			props.dirList.length = 0;
		}
		
		/** 动作数据复制 */
		public function duplicate():IAnimation
		{
			var tset:AnimationAct = new AnimationAct();
			var tvl:* = describeType(props).variable;
			for each(var xml:XML in tvl)
			{
				tset.props[xml.@name] = props[xml.@name];
			}
			tset.props.frameCount = props.frameCount;
			//复制动画
			var tlen:int = props.dirList.length;
			for(var i:int = 0; i < tlen; ++i)
			{
				tset.addDir((props.dirList[i] as AnimationDir).duplicate() as AnimationDir);
			}
			return tset;
		}
	}
}

import texture.AnimationAct;
import texture.AnimationDir;
import texture.Rect;

class ActProperties
{
	private var _frameCount:int = 3;
	
	/**动作类型名称 如 站立**/
	public var typeName:String;
	/**动作类型 如 0-站立**/
	public var type:int;
	/**恒定速度值**/
	public var speed:int = 60;
	/**动作框坐标大小定义**/
	public var rect:Rect = new Rect();
	public var repeatCount:int=0;
	/**暂时无意义**/
	public var swing:int=0;
	public var dirList:Vector.<AnimationDir> = new Vector.<AnimationDir>();
	/**速度类型，变速或恒速**/
	public var speedMode:int = AnimationAct.CONST_SPEED_MODE;
	/**各帧速度**/
	public var framesSpeed:Array = [];
	/**攻击帧**/
	public var fireFrame:int = 0;
	/**吟唱结束帧**/
	public var yinchangFrame:int=0;
	/**攻击结束帧**/
	public var attackFrame:int=0;
	/**顿刀基本时间**/
	public var baseDunDelay:int=0;
	
	//伤害效果配置
	/**每帧伤害角度**/
	public var hurtAngles:Array = [];
	/**伤害效果缩放x比列**/
	public var hurtScaleX:Number = 1;
	/**伤害效果缩放y比列**/
	public var hurtScaleY:Number = 1;
	
	//攻击帧循环相关
	/**循环开始帧**/
	public var loopStart:Number = 0;
	/**循环结束帧**/
	public var loopEnd:Number = 0;
	/**循环次数**/
	public var loops:Number = 0;
	public var loopsTemp:Number = 0;
	/**对称方式 0-无 1-左右对称 2-上下对称**/
	public var symmetry:int = 0;
	/**动作tt效果相关值
	 * 0-同步动作tt播放 1-独立播放
	 * **/
	public var playeType:int = 0;
	/**是否动作特效
	 * 0-否 1-是
	 * **/
	//public var isTTEffect:int = 0;
	/**设置动作帧数**/
	public function set frameCount(value:int):void
	{
		if(_frameCount == value && framesSpeed.length == value)
		{
			return;
		}
		
		_frameCount = value;
		framesSpeed.length = value;
		for(var i:int = 0; i < value; ++i)
		{
			framesSpeed[i] = speed;
		}
	}
	
	public function removeFrame(index:int):void
	{
		if(!framesSpeed.length)
		{
			return;
		}
		
		if(index < 0 || index >= framesSpeed.length)
		{
			throw new Error("移除索引错误");
		}
		
		++index;
		if(index >= framesSpeed.length)
		{
			index = 0;
		}
		
		framesSpeed.splice(index, 1);
		--_frameCount;
	}
	
	public function get frameCount():int
	{
		return _frameCount;
	}
	
	public function initPro():void
	{
		for(var i:int = 0; i < frameCount; ++i)
		{
			hurtAngles[i] = 0;
		}
	}
	
	/**解释动作配置数据**/
	public function parseObject(obj:Object):void
	{
		frameCount = obj.frameCount;
		type = obj.type;
		typeName = obj.typeName;
		framesSpeed = obj.framesSpeed;
		speed = obj.speed;
		swing = obj.swing;
		speedMode = obj.speedMode;
		fireFrame = obj.fireFrame;
		
		if( obj.yinchangFrame )
			yinchangFrame = obj.yinchangFrame;
		
		if( obj.attackFrame )
			attackFrame = obj.attackFrame;
		
		if( obj.baseDunDelay )
			baseDunDelay = obj.baseDunDelay;
		
		rect.x = obj.rect.x;
		rect.y = obj.rect.y;
		rect.width = obj.rect.width;
		rect.height = obj.rect.height;
		
		/*if( !obj.hurtAngles ){
			for(var i:int = 0; i < frameCount; ++i)
			{
				hurtAngles[i] = 0;
			}
		}else{
			hurtAngles = obj.hurtAngles;
		}*/
		
		/*if( obj.hurtScaleX )
			hurtScaleX = obj.hurtScaleX;
		
		if( obj.hurtScaleY )
			hurtScaleY = obj.hurtScaleY;*/
		
		if( obj.loopStart )
			loopStart = obj.loopStart;
		
		if( obj.loopEnd )
			loopEnd = obj.loopEnd;
		
		if( obj.loops )
			loops = obj.loops;
		
		symmetry = obj.symmetry;
		playeType = obj.playeType;
		//isTTEffect = obj.isTTEffect;
	}
	
	public function toObject():Object
	{
		var tobj:Object = {
			"frameCount":frameCount,
			"type":type,
			"typeName":typeName,
			"framesSpeed":framesSpeed,
			"swing":swing,
			"speedMode":speedMode,
			"fireFrame":fireFrame,
			"yinchangFrame":yinchangFrame,
			"attackFrame":attackFrame,
			"baseDunDelay":baseDunDelay,
			"rect":rect.toObject(),
			"speed":speed,
			"dirList":[],
			//"hurtAngles":hurtAngles,
			//"hurtScaleX":hurtScaleX,
			//"hurtScaleY":hurtScaleY,
			"loopStart":loopStart,
			"loopEnd":loopEnd,
			"loops":loops,
			"symmetry":symmetry,
			"playeType":playeType
			//"isTTEffect":isTTEffect
		};
		
		for(var i:int = 0; i < dirList.length; i++)
		{
			tobj.dirList[i] = dirList[i].props.toObject();
		}
		return tobj;
	}
}