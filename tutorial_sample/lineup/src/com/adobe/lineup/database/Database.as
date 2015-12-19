package com.adobe.lineup.database
{
	import com.adobe.exchange.Appointment;
	
	import flash.data.*;
	import flash.filesystem.*;

	public class Database
	{
		private var sql:XML;
		private var conn:SQLConnection;
		
		public function Database(sql:XML)
		{
			this.sql = sql;
		}
		
		public function initialize():void
		{
			this.conn = new SQLConnection();
			var dbFile:File = File.applicationStorageDirectory.resolvePath("lineup.db");
			conn.open(dbFile, SQLMode.CREATE);
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = this.conn;
			stmt.text = sql.appointments.create;
			stmt.execute();
			stmt.text = sql.alerts.create;
			stmt.execute();
		}

		public function shutdown():void
		{
			if (this.conn.connected)
			{
				this.conn.close();
			}
		}

		public function getAppointments(startDate:Date, endDate:Date):Array
		{
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = this.conn;
			stmt.text = sql.appointments.selectByDates;
			stmt.parameters[":start_date"] = startDate;
			stmt.parameters[":end_date"] = endDate;
			stmt.execute();
			var result:SQLResult = stmt.getResult();
			return result.data;
		}

		public function getReminders():Array
		{
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = this.conn;
			stmt.text = sql.appointments.selectForReminders;
			stmt.parameters[":current_date"] = new Date();
			stmt.execute();
			var result:SQLResult = stmt.getResult();
			return result.data;
		}

		public function deleteAppointments(startDate:Date, endDate:Date):void
		{
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = this.conn;
			stmt.text = sql.appointments.deleteByDates;
			stmt.parameters[":start_date"] = startDate;
			stmt.parameters[":end_date"] = endDate;
			stmt.execute();
		}

		public function insertAppointments(appts:Array):void
		{
			var stmt:SQLStatement = new SQLStatement();
			this.conn.begin();
			stmt.sqlConnection = this.conn;
			stmt.text = sql.appointments.insert;
			for each (var appt:Appointment in appts)
			{
				stmt.clearParameters();
				stmt.parameters[":uid"] = appt.uid;
				stmt.parameters[":url"] = appt.url;
				stmt.parameters[":start_date"] = appt.startDate;
				stmt.parameters[":end_date"] = appt.endDate;
				stmt.parameters[":subject"] = appt.subject;
				stmt.parameters[":location"] = appt.location;
				stmt.parameters[":last_modified"] = appt.lastModified;
				stmt.parameters[":created"] = appt.created;
				stmt.parameters[":all_day_event"] = appt.allDay;
				stmt.parameters[":text_description"] = appt.textDescription;
				stmt.parameters[":html_description"] = appt.htmlDescription;
				stmt.parameters[":reminder_offset"] = appt.reminderOffset;
				stmt.execute();
			}
			this.conn.commit();
		}

		public function insertAlert(startDate:Date, endDate:Date, subject:String):void
		{
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = this.conn;
			stmt.text = sql.alerts.insert;
			stmt.parameters[":start_date"] = startDate;
			stmt.parameters[":end_date"] = endDate;
			stmt.parameters[":subject"] = subject;
			stmt.execute();
		}

		public function countAlerts(startDate:Date, endDate:Date, subject:String):uint
		{
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = this.conn;
			stmt.text = sql.alerts.count;
			stmt.parameters[":start_date"] = startDate;
			stmt.parameters[":end_date"] = endDate;
			stmt.parameters[":subject"] = subject;
			stmt.execute();
			return stmt.getResult().data[0].cnt as uint;
		}

		public function removeAlerts():void
		{
			if (!this.conn.connected) return;
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = this.conn;
			stmt.text = sql.alerts.deleteAll;
			stmt.execute();
		}

	}
}
