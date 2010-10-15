package
{
	import as3isolib.display.IsoSprite;
	
	import flash.display.Loader;
	import flash.events.Event;
	
	public class Sunflower extends IsoSprite implements IPlant
	{
		private var states:Array = new Array();	
		
		private var _id:int;
		private var _curState:int = 1;
		private var _planted:Boolean = false;
		
		public function Sunflower(id:int, xpos:int = 0, ypos:int = 0)
		{
			super();
			_id = id;
			var tmp_loader:Loader = AssetLoader.getInstance().loadAsset("sunflower/state1.png");
			states [1] = new Loader();
			tmp_loader.contentLoaderInfo.addEventListener (Event.COMPLETE, function (e:Event):void{
				states [1].loadBytes(tmp_loader.contentLoaderInfo.bytes);
				states [1].contentLoaderInfo.addEventListener (Event.COMPLETE, function (e:Event):void{
					setCordinates (states[1]);
				});
			});
			sprites = [states[1]];
			moveTo(xpos, ypos, 0);
			setSize(60, 60, 60);
		}
		
		private function setCordinates (target:Object):void
		{
			target.x -= target.width;
			target.y -= target.height;
		}
		
		public function growUp ():void 
		{
			if (_curState == 5) return;
			if (_planted)
			{
				++_curState;
				if (states[_curState]) {
					sprites = [states[_curState]];
				}else{
					var tmp_loader:Loader = AssetLoader.getInstance().loadAsset("sunflower/state"+_curState+".png");
					states [_curState] = new Loader();
					tmp_loader.contentLoaderInfo.addEventListener (Event.COMPLETE, function (e:Event):void{
						states [_curState].loadBytes(tmp_loader.contentLoaderInfo.bytes);
						states [_curState].contentLoaderInfo.addEventListener (Event.COMPLETE, function (e:Event):void{
							setCordinates (states[_curState]);
						});
					});
					sprites = [states[_curState]];
				}
			}
		}
		
		public function plant (xpos:int, ypos:int):void 
		{
			_planted = true;
			moveTo(xpos, ypos, 0);
		}
		
		public function getID ():int
		{
			return _id;
		}
		
		public function grub ():void 
		{
			
		}

		public function isPlanted():Boolean
		{
			return _planted;
		}

	}
}