package org.mineap.a2n4as
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	[Event(name="success", type="ApiGetFlvAccess")]
	[Event(name="fail", type="ApiGetFlvAccess")]
	[Event(name="httpResponseStatus", type="HTTPStatusEvent")]
	
	/**
	 * ニコニコ動画のAPI(getflv)へのアクセスを担当するクラスです。
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class ApiGetFlvAccess extends EventDispatcher
	{
		
		public static const SUCCESS:String = "Success";
		
		public static const FAIL:String = "Fail";
		
		private var _loader:URLLoader;
		
		public function ApiGetFlvAccess()
		{
			this._loader = new URLLoader();
		}
		
		/**
		 * FLVのURLを取得する為のAPIへのアクセスを行う
		 * @param videoID ビデオID
		 * @param isEconomy 強制的にエコノミーにするかどうか。swfでは無視される。
		 * 
		 */
		public function getAPIResult(videoID:String, isEconomy:Boolean):void
		{
			//FLVのURLを取得する為にニコニコ動画のAPIにアクセスする
			if(videoID.indexOf("nm") != -1){
				
				//swfのとき。swfにエコノミーモードは存在しない
				videoID = videoID + "?as3=1";
				
			}else{
				if(isEconomy){
					videoID = videoID + "?eco=1";
				}
			}
			
			var getAPIRequest:URLRequest;
			var url:String = "http://flapi.nicovideo.jp/api/getflv/" + videoID;
			
			getAPIRequest = new URLRequest(url);
			getAPIRequest.method = "GET";
			
			this._loader.addEventListener(Event.COMPLETE, getFlvSuccess);
			this._loader.addEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
			this._loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler);
			this._loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusEventHandler);
			
			this._loader.load(getAPIRequest);
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function errorEventHandler(event:ErrorEvent):void{
			removeHandler(event.currentTarget as URLLoader);
			dispatchEvent(new ErrorEvent(FAIL, false, false, event.text));
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function httpResponseStatusEventHandler(event:HTTPStatusEvent):void{
			dispatchEvent(event);
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function getFlvSuccess(event:Event):void{
			removeHandler(event.currentTarget as URLLoader);
			dispatchEvent(new Event(SUCCESS));
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function removeHandler(target:URLLoader):void{
			target.removeEventListener(Event.COMPLETE, getFlvSuccess);
			target.removeEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
			target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler);
			target.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusEventHandler);
		}
		
		/**
		 * APIの結果から現在エコノミーモードかどうかをチェックします。
		 * @return エコノミーモードの時true。
		 * 
		 */
		public function isEconomyMode():Boolean{
			var pattern:RegExp = new RegExp("&url=http.*low&link=");
			if(this._loader.data.search(pattern) != -1){
				return true;
			}
			return false;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get data():String{
			return this._loader.data;
		}
		
		/**
		 * 
		 * 
		 */
		public function close():void{
			try{
				this.removeHandler(this._loader);
				this._loader.close();
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
//			this._loader = null;
		}
		
	}
}