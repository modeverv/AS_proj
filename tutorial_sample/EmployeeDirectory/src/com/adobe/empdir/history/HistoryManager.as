package com.adobe.empdir.history
{
	import flash.events.EventDispatcher;
	import flash.data.SQLConnection;
	import flash.filesystem.File;
	import flash.events.SQLEvent;
	import flash.events.SQLErrorEvent;
	import flash.events.Event;
	import mx.logging.ILogger;
	import com.adobe.empdir.util.LogUtil;

	/**
	 * This singleton manages application history.
	 */ 
	public class HistoryManager extends EventDispatcher
	{
		private static const MAX_HISTORY : int = 100;
		
		private static var instance : HistoryManager;
		
		private var states : Array;
		private var stateIndex : int;
		private var logger : ILogger;
		/**
		 * Private constructor. Use getInstance() instead.
		 */
		public function HistoryManager()
		{
			if ( instance != null )
			{
				throw new Error("Private constructor. Use getIntance() instead.");	
			}
			
			states = new Array();
			stateIndex = -1
			logger = LogUtil.getLogger( this );
		}
		
		
		/**
		 * Get an instance of the DataManager.
		 */ 
		public static function getInstance() : HistoryManager
		{
			if ( instance == null )
			{
				instance = new HistoryManager();
			}
			return instance;
		}
		
		/**
		 * @return True if there is a previous state; false otherwise.
		 */ 
		[Bindable("historyStateChange")]
		public function get hasPreviousState() : Boolean
		{
			return stateIndex >= 1;
		}
		
		
		/**
		 * @return True if there is s forward state; false otherwise.
		 */ 
		[Bindable("historyStateChange")]
		public function get hasNextState() : Boolean
		{
			return stateIndex < states.length - 1;
		}
		
		
		/**
		 * Add a state to the history stack. If we are in a previous state in the 
		 * history stack. We will 
		 */ 
		public function addState( state:IHistoryState ) : void
		{
			logDebug("addState: " + state );
			
			// remove any forward states
			states = states.slice( 0, stateIndex + 1 );
			
			states.push( state );
			
			// limit history to MAX_HISTORY items
			var min : uint = Math.max( states.length - MAX_HISTORY, 0 );
			states = states.slice( min, states.length );
			
			stateIndex = states.length - 1;
			notifyStateChange();
		}
		
		/**
		 * Goto the previous history state.
		 */ 
		public function gotoPreviousState() : void
		{
			logDebug("gotoPreviousState: " + stateIndex + " : "  + states.length);
			if ( stateIndex >= 1 )
			{
				stateIndex--;
				restoreState();
				notifyStateChange();
			}		
		}
		
		/**
		 * Goto the next history state.
		 */ 
		public function gotoNextState() : void
		{
			logDebug("gotoNextState: " + stateIndex + " : "  + states.length);
			if ( stateIndex < states.length - 1 )
			{
				stateIndex++;
				restoreState();
				notifyStateChange();	
			}
		}
		
		/**
		 * Clear all history from the history manager.
		 */ 
		public function clear() : void
		{
			states = new Array();
			stateIndex = -1;
			notifyStateChange();
		}
		
		private function restoreState() : void
		{
			logDebug( "restoreState: " + states[ stateIndex ] );
			var state : IHistoryState = states[ stateIndex ];
			state.restore();	
		}
		
		private function notifyStateChange() : void
		{
			dispatchEvent( new Event("historyStateChange" ) );
		}
		
		private function logDebug( msg:String ) : void
		{
			logger.debug( " - " + msg );
		}
	}
}