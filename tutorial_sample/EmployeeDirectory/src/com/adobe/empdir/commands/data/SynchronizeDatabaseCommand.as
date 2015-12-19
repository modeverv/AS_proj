package com.adobe.empdir.commands.data
{
	import com.adobe.empdir.commands.Command;
	import com.adobe.empdir.events.CommandCompleteEvent;
	import com.adobe.empdir.events.DataSynchronizationEvent;
	import com.adobe.empdir.managers.ConfigManager;
	
	import flash.data.SQLResult;
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.net.Responder;
	import flash.events.SQLEvent;

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
	 * A command to synchronize the database to an external data source.
	 * 
	 * NOTE: This command currently executes two separate commands for conf-room and employee-data commands that each
	 * separate transactions. While logically, they should be committed in a single transaction, 
	 * we can get away with this because we only update the updatelog table if they were both successful.
	 */ 
	public class SynchronizeDatabaseCommand extends SQLCommand
	{
		private var configManager : ConfigManager;
		private var employeeDataURL : String;
		private var confRoomDataURL : String;
		private var syncTimeout : Number;
		private var forceSync : Boolean;
		private var insertResponder : Responder;
		
		private var loadedEmployeeData : Object;
		private var loadedConferenceRoomData : Object;
		
		/**
		 * Constructor
		 * @param forceSync True if we should force synchronization regardless of the time comparison.
		 */ 
		public function SynchronizeDatabaseCommand( forceSync:Boolean = false ) 
		{
			this.forceSync = forceSync;
			configManager = ConfigManager.getInstance();
			employeeDataURL = configManager.getProperty( "employeeDataURL" );
			confRoomDataURL = configManager.getProperty( "conferenceRoomDataURL" );
			syncTimeout = configManager.getNumericProperty( "syncTimeoutHourInterval" ) * 60 * 60 * 1000;
			if ( isNaN( syncTimeout ) )
			{
				syncTimeout = 24 * 60 * 60 * 1000;
			}
		}
		
		
		/**
		 * Execute the SQL.
		 */ 
		override protected function executeSQL() : void
		{
			if ( forceSync )
			{
				refreshData();
			}
			else
			{
				stmt.text = "SELECT lastUpdated from updatelog";
				stmt.execute( -1, new Responder( onCheckLastRead, onSQLError ) );
			}
		}
		
		private function onCheckLastRead( res:SQLResult ) : void
		{
			// TODO: Make a better date check. Right now we just check that there are no records.
			var lastRead : Number = res.data[0]["lastUpdated"];
			
			if ( lastRead > 0 )
			{
				if ( lastRead + syncTimeout < new Date().getTime() )
				{
					refreshData();
				}
				else
				{
					notifyComplete();
				}
			}
			else
			{
				refreshData();
			}

		}
			
		/**
		 * Refresh teh data source.
		 */ 
		private function refreshData() : void
		{
			logDebug("refreshData(): " + employeeDataURL);
			 
			loadEmployeeData();
		}
		
		private function loadEmployeeData() : void
		{
			if ( employeeDataURL == null )
			{
				notifyError( "Error loading data. No 'employeeDataURL' config property defined." );
				return;
			}
			
			var cmd : LoadDataFileCommand = new LoadDataFileCommand( employeeDataURL );
			cmd.addEventListener( CommandCompleteEvent.COMPLETE, onEmployeeDataLoadComplete );
			cmd.addEventListener( ErrorEvent.ERROR, onEmployeeDataLoadError );
			cmd.execute();
		}
		
		private function onEmployeeDataLoadComplete( evt:CommandCompleteEvent ) : void
		{
			logDebug("onEmployeeDataLoadComplete()");
			var cmd : LoadDataFileCommand = evt.target as LoadDataFileCommand;
			cmd.removeEventListener(CommandCompleteEvent.COMPLETE, onEmployeeDataLoadComplete );
			cmd.removeEventListener( ErrorEvent.ERROR, onEmployeeDataLoadError );
			
			loadedEmployeeData = cmd.loadedData;
			
			loadConferenceRoomData();
		}

		private function onEmployeeDataLoadError( evt:ErrorEvent ) : void
		{
			logDebug("onEmployeeDataLoadError() - " + evt.text);
			var cmd : LoadDataFileCommand = evt.target as LoadDataFileCommand;
			cmd.removeEventListener( CommandCompleteEvent.COMPLETE, onEmployeeDataLoadComplete );
			cmd.removeEventListener( ErrorEvent.ERROR, onEmployeeDataLoadError );
			
			notifyError( evt.text );
		}
		
		private function loadConferenceRoomData() : void
		{
			if ( confRoomDataURL == null )
			{
				notifyError( "Error loading data. No 'conferenceRoomDataURL' config property defined." );
				return;
			}
			
			var cmd : LoadDataFileCommand = new LoadDataFileCommand( confRoomDataURL );
			cmd.addEventListener( CommandCompleteEvent.COMPLETE, onConfRoomDataLoadComplete );
			cmd.addEventListener( ErrorEvent.ERROR, onConfRoomDataLoadError );
			cmd.execute();
		}
		
		
		private function onConfRoomDataLoadComplete( evt:CommandCompleteEvent ) : void
		{
			logDebug("onConfRoomDataLoadComplete()");
			var cmd : LoadDataFileCommand = evt.target as LoadDataFileCommand;
			cmd.removeEventListener( CommandCompleteEvent.COMPLETE, onConfRoomDataLoadComplete );
			cmd.removeEventListener( ErrorEvent.ERROR, onConfRoomDataLoadError );
			
			loadedConferenceRoomData = cmd.loadedData;
			
			syncEmployeeData();
		}

		private function onConfRoomDataLoadError( evt:ErrorEvent ) : void
		{
			logDebug("onConfRoomDataLoadError() - " + evt.text);
			var cmd : LoadDataFileCommand = evt.target as LoadDataFileCommand;
			cmd.removeEventListener( CommandCompleteEvent.COMPLETE, onConfRoomDataLoadComplete );
			cmd.removeEventListener( ErrorEvent.ERROR, onConfRoomDataLoadError );
			
			loadedEmployeeData = null;
			notifyError( evt.text );
		}
		
		
		
		
		private function syncEmployeeData() : void
		{
			// We got our data. w00t! Inform others that we are started syncing.
			dispatchEvent( new DataSynchronizationEvent( DataSynchronizationEvent.SYNC_START ) );
			
			var cmd : InsertEmployeeDataCommand = new InsertEmployeeDataCommand( loadedEmployeeData );
			cmd.addEventListener( CommandCompleteEvent.COMPLETE, onSyncEmployeeComplete );
			cmd.addEventListener( ErrorEvent.ERROR, onSyncEmployeeError );
			cmd.execute();
		}
		
		private function onSyncEmployeeComplete( evt:CommandCompleteEvent ) : void
		{
			logDebug( "onSyncEmployeeComplete()" );
			var cmd : Command = evt.target as Command;
			cmd.removeEventListener( CommandCompleteEvent.COMPLETE, onSyncEmployeeComplete );
			cmd.removeEventListener( ErrorEvent.ERROR, onSyncEmployeeError );
			
			// delete the local cache of images to conform to company policy
			var imageDir : File = File.applicationStorageDirectory.resolvePath( "images/" );
			if ( imageDir.exists )
				imageDir.deleteDirectory( true );
			
			loadedEmployeeData = null;
			syncConferenceRoomData();
		}
		
		private function onSyncEmployeeError( evt:ErrorEvent ) : void
		{
			logError( "onSyncEmployeeError: " + evt );
			var cmd : Command = evt.target as Command;
			cmd.removeEventListener( CommandCompleteEvent.COMPLETE, onSyncEmployeeComplete );
			cmd.removeEventListener( ErrorEvent.ERROR, onSyncEmployeeError );
			
			loadedEmployeeData = null;
			notifyError( evt.text );
		}
		
		private function syncConferenceRoomData() : void
		{
			// We got our data. w00t! Inform others that we are started syncing.
			dispatchEvent( new DataSynchronizationEvent( DataSynchronizationEvent.SYNC_START ) );
			
			var cmd : InsertConferenceRoomDataCommand = new InsertConferenceRoomDataCommand( loadedConferenceRoomData );
			cmd.addEventListener( CommandCompleteEvent.COMPLETE, onSyncConfRoomComplete );
			cmd.addEventListener( ErrorEvent.ERROR, onSyncConfRoomError );
			cmd.execute();
		}
		
		private function onSyncConfRoomComplete( evt:CommandCompleteEvent ) : void
		{
			logDebug( "onSyncConfRoomComplete()" );
			var cmd : Command = evt.target as Command;
			cmd.removeEventListener( CommandCompleteEvent.COMPLETE, onSyncConfRoomComplete );
			cmd.removeEventListener( ErrorEvent.ERROR, onSyncEmployeeError );
			
			// NOTE: Update the appVersion here so that only on a successful sync of both commands.
			// This happens OUTSIDE the two transactions of the commands, but will only be executed if both
			// commands succeed.
			var time : String = String( new Date().getTime() );
			var appVersion : String = configManager.applicationVersion;
			
			stmt.text = "UPDATE updatelog set lastUpdated = '" + time + "', appVersion = '" + appVersion + "';" ;
			stmt.execute( -1, new Responder( updateComplete, onSQLError ) );
		}
				
		
		private function updateComplete( res:SQLResult ) : void
		{
			logDebug("updateComplete()");
			dispatchEvent( new DataSynchronizationEvent( DataSynchronizationEvent.SYNC_COMPLETE ) );
			notifyComplete();
		}
		
		
		private function onSyncConfRoomError( evt:ErrorEvent ) : void
		{
			logError( "onSyncConfRoomError: " + evt );
			var cmd : Command = evt.target as Command;
			cmd.removeEventListener( CommandCompleteEvent.COMPLETE, onSyncConfRoomComplete );
			cmd.removeEventListener( ErrorEvent.ERROR, onSyncConfRoomError );
			notifyError( evt.text );
		}
		
	}	
}