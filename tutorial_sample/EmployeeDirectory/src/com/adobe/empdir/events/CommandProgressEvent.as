package com.adobe.empdir.events
{
	import com.adobe.empdir.commands.Command;
	import flash.events.Event;
	
	/**
	 * An event indicating that a command has progressed.
	 */ 
	public class CommandProgressEvent extends Event
	{
		public static const PROGRESS : String = "progress";
		
		public var command : Command;
		
		/**
		 * Constructor
		 */ 
		public function CommandProgressEvent( command:Command ) : void
		{
			super( PROGRESS );
			this.command = command;
		}
		
		/** The percentage completion of the command (0-100) **/
		public function get progress() : uint 
		{
			return command.progress;
		}
		
		/** A message string associated with the command progress. **/
		public function get progressMessage() : String
		{
			return command.progressMessage;
		}
	}
}