package com.adobe.air.imagebrowser.events {
	
	import com.adobe.air.imagebrowser.data.ImageListData;
	
	import flash.events.Event;

	public class ImageEvent extends Event {
		
		public static const LOAD_START:String = 'loadStart';
		public static const LOAD_END:String = 'loadEnd';
		
		public var images:Object;
		public var imageListData:ImageListData;
		
		public function ImageEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, p_images:Object = null, p_imageListData:ImageListData = null) {
			images = p_images;
			imageListData = p_imageListData;
			
			super(type, bubbles, cancelable);
		}
		
	}
}