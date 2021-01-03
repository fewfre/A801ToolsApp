package
{
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    import flash.system.*;
    import flash.utils.*;

	[SWF(backgroundColor="0x6A7495" , width="900" , height="425")]
	public class AppMain extends MovieClip
	{
		[Embed (source="icon.png" )]
		public static const loaderIconAsset:Class;
		
		// Storage
		private var _urlLoader:URLLoader;
		private var _loader:Loader;
		private var _loadingIcon:Sprite;
		
		// Constructor
		public function AppMain() {
			super();
			stage.align = StageAlign.TOP;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			
			_loadingIcon = addChild(new Sprite()) as Sprite;
			_loadingIcon.x = stage.stageWidth * 0.5;
			_loadingIcon.y = stage.stageHeight * 0.5;
			var gear = _loadingIcon.addChild(new loaderIconAsset());
			gear.x = -gear.width*0.5;
			gear.y = -gear.height*0.5;
			gear = null;
			
			addEventListener(Event.ENTER_FRAME, _update);
			
			_startLoad();
		}

		private function _startLoad() : void {
			var url : String = "https://projects.fewfre.com/a801/tools/toolsapp/tools.swf";
			_urlLoader = new URLLoader();
			_urlLoader.dataFormat = "binary";
			_urlLoader.addEventListener("complete", _onLoadComplete);
			_urlLoader.load(new URLRequest(url + "?d=" + new Date().getTime()));
		}

		private function _onLoadComplete(event:Event) : void {
			var data:ByteArray = _urlLoader.data as ByteArray;
			var ctx:LoaderContext = new LoaderContext();
			ctx.allowCodeImport = true;
			ctx.parameters = { swfUrlBase:"https://projects.fewfre.com/a801/tools/toolsapp/" };
			
			// Remove all elements on screen
			while (numChildren) {
				removeChildAt(0);
			}
			_loadingIcon = null;
			removeEventListener(Event.ENTER_FRAME, update);
			
			// Add SWF to stage
			_loader = new Loader();
			_loader.loadBytes(data, ctx);
			addChild(_loader);
		}
		
		private function _update(pEvent:Event):void {
			var dt = 0.012;
			if(_loadingIcon != null) {
				_loadingIcon.rotation += 360 * dt;
			}
		}
	}
}
