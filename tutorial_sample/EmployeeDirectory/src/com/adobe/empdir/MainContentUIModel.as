package com.adobe.empdir
{
	import com.adobe.empdir.history.HistoryManager;
	import com.adobe.empdir.history.HistoryState;
	import com.adobe.empdir.history.IHistoryState;
	import com.adobe.empdir.history.IHistoryStateClient;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	[Event(name="change", type="mx.events.Event")]
		
	/**
	 * Singleton class maintaining the UI state of the MainContentScreen container.
	 */ 
	public class MainContentUIModel extends EventDispatcher implements IHistoryStateClient
	{
		/** The default (closed) view state. **/
		public static const DEFAULT_VIEW : String = "";
		
		/** The help view state. **/
		public static const INFO_VIEW : String = "infoView";
		
		/** The employee view state. **/
		public static const EMPLOYEE_VIEW : String = "employeeView";
		
		/** The department view state. **/
		public static const DEPARTMENT_VIEW : String = "departmentView";
		
		/** The conference room view state. **/
		public static const CONFERENCEROOM_VIEW : String = "conferenceRoomView";
		
		/** The settings panel. **/
		public static const SETTINGS_VIEW : String = "settingsView";
		
		
		private var _currentState : String; 
		
		private static var instance : MainContentUIModel;
		private var historyManager : HistoryManager;
		
		
		/**
		 * Private constructor. Use getInstance() instead.
		 */
		public function MainContentUIModel()
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
		public static function getInstance() : MainContentUIModel
		{
			if ( instance == null )
			{
				instance = new MainContentUIModel();
			}
			return instance;
		}
		
		[Bindable(event="change")]
		
		/**
		 * Get the current state of the ui model.
		 */ 
		public function get currentState() : String
		{
			return _currentState;
		}
		
		public function set currentState( state:String ) : void
		{
			_currentState = state;	
			dispatchEvent( new Event( Event.CHANGE ) );
		}
		
		/**
		 * Get the current state of this object wrapped in a HistoryState memento.
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