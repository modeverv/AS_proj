package com.adobe.empdir.commands
{
	import com.adobe.empdir.managers.ConfigManager;
	
	import flash.desktop.Updater;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	/**
	 * This command is responsible for checking that the application is updated to
	 * the latest version.
	 */ 
	public class UpdateApplicationCommand extends Command
	{
		private var configManager : ConfigManager = ConfigManager.getInstance();
		private var loader : URLLoader;
		
		private var latestVersionId : String;
		
		override public function execute() : void
		{
			
			var configURL : String = configManager.getProperty( "appCurrentVersionURL" );
			
			loader = new URLLoader( new URLRequest( configURL ) );
			loader.addEventListener( Event.COMPLETE, onConfigLoadComplete );
			loader.addEventListener( IOErrorEvent.IO_ERROR, onLoadIOError );
			
		}
		
		private function onConfigLoadComplete( evt:Event ) : void
		{
			logDebug( "onConfigLoadComplete()" );
			loader.removeEventListener( Event.COMPLETE, onConfigLoadComplete );
			loader.removeEventListener( IOErrorEvent.IO_ERROR, onLoadIOError );
			
			var xml : XML = XML( loader.data );
			
			latestVersionId = xml.attribute( "latestVersion" );
			var latestVersion : Number =  Number( latestVersionId );
			var currentVersion : Number = Number( configManager.applicationVersion );
			
			logDebug( "currentVersion: " + currentVersion + " latestVersion: " + latestVersion );

			if ( latestVersion > currentVersion )
			{
				var airURL : String = xml.attribute( "airURL" );
				
				progressMessage = "Updating application to latest version. Please wait ...";
				progress = 20;
				
				updateApp( airURL );
			}
			else
			{
				notifyComplete();
			}
			
		}
		
		private function updateApp( airURL:String ) : void
		{
			logDebug("updateApp(" + airURL + ")");
			loader.addEventListener( Event.COMPLETE, onAirLoadComplete );
			loader.addEventListener( IOErrorEvent.IO_ERROR, onLoadIOError ); 
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.load( new URLRequest( airURL ) );
		}
		
		private function onAirLoadComplete( evt:Event ) : void
		{
			logDebug("onAirLoadComplete(): " + loader.data.length);
			loader.removeEventListener( Event.COMPLETE, onAirLoadComplete );
			loader.removeEventListener( IOErrorEvent.IO_ERROR, onLoadIOError );
			
			var fileStream : FileStream = new FileStream();
			var tmpDir : File = File.createTempDirectory();
			var airfile : File = tmpDir.resolvePath( "employeedirectory.air" );
			
			var bytes : ByteArray = loader.data as ByteArray;
			
			fileStream.open( airfile, FileMode.WRITE );
			fileStream.writeBytes( bytes, 0, bytes.length );
			fileStream.close();
			
			// do the update
			var updater : Updater = new Updater();

			// this will restart the app
			updater.update( airfile, latestVersionId );
			
			//fileStream.addEventListener(Event.CLOSE, fileClosed);
			//fileStream.openAsync(file, FileMode.WRITE);
			//fileStream.close();
		}
		
		private function onLoadIOError( evt:Event ) : void
		{
			loader.removeEventListener( Event.COMPLETE, onConfigLoadComplete );
			loader.removeEventListener( Event.COMPLETE, onAirLoadComplete );
			loader.removeEventListener( IOErrorEvent.IO_ERROR, onLoadIOError );
			
			// we're not connected, probably, so don't update right now
			notifyComplete();
		}
	}
}