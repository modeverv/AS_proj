package fortest{
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.events.Event;
	
	public class XMLLoader extends EventDispatcher {
		public static const LOAD_COMPLETE:String = "load_complete";
		private var xmlLoader:URLLoader;
		private var xml:XML;
		private var object:Object;
	
		public function XMLLoader(url:String, isUnicode:Boolean = true) {
			xmlLoader = new URLLoader();
			xmlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			xmlLoader.addEventListener(Event.COMPLETE, onXMLLoaded);
			System.useCodePage = !isUnicode;
			xmlLoader.load(new URLRequest(url));
		}
		
		private function onXMLLoaded(e:Event):void {
			try {
				xml = new XML(xmlLoader.data);
				parseXML();
			} catch(err:TypeError) {
				trace(err.message);
			}
		}
		private function parseXML():void {
			var obj:Object = new Object();
			obj.title = xml.title;
			obj.img_thumb = xml.img.@thumb;
			obj.img = xml.img.@src;
			object = obj;
			dispatchEvent(new Event(LOAD_COMPLETE));
		}
		
		public function get rawXML():XML {
			return xml;
		}
		
		public function get data():Object {
			return object;
		}
	}
}