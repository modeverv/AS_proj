package classes {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class CameraBtn extends Sprite {
		private var _cameraBtnMc:Sprite;
		private var _tf:TextField;
		private var _freecamera:Boolean = true;
		public var cameraType:String = "free";
		public const CAMERA_CHANGE:String = "camera_change";
		
		public function CameraBtn() {
			addEventListener( Event.ADDED_TO_STAGE , init );
		}
		
		private function init(e:Event):void {
			this.x = 100;
			this.y = 3;
			
			_cameraBtnMc = new CameraBtnMc();
			addChild(_cameraBtnMc);
			
			_cameraBtnMc.addEventListener( MouseEvent.CLICK , cameraBtnClick );
			
			var format:TextFormat = new TextFormat( "_ゴシック" );
			_tf = new TextField();
			_tf.defaultTextFormat = format;
			_tf.wordWrap = false;
			_tf.autoSize = "left";
			_tf.selectable = false;
			addChild(_tf);
			_tf.textColor = 0xFFFFFF;
			_tf.text = "：　CameraType = FREE";
			_tf.x = 105;
			_tf.y = 3;
		}
		
		private function cameraBtnClick(e:MouseEvent):void {
			_freecamera = !_freecamera;
			if (_freecamera) {
				_tf.text = "：　CameraType = FREE";
				cameraType = "free";
			} else {
				_tf.text = "：　CameraType = TARGET";
				cameraType = "target";
			}
			
			dispatchEvent( new Event(CAMERA_CHANGE) );
		}
		
	}
	
}