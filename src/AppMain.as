package
{
    import flash.desktop.NativeApplication;
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    import flash.system.*;
    import flash.utils.*;
	import flash.utils.setTimeout;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	
	import ext.ParentAppSystem;

	[SWF(backgroundColor="0x6A7495" , width="900" , height="425")]
	public class AppMain extends MovieClip
	{
		// Assets
		[Embed (source="icon.png")]
		public static const loaderIconAsset:Class;
		
		// Constants
		private static const URL      : String = "https://projects.fewfre.com/a801/tools/toolsapp/tools.swf";
		private static const URL_BASE : String = "https://projects.fewfre.com/a801/tools/toolsapp/";
		
		// Storage
		private var _loader:Loader;
		private var _loadingDisplay:LoaderDisplay;
		private var _errorMessage:TextField;
		
		// Constructor
		public function AppMain() {
			super();
			stage.align = StageAlign.TOP;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			
			_loadingDisplay = new LoaderDisplay(stage.stageWidth * 0.5, stage.stageHeight * 0.5, loaderIconAsset);
			addChild(_loadingDisplay);
			
			ParentAppSystem.start();
			
			_startLoad();
		}
		
		private function dispose() : void {
			_loadingDisplay.dispose();
			
			// Remove all elements on screen
			while (numChildren) {
				removeChildAt(0);
			}
			_loadingDisplay = null;
			_errorMessage = null;
		}
		
		////////////////////////////////////
		// Loading Logic
		////////////////////////////////////
		
		private function _startLoad() : void {
			_attemptLoad();
		}

		private function _attemptLoad(pTries:Number=0) : void {
			try {
				var url : String = URL;
				if(pTries > 5 && pTries <= 10) {
					url = url.replace("https://", "http://");
				}
				var swfLoader:URLLoader = new URLLoader();
				swfLoader.dataFormat = "binary";//URLLoaderDataFormat.BINARY;
				swfLoader.addEventListener(Event.COMPLETE, _onLoadComplete);
				if(pTries == 11) {
					// weird possible fix for 2032 error - https://community.adobe.com/t5/air-discussions/android-air-app-random-error-2032-stream-error-httpstatusevent-0/td-p/4016276
					swfLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(e:HTTPStatusEvent):void{ trace('http status : ' + e.status); });
				}
				swfLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void{
					if(pTries == 11) {
						_displayErrorMessage("Attempting forced load");
						_onLoadComplete(e);
						return;
					}
					var message:String = "(_attemptLoad)["+e.type+":"+e.errorID+"] "+e.text;
					if(pTries > 0) {
						message += "\nRetires: "+pTries;
						if(pTries > 5 && pTries <= 10) {
							message += " -- testing without HTTPS";
						}
						if(pTries == 10) {
							message += " -- next load will test HTTPS again and will attempt force loading it";
						}
						// if(pTries > 25) {
						// 	message += " -- assuming your internet is working, I'm not really sure what is wrong :(";
						// }
					}
					_displayErrorMessage(message);
					setTimeout(_attemptLoad,1000,pTries+1);
				});
				var tRequest:URLRequest = new URLRequest(url + "?d=" + _getCacheBreak(pTries));
				if (NativeApplication.nativeApplication) tRequest.data = new URLVariables("cache=no+cache");
				tRequest.requestHeaders.push(new URLRequestHeader("pragma", "no-cache"));
				swfLoader.load(tRequest);
			}
			catch(e) {
				_displayErrorMessage("(_attemptLoad)["+e.name+":"+e.errorID+"] "+e.message);
			}
		}

		private function _onLoadComplete(event:Event) : void {
			var logs:Array = [];
			try {
				// Setup loader
				logs.push('[a] (last ditch attempt)');
				var loadedUrlLoader:URLLoader = URLLoader(event.currentTarget);
				logs.push('[b:'+Number(!!loadedUrlLoader)+']');
				logs.push('[c:'+loadedUrlLoader.dataFormat+', '+loadedUrlLoader.bytesLoaded+'/'+loadedUrlLoader.bytesTotal+']');
				var ctx:LoaderContext = new LoaderContext();
				ctx.allowCodeImport = true;
				ctx.parameters = { swfUrlBase:URL_BASE };
				
				logs.push('[d]');
				// Add SWF to stage
				_loader = new Loader();
				// I think this one might not actually ever fire
				_loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void{
					setTimeout(function():void{ _displayErrorMessage("(_attemptLoad)["+e.type+":"+e.errorID+"] "+e.text); }, 0);
				});
				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void{
					setTimeout(function():void{ _displayErrorMessage("(_attemptLoad)["+e.type+":"+e.errorID+"] "+e.text); }, 0);
				});
				logs.push('[e]');
				_loader.loadBytes(loadedUrlLoader.data, ctx);
				logs.push('[f]');
				dispose();
				addChild(_loader);
				logs.push('[g]');
			}
			catch(e) {
				_displayErrorMessage("(_onLoadComplete)["+e.name+":"+e.errorID+"] - "+e.message+JSON.stringify(logs));
			}
		}
		
		////////////////////////////////////
		// Helpers
		////////////////////////////////////
		
		private function _getCacheBreak(pTries:Number=0) : String {
			var now:Date = new Date();
			// Cache break only once a day - don't force it more than that
			// also break cache on any retries
			return [now.getFullYear(), now.getMonth(), now.getDate(), now.getSeconds(), pTries].join("-");
		}
		
		private function _displayErrorMessage(message:String) : void {
			if(!_errorMessage) {
				var txt:TextField = _errorMessage = addChild(new TextField()) as TextField;
				txt.defaultTextFormat = new TextFormat("Veranda", 16, 0xFF0000);
				txt.autoSize = TextFieldAutoSize.CENTER;
				txt.x = stage.stageWidth * 0.5 - (txt.textWidth * 0.5);
				txt.y = 20;
				txt = null;
			}
			_errorMessage.text = message;
		}
	}
}

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
import flash.events.Event;

class LoaderDisplay extends Sprite
{
	private var _loadingSpinner : Sprite;
	
	public function LoaderDisplay(pX:Number, pY:Number, loaderIconAsset:Class) {
		super();
		
		// Separate sprite from gear, since we want it to rotate around center
		_loadingSpinner = addChild(new Sprite()) as Sprite;
		_loadingSpinner.x = pX;
		_loadingSpinner.y = pY;
		
		var gear:Bitmap = _loadingSpinner.addChild(new loaderIconAsset()) as Bitmap;
		gear.x = -gear.width*0.5;
		gear.y = -gear.height*0.5;
		
		var txt:TextField = addChild(new TextField()) as TextField;
		txt.defaultTextFormat = new TextFormat("Veranda", 32, 0xC2C2DA);
		txt.autoSize = TextFieldAutoSize.CENTER;
		txt.text = "Loading...";
		txt.x = pX - (txt.textWidth * 0.5);
		txt.y = pY + gear.height*0.5 + 10;
		
		gear = null;
		txt = null;
		
		addEventListener(Event.ENTER_FRAME, _update);
	}
	
	public function dispose() : void {
		removeEventListener(Event.ENTER_FRAME, _update);
	}
	
	private function _update(e:Event) : void {
		var dt : Number = 0.012;
		if(_loadingSpinner != null) {
			_loadingSpinner.rotation += 360 * dt;
		}
	}
}