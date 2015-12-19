package com.adobe.empdir.commands.style
{
	import com.adobe.empdir.commands.Command;
	import com.adobe.empdir.managers.SettingsManager;
	import com.adobe.empdir.style.RuntimeStyleRegistry;
	
	import flash.events.IEventDispatcher;
	
	import mx.events.StyleEvent;
	import mx.styles.StyleManager;

	/**
	 * This command loads a runtime CSS stylesheet SWF.
	 * 
	 * @see  com.adobe.empdir.styles.StyleSheetConstants for available paths
	 */ 
	public class LoadStyleSheetCommand extends Command
	{
		private var fileName : String;
		private var saveSettings : Boolean;
		
		/**
		 * Constructor
		 * @param fileName The path to the CSS SWF. If its blank, a default will be loaded from a Local Shared Object.
		 * @param saveSettings True if we should save the given settings to a Shared Object; false otherwise.
		 */ 
		public function LoadStyleSheetCommand( fileName:String = null, saveSettings:Boolean = false) 
		{
			this.fileName = fileName;
			this.saveSettings = saveSettings;
		}
		
		override public function execute():void
		{

			var settingsManager : SettingsManager = SettingsManager.getInstance();
			if ( fileName == null )
			{	
				fileName = settingsManager.getSetting( SettingsManager.STYLESHEET ) as String;
				
				if ( fileName == null )
				{
					fileName = RuntimeStyleRegistry.STYLESHEET_DARK;
				}
			}
			else
			{
				settingsManager.setSetting( SettingsManager.STYLESHEET, fileName );
			}
			
			 var declEvent:IEventDispatcher = StyleManager.loadStyleDeclarations( fileName );
             declEvent.addEventListener( StyleEvent.COMPLETE, onStyleLoad );
             declEvent.addEventListener( StyleEvent.ERROR, onStyleLoadError );
		}
		
		private function onStyleLoad( evt:StyleEvent ) : void
		{
			var declEvent : IEventDispatcher = evt.target as IEventDispatcher;
			declEvent.removeEventListener( StyleEvent.COMPLETE, onStyleLoad );
            declEvent.removeEventListener( StyleEvent.ERROR, onStyleLoadError );
			notifyComplete();
			
		}
		
		private function onStyleLoadError( evt:StyleEvent ) : void
		{
			var declEvent : IEventDispatcher = evt.target as IEventDispatcher;
			declEvent.removeEventListener( StyleEvent.COMPLETE, onStyleLoad );
            declEvent.removeEventListener( StyleEvent.ERROR, onStyleLoadError );
            
			notifyError( "Error loading stylesheet: " + evt );	
		}
	}
}