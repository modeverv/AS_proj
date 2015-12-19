package com.adobe.air.imagebrowser.controls {
	
	import com.adobe.air.imagebrowser.data.ImageData;
	import com.gskinner.display.IDisplayObject;
	
	import flash.display.Loader;
	import flash.events.IEventDispatcher;
	
	public interface IImageCell extends IEventDispatcher, IDisplayObject {
		
		function set rollOverEnabled(value:Boolean):void;
		function get imageLoader():Loader;
		
		function get loaded():Boolean;
		function set imageData(p_data:ImageData):void;
		function get imageData():ImageData;
		
		function load(p_path:String = null):void
		function unload():void;
		function getInstance():IImageCell;
		
	}
}