package com.adobe.lineup.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.lineup.events.BoundsChangeEvent;
	import flash.desktop.NativeApplication;
	import flash.events.NativeWindowBoundsEvent;
	import flash.geom.Rectangle;
	import flash.display.NativeWindow;
	
	public class BoundsChangeCommand implements ICommand
	{
		public function execute(ce:CairngormEvent):void
		{
			// Placeholder
		}
	}
}
