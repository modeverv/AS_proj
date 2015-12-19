package com.adobe.empdir.avail
{
	import com.adobe.empdir.managers.NetworkConnectionManager;
	import flash.events.EventDispatcher;
	import mx.logging.ILogger;
	import com.adobe.empdir.util.LogUtil;
	import com.adobe.empdir.commands.LoadAvailabilityCommand;
	import com.adobe.empdir.avail.ICalendarObject;
	import flash.events.Event;
	import com.adobe.empdir.events.CommandCompleteEvent;
	import flash.events.ErrorEvent;
	import flash.events.StatusEvent;
	import com.adobe.empdir.util.DateUtil;
	
	/** 
	 * An event indicating that the state has changed. 
	 * @eventType flash.events.Event.CHANGE
	 */
	[Event(name="change", type="flash.events.Event")]
	
	
	/**
	 * This service provides searching for availability by date, and also works as a bindable
	 * source for availabilty results.
	 */ 
	public class AvailabilityService extends EventDispatcher
	{
		/** The data has successfully been retrieved. **/
		public static const DATA_RETRIEVED_STATE : String = "dataRetrieved";
		
		/** The data is currently being requested. **/
		public static const DATA_REQUESTING_STATE : String = "dataRequestingState";
		
		/** The availability data is unavailable. **/
		public static const DATA_UNAVAILABLE_STATE : String = "dataUnavailableState";
		
		/** 
		 * An array of OWAFreeBusyConstants representing the availability for the current 
		 * day in half-hour increments.
		 */
		[Bindable]
		public var results : Array;
		 
		
		private var networkManager : NetworkConnectionManager;
		private var logger : ILogger;
		private var _currentState : String;
		
		private var pendingCommand : LoadAvailabilityCommand;
		
		/**
		 * Constructor
		 */ 
		public function AvailabilityService() 
		{
			results = new Array();
			
			networkManager = NetworkConnectionManager.getInstance();
			networkManager.addEventListener( StatusEvent.STATUS, onNetworkStatus );
			
			if ( networkManager.networkAvailable )
			{
				currentState = DATA_RETRIEVED_STATE;
			}
			else
			{
				currentState = DATA_UNAVAILABLE_STATE;	
			}
			
			logger = LogUtil.getLogger( this );
		}
		
		
		/**
		 * Request availability for the given id and date. Availability is returned as 
		 * an array of OWAFreeBusyConstants for the given day in half-hour intervals.
		 * 
		 * @param calendarObject An ICalendarObject that has an associated identifier for requesting availability.
		 * @param date The date that we will use to request the current calendar. 
		 */ 
		public function requestAvailability( calendarObject:ICalendarObject, date:Date ) : void
		{
			logDebug("requestAvailability: " + calendarObject + " : " + date );
			cleanupCommand();
			pendingCommand = new LoadAvailabilityCommand( calendarObject.calendarId, DateUtil.getStartOfDay(date), DateUtil.getEndOfDay(date) );
			pendingCommand.addEventListener( CommandCompleteEvent.COMPLETE, onRequestComplete );
			pendingCommand.addEventListener( ErrorEvent.ERROR, onRequestError );
			pendingCommand.execute();
		}
		
		
		/**
		 * Clear any pending request and the associated data with the command.
		 */ 
		public function clear() : void
		{
			cleanupCommand();
			results = new Array();
		}
		
		private function onRequestComplete( evt:CommandCompleteEvent ) : void
		{
			results = pendingCommand.results;
			currentState = DATA_RETRIEVED_STATE;
			cleanupCommand();
		}
		
		private function onRequestError( evt:ErrorEvent ) : void
		{
			results = null;
			currentState = DATA_UNAVAILABLE_STATE;
			cleanupCommand();
		}
		
		private function cleanupCommand() : void
		{
			if ( pendingCommand ) 
			{
				pendingCommand.removeEventListener( CommandCompleteEvent.COMPLETE, onRequestComplete );
				pendingCommand.removeEventListener( ErrorEvent.ERROR, onRequestError );
				pendingCommand = null;
			}	
		}
		
		/** The current state of the service. Either DATA_RETRIEVED_STATE, DATA_REQUESTING_STATE, DATA_UNAVAILABLE_STATE  */
		[Bindable]
		public function get currentState() : String
		{
			return _currentState;
		}
		
	 
		private function set currentState( state:String ) : void
		{
			_currentState = state;
			dispatchEvent( new Event( Event.CHANGE ) );
		}
		
		
		private function onNetworkStatus( evt:StatusEvent ) : void
		{
			if ( networkManager.networkAvailable )
			{
				currentState = DATA_RETRIEVED_STATE;
			}
			else
			{
				clear();
				currentState = DATA_UNAVAILABLE_STATE;	
			}
		}
		
		private function logDebug( msg:String ) : void
		{
			logger.debug( msg );
		}
		
		
	}
}