package com.adobe.empdir.commands
{
	import com.adobe.empdir.managers.ConfigManager;
	import com.adobe.empdir.model.Employee;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import mx.utils.StringUtil;
	
	/**
	 * This command will retrieve an image from the server or local store. It will throw
	 * an error if no image is available. 
	 */ 
	public class GetEmployeeImageCommand extends Command
	{
		/** The resulting image for this employee. **/
		public var imageBitmap : Bitmap;
		
		private var employee : Employee;
		private var loadThumb : Boolean;
		private var localFile : File;
		
		/**
		 * Constructor
		 * @param employee The employee that we are loading. 
		 * @param loadThumb Boolean True if we should load the thumb (smaller) size; false otherwise.
		 */
		public function GetEmployeeImageCommand( employee:Employee, loadThumb:Boolean = false ) 
		{
			this.employee = employee;	
			this.loadThumb = loadThumb;
		}
		
		/**
		 * Execute the command
		 */ 
		override public function execute() : void
		{
			// ensure the localDir is created.
			var localDir : File = File.applicationStorageDirectory.resolvePath( "images/" + employee.id.charAt(0) );
			localDir.createDirectory();
			
			localFile = loadThumb ? localDir.resolvePath( employee.id + "_sm.jpg" ) :   localDir.resolvePath( employee.id + ".jpg" );
			
			var stream : FileStream = new FileStream();
			try 
			{
				stream.open( localFile, FileMode.READ );
				var byteArray : ByteArray = new ByteArray();
				stream.readBytes( byteArray, 0, stream.bytesAvailable );
				stream.close();
				
				//logDebug("loading image from local file: " + localFile.nativePath);
				loadBytes( byteArray );
			}
			catch ( e:Error )
			{
				loadRemoteFile();
			}
			finally 
			{
				try { stream.close(); }
				catch ( e2:Error ) { }
			}
		
		}
		
		public function loadRemoteFile() : void
		{	
			var configManager : ConfigManager = ConfigManager.getInstance();
			var templateURL : String = loadThumb ? configManager.getProperty( "employeeThumbImageURLTemplate" ) : configManager.getProperty( "employeeImageURLTemplate" );
			
			var url : String = StringUtil.substitute( templateURL, employee.id );
		
			logDebug("Loading remote image: " + url);
			var urlLoader : URLLoader = new URLLoader( new URLRequest( url ) );
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.addEventListener( Event.COMPLETE, onImageLoadComplete );
			urlLoader.addEventListener( HTTPStatusEvent.HTTP_STATUS, onImageLoadHTTPStatus );
			urlLoader.addEventListener( IOErrorEvent.IO_ERROR, onImageLoadError );	
		}
		
		/**
		 * Callback upon completion of a successful image load. 
		 * 
		 * Note that we remove the callback on a 404 HTTP status code below.
		 */ 
		private function onImageLoadComplete( evt:Event ) : void
		{
			//logDebug("onImageLoadComplete()");
			var urlLoader : URLLoader = evt.target as URLLoader;
			urlLoader.removeEventListener( Event.COMPLETE, onImageLoadComplete );
			urlLoader.removeEventListener( HTTPStatusEvent.HTTP_STATUS, onImageLoadHTTPStatus );
			urlLoader.removeEventListener( IOErrorEvent.IO_ERROR, onImageLoadError );
			
			var byteArray : ByteArray = urlLoader.data as ByteArray;
			
		
			// first, try to save the imageData to a file
			var stream : FileStream = new FileStream();
			try 
			{
				stream.open( localFile, FileMode.WRITE );
				stream.writeBytes( byteArray, 0, byteArray.bytesAvailable );
				stream.close();
			}
			catch ( e:Error )
			{
				notifyComplete();
			}
			finally
			{
				try { stream.close(); }
				catch ( e2:Error ) { }
			}
			
			loadBytes( byteArray );
		}
		
		private function loadBytes( byteArray:ByteArray ) : void
		{
			// now, load the bitmap data from the bytes
			var loader : Loader = new Loader();
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onBytesLoadComplete );
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onBytesLoadError );
			loader.loadBytes( byteArray );
		}
		
		private function onImageLoadHTTPStatus( evt:HTTPStatusEvent ) : void
		{
			//logDebug( "onImageLoadHTTPStatus(" + evt.status +")");
			if ( evt.status == 404 )
			{
				// stop listening for the complete event, as we expect that to indicate a successful load.
				var urlLoader : URLLoader = evt.target as URLLoader;
				urlLoader.removeEventListener( Event.COMPLETE, onImageLoadComplete );
				urlLoader.removeEventListener( HTTPStatusEvent.HTTP_STATUS, onImageLoadHTTPStatus );
				urlLoader.removeEventListener( IOErrorEvent.IO_ERROR, onImageLoadError );
				
				// we can' t get to the image. 
				notifyError( "Image not found." );
			}
		}
		
		
		/**
		 * Callback when the loader has loaded images normally.
		 */ 
		private function onBytesLoadComplete( evt:Event ) : void
		{
			var loaderInfo : LoaderInfo = evt.target as LoaderInfo;
			loaderInfo.removeEventListener( Event.COMPLETE, onBytesLoadComplete );
			loaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, onBytesLoadError );
			
			imageBitmap =  loaderInfo.content as Bitmap;
	
			notifyComplete();
		}
		
		private function onBytesLoadError( evt:Event ) : void
		{
			var loaderInfo : LoaderInfo = evt.target as LoaderInfo;
			loaderInfo.removeEventListener( Event.COMPLETE, onBytesLoadComplete );
			loaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, onBytesLoadError );
			
			notifyError( "Error loading image bytes." );
		}
		
		
		private function onImageLoadError( evt:Event = null ) : void
		{
			// stop listening for the complete event, as we expect that to indicate a successful load.
			var urlLoader : URLLoader = evt.target as URLLoader;
			urlLoader.removeEventListener( Event.COMPLETE, onImageLoadComplete );
			urlLoader.removeEventListener( HTTPStatusEvent.HTTP_STATUS, onImageLoadHTTPStatus );
			urlLoader.removeEventListener( IOErrorEvent.IO_ERROR, onImageLoadError );
			
			notifyError( "Error loading image." );
		}
	}
}