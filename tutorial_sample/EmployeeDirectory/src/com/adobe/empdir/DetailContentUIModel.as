package com.adobe.empdir
{
	import com.adobe.empdir.history.HistoryManager;
	import com.adobe.empdir.history.HistoryState;
	import com.adobe.empdir.history.IHistoryState;
	import com.adobe.empdir.history.IHistoryStateClient;
	
	import flash.events.EventDispatcher;
	
	/**
	 * Singleton class maintaining the UI state of the current application 
	 */ 
	public class DetailContentUIModel extends EventDispatcher implements IHistoryStateClient
	{
		/** The default (closed) view state. **/
		public static const DEFAULT_VIEW : String = "";
		

		/** The direct report view state. **/
		public static const DIRECTREPORT_VIEW : String = "directReportView";
		
		
		/** The availability panel view. **/
		public static const AVAILABILITY_VIEW : String = "availabilityView";
		
		
		[Bindable]
		public var currentState : String; 
		
		private static var instance : DetailContentUIModel;
		
		private var historyManager : HistoryManager;
		
		
		/**
		 * Private constructor. Use getInstance() instead.
		 */
		public function DetailContentUIModel()
		{
			if ( instance != null )
			{
				throw new Error("Private constructor. Use getIntance() instead.");	
			}
			historyManager = HistoryManager.getInstance();
			currentState = DEFAULT_VIEW;
		}
		
		/**
		 * Get an instance of the DataManager.
		 */ 
		public static function getInstance() : DetailContentUIModel
		{
			if ( instance == null )
			{
				instance = new DetailContentUIModel();
			}
			return instance;
		}
		
		/**
		 * Get the current history state of this object.
		 */ 
		public function get historyState( ) : IHistoryState
		{
			return new HistoryState( this, currentState );
		}
		

		/**
		 * Set the history state of this object.
		 */ 
		public function set historyState( state:IHistoryState ) : void
		{
			currentState = state.value as String;
		}
		
	}
}