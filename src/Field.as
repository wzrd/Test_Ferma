package
{
	import as3isolib.data.INode;
	import as3isolib.display.IsoSprite;
	import as3isolib.display.IsoView;
	import as3isolib.display.renderers.SimpleSceneLayoutRenderer;
	import as3isolib.display.scene.IsoGrid;
	import as3isolib.display.scene.IsoScene;
	
	import eDpLib.events.ProxyEvent;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	
	public class Field extends Sprite
	{
		
		private var _scene:IsoScene;
		private var _viewPort:IsoView;
		private var _loader:Loader;
		
		private var _cellSizeX:int = 10;
		private var _cellSizeY:int = 10;
		
		private var _grid:Array;
		
		private const GRID_MAX_COLUMNS:int = 6;
		private const GRID_MAX_ROWS:int = 6;
		
		private var _isDrag:Boolean = false;
		private var _isDelete:Boolean = false;
		
		private var _numberOfPlants:int;
		
		public function Field()	
		{ 
			_viewPort = new IsoView();
			_viewPort.x = x;
			_viewPort.y = y;
			makeGrid();
			buildScene();
		}
	
		public function addPlant (plant_type:String, id:int, process_state:int, xpos:int, ypos:int):void
		{
			var i:int = 0;
			var j:int = 0;
			for (i=0; i<GRID_MAX_ROWS; ++i) for (j=0; j<GRID_MAX_COLUMNS; ++j)
			{
				if ( (_grid [i][j] != null) && (id == _grid [i][j].getID()) ) 
				{
					if (process_state == 0) 
					{
						_scene.removeChild(_grid[i][j] as INode);
						_grid[i][j].grub();
						_numberOfPlants--;
						_grid[i][j].removeEventListener (MouseEvent.CLICK, plantClickHandler);
						_grid[i][j] = null;
					}else{
						_grid [i][j].growUp();
					}
					_scene.render();
					return;
				}
			}
			plant_type = plant_type.charAt(0).toUpperCase() + plant_type.substr(1, plant_type.length);
			var cls:Class = getDefinitionByName(plant_type) as Class;
			var plant_tmp:Object = new cls(id);
			plant_tmp.plant (xpos * _cellSizeX, -1 * ypos * _cellSizeY);
			_scene.addChild (plant_tmp as INode); 
			_grid [xpos][ypos] = plant_tmp;
			_numberOfPlants++;
			plant_tmp.addEventListener (MouseEvent.MOUSE_DOWN, plantClickHandler);
			plant_tmp = null;
			_scene.render();
		}
		
		private function plantClickHandler (me:ProxyEvent):void
		{
			if (_isDelete) 
			{
				_scene.removeChild(me.target as INode);
				me.target.grub();
				_numberOfPlants--;
				me.target.removeEventListener (MouseEvent.CLICK, plantClickHandler);
				var xpos:int = Math.abs( Math.floor( me.target.x / _cellSizeX) as int);
				var ypos:int = Math.abs( Math.floor( me.target.y / _cellSizeY) as int);
				_grid[xpos][ypos] = null;
			}else if (!_isDrag) 
			{
				var i:int = 0;
				var j:int = 0;
				for (i=0; i<GRID_MAX_ROWS; ++i) for (j=0; j<GRID_MAX_COLUMNS; ++j)
				{
					if (_grid[i][j] == me.target) _grid[i][j] = null;
				}
				drag (me.target as IsoSprite);
			}
			_isDelete = false;
		}

		private function buildScene ():void
		{
			_scene = new IsoScene();
			_scene.hostContainer = this;
			var renderer:SimpleSceneLayoutRenderer = new SimpleSceneLayoutRenderer ();
			_scene.layoutEnabled = true;
			_scene.layoutRenderer = renderer;
		}
		
		private function makeGrid ():void
		{
			_grid = new Array ();
			for (var i:int=0; i<GRID_MAX_ROWS; ++i)
			{
				_grid[i] = new Array ();	
			}
			_numberOfPlants = 0;
		}
		
		public function prepareToDelete ():void 
		{
			_isDelete = true;
			_isDrag = false;
		}
		
		public function drag (target:IsoSprite):void 
		{
			_isDrag = true;
			if (!(target as IPlant).isPlanted()) _scene.addChild(target);
			target.addEventListener(Event.ENTER_FRAME, dragHandler);	
			target.addEventListener(MouseEvent.MOUSE_UP, function stopDrag (me:ProxyEvent):void {
				var _x:int = (me.target.x);
				var _y:int = (me.target.y);
				var xpos:int = Math.abs( Math.floor( _x / _cellSizeX) as int);
				var ypos:int = Math.abs( Math.floor( _y / _cellSizeY) as int);
				if ( (_x > 0) && (_x < 330) && (_y < 60) && (_y > -280) && (_grid[xpos][ypos]==null) ) 
				{
					_grid [xpos][ypos] = me.target;
					if (!(me.target as IPlant).isPlanted())  
					{
						me.target.addEventListener (MouseEvent.MOUSE_DOWN, plantClickHandler);
						_numberOfPlants++;
					}
					me.target.plant (xpos * _cellSizeX, -1 * ypos * _cellSizeY);
					_scene.render();
					_isDrag = false;
					me.target.removeEventListener (MouseEvent.CLICK, stopDrag);
					me.target.removeEventListener (Event.ENTER_FRAME, dragHandler);
				}
			}); 
			
		}
		
		private function dragHandler (e:Event):void
		{
			var localMousePoint:Point = _viewPort.localToIso(new Point (stage.mouseX + this.x, stage.mouseY) );
			e.target.moveTo (localMousePoint.x-180, localMousePoint.y-120, 0);
			_scene.render();
		}
		
		public function growAll ():void
		{
			var i:int = 0;
			var j:int = 0;
			for (i=0; i<GRID_MAX_ROWS; ++i) for (j=0; j<GRID_MAX_COLUMNS; ++j)
			{
				if (_grid[i][j] != null) _grid[i][j].growUp();
			}
			_scene.render();
		}
		
		public function get cellSizeY():int
		{
			return _cellSizeY;
		}
		public function set cellSizeY(value:int):void
		{
			_cellSizeY = value - 5;
		}
		
		public function get cellSizeX():int
		{
			return _cellSizeX;
		}
		
		public function set cellSizeX(value:int):void
		{
			_cellSizeX = value - 5;
		}

		public function get isDrag():Boolean
		{
			return _isDrag;
		}
	}
}