package
{
  import flash.display.SimpleButton;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.text.TextField;
  import flash.text.TextFieldType
  import flash.events.MouseEvent;
  /**
   * ...
   * @author modeverv
   */
  public class FileldAndSend extends Sprite
  {
    public var echo:String;
    private var tf:TextField;
    private var bt:SimpleButton;
		public var tf2:TextField;
    public function FileldAndSend() 
    {
			tf2 = new TextField();
			tf2.text = "入力シテ押下";
			tf2.x = 0;
			tf2.y = 0;
			tf2.width = 80;
			tf2.height = 20;
			addChild(tf2);
			
      tf = new TextField();
      tf.border = true;
      tf.type = TextFieldType.INPUT
      tf.width = 300;
      tf.height = 20;
//      tf.text = "http://216.45.62.48/0884498173211799/2342348/video/2010-07-03/krenai.flv";
      tf.x = 90;
      tf.y = 0;
      addChild(tf);

      bt = new SimpleButton;
      bt.upState = makeRoundRect(Math.random() * 0xffffff);
      bt.overState = makeRoundRect(Math.random() * 0xffffff);
      bt.downState = makeRoundRect(Math.random() * 0xffffff);
      bt.hitTestState = bt.upState;
      bt.x = 400;
      bt.y = 0;
      addChild(bt);

      bt.addEventListener(MouseEvent.CLICK, shot);

      echo = new String();
    }

    public static const START:String = "start";
    
		private function shot(evt:MouseEvent):void{
      var str:String = tf.text;
      echo = str;
      trace(str);
			tf.text = "";
      dispatchEvent(new Event(FileldAndSend.START));
			
    }

    private function makeRoundRect(c:uint):Sprite {
      var s:Sprite = new Sprite;
      s.graphics.beginFill(c);
      s.graphics.drawRoundRect(0,0,50,20,20,20);
      s.graphics.endFill();
      return s;
    }
  }
}
