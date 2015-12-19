package com.adobe.empdir.commands.ui
{
	import com.adobe.empdir.commands.Command;
	import com.adobe.empdir.commands.data.SynchronizeDatabaseCommand;
	import com.adobe.empdir.events.CommandCompleteEvent;
	import com.adobe.empdir.managers.WindowBoundsManager;
	
	import flash.events.ErrorEvent;
	import flash.desktop.NativeApplication;
	
	import mx.core.Application;
	
	/**
	 * This command is responsible for closing the application. It first makes sure that the window won't automatically close the application.
	 */ 
	public class CloseApplicationCommand extends Command
	{
		override public function execute() : void
		{
			
			WindowBoundsManager.getInstance().saveWindowPosition();
			
			// close the window, and then do a sync check in the background
			//Application.application.stage.window.close();
			Application.application.stage.nativeWindow.visible = false;
			
			var cmd : SynchronizeDatabaseCommand = new SynchronizeDatabaseCommand( false );
			cmd.addEventListener( CommandCompleteEvent.COMPLETE, onCommandComplete );
			cmd.addEventListener( ErrorEvent.ERROR, onCommandError );
			cmd.execute();
		}
		
		private function onCommandComplete( evt:CommandCompleteEvent ) : void
		{
			logDebug("onCommandComplete()");
			
			NativeApplication.nativeApplication.exit();
		}
		
		private function onCommandError( evt:ErrorEvent ) : void
		{
			logError("onCommandError()");
			NativeApplication.nativeApplication.exit();	
		}
	}
}