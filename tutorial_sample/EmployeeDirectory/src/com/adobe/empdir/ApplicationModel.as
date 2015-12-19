package com.adobe.empdir
{
	import com.adobe.empdir.events.SelectedItemChangeEvent;
	import com.adobe.empdir.history.HistoryState;
	import com.adobe.empdir.history.IHistoryState;
	import com.adobe.empdir.history.IHistoryStateClient;
	import com.adobe.empdir.model.IModelObject;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	
	/** An event indicating that the selected employee has been changed. **/
	[Event(name="change", type="com.adobe.empdir.events.SelectedItemChange")]
	
	/**
	 * Singleton class holding application-wide result and selection data.
	 */ 
	public class ApplicationModel extends EventDispatcher implements IHistoryStateClient
	{
		
		/** The results from SearchService. **/ 
		[Bindable]
		public var searchResults : ArrayCollection = new ArrayCollection();
		
		private static var instance : ApplicationModel;
		
		
		private var _selectedItem : IModelObject;
		
		
		/**
		 * Private constructor. Use getInstance() instead.
		 */
		public function ApplicationModel()
		{
			if ( instance != null )
			{
				throw new Error("Private constructor. Use getIntance() instead.");	
			}
		}
		
		/**
		 * Get an instance of the DataManager.
		 */ 
		public static function getInstance() : ApplicationModel
		{
			if ( instance == null )
			{
				instance = new ApplicationModel();
			}
			return instance;
		}
		
		/**
		 * New search results. 
		 */ 
		public function updateSearchResults( newResults:Array ) : void
		{
			searchResults.disableAutoUpdate();
			searchResults.removeAll();
			if ( newResults != null)
            {
            	searchResults.source = newResults;
            }
            else
            {
            	searchResults.removeAll();
            }
            searchResults.enableAutoUpdate();
		}
		
		/**
		 * Get the selected item (e.g. Employee, Department) in the model.
		 */ 
		[Bindable("selectedItemChange")]
		public function get selectedItem() : IModelObject
		{
			return _selectedItem;
		}
		
		/**
		 * Set the selected item (e.g. Employeee, Department) in the model.
		 */ 
		public function set selectedItem( item:IModelObject ) : void
		{
			_selectedItem = item;
			dispatchEvent( new SelectedItemChangeEvent( item ) );
		}
		
		
		/**
		 * Get the current history state of this object.
		 */ 
		public function get historyState( ) : IHistoryState
		{
			return new HistoryState( this, selectedItem );
		}
		

		/**
		 * Set the history state of this object.
		 */ 
		public function set historyState( state:IHistoryState ) : void
		{
			selectedItem = state.value as IModelObject;
		}
	}
}