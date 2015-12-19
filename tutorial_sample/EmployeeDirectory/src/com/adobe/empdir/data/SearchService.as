package com.adobe.empdir.data
{
	import com.adobe.empdir.ApplicationModel;
	import com.adobe.empdir.managers.DatabaseConnectionManager;
	import com.adobe.empdir.model.ConferenceRoom;
	import com.adobe.empdir.model.Employee;
	import com.adobe.empdir.util.LogUtil;
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.Responder;
	
	import mx.logging.ILogger;
	import mx.utils.StringUtil;

	/**
	 * This singleton class is responsible for searching the database. Its implemented as a singleton
	 * service instead of a command to keep a persistent SQLStatement and case for pending operations.
	 * 
	 * @author Daniel Wabyick.
	 */ 
	public class SearchService extends EventDispatcher
	{
		
		private static var instance : SearchService;
		
		private var conn : SQLConnection;
		
		private var empStmt1 : SQLStatement;
		private var empStmt2 : SQLStatement;
		private var confStmt : SQLStatement;
		
		
		private var inited : Boolean;
		private var model : ApplicationModel;
		
		
		private var pendingSearchTerm : String;
		private var searchTerm : String;
		private var searchResults : Array;
		
		protected var logger : ILogger;
		
		/**
		 * Private constructor. Use getInstance() instead.
		 */
		public function SearchService()
		{
			if ( instance != null )
			{
				throw new Error("Private constructor. Use getIntance() instead.");	
			}
			model = ApplicationModel.getInstance();	
			logger = LogUtil.getLogger( this );
			
			conn = DatabaseConnectionManager.getInstance().getConnection();
			
			empStmt1 = new SQLStatement();
			empStmt1.sqlConnection = conn;
			empStmt1.itemClass = Employee;
			empStmt1.text = "SELECT * from employee where firstName like :searchTerm1 or " + 
 							"lastName like :searchTerm2 or id like :searchTerm3 ORDER BY firstName, lastName;"
 			
 			empStmt2 = new SQLStatement();
 			empStmt2.sqlConnection = conn;
 			empStmt2.itemClass = Employee;
 			empStmt2.text = "SELECT * from employee where firstName like :searchTerm1 and " + 
 							"lastName like :searchTerm2 OR firstName like :searchTerm3 " +  
 							"OR lastName like :searchTerm3 ORDER BY firstName, lastName;";
 			
 							
 			confStmt = new SQLStatement();
 			confStmt.sqlConnection = conn;
 			confStmt.itemClass = ConferenceRoom;
 			confStmt.text = "SELECT * FROM conferenceroom WHERE extendedName like :searchTerm1 order by extendedName";
		}
		
		/**
		 * Get an instance of the DataManager.
		 */ 
		public static function getInstance() : SearchService
		{
			if ( instance == null )
			{
				instance = new SearchService();
			}
			return instance;
		}
	
 		
 		/**
 		 * Search for employees and conference rooms based on the current terms. 
 		 * 
 		 */ 
 		public function search( term:String ) : void
 		{
 			if ( searchTerm != null )
 			{
 				pendingSearchTerm = term;
 				return;
 			}
 			
 			searchTerm = term;
 			
 			logDebug("search: [" + term + "]" );
 			if ( ! conn.connected )
 			{
 				// ignore if we aren't yet connected. not likely to ever happen
 			}
 			else
 			{
 				
 				if ( term.length == 0 )
 				{
 					model.updateSearchResults( null );	
		          	return;
 				}
 				
	 			var parts : Array = StringUtil.trim( searchTerm ).split(' ');
	 			
	 			
 				searchResults = null;
 				
 				if ( parts.length == 1 )
 				{
 					empStmt1.parameters[":searchTerm1"] = 
 					empStmt1.parameters[":searchTerm2"] = 
 					empStmt1.parameters[":searchTerm3"] = parts[0] + "%";
 					
 					empStmt1.execute( 100, new Responder( onEmpSearchResult, onEmpSearchResultError ) );

 				}
 				else if ( parts.length > 1 )
 				{
 					empStmt2.parameters[":searchTerm1"] = parts.shift() + "%";
 					empStmt2.parameters[":searchTerm2"] = parts.join(" ") + "%";
 					empStmt2.parameters[":searchTerm3"] = term;
 					
 					empStmt2.execute( 100, new Responder( onEmpSearchResult, onEmpSearchResultError ) );
 				}			
 			}
 		}
 		
		private function onEmpSearchResult( res:SQLResult ) : void
		{
			if ( res != null && res.data != null )
 			{
 				searchResults = res.data.slice();
 			}
 			
 			// cancel the pending statement
 			if ( empStmt1.executing )
 			{
 				empStmt1.cancel();
 			}
 			
 			if ( empStmt2.executing ) 
 			{
 				empStmt2.cancel();
 			}
 			
 			executeConferenceRoomSearch();
	 		
		 }
		 
		
		private function onEmpSearchResultError( err:SQLError ) : void
		{
			logDebug( "onEmpSearchResultError: " + err );
			
 			executeConferenceRoomSearch();
		}
		
		private function executeConferenceRoomSearch( evt:Event = null ) : void
		{
			confStmt.parameters[":searchTerm1"] = '%' + searchTerm + '%';
			confStmt.execute( 100, new Responder( onConfRoomSearchResult, onConfRoomSearchResultError ) );
		}
		
		private function onConfRoomSearchResult( res:SQLResult = null ) : void
		{
			logDebug("onConfRoomSearchResult()");
			
			if ( ! res.data )
			{
				// don't do anything
			}
			else
			{
				if ( searchResults == null )
					searchResults = res.data.slice();
				else
				{
					for each ( var room : ConferenceRoom in res.data )
					{ 
						searchResults.push( room );
					}
				}
			}
			
			
			// cancel the pending statement
			if ( confStmt.executing )
			{
				confStmt.cancel();
			}
			updateModelResults();
		}
		
		private function onConfRoomSearchResultError ( err:SQLError ) : void
		{
			logDebug("onConfRoomSearchResultError(): " + err);
			
			model.updateSearchResults( searchResults );
			searchResults = null;
		}
		
		/**
		 * Function called when our conference room search is 'cancelled' via an error inv
		 */ 
		private function onConfSearchCancel( err:SQLError ) : void
		{
			updateModelResults();
		}
		
		private function updateModelResults() : void
		{	
			model.updateSearchResults( searchResults );
			searchTerm = null;
			searchResults = null;
			if ( pendingSearchTerm )
			{
				var tempTerm : String = pendingSearchTerm;
				pendingSearchTerm = null;
				search( tempTerm );		
			}
		}
		
		private function logDebug( msg:String ) : void
		{
			logger.debug( ": " + msg );	
		}
		
	}
}