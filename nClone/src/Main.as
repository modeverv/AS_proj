package
{
  import flash.events.Event;
	import flash.display.*;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
  /**
   * ...
   * @author modeverv
   */
  public class Main extends Sprite
  {

    public function Main():void
    {
      if (stage) init();
      else addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private var tb:FileldAndButton;
		private var ts:FileldAndSend;
    private var flv:VideoStageCls;
    private function init(e:Event = null):void
    {
      removeEventListener(Event.ADDED_TO_STAGE, init);
      // entry point
      tb = new FileldAndButton;
      addChild(tb);
      tb.x = 10;
      tb.y = 10;
      tb.addEventListener(FileldAndButton.START, startplay);
			
			ts = new FileldAndSend;
			addChild(ts);
			ts.x = 10;
			ts.y = 400;
			ts.addEventListener(FileldAndSend.START, sendMsg);
			
    }
		private function sendMsg(e:Event):void {
			trace("from ts:" + ts.echo);
			if(flv != null){
				trace("now sec:" + flv.getNowTime());
			}
			
			//ｺｺﾆphp通信
			if (ts.echo != "" && flv != null) {

				trace("ホゲ");
				var o:Object = new Object;
				o.str = ts.echo;
				o.time = flv.getNowTime();
				o.url = tb.tf.text;
				
				cp = new ConnectPHP();
				cp.sendAndLoad("test.php", o);
				cp.addEventListener(Event.COMPLETE, function(e:Event):void {
					var ret :Object = e.currentTarget.result;
					ts.tf2.text = ret.str;
				});
			}
			
		}
		private var cp:ConnectPHP;
    private function startplay(e:Event):* {
      trace("from EV:" + tb.echo );
      flv = new VideoStageCls(tb.echo);
      addChild(flv);
      flv.x = 10;
			flv.width = 480;
			flv.height = 360;
      flv.y = 40;
    }

  }
}