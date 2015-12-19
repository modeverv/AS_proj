package com.salesbuilder.dao
{
	import com.salesbuilder.model.CalendarItemModel;
	import mx.collections.ArrayCollection;
	
	public interface ICalendarItemDAO
	{
		function getItem(id:int):CalendarItemModel;

		function findAll():ArrayCollection;
		
		function getChanges():ArrayCollection;

		function save(calendarItem:CalendarItemModel):void;

		function update(item:CalendarItemModel):void;

		function remove(item:CalendarItemModel):void;
		
		function create(item:CalendarItemModel):void;

		function unflagChanges():void;
		
	}
}