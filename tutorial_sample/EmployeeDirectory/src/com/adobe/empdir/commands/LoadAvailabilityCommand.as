package com.adobe.empdir.commands
{
	import com.adobe.empdir.managers.ConfigManager;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.formatters.DateFormatter;
	import mx.utils.StringUtil;
	

	/**
	 * This command loads free/busy information using a Cold Fusion REST API that works as a proxy to the Outlook Web Access (OWA) service. The proxy
	 * manages authenticating to the OWA service, as well as sending the correct HTTP headers so that OWA returns the results in a proper format.
	 * 
	 * NOTE - This implementation uses mock local data for the sample
	 */ 
	public class LoadAvailabilityCommand extends Command
	{
		
		/** An array of OWAFreeBusyConstants values that is the result of this command. One constant for each load interval. **/
		public var results : Array;
		
		/**
		 * The templated URL
		 * Example: http://cfserver.mycompany.com/empdir/rest.cfm?service=exchange&cmd=GetUserAvailability&start={0}&end={1}&interval={2}&u=SMTP:{3}
		 * 	{0} -> 2007-06-15T00:00:00-08:00
		 *	{1} -> 2007-06-15T23:59:00-08:00
		 *  {2} -> 30
		 *  {3} -> dwabyick@mycompany.com
		 */ 
		private var scheduleURLTemplate : String;
		
		private var formatter : DateFormatter;
		private var calendarId : String;
		private var startDate : Date;
		private var endDate : Date;
		private var minuteInterval : uint;
		
		/**
		 * Constructor
		 * @param calendarId The identifier of the user/room that we are loading the schedule. 
		 * @param startDate The start date of the schedule loading.
		 * @param endDate The end date of the schedule loading.
		 * @param minuteInterval The interval that we request scheduling in minutes. 
		 */ 
		public function LoadAvailabilityCommand( calendarId:String, startDate:Date, endDate:Date, minuteInterval : uint = 30 )
		{
			this.calendarId = calendarId;
			this.startDate = startDate;
			this.endDate = endDate;
			this.minuteInterval = minuteInterval;
			scheduleURLTemplate = ConfigManager.getInstance().getProperty( "scheduleDataURLTemplate" );
		
			formatter = new DateFormatter();
			formatter.formatString =  "YYYY-MM-DDTJJ:NN:SS";
		}
		
		override public function execute() : void
		{
			// NOTE: Mock implementation.
			var localFileName : int = getMockFilePath();
			var url : String = StringUtil.substitute( scheduleURLTemplate, [ localFileName   ] );		

			// NOTE - Uncomment for the real remote implementation. 		
//			var url : String = StringUtil.substitute( scheduleURLTemplate, [ getOWADateString( startDate ), getOWADateString( endDate ), String( minuteInterval ), calendarId ] );		
//			trace("Availability URL :-" + url);

			url = url.replace( "\+", "%2B" );
			var req : URLRequest = new URLRequest( url );
			var ldr : URLLoader = new URLLoader( req );
			ldr.addEventListener( IOErrorEvent.IO_ERROR, onIOError );
			ldr.addEventListener( Event.COMPLETE, onLoadComplete );
		}
		
		
		private function onIOError( evt:ErrorEvent ) : void
		{
			logDebug( "onIOError()" );
			removeURLLoaderListeners( evt );
			notifyError( evt.toString() );
		}
		
		private function onHTTPStatus( evt:HTTPStatusEvent ) : void
		{
			logDebug("onHTTPStatus(): " + evt);
		}

		private function onLoadComplete( evt:Event ) : void
		{
			logDebug("onLoadComplete()");
			removeURLLoaderListeners( evt );
			
			var ldr : URLLoader = evt.target as URLLoader;

			results = new Array();
			
			var data : String = ( evt.target as URLLoader ).data;
			try {
				var xml : XML = XML( data );
			
				var sked : String =  XML( XMLList( xml .. *::fbdata )[0] ).text();
				for ( var i:int = 0; i < sked.length; i++ )
				{
					results.push( Number( sked.charAt( i ) ) );	
				}
				notifyComplete();
			}
			catch ( e:Error ) 
			{
				notifyError( "Error parsing availability XML." );
			}
		}
		
		
		private function getOWADateString( date:Date ) : String
		{
			return formatter.format( date ) + getTimeZoneString( date );
		} 
		
		private function getTimeZoneString( date:Date ) : String
		{
			var timeZone : int = date.getTimezoneOffset();
	
			var timeZoneHour : String = String( Math.floor( Math.abs(timeZone) / 60 ) );
			if ( timeZoneHour.length == 1 )
				timeZoneHour = "0" + timeZoneHour;
				
			var timeZoneMin : String = String( Math.abs(timeZone) % 60 );
			if ( timeZoneMin.length == 1 )
				timeZoneMin = "0" + timeZoneMin;
			
			if ( timeZone > 0 )
				return ( "-" + timeZoneHour + ":" + timeZoneMin );
			else
				return ( "+" + timeZoneHour + ":" + timeZoneMin );
		}
		
		private function removeURLLoaderListeners( evt:Event ) : void
		{
			var ldr : URLLoader = evt.target as URLLoader;
			ldr.removeEventListener( Event.COMPLETE, onLoadComplete );
			ldr.removeEventListener( IOErrorEvent.IO_ERROR, onIOError );
		}
		
		/**
		 * This function returns the modulus of the sum of uid and datetime string for consistent
		 * filename. 
		 * 
		 * This function is not needed for real implementation as the xml data would come from Exchange server.		
		 */
		private function getMockFilePath() : int
		{			
			var sumOfIdandDate : int ;
			for ( var i : int = 0 ; i < calendarId.length; i++ )
			{
				sumOfIdandDate = sumOfIdandDate + calendarId.charCodeAt(i);
			}	

			var owaDate : String = getOWADateString( startDate );
			for ( i = 0 ; i < owaDate.length; i++ )
			{
				sumOfIdandDate = sumOfIdandDate + owaDate.charCodeAt(i);
			}	

			// Modulus of sumOfIdandDate will return values between 0 to 5
			//trace("Mod of uid :-" + sumOfIdandDate % 5 );
			return sumOfIdandDate % 5; 

		}
		
	}
}