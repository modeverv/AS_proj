package jp.fores.common.net
{
	import com.codeazur.fzip.*;
	
	import flash.desktop.NativeApplication;
	import flash.desktop.Updater;
	import flash.events.*;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.*;
	import flash.utils.*;
	
	//==========================================================
	//メタ情報の定義
	
	/**
	 * リモートバージョンの取得が完了した場合に投げられるイベント
	 *
	 * @eventType jp.fores.common.net.AIRRemoteUpdaterEvent.REMOTE_VERSION_CHECK 
	 */
	[Event(name="remoteVersionCheck", type="jp.fores.common.net.AIRRemoteUpdaterEvent")]

	/**
	 * リモートアップデートの直前に投げられるイベント
	 *
	 * @eventType jp.fores.common.net.AIRRemoteUpdaterEvent.REMOTE_UPDATE 
	 */
	[Event(name="remoteUpdate", type="jp.fores.common.net.AIRRemoteUpdaterEvent")]

	/**
	 * AIRファイルの取得中に発生したイベントをそのまま投げます
	 *
	 * @eventType flash.events.HTTPStatusEvent.HTTP_STATUS 
	 */
	[Event(name="httpStatus", type="flash.events.HTTPStatusEvent")]

	/**
	 * AIRファイルの取得中に発生したイベントをそのまま投げます
	 *
	 * @eventType flash.events.IOErrorEvent.IO_ERROR
	 */
	[Event(name="ioError", type="flash.events.IOErrorEvent")]

	/**
	 * AIRファイルの取得中に発生したイベントをそのまま投げます
	 *
	 * @eventType flash.events.Event.OPEN
	 */
	[Event(name="open", type="flash.events.Event")]

	/**
	 * AIRファイルの取得中に発生したイベントをそのまま投げます
	 *
	 * @eventType flash.events.ProgressEvent.PROGRESS
	 */
	[Event(name="progress", type="flash.events.ProgressEvent")]

	/**
	 * AIRファイルの取得中に発生したイベントをそのまま投げます
	 * 
	 * @eventType flash.events.SecurityErrorEvent.SECURITY_ERROR
	 */
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]


	/**
	 * AIRアプリケーションのリモートアップデートを行うためのクラス。
	 */
	public class AIRRemoteUpdater extends EventDispatcher
	{
		//==========================================================
		//定数
		
		/**
		 * 「application.xml」のパス
		 */
		protected static const APPLICATION_XML_PATH :String = "META-INF/AIR/application.xml";
		
		/**
		 * 「application.xml」のネームスペース
		 */
		protected static const APPLICATION_XML_NAMESPACE :String = "http://ns.adobe.com/air/application/1.0";
		
		
		//==========================================================
		//フィールド
		
		/**
		 * リモートバージョン
		 */
		protected var _remoteVersion:String = "";
		
		/**
		 * AIRファイルのURL
		 */
		protected var airURL :String = null;
		
		/**
		 * 自動更新を行うかどうかのフラグ
		 */
		protected var isAutoUpdate :Boolean = false;
		
		
		//==========================================================
		//メソッド
		
		public function AIRRemoteUpdater()
		{
			default xml namespace = new Namespace(APPLICATION_XML_NAMESPACE);
		}
		
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//Getter(読み取り専用プロパティ)
		
		/**
		 * ローカルのapplication.xmlからバージョンを取得します。
		 * 
		 * @return バージョン
		 */
		public function get localVersion() :String 
		{
			//ローカルのapplication.xmlから読み込む際のネームスペースを設定
			//NativeApplication.nativeApplication.applicationDescriptor.setNamespace(new Namespace(APPLICATION_XML_NAMESPACE));

			//ローカルのapplication.xmlからバージョンを取得する
			return NativeApplication.nativeApplication.applicationDescriptor.version;
		}
		
		/**
		 * ローカルのapplication.xmlからコピーライトを取得します。
		 * 
		 * @return コピーライト
		 */
		public function get localCopyRight() :String 
		{
			//ローカルのapplication.xmlからコピーライトを取得する
			return NativeApplication.nativeApplication.applicationDescriptor.copyright;
		}
		
		/**
		 * ローカルのapplication.xmlからアプリケーション名を取得します。
		 * 
		 * @return アプリケーション名
		 */
		public function get localApplicationName() :String 
		{
			//ローカルのapplication.xmlからアプリケーション名を取得する
			return NativeApplication.nativeApplication.applicationDescriptor.name;
		}
		
		/**
		 * リモートのapplication.xmlからバージョンを取得します。
		 * 
		 * @return バージョン
		 */
		public function get remoteVersion() :String 
		{
			//フィールドの値をそのまま返す
			return _remoteVersion;
		}
		
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//通常のメソッド
		
		/**
		 * AIRアプリケーションのリモートバージョンのチェックを行います。
		 * 自動更新を行うかどうかのフラグがたっている場合は、ローカルバージョンとリモートバージョンが異なる場合に自動的にAIRアプリケーションのアップデートします。
		 * 
		 * @param airURL AIRファイルのURL
		 * @param isAutoUpdate 自動更新を行うかどうかのフラグ(省略可能, デフォルト=false)
		 */
		public function remoteVersionCheck(airURL :String, isAutoUpdate :Boolean = false):void {
			//引数の値をフィールドに設定
			this.airURL = airURL;
			this.isAutoUpdate = isAutoUpdate;
			
			//Zipファイルのダウンローダーのインスタンスを生成
			var fZip :FZip = new FZip();

			//イベントリスナーを設定
			fZip.addEventListener(FZipEvent.FILE_LOADED, zipFileLoadedHandler);
			fZip.addEventListener(IOErrorEvent.IO_ERROR, defaultHandler);
			fZip.addEventListener(SecurityErrorEvent.SECURITY_ERROR, defaultHandler);
			
			//AIRファイルのURLを元にファイルをダウンロードする
			fZip.load(new URLRequest(this.airURL));
		}

		/**
		 * AIRアプリケーションのリモートアップデートを行います。
		 * リモートバージョンが正しくないと、アップデートできないので注意して下さい。
		 * 
		 * @param airURL AIRファイルのURL
		 * @param remoteVersion リモートバージョン
		 */
		public function update(airURL :String, remoteVersion :String):void {
			//引数の値をフィールドに設定
			this.airURL = airURL;
			this._remoteVersion = remoteVersion;

			//ローダーのインスタンスを生成
			var loader :URLLoader = new URLLoader();
			
			//データフォーマットをバイナリ形式に変更
			loader.dataFormat = URLLoaderDataFormat.BINARY;

			//イベントリスナーを設定
			loader.addEventListener(Event.COMPLETE, aurFileDownloadCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, defaultHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, defaultHandler);
			loader.addEventListener(Event.OPEN, defaultHandler);
			loader.addEventListener(ProgressEvent.PROGRESS, defaultHandler);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, defaultHandler);

			//AIRファイルのURLを元にファイルをダウンロードする
			loader.load(new URLRequest(this.airURL));
		}


		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//内部処理用

		/**
		 * Zipファイルのロード完了時のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		protected function zipFileLoadedHandler(event :FZipEvent) :void 
		{
			//対象ファイルがapplication.xml
			if(event.file.filename == APPLICATION_XML_PATH) 
			{
				//Zipを閉じる
				FZip(event.target).close();
				
				//対象ファイルの内容を文字列として取得
				var content:String = event.file.getContentAsString();
				
				//取得した文字列をXMLオブジェクトに変換
				var contextXML :XML = new XML(content);
				
				//XMLからバージョンを取得して、フィールドのリモートバージョンに設定
				this._remoteVersion = contextXML.version;
				
				//リモートバージョンの取得完了イベントを投げる
				dispatchEvent(new AIRRemoteUpdaterEvent(AIRRemoteUpdaterEvent.REMOTE_VERSION_CHECK));
				
				//フィールドの自動更新を行うかどうかのフラグがたっている場合
				if(this.isAutoUpdate)
				{
					//ローカルバージョンとリモートバージョンが異なる場合
					if(this.localVersion != this.remoteVersion)
					{
						//AIRアプリケーションの更新処理を呼び出す
						update(this.airURL, this.remoteVersion);
					}
				}
			}
		}
		
		/**
		 * AIRファイルのダウンロード完了時のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		protected function aurFileDownloadCompleteHandler(event :Event):void 
		{
			//ダウンロードしたファイルをテンポラリファイルとして保存する
			var file :File = File.createTempFile();
			var stream :FileStream = new FileStream();
			var data:ByteArray = URLLoader(event.target).data as ByteArray;
			stream.open(file, FileMode.WRITE);
			stream.writeBytes(data);
			stream.close();

			//リモートアップデートの直前イベントを投げる
			dispatchEvent(new AIRRemoteUpdaterEvent(AIRRemoteUpdaterEvent.REMOTE_UPDATE));

			//ダウンロードしたテンポラリファイル, リモートバージョンを元に、AIRのアップデート機能を使って実際にアップデートを行う
			var updater:Updater = new Updater();
			updater.update(file, this.remoteVersion);
		}

		/**
		 * デフォルトのイベントハンドラーです。
		 * 発生したイベントを投げ直します。
		 * 
		 * @param event イベントオブジェクト
		 */
		protected function defaultHandler(event :Event):void 
		{
			//発生したイベントを投げ直す
			dispatchEvent(event);
		}
	}
}
