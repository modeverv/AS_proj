package modeverv {
		import flash.display.Sprite;
		
		public class Obj extends Sprite {
			public var color:uint;
			
			public function Obj(c:uint = 0xffffff) {
				this.color = c;
			}
			
			public function chgColor(c:uint):void {
				this.color = c;
			}
		}
}