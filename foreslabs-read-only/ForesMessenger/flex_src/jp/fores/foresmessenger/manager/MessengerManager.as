package jp.fores.foresmessenger.manager
{
	import com.adobe.air.notification.AbstractNotification;
	import com.adobe.air.notification.Notification;
	import com.adobe.air.notification.NotificationClickedEvent;
	import com.adobe.air.notification.Purr;
	
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.InvokeEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.net.SharedObject;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import jp.fores.common.managers.AnimationTrayIconManager;
	import jp.fores.common.net.AIRRemoteUpdater;
	import jp.fores.common.utils.ArrayUtil;
	import jp.fores.common.utils.FileUtil;
	import jp.fores.common.utils.StringUtil;
	import jp.fores.common.utils.TrayIconUtil;
	import jp.fores.common.utils.WindowUtil;
	import jp.fores.common.utils.collections.ArraySet;
	import jp.fores.common.utils.collections.Set;
	import jp.fores.foresmessenger.constant.ForesMessengerConstant;
	import jp.fores.foresmessenger.constant.ForesMessengerIconConstant;
	import jp.fores.foresmessenger.dto.AttachmentFileDto;
	import jp.fores.foresmessenger.dto.ConfigDto;
	import jp.fores.foresmessenger.dto.ConfirmMessageDto;
	import jp.fores.foresmessenger.dto.MessageDto;
	import jp.fores.foresmessenger.dto.SendingMessageDto;
	import jp.fores.foresmessenger.dto.UserInfoDto;
	import jp.fores.foresmessenger.view.ConfigView;
	import jp.fores.foresmessenger.view.ErrorView;
	import jp.fores.foresmessenger.view.HistoryView;
	import jp.fores.foresmessenger.view.LogView;
	import jp.fores.foresmessenger.view.MessageCreateView;
	import jp.fores.foresmessenger.view.MessageDisplayView;
	import jp.fores.foresmessenger.view.MessageOpenConfirmView;
	import jp.fores.foresmessenger.view.WarningView;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.core.Application;
	import mx.core.Window;
	import mx.formatters.DateBase;
	import mx.managers.CursorManager;
	import mx.messaging.ChannelSet;
	import mx.messaging.Consumer;
	import mx.messaging.Producer;
	import mx.messaging.channels.AMFChannel;
	import mx.messaging.events.MessageEvent;
	import mx.messaging.messages.AsyncMessage;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import org.seasar.flex2.rpc.remoting.S2Flex2Service;
	
	/**
	 * メッセンジャーのメインの管理クラス。
	 * (Singletonパターンを使用)
	 */
	[Bindable]
	public class MessengerManager
	{
		//==========================================================
		//定数
		
		/**
		 * セッションキープ処理の定期呼び出しの間隔(単位=秒)
		 */
		public static const SESSION_KEEP_SPAN :int = 45;
		
		/**
		 * アイドル秒数変更処理の定期呼び出しの間隔(単位=秒)
		 */
		public static const CHANGE_IDLE_SECOND_SPAN :int = 300;
		
		/**
		 * トレイアイコンのアニメーションの間隔(単位=ミリ秒)
		 */
		public static const TRAY_ICON_ANIMATION_SPAN :int = 50;
		
		/**
		 * トレイアイコンのツールチップにデフォルトで表示する文言
		 */
		public static const TRAY_ICON_DEFAULT_TOOLTIP :String = "ForesMessenger";
		
		
		//==========================================================
		//フィールド
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//クラスフィールド
		
		/**
		 * 自分自身の唯一のインスタンス
		 */
		private static var _selfInstance :MessengerManager = null;
		
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//インスタンスフィールド
		
		/**
		 * ログイン中の利用者情報のリスト
		 */
		public var loginUserList :ArrayCollection = new ArrayCollection();
		
		/**
		 * 自分自身の利用者情報
		 */
		public var selfUserInfo :UserInfoDto = null;
		
		/**
		 * 設定情報用DTO
		 */
		private var _configDto :ConfigDto = null;
		
		/**
		 * 自グループのみ表示するかどうかのフラグ
		 */
		private var _isOnlySelfGroup :Boolean = false;
		
		/**
		 * 接続先のホストのURL
		 */
		private var _hostURL :String = ForesMessengerConstant.DEFAULT_HOST_URL;

		/**
		 * ログイン中の利用者情報のリスト受信用のコンシュマーオブジェクト
		 */
		private var _loginUserListConsumer :Consumer = new Consumer();

		/**
		 * メッセージ受信用のコンシュマーオブジェクト
		 */
		private var _messageReceiveConsumer :Consumer = new Consumer();

		/**
		 * ログイン通知受信用のコンシュマーオブジェクト
		 */
		private var _loginNotifyConsumer :Consumer = new Consumer();

		/**
		 * サーバー状態通知受信用のコンシュマーオブジェクト
		 */
		private var _serverConditionNotifyConsumer :Consumer = new Consumer();

		/**
		 * メッセージ送信用のプロデューサーオブジェクト
		 */
		private var _messageSendProducer :Producer = new Producer();

		/**
		 * S2Flex2用のサービス
		 */
		private var _s2Flex2Service :S2Flex2Service = new S2Flex2Service();

		/**
		 * セッションキープ処理の定期呼び出し用のタイマー
		 * (定数の間隔で永遠に繰り返す)
		 */
		private var _sessionKeepTimer :Timer = new Timer(SESSION_KEEP_SPAN * 1000, 0);
		
		/**
		 * アイドル秒数変更処理の定期呼び出し用のタイマー
		 * (定数の間隔で永遠に繰り返す)
		 */
		private var _changeIdleSecondTimer :Timer = new Timer(CHANGE_IDLE_SECOND_SPAN * 1000, 0);
		
		/**
		 * 設定情報保存用のSharedObject
		 */
		private var _configSharedObject :SharedObject = null;
		
		/**
		 * プルオブジェクト
		 * (アイドル状態になるまでの時間には定数の値を指定)
		 */
		private var _purr :Purr = new Purr(ForesMessengerConstant.IDLE_THRESHOLD);
		
		/**
		 * アニメーション機能付きのトレイアイコンの管理クラス
		 */
		private var _animationTrayIconManager :AnimationTrayIconManager = null;
		
		/**
		 * 「ログ参照」メニュー
		 * (設定に応じて有効・無効を切り替えられるようにフィールドに保持する)
		 */
		private var _logViewMenuItem :NativeMenuItem = null;
		
		/**
		 * 手つかずのメッセージの配列
		 */
		private var _untouchedMessageArray :Array = new Array();
		
		/**
		 * 設定画面を開くかどうかのフラグ
		 * (サーバーからの応答を待ってから処理を行うため)
		 */
		private var _isOpenConfigWindow :Boolean = false;
		
		/**
		 * 通知ウインドウに表示するアイコンのビットマップ
		 */
		private var _notifyIconBitmap :Bitmap = null;
		
		/**
		 * トレイアイコンを前回クリックした時間
		 * (1970 年 1 月 1 日 0 時（世界時）からのミリ秒数)
		 */
		private var _trayIconClickTime :Number = 0;
		
		/**
		 * アプリケーションの起動回数
		 */
		private var invokeCount :int = 0;
		
		/**
		 * テンポラリディレクトリの配列
		 */
		private var tempDirectoryArray :Array = new Array();

		
		//==========================================================
		//メソッド
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//コンストラクタ
		
		/**
		 * コンストラクタです。
		 * Singletonにするため、内部のダミーのプライベートクラスのインスタンスを引数にとります。
		 * 
		 * @param dummy ダミーのプライベートクラス
		 */
		public function MessengerManager(dummy :PrivateClass)
		{
			//ダミーのプライベートクラスのインスタンスがnullの場合
			//(外部のクラスからもnullを引数に指定すれば呼び出すことができるので、それを防止するためにチェック)
			if(dummy == null)
			{
				//例外を投げる
				throw new Error("このクラスはSingletonです。newではなくgetInstance()でインスタンスを取得して下さい。");
			}
		}
		
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//クラスメソッド
		
		/**
		 * このクラスの唯一のインスタンスを取得します。
		 * 
		 * @return このクラスの唯一のインスタンス
		 */
		public static function getInstance() :MessengerManager
		{
			//まだインスタンスが生成されていない場合
			if(_selfInstance == null)
			{
				//自分自身のクラスのインスタンスを生成
				_selfInstance = new MessengerManager(new PrivateClass())
			}
			
			//自分自身の唯一のインスタンスを返す
			return _selfInstance;
		}
		
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//通常のメソッド
		
		/**
		 * 初期化処理を行います。
		 */
		public function init() :void
		{
			//==========================================================
			//ByteArrayやSharedObjectで型情報が消滅しないようにするための登録処理
			//(念のため全てのDTOに対して行っておく)
			registerClassAlias("jp.fores.foresmessenger.dto.AttachmentFileDto", AttachmentFileDto);
			registerClassAlias("jp.fores.foresmessenger.dto.ConfigDto", ConfigDto);
			registerClassAlias("jp.fores.foresmessenger.dto.ConfirmMessageDto", ConfirmMessageDto);
			registerClassAlias("jp.fores.foresmessenger.dto.MessageDto", MessageDto);
			registerClassAlias("jp.fores.foresmessenger.dto.SendingMessageDto", SendingMessageDto);
			registerClassAlias("jp.fores.foresmessenger.dto.UserInfoDto", UserInfoDto);


			//==========================================================
			//すべてのウィンドウを閉じてもアプリケーションを終了しなくする
			NativeApplication.nativeApplication.autoExit = false;
			
			
			//==========================================================
			//アプリケーション終了直前に発生するイベントのイベントリスナーを設定
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onApplicationExiting);
			
			
			//==========================================================
			//アプリケーションが起動された場合に発生するイベントのイベントリスナーを設定
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onApplicationInvoke);
			
			
			//==========================================================
			//通知ウインドウに表示するアイコンのビットマップを生成
			this._notifyIconBitmap = new ForesMessengerIconConstant.notify_icon_image();
			
			
			//==========================================================
			//ログに出力する日付の曜日・月の略称の形式を設定
			DateBase.dayNamesShort = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
			DateBase.monthNamesShort = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct","Nov", "Dec"];

			
			//==========================================================
			//設定ファイルの内容を読み込んで、フィールドの接続先のホストのURLに設定
			setHostURLFromConfigFile();


			//==========================================================
			//チャネルセットの設定
			
			//チャネルセットのインスタンスを生成
			var channelSet :ChannelSet = new ChannelSet();
			
			//ストリーミング用のチャネルを生成してチャネルセットに追加
			//var streamingChannel :StreamingAMFChannel = new StreamingAMFChannel("my-streaming-amf", this.hostURL + "/messagebroker/streamingamf");
			//channelSet.addChannel(streamingChannel);

			//ポーリング用のチャネルを生成してチャネルセットに追加
			var pollingChannel :AMFChannel = new AMFChannel("my-polling-amf", this.hostURL + "/messagebroker/amfpolling");
			channelSet.addChannel(pollingChannel);


			//==========================================================
			//フィールドの全てのコンシュマー・プロデューサーオブジェクトにチャネルセットを設定する

			//ログイン中の利用者情報のリスト受信用のコンシュマーオブジェクト
			this._loginUserListConsumer.channelSet = channelSet;

			//メッセージ受信用のコンシュマーオブジェクト
			this._messageReceiveConsumer.channelSet = channelSet;

			//ログイン通知受信用のコンシュマーオブジェクト
			this._loginNotifyConsumer.channelSet = channelSet;

			//サーバー状態通知受信用のコンシュマーオブジェクト
			this._serverConditionNotifyConsumer.channelSet = channelSet;

			//メッセージ送信用のプロデューサーオブジェクト
			this._messageSendProducer.channelSet = channelSet;
			
			
			//==========================================================
			//コンシュマーオブジェクトの設定
			
			//ログイン中の利用者情報のリスト受信用のコンシュマーオブジェクトの宛先を設定
			this._loginUserListConsumer.destination = "loginUserList";
			
			//ログイン中の利用者情報のリスト受信用のコンシュマーオブジェクトを安全にサブスクライブ状態にする
			//(ログイン前の状態でもグループ選択の候補を表示するために、ログイン中の利用者情報のリストは受信しておきたいため)
			safetySubscribe(this._loginUserListConsumer);


			//ログイン通知受信用のコンシュマーオブジェクトの宛先を設定
			this._loginNotifyConsumer.destination = "loginNotify";


			//サーバー状態通知受信用のコンシュマーオブジェクトの宛先を設定
			this._serverConditionNotifyConsumer.destination = "serverConditionNotify";
			
			//サーバー状態通知受信用のコンシュマーオブジェクトを安全にサブスクライブ状態にする
			safetySubscribe(this._serverConditionNotifyConsumer);


			//コンシュマーオブジェクトのメッセージ受信時のイベントハンドラーを設定
			this._loginUserListConsumer.addEventListener(MessageEvent.MESSAGE, onLoginUserListReceive);
			this._messageReceiveConsumer.addEventListener(MessageEvent.MESSAGE, onMessageReceive);
			this._loginNotifyConsumer.addEventListener(MessageEvent.MESSAGE, onLoginNotifyReceive);
			this._serverConditionNotifyConsumer.addEventListener(MessageEvent.MESSAGE, onServerConditionNotifyReceive);


			//==========================================================
			//フィールドのS2Flex2用のサービスの設定
			this._s2Flex2Service.gatewayUrl = this.hostURL + "/gateway"
			this._s2Flex2Service.destination = "messengerService";
			this._s2Flex2Service.showBusyCursor = true;
			this._s2Flex2Service.initialized(Application.application, "s2Flex2Service");

			//エラー系のイベントのイベントリスナーを設定
			this._s2Flex2Service.addEventListener(IOErrorEvent.IO_ERROR, onNetworkError);
			this._s2Flex2Service.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onNetworkError);
			this._s2Flex2Service.addEventListener(NetStatusEvent.NET_STATUS, onS2FlexServiceNetStaus);
			
			
			//==========================================================
			//ログイン中の利用者情報のリストのデフォルトのソート順の設定
			//(グループ名の昇順)
			var sort :Sort = new Sort();
			sort.fields = [new SortField("groupName")];
			this.loginUserList.sort = sort;
			
			
			//==========================================================
			//セッションキープ処理の定期呼び出し用のタイマーを起動
			this._sessionKeepTimer.addEventListener(TimerEvent.TIMER, onSessionKeepTimer);
			this._sessionKeepTimer.start();
			
			
			//==========================================================
			//アイドル秒数変更処理の定期呼び出し用のタイマーを起動
			this._changeIdleSecondTimer.addEventListener(TimerEvent.TIMER, onChangeIdleSecondTimer);
			this._changeIdleSecondTimer.start();
			
			
			//==========================================================
			//設定状態の復元
			
			//チェック状態記憶用のSharedObjectを取得してフィールドに設定
			this._configSharedObject = SharedObject.getLocal("ConfigDto");
			
			//SharedObjectが取得できなかった場合、または内容を元の型に復元できなかった場合
			//(初回起動の場合)
			if((this._configSharedObject.size == 0) || !(this._configSharedObject.data.configDto is ConfigDto))
			{
				//SharedObjectの内容を元の型にキャストしてフィールドの設定情報用DTOに設定
				//(Setterの処理は呼び出したくないので、フィールドの生の変数に直接設定する)
				this._configDto = new ConfigDto();
				
				//ログファイルのパスにアプリケーションのプライベート記憶領域ディレクトリ配下の「messenger.log」を設定
				this._configDto.logFilePath = File.applicationStorageDirectory.resolvePath("messenger.log").nativePath;
			}
			//それ以外の場合
			else
			{
				//SharedObjectの内容を元の型にキャストしてフィールドの設定情報用DTOに設定
				//(Setterを呼び出す)
				this.configDto = this._configSharedObject.data.configDto as ConfigDto;
			}


			//自動ログインを行うかどうかのフラグがたっている場合
			if(this.configDto.isAutoLogin)
			{
				//自動ログインを行う
				login();
				
				//自動バージョンアップを行うかどうかのフラグがたっている場合
				if(this.configDto.isAutoVersionUp)
				{
					//自動ログインで自動バージョンチェックを行う設定で設定画面のウインドウを開く
					openConfigWindow(true, true);
				}
				
			}
			//それ以外の場合
			else
			{
				//設定画面を開くかどうかのフラグをたてる
				//(サーバーからの応答を待ってから処理を行うため)
				this._isOpenConfigWindow = true;
		
				//ログインしている全ての利用者の一覧の取得処理を行う
				//(ログイン中の全ての利用者のグループ名を取得できるようにするため)
				getLoginUserList();
			}
		}
		
		/**
		 * 安全にアプリケーションを終了させます。
		 * 
		 * @param exitCode 終了コード(省略可能, デフォルト = 0)
		 */
		public function safetyExitApplication(exitCode :int = 0) :void
		{
			//==========================================================
			//作成した一時ディレクトリをなるべく削除
			for each(var file :File in this.tempDirectoryArray)
			{
				try
				{
					//ディレクトリを中身もろとも削除する
					file.deleteDirectory(true);
				}
				//ディレクトリの削除に失敗した場合
				catch(e :Error)
				{
					//どうしようもないので何もしない
				}
			}
			
			
			//==========================================================
			//実際にアプリケーションを終了させる
			NativeApplication.nativeApplication.exit(exitCode);
		}
		
		/**
		 * テンポラリディレクトリを作成します。
		 * Fileクラスの純正のものでは、アプリケーションの終了時にもディレクトリが残ったままになってしまいますが、
		 * このメソッドを使えばアプリケーション終了時になるべく削除します。
		 */
		public function createTempDirectory() :File
		{
			//テンポラリディレクトリを作成
			var file :File = File.createTempDirectory();
			
			//作成したテンポラリディレクトリをフィールドの配列に追加
			this.tempDirectoryArray.push(file);
			
			//作成したテンポラリディレクトリを返す
			return file;
		}
		
		/**
		 * ログイン処理を行います。
		 */
		public function login() :void
		{
			//ログイン中の場合
			if(this.isLogin)
			{
				//以降の処理を行わない
				return;
			}
			
			//ログイン用の利用者情報DTOのインスタンスを生成
			var loginUserInfo :UserInfoDto = new UserInfoDto();
			
			//設定情報から取得した利用者名とグループ名を設定
			loginUserInfo.userName = this.configDto.userName;
			loginUserInfo.groupName = this.configDto.groupName;
			
			//クライアントのバージョンを設定
			loginUserInfo.clientVersion = new AIRRemoteUpdater().localVersion;
			
			
			//==========================================================
			//サーバーの処理の呼び出し
			
			//サーバーのログイン処理を呼び出す
			var token :AsyncToken = this._s2Flex2Service.doLogin(loginUserInfo);
			
			//成功時と失敗時に呼び出す関数を割り当てる
			token.addResponder(new mx.rpc.Responder(onLoginSuccess, onLoginFault));
		}

		/**
		 * ログアウト処理を行います。
		 */
		public function logout() :void
		{
			//ログイン中でない場合
			if(!this.isLogin)
			{
				//アプリケーションを正常終了させる
				safetyExitApplication(0);

				//以降の処理を行わない
				return;
			}
			
			
			//==========================================================
			//フィールドのコンシュマーオブジェクトのサブスクライブ状態を安全に解除する
			
			//メッセージ受信用のコンシュマーオブジェクト
			safetyUnsubscribe(this._messageReceiveConsumer);
			
			//ログイン通知受信用のコンシュマーオブジェクト
			safetyUnsubscribe(this._loginNotifyConsumer);


			//==========================================================
			//フィールドの自分自身の利用者情報をnullに戻す
			this.selfUserInfo = null;


			//==========================================================
			//サーバーの処理の呼び出し
			
			//サーバーのログアウト処理を呼び出す
			var token :AsyncToken = this._s2Flex2Service.doLogout();
			
			//成功時と失敗時に呼び出す関数を割り当てる
			token.addResponder(new mx.rpc.Responder(onLogoutSuccess, onLogoutFault));
		}

		/**
		 * バージョンアップ時のログアウト処理を行います。
		 */
		public function logoutForVersionUp() :void
		{
			//ログイン中でない場合
			if(!this.isLogin)
			{
				//以降の処理を行わない
				return;
			}
			
			
			//==========================================================
			//フィールドのコンシュマーオブジェクトのサブスクライブ状態を安全に解除する
			
			//メッセージ受信用のコンシュマーオブジェクト
			safetyUnsubscribe(this._messageReceiveConsumer);
			
			//ログイン通知受信用のコンシュマーオブジェクト
			safetyUnsubscribe(this._loginNotifyConsumer);


			//==========================================================
			//フィールドの自分自身の利用者情報をnullに戻す
			this.selfUserInfo = null;


			//==========================================================
			//サーバーの処理の呼び出し
			
			//サーバーのログアウト処理を呼び出す
			//(成功しても失敗しても何も処理を行わないので、戻り値のトークンは受け取らない)
			this._s2Flex2Service.doLogout();
		}

		/**
		 * ログインしている全ての利用者の一覧の取得処理を行います。
		 */
		public function getLoginUserList() :void
		{
			//==========================================================
			//サーバーの処理の呼び出し
			
			//サーバーのログインしている全ての利用者の一覧の取得処理を呼び出す
			var token :AsyncToken = this._s2Flex2Service.getLoginUserList();
			
			//成功時と失敗時に呼び出す関数を割り当てる
			token.addResponder(new mx.rpc.Responder(onGetLoginUserListSuccess, onGetLoginUserListFault));
		}

		/**
		 * メッセージ作成画面のウインドウを開きます。
		 */
		public function openMessageCreateWindow() :void 
		{
			//==========================================================
			//メッセージ作成画面のウインドウを開く
			
			//メッセージ作成画面のビューを作成
			var view :MessageCreateView = new MessageCreateView();
			view.systemChrome = NativeWindowSystemChrome.NONE;
			view.transparent = true;
			view.alwaysInFront = true;
			
			//ビューのウインドウを開く
			view.open();

			//画面中央からランダムにずれて表示されるように位置を調整する
			WindowUtil.centeringWindowRandomPosition(view.nativeWindow);
		}

		/**
		 * メッセージ作成画面のウインドウを返信用に開きます。
		 * 
		 * @param sendUserInfo 送信者の利用者情報
		 * @param quoteMessage 引用するメッセージ
		 * @param quoteMessageDisplayView 引用元のメッセージ表示ウインドウ
		 */
		public function openMessageCreateWindowForReply(sendUserInfo :UserInfoDto, quoteMessage :String, quoteMessageDisplayView :Window) :void 
		{
			//==========================================================
			//メッセージ作成画面のウインドウを開く
			
			//メッセージ作成画面用のビューを作成
			var view :MessageCreateView = new MessageCreateView();
			view.systemChrome = NativeWindowSystemChrome.NONE;
			view.transparent = true;
			view.alwaysInFront = true;

			//引数の値を設定
			view.selectedUserArray = [sendUserInfo];
			view.quoteMessage = quoteMessage;
			view.quoteMessageDisplayView = quoteMessageDisplayView;
			
			//メッセージ作成画面を開く
			view.open();

			//画面中央からランダムにずれて表示されるように位置を調整する
			//(通常の場合よりもずれかたを激しくする)
			WindowUtil.centeringWindowRandomPosition(view.nativeWindow, 200, 150);
		}

		/**
		 * 設定画面のウインドウを開きます。
		 * 
		 * @param isDisplayVersionTab バージョン情報タブを最初に表示するかどうかのフラグ(省略可能, デフォルト=false)
		 * @param isAutoLoginVersionCheck 自動ログインで自動バージョンチェックかどうかのフラグ(省略可能, デフォルト=false)
		 */
		public function openConfigWindow(isVersionTabFirstDisplay :Boolean = false, isAutoLoginVersionCheck :Boolean = false) :void 
		{
			//==========================================================
			//設定画面がすでに開かれている場合はアクティブ化する
			if(WindowUtil.activateWindowByTitle("設定"))
			{
				//アクティブ化に成功したので、以降の処理を行わない
				return;
			}


			//==========================================================
			//設定画面のウインドウを開く
			
			//設定画面のビューを作成
			var view :ConfigView = new ConfigView();
			view.systemChrome = NativeWindowSystemChrome.NONE;
			view.transparent = false;
			view.alwaysInFront = true;
			
			//バージョン情報タブを最初に表示するかどうかのフラグを設定
			view.isVersionTabFirstDisplay = isVersionTabFirstDisplay;
			
			//自動ログインで自動バージョンチェックかどうかのフラグを設定
			view.isAutoLoginVersionCheck = isAutoLoginVersionCheck;
			
			//自動ログインで自動バージョンチェックの場合
			if(isAutoLoginVersionCheck)
			{
				//ビューが表示されないようにする
				view.visible = false;
			}
				
			//ビューのウインドウを開く
			view.open();

			//画面中央からランダムにずれて表示されるように位置を調整する
			WindowUtil.centeringWindowRandomPosition(view.nativeWindow);
		}

		/**
		 * ログ参照画面のウインドウを開きます。
		 */
		public function openLogWindow() :void 
		{
			//==========================================================
			//ログ参照画面がすでに開かれている場合はアクティブ化する
			if(WindowUtil.activateWindowByTitle("ログ参照"))
			{
				//アクティブ化に成功したので、以降の処理を行わない
				return;
			}


			//==========================================================
			//ログ参照画面のウインドウを開く
			
			//ログ参照画面のビューを作成
			var view :LogView = new LogView();
			view.systemChrome = NativeWindowSystemChrome.NONE;
			view.transparent = false;
			view.alwaysInFront = true;
			
			//ビューのウインドウを開く
			view.open();

			//画面中央に表示されるように位置を調整する
			WindowUtil.centeringWindow(view.nativeWindow);
		}

		/**
		 * 更新履歴画面のウインドウを開きます。
		 */
		public function openHistoryWindow() :void 
		{
			//==========================================================
			//更新履歴画面がすでに開かれている場合はアクティブ化する
			if(WindowUtil.activateWindowByTitle("更新履歴"))
			{
				//アクティブ化に成功したので、以降の処理を行わない
				return;
			}


			//==========================================================
			//更新履歴画面のウインドウを開く
			
			//更新履歴照画面のビューを作成
			var view :HistoryView = new HistoryView();
			view.systemChrome = NativeWindowSystemChrome.NONE;
			view.transparent = false;
			view.alwaysInFront = true;
			
			//ビューのウインドウを開く
			view.open();

			//画面中央に表示されるように位置を調整する
			WindowUtil.centeringWindow(view.nativeWindow);
		}

		/**
		 * エラーメッセージ表示画面のウインドウを開きます。
		 * 
		 * @param errorMessage エラーメッセージ
		 */
		public function openErrorWindow(errorMessage :String) :void 
		{
			//==========================================================
			//エラーメッセージ表示画面がすでに開かれている場合はアクティブ化する
			if(WindowUtil.activateWindowByTitle("エラー"))
			{
				//アクティブ化に成功したので、以降の処理を行わない
				return;
			}


			//==========================================================
			//先に全てのウインドウを閉じておく
			WindowUtil.closeAllWindow();


			//==========================================================
			//エラーメッセージ表示画面のウインドウを開く
			
			//エラーメッセージ表示画面のビューを作成
			var view :ErrorView = new ErrorView();
			view.systemChrome = NativeWindowSystemChrome.NONE;
			view.transparent = false;
			view.alwaysInFront = true;
			
			//エラーメッセージを設定
			view.errorMessage = errorMessage;
			
			//ビューのウインドウを開く
			view.open();

			//画面中央に表示されるように位置を調整する
			WindowUtil.centeringWindow(view.nativeWindow);
		}

		/**
		 * 警告メッセージ表示画面のウインドウを開きます。
		 * 
		 * @param warningMessage 警告メッセージ
		 */
		public function openWarningWindow(warningMessage :String) :void 
		{
			//==========================================================
			//警告メッセージ表示画面のウインドウを開く
			
			//警告メッセージ表示画面のビューを作成
			var view :WarningView = new WarningView();
			view.systemChrome = NativeWindowSystemChrome.NONE;
			view.type = NativeWindowType.LIGHTWEIGHT;
			view.transparent = false;
			view.alwaysInFront = true;
			
			//警告メッセージを設定
			view.warningMessage = warningMessage;
			
			//ビューのウインドウを開く
			view.open();

			//画面中央に表示されるように位置を調整する
			WindowUtil.centeringWindow(view.nativeWindow);
		}

		/**
		 * 全ての手つかずのメッセージ表示画面のウインドウを開きます。
		 */
		public function openAllUntouchedMessageWindow() :void
		{
			//手つかずのメッセージの配列がnullまたは空配列の場合
			if(ArrayUtil.isBlank(this._untouchedMessageArray))
			{
				//以降の処理を行わない
				return;
			}

			//重ならないようにずらして表示するためのインデックス
			var index :int = 0;
			
			//手つかずのメッセージの配列の全ての要素に対して処理を行う
			for each(var message :SendingMessageDto in this._untouchedMessageArray)
			{
				//==========================================================
				//メッセージ表示画面のウインドウを開く
				
				//メッセージ表示画面のビューを作成
				var view :MessageDisplayView = new MessageDisplayView();
				view.systemChrome = NativeWindowSystemChrome.NONE;
				view.transparent = false;
				view.alwaysInFront = true;
	
				//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
				//各引数の値をポップアップの初期値として設定
				
				//送信メッセージ
				view.messageDto = message;
				//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/

				//ビューのウインドウを開く
				view.open();

				//画面中央に表示されるように位置を調整する
				//(重ならないようにするためにインデックスの分だけ位置をずらす)
				WindowUtil.centeringWindow(view.nativeWindow, index * 30, index * 20);
				
				//後から開いたウインドウの方が前に来るようにする
				view.orderToFront();

				//インデックスを進める
				index++;
			}

			//手つかずのメッセージの配列を空にする
			ArrayUtil.clear(this._untouchedMessageArray);
			
			//トレイアイコンのアニメーションを止める
			this._animationTrayIconManager.isAnimation = false;

			//トレイアイコンのツールチップをデフォルトの文言に戻す
			TrayIconUtil.setTooltip(TRAY_ICON_DEFAULT_TOOLTIP);
		}
		
		/**
		 * メッセージを送信します。
		 * 
		 * @param targetUserInfoArray 対象者の利用者情報の配列
		 * @param bodyText メッセージ本文
		 * @param attachmentFileArray 添付ファイル情報の配列
		 */
		public function sendMessage(targetUserInfoArray :Array, bodyText :String, attachmentFileArray :Array) :void
		{
			//Alert.show("メッセージを送信します");
			
			//対象者の利用者情報の配列がnullまたは空配列の場合
			if(ArrayUtil.isBlank(targetUserInfoArray))
			{
				//以降の処理を行わない
				return;
			}

			//最初の要素かどうかのフラグ
			var isFirstElement :Boolean = true;
			
			//対象者の利用者情報の配列の全ての要素に対して処理を行う
			for each(var targetUserInfo :UserInfoDto in targetUserInfoArray)
			{
				//送信メッセージ情報用DTOクラスのインスタンスを生成
				var message :SendingMessageDto = new SendingMessageDto();
				
				//対象者の利用者情報を設定
				message.targetUserInfo = targetUserInfo;
				
				//送信者の利用者情報にフィールドの自分自身の利用者情報を設定
				message.sendUserInfo = this.selfUserInfo;
				
				//メッセージ本文に引数の値を設定
				message.bodyText = bodyText;
				
				//添付ファイル情報の配列に引数の値を設定
				message.attachmentFileArray = attachmentFileArray;
				
				//作成したメッセージをプッシュ配信する
				sendMessageInternal(message, "send");
				
				//最初の要素の場合
				if(isFirstElement)
				{
					//最初の要素かどうかのフラグをfalseにする
					isFirstElement = false;
					
					//ログをファイルに記録するかどうかのフラグがたっている場合
					if(this.configDto.isLogging)
					{
						//送信メッセージの内容をログファイルに出力する
						LogManager.writeSendMessageLog(new File(this.configDto.logFilePath), message, targetUserInfoArray);
					}
				}
			}
		}

		/**
		 * 開封確認メッセージを送信します。
		 * 
		 * @param originalMessage 送信元のメッセージ
		 */
		public function sendOpenConfirmMessage(originalMessage :SendingMessageDto) :void
		{
			//ログをファイルに記録するかどうかのフラグがたっていて、かつ開封前の状態でログをファイルに記録するかどうかのフラグがたっていない場合
			if(this.configDto.isLogging && !this.configDto.isBeforeOpenLogging)
			{
				//受信したメッセージの内容をログファイルに出力する
				LogManager.writeReceiveMessageLog(new File(this.configDto.logFilePath), originalMessage);
			}
			
			
			//送信元のメッセージを元にして、開封確認メッセージ情報用DTOクラスのインスタンスを生成
			var confirmMessage :ConfirmMessageDto = new ConfirmMessageDto(originalMessage);
			
			//開封確認のメッセージをプッシュ配信する
			sendMessageInternal(confirmMessage, "openConfirm");
		}

		/**
		 * 通知ウインドウにメッセージを表示します。
		 * 
		 * @param title タイトル
		 * @param message メッセージ
		 * @param duration 表示時間
		 * @param titleTextColor 通知ウインドウのタイトルのテキストの色
		 * @param messageTextColor 通知ウインドウのメッセージのテキストの色
		 * @param backgroundColor 通知ウインドウの背景の色
		 */
		public function addNotification(title :String, message :String, duration :uint, titleTextColor :uint, messageTextColor :uint, backgroundColor :uint) :void
		{
			//引数の値を元にして通知ウインドウのインスタンスを生成
			//(表示位置は右下固定で、ビットマップにはフィールドの通知ウインドウに表示するアイコンのビットマップを指定)
			var notification :Notification = new Notification(title, message, AbstractNotification.BOTTOM_RIGHT, duration, this._notifyIconBitmap);
			
			//通知ウインドウの各色に引数の値を設定
			notification.titleTextColor = titleTextColor;
			notification.messageTextColor = messageTextColor;
			notification.backgroundColor = backgroundColor;
		
			//通知ウインドウのフォントをこのアプリケーションで使用するメインのフォントに変更
			notification.titleTextFont = ForesMessengerConstant.MAIN_FONT;
			notification.messageTextFont = ForesMessengerConstant.MAIN_FONT;
		
			//通知ウインドウがクリックされた場合のイベントリスナーを設定
			//(使い捨てにされるオブジェクトなので、一応弱参照のリスナーにしておく)
			notification.addEventListener(NotificationClickedEvent.NOTIFICATION_CLICKED_EVENT, onNotificationClick, false, 0, true);
		
			//プルオブジェクトを使って通知ウインドウを表示する
			this._purr.addNotification(notification);
		}

		/**
		 * 添付ファイル対象ディレクトリ用のファイルオブジェクトをSharedObjectの内容を元にして返します。
		 * 
		 * @param isAdd 追加用かどうかのフラグ(true=追加用, false=保存用)
		 * @return 添付ファイル対象ディレクトリ用のファイルオブジェクト
		 */
		public function getAttachmentTargetDirFileFromSharedObject(isAdd :Boolean) :File
		{
			//ディレクトリのネイティブパス
			var nativePath :String = null;

			//SharedObjectのプロパティ名
			var propertyName :String = "attachmentFileAddTargetDir";
			
			//保存用の場合
			if(!isAdd)
			{
				//SharedObjectのプロパティ名を保存用のものに変更する
				propertyName = "attachmentFileSaveTargetDir";
			}

			//設定情報保存用のSharedObjectの内容を元の型に復元できなかった場合
			//(初回起動の場合)
			if(!(this._configSharedObject.data[propertyName] is String))
			{
				//デスクトップディレクトリのネイティブパスを使用する
				return new File(File.desktopDirectory.nativePath);
			}
			//それ以外の場合
			else
			{
				//ネイティブパスを取得し、元の型にキャスト
				nativePath= this._configSharedObject.data[propertyName] as String;
			}

			//ネイティブパスに対応するファイルオブジェクトを生成して返す
			return new File(nativePath);
		}

		/**
		 * 添付ファイル対象ディレクトリ情報をSharedObjectに保存します。
		 * 
		 * @param file 添付ファイル選択対象ディレクトリ用のファイルオブジェクト
		 * @param isAdd 追加用かどうかのフラグ(true=追加用, false=保存用)
		 */
		public function saveAttachmentFileSelectTargetDirToSharedObject(file :File, isAdd :Boolean) :void
		{
			//ネイティブパス
			var nativePath :String = null;
			
			//SharedObjectのプロパティ名
			var propertyName :String = "attachmentFileAddTargetDir";
			
			//保存用の場合
			if(!isAdd)
			{
				//SharedObjectのプロパティ名を保存用のものに変更する
				propertyName = "attachmentFileSaveTargetDir";
			}


			//引数のファイルオブジェクトがディレクトリの場合
			if(file.isDirectory)
			{
				//引数のファイルオブジェクトのネイティブパスを使用する
				nativePath = file.nativePath;
			}
			//引数のファイルオブジェクトがディレクトリの場合
			else
			{
				//引数のファイルオブジェクトの親ディレクトリのネイティブパスを使用する
				nativePath = file.parent.nativePath;
			}
			
			//設定情報保存用のSharedObjectにネイティブパスを設定する
			this._configSharedObject.data[propertyName] = nativePath;
			
			//設定情報保存用のSharedObjectをフラッシュして、値を確定する
			this._configSharedObject.flush();
		}
		
		/**
		 * ファイルオブジェクトの情報を元に、添付ファイル情報用DTOのインスタンスを生成します。
		 * 
		 * @param file ファイルオブジェクト
		 * @return 添付ファイル情報用DTOのインスタンス
		 */
		public function createAttachmentFileDtoFromFile(file :File) :AttachmentFileDto
		{
			//添付ファイル情報用DTOのインスタンスを生成
			var dto :AttachmentFileDto = new AttachmentFileDto();
			
			//ファイルのフルパスを設定
			dto.fullPath = file.nativePath;

			//ファイル名を設定
			dto.fileName = file.name;

			//ファイルサイズを設定
			dto.fileSize = file.size;
			
			//ファイルの内容をByteArrayとして取得してバイナリデータに設定
			dto.fileData = FileUtil.readFileToByteArray(file);
			
			//バイナリデータのサイズを少しでも減らすためにByteArrayを圧縮する
			dto.fileData.compress();
			
			//作成したDTOを返す
			return dto;
		}

		/**
		 * 添付ファイル情報用DTOのインスタンスのバイナリデータの内容をファイルに出力します。
		 * 
		 * @param dto 添付ファイル情報用DTOのインスタンス
		 * @param file ファイルオブジェクト(省略可能, 省略された場合はテンポラリファイルを作成するのみ)
		 */
		public function writeAttachmentFileDtoFileDataToFile(dto :AttachmentFileDto, file :File = null) :void
		{
			//まだテンポラリファイルが作成されていない場合
			if(dto.tempFile == null)
			{
				//バイナリデータのByteArrayの圧縮を解凍する
				dto.fileData.uncompress();

				//ファイル名を元に、テンポラリファイルを作成
				dto.tempFile = createTempDirectory().resolvePath(dto.fileName);
				
				//バイナリデータの内容をテンポラリファイルに出力
				FileUtil.writeByteArrayToFile(dto.fileData, dto.tempFile);
			}
			
			//引数のファイルオブジェクトが指定されている場合
			if(file != null)
			{
				//テンポラリファイルの内容を引数のファイルに上書きモードでコピーする
				dto.tempFile.copyTo(file, true);
			}
		}


		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//Setter

		/**
		 * 設定情報用DTOを設定します。
		 * 
		 * @param configDto 設定情報用DTO
		 */
		public function set configDto(configDto :ConfigDto) :void
		{
			//フィールドの値を一時変数に退避
			var oldConfigDto :ConfigDto = this._configDto;
			
			//引数の値をフィールドに設定
			this._configDto = configDto;
			
			//ログイン中の場合
			if(this.isLogin)
			{
				//変更前の値が存在する場合
				if(oldConfigDto != null)
				{
					//利用者名またはグループ名が変化した場合
					if((this._configDto.userName != oldConfigDto.userName) || (this._configDto.groupName != oldConfigDto.groupName))
					{
						//利用者情報の変更処理を行う
						changeUserInfo(this._configDto.userName, this._configDto.groupName);
					}
					//それ以外の場合
					else
					{
						//現在開いているウインドウの表示を更新するため、ログイン中の利用者情報のリストをリフレッシュする
						this.loginUserList.refresh();
					}
				}
			}

			//「ログ参照」メニューがnullで内場合
			if(this._logViewMenuItem != null)
			{
				//ログをファイルに記録するかどうかのフラグに応じて、「ログ参照」メニューの有効状態を切り替える
				this._logViewMenuItem.enabled = this.configDto.isLogging;
			}

			try
			{
				//OS起動時にアプリケーションの自動起動を行うかどうかのフラグを設定
				NativeApplication.nativeApplication.startAtLogin = this.configDto.isAutoStart;
			}
			//自動起動の設定に失敗した場合
			catch(e :IllegalOperationError)
			{
				//特に何も行わない
			}


			//==========================================================
			//SharedObjectに値を保存

			//設定情報保存用のSharedObjectに設定情報用DTOを設定する
			this._configSharedObject.data.configDto = this._configDto;
			
			//設定情報保存用のSharedObjectをフラッシュして、値を確定する
			this._configSharedObject.flush();
		}

		/**
		 * 自グループのみ表示するかどうかのフラグを設定します。
		 * 
		 * @param isOnlySelfGroup 自グループのみ表示するかどうかのフラグ
		 */
		public function set isOnlySelfGroup(isOnlySelfGroup :Boolean) :void
		{
			//引数の値をフィールドに設定
			this._isOnlySelfGroup = isOnlySelfGroup;
			
			//フラグがたっている場合
			//(自グループのみ表示する場合)
			if(this._isOnlySelfGroup)
			{
				//ログイン中の利用者情報のリストのフィルタ関数に、自グループの利用者情報のみを選別するためのフィルタ用関数を設定する
				this.loginUserList.filterFunction = onlySelfGroupFilterFunction;
			}
			//フラグが立っていない場合
			//(全てのグループを表示する場合)
			else
			{
				//ログイン中の利用者情報のリストのフィルタリングを解除するために、フィルタ関数をnullに戻す
				this.loginUserList.filterFunction = null;
			}
			
			//フィルタ関数の変更を反映するためリフレッシュする
			this.loginUserList.refresh();
		}


		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//Getter

		/**
		 * 設定情報用DTOを取得します。
		 * 
		 * @return 設定情報用DTO
		 */
		public function get configDto() :ConfigDto
		{
			//フィールドの値をそのまま返す
			return this._configDto;
		}

		/**
		 * 自グループのみ表示するかどうかのフラグを取得します。
		 * 
		 * @return 自グループのみ表示するかどうかのフラグ
		 */
		public function get isOnlySelfGroup() :Boolean
		{
			//フィールドの値をそのまま返す
			return this._isOnlySelfGroup;
		}

		/**
		 * 接続先のホストのURLを取得します。
		 * (読み取り専用プロパティ)
		 * 
		 * @return 接続先のホストのURL
		 */
		public function get hostURL() :String
		{
			//フィールドの値をそのまま返す
			return this._hostURL;
		}
		
		/**
		 * ログイン中かどうかを取得します。
		 * (読み取り専用プロパティ)
		 * 
		 * @return true=ログイン中, false=ログイン中でない
		 */
		public function get isLogin() :Boolean
		{
			//自分自身の利用者情報がnullでない場合
			if(this.selfUserInfo != null)
			{
				//ログイン中なのでtrueを返す
				return true;
			}
			//それ以外の場合
			else
			{
				//ログイン中なのでtrueを返す
				return false;
			}
		}
		
		/**
		 * ログイン中の全ての利用者のグループ名の配列を取得します。
		 * (読み取り専用プロパティ)
		 * 
		 * @return ログイン中の全ての利用者のグループ名の配列
		 */
		public function get loginGroupNameList() :Array
		{
			//フィールドのログイン中の利用者情報のリストがnullまたは空配列の場合
			if((this.loginUserList == null) || (this.loginUserList.length == 0))
			{
				//空配列を返す
				return new Array();
			}
			
			//Setのインスタンスを生成
			//(重複を除外するため)
			var groupNameSet :Set = new ArraySet();
			
			//フィールドのログイン中の利用者情報のリストの全ての要素に対して処理を行う
			for each(var userInfo :UserInfoDto in this.loginUserList)
			{
				//Setにグループ名を追加する
				groupNameSet.add(userInfo.groupName);
			}
			
			//Setを配列に変換して返す
			return groupNameSet.toArray();
		}
		
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//内部処理用
		
		/**
		 * 実際にメッセージをプッシュ配信する内部処理用のメソッドです。
		 * 
		 * @param messageDto メッセージ情報用DTOクラスのインスタンス
		 * @param messageType ヘッダのメッセージタイプに設定する文字列
		 */
		private function sendMessageInternal(messageDto :MessageDto, messageType :String) :void
		{
			//実際に送信される非同期メッセージオブジェクトを生成
			var message: AsyncMessage = new AsyncMessage();
			
			//メッセージ情報用DTOクラスのインスタンスをByteArrayに変換
			//(こうしないと型情報が失われてしまうため)
			var byteArray :ByteArray = new ByteArray();
			byteArray.writeObject(messageDto);
			
			//非同期メッセージのボディーにByteArrayを設定
			message.body = byteArray;
			
			//非同期メッセージのヘッダのメッセージタイプに引数の値を設定
			message.headers.messageType = messageType
			
			//メッセージ送信用のプロデューサーオブジェクトの宛先に対象者の利用者IDを設定
			this._messageSendProducer.destination = messageDto.targetUserInfo.userID;
			
			//メッセージ送信用のプロデューサーオブジェクトを使ってプッシュ配信を行う
			this._messageSendProducer.send(message);
		}

		/**
		 * 利用者情報の変更処理を行います。
		 * 
		 * @param newUserName 新しい利用者名
		 * @param newGroupName 新しいグループ名
		 */
		private function changeUserInfo(newUserName :String, newGroupName :String) :void
		{
			//==========================================================
			//サーバーの処理の呼び出し
			
			//サーバーの利用者情報の変更処理を呼び出す
			var token :AsyncToken = this._s2Flex2Service.changeUserInfo(newUserName, newGroupName);
			
			//成功時と失敗時に呼び出す関数を割り当てる
			token.addResponder(new mx.rpc.Responder(onChangeUserInfoSuccess, onChangeUserInfoFault));
		}

		/**
		 * セッションキープ処理の定期呼び出し用のタイマーのタイマーイベントが発生した場合の処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onSessionKeepTimer(event :Event = null) :void
		{
			//セッションキープ処理を呼び出す
			sessionKeep();
		}

		/**
		 * サーバーのセッションキープ処理を呼び出します。
		 */
		private function sessionKeep() :void
		{
			//ログイン中でない場合
			if(!this.isLogin)
			{
				//以降の処理を行わない
				return;
			}
			

			//==========================================================
			//サーバーの処理の呼び出し
			
			//サーバーのセッションキープ処理を呼び出す
			var token :AsyncToken = this._s2Flex2Service.keepSession();
			
			//成功時と失敗時に呼び出す関数を割り当てる
			token.addResponder(new mx.rpc.Responder(onKeepSessionSuccess, onKeepSessionFault));
		}

		/**
		 * アイドル秒数変更処理の定期呼び出し用のタイマーのタイマーイベントが発生した場合の処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onChangeIdleSecondTimer(event :Event = null) :void
		{
			//アイドル秒数変更処理を呼び出す
			changeIdleSecond();
		}

		/**
		 * サーバーのアイドル秒数変更処理を呼び出します。
		 */
		private function changeIdleSecond() :void
		{
			//ログイン中でない場合
			if(!this.isLogin)
			{
				//以降の処理を行わない
				return;
			}
			

			//==========================================================
			//サーバーの処理の呼び出し
			
			//サーバーのアイドル秒数変更処理を呼び出す
			//(引数には最後のマウス入力またはキーボード入力からの経過時間を指定する)
			var token :AsyncToken = this._s2Flex2Service.changeIdleSecond(NativeApplication.nativeApplication.timeSinceLastUserInput);
			
			//成功時と失敗時に呼び出す関数を割り当てる
			token.addResponder(new mx.rpc.Responder(onChangeIdleSecondSuccess, onChangeIdleSecondFault));
		}


		/**
		 * 設定ファイルの内容を読み込んで、フィールドの接続先のホストのURLに設定します。
		 * 
		 * @param host ホスト
		 */
		private function setHostURLFromConfigFile() :void
		{
			try
			{
				//アプリケーションの起動したディレクトリを基準にして、設定ファイルを指すファイルオブジェクトを生成
				var file :File = File.applicationDirectory.resolvePath("config/config.ini");
				
				//設定ファイルの内容を読み込んで文字列として取得
				var str :String = FileUtil.readFileToString(file);

				//「\r」または「\n」を空文字列に変換することにより改行文字を削除
				str = str.replace(/(\r|\n)/g, "");
				
				//結果の値をフィールドの接続先のホストのURLに設定
				this._hostURL = str;
			}
			//例外が発生した場合
			catch(e :Error)
			{
				//エラーメッセージを表示
				//Alert.show("設定ファイルの読み込みに失敗しました:" + e);
				
				//どうしようもないので、デフォルトの定数をフィールドの接続先のホストのURLに設定
				this._hostURL = ForesMessengerConstant.DEFAULT_HOST_URL;
			}
		}
		
		/**
		 * トレイアイコンの設定を行います。
		 */
		private function setTrayIcon() :void
		{
			//==========================================================
			//アニメーション機能付きのトレイアイコンの設定
			
			//アニメーション機能付きのトレイアイコンの管理クラスのインスタンスを生成
			this._animationTrayIconManager = new AnimationTrayIconManager([ForesMessengerIconConstant.trayIcon_normal_image], ForesMessengerIconConstant.trayIcon_animationArray);
			
			//トレイアイコンのアニメーションの間隔を設定
			this._animationTrayIconManager.animationSpan = TRAY_ICON_ANIMATION_SPAN;
			
			//トレイアイコンのクリック時のイベントリスナーを設定
			TrayIconUtil.addClickEventListener(onTrayIconClick);
			
			
			//==========================================================
			//ツールチップを設定
			TrayIconUtil.setTooltip(TRAY_ICON_DEFAULT_TOOLTIP);
			
			
			//==========================================================
			//トレイアイコンのメニューを設定
			var menu :NativeMenu = new NativeMenu();
			
			//「メッセージ作成ウインドウを開く」メニュー
			var messageCreateWindowOpenMenuItem :NativeMenuItem = new NativeMenuItem("メッセージ作成ウインドウを開く");
			messageCreateWindowOpenMenuItem.addEventListener(Event.SELECT, onMessageCreateWindowOpenMenuItemSelect);
			menu.addItem(messageCreateWindowOpenMenuItem);

			//「全てのウインドウを前に」メニュー
			var allWindowOpenMenuItem :NativeMenuItem = new NativeMenuItem("全てのウインドウを前に");
			allWindowOpenMenuItem.addEventListener(Event.SELECT, onAllWindowOpenMenuItemSelect);
			menu.addItem(allWindowOpenMenuItem);

			//「全てのウインドウを閉じる」メニュー
			var allWindowCloseMenuItem :NativeMenuItem = new NativeMenuItem("全てのウインドウを閉じる");
			allWindowCloseMenuItem.addEventListener(Event.SELECT, onAllWindowCloseMenuItemSelect);
			menu.addItem(allWindowCloseMenuItem);

			//区切りの線を追加
			menu.addItem(new NativeMenuItem("", true));

			//「設定...」メニュー
			var configMenuItem :NativeMenuItem = new NativeMenuItem("設定...");
			configMenuItem.addEventListener(Event.SELECT, onConfigMenuItemSelect);
			menu.addItem(configMenuItem);

			//「バージョン情報」メニュー
			var versionMenuItem :NativeMenuItem = new NativeMenuItem("バージョン情報");
			versionMenuItem.addEventListener(Event.SELECT, onVersionMenuItemSelect);
			menu.addItem(versionMenuItem);

			//「ログ参照」メニュー
			//(設定に応じて有効・無効を切り替えられるようにフィールドの変数を使用する)
			this._logViewMenuItem = new NativeMenuItem("ログ参照");
			this._logViewMenuItem.addEventListener(Event.SELECT, onLogViewMenuItemSelect);
			menu.addItem(this._logViewMenuItem);

			//ログをファイルに記録するかどうかのフラグに応じて、「ログ参照」メニューの有効状態を切り替える
			this._logViewMenuItem.enabled = this.configDto.isLogging;

			//==========================================================
			//終了メニューはWindowsの場合のみ表示する
			//(Macだとシステム標準のものと併せて二重に表示されてしまうため)
			if(TrayIconUtil.isWindows())
			{
				//区切りの線を追加
				menu.addItem(new NativeMenuItem("", true));
	
				//「終了」メニュー
				var exitMenuItem :NativeMenuItem = new NativeMenuItem("終了");
				exitMenuItem.addEventListener(Event.SELECT, onExitMenuItemSelect);
				menu.addItem(exitMenuItem);
			}
			//==========================================================

			//作成したメニューをトレイアイコンのメニューとして設定
			TrayIconUtil.setTrayIconMenu(menu);
		}
		
		/**
		 * コンシュマーオブジェクトのサブスクライブ状態を安全に解除します。
		 * 
		 * @param consumer コンシュマーオブジェクト
		 */
		private function safetyUnsubscribe(consumer :Consumer) :void
		{
			try
			{
				//コンシュマーがサブスクライブ状態の場合
				if(consumer.subscribed)
				{
					//サブスクライブ状態を解除する
					consumer.unsubscribe();
				}
			}
			//例外が発生した場合
			catch(e :Error)
			{
				//どうしようもないので何もしない
				//Alert.show("サブスクライブ状態の解除に失敗しました。");
			}
		}

		/**
		 * コンシュマーオブジェクトを安全にサブスクライブ状態にします。
		 * 
		 * @param consumer コンシュマーオブジェクト
		 */
		private function safetySubscribe(consumer :Consumer) :void
		{
			try
			{
				//コンシュマーがサブスクライブ状態でないの場合
				if(!consumer.subscribed)
				{
					//サブスクライブ状態にする
					consumer.subscribe();
				}
			}
			//例外が発生した場合
			catch(e :Error)
			{
				//どうしようもないので何もしない
				//Alert.show("サブスクライブ状態の設定に失敗しました。");
			}
		}
		
		/**
		 * 自グループの利用者情報のみを選別するためのフィルタ用関数です。
		 * 
		 * @param item 対象オブジェクト
		 * @param true=表示対象, false=表示対象でない
		 */
		private function onlySelfGroupFilterFunction(item :Object) :Boolean
		{
			//対象オブジェクトが利用者情報用DTOクラスでない場合
			if(!(item is UserInfoDto))
			{
				//表示対象でないのでfalseを返す
				return false;
			}
			
			//対象オブジェクトを利用者情報用DTOクラスにキャストする
			var userInfo :UserInfoDto = item as UserInfoDto;
			
			//対象オブジェクトのグループ名が自分自身の利用者情報のグループ名と一致する場合
			if(userInfo.groupName == this.selfUserInfo.groupName)
			{
				//表示対象なのでtrueを返す
				return true;
			}
			//それ以外の場合
			else
			{
				//表示対象でないのでfalseを返す
				return false;
			}
		}
		
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//イベント処理用のハンドラ
		
		/**
		 * ログイン処理成功時のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onLoginSuccess(event :ResultEvent):void
		{
			//Alert.show("ログイン成功:" + ObjectUtil.toString(event.result));

			//結果のオブジェクトを取得して元の型にキャストし、フィールドの自分自身の利用者情報に設定
			this.selfUserInfo = event.result as UserInfoDto;
			
			//ログインしている全ての利用者の一覧の取得処理を行う
			getLoginUserList();
			
			//メッセージ受信用のコンシュマーオブジェクトの宛先に自分自身の利用者情報の利用者IDを設定
			this._messageReceiveConsumer.destination = this.selfUserInfo.userID;

			//メッセージ受信用のコンシュマーオブジェクトを安全にサブスクライブ状態にする
			safetySubscribe(this._messageReceiveConsumer);
			
			//ログイン通知受信用のコンシュマーオブジェクトを安全にサブスクライブ状態にする
			safetySubscribe(this._loginNotifyConsumer);

			//トレイアイコンを設定する
			setTrayIcon();
		}

		/**
		 * ログイン処理失敗時のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onLoginFault(event :FaultEvent):void
		{
			//ビジーカーソルの表示を解除する
			CursorManager.removeBusyCursor();
			
			//どうしようもないのでメッセージを表示する
			//Alert.show("ログイン処理に失敗しました:" + event.message);

			//通信系のエラーが発生した場合のイベント処理を行う
			onNetworkError();
		}

		/**
		 * ログアウト処理成功時のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onLogoutSuccess(event :ResultEvent):void
		{
			//Alert.show("ログアウト成功");
			
			//アプリケーションを正常終了させる
			safetyExitApplication(0);
		}

		/**
		 * ログアウト処理失敗時のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onLogoutFault(event :FaultEvent):void
		{
			//Alert.show("ログアウト失敗");

			//アプリケーションを異常終了させる
			safetyExitApplication(1);
		}

		/**
		 * ログインしている全ての利用者の一覧の取得処理成功時のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onGetLoginUserListSuccess(event :ResultEvent):void
		{
			//Alert.show("ログインしている全ての利用者の一覧の取得処理成功");

			//結果のオブジェクトを取得
			var result :Object = event.result;

			//結果のオブジェクトがArrayCollectionの場合
			if(result is ArrayCollection)
			{
				//結果のオブジェクトの配列を取得して、フィールドのログイン中の利用者情報のリストのソースに設定
				//(ArrayCollectionをそのままフィールドに設定してしまうと、ソート順などの情報が消えてしまうため、中の配列データを使用する)
				this.loginUserList.source = (result as ArrayCollection).source;
			}
			//結果のオブジェクトが配列の場合
			else if(result is Array)
			{
				//フィールドのログイン中の利用者情報のリストのソースに設定
				this.loginUserList.source = result as Array;
			}


			//設定画面を開くかどうかのフラグがたっている場合
			if(this._isOpenConfigWindow)
			{
				//設定画面を開くかどうかのフラグをfalseにする
				this._isOpenConfigWindow = false;
		
				//設定画面のウインドウを開く
				openConfigWindow();
			}
		}

		/**
		 * ログインしている全ての利用者の一覧の取得処理失敗時のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onGetLoginUserListFault(event :FaultEvent):void
		{
			//ビジーカーソルの表示を解除する
			CursorManager.removeBusyCursor();
			
			//どうしようもないのでメッセージを表示する
			//Alert.show("ログインしている全ての利用者の一覧の取得処理に失敗しました:" + event.message);

			//通信系のエラーが発生した場合のイベント処理を行う
			onNetworkError();
		}

		/**
		 * 利用者情報の変更処理成功時のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onChangeUserInfoSuccess(event :ResultEvent):void
		{
			//結果のオブジェクトを取得して元の型にキャストし、フィールドの自分自身の利用者情報に設定
			this.selfUserInfo = event.result as UserInfoDto;
		}

		/**
		 * 利用者情報の変更処理失敗時のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onChangeUserInfoFault(event :FaultEvent):void
		{
			//ビジーカーソルの表示を解除する
			CursorManager.removeBusyCursor();
			
			//通信系のエラーが発生した場合のイベント処理を行う
			onNetworkError();
		}

		/**
		 * セッションキープ処理成功時のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onKeepSessionSuccess(event :ResultEvent):void
		{
			//Alert.show("セッションキープ処理成功");
		}

		/**
		 * セッションキープ処理失敗時のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onKeepSessionFault(event :FaultEvent):void
		{
			//ビジーカーソルの表示を解除する
			CursorManager.removeBusyCursor();
			
			//どうしようもないのでメッセージを表示する
			//Alert.show("セッションキープ処理に失敗しました:" + event.message);

			//通信系のエラーが発生した場合のイベント処理を行う
			onNetworkError();
		}

		/**
		 * アイドル秒数変更処理成功時のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onChangeIdleSecondSuccess(event :ResultEvent):void
		{
			//Alert.show("アイドル秒数変更処理成功");
			
			//ログインしている全ての利用者の一覧の取得処理成功時のイベント処理と同じ処理を行う
			onGetLoginUserListSuccess(event);
		}

		/**
		 * アイドル秒数変更処理失敗時のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onChangeIdleSecondFault(event :FaultEvent):void
		{
			//ビジーカーソルの表示を解除する
			CursorManager.removeBusyCursor();
			
			//どうしようもないのでメッセージを表示する
			//Alert.show("アイドル秒数変更処理に失敗しました:" + event.message);

			//通信系のエラーが発生した場合のイベント処理を行う
			onNetworkError();
		}

		/**
		 * ログイン中の利用者情報のリスト受信用のコンシュマーオブジェクトがメッセージを受信した場合のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onLoginUserListReceive(event: MessageEvent) :void 
		{
			//メッセージヘッダに設定されたメッセージタイプを取得
			var messageType :String = event.message.headers.messageType;
			
			//サーバーからプッシュされたメッセージの場合
			if(messageType == "serverPush")
			{
				//結果のオブジェクトを取得
				var result :Object = event.message.body;
				
				//Alert.show("ログイン中の利用者情報のリスト受信 - サーバーからプッシュされたメッセージ:" + ObjectUtil.toString(result));

				//結果のオブジェクトがArrayCollectionの場合
				if(result is ArrayCollection)
				{
					//結果のオブジェクトの配列を取得して、フィールドのログイン中の利用者情報のリストのソースに設定
					//(ArrayCollectionをそのままフィールドに設定してしまうと、ソート順などの情報が消えてしまうため、中の配列データを使用する)
					this.loginUserList.source = (result as ArrayCollection).source;
				}
				//結果のオブジェクトが配列の場合
				else if(result is Array)
				{
					//フィールドのログイン中の利用者情報のリストのソースに設定
					this.loginUserList.source = result as Array;
				}
			}
		}

		/**
		 * メッセージ受信用のコンシュマーオブジェクトがメッセージを受信した場合のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onMessageReceive(event: MessageEvent) :void 
		{
			//メッセージヘッダに設定されたメッセージタイプを取得
			var messageType :String = event.message.headers.messageType;
			
			//送信メッセージの場合
			if(messageType == "send")
			{
				//メッセージのボディーを元の型に戻す
				var sendingMessage :SendingMessageDto = (event.message.body as ByteArray).readObject() as SendingMessageDto
				
				//送信メッセージを受信した場合の処理を行う
				onReceiveSendingMessage(sendingMessage);
			}
			//開封確認メッセージの場合
			else if(messageType == "openConfirm")
			{
				//メッセージのボディーを元の型に戻す
				var confirmMessage :ConfirmMessageDto = (event.message.body as ByteArray).readObject() as ConfirmMessageDto
				
				//開封確認メッセージを受信した場合の処理を行う
				onReceiveOpenConfirmMessage(confirmMessage);
			}
		}

		/**
		 * 送信メッセージを受信した場合の処理を行います。
		 * 
		 * @param message 送信メッセージ
		 */
		private function onReceiveSendingMessage(message :SendingMessageDto) :void
		{
			//==========================================================
			//着信拒否のチェック
			
			//設定情報の別のグループからの着信を拒否するかどうかのフラグがたっていて、ログイン中の利用者情報とメッセージの送信者の利用者情報とのグループ名が一致しない場合
			if((this.configDto.isDenyOtherGroup && (this.selfUserInfo.groupName != message.sendUserInfo.groupName)))
			{
				//以降の処理を行わない
				return;
			}
			
			
			//==========================================================
			//受信したメッセージを手つかずのメッセージの配列に追加する
			this._untouchedMessageArray.push(message);
			
			
			//==========================================================
			//設定情報の値に応じてメッセージ表示画面のウインドウをすぐに開くか、トレイアイコンのアニメーションを開始するか決定する
			
			//着信メッセージをすぐにポップアップウインドウで表示するかどうかのフラグがたっている場合
			if(this.configDto.isReceiveOpenWindow)
			{
				//全ての手つかずのメッセージ表示画面のウインドウを開く
				openAllUntouchedMessageWindow();
			}
			//それ以外の場合
			else
			{
				//トレイアイコンのアニメーションを開始する
				this._animationTrayIconManager.isAnimation = true;

				//トレイアイコンのツールチップに未読件数を設定する
				TrayIconUtil.setTooltip("未読メッセージ: " + this._untouchedMessageArray.length + "件");
			}
			
			//==========================================================
			//通知ウインドウの表示
			
			//設定情報の着信通知レベルが「全て」の場合、または「同じグループの場合に通知する」かつログイン中の利用者情報とメッセージの送信者の利用者情報とのグループ名が一致する場合
			if((this.configDto.receiveNotifyLevel == ForesMessengerConstant.NOTIFY_LEVEL_ALL) ||
				((this.configDto.receiveNotifyLevel == ForesMessengerConstant.NOTIFY_LEVEL_GROUP) && (this.selfUserInfo.groupName == message.sendUserInfo.groupName)))
			{
				//通知タイトル
				var notifyTitle :String = "新着メッセージを受信しました";
				
				//通知メッセージ
				//(送信者名/グループ名\n送信日時)
				var notifyMessage :String = message.sendUserInfo.userName + "/" + message.sendUserInfo.groupName + "\n" + StringUtil.formatTime(message.sendTime);
				
				//通知ウインドウにメッセージを表示
				addNotification(notifyTitle, notifyMessage, this.configDto.receiveNotifyDuration, this.configDto.receiveNotifyWindowTitleTextColor, this.configDto.receiveNotifyWindowMessageTextColor, this.configDto.receiveNotifyWindowBackgroundColor);
			}


			//==========================================================
			//ログ出力

			//ログをファイルに記録するかどうかのフラグがたっていて、かつ開封前の状態でログをファイルに記録するかどうかのフラグがたっている場合
			if(this.configDto.isLogging && this.configDto.isBeforeOpenLogging)
			{
				//受信したメッセージの内容をログファイルに出力する
				LogManager.writeReceiveMessageLog(new File(this.configDto.logFilePath), message);
			}
		}

		/**
		 * 開封確認メッセージを受信した場合の処理を行います。
		 * 
		 * @param message 開封確認メッセージ
		 */
		private function onReceiveOpenConfirmMessage(message :ConfirmMessageDto) :void
		{
			//設定情報の開封通知レベルが「ポップアップウインドウで通知する」の場合
			if(this.configDto.openNotifyLevel == ForesMessengerConstant.OPEN_NOTIFY_LEVEL_WINDOW)
			{
				//==========================================================
				//開封確認画面のウインドウを開く
				
				//開封確認画面のビューを作成
				var view :MessageOpenConfirmView = new MessageOpenConfirmView();
				view.systemChrome = NativeWindowSystemChrome.NONE;
				view.transparent = false;
				view.alwaysInFront = true;
	
				//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
				//各引数の値をポップアップの初期値として設定
				
				//開封確認メッセージ
				view.messageDto = message;
				//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
			
				//ビューのウインドウを開く
				view.open();
			
				//画面中央からランダムにずれて表示されるように位置を調整する
				WindowUtil.centeringWindowRandomPosition(view.nativeWindow, 50, 40);
			}
			//設定情報の開封通知レベルが「画面右下の通知ウインドウで通知する」の場合
			else if(this.configDto.openNotifyLevel == ForesMessengerConstant.OPEN_NOTIFY_LEVEL_NOTIFY)
			{
				//==========================================================
				//通知ウインドウの表示
				
				//通知タイトル
				var notifyTitle :String = "メッセージが開封されました";
				
				//通知メッセージ
				//(送信者名/グループ名\n送信日時)
				var notifyMessage :String = message.sendUserInfo.userName + "/" + message.sendUserInfo.groupName + "\n" + StringUtil.formatTime(message.sendTime);
				
				//通知ウインドウにメッセージを表示
				addNotification(notifyTitle, notifyMessage, this.configDto.openNotifyDuration, this.configDto.openNotifyWindowTitleTextColor, this.configDto.openNotifyWindowMessageTextColor, this.configDto.openNotifyWindowBackgroundColor);
			}
		}

		/**
		 * ログイン通知受信用のコンシュマーオブジェクトがメッセージを受信した場合のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onLoginNotifyReceive(event: MessageEvent) :void 
		{
			//メッセージヘッダに設定されたメッセージタイプを取得
			var messageType :String = event.message.headers.messageType;
			
			//サーバーからプッシュされたメッセージの場合
			if(messageType == "serverPush")
			{
				//ログインしている全ての利用者の一覧の取得処理を行う
				getLoginUserList();

				
				//メッセージヘッダに設定されたログインタイプを取得
				var loginType :String = event.message.headers.loginType;

				//メッセージのボディーを元の型に戻す
				var userInfo :UserInfoDto = event.message.body as UserInfoDto
				
				//ログインタイプが「logout」(ログアウト)の場合で、かつログイン中の利用者情報とログイン通知の利用者情報の利用者IDが一致する場合
				//(自分自身のログアウト通知を受信した場合)
				if((loginType == "logout")&& (this.selfUserInfo.userID == userInfo.userID))
				{
					//エラーメッセージ表示画面のウインドウを開く
					openErrorWindow("サーバーとの通信が途絶えました。\n\n申し訳ありませんが、アプリケーションを起動しなおして下さい。");

					//以降の処理を行わない
					return;
				}
				
			
				//ログイン通知を受け取らない設定になっている場合
				if(this._configDto.loginNotifyLevel == ForesMessengerConstant.NOTIFY_LEVEL_NONE)
				{
					//以降の処理を行わない
					return;
				}

				
				//設定情報のログイン通知レベルが「全て」の場合、または「同じグループの場合に通知する」かつログイン中の利用者情報とログイン通知の利用者情報のグループ名が一致する場合
				if((this.configDto.loginNotifyLevel == ForesMessengerConstant.NOTIFY_LEVEL_ALL) ||
					((this.configDto.loginNotifyLevel == ForesMessengerConstant.NOTIFY_LEVEL_GROUP) && (this.selfUserInfo.groupName == userInfo.groupName)))
				{
					//==========================================================
					//通知ウインドウの表示
					
					//ログインタイプの文字列表現
					var loginTypeStr :String = "ログイン"
					
					//ログインタイプが「logout」(ログアウト)の場合
					if(loginType == "logout")
					{
						//ログインタイプの文字列表現を「ログアウト」に変更
						loginTypeStr = "ログアウト";
					}
					
					//通知タイトル
					//((ログイン または ログアウト)通知)
					var notifyTitle :String = loginTypeStr + "通知";
					
					//通知メッセージ
					//(利用者名/グループ名 が(ログイン または ログアウト)しました。\n送現在信日時)
					var notifyMessage :String = userInfo.userName + "/" + userInfo.groupName + " が" + loginTypeStr + "しました。\n" + StringUtil.formatTime(new Date());
					
					//通知ウインドウにメッセージを表示
					addNotification(notifyTitle, notifyMessage, this.configDto.loginNotifyDuration, this.configDto.loginNotifyWindowTitleTextColor, this.configDto.loginNotifyWindowMessageTextColor, this.configDto.loginNotifyWindowBackgroundColor);
				}
			}
		}
		
		/**
		 * サーバー状態通知受信用のコンシュマーオブジェクトがメッセージを受信した場合のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onServerConditionNotifyReceive(event: MessageEvent) :void 
		{
			//メッセージヘッダに設定されたメッセージタイプを取得
			var messageType :String = event.message.headers.messageType;
			
			//サーバーからプッシュされたメッセージの場合
			if(messageType == "serverPush")
			{
				//メッセージヘッダに設定されたサーバー状態を取得
				var serverCondition :String = event.message.headers.serverCondition;
				
				//サーバー状態が「stop」(停止)の場合
				if(serverCondition == "stop")
				{
					//エラーメッセージ表示画面のウインドウを開く
					openErrorWindow("サーバーを再起動します。\n\nしばらく時間がたってから、アプリケーションを起動しなおして下さい。");
				}
			}
		}
		
		/**
		 * 「メッセージ作成ウインドウを開く」メニューが選択された場合のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onMessageCreateWindowOpenMenuItemSelect(event: Event = null) :void 
		{
			//メッセージ作成画面のウインドウを開く
			openMessageCreateWindow();
		}
		
		/**
		 * 「全てのウインドウを前に」メニューが選択された場合のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onAllWindowOpenMenuItemSelect(event: Event = null) :void 
		{
			//全てのウインドウをアクティブ化する
			WindowUtil.activateAllWindow();
			
			//全ての手つかずのメッセージ表示画面のウインドウを開く
			openAllUntouchedMessageWindow();
		}
		
		/**
		 * 「全てのウインドウを閉じる」メニューが選択された場合のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onAllWindowCloseMenuItemSelect(event: Event = null) :void 
		{
			//全てのウインドウを閉じる
			WindowUtil.closeAllWindow();
		}
		
		/**
		 * 「設定...」メニューが選択された場合のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onConfigMenuItemSelect(event: Event = null) :void 
		{
			//設定画面のウインドウを開く
			openConfigWindow();
		}
		
		/**
		 * 「バージョン情報」メニューが選択された場合のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onVersionMenuItemSelect(event: Event = null) :void 
		{
			//バージョンタブを最初に表示する設定で、設定画面のウインドウを開く
			openConfigWindow(true);
		}
		
		/**
		 * 「ログ参照」メニューが選択された場合のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onLogViewMenuItemSelect(event: Event = null) :void 
		{
			//ログ参照画面のウインドウを開く
			openLogWindow();
		}
		
		/**
		 * 「終了」メニューが選択された場合のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onExitMenuItemSelect(event: Event = null) :void 
		{
			//ログアウト処理を行う
			logout();
		}
		
		/**
		 * 通知ウインドウがクリックされた場合のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onNotificationClick(event: Event = null) :void 
		{
			//通知ウインドウクリック時の動作設定が、全ての通知をまとめて閉じるようになっている場合
			if(this.configDto.notifyWindowClickOperation == ForesMessengerConstant.NOTIFY_WINDOW_CLICK_OPERATION_ALL_CLOSE)
			{
				//全ての通知をクリアする
				this._purr.clear(AbstractNotification.BOTTOM_RIGHT);
			}
			
			//全ての手つかずのメッセージ表示画面のウインドウを開く
			openAllUntouchedMessageWindow();
		}
		
		/**
		 * トレイアイコンがクリックされた場合のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onTrayIconClick(event: Event = null) :void 
		{
			//Alert.show("トレイアイコンがクリックされました。");
			
			//手つかずのメッセージの配列がnullまたは空配列の場合
			if(ArrayUtil.isBlank(this._untouchedMessageArray))
			{
				//Windowsの場合
				if(TrayIconUtil.isWindows())
				{
					//==========================================================
					//ダブルクリックの場合のみ反応するようにする
					//(AIRではトレイアイコンのダブルクリックイベントが用意されていないので、自分で実装する)
					
					//現在時間を取得
					//(1970 年 1 月 1 日 0 時（世界時）からのミリ秒数)
					var currentTime :Number = new Date().time;
				
					//現在時間からトレイアイコンを前回クリックした時間をひいた値が、ダブルクリックとみなす間隔よりも短い場合
					if((currentTime - this._trayIconClickTime) < ForesMessengerConstant.DOUBLE_CLICK_DURATION)
					{
						//メッセージ作成画面のウインドウを開く
						openMessageCreateWindow();
	
						//トレイアイコンを前回クリックした時間を0に戻す
						this._trayIconClickTime = 0;
					}
					//それ以外の場合
					else
					{
						//トレイアイコンを前回クリックした時間を更新する
						this._trayIconClickTime = currentTime;
					}
				}
				//それ以外のOSの場合
				//(おそらくMac)
				else
				{
					//==========================================================
					//ドックアイコンはダブルクリックできないので、シングルクリックで反応するようにする

					//メッセージ作成画面のウインドウを開く
					openMessageCreateWindow();
				}
			}
			//それ以外の場合
			else
			{
				//==========================================================
				//こちらはシングルクリックで反応するようにするので、特別な制御はかけない
				
				//全ての手つかずのメッセージ表示画面のウインドウを開く
				openAllUntouchedMessageWindow();
			}
		}
		
		/**
		 * 通信系のエラーが発生した場合のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onNetworkError(event: Event = null) :void 
		{
			//エラーメッセージ表示画面のウインドウを開く
			openErrorWindow("通信エラーが発生しました。\n\nアプリケーションを終了します。");
		}

		/**
		 * S2Flex2用のサービスでネットワークステータスが変化した場合のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onS2FlexServiceNetStaus(event: NetStatusEvent) :void 
		{
			//エラー系のイベントの場合
			if((event.info != null) && (event.info.level == "error"))
			{
				//通信系のエラーが発生した場合のイベント処理を行う
				onNetworkError();
			}
		}
		
		/**
		 * アプリケーション終了直前に発生するイベントが発生した場合のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onApplicationExiting(event :Event) :void
		{
			//デフォルトのイベント処理を行わないようにする
			event.preventDefault();
			
			//ログアウト処理を行う
			logout();
		}

		/**
		 * アプリケーションが起動された場合に発生するイベントが発生した場合のイベント処理を行います。
		 * 
		 * @param event イベントオブジェクト
		 */
		private function onApplicationInvoke(event :Event) :void
		{
			//アプリケーションの起動回数を1増やす
			this.invokeCount++;
			
			//初回起動以外の場合
			//(２重起動しようとした場合)
			if(this.invokeCount != 1)
			{
				//Windowsの場合
				if(TrayIconUtil.isWindows())
				{
					//アプリケーション名を取得
					var applicationName :String = new AIRRemoteUpdater().localApplicationName;
					
					//警告メッセージ表示画面のウインドウを開く
					//(メッセージにはアプリケーション名を含める)
					openWarningWindow(applicationName + "はすでに起動しています。");
				}
				//それ以外のOSの場合
				//(おそらくMac)
				else
				{
					//ログイン中の場合
					if(this.isLogin)
					{
						//トレイアイコンがクリックされた場合と同じ処理を行う
						onTrayIconClick();
					}
				}
				
			}
		}
	}
	
	
}

//==========================================================
//Singletonにするためのダミーのプライベートクラス
class PrivateClass
{
	//特に何も行わない
}
		
