package com.adobe.empdir.util
{
	import com.adobe.empdir.commands.Command;
	import com.adobe.empdir.commands.GetEmployeeImageCommand;
	import com.adobe.empdir.events.CommandCompleteEvent;
	import com.adobe.empdir.model.Employee;
	
	import flash.display.Bitmap;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * This class functions as an easily bindable source for getting
	 * employee image bitmaps, providing a consistent fallback image.
	 */ 
	public class EmployeeImageProxy extends EventDispatcher
	{
		
		private var _employee : Employee;
		private var _imageBitmap : Bitmap;
		
		private var pendingCommand : GetEmployeeImageCommand;
		
		[Embed('/embed_assets/image_unavailable.png')]
		private static var imageUnavailClass : Class;
		
		
		/** This indicates whether or not we load the miniThumb. **/
		public var miniThumb : Boolean = false;
		
		
		/**
		 * Constructor
		 */ 
		public function EmployeeImageProxy() : void
		{
			
		}
		
		[Bindable]
		/**
		 * Get the empplo
		 */ 
		public function get employee() : Employee
		{
			return _employee;
		}
		
		/**
		 * Set the employee. This will update the imageData automatically.
		 */ 
		public function set employee( emp:Employee ) : void
		{
			_employee = emp;
			_imageBitmap = null;
			dispatchEvent( new Event( "imageDataUpdated" ) );
			
		
			if ( emp != null )
			{
				pendingCommand = new GetEmployeeImageCommand( emp, miniThumb );	
				pendingCommand.addEventListener( CommandCompleteEvent.COMPLETE, onImageLoad );
				pendingCommand.addEventListener( ErrorEvent.ERROR, onImageLoadError );
				pendingCommand.execute();
			}
		}
		
		private function onImageLoad( evt:CommandCompleteEvent ) : void
		{
			var cmd : GetEmployeeImageCommand = evt.target as GetEmployeeImageCommand;
			
			if ( cmd == pendingCommand )
			{
				_imageBitmap = pendingCommand.imageBitmap;
				dispatchEvent( new Event( "imageDataUpdated" ) );
				pendingCommand = null;
			}
				
			removeCommandListeners( cmd );
		}
		
		private function onImageLoadError( evt:Event ) : void
		{
			var cmd : GetEmployeeImageCommand = evt.target as GetEmployeeImageCommand;
			
			if ( cmd == pendingCommand )
			{
				dispatchEvent( new Event( "imageDataUpdated" ) );
				pendingCommand = null;
			}
			removeCommandListeners( cmd );
		}
		
		[Bindable("imageDataUpdated")]
		public function get imageBitmap() : Bitmap
		{
			if ( _imageBitmap != null )
			{
				return _imageBitmap;
			}
			else
			{
				return new imageUnavailClass();
			}
		}
		
		private function removeCommandListeners( cmd:Command ) : void
		{
			cmd.removeEventListener( CommandCompleteEvent.COMPLETE, onImageLoad );
			cmd.removeEventListener( ErrorEvent.ERROR, onImageLoadError );
		}
	}
}