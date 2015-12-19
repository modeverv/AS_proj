package org.libspark.next {
	
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLVariables;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.media.Sound;
	import flash.utils.ByteArray;
	
	internal class LoaderTrigger extends Trigger {
	
		/**
		* ロードした物のタイプ
		*/
		private var type:String;
		
		/**
		* ターゲット
		*/
		private var target:EventDispatcher;
		
		public function LoaderTrigger(... args:Array) {
			var request:URLRequest;
			switch(Overload.check(args, [String], [URLRequest], [Loader], [URLLoader], [Sound])) {
				case 0: request = new URLRequest(args[0]); break;
				case 1: request = args[0]; break;
				case 2: target = Loader(args[0]).contentLoaderInfo; break;
				case 3: target = args[0];
				case 4: target = args[0];
			}
			type = (args[1] as String) || determineType(request.url);
			if(!target) {
				switch(type) {
					case LoaderType.LOADER:
						var loader:Loader = new Loader();
						loader.load(request);
						target = loader.contentLoaderInfo;
						break;
					case LoaderType.TEXT:
					case LoaderType.XML:
					case LoaderType.VARIABLES:
					case LoaderType.BINARY:
						var urlloader:URLLoader = new URLLoader();
						if(type==LoaderType.BINARY) urlloader.dataFormat = URLLoaderDataFormat.BINARY; else
						if(type==LoaderType.VARIABLES) urlloader.dataFormat = URLLoaderDataFormat.VARIABLES;
						urlloader.load(request);
						target = urlloader;
						break;
					case LoaderType.SOUND:
						var sound:Sound = new Sound();
						sound.load(request);
						target = sound;
						break;
				}
			}
			if(target) {
				target.addEventListener(Event.COMPLETE, onComplete);
				target.addEventListener(IOErrorEvent.IO_ERROR, halt);
				target.addEventListener(SecurityErrorEvent.SECURITY_ERROR, halt);
			} else throw new Error("Unknown type ...");
		}
		
		/**
		* 中断
		*/
		override public function halt(... args:Array):void {
			removeEventListener();
			super.call(null);
		}
		
		/**
		* ロード完了
		*/
		private function onComplete(e:Event):void {
			removeEventListener();
			call(e);
		}

		/**
		* イベントリスナーを解除
		*/
		private function removeEventListener():void {
			target.removeEventListener(Event.COMPLETE, onComplete);
			target.removeEventListener(IOErrorEvent.IO_ERROR, halt);
			target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, halt);
		}
		
		/**
		* 拡張子からタイプ判別
		*/
		private function determineType(url:String):String {
			var pair:Array = [
				/\.(swf|jpg|jpeg|png)$/i, 	LoaderType.LOADER,
				/\.(txt)$/i, 			  	LoaderType.TEXT,
				/\.(mp3)$/i,			  	LoaderType.SOUND,
				/\.(xml)$/i,				LoaderType.XML,
			];
			for(var i:int=0; i<pair.length; i+=2) {
				if(url.match(pair[i])) return pair[i+1];
			}
			return LoaderType.UNKOWN;
		}

		/**
		* タイプ別コール
		*/
		override public function call(... args:Array):void {
			Overload.check(args, [Event]);
			var event:Event = args[0];
			switch(type) {
				case LoaderType.LOADER:
					super.call(LoaderInfo(event.target).loader);
					break;
				case LoaderType.TEXT:
					super.call(String(URLLoader(event.target).data));
					break;
				case LoaderType.SOUND:
					super.call(Sound(event.target));
					break;
				case LoaderType.XML:
					super.call(XML(URLLoader(event.target).data));
					break;
				case LoaderType.VARIABLES:
					super.call(URLVariables(URLLoader(event.target).data));
					break;
				case LoaderType.BINARY:
					super.call(ByteArray(URLLoader(event.target).data));
					break;
				default:
					super.call(event);
					break;
			}
		}
	}
}