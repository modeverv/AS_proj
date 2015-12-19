/***********************************************************
 * DataAccess Class
 * This is a simple data access layer intended to seperate
 * data calls from component views by putting all data access
 * in a reusable class.
 * 
 * Brandon Ellis - 2007
 * brandonthedeveloper@gmail.com
 * http://www.brandonellis.org	
 * 
 * Usage
 * Import the class to your mxml file.
 * 		import org.brandonellis.DataAccess;
 *
 * Create an 'bindable' instance of the DataAccess Class in the mxml file;
 *		[Bindable]
		private var da:DataAccess;
 * 
 * Pass in the file path to the database
 *		da = new DataAccess("app-resource:/friends.db");  // note from Andrew Muller - app-resource is now app-storage
 * 
 * Open a connection to the database and pass in the initial sql statement to run
 * 		da.openConnection("select * from friends") - this is optional;
			
 * Set the receiving data component's dataProvider to be the DataAccess.dbResult property.
 * dataProvider="{da.dbResult}"
 * 
 * For more information on creating a local instance of the DataAccess Class take a look at the 'main.mxml' file
 * 
 * Modified by Andrew Muller to dispatch a custom event
 * andrew.muller@gmail.com
***********************************************************/
package org.brandonellis
{
// imported classes
import flash.data.SQLConnection;
import flash.data.SQLResult;
import flash.data.SQLStatement;
import flash.errors.SQLError;
import flash.events.SQLErrorEvent;
import flash.events.SQLEvent;
import flash.filesystem.File;
import mx.collections.ArrayCollection;
import mx.controls.Alert;

import com.flickrfloater.events.SqlDbEvent;

public class DataAccess
{
	// private variables for the class
	private var _dbFilePath:String;
	private var _result:ArrayCollection = new ArrayCollection();
	private var _sql2:String="";
	private var db:File;
	private var sqlConnection:SQLConnection;
	private var sqlStatement:SQLStatement;	

	// this ArrayCollection is used as the data provider 
	// dbResult getter
	[Bindable]
	public function get dbResult():ArrayCollection {
	    return _result;
	}

	// dbResult setter
	public function set dbResult(value:ArrayCollection):void {
	    _result = value;
	    
	    // Modification by Andrew Muller to dispatch a custom event
		var e:SqlDbEvent = new SqlDbEvent(SqlDbEvent.SQL_RESPONSE);
		dispatchEvent(e);	    
	    
	}
	
	// constructor
	public function DataAccess(dbFilePath:String) {
		_dbFilePath = dbFilePath;
		//openConnection();
	}
	
/***************** Open Connection *************************
* Create a sqlConnection and open the database
***********************************************************/
	public function openConnection(sql:String=""):void {
		_sql2 = sql;
		// the database
	    db = new File(_dbFilePath);
	    // instance of the SQLConnection
	    sqlConnection = new SQLConnection();
	    sqlConnection.addEventListener(SQLEvent.OPEN, sqlConnectionOpenHandler);
	    sqlConnection.addEventListener(SQLErrorEvent.ERROR, sqlConnectionErrorHandler);
	    // open the database
	    sqlConnection.open(db);		
	}
	
	// when the connection is opened
	private function sqlConnectionOpenHandler(evt:SQLEvent):void {
	    if (evt.type == "open" && _sql2 != "") {
	        // the initial database view to show
	        executeSQL(_sql2, selectResultHandler);
	    }
	}
	
	// when the connection has an error
	private function sqlConnectionErrorHandler(evt:SQLErrorEvent):void {
		Alert.show("You have problems... " +  evt.error.message);
	}	
	
/***************** Select **********************************
 * the method 'executeSQL' is used by the Select, Insert, Update and Delete methods
 * as a generic/reusable function to connect to the database and execute the passed in sql query.
 * the handler to fire 'onResult' is passed in as the second argument
***********************************************************/
	public function DataAccessSelect(sql:String):void {
		executeSQL(sql, selectResultHandler);
	}
	
	private function selectResultHandler(evt:SQLEvent):void {
		var result:SQLResult = sqlStatement.getResult();	
		if (result != null) {	
			dbResult = new ArrayCollection(result.data);
		}
		// reset the _sql2 variable to an empty string
		if (_sql2 != "") _sql2 = "";
	}
	
/***************** Insert **********************************
***********************************************************/
	public function DataAccessInsert(sql:String, sql2:String=""):void {
		// give the variable _sql2 its value
	    this._sql2 = sql2;
		executeSQL(sql, insertResultHandler);
	}
	
	private function insertResultHandler(evt:SQLEvent):void {
		// if a change has been made to the database and _sql2 is not an empty string
	    if (sqlConnection.totalChanges >= 1 && _sql2 != "") {
	        DataAccessSelect(_sql2);
	    }
	}
	
/***************** Update **********************************
***********************************************************/
	public function DataAccessUpdate(sql:String, sql2:String=""):void {
		this._sql2 = sql2;
		executeSQL(sql, updateResultHandler);
	}
	
	private function updateResultHandler(evt:SQLEvent):void {
	    if (sqlConnection.totalChanges >= 1 && _sql2 != "") {
	        DataAccessSelect(_sql2);
	    }
	}	
	
/***************** Delete **********************************	
***********************************************************/
	public function DataAccessDelete(sql:String, sql2:String=""):void {
		this._sql2 = sql2;
		executeSQL(sql, deleteResultHandler);
	}
	
	private function deleteResultHandler(evt:SQLEvent):void {
	    if (sqlConnection.totalChanges >= 1 && _sql2 != "") {
	        DataAccessSelect(_sql2);
	    }
	}
			
/***************** Execute **********************************
 * the executeSQL function returns as  String so you could (optionally) read back any 
 * SQLError messages.
***********************************************************/	
	private function executeSQL(sql:String, handler:Function):String {
		var statusMsg:String = "";
		try {
			// eventlistener function to fire off on result
			var _handler:Function = handler;
			sqlStatement = new SQLStatement();
		    sqlStatement.sqlConnection = sqlConnection;	
		    // sql to run
		    sqlStatement.text = sql;
		    sqlStatement.addEventListener(SQLEvent.RESULT, _handler);
		    // execute the sqlStatement
		    sqlStatement.execute();	
		} catch (e:SQLError) {
			// catch any errors
			statusMsg = e.message;
		}	
		
		return statusMsg;	
	}
} // class
} // namespace