package {
	public class MySubClass extends MyBaseClass {
		override public function sayHello():void {
			Logger.debug("MySubClassからニーハオ");
		}

		public function sayGoodbye():void {
			Logger.debug("MySubClassからさようなら");
		}
	}
}