package com.adobe.empdir.commands
{
	import com.adobe.empdir.IncludeClasses;
	import com.adobe.empdir.commands.data.InitDatabaseCommand;
	import com.adobe.empdir.commands.style.LoadStyleSheetCommand;
	import com.adobe.empdir.events.CommandCompleteEvent;
	import com.adobe.empdir.events.CommandProgressEvent;
	import com.adobe.empdir.managers.ConfigManager;
	import com.adobe.empdir.managers.DatabaseConnectionManager;
	import com.adobe.empdir.managers.NetworkConnectionManager;
	import com.adobe.empdir.managers.WindowBoundsManager;
	import com.adobe.empdir.ui.ApplicationUI;
	
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemTrayIcon;
	import flash.display.Bitmap;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.Stage;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	import mx.core.Application;
	
	/**
	 * This command is used to manage initialization of the application.
	 */ 
	public class InitApplicationCommand extends Command
	{
		private static var CONFIG_URL : String = "config/employeedirectory_config.xml";
		
		private var configManager : ConfigManager;
		private var networkManager : NetworkConnectionManager;
		
		private var stage : Stage;
		private var ui : ApplicationUI;
		
		
		[Embed('/embed_assets/tray_icons/icon_16.png')]
		private static var sysTrayIcon16 : Class;
		
		[Embed('/embed_assets/tray_icons/icon_128.png')]
		private static var sysTrayIcon128 : Class;
		
		/**
		 * Constructor.
		 * @param The stage. Required for several
		 */ 
		public function InitApplicationCommand( stage:Stage, ui:ApplicationUI ) : void
		{
			super();
			this.stage = stage;
			this.ui = ui;
			
			// set this to false, when we close the application we first do an update.
			NativeApplication.nativeApplication.autoExit = false;
			
			setupSystemTrayIcon();
		
			/** Used to include parser classes that may be specified in configuration files. **/
			var ic : IncludeClasses;
					
		}
		
		/**
		 * Execute the application initialization command.
		 */ 
		override public function execute() : void
		{
			WindowBoundsManager.getInstance().init( stage.nativeWindow, ui );
			
			var cmd : LoadStyleSheetCommand = new LoadStyleSheetCommand();
			cmd.addEventListener( CommandCompleteEvent.COMPLETE, onLoadStyleSheet );
			cmd.addEventListener( ErrorEvent.ERROR, onLoadStyleSheetError );
			cmd.execute();
		}
		
		private function onLoadStyleSheetError( evt:ErrorEvent ) : void
		{
			var cmd : Command = evt.target as Command;
			cmd.removeEventListener( CommandCompleteEvent.COMPLETE, onLoadStyleSheet );
			cmd.removeEventListener( ErrorEvent.ERROR, onLoadStyleSheetError );
			
			
			notifyError( "Error loading stylesheet: " + evt.text );
		}
		
		private function onLoadStyleSheet( evt:CommandCompleteEvent ) : void
		{
			logDebug("onLoadStyleSheet()");
			var cmd : Command = evt.command;
			cmd.removeEventListener( CommandCompleteEvent.COMPLETE, onLoadStyleSheet );
			cmd.removeEventListener( ErrorEvent.ERROR, onLoadStyleSheetError );
			
			
			Application.application.visible = true;
			
			configManager = ConfigManager.getInstance();
			configManager.addEventListener( Event.COMPLETE, onConfigLoad );
			configManager.addEventListener( ErrorEvent.ERROR, onConfigLoadError );
			configManager.loadConfig( CONFIG_URL );
			
			progress = 5;
			notifyProgress( 5, "Initializing application ..." );
		}
		
		private function onConfigLoad( evt:Event ) : void
		{
			configManager.removeEventListener( Event.COMPLETE, onConfigLoad );
			configManager.removeEventListener( ErrorEvent.ERROR, onConfigLoadError );
			
			var connManager : DatabaseConnectionManager = DatabaseConnectionManager.getInstance();
			connManager.addEventListener( Event.INIT, onConnManagerInit );
			connManager.init();
			
		}
		
		private function onConnManagerInit( evt:Event ) : void
		{
			logDebug("onConnManagerInit()");

			networkManager = NetworkConnectionManager.getInstance();
			networkManager.addEventListener( Event.INIT, onNetworkManagerInit );
			networkManager.init();
		}
		
		private function onNetworkManagerInit( evt:Event ) : void
		{
			logDebug("onNetworkManagerInit: " + networkManager.networkAvailable );
			
			if ( networkManager.networkAvailable && configManager.getBooleanProperty( "checkForAppUpdates" ) )
			{
				
				var cmd : UpdateApplicationCommand = new UpdateApplicationCommand();
				cmd.addEventListener( CommandCompleteEvent.COMPLETE, onUpdateAppComplete );
				cmd.addEventListener( CommandProgressEvent.PROGRESS, onUpdateAppProgress );
				cmd.addEventListener( ErrorEvent.ERROR, onError );
				cmd.execute();
			}
			else
			{
				var cmd1 : InitDatabaseCommand = new InitDatabaseCommand();
				cmd1.addEventListener( CommandCompleteEvent.COMPLETE, onInitDBComplete );
				cmd1.addEventListener( ErrorEvent.ERROR, onError );
				cmd1.execute();
			}
		}
		
		private function onConfigLoadError( evt:ErrorEvent ) : void
		{
			notifyError( "Error loading config: " + evt.text );
		}
		
		private function onUpdateAppProgress( evt:CommandProgressEvent ) : void
		{
			notifyProgress( 30, evt.progressMessage );
		}
		
		private function onUpdateAppComplete( evt:Event ) : void
		{	
			var cmd : Command = evt.target as Command;
			cmd.removeEventListener( CommandCompleteEvent.COMPLETE, onUpdateAppComplete );
			cmd.removeEventListener( CommandProgressEvent.PROGRESS, onUpdateAppProgress );
			cmd.removeEventListener( ErrorEvent.ERROR, onError );
			
			var cmd1 : InitDatabaseCommand = new InitDatabaseCommand();
			cmd1.addEventListener( CommandCompleteEvent.COMPLETE, onInitDBComplete );
			cmd1.addEventListener( ErrorEvent.ERROR, onError );
			cmd1.execute();
			
			notifyProgress( 50 );
		}
		
		private function onInitDBComplete( evt:Event ) : void
		{
			logDebug("onInitDBComplete()");
			var cmd : InitDatabaseCommand = evt.target as InitDatabaseCommand;
			cmd.removeEventListener( CommandCompleteEvent.COMPLETE, onInitDBComplete );
			cmd.removeEventListener( ErrorEvent.ERROR, onError );
			
			notifyComplete();
		}
		
		private function onError( evt:ErrorEvent ) : void
		{
			var cmd : Command = evt.target as Command;
			cmd.removeEventListener( CommandCompleteEvent.COMPLETE, onInitDBComplete );
			cmd.removeEventListener( ErrorEvent.ERROR, onError );
			
			notifyError( evt.text );
		}
		
		private function setupSystemTrayIcon() : void
		{
			
			if ( NativeApplication.supportsSystemTrayIcon ) 
			{
				var icon : SystemTrayIcon = NativeApplication.nativeApplication.icon as SystemTrayIcon;
				icon.tooltip = "Employee Directory";
				icon.bitmaps = [ (new sysTrayIcon16() as Bitmap).bitmapData, (new sysTrayIcon128() as Bitmap).bitmapData ];
				icon.menu = new NativeMenu();
				
				icon.addEventListener( "click",
					function( event:Event ) : void
					{
						ui.stage.nativeWindow.visible = true;
						ui.stage.nativeWindow.activate();
					}
				);
				

				var exitCommand:NativeMenuItem = icon.menu.addItem( new NativeMenuItem( "Exit" ) );
				exitCommand.addEventListener( Event.SELECT,
				   	function( event:Event ):void
				   	{
				  		 ui.titleControls.closeApp();
					}
				);

			}
			
		}
	}
}