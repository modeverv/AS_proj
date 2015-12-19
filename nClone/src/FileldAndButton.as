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
  public class FileldAndButton extends Sprite
  {
    public var echo:String;
    public var tf:TextField;
    private var bt:SimpleButton;
    public function FileldAndButton()
    {

      tf = new TextField();
      tf.border = true;
      tf.type = TextFieldType.INPUT
      tf.width = 390;
      tf.height = 20;
      tf.text = "http://216.45.62.48/0884498173211799/2342348/video/2010-07-03/krenai.flv";
      tf.x = 0;
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
      dispatchEvent(new Event(FileldAndButton.START));
    }

    private function makeRoundRect(c:uint):Sprite {
      var s:Sprite = new Sprite;
      s.graphics.beginFill(c);
      s.graphics.drawRoundRect(0,0,100,20,20,20);
      s.graphics.endFill();
      return s;
    }
  }
}
