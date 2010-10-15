
package {
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	public final class AssetLoader {
		
		private static var instance:AssetLoader = new AssetLoader();
		private const PREFIX:String = "assets/";
		
		public var cache:Object = new Object(); 
		
		public function AssetLoader() {
			if( instance ) throw new Error("Невозможно инициализировать. Синглтон класс." ); 
		}
		
		public static function getInstance():AssetLoader {
			return instance;
		}
		
		public function loadAsset (url:String):Loader
		{
			if (cache[PREFIX + url]) 
			{
				return makeCopy (cache[PREFIX + url].contentLoaderInfo);
			}else{
				var loader:Loader = new Loader ();
				loader.load(new URLRequest (PREFIX + url));
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function completeHandler (e:Event):void{
					cache[PREFIX + url] = loader;
				});
			}
			return loader;
		}
		
		public function makeCopy (source:LoaderInfo):Loader
		{
			var copyLoader:Loader = new Loader();
			copyLoader.loadBytes(source.bytes);
			return copyLoader;

		}
		
	}
	
}