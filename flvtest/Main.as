package
{
//html経由でないとflvは読み込まれません
//ローカル以外ならphpなどで読み込んで渡す部分が必要なのかも。

    import flash.display.Sprite;
    import flash.events.AsyncErrorEvent;
    import flash.events.Event;
    import flash.events.NetStatusEvent;
    import flash.events.SecurityErrorEvent;
    import flash.media.Video;
    import flash.net.NetConnection;
    import flash.net.NetStream;
    import flash.text.TextField;//for test

    /**
     * ビデオの再生サンプル
     * @author Hikipuro
     */
    public class Main extends Sprite
    {
        /**
         * ビデオの URL
         */
        private var videoURL:String = "test.flv";

        /**
         * ネット接続用オブジェクト
         */
        private var netConnection:NetConnection;

/*
NetConnectionを作り、コネクションのconnectイベントにコールバックnetStatusHandlerを登録。
netStatusHandlerは無事つなげたらconnectStreamを呼び出す。だめならエラーを何とかする。。。
connectStreamではNetStreamをnetConnectionからつくる。
さらにVideoをつくり、videoのソースにstreamに設定し、再生開始。
リモートのvideoを再生させるにはstreamを同じドメインに作るphpなどからねじ込めばいいのだろうけど、
ちょっと今夜はやめておこう。
*/
        private var textField:TextField;
        /**
         * コンストラクタ
         */
        public function Main():void
        {
            textField = new TextField();
            textField.text = "Hello World2";
            addChild(textField);

            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }

        /**
         * 初期化イベント
         * @param   e
         */
        private function init(e:Event = null):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init); //?
            // entry point
            netConnection = new NetConnection(); //コネクションを作る。
            netConnection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler); //コネクションにイベントを追加
            netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);//コネクションにイベントを追加 いわゆるエラー系
            netConnection.connect(null); //コネクト(runみたいなものだと理解する)
        }

        /**
         * ビデオにストリームを接続して再生する
         */
        private function connectStream():void
        {
            //つながったらストリームを開き始める
            var netStream:NetStream = new NetStream(netConnection);
//            netStream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);//なくても動く。
//            netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler); //なくても動く。
//動くけど。。。
            textField.text = "now to make video";
            var video:Video = new Video();
            textField.text = "now to atatch";
            video.attachNetStream(netStream);//videoを作ってストリームをつなげる
            textField.text = videoURL + ":now to atatch" ;
            netStream.play(videoURL);//再生
            textField.text = "now playing..";
            addChild(video);
        }

        /**
         * ネットステータスイベント
         * @param   event
         */
        private function netStatusHandler(event:NetStatusEvent):void
        {
            //接続できたらconnectにつなげるだけ
            switch (event.info.code) {
                case "NetConnection.Connect.Success":
                    textField.text = "connectStream";
                    trace("connectStream");
                    connectStream();
                    break;
                case "NetStream.Play.StreamNotFound":
                    trace("Unable to locate video: " + videoURL);
                    textField.text = "Unable to locate video: " + videoURL;
                    break;
            }
        }

        /**
         * セキュリティエラーイベント
         * @param   event
         */
        private function securityErrorHandler(event:SecurityErrorEvent):void
        {
            trace("securityErrorHandler: " + event);
            textField.text = ("securityErrorHandler: " + event);
        }

        /**
         * 非同期処理エラーイベント
         * @param   event
         */
        private function asyncErrorHandler(event:AsyncErrorEvent):void
        {
            // AsyncErrorEvent を無視する
        }

    }

}