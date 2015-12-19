package
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	
	import ilog.utils.GregorianCalendar;
	import ilog.utils.TimeUnit;
	
	import mx.collections.ArrayCollection;
	
	public class CalendarItemDAO
	{
		private var sqlConnection:SQLConnection;
		
		private var stmtFindAll:SQLStatement;
		private var stmtInsert:SQLStatement;
		private var stmtUpdate:SQLStatement;
		private var stmtUpdatePicture:SQLStatement;
		private var stmtDelete:SQLStatement;
		
		public function CalendarItemDAO(sqlConnection:SQLConnection)
		{
			this.sqlConnection = sqlConnection;
			
			// Prepare the findAll statement
			stmtFindAll = new SQLStatement();
			stmtFindAll.sqlConnection = sqlConnection;
			stmtFindAll.text = "SELECT * FROM calendaritem";

			// Prepare the insert statement
			stmtInsert = new SQLStatement();
			stmtInsert.sqlConnection = sqlConnection;
			stmtInsert.text = 
				"INSERT INTO calendaritem (start_time, end_time, summary, description) " +
					"VALUES (:startTime, :endTime, :summary, :description)"; 
			
			// Prepare the update statement
			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
			stmtUpdate.text = 
				"UPDATE calendaritem set " + 
					"start_time=:startTime, " + 
					"end_time=:endTime, " +
					"summary=:summary, " +
					"description=:description " +
					"WHERE id=:id";

			// Prepare the delete statement
			stmtDelete = new SQLStatement();
			stmtDelete.sqlConnection = sqlConnection;
			stmtDelete.text = "DELETE FROM calendaritem WHERE id=:id";
		}
		
		public function findAll():ArrayCollection
		{
			stmtFindAll.execute();
			var rows:Array = stmtFindAll.getResult().data;
			var items:ArrayCollection = new ArrayCollection();
			if (rows != null) 
			{
				for (var i:int=0; i<rows.length; i++)
				{
					items.addItem(processRow(rows[i]));
				}
			}
			return items;
		}
		
		public function insert(item:CalendarItemModel):void
		{
			stmtInsert.parameters[":startTime"] = item.startTime; 
			stmtInsert.parameters[":endTime"] = item.endTime; 
			stmtInsert.parameters[":summary"] = item.summary; 
			stmtInsert.parameters[":description"] = item.description; 
			stmtInsert.execute();
			item.id = stmtInsert.getResult().lastInsertRowID;
		}
		
		public function update(item:CalendarItemModel):void
		{
			stmtUpdate.parameters[":startTime"] = item.startTime; 
			stmtUpdate.parameters[":endTime"] = item.endTime; 
			stmtUpdate.parameters[":summary"] = item.summary; 
			stmtUpdate.parameters[":description"] = item.description; 
			stmtUpdate.parameters[":id"] = item.id; 
			stmtUpdate.execute();
		}

		public function deleteItem(item:CalendarItemModel):void
		{
			stmtDelete.parameters[":id"] = item.id; 
			stmtDelete.execute();
		}
		
		public function createTable():void
		{
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = sqlConnection;
			stmt.text = "CREATE TABLE calendaritem (id INTEGER PRIMARY KEY AUTOINCREMENT, start_time DATE, end_time DATE, summary TEXT, description TEXT)";
			stmt.execute();
			
			var item:CalendarItemModel = new CalendarItemModel();
			item.startTime = new Date();
			var gc:GregorianCalendar = new GregorianCalendar();
			item.startTime = gc.round(item.startTime, TimeUnit.HOUR, 1);
			item.endTime = gc.addUnits(item.startTime, TimeUnit.MINUTE, 60);
			item.summary = "Explore Quicklook";
			item.description = 
				"<font size='12'><p>Try the following actions:</p>" +
				"<ol>" +
				"<li><font color='#0000CC'><b><i>To add an event:</i></b></font> select the time with your mouse directly in the calendar and press Enter or start typing the event summary</li>" +
				"<li><font color='#0000CC'><b><i>To move an event:</i></b></font> click and drag the event to the desired time.</li>" +
				"<li><font color='#0000CC'><b><i>To resize an event:</i></b></font> click the event top or bottom border and drag it to adjust its duration.</li>" +
				"<li><font color='#0000CC'><b><i>To delete an event:</i></b></font> select it and press the delete key.</li>" +
				"</ol>" +
				"<p>The properties of the selected event are also editable in the right pane.</p></font>";
			insert(item);

			
			item.startTime = gc.addUnits(item.startTime, TimeUnit.DAY, 1);
			item.startTime.hours = 9;
			item.startTime.minutes =0;
			item.endTime = gc.addUnits(item.startTime, TimeUnit.MINUTE, 120);
			item.summary = "Explore Quicklook more";
			insert(item);

			item.startTime = gc.addUnits(item.startTime, TimeUnit.HOUR, 3);
			item.endTime = gc.addUnits(item.startTime, TimeUnit.MINUTE, 60);
			item.summary = "Visit Christophe's Blog";
			item.description = "Check out other Flex samples on Christophe's blog at http://coenraets.org";
			insert(item);

			item.startTime = gc.addUnits(item.startTime, TimeUnit.HOUR, 2);
			item.endTime = gc.addUnits(item.startTime, TimeUnit.MINUTE, 120);
			item.summary = "Visit ILog Website";
			item.description = "Check out other ILog components for Flex at http://labs.ilog.fr/ILOG_Elixir/Elixir20BetaProgram";
			insert(item);
			
		}

		private function processRow(row:Object):CalendarItemModel
		{
			var item:CalendarItemModel = new CalendarItemModel();
			item.id = row.id;
			item.startTime = row.start_time;
			item.endTime = row.end_time;
			item.summary = row.summary;
			item.description = row.description;
			return item;
		} 

	}
}