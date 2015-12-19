package com.adobe.empdir.commands
{
	import com.adobe.empdir.events.CommandCompleteEvent;
	import com.adobe.empdir.events.CommandProgressEvent;
	import com.adobe.empdir.util.LogUtil;
	
	import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;
	
	import mx.logging.ILogger;
	
	[Event(name="complete", type="com.adobe.empdir.events.CommandCompleteEvent")]
	
	[Event(name="progress", type="com.adobe.empdir.events.CommandProgressEvent")]
	
	/** An event indicating that the initialization has failed. **/
	[Event(name="error", type="flash.events.ErrorEvent")]
	
	/**
	 * A simple command superclass.
	 */ 
	public class Command extends EventDispatcher
	{
		/** The percentage completion of the command (0-100) **/
		public var progress : uint = 0;
		
		/** A message string associated with the command progress. **/
		public var progressMessage : String;
		
		protected var logger : ILogger;
		
		/**
		 * Constructor
		 */ 
		public function Command() 
		{
			logger = LogUtil.getLogger( this );
		}
		/**
		 * Execute the command.   Abstract method.
		 */ 
		public function execute() : void
		{
			throw new Error("execute() must be override by subclasses.");
		}
		
		/**
		 * Notify listeners that the command has completed.
		 */ 
		protected function notifyComplete() : void
		{
			progress = 100;
			dispatchEvent( new CommandCompleteEvent( this ) );
		}
		
		/**
		 * Notify listeners that the command has updated progress.
		 */ 
		protected function notifyProgress( progress:uint, progressMessage:String = null ) : void
		{
			this.progress = progress;
			if ( progressMessage )	
				this.progressMessage = progressMessage;
			dispatchEvent( new CommandProgressEvent( this ) );
		}
		
		/**
		 * Notify listeners that an error has occured executing the command.
		 */ 
		protected function notifyError( msg:String ) : void
		{
			logError( ": " + msg );
			
			var evt : ErrorEvent = new ErrorEvent( ErrorEvent.ERROR );
			evt.text = msg;
			dispatchEvent( evt );
		}
		
		protected function logDebug( msg:String ) : void
		{
			logger.debug( ": " + msg );
		}
		
		protected function logError( msg:String ) : void
		{
			logger.error( ": " + msg );
		}
	}
}