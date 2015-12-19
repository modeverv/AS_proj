package com.adobe.empdir.events
{
	import com.adobe.empdir.commands.Command;
	import flash.events.Event;
	
	/**
	 * An event indicating that a command has completed.
	 */ 
	public class CommandCompleteEvent extends Event
	{
		public static const COMPLETE : String = "complete";
		
		public var command : Command;
		
		/**
		 * Constructor
		 */ 
		public function CommandCompleteEvent( command:Command ) : void
		{
			super( COMPLETE );
			this.command = command;
		}
	}
}