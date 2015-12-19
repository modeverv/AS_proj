package com.adobe.lineup.commands
{
	import air.net.URLMonitor;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.lineup.model.ModelLocator;
	
	import flash.events.StatusEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	public class StartServerMonitorCommand implements ICommand
	{
		public function execute(ce:CairngormEvent):void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			var req:URLRequest = new URLRequest("http://" + ml.serverInfo.exchangeServer);
			req.method = URLRequestMethod.HEAD;
			var monitor:URLMonitor = new URLMonitor(req);
			monitor.addEventListener(StatusEvent.STATUS, onNetworkStatusChange);
			monitor.pollInterval = 0;
			monitor.acceptableStatusCodes.push(302);
			monitor.start();
			ml.serverMonitor = monitor;
		}

		private function onNetworkStatusChange(e:StatusEvent):void
		{
			ModelLocator.getInstance().online = (e.code == "Service.available") ? true : false;
		}
	}
}
