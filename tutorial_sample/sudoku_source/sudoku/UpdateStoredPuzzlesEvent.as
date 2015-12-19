package sudoku{
	

	import flash.events.Event;

	public class UpdateStoredPuzzlesEvent extends Event {
		
		public static const UPDATE:String = "onUpdate";
		
		public var level:uint;
		public var puzzle:String;
		
		public function UpdateStoredPuzzlesEvent(lv:uint, data:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			
			super(UPDATE, bubbles, cancelable);
			
			level = lv;
			puzzle = data;
			
		}
		
		public override function clone():Event {
			
			return new UpdateStoredPuzzlesEvent(level, puzzle);
		
		}

		public override function toString():String {
			
			return formatToString("UpdateStoredPuzzlesEvent", "type", "bubbles", "cancelable", "eventPhase", "level", "puzzle");
		
		}	
		
	}
	
}