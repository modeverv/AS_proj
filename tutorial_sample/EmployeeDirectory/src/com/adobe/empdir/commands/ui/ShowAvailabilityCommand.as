package com.adobe.empdir.commands.ui
{
	import com.adobe.empdir.ApplicationModel;
	import com.adobe.empdir.DetailContentUIModel;
	import com.adobe.empdir.commands.Command;

	
	/**
	 * This commands showing the availability info in the detail panel.
	 */ 
	public class ShowAvailabilityCommand extends Command
	{

		/**
		 * Constructor
		 */ 
		public function ShowAvailabilityCommand() 
		{

		}
		
		override public function execute() : void
		{
			var uiModel : DetailContentUIModel = DetailContentUIModel.getInstance();
			var appModel : ApplicationModel = ApplicationModel.getInstance();
		
			uiModel.currentState = DetailContentUIModel.AVAILABILITY_VIEW;
			notifyComplete();
		}
	}
}