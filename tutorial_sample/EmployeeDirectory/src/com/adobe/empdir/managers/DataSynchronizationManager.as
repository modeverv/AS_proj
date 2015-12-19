package com.adobe.empdir.managers
{
	import com.adobe.empdir.commands.data.GetLastUpdateCommand;
	import com.adobe.empdir.commands.data.SynchronizeDatabaseCommand;
	import com.adobe.empdir.events.CommandCompleteEvent;
	import com.adobe.empdir.events.DataSynchronizationEvent;
	import com.adobe.empdir.util.LogUtil;
	
	import flash.display.Stage;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.system.System;
	import flash.utils.Timer;
	
	import mx.logging.ILogger;
	
	
	
	/** 
	 * An event indicating that synchronization has started. 
	 *  @eventType com.adobe.empdir.events.DataSynchronizationEvent.SYNC_START
	 */
	[Event(name="syncStart", type="com.adobe.empdir.events.DataSynchronizationEvent")]
	
	/** 
	 * An event indicating that synchronization has completed. 
	 * @eventType com.adobe.empdir.events.DataSynchronizationEvent.SYNC_COMPLETE
	 */
	[Event(name="syncComplete", type="com.adobe.empdir.events.DataSynchronizationEvent")]
	
	
	/**
	 * This class periodically syncs the database to an external data store. It attempts to only do this 
	 * when there is no activity, and no searching is occurring.
	 */ 
	public class DataSynchronizationManager extends EventDispatcher
	{	
		[Bindable]
		public var lastUpdated : Date;
		
		private static var instance : DataSynchronizationManager;
		
		// this is the interval that we perform a check to see if we need to sync
		//private var checkInterval : uint = 1000 * 1;  // 1 second for testing. 
		private var checkInterval : uint = 1000 * 60 * 60;  // check every hour
		
		
		// this is the interval for mouse/keyboard activity timeouts
		private var activityInterval : uint = 1000 * 15; 
		//private var activityInterval : uint = 1000 * 2;
		
		// set to true to force a refresh every time
		private static var FORCE_SYNC : Boolean = false;
		
		private var timer : Timer;
		private var activityTimer : Timer;
		private var inited : Boolean;
		private var logger : ILogger;

		
		private var stage : Stage;
		
		/**
		 * Private constructor.
		 */ 
		public function DataSynchronizationManager() 
		{
			if ( instance != null )
			{
				throw new Error( "Private constructor. Use getInstance() instead." );
			}
			inited = false;
			logger = LogUtil.getLogger( this );
		}
		
		/**
		 * Get an instance of the location manager.
		 */ 
		public static function getInstance() : DataSynchronizationManager
		{
			if ( instance == null )
			{
				instance = new DataSynchronizationManager();
			}
			return instance;
		}
		
		/**
		 * Initialize the manager.
		 * @param stage We pass an instance of the stage, as the manager will not synchronize while 
		 *  there is any mouse activity. 
		 */ 
		public function init( stage:Stage ) : void
		{
			if ( ! inited )
			{
				inited = true;
				this.stage = stage;
				
				var cmd : GetLastUpdateCommand = new GetLastUpdateCommand();
				cmd.addEventListener( CommandCompleteEvent.COMPLETE, onInitGetLastUpdateComplete );
				cmd.addEventListener( ErrorEvent.ERROR, onInitGetLastUpdateError );
				cmd.execute();
			}
		}
				
				
		private function onInitGetLastUpdateComplete( evt:CommandCompleteEvent ) : void
		{
			var cmd : GetLastUpdateCommand = evt.target as GetLastUpdateCommand;
			cmd.removeEventListener( CommandCompleteEvent.COMPLETE, onInitGetLastUpdateComplete );
			cmd.removeEventListener( ErrorEvent.ERROR, onInitGetLastUpdateError );
			
			lastUpdated = cmd.lastUpdated;
		
			
			startSync();
		}
		
		
		private function onInitGetLastUpdateError( evt:ErrorEvent ) : void
		{	
			var cmd : GetLastUpdateCommand = evt.target as GetLastUpdateCommand;
			cmd.removeEventListener( CommandCompleteEvent.COMPLETE, onInitGetLastUpdateComplete );
			cmd.removeEventListener( ErrorEvent.ERROR, onInitGetLastUpdateError );
			
			startSync();
		}
		
		private function startSync() : void
		{
			logDebug( "startSync()" );
			timer = new Timer( checkInterval, 1 );
			timer.addEventListener( TimerEvent.TIMER, doSync );
			timer.start();
			
			// This timer provides a timeout for activity. We do this so we aren't constantly 
			// listening for activity and performing actions on every keystroke. 
			activityTimer = new Timer( activityInterval, 1 );
			activityTimer.addEventListener( TimerEvent.TIMER, onActivityTimeout );
			
			monitorActivity();
		}
		
		private function monitorActivity() : void
		{
			logDebug("monitorActivity()");
			
			// remove in case it was already added
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, onActivity );
			stage.removeEventListener( KeyboardEvent.KEY_DOWN, onActivity );
			
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onActivity );
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onActivity );
		}
		
		private function stopMonitorActivity() : void
		{
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, onActivity );
			stage.removeEventListener( KeyboardEvent.KEY_DOWN, onActivity );
			activityTimer.stop();
		}
		
		private function onActivity( evt:Event ) : void
		{
			logDebug("onActivity()");
			
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, onActivity );
			stage.removeEventListener( KeyboardEvent.KEY_DOWN, onActivity );
			
			if ( timer.running )
				timer.stop();
	
			activityTimer.reset();
			activityTimer.start();
		}
		
		
		
		private function onActivityTimeout( evt:TimerEvent ) : void
		{
			logDebug("onActivityTimeout()");
			
			monitorActivity();
			restartTimer();
		}
		
		
		private function doSync( evt:TimerEvent = null ) : void
		{
			logDebug( "doSync()" );
			
			sync( FORCE_SYNC );
		}
		
		/**
		 * Perform a database synchronization manually.
		 */ 
		public function sync( forceSync:Boolean = true ) : void
		{
			stopMonitorActivity();
			
			var cmd : SynchronizeDatabaseCommand = new SynchronizeDatabaseCommand( forceSync );
			
			// Listen for the command to see if synchronization truly happened, and not just a check. 
			cmd.addEventListener( DataSynchronizationEvent.SYNC_START, onSyncStart );
			cmd.addEventListener( DataSynchronizationEvent.SYNC_COMPLETE, onSyncComplete );
			
			cmd.addEventListener( CommandCompleteEvent.COMPLETE, onSyncCommandComplete );
			cmd.addEventListener( ErrorEvent.ERROR, onSyncError );
			cmd.execute();	
		}
		
		private function onSyncStart( evt:DataSynchronizationEvent ) : void
		{
			dispatchEvent( new DataSynchronizationEvent( DataSynchronizationEvent.SYNC_START ) );
		}
		
		private function onSyncComplete( evt:DataSynchronizationEvent ) : void
		{
			var cmd : GetLastUpdateCommand = new GetLastUpdateCommand();
			cmd.addEventListener( CommandCompleteEvent.COMPLETE, onSyncLastUpdateComplete );
			cmd.addEventListener( ErrorEvent.ERROR, onSyncLastUpdateError );
			cmd.execute();
				
			
		}
		
		private function onSyncLastUpdateComplete( evt:CommandCompleteEvent ) : void
		{
			var cmd : GetLastUpdateCommand = evt.target as GetLastUpdateCommand;
			cmd.removeEventListener( CommandCompleteEvent.COMPLETE, onSyncLastUpdateComplete );
			cmd.removeEventListener( ErrorEvent.ERROR, onSyncLastUpdateError );
			
			lastUpdated = cmd.lastUpdated;
			
			dispatchEvent( new DataSynchronizationEvent( DataSynchronizationEvent.SYNC_COMPLETE ) );
		}
		
		private function onSyncLastUpdateError( evt:ErrorEvent ) : void
		{
			var cmd : GetLastUpdateCommand = evt.target as GetLastUpdateCommand;
			cmd.removeEventListener( CommandCompleteEvent.COMPLETE, onSyncLastUpdateComplete );
			cmd.removeEventListener( ErrorEvent.ERROR, onSyncLastUpdateError );
		}
		
		private function onSyncCommandComplete( evt:Event ) : void
		{
			logDebug("onSyncCommandComplete(): " + systemMemStr);
			var cmd : SynchronizeDatabaseCommand = evt.target as SynchronizeDatabaseCommand;
			

			removeCommandListeners( cmd );
			
			monitorActivity();
			restartTimer();
		}
		
		private function onSyncError( evt:ErrorEvent ) : void
		{
			// NOTE: Sync errors can easily be caused by being offline. 
			logDebug( "onSyncError - " + evt.text );
			var cmd : SynchronizeDatabaseCommand = evt.target as SynchronizeDatabaseCommand;
			removeCommandListeners( cmd );
			
			monitorActivity();
			restartTimer();
		}
	
		private function restartTimer() : void
		{
			//logDebug("restartTimer()");
			timer.reset();
			timer.start();
		}
		
		private function removeCommandListeners( cmd:SynchronizeDatabaseCommand ) : void
		{
			cmd.removeEventListener( CommandCompleteEvent.COMPLETE, onSyncCommandComplete );
			cmd.removeEventListener( ErrorEvent.ERROR, onSyncError );
			cmd.removeEventListener( DataSynchronizationEvent.SYNC_START, onSyncStart );
			cmd.removeEventListener( DataSynchronizationEvent.SYNC_COMPLETE, onSyncComplete );
		}
		
		
		private function get systemMemStr() : String
		{
			return String( System.totalMemory / (1024*1024)) + " MB"; 
		}
		
		private function logDebug( msg:String ) : void
		{
			logger.debug( ": " + msg );	
		}
	}
}