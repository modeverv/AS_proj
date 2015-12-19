package com.adobe.lineup.commands
{
	import com.adobe.air.preferences.Preference;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.lineup.events.GetAppointmentsEvent;
	import com.adobe.lineup.events.SaveServerConfigEvent;
	import com.adobe.lineup.model.ModelLocator;
	import com.adobe.lineup.events.StartServerMonitorEvent;
	
	public class SaveServerConfigCommand implements ICommand
	{
		public function execute(ce:CairngormEvent):void
		{
			var ssce:SaveServerConfigEvent = ce as SaveServerConfigEvent;

			// Get server configuration
			var pref:Preference = new Preference();
			pref.load();
			pref.setValue("exchangeServer", ssce.exchangeServer);
			pref.setValue("exchangeDomain", ssce.exchangeDomain);
			pref.setValue("exchangeUsername", ssce.exchangeUsername);
			pref.setValue("exchangePassword", ssce.exchangePassword, true);
			pref.setValue("useHttps", ssce.useHttps);
			pref.save();

			var ml:ModelLocator = ModelLocator.getInstance();
			ml.serverInfo.exchangeServer = ssce.exchangeServer;
			ml.serverInfo.exchangeDomain = ssce.exchangeDomain;
			ml.serverInfo.exchangeUsername = ssce.exchangeUsername;
			ml.serverInfo.exchangePassword = ssce.exchangePassword;
			ml.serverInfo.useHttps = ssce.useHttps;
			ml.serverConfigOpen = false;

			var ssme:StartServerMonitorEvent = new StartServerMonitorEvent();
			ssme.dispatch();

			var gae:GetAppointmentsEvent = new GetAppointmentsEvent();
			gae.startDate = ModelLocator.getInstance().selectedDate;
			gae.endDate = ModelLocator.getInstance().selectedDate;
			gae.updateUI = true;
			gae.dispatch();
		}
	}
}
