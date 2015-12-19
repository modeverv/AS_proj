package com.salesbuilder.dao
{
	import com.salesbuilder.context.Context;
	import com.salesbuilder.model.CalendarItemModel;
	
	import mx.collections.ArrayCollection;
	
	public class CalendarItemDAO extends BaseDAO implements ICalendarItemDAO
	{
		public function CalendarItemDAO()
		{
			sqlConnection = Context.getAttribute("sqlConnection"); 	
		}

		public function getItem(id:int):CalendarItemModel
		{
			return getSingleItem("SELECT * FROM CALENDARITEM WHERE ID=?", id) as CalendarItemModel;
		}

		public function findAll():ArrayCollection
		{
			return getList("SELECT * FROM CALENDARITEM WHERE OFFLINE_OPERATION <> 'DELETE'");
		}
		
		public function getChanges():ArrayCollection
		{
			return getList("SELECT * FROM CALENDARITEM WHERE OFFLINE_OPERATION = 'INSERT' OR OFFLINE_OPERATION = 'UPDATE'");
		}

		public function save(calendarItem:CalendarItemModel):void
		{
			calendarItem.lastUpdated = new Date().time;
			if (calendarItem.id)
			{
				 // Check if we aren't updating a calendar item that has been created offline
				 // and not yet sent to the server
				if (calendarItem.offlineOperation != "INSERT")
				{
					calendarItem.offlineOperation = "UPDATE";
				}
				update(calendarItem);
			}
			else
			{
				calendarItem.offlineOperation = "INSERT";
				create(calendarItem);
			}
		}

		public function update(item:CalendarItemModel):void
		{
			executeUpdate("UPDATE CALENDARITEM SET START_TIME=?, END_TIME=?, SUMMARY=?, DESCRIPTION=?, LAST_UPDATED=?, OFFLINE_OPERATION=? WHERE id=?",
				[item.startTime, item.endTime, item.summary, item.description, item.lastUpdated, item.offlineOperation, item.id]);
		}

		public function remove(item:CalendarItemModel):void
		{
			item.offlineOperation = "DELETE";
			update(item);
		}
		
		public function create(item:CalendarItemModel):void
		{
			var id:int = createItem(
				"INSERT INTO CALENDARITEM (ID, START_TIME, END_TIME, SUMMARY, DESCRIPTION, LAST_UPDATED, OFFLINE_OPERATION) " +
					"VALUES (?,?,?,?,?,?,?)",
					[	item.id > 0 ? item.id : null,
						item.startTime, 
						item.endTime, 
						item.summary, 
						item.description, 
						item.lastUpdated, 
						item.offlineOperation]);
      		item.id = id;
		}

		public function unflagChanges():void
		{
            executeUpdate("DELETE FROM CALENDARITEM WHERE OFFLINE_OPERATION='DELETE'");
            executeUpdate("UPDATE CALENDARITEM SET OFFLINE_OPERATION=''");
		}
		
		override protected function processRow(row:Object):Object
		{
			var item:CalendarItemModel = new CalendarItemModel();
			item.id = row.ID;
			item.startTime = row.START_TIME;
			item.endTime = row.END_TIME;
			item.summary = row.SUMMARY;
			item.description = row.DESCRIPTION;
			item.lastUpdated = row.LAST_UPDATED;
			item.offlineOperation = row.OFFLINE_OPERATION;
			return item;
		} 
		
	}
}