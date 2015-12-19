package com.adobe.spf
{
	import flash.display.NativeWindow;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowType;
	import flash.display.NativeWindowSystemChrome;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.display.Loader;
	import flash.filesystem.*;
	import flash.utils.ByteArray;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Point;

	public class ScreenSaver
		extends NativeWindow
	{
		private var spf:SPF;
		private var imageFiles:Array;
		private var interval:uint;
		private var lastBitmap:Bitmap;
		private var timer:Timer;

		public function ScreenSaver(spf:SPF, imageFiles:Array, pictureTransitionInterval:uint)
		{
			this.spf = spf;
			this.imageFiles = imageFiles;
			this.interval = pictureTransitionInterval;

			// Configure the parent window
			var initOpts:NativeWindowInitOptions = new NativeWindowInitOptions();
			initOpts.type = NativeWindowType.UTILITY;
			initOpts.systemChrome = NativeWindowSystemChrome.NONE;
			super(initOpts);

			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.addEventListener(MouseEvent.MOUSE_DOWN, spf.stop);
			
			// Configure event listeners
			this.addEventListener(Event.CLOSE,
				function(e:Event):void
				{
					timer.stop();
				});
			
			start();

		}
		
		private function start():void
		{
			timer = new Timer(interval * 1000);
			timer.addEventListener(TimerEvent.TIMER, displayNewImage);
			timer.start();
			displayNewImage();
		}
		
		private function displayNewImage(e:TimerEvent = null):void
		{
			var stream:FileStream = new FileStream();
			stream.open(getRandomImageFile(), FileMode.READ);
			var imageBytes:ByteArray = new ByteArray();
			stream.readBytes(imageBytes);
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,
				function(e:Event):void
				{
					var bitmap:Bitmap = Bitmap(loader.content);
					bitmap.x = 0;
					bitmap.y = 0;
					bitmap.width = width;
					bitmap.height = height;
					var data:BitmapData = Bitmap(loader.content).bitmapData;
					if (lastBitmap != null)
					{
						stage.removeChild(lastBitmap);
					}
					stage.addChild(bitmap);
					lastBitmap = bitmap;
				});
			loader.loadBytes(imageBytes);
		}
		
		private function getRandomImageFile():File
		{
			return imageFiles[Math.round(Math.random() * (imageFiles.length - 1))];
		}
	}
}