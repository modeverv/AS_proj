package com.adobe.empdir.commands.ui
{
	import com.adobe.empdir.ApplicationModel;
	import com.adobe.empdir.MainContentUIModel;
	import com.adobe.empdir.commands.Command;
	import com.adobe.empdir.history.CompositeHistoryState;
	import com.adobe.empdir.history.HistoryManager;
	
	/**
	 * A simple command to record the UI history state.
	 */ 
	public class RecordHistoryCommand extends Command
	{
		override public function execute() : void
		{
			var appModel : ApplicationModel = ApplicationModel.getInstance();
			var uiModel : MainContentUIModel = MainContentUIModel.getInstance();
			//var detailUIModel : DetailContentUIModel = DetailContentUIModel.getInstance();
			
			var states : Array = new Array();
			states.push( appModel.historyState );
			states.push( uiModel.historyState );
			//states.push( detailUIModel.historyState );
			
			var state : CompositeHistoryState = new CompositeHistoryState( states );
			HistoryManager.getInstance().addState( state );	
		}
	}
}