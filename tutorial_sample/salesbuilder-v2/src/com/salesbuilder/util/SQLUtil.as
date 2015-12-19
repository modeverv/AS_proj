package com.salesbuilder.util
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.data.SQLTransactionLockType;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	public class SQLUtil
	{
		public function executeBatch(file:File, connection:SQLConnection):void
		{
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			var xml:XML = XML(stream.readUTFBytes(stream.bytesAvailable));
			stream.close();
			connection.begin(SQLTransactionLockType.IMMEDIATE);
			for each (var statement:XML in xml.statement)
			{
	            var stmt:SQLStatement = new SQLStatement();
	            stmt.sqlConnection = connection;
				stmt.text = statement;
				stmt.execute();			
			}
			connection.commit();
		}
	}
}