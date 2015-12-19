package com.adobe.empdir.history
{
	/**
	 * This is a composite history state that restores a number of other history states.
	 * 
	 */ 
	public class CompositeHistoryState implements IHistoryState
	{
	
		private var states : Array;
		
		/**
		 * Constructor
		 */ 
		public function CompositeHistoryState( states:Array )
		{
			this.states = states;	
		}	
		
		
		/**
		 * Returns the array of states associated with this state.
		 */ 
		public function get value():Object
		{
			return states;
		}
		
		/**
		 * Restore the state by asynchronously calling all of the subclasses. 
		 */ 
		public function restore() : void
		{
			for each ( var state : IHistoryState in states ) 
			{
				state.restore();
			}	
		}
		
		/**
		 * Return if two states are logically equal. If so, we do not record the difference in states. 
		 */ 
		public function equals( state:IHistoryState ) : Boolean
		{	
			var compositeState : CompositeHistoryState = state as CompositeHistoryState;
			if ( ! compositeState )
			{
				return false;
			}
			var otherStates : Array = compositeState.value as Array; 
			
			for ( var i:int = 0; i < states.length; i++ )
			{
				if ( IHistoryState( states[i] ).value != IHistoryState( otherStates[i] ).value )
					return false;
			}
			return true;
		}
	}
}