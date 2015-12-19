package com.adobe.empdir.commands.ui
{
	import com.adobe.empdir.ApplicationModel;
	import com.adobe.empdir.DetailContentUIModel;
	import com.adobe.empdir.commands.Command;
	/**
	 * This command selects a given object in the UI, managing UI and model state.
	 */ 
	public class ShowDirectReportsCommand extends Command
	{

		/**
		 * Constructor
		 */ 
		public function ShowDirectReportsCommand() 
		{

		}
		
		override public function execute() : void
		{
			var uiModel : DetailContentUIModel = DetailContentUIModel.getInstance();
			var appModel : ApplicationModel = ApplicationModel.getInstance();
		
			uiModel.currentState = DetailContentUIModel.DIRECTREPORT_VIEW;
			notifyComplete();
		}
	}
}