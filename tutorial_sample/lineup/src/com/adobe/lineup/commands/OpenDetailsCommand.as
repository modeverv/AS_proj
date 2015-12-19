package com.adobe.lineup.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.lineup.events.OpenDetailsEvent;
	import com.adobe.lineup.views.pages.AppointmentDetails;
	import com.adobe.lineup.vo.CalendarEntry;
	
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.Screen;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class OpenDetailsCommand implements ICommand
	{
		public function execute(ce:CairngormEvent):void
		{
			var ode:OpenDetailsEvent = ce as OpenDetailsEvent;
			var event:CalendarEntry = ode.event;
			var details:AppointmentDetails = new AppointmentDetails();
			details.entry = event;

			// Close any windows that are already open
			for (var i:uint = 1; i < NativeApplication.nativeApplication.openedWindows.length; ++i)
			{
				NativeWindow(NativeApplication.nativeApplication.openedWindows[i]).close();
			}

			var win:NativeWindow = NativeApplication.nativeApplication.openedWindows[0] as NativeWindow;

			var appBounds:Rectangle = win.bounds;
			
			var adjustedPoint:Point = win.globalToScreen(new Point(ode.clickX, ode.clickY));

			var winX:uint = adjustedPoint.x;
			var winY:uint = adjustedPoint.y - 60;
			
			var currentScreen:Screen = Screen.getScreensForRectangle(appBounds).pop();

			var actualWidth:uint = currentScreen.bounds.width + currentScreen.bounds.x;			

			details.open(true);
			
			if ((winX + details.width) >= actualWidth)
			{
				winX = actualWidth - details.width;
			}
			
			var newBounds:Rectangle = new Rectangle(winX, winY, details.width, details.height);
			details.nativeWindow.bounds = newBounds;
		}
	}
}