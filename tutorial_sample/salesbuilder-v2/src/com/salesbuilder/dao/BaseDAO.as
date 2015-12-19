// Christophe Coenraets, christophe@coenraets.org - http://coenraets.org
package com.salesbuilder.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	public class BaseDAO extends EventDispatcher
	{
		public var sqlConnection:SQLConnection;
		
		public function getList(sql:String, params:Array=null, startRow:int=0, pageSize:int=0):ArrayCollection
		{
            var stmt:SQLStatement = new SQLStatement();
            stmt.sqlConnection = sqlConnection;
			stmt.text = sql;
			
			if (params)
			{
				for (var i:int=0; i<params.length; i++)
				{
					stmt.parameters[i] = params[i];
				}
			}
			
			stmt.execute();

			var result:Array = stmt.getResult().data;

			if (result == null) return new ArrayCollection();
			
			if (pageSize != 0)
			{
				result = result.slice(startRow, pageSize);
			}
			
			var ac:ArrayCollection = new ArrayCollection();
			for (var j:int=0; j<result.length; j++)
			{
				ac.addItem(processRow(result[j]));
			}
			return ac;			
		}
		
		public function getSingleItem(sql:String, id:*):Object
		{
			var list:ArrayCollection = getList(sql, [id]);
			if (list && list.length == 1)
			{
				return list.getItemAt(0);
			}
			else
			{
				return null;
			}
		}

		public function executeUpdate(sql:String, params:Array=null):int
		{
            var stmt:SQLStatement = new SQLStatement();
            stmt.sqlConnection = sqlConnection;
			stmt.text = sql; 
			
			if (params)
			{
				for (var i:int=0; i<params.length; i++)
				{
					stmt.parameters[i] = params[i];
				}
			}
			
			stmt.execute();
			return stmt.getResult().rowsAffected;
		}

		public function createItem(sql:String, params:Array=null):int
		{
            var stmt:SQLStatement = new SQLStatement();
            stmt.sqlConnection = sqlConnection;
			stmt.text = sql; 
			
			if (params)
			{
				for (var i:int=0; i<params.length; i++)
				{
					stmt.parameters[i] = params[i];
				}
			}
			
			stmt.execute();
			return stmt.getResult().lastInsertRowID;
		}
		
		protected function processRow(row:Object):Object
		{
			throw new Error("You need to override processRow() in your concrete DAO");
		}
		
	}
}