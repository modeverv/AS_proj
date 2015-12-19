package org.mineap.NNDD
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	
	import org.mineap.a2n4as.Login;
	import org.mineap.a2n4as.PublicMyListLoader;

	public class NNDDMyListLoader extends EventDispatcher
	{
		
		private var _logManager:LogManager;
		private var _login:Login;
		private var _publicMyListLoader:PublicMyListLoader;
		
		private var _libraryManager:LibraryManager;
		
		private var _publicMyListId:String;
		
		private var _xml:XML;
		
		/**
		 * 
		 */
		public static const LOGIN_SUCCESS:String = "LoginSuccess";
		
		/**
		 * 
		 */
		public static const LOGIN_FAIL:String = "LoginFail";
		
		/**
		 * 
		 */
		public static const PUBLIC_MY_LIST_GET_SUCCESS:String = "PublicMyListGetSuccess";
		
		/**
		 * 
		 */
		public static const PUBLIC_MY_LIST_GET_FAIL:String = "PublicMyListGetFail";
		
		/**
		 * ダウンロード処理が通常に終了したとき、typeプロパティがこの定数に設定されたEventが発行されます。
		 */
		public static const DOWNLOAD_PROCESS_COMPLETE:String = "DownloadProcessComplete";
		
		/**
		 * ダウンロード処理が中断された際に、typeプロパティがこの定数に設定されたEventが発行されます。
		 */
		public static const DOWNLOAD_PROCESS_CANCELD:String = "DonwloadProcessCancel";
		
		/**
		 * ダウンロード処理が以上終了した際に、typeプロパティがこの定数に設定されたEventが発行されます。
		 */
		public static const DOWNLOAD_PROCESS_ERROR:String = "DownloadProccessError";
		
		/**
		 * 
		 * @param logManager
		 * 
		 */
		public function NNDDMyListLoader(logManager:LogManager, libraryManager:LibraryManager)
		{
			this._logManager = logManager;
			this._libraryManager = libraryManager;
			this._login = new Login();
			this._publicMyListLoader = new PublicMyListLoader();
		}
		
		/**
		 * 
		 * @param user
		 * @param password
		 * @param myListId
		 * 
		 */
		public function requestDownloadForPublicMyList(user:String, password:String, myListId:String):void{
			
			trace("start - requestDownload(" + user + ", ****, " + myListId + ")");
			
			this._publicMyListId = myListId;
			
			this._login.addEventListener(Login.LOGIN_SUCCESS, loginSuccess);
			this._login.addEventListener(Login.LOGIN_FAIL, function(event:ErrorEvent):void{
				(event.target as URLLoader).close();
				_logManager.addLog(LOGIN_FAIL + event.target + ":" + event.text);
				trace(event + ":" + event.target +  ":" + event.text);
				dispatchEvent(new ErrorEvent(LOGIN_FAIL, false, false, event.text));
				close(true, true, event);
			});
			this._login.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(event:HTTPStatusEvent):void{
				trace(event);
				_logManager.addLog("\t\t" + HTTPStatusEvent.HTTP_RESPONSE_STATUS + ":" + event);
			});
			
			this._login.login(user, password);
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function loginSuccess(event:Event):void{
			
			//ログイン成功通知
			trace(LOGIN_SUCCESS + ":" + event);
			dispatchEvent(new Event(LOGIN_SUCCESS));
			
			this._publicMyListLoader.addEventListener(Event.COMPLETE, getPublicMyListSuccess);
			this._publicMyListLoader.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
				(event.target as URLLoader).close();
				_logManager.addLog(PUBLIC_MY_LIST_GET_FAIL + ":" +  _publicMyListId + ":" + event + ":" + event.target +  ":" + event.text);
				trace(PUBLIC_MY_LIST_GET_FAIL + ":" +  _publicMyListId  + ":" + event + ":" + event.target +  ":" + event.text);
				dispatchEvent(new IOErrorEvent(PUBLIC_MY_LIST_GET_FAIL, false, false, event.text));
				close(false, false);
			});
			
			this._publicMyListLoader.getPublicMyList(this._publicMyListId);
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function getPublicMyListSuccess(event:Event):void{
//			trace((event.target as URLLoader).data);
			
			this._xml = new XML((event.target as URLLoader).data);
			
//			trace(DOWNLOAD_PROCESS_COMPLETE + ":" + event + ":" + xml);
			this._logManager.addLog(DOWNLOAD_PROCESS_COMPLETE + ":" + this._publicMyListId);
			dispatchEvent(new Event(DOWNLOAD_PROCESS_COMPLETE));
		}
		
		/**
		 * 
		 * 
		 */
		public function get xml():XML{
			return this._xml;
		}
		
		/**
		 * 
		 * 
		 */
		private function terminate():void{
			this._logManager = null;
			this._login = null;
			this._publicMyListLoader = null;
		}
		
		/**
		 * Loaderをすべて閉じます。
		 * 
		 */
		public function close(isCancel:Boolean, isError:Boolean, event:ErrorEvent = null):void{
			
			//終了処理
			try{
				this._login.close();
				trace(this._login + " is closed.");
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
			try{
				this._publicMyListLoader.close();
				trace(this._publicMyListLoader + " is closed.");
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
			terminate();
			
			var eventText:String = "";
			if(event != null){
				eventText = event.text;
			}
			if(isCancel && !isError){
				dispatchEvent(new Event(DOWNLOAD_PROCESS_CANCELD));
			}else if(isCancel && isError){
				dispatchEvent(new IOErrorEvent(DOWNLOAD_PROCESS_ERROR, false, false, eventText));
			}
		}
		
		
		/**
		 * 渡された文字列からマイリストIDを探して返します。
		 * 
		 * @param string
		 * @return 
		 * 
		 */
		public static function getMyListId(string:String):String{
			
			var myListId:String = null;
			
			var pattern:RegExp = new RegExp("http://www.nicovideo.jp/mylist/(\\d*)", "ig");
			var array:Array = pattern.exec(string);
			if(array != null && array.length >= 1){
				myListId = array[1];
			}
			pattern = new RegExp("[mylist/]*(\\d+)", "ig");
			array = pattern.exec(string);
			if(array != null && array.length >= 1 && array[1].length >= 1){
				myListId = array[array.length-1];
			}
			
			return myListId;
		}
		
	}
}