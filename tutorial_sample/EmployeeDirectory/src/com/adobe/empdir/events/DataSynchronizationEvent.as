package com.adobe.empdir.events
{
	
	import flash.events.Event;
	
	/**
	 * A event indicating that the database has started a synchronization event.
	 */ 
	public class DataSynchronizationEvent extends Event
	{
		public static const SYNC_START : String = "syncStart";
		public static const SYNC_COMPLETE : String = "syncComplete";
	
		/**
		 * Constructor
		 * @param event The type of event. SYNC_START or SYNC_COMPLETE
		 */ 
		public function DataSynchronizationEvent( type:String ) : void
		{
			super( type );
		}
	}
}