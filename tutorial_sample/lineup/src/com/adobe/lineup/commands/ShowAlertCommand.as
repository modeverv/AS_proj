package com.adobe.lineup.commands
{
	import com.adobe.air.alert.AlertEvent;
	import com.adobe.air.alert.NativeAlert;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.lineup.events.ShowAlertEvent;
	import com.adobe.lineup.model.ModelLocator;
	
	import flash.desktop.NativeApplication;

	
	public class ShowAlertCommand implements ICommand
	{
		public function execute(ce:CairngormEvent):void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			if (ml.showingAlert) return;
			ml.showingAlert = true;
			var message:String = ShowAlertEvent(ce).message;
			var title:String = ShowAlertEvent(ce).title;
			NativeAlert.show(message,
							 title,
							 NativeAlert.OK,
							 true,
							 NativeApplication.nativeApplication.openedWindows[0],
							 onClose,
							 ModelLocator.getInstance().alertIcon);
		}
		
		private function onClose(e:AlertEvent):void
		{
			ModelLocator.getInstance().showingAlert = false;
		}
	}
}
