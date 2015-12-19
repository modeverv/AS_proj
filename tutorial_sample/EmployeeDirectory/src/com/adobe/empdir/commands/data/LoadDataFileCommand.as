package com.adobe.empdir.commands.data
{
	import com.adobe.empdir.commands.Command;
	
	import deng.fzip.FZip;
	import deng.fzip.FZipErrorEvent;
	import deng.fzip.FZipFile;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	/**
	 * This command loads a remote data file, encapsulating some of the conditional logic 
	 * as to whether or not it is a zipped data source. 
	 */ 
	public class LoadDataFileCommand extends Command
	{
		
		private var dataURL : String;
		
		public var loadedData : Object;
		/**
		 * Constructor
		 * @param url dataURL URL to the data file.
		 */ 
		public function LoadDataFileCommand( dataURL:String ) 
		{
			this.dataURL = dataURL;
		}
		
		
		override public function execute() : void
		{
			if ( dataURL.indexOf(".zip") > 0 )
			{
				var zip : FZip = new FZip();
				zip.addEventListener( Event.COMPLETE, onZipLoadComplete );
				zip.addEventListener( IOErrorEvent.IO_ERROR, onLoadError );
				//zip.addEventListener( HTTPStatusEvent.HTTP_STATUS, onZipLoadStatus );
				zip.addEventListener( FZipErrorEvent.PARSE_ERROR, onZipParseError );
				zip.load( new URLRequest( dataURL ) );
			} 
			else
			{	
				var ldr : URLLoader = new URLLoader( new URLRequest( dataURL ) );
				ldr.addEventListener( Event.COMPLETE, onLoadComplete );
				ldr.addEventListener( IOErrorEvent.IO_ERROR, onLoadError );	
			}
		}
		
		private function onZipParseError( evt:FZipErrorEvent ) : void
		{
			logDebug("onZipParseError()");
			var zip : FZip = evt.target as FZip;
			removeZipListeners( zip );
			notifyError( evt.text );
		}
		
		private function onZipLoadComplete( evt:Event ) : void
		{
			logDebug("onZipLoadComplete()");
			var zip : FZip = evt.target as FZip;
			var zipFile : FZipFile = zip.getFileAt( 0 );
			
			loadedData = zipFile.content;
			
			removeZipListeners( zip );
			
			notifyComplete();
		}
		
		
		private function onLoadComplete( evt:Event ) : void
		{
			logDebug("onLoadComplete()");
			
			var ldr : URLLoader = evt.target as URLLoader;
			ldr.removeEventListener( Event.COMPLETE, onLoadComplete );
			ldr.removeEventListener( IOErrorEvent.IO_ERROR, onLoadError );
			ldr.close();
			
			loadedData = ldr.data;
			
			ldr.data = null;
			ldr = null;
			
			notifyComplete();
		}
		
		private function removeZipListeners( zip:FZip ) : void
		{
			zip.removeEventListener( Event.COMPLETE, onZipLoadComplete );
			zip.removeEventListener( IOErrorEvent.IO_ERROR, onLoadError );
			//zip.removeEventListener( HTTPStatusEvent.HTTP_STATUS, onZipLoadstatus );
			zip.removeEventListener( FZipErrorEvent.PARSE_ERROR, onZipParseError );
			zip.close();	
		}
		
		private function onLoadError( evt:IOErrorEvent ) : void
		{
			logDebug("onLoadError()");
			// this is an expected error in offline mode.
			notifyError( "Error loading data source - " + dataURL );
		}
	}
}