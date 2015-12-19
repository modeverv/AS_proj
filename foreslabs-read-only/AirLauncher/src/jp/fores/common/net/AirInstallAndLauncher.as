package jp.fores.common.net
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	
	import mx.controls.Alert;
	
	/**
	 * 初期化処理終了時のイベント
	 *
	 * @eventType flash.events.Event.INIT
	 */
	[Event(name="init", type="flash.events.Event")]
	
	
	/**
	 * AIRアプリケーションのインストール、または起動を行うクラス。
	 */
	public class AirInstallAndLauncher extends EventDispatcher
	{
		//==========================================================
		//定数
		
		/**
		 * air.swfのURL
		 */
		public static const AIR_SWF_URL :String = "http://airdownload.adobe.com/air/browserapi/air.swf";
		
		/**
		 * AIRランタイムのバージョンのデフォルト値
		 */
		public static const DEFAULT_RUNTIME_VERSION :String = "1.0";
		
		/**
		 * ステータス: 初期化前
		 */
		public static const STATUS_BEFORE_INIT :String = "0";
		
		/**
		 * ステータス: AIRアプリケーションインストール済み
		 */
		public static const STATUS_APPLICATION_INSTALLED :String = "1";
		
		/**
		 * ステータス: AIRアプリケーション未インストール
		 */
		public static const STATUS_APPLICATION_NOT_INSTALL :String = "2";
		
		/**
		 * ステータス: AIRランタイム未インストール
		 */
		public static const STATUS_RUNTIME_NOT_INSTALL :String = "3";
		
		/**
		 * ステータス: AIRランタイム使用不可能
		 */
		public static const STATUS_RUNTIME_UNAVAILABLE :String = "4";
		
		/**
		 * ステータス: air.swfの読み込み中に入出力エラーが発生
		 */
		public static const STATUS_AIR_SWF_IO_ERROR :String = "5";
		
		
		//==========================================================
		//フィールド
		
		/**
		 * インストール対象のAIRアプリケーションのAIRファイルのURL
		 */
		public var targetAirURL :String = null; 
		
		/**
		 * AIRランタイムのバージョン
		 */
		public var runtimeVersion :String = DEFAULT_RUNTIME_VERSION; 
		
		/**
		 * インストール対象のAIRアプリケーションのアプリケーションID
		 * (xxx-app.xml内に記述されている)
		 */
		public var appicationID :String = null; 
		
		/**
		 * インストール対象のAIRアプリケーションのパブリッシャーID
		 * (AIRのインストール先のMETA-INF/AIR/publisheridに記述されている)
		 */
		public var publisherID :String = null; 
		
		/**
		 * 対象のAIRアプリケーションに渡す引数の配列
		 * (通常は必要ない)
		 */
		public var arguments :Array = new Array();


		/**
		 * air.swfのオブジェクトを保持する変数
		 */
		protected var airSwf :Object;
		
		/**
		 * air.swfを読み込むためのローダー
		 */
		protected var airSwfLoader :Loader = null;
		
		/**
		 * ステータス
		 */
		protected var _status :String = STATUS_BEFORE_INIT;
		
		
		//==========================================================
		//メソッド
		
		/**
		 * 初期化処理を行います。
		 */
		public function init() :void
		{
			//インストール対象のAIRアプリケーションのAIRファイルのURLが指定されていない場合
			if((this.targetAirURL == null) || (this.targetAirURL == ""))
			{
				//例外を投げる
				throw new Error("インストール対象のAIRアプリケーションのAIRファイルのURLが指定されていません");
			}
			
			//インストール対象のAIRアプリケーションのアプリケーションIDが指定されていない場合
			if((this.appicationID == null) || (this.appicationID == ""))
			{
				//例外を投げる
				throw new Error("インストール対象のAIRアプリケーションのアプリケーションIDが指定されていません");
			}
			
			//インストール対象のAIRアプリケーションのパブリッシャーIDが指定されていない場合
			if((this.publisherID == null) || (this.publisherID == ""))
			{
				//例外を投げる
				throw new Error("インストール対象のAIRアプリケーションのパブリッシャーIDが指定されていません");
			}
			
			//air.swfを読み込むためのローダーのインスタンスを設定
			this.airSwfLoader = new Loader();

			//air.swfのイベントリスナーを設定する
			//(プロパティとメソッドにアクセスできるようになれば良いので、completeイベントではなくinitイベントを使う)
			this.airSwfLoader.contentLoaderInfo.addEventListener(Event.INIT, onAirSwfLoaderInit);
			this.airSwfLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onAirSwfLoaderErrorHandler);
			this.airSwfLoader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, onAirSwfLoaderHttpStatus);
			
			//air.swfの読み込み実行
			airSwfLoader.load(new URLRequest(AIR_SWF_URL));
		}

		/**
		 * 対象のAIRアプリケーションをインストールします。
		 * AIRのランタイム自体がまだイントールされていない場合は、ランタイムからインストールします。
		 */
		public function installApplication() :void
		{
			//ステータスが「AIRアプリケーション未インストール」、「AIRランタイム未インストール」以外の場合
			if((this._status != STATUS_APPLICATION_NOT_INSTALL) && (this._status != STATUS_RUNTIME_NOT_INSTALL))
			{
				//例外を投げる
				throw new Error("ステータスが不正です:" + this._status);
			}
				
			//air.swfに処理を委譲する
			this.airSwf.installApplication(this.targetAirURL, this.runtimeVersion, this.arguments); 
		}
		
		/**
		 * インストールされているAIRアプリケーションを起動します。
		 */
		public function launchApplication() :void
		{
			//ステータスが「AIRアプリケーションインストール済み」以外の場合
			if(this._status != STATUS_APPLICATION_INSTALLED)
			{
				//例外を投げる
				throw new Error("ステータスが不正です:" + this._status);
			}
				
			//air.swfに処理を委譲する
			this.airSwf.launchApplication(this.appicationID, this.publisherID, this.arguments);
		}
		
		/**
		 * ステータスの値を取得します。
		 * (読み取り専用)
		 * 
		 * @return ステータス
		 */
		public function get status() :String
		{
			//フィールドの値をそのまま返す
			return this._status;
		}
		
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//内部処理用
		
		/**
		 * air.swfの読み込み完了時のイベント処理を行います。
		 *
		 * @param event イベントオブジェクト
		 */
		protected function onAirSwfLoaderInit(event :Event):void
		{
			//読み込みが完了したair.swfのオブジェクトを取得
			this.airSwf = event.target.content;
			
			//AIRランタイム自体のインストール状況を取得
			var runtimeStatus :String = this.airSwf.getStatus();
			
			//AIRランタイムがすでにインストールされている場合
			if(runtimeStatus == "installed")
			{
				//対象のAIRアプリケーションのバージョン取得を行い、結果に応じてインストールまたは起動させる
				this.airSwf.getApplicationVersion(this.appicationID, this.publisherID, versionDetectCallback);
			}
			//AIRランタイムがまだインストールされていないが、インストールできる環境の場合
			else if(runtimeStatus == "available")
			{
				//ステータスを「AIRランタイム未インストール」に変更する
				this._status = STATUS_RUNTIME_NOT_INSTALL;
				
				//初期化イベントを投げる
				super.dispatchEvent(new Event(Event.INIT));
			}
			//AIRランタイムがインストールできない環境の場合
			else
			{
				//ステータスを「AIRランタイム使用不可能」に変更する
				this._status = STATUS_RUNTIME_UNAVAILABLE;
				
				//初期化イベントを投げる
				super.dispatchEvent(new Event(Event.INIT));
			}
		}
		
		/**
		 * air.swfのエラー系のイベント処理を行います。
		 *
		 * @param event イベントオブジェクト
		 */
		protected function onAirSwfLoaderErrorHandler(event :Event):void
		{
			//ステータスを「air.swfの読み込み中に入出力エラーが発生」に変更する
			this._status = STATUS_AIR_SWF_IO_ERROR;
			
			//初期化イベントを投げる
			super.dispatchEvent(new Event(Event.INIT));
		}
		
		/**
		 * air.swfのHTTPステータス変更時のイベント処理を行います。
		 *
		 * @param event イベントオブジェクト
		 */
		protected function onAirSwfLoaderHttpStatus(event :HTTPStatusEvent):void
		{
			//HTTPステータスが「404(Not Found)」の場合
			if(event.status == 404)
			{
				//エラー発生時と同じ処理を行う
				onAirSwfLoaderErrorHandler(event);
			}
		}
		
		/**
		 * 対象のAIRアプリケーションのバージョン取得処理のコールバック関数です。
		 *
		 * @param version バージョン
		 */
		protected function versionDetectCallback(version :String) :void 
		{
			//バージョンが取得できなかった場合
			//(対象のAIRアプリケーションがインストールされていない場合)
			if(version == null) 
			{
				//ステータスを「AIRアプリケーション未インストール」に変更する
				this._status = STATUS_APPLICATION_NOT_INSTALL;
			}
			//対象のAIRアプリケーションがインストールされている場合
			else
			{
				//ステータスを「AIRアプリケーションインストール済み」に変更する
				this._status = STATUS_APPLICATION_INSTALLED;
			}

			//初期化イベントを投げる
			super.dispatchEvent(new Event(Event.INIT));
		}
		
	}
}