package com.adobe.empdir
{

	/**
	 * This is a very simple singleton class functioning as a bindable data model for the 
	 * ApplicationUI.mxml class.
	 * 
	 */ 
	public class ApplicationUIModel 
	{
		
		
		
		/**
		 * Definies whether or not the UI is resizing. 
		 * 
		 * This is used to ensure that buttons can't execute panels opening/closing mid-transition.
		 */ 
		[Bindable]
		public var isResizing : Boolean;
	
		private static var instance : ApplicationUIModel;
		
		
		/**
		 * Private constructor. Use getInstance() instead.
		 */
		public function ApplicationUIModel()
		{
			if ( instance != null )
			{
				throw new Error("Private constructor. Use getIntance() instead.");	
			}
		}
		
		/**
		 * Get an instance of the DataManager.
		 */ 
		public static function getInstance() : ApplicationUIModel
		{
			if ( instance == null )
			{
				instance = new ApplicationUIModel();
			}
			return instance;
		}
		
		
		
	}
}