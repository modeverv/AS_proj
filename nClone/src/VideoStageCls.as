package {

		import flash.display.*;
		import flash.events.*;
		import flash.media.*;
		import flash.net.*;

		public class VideoStageCls extends Sprite{

			//NETSTREAM
			private var connection : NetConnection;
			private var netStream : NetStream;
			private var obj : Object;
			private var video_obj : Video;
			private var video_cotena : DisplayObjectContainer;
		
			public var src:String;
			
			public function VideoStageCls(s:String)
			{
					src = s;
					trace(src);
					VideoStart();
			}

			public var total_time:Number;
			
			private function VideoStart():void {
				video_cotena = new Sprite();
				addChild(video_cotena);
				//ローカルファイルアクセス用のネットコネクションを作成する
				connection = new NetConnection();
				//ストリーミングの場合「null」を変更する
				connection.connect (null);
				//Object
				obj = new Object();

				//ネットストリームオブジェクトを作成する
				netStream = new NetStream(connection);
				obj.onMetaData = function(param:Object):void {
					trace("total:" + param.duration + "sec");
					trace("width:" + param.width );
					trace ("height:" + param.height);
					trace("vrate:" + param.videodatarate + "kb");
					trace ("frate:" + param.framerate + "fps");
					trace("codec:" + param.videocodecid);
					
					var key:String;
					for ( key in param) {
						trace(key+ ":" + param[key]);
					}
				}
				netStream.client = obj;
				
				//画面上に表示する
				video_obj = new Video();
				video_cotena.addChild(video_obj);
				video_obj.x = 0;
				video_obj.y = 0;
				video_obj.width = 480;
				video_obj.height = 360;

				//ビデオオブジェクトとネットストリームオブジェクトを関連付ける
				video_obj.attachNetStream (netStream);
	//			netStream.play("flv/sample.flv");//再生
				trace(src);
				netStream.play(src);//再生
//				obj = netStream.client;// = obj;
//				obj = netStream;
				netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR,asyncErrorHandler);
				netStream.addEventListener(IOErrorEvent.IO_ERROR,URLLoaderIOErrorFunc);
				netStream.addEventListener(NetStatusEvent.NET_STATUS ,URLLoaderProgressFunc);

//				video_cotena.addEventListener(Event.ENTER_FRAME, Main_EnterFrame);
			}
			
			//　ゲンザイジコクヲエル
			public function getNowTime():Number {
				return netStream.time;
			}
			
			private var totalsec:Number;
			
			private function Main_EnterFrame(event:Event):void{

				//-----------------------------------------------------------------
				//再生中の FLV ファイルに埋め込まれている詳細情報を取得
				//-----------------------------------------------------------------
				
				
				//trace("time:" + netStream.time);
				
				//not use
				//trace("bufferLen:"+netStream.bufferLength);
				//trace("bufferTime:"+netStream.bufferTime);
				
				//この２つでよみこみ済みを管理できそう
				//trace("byteLoad:" + netStream.bytesLoaded);
				//trace("byteTotal:" + netStream.bytesTotal);

				//trace("client:" + netStream.client);
				
				var key:String ;
				for (key in netStream.client) {
					trace("[ key ] " + key + ": " + netStream.client[key]);		
				}
				totalsec = netStream.client["total"];
				
	/*
				obj.onMetaData = function(param:Object):void{

					trace("総時間 : " + param.duration + "秒");
					trace("幅 : " + param.width);
					trace("高さ : " + param.height);
					trace("ビデオレート : " + param.videodatarate + "kb");
					trace("フレームレート : " + param.framerate + "fps");
					trace("コーデックＩＤ : " + param.videocodecid);
	*/
					//キューポイント
	//				var key:String;
				
	//				for( key in param ){
	//					trace("[ key ] " + key + ": " + param[key]);
	//				}
	//		}
		}

		private function asyncErrorHandler(event:AsyncErrorEvent):void
		{
			trace("ASYNC_ERROR");
		}
		private function URLLoaderIOErrorFunc(event:IOErrorEvent):void
		{
			trace ("ファイル入出力のエラー");
		}
		private function URLLoaderProgressFunc(event:NetStatusEvent):void
		{
			switch(event.info.code){
				case "NetStream.Buffer.Empty":
					trace ("バッファが空になったので中断");
					break;
				case "NetStream.Buffer.Full":
					trace ("バッファを満たしたので再生");
					break;
				case "NetStream.Buffer.Flush":
					trace ("ストリーム読み込みが終了した");
					break;
				case "NetStream.Play.Start":
					trace ("再生の開始");
					break;
				case "NetStream.Play.Stop":
					trace ("再生の停止");
					break;
				case "NetStream.Play.StreamNotFound":
					trace ("FLV ファイルが見つからない");
					break;
				case "NetStream.Play.Failed":
					trace ("その他のエラー");
					break;
				case "NetStream.Seek.Failed":
					trace ("シークが失敗した");
					break;
				case "NetStream.Seek.InvalidTime":
					trace ("有効ではないシーク時間を指定した");
					trace ("指定可能なシーク時間 : " + event.info.details);
					netStream.seek (event.info.details);
					break;
				case "NetStream.Seek.Notify":
					trace ("シーク操作を完了");
					break;
				default:
					trace ("その他のイベントコード:" + event.info.code);
			}
		}	
	}
	
}
