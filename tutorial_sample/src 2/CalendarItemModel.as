package
{
	[Bindable]
	public class CalendarItemModel
	{
		public var id:int;
		public var startTime:Date;
		public var endTime:Date;
		public var summary:String = "";
		public var description:String = "";
	}
}