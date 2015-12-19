package com.adobe.empdir.commands.ui
{
	import com.adobe.empdir.ApplicationModel;
	import com.adobe.empdir.MainContentUIModel;
	import com.adobe.empdir.commands.Command;
	
	/**
	 * This command removes any selected object and returns to the base state. 
	 */ 
	public class ClosePanelCommand extends Command
	{
	
		/**
		 * Constructor
		 */ 
		public function ClosePanelCommand() 
		{
		}
		
		override public function execute() : void
		{
			//logDebug("execute()");
			var uiModel : MainContentUIModel = MainContentUIModel.getInstance();
			var appModel : ApplicationModel = ApplicationModel.getInstance();
		
			uiModel.currentState = MainContentUIModel.DEFAULT_VIEW;
			appModel.selectedItem = null;
			
			//WindowBoundsManager.getInstance().resetOrigPosition();
			
			var cmd : RecordHistoryCommand = new RecordHistoryCommand();
			cmd.execute();
			
			notifyComplete();
		}
	}
}