package com.adobe.empdir.commands.ui
{
	import com.adobe.empdir.ApplicationModel;
	import com.adobe.empdir.MainContentUIModel;
	import com.adobe.empdir.commands.Command;
	
	/**
	 * This is a UI command to show the settings panel.
	 */ 
	public class ShowSettingsPanelCommand extends Command
	{
		/**
		 * Constructor
		 */ 
		public function ShowSettingsPanelCommand( ) 
		{
		}
		
		override public function execute() : void
		{			
			var uiModel : MainContentUIModel = MainContentUIModel.getInstance();
			var appModel : ApplicationModel = ApplicationModel.getInstance();
			
			if ( uiModel.currentState != MainContentUIModel.SETTINGS_VIEW )
			{
				uiModel.currentState = MainContentUIModel.SETTINGS_VIEW;
				appModel.selectedItem = null;
	
				var cmd : RecordHistoryCommand = new RecordHistoryCommand();
				cmd.execute();
			}
			
			notifyComplete();
		}
	}
}