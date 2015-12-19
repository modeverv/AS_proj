package com.adobe.lineup.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.utils.DateUtil;
	
	public class GetAppointmentsEvent extends CairngormEvent
	{

		public static var GET_APPOINTMENTS_EVENT:String = "getAppointmentsEvent";
		private var _startDate:Date;
		private var _endDate:Date;
		public var updateUI:Boolean;
		
		public function GetAppointmentsEvent()
		{
			super(GET_APPOINTMENTS_EVENT);
		}
		
		public function set startDate(d:Date):void
		{
			this._startDate = DateUtil.makeMorning(d);
		}

		public function set endDate(d:Date):void
		{
			var tmpDate:Date = DateUtil.makeNight(d);
			tmpDate = new Date(tmpDate.time + 1000);			
			this._endDate = tmpDate;
		}
		
		public function get startDate():Date
		{
			return this._startDate;
		}

		public function get endDate():Date
		{
			return this._endDate;
		}
		
	}
}
