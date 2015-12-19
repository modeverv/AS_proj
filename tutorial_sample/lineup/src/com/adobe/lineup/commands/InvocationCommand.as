package com.adobe.lineup.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.display.NativeWindow;
	import flash.display.NativeWindowDisplayState;
	import flash.desktop.NativeApplication;
	
	public class InvocationCommand implements ICommand
	{
		public function execute(ce:CairngormEvent):void
		{
			if (NativeApplication.nativeApplication.openedWindows == null || NativeApplication.nativeApplication.openedWindows.length == 0) return;
			var win:NativeWindow = NativeWindow(NativeApplication.nativeApplication.openedWindows[0]);
			if (win.displayState == NativeWindowDisplayState.MINIMIZED)
			{
				win.maximize();
			}
		}
	}
}
