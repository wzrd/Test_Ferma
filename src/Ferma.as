package 
{	
	import as3isolib.display.IsoSprite;
	
	import fl.controls.Button;
	import fl.controls.List;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;
	
	
	[SWF (width="800", height="600", frameRate="25")]

	public class Ferma extends Sprite
	{
		private var _gameField:Field;
		
		private const OFFSET_X:int = 155;
		private const OFFSET_Y:int = 315;
		
		public static var loader:Loader;
		
		private var plant_btn:Button;
		private var grub_btn:Button;
		private var make_turn_btn:Button;
		private var plant_list:List;
		
		public function Ferma ()
		{
			setBackground();
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			xmlLoader.addEventListener(Event.COMPLETE, loadXMLHandler);
			xmlLoader.load(new URLRequest("assets/REF.xml"));
		}
		
		private function loadXMLHandler (e:Event):void
		{
			initGameField();
			parseXML(new XML (e.target.data));
			initButtons();
		}
		
		private function parseXML (target:XML):void
		{
			var cellSizeX:int = target["field"].@size_x;
			var cellSizeY:int = target["field"].@size_y;
			
			_gameField.cellSizeX = cellSizeX;
			_gameField.cellSizeY = cellSizeY;
			
			var targetElements:XMLList = target["field"].elements();
			for each (var element:XML in targetElements) {
				var plantName:String = element.name();
				var id:int = element.@id;
				var xpos:int = element.@x / 5;
				var ypos:int = element.@y / 5;
				var processEnd:int = element.@process_end;
				_gameField.addPlant(plantName, id, processEnd, xpos, ypos);
			}
		}
		
		public function setBackground ():void
		{
			var bg_img:Loader = new Loader();
			bg_img.load(new URLRequest ("assets/BG.jpg"));
			bg_img.x=0;
			bg_img.y=0;
			addChild (bg_img);
		}
		
		private function initGameField():void
		{
			_gameField = new Field();
			addChild(_gameField);
			_gameField.x = OFFSET_X;
			_gameField.y = OFFSET_Y;	
		}
		
		
		private function initButtons():void
		{
			plant_btn = new Button();
			plant_btn.label = "Посадить";
			plant_btn.x = 10;
			plant_btn.y = 10;
			plant_btn.enabled = false;
			
			grub_btn = new Button();
			grub_btn.label = "Собрать";
			grub_btn.x = plant_btn.x + plant_btn.width + 5;
			grub_btn.y = 10;
			
			make_turn_btn = new Button();
			make_turn_btn.label = "Сделать ход";
			make_turn_btn.x = grub_btn.x + plant_btn.width + 5;
			make_turn_btn.y = 10;
			
			plant_list = new List();
			plant_list.x = plant_btn.x;
			plant_list.y = plant_btn.y + plant_btn.height + 5;
			plant_list.addItem({label:"Clover"});
			plant_list.addItem({label:"Potato"});
			plant_list.addItem({label:"Sunflower"});
			plant_list.height = 60;
			plant_list.addEventListener (Event.CHANGE, function (e:Event):void {
				plant_btn.enabled = true;
			});

			addChild(plant_list);
			addChild(plant_btn);
			addChild(make_turn_btn);
			addChild(grub_btn);
			
			plant_btn.addEventListener (MouseEvent.CLICK, function (me:MouseEvent):void {
				if (!_gameField.isDrag)
				{
					var plant_cls:Class = getDefinitionByName(plant_list.selectedItem.label) as Class;
					var plant_obj:Object = new plant_cls(100);
					_gameField.drag(plant_obj as IsoSprite);
				}
			});
			grub_btn.addEventListener (MouseEvent.CLICK, function (me:MouseEvent):void {
				if (!_gameField.isDrag)
				{
					_gameField.prepareToDelete();	
				}
			});
			make_turn_btn.addEventListener (MouseEvent.CLICK, function (me:MouseEvent):void {
				if (!_gameField.isDrag)
				{
					_gameField.growAll();
				}
			});
		}
	}
}