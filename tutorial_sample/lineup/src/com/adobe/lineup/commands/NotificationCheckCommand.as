package com.adobe.lineup.commands
{
	import com.adobe.air.notification.AbstractNotification;
	import com.adobe.air.notification.Notification;
	import com.adobe.air.notification.NotificationClickedEvent;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.lineup.model.ModelLocator;
	import com.adobe.lineup.vo.CalendarEntry;
	
	import flash.desktop.NativeApplication;
	import flash.desktop.NotificationType;
	import flash.display.Bitmap;
	
	import mx.formatters.DateFormatter;

	public class NotificationCheckCommand implements ICommand
	{
		public function execute(ce:CairngormEvent):void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			var appts:Array = ml.db.getReminders();

			if (appts != null && appts.length > 0)
			{
				var alerts:Array = new Array();
				for each (var a:Object in appts)
				{
					if (ml.db.countAlerts(a.start_date as Date, a.end_date as Date, a.subject) == 0)
					{
						alerts.push(a);
					}
				}				

				if (alerts.length == 0) return;

				var notificationDateFormatter:DateFormatter = new DateFormatter();
				notificationDateFormatter.formatString = "L:NN A";

				if (NativeApplication.nativeApplication.activeWindow == null)
				{
					ml.purr.setIcons([ml.alertIcon], "Upcoming appointment");
				}
				
				ml.purr.alert(NotificationType.CRITICAL, NativeApplication.nativeApplication.openedWindows[0]);

				for each (var appt:Object in alerts)
				{
					var notification:Notification = new Notification(notificationDateFormatter.format(appt.start_date) +
													  " - " +
													  notificationDateFormatter.format(appt.end_date),
													  appt.subject, null, 5, new Bitmap(ml.notificationIcon.bitmapData.clone()));
					notification.width = 250;
					notification.id = appt.url;
					notification.addEventListener(NotificationClickedEvent.NOTIFICATION_CLICKED_EVENT,
						function(e:NotificationClickedEvent):void
						{
							var url:String = AbstractNotification(e.target).id;
							var ml:ModelLocator = ModelLocator.getInstance();
							for each (var se:CalendarEntry in ml.appointments)
							{
								if (se.url == url)
								{
									NativeApplication.nativeApplication.activate();
									ml.selectedAppointment = null;
									ml.selectedAppointment = se;
									break;
								}
							}
						});
					ml.purr.addNotification(notification);
					ml.db.insertAlert(appt.start_date, appt.end_date, appt.subject);	
				}
			}
		}
	}
}
