package com.adobe.lineup.controller
{
	import com.adobe.cairngorm.control.FrontController;
	
	public class Controller extends FrontController
	{

		import com.adobe.lineup.events.*;
		import com.adobe.lineup.commands.*;

		public function Controller()
		{
			this.addCommands();
		}
		
		private function addCommands():void
		{
			this.addCommand(InitEvent.INIT_EVENT, InitCommand);
			this.addCommand(InvocationEvent.INVOCATION_EVENT, InvocationCommand);
			this.addCommand(ActivateEvent.ACTIVATE_EVENT, ActivateCommand);
			this.addCommand(BoundsChangeEvent.BOUNDS_CHANGE_EVENT, BoundsChangeCommand);
			this.addCommand(ShutdownEvent.SHUTDOWN_EVENT, ShutdownCommand);
			this.addCommand(GetAppointmentsEvent.GET_APPOINTMENTS_EVENT, GetAppointmentsCommand);
			this.addCommand(SaveServerConfigEvent.SAVE_SERVER_CONFIG_EVENT, SaveServerConfigCommand);
			this.addCommand(StartServerMonitorEvent.START_SERVER_MONITOR_EVENT, StartServerMonitorCommand);
			this.addCommand(ShowAlertEvent.SHOW_ALERT_EVENT, ShowAlertCommand);
			this.addCommand(NotificationCheckEvent.NOTIFICATION_CHECK_EVENT, NotificationCheckCommand);
			this.addCommand(OpenDetailsEvent.OPEN_DETAILS_EVENT, OpenDetailsCommand);
			this.addCommand(UpdateIconsEvent.UPDATE_ICONS_EVENT, UpdateIconsCommand);
		}
		
	}
}
