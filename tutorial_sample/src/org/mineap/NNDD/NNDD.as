/**
 * NNDD.as
 * ニコニコ動画からのダウンロードを処理およびその他のGUI関連処理を行う。
 * 
 * Copyright (c) 2008-2009 MAP - MineApplicationProject. All Rights Reserved.
 * 
 */

import flash.data.EncryptedLocalStore;
import flash.desktop.Clipboard;
import flash.desktop.ClipboardFormats;
import flash.desktop.NativeApplication;
import flash.errors.EOFError;
import flash.events.ContextMenuEvent;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.IOErrorEvent;
import flash.events.InvokeEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.geom.Rectangle;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLVariables;
import flash.net.navigateToURL;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;
import flash.ui.Keyboard;
import flash.utils.ByteArray;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.containers.Canvas;
import mx.controls.Alert;
import mx.controls.CheckBox;
import mx.controls.DataGrid;
import mx.controls.FileSystemEnumerationMode;
import mx.controls.TextInput;
import mx.controls.TileList;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.controls.dataGridClasses.DataGridItemRenderer;
import mx.core.Application;
import mx.core.IUIComponent;
import mx.events.AIREvent;
import mx.events.CloseEvent;
import mx.events.DragEvent;
import mx.events.FlexEvent;
import mx.events.FlexNativeWindowBoundsEvent;
import mx.events.ListEvent;
import mx.events.ResizeEvent;
import mx.events.SliderEvent;
import mx.managers.DragManager;
import mx.managers.PopUpManager;

import org.mineap.NNDD.Access2Nico;
import org.mineap.NNDD.DownloadedListManager;
import org.mineap.NNDD.LibraryManager;
import org.mineap.NNDD.LogManager;
import org.mineap.NNDD.Message;
import org.mineap.NNDD.NNDDMyListLoader;
import org.mineap.NNDD.PlayListManager;
import org.mineap.NNDD.PlayerController;
import org.mineap.NNDD.RenewDownloadManager;
import org.mineap.NNDD.SystemTrayIconManager;
import org.mineap.NNDD.downloadManager.DownloadManager;
import org.mineap.NNDD.downloadManager.ScheduleManager;
import org.mineap.NNDD.historyManager.HistoryManager;
import org.mineap.NNDD.model.NNDDVideo;
import org.mineap.NNDD.model.Schedule;
import org.mineap.NNDD.model.SearchItem;
import org.mineap.NNDD.model.SearchSortType;
import org.mineap.NNDD.model.SearchType;
import org.mineap.NNDD.myList.MyListBuilder;
import org.mineap.NNDD.myList.MyListManager;
import org.mineap.NNDD.searchItemManager.SearchItemManager;
import org.mineap.NNDD.util.PathMaker;
import org.mineap.NNDD.view.LoadingPicture;
import org.mineap.a2n4as.Login;
import org.mineap.a2n4as.RankingLoader;
import org.mineap.a2n4as.model.RankingItem;
import org.mineap.a2n4as.util.RankingAnalyzer;

private var nndd:NNDD;
private var downloadedListManager:DownloadedListManager;
private var playListManager:PlayListManager;
private var libraryManager:LibraryManager;
private var playerController:PlayerController;
private var logManager:LogManager;
private var loading:LoadingPicture;
private var downloadManager:DownloadManager;
private var scheduleManager:ScheduleManager;
private var historyManager:HistoryManager;

private var renewDownloadManager:RenewDownloadManager;
private var a2nForRanking:Access2Nico;
private var a2nForSearch:Access2Nico;

private var _nnddMyListLoader:NNDDMyListLoader;
private var _myListManager:MyListManager;
private var _searchItemManager:SearchItemManager;

private var loginDialog:LoginDialog;
private var updateDialog:UpdateDialog;
private var loadingWindow:LoadWindow;

private var libraryFile:File;
private var selectedLibraryFile:File;

private var playingVideoPath:String;

public static const RANKING_AND_SERACH_TAB_NUM:int = 0;
public static const SEARCH_TAB_NUM:int = 1
public static const MYLIST_TAB_NUM:int = 2;
public static const DOWNLOAD_LIST_TAB_NUM:int = 3;
public static const LIBRARY_LIST_TAB_NUM:int = 4;
public static const HISTORY_LIST_TAB_NUM:int = 5;
public static const OPTION_TAB_NUM:int = 6;

public var version:String = "";

public static const RANKING_MENU_ITEM_LABEL_PLAY:String = "DL済の動画を再生";
public static const RANKING_MENU_ITEM_LABEL_STREAMING_PLAY:String = "ストリーミング再生";
public static const RANKING_MENU_ITEM_LABEL_ADD_DL_LIST:String = "DLリストに追加";
public static const DOWNLOADED_MENU_ITEM_LABEL_DELETE:String = "動画を削除";
public static const DOWNLOADED_MENU_ITEM_LABEL_PLAY:String = "動画を再生";
public static const DOWNLOADED_MENU_ITEM_LABEL_PLAY_BY_QUEUE:String = "動画を再生";
public static const DOWNLOADED_MENU_ITEM_LABEL_DELETE_BY_QUEUE:String = "動画をリストから削除";
public static const DOWNLOADED_MENU_ITEM_LABEL_EDIT:String = "動画を編集";
public static const TAB_LIST_MENU_ITEM_LABEL_SEARCH:String = "タグをニコニコで検索";
public static const COPY_URL:String = "URLをコピー";
public static const ADD_PLAYER_PLAYLIST_AND_PLAY:String = "一覧を連続再生";

private var MAILADDRESS:String = "";
private var PASSWORD:String = "";

private var logString:String = "";

//private var urlList:Array = new Array();
private var categoryList:Array = new Array();
private var tagsArray:ArrayCollection = new ArrayCollection();
private var rankingPageLinkList:Array = new Array();
private var searchPageLinkList:Array = new Array();

private var isVersionCheckEnable:Boolean = true;

private var isFirstTimePlayerActiveEvent:Boolean = true;

private var isRankingRenewAtStart:Boolean = false;

private var rankingPageIndex:int = 0;
private var searchPageIndex:int = 0;

private var rankingMenu:ContextMenu;
private var rankingMenuitem:ContextMenuItem;
private var rankingMenuitem2:ContextMenuItem;
private var rankingMenuitem3:ContextMenuItem;
private var searchMenu:ContextMenu;
private var searchMenuitem:ContextMenuItem;
private var searchMenuitem2:ContextMenuItem;
private var searchMenuitem3:ContextMenuItem;
private var downloadedMenu:ContextMenu;
private var downloadedMenuitem1:ContextMenuItem;
private var downloadedMenuitem2:ContextMenuItem;
private var downloadedMenuitem3:ContextMenuItem;
private var downloadMenu:ContextMenu;
private var downloadMenuitem1:ContextMenuItem;
private var downloadMenuitem2:ContextMenuItem;
private var myListMenu:ContextMenu;
private var myListMenuItem1:ContextMenuItem;
private var myListMenuItem2:ContextMenuItem;
private var myListMenuItem3:ContextMenuItem;
private var tabTileListMenu:ContextMenu;
private var tabTileListMenuItem1:ContextMenuItem;
private var historyMenu:ContextMenu;
private var historyPlay:ContextMenuItem;
private var historyDownload:ContextMenuItem;
private var historyDelete:ContextMenuItem;

private var copyUrlMenuItem:ContextMenuItem;
private var playAllMenuItem:ContextMenuItem;

private var lastRect:Rectangle = new Rectangle();
private var lastCanvasPlaylistHight:int = -1;
private var lastCanvasTagTileListHight:int = -1;

private var isArgumentBoot:Boolean = false;
private var argumentURL:String = "";

private var isAutoLogin:Boolean = false;

private var isSayHappyNewYear:Boolean = false;

private var isAutoDownload:Boolean = true;

private var isRankingWatching:Boolean = true;

private var isEnableEcoCheck:Boolean = true;

private var isShowOnlyNowLibraryTag:Boolean = true;

private var isOutStreamingPlayerUse:Boolean = false;

private var isDoubleClickOnStreaming:Boolean = false;

private var libraryDataGridSortFieldName:String = "";

private var libraryDataGridSortDescending:Boolean = false;

private var isEnableLibrary:Boolean = true;

private var isCtrlKeyPush:Boolean = false;

private var isAddedDefSearchItems:Boolean = false;

private var _exitProcessCompleted:Boolean = false;

private var isAlwaysEconomy:Boolean = false;

private var isDisEnableAutoExit:Boolean = false;

private var isReNameOldComment:Boolean = false;

private var period:int = 0;
private var target:int = 0;

private var lastTagWidth:int = -1;

private var lastCategoryListWidth:int = -1;
private var lastMyListSummaryWidth:int = -1;
private var lastMyListHeight:int = -1;
private var lastLibraryWidth:int = -1;
private var lastSearchItemListWidth:int = -1;

private var thumbImgSizeForSearch:Number = -1;
private var thumbImgSizeForMyList:Number = -1;

[Bindable]
private var rankingProvider:ArrayCollection = new ArrayCollection();
[Bindalbe]
private var searchProvider:ArrayCollection = new ArrayCollection();
[Bindable]
private var downloadedProvider:ArrayCollection = new ArrayCollection();
[Bindable]
private var fileSystemProvider:ArrayCollection = new ArrayCollection();
[Bindable]
private var categoryListProvider:Array = new Array();
[Bindable]
private var searchSortListProvider:Array = SearchSortType.NICO_SEARCH_SORT_TEXT;
[Bindable]
private var myListItemProvider:ArrayCollection = new ArrayCollection();
[Bindable]
private var myListProvider:Array = new Array();
[Bindable]
private var rankingPageCountProvider:Array = new Array();
[Bindalbe]
private var searchListProvider:Array = new Array();
[Bindable]
private var searchPageCountProvider:Array = new Array();
[Bindable]
private var serchTypeProvider:Array = SearchType.NICO_SEARCH_TYPE_TEXT;
[Bindable]
private var playListProvider:Array = new Array();
[Bindable]
private var downloadProvider:ArrayCollection = new ArrayCollection();
[Bindable]
private var tagProvider:Array = new Array();
[Bindalbe]
private var historyProvider:ArrayCollection = new ArrayCollection();

/**
 * イニシャライザです。<br>
 * 当クラスのインスタンスを使って、以下のクラスを初期化します。<br>
 * ・LoginDialogクラスのオブジェクト<br>
 * ・PlayerControllerクラスのオブジェクト<br>
 * ・DownloadedListManagerクラスのオブジェクト<br>
 * @param nndd
 * 
 */
public function initNNDD(nndd:NNDD):void
{
	
	/*クラスインスタンスの初期化*/
	this.nndd = nndd;
	
	var appXML:XML = NativeApplication.nativeApplication.applicationDescriptor;
	var air:Namespace = appXML.namespaceDeclarations()[0];
	this.version = appXML.air::version;
	this.version = this.version.substring(1);
	
	NativeApplication.nativeApplication.addEventListener(Event.EXITING, exitingEventHandler);
	
	/* ロガー */
	LogManager.initialize(textArea_log);
	logManager = LogManager.getInstance();
	
	/* ストアの内容をまとめて呼び出し */
	readStore();
	
	/* ウィンドウを一番手前に持ってくる処理 */
	if(playerController == null || !playerController.isOpen()){
		this.playerController = new PlayerController(logManager, MAILADDRESS, PASSWORD, libraryFile, libraryManager, playListManager);
	}
	
	/* バージョンチェック */
	versionCheck(false);
	
//	var startDate:Date = new Date(2009, 0, 1);
//	var lastDate:Date = new Date(2009, 0, 4);
//	var nowDate:Date = new Date();
//	if(nowDate.getTime() > startDate.getTime() && nowDate.getTime() < lastDate.getTime() && !isSayHappyNewYear){
//		Alert.show("あけましておめでとうございます！\n新年も皆様がニコニコできますように！");
//		isSayHappyNewYear = true;
//	}
	
	/* コンテキストメニューを追加 */
	//ランキング
	rankingMenu = new ContextMenu();
	rankingMenuitem = new ContextMenuItem(RANKING_MENU_ITEM_LABEL_PLAY);
	rankingMenuitem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, rankingItemHandler);
	rankingMenuitem2 = new ContextMenuItem(RANKING_MENU_ITEM_LABEL_STREAMING_PLAY);
	rankingMenuitem2.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, rankingItemHandler);
	rankingMenuitem3 = new ContextMenuItem(RANKING_MENU_ITEM_LABEL_ADD_DL_LIST);
	rankingMenuitem3.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, rankingItemHandler);
	copyUrlMenuItem = new ContextMenuItem(COPY_URL);
	copyUrlMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, copyUrl);
	playAllMenuItem = new ContextMenuItem(ADD_PLAYER_PLAYLIST_AND_PLAY);
	playAllMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, playAllMenuItemHandler);
	rankingMenu.customItems.push(rankingMenuitem, rankingMenuitem2, rankingMenuitem3, copyUrlMenuItem, playAllMenuItem);
	rankingMenu.addEventListener(ContextMenuEvent.MENU_SELECT, contextMenuSelectHandler);
	dataGrid_ranking.contextMenu = rankingMenu;
	
	//検索
	searchMenu = new ContextMenu();
	searchMenuitem = new ContextMenuItem(RANKING_MENU_ITEM_LABEL_PLAY);
	searchMenuitem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, searchItemHandler);
	searchMenuitem2 = new ContextMenuItem(RANKING_MENU_ITEM_LABEL_STREAMING_PLAY);
	searchMenuitem2.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, searchItemHandler);
	searchMenuitem3 = new ContextMenuItem(RANKING_MENU_ITEM_LABEL_ADD_DL_LIST);
	searchMenuitem3.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, searchItemHandler);
	copyUrlMenuItem = new ContextMenuItem(COPY_URL);
	copyUrlMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, copyUrl);
	playAllMenuItem = new ContextMenuItem(ADD_PLAYER_PLAYLIST_AND_PLAY);
	playAllMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, playAllMenuItemHandler);
	searchMenu.addEventListener(ContextMenuEvent.MENU_SELECT, contextMenuSelectHandler);
	searchMenu.customItems.push(searchMenuitem, searchMenuitem2, searchMenuitem3, copyUrlMenuItem, playAllMenuItem);
	
	canvas_search.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:FlexEvent):void{
		dataGrid_search.contextMenu = searchMenu;
	});
	
	//ライブラリ
	downloadedMenu = new ContextMenu();
	downloadedMenuitem1 = new ContextMenuItem(DOWNLOADED_MENU_ITEM_LABEL_PLAY);
	downloadedMenuitem1.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,downloadedItemHandler);
	downloadedMenu.customItems.push(downloadedMenuitem1);
	downloadedMenuitem2 = new ContextMenuItem(DOWNLOADED_MENU_ITEM_LABEL_DELETE);
	downloadedMenuitem2.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,downloadedItemHandler);
	downloadedMenu.customItems.push(downloadedMenuitem2);
	downloadedMenuitem3 = new ContextMenuItem(DOWNLOADED_MENU_ITEM_LABEL_EDIT);
	downloadedMenuitem3.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,downloadedItemHandler);
	downloadedMenu.customItems.push(downloadedMenuitem3);
	downloadedMenu.addEventListener(ContextMenuEvent.MENU_SELECT, contextMenuSelectHandler);
	
	//タグ
	tabTileListMenu = new ContextMenu();
	tabTileListMenuItem1 = new ContextMenuItem(TAB_LIST_MENU_ITEM_LABEL_SEARCH);
	tabTileListMenuItem1.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,tagListItemHandler);
	
	canvas_library.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:FlexEvent):void{
		dataGrid_downloaded.contextMenu = downloadedMenu;
		tileList_tag.contextMenu = tabTileListMenu;
	});
	
	//ダウンロードリスト
	downloadMenu = new ContextMenu();
	downloadMenuitem1 = new ContextMenuItem(DOWNLOADED_MENU_ITEM_LABEL_PLAY_BY_QUEUE);
	downloadMenuitem1.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,queueItemHandler);
	downloadMenu.customItems.push(downloadMenuitem1);
	downloadMenuitem2 = new ContextMenuItem(DOWNLOADED_MENU_ITEM_LABEL_DELETE_BY_QUEUE);
	downloadMenuitem2.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,queueItemHandler);
	downloadMenu.customItems.push(downloadMenuitem2);
	copyUrlMenuItem = new ContextMenuItem(COPY_URL);
	copyUrlMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, copyUrl);
	downloadMenu.customItems.push(copyUrlMenuItem);
	downloadMenu.addEventListener(ContextMenuEvent.MENU_SELECT, contextMenuSelectHandler);
	canvas_queue.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:FlexEvent):void{
		dataGrid_downloadList.contextMenu = downloadMenu;
	});
	
	//マイリスト
	myListMenu = new ContextMenu();
	myListMenuItem1 = new ContextMenuItem(RANKING_MENU_ITEM_LABEL_PLAY);
	myListMenuItem1.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, myListItemHandler);
	myListMenuItem2 = new ContextMenuItem(RANKING_MENU_ITEM_LABEL_STREAMING_PLAY);
	myListMenuItem2.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, myListItemHandler);
	myListMenuItem3 = new ContextMenuItem(RANKING_MENU_ITEM_LABEL_ADD_DL_LIST);
	myListMenuItem3.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, myListItemHandler);
	copyUrlMenuItem = new ContextMenuItem(COPY_URL);
	copyUrlMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, copyUrl);
	playAllMenuItem = new ContextMenuItem(ADD_PLAYER_PLAYLIST_AND_PLAY);
	playAllMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, playAllMenuItemHandler);
	myListMenu.customItems.push(myListMenuItem1, myListMenuItem2, myListMenuItem3, copyUrlMenuItem, playAllMenuItem);
	myListMenu.addEventListener(ContextMenuEvent.MENU_SELECT, contextMenuSelectHandler);
	
	canvas_myList.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:FlexEvent):void{
		dataGrid_myList.contextMenu = myListMenu;
	});
	
	//履歴
	historyMenu = new ContextMenu();
	historyPlay = new ContextMenuItem(DOWNLOADED_MENU_ITEM_LABEL_PLAY);
	historyPlay.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, historyItemHandler);
	historyDownload = new ContextMenuItem(RANKING_MENU_ITEM_LABEL_ADD_DL_LIST);
	historyDownload.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, historyItemHandler);
	historyDelete = new ContextMenuItem(DOWNLOADED_MENU_ITEM_LABEL_DELETE_BY_QUEUE)
	historyDelete.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, historyItemHandler);
	copyUrlMenuItem = new ContextMenuItem(COPY_URL);
	copyUrlMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, copyUrl);
	historyMenu.customItems.push(historyPlay, historyDownload, historyDelete, copyUrlMenuItem);
	historyMenu.addEventListener(ContextMenuEvent.MENU_SELECT, contextMenuSelectHandler);
	
	canvas_history.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:FlexEvent):void{
		dataGrid_history.contextMenu = historyMenu;
	});
	
	/* プレイリスト読み込み */
	canvas_library.addEventListener(FlexEvent.CREATION_COMPLETE, function():void{
		playListManager.addEventListener(PlayListManager.PLAYLIST_UPDATE, function():void{
//			trace(playListProvider);
			list_playList.dataProvider = playListProvider;
		});
	});
	
	/* ライブラリマネージャー生成 */
//	this.libraryManager = new LibraryManager(nndd, tagProvider, logManager);
	LibraryManager.initialize(nndd, tagProvider);
	this.libraryManager = LibraryManager.getInstance();
	this.libraryManager.changeLibraryDir(libraryFile, false);
	
	//システムディレクトリにライブラリファイルがあればそっちを取りに行く
	var libFile:File = LibraryManager.getInstance().systemFileDir;
	libFile.url = libFile.url + "/" + LibraryManager.LIBRARY_FILE_NAME;
	if(libFile.exists){
		/* ライブラリ読み込み後、タグの設定 */
		this.libraryManager.loadLibraryFile(LibraryManager.getInstance().systemFileDir, LibraryManager.getInstance().libraryDir, true);
	}else{
		//ないなら古い方を探してみる
		this.libraryManager.loadLibraryFile(LibraryManager.getInstance().libraryDir, LibraryManager.getInstance().libraryDir, true);
	}
	
	/* ダウンロード済リストマネージャー */
	this.downloadedListManager = new DownloadedListManager(viewStack, fileSystemProvider, downloadedProvider);
	
	/* プレイリストマネージャー */
	this.playListManager = new PlayListManager(libraryManager, playListProvider, downloadedProvider, logManager, this.dataGrid_downloaded);
	
	/* マイリストマネージャー */
	this._myListManager = new MyListManager(libraryManager, myListProvider, logManager);
	var isSuccess:Boolean = this._myListManager.readMyListSummary(libraryManager.systemFileDir);
	if(!isSuccess){
		this._myListManager.readMyListSummary(libraryFile);
	}
	
	/* マイリスト読み込み */
	canvas_myList.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:Event):void{
		tree_myList.dataProvider = myListProvider;
	});
	
	/* 検索条件マネージャー */
	this._searchItemManager = new SearchItemManager(libraryManager, searchListProvider, logManager);
	isSuccess = this._searchItemManager.readSearchItems(libraryManager.systemFileDir);
	if(!isSuccess){
		this._searchItemManager.readSearchItems(libraryFile);
	}
	if(!isAddedDefSearchItems){
		this._searchItemManager.addDefSearchItems();
		isAddedDefSearchItems = true;
	}
	
	/* ファイルシステムツリーのトップレベルを開いておく */
	this.canvas_library.addEventListener(FlexEvent.CREATION_COMPLETE, function():void{
		tree_FileSystem.openSubdirectory(libraryFile.nativePath);
	});
	
	/* ダウンロードマネージャ */
	this.downloadManager = new DownloadManager(downloadProvider, downloadedListManager, MAILADDRESS, PASSWORD, libraryManager, canvas_queue, 
		rankingProvider, searchProvider, myListItemProvider, logManager);
	this.downloadManager.isAlwaysEconomy = this.isAlwaysEconomy;
	this.downloadManager.isReNameOldComment = this.isReNameOldComment;
	
	/* 履歴管理 */
	HistoryManager.initialize(historyProvider);
	this.historyManager = HistoryManager.getInstance();
	this.historyManager.loadHistory();
	
	var menu:NativeMenu = this.nativeApplication.menu;
	if(menu != null){
		var menuItem:NativeMenuItem = menu.items[2];
		var isExists:Boolean = false;
		if(menuItem != null){
			menuItem = menuItem.submenu.items[2];
			if(menuItem != null){
				//Macの時はショートカットを使う
				isExists = true;
			}
		}
	}
	if(isExists){
		menuItem.addEventListener(Event.SELECT, queueMenuHandler);
	}else{
		//WindowsとLinuxの時は自分で追加
		this.addEventListener(AIREvent.WINDOW_COMPLETE, function(event:Event):void{
			stage.addEventListener(KeyboardEvent.KEY_UP, queueKeyUpHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, queueKeyDownHandler);
		});
	}
	
	this.addEventListener(AIREvent.WINDOW_COMPLETE, function(event:Event):void{
		//初回自動ランキング更新
		if(isRankingRenewAtStart){
			rankingRenewButtonClicked();
		}
		
		
		if(lastCategoryListWidth != -1){
  			list_categoryList.width = lastCategoryListWidth;
  		}else{
  			lastCategoryListWidth = list_categoryList.width;
  		}
		
	});
	
	/* タスクトレイ or Dockの設定 */
	var trayIconManager:SystemTrayIconManager = new SystemTrayIconManager();
	trayIconManager.setTrayIcon();
	
}

public function versionCheck(byConfig:Boolean):void{
	
	logManager.addLog("バージョン情報\nNNDDバージョン:" + version );
	
	/* バージョンチェック */
	if(this.isVersionCheckEnable){
		
		var version:String = this.version;
		
		if(byConfig){
			
			// ログインダイアログの作成
			updateDialog = PopUpManager.createPopUp(nndd, UpdateDialog, true) as UpdateDialog;
			updateDialog.addEventListener(UpdateDialog.UPDATE_DIALOG_CLOSE, function():void{
				PopUpManager.removePopUp(updateDialog);
			});
			// ダイアログを中央に表示
			PopUpManager.centerPopUp(updateDialog);
			
			updateDialog.label_info.text = "新しいバージョンのNNDDが公開されていないか確認しています。";
			updateDialog.label_newerVersion.text = "確認中...";
			
		}
		
		try{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, function():void{
				var pattern:RegExp = new RegExp(">NNDD version v(.*)<", "ig");
				var array:Array = pattern.exec(loader.data);
//				trace(loader.data);
				try{
					if((array[array.length-1] as String).indexOf(version) == -1 || array[array.length-1].length != version.length){
						if(!byConfig){
							// ログインダイアログの作成
							updateDialog = PopUpManager.createPopUp(nndd, UpdateDialog, true) as UpdateDialog;
							updateDialog.addEventListener(UpdateDialog.UPDATE_DIALOG_CLOSE, function():void{
								PopUpManager.removePopUp(updateDialog);
							});
							// ダイアログを中央に表示
							PopUpManager.centerPopUp(updateDialog);
						}
						updateDialog.label_info.text = "新しいバージョンのNNDDが公開されています。";
						updateDialog.label_newerVersion.text = "最新版は" + array[array.length-1] + "です。";
						
						logManager.addLog("新しいバージョンのNNDDが公開されています。\n最新版は " + array[array.length-1]+ " です。\nhttp://d.hatena.ne.jp/MineAP/20080730/1217412550");
					}else{
						if(byConfig){
							updateDialog.label_info.text = "このNNDDは最新です。";
							updateDialog.label_newerVersion.text = "バージョン:" + version;
						}
						logManager.addLog("バージョンチェック:このNNDDは最新です。(" + version + ")");
					}
				}catch(error:Error){
					logManager.addLog("バージョンチェック:失敗\n"+error.getStackTrace());
				}
				
				try{
					loader.close();
				}catch(error:Error){
					trace(error.getStackTrace());
				}
				
			});
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(event:Event):void{
				try{
					loader.close();
				}catch(error:Error){
					trace(error.getStackTrace());
				}
				logManager.addLog("バージョンチェック:失敗\n"+event);
			});
			loader.load(new URLRequest("http://web.me.com/shiraminekeisuke/Site/version.html"));
		}catch(error:Error){
			logManager.addLog("バージョンチェック:失敗\n"+error.getStackTrace());
		}
	}
}

/**
 * コンテキストメニュー選択時のイベントハンドラ
 * @param event
 * 
 */
private function contextMenuSelectHandler(event:ContextMenuEvent):void{
	var dataGrid:DataGrid = DataGrid(event.contextMenuOwner);
	if(dataGrid != null && dataGrid.dataProvider.length > 0){
		if(event.mouseTarget is DataGridItemRenderer){
			if((event.mouseTarget as DataGridItemRenderer).data != null){
				var newSelectedItem:Object = (event.mouseTarget as DataGridItemRenderer).data;
				if(newSelectedItem is DataGridColumn){
					return;
				}
				if(dataGrid.selectedIndices.length > 1){
					//複数選択中
					var selectedItems:Array = dataGrid.selectedItems;
					
					var isExist:Boolean = false;
					for each(var item:Object in selectedItems){
						if(item == newSelectedItem){
							isExist = true;
							break;
						}
					}
					
					if(!isExist){
						selectedItems.push(newSelectedItem);
					}
					dataGrid.selectedItems = selectedItems;
				}else{
					//選択の変更
					dataGrid.selectedItem = newSelectedItem;
				}
			}
			
		}
	}
}


/**
 * 「URLをコピー」のコンテキストメニューアイテム用イベントハンドラ
 * @param event
 * 
 */
private function copyUrl(event:ContextMenuEvent):void{
	var dataGrid:DataGrid = DataGrid(event.contextMenuOwner);
	if(dataGrid != null && dataGrid.dataProvider.length > 0){
		if(event.mouseTarget is DataGridItemRenderer && (event.mouseTarget as DataGridItemRenderer).data != null){
			var url:String = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_nicoVideoUrl;
			if(url == null || url == "" || url == "undefined"){
				url = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_videoUrl;
			}
			if(url == null || url == "" || url == "undefined"){
				url = (event.mouseTarget as DataGridItemRenderer).data.col_videoUrl;
			}
			if(url == null || url == "" || url == "undefined"){
				url = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_videoName;
				url = "http://www.nicovideo.jp/watch/" + PathMaker.getVideoID(url);
			}
			
			if(url.indexOf("http://") != -1){
				Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, url);
			}
			
		}
	}
}

/**
 * ランキングのデータグリッドコンテキストメニュー用イベントハンドラ
 * @param event
 * 
 */
private function rankingItemHandler(event:ContextMenuEvent):void{
	var dataGrid:DataGrid = DataGrid(event.contextMenuOwner);
	if(dataGrid != null && dataGrid.dataProvider.length > 0){
		if(event.mouseTarget is DataGridItemRenderer && (event.mouseTarget as DataGridItemRenderer).data != null){
			var videoPath:String = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_videoPath;
			if(videoPath == null || videoPath == ""){
				videoPath = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_nicoVideoUrl;
			}
			if(videoPath != null && videoPath != ""){
				if((event.target as ContextMenuItem).label == RANKING_MENU_ITEM_LABEL_PLAY){
					this.playingVideoPath = videoPath;
					this.textInput_mUrl.text = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_nicoVideoUrl;
					playMovie(this.playingVideoPath, -1);
				}else if((event.target as ContextMenuItem).label == RANKING_MENU_ITEM_LABEL_STREAMING_PLAY){
					this.playingVideoPath = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_nicoVideoUrl;
					this.textInput_mUrl.text = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_nicoVideoUrl;
					this.videoStreamingPlayStartButtonClicked(this.playingVideoPath);
				}else if((event.target as ContextMenuItem).label == RANKING_MENU_ITEM_LABEL_ADD_DL_LIST){
					this.textInput_mUrl.text = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_nicoVideoUrl;
					
					var items:Array = dataGrid.selectedItems;
					var itemIndices:Array = dataGrid.selectedIndices;
					for(var index:int = 0; index<items.length; index++){
						
						var video:NNDDVideo = new NNDDVideo(items[index].dataGridColumn_nicoVideoUrl, items[index].dataGridColumn_videoName);
						addDownloadList(video, itemIndices[index]);
						
					}
				}
			}
		}
	}
}

/**
 * 検索結果のコンテキストメニューハンドラ
 * @param event
 * 
 */
private function searchItemHandler(event:ContextMenuEvent):void{
	var dataGrid:DataGrid = DataGrid(event.contextMenuOwner);
	if(dataGrid != null && dataGrid.dataProvider.length > 0){
		if(event.mouseTarget is DataGridItemRenderer && (event.mouseTarget as DataGridItemRenderer).data != null && (event.mouseTarget as DataGridItemRenderer).data.hasOwnProperty("dataGridColumn_nicoVideoUrl")){
			var videoPath:String = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_videoPath;
			if(videoPath == null || videoPath == ""){
				videoPath = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_nicoVideoUrl;
			}
			if(videoPath != null && videoPath != ""){
				if((event.target as ContextMenuItem).label == RANKING_MENU_ITEM_LABEL_PLAY){
					this.playingVideoPath = videoPath;
					playMovie(this.playingVideoPath, -1);
				}else if((event.target as ContextMenuItem).label == RANKING_MENU_ITEM_LABEL_STREAMING_PLAY){
					this.playingVideoPath = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_nicoVideoUrl;
					this.videoStreamingPlayStartButtonClicked(this.playingVideoPath);
				}else if((event.target as ContextMenuItem).label == RANKING_MENU_ITEM_LABEL_ADD_DL_LIST){
					this.textInput_mUrl.text = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_nicoVideoUrl;
					
					var items:Array = dataGrid.selectedItems;
					var itemIndices:Array = dataGrid.selectedIndices;
					for(var index:int = 0; index<items.length; index++){
						
						var video:NNDDVideo = new NNDDVideo(items[index].dataGridColumn_nicoVideoUrl, items[index].dataGridColumn_videoName);
						addDownloadListForSearch(video, itemIndices[index]);
						
					}
				}
			}
		}
	}
}

/**
 * マイリストのコンテキストメニューイベントハンドラ
 * @param event
 * 
 */
private function myListItemHandler(event:ContextMenuEvent):void{
	var dataGrid:DataGrid = DataGrid(event.contextMenuOwner);
	if(dataGrid != null && dataGrid.dataProvider.length > 0){
		if(event.mouseTarget is DataGridItemRenderer && (event.mouseTarget as DataGridItemRenderer).data != null){
			var videoName:String = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_videoName;
			if((event.target as ContextMenuItem).label == RANKING_MENU_ITEM_LABEL_PLAY){
				var videoLocalPath:String = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_videoLocalPath;
				if(videoLocalPath != null){
					playMovie(videoLocalPath, -1);
				}
			}else if((event.target as ContextMenuItem).label == RANKING_MENU_ITEM_LABEL_STREAMING_PLAY){
				var videoUrl:String = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_videoUrl;
				if(videoUrl != null){
					videoStreamingPlayStartButtonClicked(videoUrl);
				}
			}else if((event.target as ContextMenuItem).label == RANKING_MENU_ITEM_LABEL_ADD_DL_LIST){
				var items:Array = dataGrid.selectedItems;
				var itemIndices:Array = dataGrid.selectedIndices;
				for(var index:int = 0; index<items.length; index++){
					
					var video:NNDDVideo = new NNDDVideo(items[index].dataGridColumn_videoUrl, items[index].dataGridColumn_videoName);
					addDownloadListForMyList(video, itemIndices[index]);
					
				}
			}
		}
	}
}


/**
 * ダウンロードリストのデータグリッドコンテキストメニュー用イベントハンドラ 
 * @param event
 * 
 */
private function queueItemHandler(event:ContextMenuEvent):void{
	var dataGrid:DataGrid = DataGrid(event.contextMenuOwner);
	if(dataGrid != null && dataGrid.dataProvider.length > 0){
		if((event.target as ContextMenuItem).label == DOWNLOADED_MENU_ITEM_LABEL_PLAY_BY_QUEUE){
			if((event.mouseTarget as DataGridItemRenderer).data != null && (event.mouseTarget as DataGridItemRenderer).data.hasOwnProperty("col_downloadedPath")){
				this.playingVideoPath = (event.mouseTarget as DataGridItemRenderer).data.col_downloadedPath;
				if(this.playingVideoPath != null){
					playMovie(this.playingVideoPath, -1);
				}
			}
		}else{
			if(dataGrid_downloadList.selectedIndices.length > 0){
				downloadManager.deleteSelectedItems(dataGrid_downloadList.selectedIndices);
			}
		}
	}
}

/**
 * 
 * @param event
 * 
 */
private function downloadItemHandler(event:ContextMenuEvent):void{
	var dataGrid:DataGrid = DataGrid(event.contextMenuOwner);
	if(dataGrid != null && dataGrid.dataProvider.length > 0){
		if(event.mouseTarget is DataGridItemRenderer && (event.mouseTarget as DataGridItemRenderer).data != null){
			var videoPath:String = (event.mouseTarget as DataGridItemRenderer).data.col_downloadedPath
			if(videoPath != null && videoPath != ""){
				this.playingVideoPath = videoPath;
				playMovie(this.playingVideoPath, -1);		
			}
		}
	}
}

/**
 * ダウンロード済アイテムのデータグリッドコンテキストメニュー用イベントハンドラ
 * @param event
 * 
 */
private function downloadedItemHandler(event:ContextMenuEvent):void {
	var dataGrid:DataGrid = DataGrid(event.contextMenuOwner);
	if(dataGrid != null && dataGrid.dataProvider.length > 0){
		if(event.mouseTarget is DataGridItemRenderer && (event.mouseTarget as DataGridItemRenderer).data != null 
				&& (event.mouseTarget as DataGridItemRenderer).data.hasOwnProperty("dataGridColumn_videoPath")){
			if((event.target as ContextMenuItem).label == DOWNLOADED_MENU_ITEM_LABEL_PLAY){
				if(this.playListManager.isSelectedPlayList){
					this.playMovie((event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_videoPath, 
						dataGrid_downloaded.selectedIndex, (playListManager.getUrlListByIndex(list_playList.selectedIndex) as Array)
						,null, playListManager.getPlayListNameByIndex(list_playList.selectedIndex));
				}else{
					this.playMovie((event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_videoPath, -1);
				}
			}else if((event.target as ContextMenuItem).label == DOWNLOADED_MENU_ITEM_LABEL_DELETE){
				
				//右クリックされた対象のURL
//				var targetVideoPath:String = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_videoPath;
				
				//すでに選択済みのURL
				var indices:Array = dataGrid_downloaded.selectedIndices;
				if(indices.length > 0 && indices[0] > -1){
					var urls:Array = new Array(indices.length);
					var isExist:Boolean = false;
					for(var i:int=indices.length-1; -1 < i; i--){
						urls[i] = this.downloadedListManager.getVideoPath(indices[i]);
//						if(urls[i] == targetVideoPath){
//							isExist = true;
//						}
					}
//					if(!isExist){
//						urls.push(targetVideoPath);
//					}
//					
					deleteVideo(urls,indices);
				}
			}else if((event.target as ContextMenuItem).label == DOWNLOADED_MENU_ITEM_LABEL_EDIT){
				var isExists:Boolean = false;
				
				var url:String = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_videoPath;
				var video:NNDDVideo = this.libraryManager.isExist(LibraryManager.getVideoKey(url));
				
				if(video == null && url.indexOf("http://") == -1){
					//ライブラリ管理出来ていないビデオについては新規追加
					video = libraryManager.loadInfo(url);
					isExists = false;
				}else if(video == null && playListManager.isSelectedPlayList){
					//これはストリーミング用。編集不可。
					Alert.show("この動画はまだダウンロードされていません。先にダウンロードしてください。", Message.M_MESSAGE);
					return;
				}else{
					isExists = true;
				}
				
				var videoEditDialog:VideoEditDialog = PopUpManager.createPopUp(this, VideoEditDialog, true) as VideoEditDialog;
				PopUpManager.centerPopUp(videoEditDialog);
				videoEditDialog.init(video, logManager);
				
				videoEditDialog.addEventListener(Event.COMPLETE, function(event:Event):void{
					try{
						if(videoEditDialog.oldVideo.uri != videoEditDialog.newVideo.uri){
							(new File(videoEditDialog.oldVideo.uri)).moveTo(new File(videoEditDialog.newVideo.uri));
						}
						libraryManager.update(videoEditDialog.newVideo, true);
					}catch(error:IOError){
						Alert.show("ファイル名の変更に失敗しました。" + error, Message.M_ERROR)
						logManager.addLog("ファイル名の変更に失敗:" + error + ":" + error.getStackTrace());
					}
					downloadedListManager.refresh();
					PopUpManager.removePopUp(videoEditDialog);
				});
				videoEditDialog.addEventListener(Event.CANCEL, function(event:Event):void{
					if(isExists == false){
						//新規ビデオの場合はキャンセルでも登録
						libraryManager.add(video, true);
					}
					PopUpManager.removePopUp(videoEditDialog);
				});
			}
		}
	}
}

/**
 * ライブラリタブのタグ表示タイルリストコンテキストメニュー用イベントハンドラ
 * @param event
 * 
 */
private function tagListItemHandler(event:ContextMenuEvent):void {
	if(tileList_tag.selectedIndex > -1){
		if((event.target as ContextMenuItem).label == TAB_LIST_MENU_ITEM_LABEL_SEARCH){
			var tag:String = tileList_tag.dataProvider[tileList_tag.selectedIndex];
		}
	}
}

/**
 * 「連続再生」が選択されたときのイベントハンドラ
 * @param event
 * 
 */
private function playAllMenuItemHandler(event:ContextMenuEvent):void{
	if((event.contextMenuOwner as DataGrid).dataProvider != null){
		var array:ArrayCollection = ((event.contextMenuOwner as DataGrid).dataProvider as ArrayCollection);
		if(array.length > 0){
			
			var playList:Array = new Array();
			var videoNameList:Array = new Array();
			var isMyList:Boolean = false;
			
			if(array[0].hasOwnProperty("dataGridColumn_videoLocalPath")){
				isMyList = true;
			}
			
			for(var i:int = 0; i<array.length; i++){
				
				//ランキング・検索
//				dataGridColumn_videoPath: localURL,
//				dataGridColumn_nicoVideoUrl: urlList[i][0]
				//マイリスト
//				dataGridColumn_videoUrl:videoUrl,
//				dataGridColumn_videoLocalPath:videoLocalPath
				
				var url:String = "";
				if(isMyList){
					url = array[i].dataGridColumn_videoLocalPath;
					if(url == null || url == ""){
						url = array[i].dataGridColumn_videoUrl;
					}
				}else{
					url = array[i].videoPath;
					if(url == null || url == ""){
						url = array[i].dataGridColumn_nicoVideoUrl;
					}
				}
				
				playList.push(url);
				
				var videoName:String = array[i].dataGridColumn_videoName;
				var videoId:String = PathMaker.getVideoID(url);
				if(videoName.indexOf("\n") != -1){
					videoName = videoName.substring(0, videoName.indexOf("\n")) + " - [" + videoId + "]";
				}
				videoNameList.push(videoName);
				
			}
			
			var startIndex:int = (event.contextMenuOwner as DataGrid).selectedIndex;
			
			if(playList.length > 0 && startIndex >= 0 && playList.length > startIndex){
				playMovie(playList[startIndex], startIndex, playList, videoNameList, "");
			}
			
		}
	}
}

/**
 * 起動時に引数が指定されていた場合、その引数を受け取ります。
 * @param event
 * 
 */
private function invokeEventHandler(event:InvokeEvent):void{
	if(event.arguments.length >= 1){
		
		var arguments:String = "";
		for each(var arg:String in event.arguments){
			if(arguments.length != 0){
				arguments = arguments + ",";
			}
			arguments = arguments + arg;
		}
		
		logManager.addLog(Message.INVOKE_ARGUMENT + ":" + arguments);
		
		var arg1:String = event.arguments[0];
		
		try{
			if(arg1.indexOf("-d") != -1){
				var url:String = event.arguments[1];
				var videoId:String = PathMaker.getVideoID(url);
				if(videoId != null){
					url = "http://www.nicovideo.jp/watch/" + videoId;
				}
				
				if(url.match(new RegExp("http://www.nicovideo.jp/watch/")) != null){
					//DLリストに追加
					var video:NNDDVideo = new NNDDVideo(url, "-");
					addDownloadList(video, -1);
				}else{
					//これはニコ動のURL or ビデオIDじゃない
					logManager.addLog(Message.FAIL_ARGUMENT_BOOT + ":argument=[" + arguments + "]\n" + Message.ARGUMENT_FORMAT);
					Alert.show(Message.M_FAIL_ARGUMENT_BOOT + "\n\n" + arguments + "\n" + Message.ARGUMENT_FORMAT, Message.M_ERROR);
				}
			}else if(arg1.indexOf("http://") == -1){
				var file:File = new File(arg1);
				if(file.exists){
//					this.isArgumentBoot = true;
					this.playingVideoPath = decodeURIComponent(file.nativePath);
					playMovie(decodeURIComponent(file.url), -1);
				}
			}else if(arg1.match(new RegExp("http://www.nicovideo.jp/watch/")) != null){
				if(this.textInput_mUrl != null){
					this.textInput_mUrl.text = arg1;
				}
				
				if(MAILADDRESS == ""){
					this.isArgumentBoot = true;
					this.argumentURL = arg1;
				}else{
					this.playingVideoPath = arg1;
					this.videoStreamingPlayStartButtonClicked(arg1);
				}
			}else{
				logManager.addLog(Message.FAIL_ARGUMENT_BOOT + ":argument=[" + arguments + "]\n" + Message.ARGUMENT_FORMAT);
				Alert.show(Message.M_FAIL_ARGUMENT_BOOT + "\n\n" + arguments + "\n" + Message.ARGUMENT_FORMAT, Message.M_ERROR);
			}
		}catch(error:Error){
			logManager.addLog(Message.FAIL_ARGUMENT_BOOT + ":argument=[" + arguments + "]\n" + error.getStackTrace());
			Alert.show(Message.M_FAIL_ARGUMENT_BOOT + "\n\n" + arguments + "\n" + Message.ARGUMENT_FORMAT, Message.M_ERROR);
		}
	}
}

/**
 * ビデオの削除を行います。
 * @param url URIエンコードされていないURLを指定します。
 * @param index データグリッドのインデックスです
 * 
 */
private function deleteVideo(urls:Array, indices:Array):void{
	if(!this.playListManager.isSelectedPlayList){
		var fileNames:String = "";
		for(var j:int=0; indices.length > j; j++){
			fileNames += "・"+ urls[j].substring(urls[j].lastIndexOf("/")+1) + "\n";
		}
		
		if(urls.length > 0){
			Alert.show("次のファイルを削除してもよろしいですか？（コメント・サムネイル情報・ユーザーニコ割も同時に削除されます。）\n\n" + fileNames, 
					Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
				if(event.detail == Alert.YES){
					try{
						for(var i:int=indices.length-1; -1 < i; i--){
							var url:String = urls[i];
							var index:int = i;
							
							//動画を削除
							var movieFile:File = new File(url);
							movieFile.moveToTrash();
//							downloadedProvider.removeItemAt(index);
							logManager.addLog(Message.DELETE_FILE + ":" + movieFile.nativePath);
							
							var nnddVideo:NNDDVideo = libraryManager.remove(LibraryManager.getVideoKey(movieFile.nativePath), true);
							if(nndd == null){
								logManager.addLog("指定された動画はNNDDの管理外です。:" + movieFile.nativePath);
							}
							
							try{
								
								var failURL:String = "";
								
								//通常コメントを削除
								var commentFile:File = new File(PathMaker.createNomalCommentPathByVideoPath(decodeURIComponent(url)));
								failURL = decodeURIComponent(commentFile.url);
								if(commentFile.exists){
									commentFile.moveToTrash();
									logManager.addLog(Message.DELETE_FILE + ":" + commentFile.nativePath);
								}
								
								//投稿者コメントを削除
								var ownerCommentFile:File = new File(PathMaker.createOwnerCommentPathByVideoPath(decodeURIComponent(url)));
								failURL = decodeURIComponent(ownerCommentFile.url);
								if(ownerCommentFile.exists){
									ownerCommentFile.moveToTrash();
									logManager.addLog(Message.DELETE_FILE + ":" + ownerCommentFile.nativePath);
								}
								
								//サムネイル情報を削除
								var thmbInfoFile:File = new File(PathMaker.createThmbInfoPathByVideoPath(decodeURIComponent(url)));
								failURL = decodeURIComponent(thmbInfoFile.url);
								if(thmbInfoFile.exists){
									thmbInfoFile.moveToTrash();
									logManager.addLog(Message.DELETE_FILE + ":" + thmbInfoFile.nativePath);
								}
								
								//市場情報を削除
								var iChibaFile:File = new File(PathMaker.createNicoIchibaInfoPathByVideoPath(decodeURIComponent(url)));
								failURL = decodeURIComponent(iChibaFile.url);
								if(iChibaFile.exists){
									iChibaFile.moveToTrash();
									logManager.addLog(Message.DELETE_FILE + ":" + iChibaFile.nativePath);
								}
								
								//サムネイル画像を削除（あれば）
								var thumbImgFile:File = new File(PathMaker.createThumbImgFilePath(decodeURIComponent(url)));
								failURL = decodeURIComponent(thumbImgFile.url);
								if(thumbImgFile.exists){
									thumbImgFile.moveToTrash();
									logManager.addLog(Message.DELETE_FILE + ":" + thumbImgFile.nativePath);
								}
								
								//ニコ割を削除
								while(true){
									var file:File = new File(PathMaker.createNicowariPathByVideoPathAndNicowariVideoID(decodeURIComponent(url)));
									if(file.exists){
										failURL = decodeURIComponent(file.url);
										file.moveToTrash();
										logManager.addLog(Message.DELETE_FILE + ":" + file.nativePath);
									}else{
										break;
									}
								}
								
							}catch (error:Error){
								Alert.show(Message.M_FAIL_OTHER_DELETE, Message.M_ERROR);
								logManager.addLog(Message.M_FAIL_OTHER_DELETE + ":" + failURL + ":" + error + "\n" + error.getStackTrace());
							}
						}
						
						tree_FileSystem.refresh();
						sourceChanged(tree_FileSystem.selectedIndex);
						
					}catch (error:Error){
						tree_FileSystem.refresh();
						sourceChanged(tree_FileSystem.selectedIndex);
						Alert.show(Message.M_FAIL_VIDEO_DELETE, Message.M_ERROR);
						logManager.addLog(Message.M_FAIL_VIDEO_DELETE + ":" + movieFile.nativePath + ":" + error + "\n" + error.getStackTrace());
					}
					
				}
			}, null, Alert.NO);
		}
	}else{
		playListManager.removePlayListItemByIndex(list_playList.selectedIndex, indices);
	}
}

/**
 * データグリッドでキーボードイベントを受け取るイベントハンドラです
 * @param event
 * 
 */
private function downloadedKeyUpHandler(event:KeyboardEvent):void{
	if(event.keyCode == Keyboard.DELETE || event.keyCode == Keyboard.BACKSPACE){
		var indices:Array = dataGrid_downloaded.selectedIndices;
		if(indices.length > 0 && indices[0] > -1){
			var urls:Array = new Array(indices.length);
			for(var i:int=indices.length-1; -1 < i; i--){
				urls[i] = this.downloadedListManager.getVideoPath(indices[i]);
			}
			deleteVideo(urls,indices);
		}
	}
}

/**
 * 暗号化されたローカルストアから各種設定値を読み込みます
 * 
 */
private function readStore(isLogout:Boolean = false):void{
	
	var errorName:String = "LocalStoreKey";
	var isStore:Boolean = false;
	var name:String = "" , pass:String = "";
	
	this.libraryFile = File.documentsDirectory;
	this.libraryFile.url = this.libraryFile.url + "/NNDD";
	
	try{
		
		errorName = "NameAndPass";
		
		/*ローカルストアから値の呼び出し*/
		var storedValue:ByteArray = EncryptedLocalStore.getItem("storeNameAndPass");
		if(storedValue != null){
			isStore = storedValue.readBoolean();
			
			if(isStore){
				storedValue = EncryptedLocalStore.getItem("userName");
				name = storedValue.readUTFBytes(storedValue.length);
				storedValue = EncryptedLocalStore.getItem("password");
				pass = storedValue.readUTFBytes(storedValue.length);
			}
		}
		
		errorName = "windowPosition_x";
		//x,y,w,h
		storedValue = EncryptedLocalStore.getItem("windowPosition_x");
		if(storedValue != null){
			var windowPosition_x:Number = storedValue.readDouble();
			nativeWindow.x = lastRect.x = windowPosition_x;
		}
		errorName = "windowPosition_y";
		storedValue = EncryptedLocalStore.getItem("windowPosition_y");
		if(storedValue != null){
			var windowPosition_y:Number = storedValue.readDouble();
			nativeWindow.y = lastRect.y = windowPosition_y;
		}
		errorName = "windowPosition_w";
		storedValue = EncryptedLocalStore.getItem("windowPosition_w");
		if(storedValue != null){
			var windowPosition_w:Number = storedValue.readDouble();
			nativeWindow.width = lastRect.width = windowPosition_w;
		}
		errorName = "windowPosition_h";
		storedValue = EncryptedLocalStore.getItem("windowPosition_h");
		if(storedValue != null){
			var windowPosition_h:Number = storedValue.readDouble();
			nativeWindow.height = lastRect.height = windowPosition_h;
		}
		
		errorName = "isVersionCheckEnable";
		storedValue = EncryptedLocalStore.getItem("isVersionCheckEnable");
		if(storedValue != null){
			this.isVersionCheckEnable = storedValue.readBoolean();
		}
		
		errorName = "canvasPlaylistHight";
		storedValue = EncryptedLocalStore.getItem("canvasPlaylistHight");
		if(storedValue != null){
			try{
				this.lastCanvasPlaylistHight = storedValue.readInt();
			}catch(eorError:EOFError){
				this.lastCanvasPlaylistHight = 0;
			}
		}
		
		errorName = "thumbImangeSize";
		storedValue = EncryptedLocalStore.getItem("thumbImangeSize");
		if(storedValue != null){
			slider_thumbImageSize.value = storedValue.readDouble();
			dataGrid_ranking.rowHeight = 50*slider_thumbImageSize.value;
			dataGridColumn_thumbImage.width = 60*slider_thumbImageSize.value;
		}
		
		errorName = "thumbImgSizeForMyList";
		storedValue = EncryptedLocalStore.getItem("thumbImgSizeForMyList");
		if(storedValue != null){
			thumbImgSizeForMyList = storedValue.readDouble();
		}
		
		errorName = "thumbImgSizeForSearch";
		storedValue = EncryptedLocalStore.getItem("thumbImgSizeForSearch");
		if(storedValue != null){
			thumbImgSizeForSearch = storedValue.readDouble();
		}
		
		errorName = "isAutoLogin";
		storedValue = EncryptedLocalStore.getItem("isAutoLogin");
		if(storedValue != null){
			this.isAutoLogin = storedValue.readBoolean();
		}
		
		errorName = "isAutoDownload";
		storedValue = EncryptedLocalStore.getItem("isAutoDownload");
		if(storedValue != null){
			this.isAutoDownload = storedValue.readBoolean();
		}
		
		errorName = "isEnableEcoCheck";
		storedValue = EncryptedLocalStore.getItem("isEnableEcoCheck");
		if(storedValue != null){
			this.isEnableEcoCheck = storedValue.readBoolean();
		}
		
		
		errorName = "rankingTarget";
		storedValue = EncryptedLocalStore.getItem("rankingTarget");
		if(storedValue != null){
			this.target = storedValue.readInt();
			this.addEventListener(AIREvent.WINDOW_COMPLETE, function():void{
				radiogroup_target.selectedValue = target;
			});
		}
		
		errorName = "rankingPeriod";
		storedValue = EncryptedLocalStore.getItem("rankingPeriod");
		if(storedValue != null){
			this.period = storedValue.readInt();
			this.addEventListener(AIREvent.WINDOW_COMPLETE, function():void{
				radiogroup_period.selectedValue = period;
			});
		}
		
		errorName = "libraryURL";
		/*保存先を設定*/
		storedValue = EncryptedLocalStore.getItem("libraryURL");
		if(storedValue != null){
			this.libraryFile.url = storedValue.readUTFBytes(storedValue.length);
		}else{
			this.libraryFile = File.documentsDirectory;
			this.libraryFile.url = this.libraryFile.url + "/NNDD";
		}
		logManager.setLogDir(new File(this.libraryFile.url + "/system/"));
		
		storedValue = EncryptedLocalStore.getItem("isSayHappyNewYear");
		if(storedValue != null){
			isSayHappyNewYear = storedValue.readBoolean();
		}
		
//		errorName = "isShowOnlyNowLibraryTag";
//		storedValue = EncryptedLocalStore.getItem("isShowOnlyNowLibraryTag");
//		if(storedValue != null){
//			this.isShowOnlyNowLibraryTag = storedValue.readBoolean();
//		}

		errorName = "isAlwaysEconomy";
		storedValue = EncryptedLocalStore.getItem("isAlwaysEconomy");
		if(storedValue != null){
			this.isAlwaysEconomy = storedValue.readBoolean();
		}
		
		
		errorName = "lastCanvasTagTileListHight";
		storedValue = EncryptedLocalStore.getItem("lastCanvasTagTileListHight");
		if(storedValue != null){
			this.lastCanvasTagTileListHight = storedValue.readInt();
		}
		
		errorName = "isRankingRenewAtStart";
		storedValue = EncryptedLocalStore.getItem("isRankingRenewAtStart");
		if(storedValue != null){
			this.isRankingRenewAtStart = storedValue.readBoolean();
		}
		
		errorName = "isOutStreamingPlayerUse";
		storedValue = EncryptedLocalStore.getItem("isOutStreamingPlayerUse");
		if(storedValue != null){
			this.isOutStreamingPlayerUse = storedValue.readBoolean();
		}
		
		errorName = "isDoubleClickOnStreaming"
		storedValue = EncryptedLocalStore.getItem("isDoubleClickOnStreaming");
		if(storedValue != null){
			this.isDoubleClickOnStreaming = storedValue.readBoolean();
		}
		
		errorName = "lastCategoryListWidth"
		storedValue = EncryptedLocalStore.getItem("lastCategoryListWidth");
		if(storedValue != null){
			this.lastCategoryListWidth = storedValue.readInt();
		}
		
		errorName = "lastMyListSummaryWidth"
		storedValue = EncryptedLocalStore.getItem("lastMyListSummaryWidth");
		if(storedValue != null){
			this.lastMyListSummaryWidth = storedValue.readInt();
		}
		
		errorName = "lastMyListHeight"
		storedValue = EncryptedLocalStore.getItem("lastMyListHeight");
		if(storedValue != null){
			this.lastMyListHeight = storedValue.readInt();
		}
		
		errorName = "lastLibraryWidth"
		storedValue = EncryptedLocalStore.getItem("lastLibraryWidth");
		if(storedValue != null){
			this.lastLibraryWidth = storedValue.readInt();
		}
		
		errorName = "lastCategoryListWidth";
		storedValue = EncryptedLocalStore.getItem("lastCategoryListWidth");
		if(storedValue != null){
			this.lastCategoryListWidth = storedValue.readInt();
		}
		
		errorName = "libraryDataGridSortFieldName"
		storedValue = EncryptedLocalStore.getItem("libraryDataGridSortFieldName");
		if(storedValue != null){
			this.libraryDataGridSortFieldName = storedValue.readUTF();
		}
		
		errorName = "libraryDataGridSortDescending"
		storedValue = EncryptedLocalStore.getItem("libraryDataGridSortDescending");
		if(storedValue != null){
			this.libraryDataGridSortDescending = storedValue.readBoolean();
		}
		
		errorName = "isEnableLibrary";
		storedValue = EncryptedLocalStore.getItem("isEnableLibrary");
		if(storedValue != null){
			this.isEnableLibrary = storedValue.readBoolean();
		}
		
		errorName = "isAddedDefSearchItems";
		storedValue = EncryptedLocalStore.getItem("isAddedDefSearchItems");
		if(storedValue != null){
			this.isAddedDefSearchItems = storedValue.readBoolean();
		}
		
		errorName = "isDisEnableAutoExit";
		storedValue = EncryptedLocalStore.getItem("isDisEnableAutoExit");
		if(storedValue != null){
			this.isDisEnableAutoExit = storedValue.readBoolean();
		}
		this.autoExit = !this.isDisEnableAutoExit;
		
		errorName = "isReNameOldComment";
		storedValue = EncryptedLocalStore.getItem("isReNameOldComment");
		if(storedValue != null){
			this.isReNameOldComment = storedValue.readBoolean();
		}
		
		/* ログイン処理 */
		// ログインダイアログの作成
		loginDialog = PopUpManager.createPopUp(this, LoginDialog, true) as LoginDialog;
		loginDialog.initLoginDialog(Access2Nico.TOP_PAGE_URL, Access2Nico.LOGIN_URL, isStore, isAutoLogin, logManager, name, pass, isLogout);
		// ログイン時のイベントリスナを追加
		loginDialog.addEventListener(LoginDialog.ON_LOGIN_SUCCESS, onFirstTimeLoginSuccess);
		loginDialog.addEventListener(LoginDialog.NO_LOGIN, noLogin);
		// ダイアログを中央に表示
		PopUpManager.centerPopUp(loginDialog);
		loginDialog.setBootTimePlay(true);
		
	}catch(error:Error){
		
		/* ストアをリセット */
		EncryptedLocalStore.reset();
		
		/* エラー時は初期値を利用 */
		isStore = false;
		isAutoLogin = false;
		name = "";
		pass = "";
		
		this.libraryFile = File.documentsDirectory;
		this.libraryFile.url = this.libraryFile.url + "/NNDD";
		
		logManager.setLogDir(this.libraryFile);
		
		/* ログイン処理 */
		// ログインダイアログの作成
		loginDialog = PopUpManager.createPopUp(this, LoginDialog, true) as LoginDialog;
		loginDialog.initLoginDialog(Access2Nico.TOP_PAGE_URL, Access2Nico.LOGIN_URL, isStore, isAutoLogin, logManager, name, pass, isLogout);
		// ログイン時のイベントリスナを追加
		loginDialog.addEventListener(LoginDialog.ON_LOGIN_SUCCESS, onFirstTimeLoginSuccess);
		loginDialog.addEventListener(LoginDialog.LOGIN_FAIL, loginFailEventHandler);
		loginDialog.addEventListener(LoginDialog.NO_LOGIN, noLogin);
		// ダイアログを中央に表示
		PopUpManager.centerPopUp(loginDialog);
		
		/* エラーログ出力 */
		Alert.show(Message.M_LOCAL_STORE_IS_BROKEN, Message.M_ERROR);
		logManager.addLog(Message.M_LOCAL_STORE_IS_BROKEN + ":" + Message.FAIL_LOAD_LOCAL_STORE_FOR_NNDD_MAIN_WINDOW + "[" + errorName + "]:" + error + ":" + error.getStackTrace());
		
		
	}
	
}

/**
 * 
 * @param event
 * 
 */
private function loginFailEventHandler(event:Event):void{
	logManager.addLog("ログインに失敗:" + event);
}

/**
 * 初回ログイン作業が成功した場合に呼ばれるリスナー
 * @param event
 * 
 */
private function onFirstTimeLoginSuccess(event:HTTPStatusEvent):void
{
	logoutButton.label = "ログアウト";
	logoutButton.enabled = true;
	
	PopUpManager.removePopUp(loginDialog);
	
	this.MAILADDRESS = loginDialog.textInput_userName.text;
	this.PASSWORD = loginDialog.textInput_password.text;
	
	downloadManager.setMailAndPass(this.MAILADDRESS, this.PASSWORD);
	downloadManager.isContactTheUser = isEnableEcoCheck;
	scheduleManager = new ScheduleManager(logManager, downloadManager);
	
//	this.nndd.label_status.text = "ログインに成功(" + event.status + ")";
	trace("ログインに成功"+event);
	logManager.addLog("ログイン:" + event);
	
//	nndd.rankingRenewButton.enabled = true;
//	nndd.downloadStartButton.enabled = true;
//	nndd.button_SearchNico.enabled = true;
//	nndd.dataGrid_ranking.enabled = true;
//	nndd.list_categoryList.enabled = true;
//	nndd.playStartButton.enabled = true;
//	
//	setEnableRadioButtons(true);
	
//	if(nndd.newCommentDownloadButton != null){
//		nndd.newCommentDownloadButton.enabled = true;
//	}
	
	//引数指定起動でニコ動のURLが指定されていたときはログイン後に再生開始
	if(isArgumentBoot){
		this.textInput_mUrl.text = this.argumentURL;
		isArgumentBoot = false;
		try{
			this.playingVideoPath = this.argumentURL;
			this.videoStreamingPlayStartButtonClicked(this.playingVideoPath);
			this.isArgumentBoot = false;
			this.argumentURL = "";
		}catch(error:Error){
			Alert.show("引数で指定されていたビデオの再生に失敗\n" + this.argumentURL, Message.M_ERROR);
			logManager.addLog("引数で指定されていたビデオの再生に失敗:url" + this.argumentURL + "\n" + error.getStackTrace());
		}
	}
	

}

/**
 * ログインダイアログで"今はログインしない"を選択したときに呼ばれるリスナー
 * 
 */
private function noLogin(event:HTTPStatusEvent):void
{
	logoutButton.label = "ログイン";
	logoutButton.enabled = true;
	
	PopUpManager.removePopUp(loginDialog);
	
	this.MAILADDRESS = "";
	this.PASSWORD = "";
	
	logManager.addLog("ログインせず:" + event);
	
	downloadManager.setMailAndPass(this.MAILADDRESS, this.PASSWORD);
	scheduleManager = new ScheduleManager(logManager, downloadManager);
	
//	this.nndd.label_status.text = "ログインしていません。";
	
//	nndd.rankingRenewButton.enabled = false;
//	nndd.downloadStartButton.enabled = false;
//	nndd.button_SearchNico.enabled = false;
//	nndd.dataGrid_ranking.enabled = false;
//	nndd.list_categoryList.enabled = false;
//	nndd.playStartButton.enabled = false;
//	
//	setEnableRadioButtons(false);
//	
//	if(nndd.newCommentDownloadButton != null){
//		nndd.newCommentDownloadButton.enabled = false;
//	}
	
	this.isArgumentBoot = false;
	this.argumentURL = "";
	
}

private function setEnableTargetRadioButtons(enable:Boolean):void{
	
	nndd.radio_target_mylist.enabled = enable;
	nndd.radio_target_res.enabled = enable;
	nndd.radio_target_view.enabled = enable;
	
}

/**
 * ラジオボタンをまとめて有効・無効に設定します。
 * @param enable
 * 
 */
private function setEnableRadioButtons(enable:Boolean):void{
	nndd.radiogroup_period.enabled = enable;
	nndd.radiogroup_target.enabled = enable;
	
	nndd.radio_period_new.enabled = enable;
	nndd.radio_period_daily.enabled = enable;
	nndd.radio_period_hourly.enabled = enable;
	nndd.radio_period_monthly.enabled = enable;
	nndd.radio_period_weekly.enabled = enable;
	nndd.radio_period_all.enabled = enable;
	nndd.radio_target_mylist.enabled = enable;
	nndd.radio_target_res.enabled = enable;
	nndd.radio_target_view.enabled = enable;
}

/**
 * 「参照」ボタンがクリックされた際に呼ばれます。 <br>
 * 
 */
private function folderSelectButtonClicked(event:MouseEvent):void
{
	var directory:File = new File(libraryFile.url);
	
	directory.browseForDirectory("ファイルの保存先を指定");
	
	// ファイル選択イベントのリスナを登録
	directory.addEventListener(Event.SELECT, function(event:Event):void{
		// イベントのターゲットが選択されたファイルなので、`File`型に変換
		libraryFile = File(event.target);
		nndd.textInput_saveAdress.text = libraryFile.nativePath;
		
		downloadedListManager.updateDownLoadedItems(libraryFile.url);
		libraryManager.changeLibraryDir(libraryFile);
		
		logManager.addLog("保存先を変更:"+libraryFile.nativePath);
	});
}


/**
 * タブが変更されたときに呼ばれます。
 * 
 */
private function tabChanged():void{
	switch(viewStack.selectedIndex){
		case RANKING_AND_SERACH_TAB_NUM:
			
			break;
		case SEARCH_TAB_NUM:
			tree_SearchItem.dataProvider = searchListProvider;
			tree_SearchItem.validateNow();
			break;	
		case MYLIST_TAB_NUM:
			
			break;
		case DOWNLOAD_LIST_TAB_NUM:
			label_nextDownloadTime.text = scheduleManager.scheduleString;
			dataGrid_downloadList.setFocus();
			break;
		case LIBRARY_LIST_TAB_NUM:
		
			this.tree_FileSystem.enabled = isEnableLibrary;
			this.button_addDir.enabled = isEnableLibrary;
			this.button_delDir.enabled = isEnableLibrary;
			this.button_fileNameEdit.enabled = isEnableLibrary;
			this.tileList_tag.dataProvider = new Array();
			(this.dataGrid_downloaded.dataProvider as ArrayCollection).removeAll();
		
			if(playListManager.isSelectedPlayList){
				
				//プレイリストが開かれていた場合はプレイリストを更新
				playListManager.downLoadedProvider.sort = null;
				playListManager.downLoadedProvider.refresh();
				
				this.playListItemClicked(this.playListManager.selectedPlayListIndex);
				libraryManager.tagManager.tagRenewOnPlayList(tileList_tag, playListManager.getPlayListVideoListByIndex(this.playListManager.selectedPlayListIndex));
				
			}else if(isEnableLibrary){
				
				var openPaths:Array = new Array();
				var selectedPaths:Array = new Array();
				if(this.tree_FileSystem.openPaths != null){
					openPaths = this.tree_FileSystem.openPaths;
				}
				if(this.tree_FileSystem.selectedPaths != null){
					selectedPaths = this.tree_FileSystem.selectedPaths;
				}
				//ダウンロード済みリストを更新する。
				var myFile:File = new File((libraryFile.url.substr(0,libraryFile.url.lastIndexOf("/"))));
				
				this.tree_FileSystem.filterFunction = function(file:File):Boolean{
					if(0 == file.url.indexOf((libraryFile.url + "/"))){
						//メインのディレクトリを含んでいるものしか見せない
						if((file.url == libraryFile.url + "/system")){
							return false;
						}
						return true;
					}else if(-1 != file.url.indexOf(libraryFile.url) && file.url.length == libraryFile.url.length ){
						return true;
					}
					return false;
				};
				
				this.tree_FileSystem.directory = myFile;
				this.tree_FileSystem.enumerationMode = FileSystemEnumerationMode.DIRECTORIES_ONLY;
				this.downloadedListManager.updateDownLoadedItems(tree_FileSystem.selectedPath);
		  		
		  		//ツリーで以前開いていた部分を再度開く
		  		var newOpenPaths:Array = new Array();
		  		for(var i:int = 0; i<openPaths.length; i++){
		  			var file:File = new File(openPaths[i]);
		  			if(file.exists){
		  				newOpenPaths.push(openPaths[i]);
		  			}
		  		}
		  		this.tree_FileSystem.openPaths = newOpenPaths;
		  		
		  		//ツリーで以前選択されていた部分を再度選択する
		  		var newSelectedPaths:Array = new Array();
		  		for(i = 0; i<selectedPaths.length; i++){
		  			file = new File(selectedPaths[i]);
		  			if(file.exists){
		  				newSelectedPaths.push(selectedPaths[i]);
		  			}
		  		}
		  		this.tree_FileSystem.selectedPaths = newSelectedPaths;
		  		
				if(newOpenPaths.length > 0){
					/* 開かれているパスの項目でタグを更新 */
					var openFile:File = new File();
					openFile.nativePath = newOpenPaths[0];
					libraryManager.tagManager.tagRenew(tileList_tag, openFile);
				}else{
					/* ライブラリ直下でタグを更新 */
					libraryManager.tagManager.tagRenew(tileList_tag, libraryFile);
				}
		  		
		  		//ソートを反映
		  		if(this.libraryDataGridSortFieldName != null && this.libraryDataGridSortFieldName != ""){
			  		(this.dataGrid_downloaded.dataProvider as ArrayCollection).sort = new Sort();
			  		(this.dataGrid_downloaded.dataProvider as ArrayCollection).sort.fields = [new SortField(this.libraryDataGridSortFieldName, false, this.libraryDataGridSortDescending)];
		  		}else{
		  			(this.dataGrid_downloaded.dataProvider as ArrayCollection).sort = new Sort();
			  		(this.dataGrid_downloaded.dataProvider as ArrayCollection).sort.fields = [new SortField("dataGridColumn_videoName", false, false)];
		  		}
	  		}else if(!isEnableLibrary){
	  			var openPaths:Array = new Array();
				var selectedPaths:Array = new Array();
				if(this.tree_FileSystem.openPaths != null){
					openPaths = this.tree_FileSystem.openPaths;
				}
				if(this.tree_FileSystem.selectedPaths != null){
					selectedPaths = this.tree_FileSystem.selectedPaths;
				}
				//ダウンロード済みリストを更新する。
				var myFile:File = new File((libraryFile.url.substr(0,libraryFile.url.lastIndexOf("/"))));
				
				this.tree_FileSystem.filterFunction = function(file:File):Boolean{
					if(0 == file.url.indexOf((libraryFile.url + "/"))){
						//メインのディレクトリを含んでいるものしか見せない
						if((file.url == libraryFile.url + "/system")){
							return false;
						}
						return true;
					}else if(-1 != file.url.indexOf(libraryFile.url) && file.url.length == libraryFile.url.length ){
						return true;
					}
					return false;
				};
				
				this.tree_FileSystem.directory = myFile;
				this.tree_FileSystem.enumerationMode = FileSystemEnumerationMode.DIRECTORIES_ONLY;
		  		
		  		//ツリーで以前開いていた部分を再度開く
		  		var newOpenPaths:Array = new Array();
		  		for(var i:int = 0; i<openPaths.length; i++){
		  			var file:File = new File(openPaths[i]);
		  			if(file.exists){
		  				newOpenPaths.push(openPaths[i]);
		  			}
		  		}
		  		this.tree_FileSystem.openPaths = newOpenPaths;
		  		
		  		//ツリーで以前選択されていた部分を再度選択する
		  		var newSelectedPaths:Array = new Array();
		  		for(i = 0; i<selectedPaths.length; i++){
		  			file = new File(selectedPaths[i]);
		  			if(file.exists){
		  				newSelectedPaths.push(selectedPaths[i]);
		  			}
		  		}
		  		this.tree_FileSystem.selectedPaths = newSelectedPaths;
	  		}
	  		
	  		(this.dataGrid_downloaded.dataProvider as ArrayCollection).refresh();
			break;
		case HISTORY_LIST_TAB_NUM:
			historyManager.refresh();
			break;
		case OPTION_TAB_NUM:
			if(textArea_log != null){
				logManager.showLog(textArea_log);
			}else{
				canvas_innerConfing_log.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:FlexEvent):void{
					logManager.showLog(textArea_log);
				});
			}
			break;
		
	}
}

private function confTabChange(event:Event):void{
	if(textArea_log != null){
		logManager.showLog(textArea_log);
	}else{
		canvas_innerConfing_log.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:FlexEvent):void{
			logManager.showLog(textArea_log);
		});
	}
}


private function rankingCanvasCreationComplete(event:FlexEvent):void{
	if(this.lastCategoryListWidth != -1){
  		this.list_categoryList.width = this.lastCategoryListWidth;
  		this.validateNow();
  	}
  	this.list_categoryList.addEventListener(ResizeEvent.RESIZE, categoryListWidthChanged);
}

private function searchCanvasCreationComplete(event:FlexEvent):void{
	if(this.lastSearchItemListWidth != -1){
		this.canvas_searchItemList.width = this.lastSearchItemListWidth;
		this.validateNow();
	}
	if(this.thumbImgSizeForSearch != -1){
		slider_thumbImageSize_search.value = this.thumbImgSizeForSearch;
		dataGrid_search.rowHeight = 50*slider_thumbImageSize_search.value;
		dataGridColumn_thumbImage_Search.width = 60*slider_thumbImageSize_search.value;
		this.validateNow();
	}
	this.canvas_searchItemList.addEventListener(ResizeEvent.RESIZE, searchItemListWidthChanged);
}

private function myListCanvasCreationComplete(event:FlexEvent):void{
	if(this.thumbImgSizeForMyList != -1){
		slider_thumbImageSizeForMyList.value = this.thumbImgSizeForMyList;
		dataGrid_myList.rowHeight = 50*slider_thumbImageSizeForMyList.value;
		dataGridColumn_thumbUrl.width = 60*slider_thumbImageSizeForMyList.value;
		this.validateNow();
	}
	if(this.lastMyListHeight != -1){
  		this.textArea_myList.height = this.lastMyListHeight;
  		this.validateNow();
  	}
	if(this.lastMyListSummaryWidth != -1){
		trace(this.textArea_myList.height);
  		this.canvas_myListSummary.width = this.lastMyListSummaryWidth;
  		this.validateNow();
  		trace(this.textArea_myList.height + ":" + this.lastMyListSummaryWidth);
  	}
  	this.textArea_myList.addEventListener(ResizeEvent.RESIZE, myListHeightChanged);
  	this.canvas_myListSummary.addEventListener(ResizeEvent.RESIZE, myListSummaryWidthChagned);
}

private function downloadListCanvasCreationComplete(event:FlexEvent):void{
	
}

private function libraryCanvasCreationComplete(event:FlexEvent):void{
	if(this.lastLibraryWidth != -1){
  		this.canvas_libAndPList.width = this.lastLibraryWidth;
		this.validateNow();
  	}
  	if(this.lastCanvasPlaylistHight != -1){
  		this.canvas_playlist.height = this.lastCanvasPlaylistHight;
  		this.validateNow();
  	}
  	if(this.lastCanvasTagTileListHight != -1){
  		this.canvas_tagTileList.height = this.lastCanvasTagTileListHight;
  		this.validateNow();
  	}
  	this.canvas_libAndPList.addEventListener(ResizeEvent.RESIZE, libraryWidthChanged);
  	this.canvas_playlist.addEventListener(ResizeEvent.RESIZE, playlistHeightChanged);
  	this.canvas_tagTileList.addEventListener(ResizeEvent.RESIZE, tileListHeightChanged);
}

private function configCanvasCreationComplete(event:FlexEvent):void{
//	this.checkbox_showOnlyNowLibraryTag.selected = isShowOnlyNowLibraryTag;
	checkbox_autoDL.selected = this.isAutoDownload;
	checkbox_ecoDL.selected = this.isEnableEcoCheck;
	checkBox_versionCheck.selected = this.isVersionCheckEnable;
	textInput_saveAdress.text = this.libraryFile.nativePath;
	checkbox_isRankingRenewAtStart.selected = isRankingRenewAtStart;
	checkBox_isUseOutStreamPlayer.selected = this.isOutStreamingPlayerUse;
	checkBox_isDoubleClickOnStreaming.selected = this.isDoubleClickOnStreaming;
	checkBox_isAlwaysEconomyMode.selected = this.isAlwaysEconomy
	
	checkBox_enableLibrary.selected = this.isEnableLibrary;
//	checkbox_showOnlyNowLibraryTag.enabled = isEnableLibrary;
	checkBox_DisEnableAutoExit.selected = this.isDisEnableAutoExit;
	checkBox_isReNameOldComment.selected = this.isReNameOldComment;

}

private function playlistHeightChanged(event:ResizeEvent):void{
	this.lastCanvasPlaylistHight = event.currentTarget.height;
}

private function libraryWidthChanged(event:ResizeEvent):void{
	this.lastLibraryWidth = event.currentTarget.width;
}

private function categoryListWidthChanged(event:ResizeEvent):void{
	this.lastCategoryListWidth = event.currentTarget.width;
}

private function searchItemListWidthChanged(event:ResizeEvent):void{
	this.lastSearchItemListWidth = event.currentTarget.width;
}


private function myListSummaryWidthChagned(event:ResizeEvent):void{
	this.lastMyListSummaryWidth = event.currentTarget.width;
}

private function myListHeightChanged(event:ResizeEvent):void{
	this.lastMyListHeight = event.currentTarget.height;
}

/**
 * ダウンロードボタンを押したときの動作
 * 
 */
private function addDownloadListButtonClicked():void{
	if(downloadStartButton.enabled == true){
		
		if(dataGrid_ranking.selectedIndices.length > 0){
			
			var items:Array = dataGrid_ranking.selectedItems;
			var itemIndices:Array = dataGrid_ranking.selectedIndices;
			for(var index:int = 0; index<items.length; index++){
				
				var video:NNDDVideo = new NNDDVideo(items[index].dataGridColumn_nicoVideoUrl, items[index].dataGridColumn_videoName);
				addDownloadList(video, itemIndices[index]);
				
			}
			
			return;
		}
		
		var mUrl:String = textInput_mUrl.text;
		
		var isVideoUrlEnable:Boolean = false;
		
		if(mUrl != null && mUrl != ""){
			if(mUrl.indexOf("http://www.nicovideo.jp/watch/") == -1){
				var videoID:String = PathMaker.getVideoID(mUrl);
				if(videoID != null){
					mUrl = "http://www.nicovideo.jp/watch/" + videoID;
					isVideoUrlEnable = true;
				}
			}else{
				isVideoUrlEnable = true;
			}
		}
			
		if(isVideoUrlEnable){
			
			try{
				
				var video:NNDDVideo = new NNDDVideo(mUrl, "-");
				
				downloadManager.add(video, isAutoDownload);
				
			}catch(e:Error){
				downloadStartButton.label = Message.L_DOWNLOAD;
				Alert.show("ダウンロード中に予期せぬ例外が発生しました。\nError:" + e,"エラー");
				logManager.addLog("ダウンロード中に予期せぬ例外が発生しました。\nError:" + e.getStackTrace());
				downloadStartButton.enabled = true;
			}
			
		}else{
			Alert.show(Message.M_NOT_NICO_URL, Message.M_ERROR);
		}
	}
}

/**
 * ストリーミングボタンが押されたときの動作
 * @param url
 * 
 */
private function videoStreamingPlayStartButtonClicked(url:String = null):void{
	if(playStartButton.enabled == true){
		
		var mUrl:String = textInput_mUrl.text;
		if(url != null){
			mUrl = url;
		}
		
		var videoId:String = PathMaker.getVideoID(mUrl);
		if(videoId != null){
			mUrl = "http://www.nicovideo.jp/watch/" + videoId;
		}
		
		if(mUrl != null && mUrl.indexOf("http://www.nicovideo.jp/watch/") != -1){
			
			if(isOutStreamingPlayerUse){
				
				navigateToURL(new URLRequest(mUrl));
				
			}else{
				
				if(!playerController.isOpen()){
					playerController.destructor();
					playerController = null;
					playerController = new PlayerController(logManager, MAILADDRESS, PASSWORD, libraryFile, libraryManager, playListManager);
					playerController.open();
				}
				
				try{
					
					playerController.playMovie(mUrl);
					
				}catch(e:Error){
					
					Alert.show("ストリーミング再生中に予期せぬ例外が発生しました。\nError:" + e, Message.M_ERROR);
					logManager.addLog("ストリーミング再生中に予期せぬ例外が発生しました。\nError:" + e + ":" + e.getStackTrace());
					
				}
			}
			
		}else{
			Alert.show(Message.M_NOT_NICO_URL, Message.M_ERROR);
		}
		
	}
}

/**
 * ランキングデータグリッドがクリックされたときの動作
 * 
 */
private function rankingDataGridClicked(event:ListEvent):void{
	var index:int = this.nndd.dataGrid_ranking.selectedIndex;
	
	if(dataGrid_ranking.dataProvider.length > 0 && index<dataGrid_ranking.dataProvider.length && index >= 0){
		this.nndd.textInput_mUrl.text = dataGrid_ranking.dataProvider[index].dataGridColumn_nicoVideoUrl;
	}
}

/**
 * ランキングデータグリッドがダブルクリックされたときの動作
 * 
 */
private function rankingDataGridDoubleClicked(event:ListEvent):void{
	
	var myDataGrid:DataGrid = (event.currentTarget as DataGrid);
	
	var mUrl:String = myDataGrid.dataProvider[myDataGrid.selectedIndex].dataGridColumn_nicoVideoUrl;
	
	if(myDataGrid.enabled == true){
		
		if(isDoubleClickOnStreaming){
			this.videoStreamingPlayStartButtonClicked(mUrl);
		}else{
			var videoName:String = myDataGrid.dataProvider[myDataGrid.selectedIndex].dataGridColumn_videoName;
			var index:int = myDataGrid.selectedIndex;
			
			var video:NNDDVideo = new NNDDVideo(mUrl, videoName);
			var isExistsInLibrary:Boolean = false;
			video = libraryManager.isExist(LibraryManager.getVideoKey(mUrl));
			if(video != null){
				isExistsInLibrary = true;
			}
			
			if(isExistsInLibrary){
				Alert.show(Message.M_ALREADY_DOWNLOADED_VIDE_EXIST, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
					if(event.detail == Alert.YES){
						var video:NNDDVideo = new NNDDVideo(mUrl, videoName);
						addDownloadList(video, index);
					}
				}, null, Alert.NO);
			}else{
				video = new NNDDVideo(mUrl, videoName);
				addDownloadList(video, index);
			}
				
		
		}
	}
}

/**
 * 検索データグリッドがダブルクリックされたときの動作
 * 
 */
private function searchDataGridDoubleClicked(event:ListEvent):void{
	
	var myDataGrid:DataGrid = (event.currentTarget as DataGrid);
	
	var mUrl:String = myDataGrid.dataProvider[myDataGrid.selectedIndex].dataGridColumn_nicoVideoUrl;
	
	if(myDataGrid.enabled == true){
		
		if(isDoubleClickOnStreaming){
			this.videoStreamingPlayStartButtonClicked(mUrl);
		}else{
			var videoName:String = myDataGrid.dataProvider[myDataGrid.selectedIndex].dataGridColumn_videoName;
			var index:int = myDataGrid.selectedIndex;
			
			var video:NNDDVideo = new NNDDVideo(mUrl, videoName);
			var isExistsInLibrary:Boolean = false;
			video = libraryManager.isExist(LibraryManager.getVideoKey(mUrl));
			if(video != null){
				isExistsInLibrary = true;
			}
			
			if(isExistsInLibrary){
				Alert.show(Message.M_ALREADY_DOWNLOADED_VIDE_EXIST, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
					if(event.detail == Alert.YES){
						var video:NNDDVideo = new NNDDVideo(mUrl, videoName);
						addDownloadListForSearch(video, index);
					}
				}, null, Alert.NO);
			}else{
				video = new NNDDVideo(mUrl, videoName);
				addDownloadListForSearch(video, index);
			}
				
		
		}
	}
}


/**
 * 
 * @param event
 * 
 */
private function addDownloadListForDownloadedList(event:Event):void{
	var index:int = dataGrid_downloaded.selectedIndex;
	var videoPath:String = downloadedListManager.getVideoPath(index);
	if(videoPath != null){
		var videoId:String = LibraryManager.getVideoKey(videoPath);
		if(videoId != null){
			var video:NNDDVideo = libraryManager.isExist(videoId);
			if(video != null){
				Alert.show("動画をダウンロードし直します。よろしいですか？(DLリストに追加します。)", Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
					if(event.detail == Alert.YES){
						addDownloadList(video, -1);
					}
				}, null, Alert.YES);
			}else{
				video = new NNDDVideo(videoPath, "-")
				addDownloadList(video, -1);
			}
		}else{
			Alert.show("ビデオIDが見つからなかったため、動画を更新できませんでした。\n" + videoPath);
			logManager.addLog("ビデオIDが見つかりませんでした。:" + videoPath);
		}
	}
}

/**
 * 
 * @param video
 * @param index
 * 
 */
private function addDownloadList(video:NNDDVideo, index:int = -1):void{
	
	var isExistsInDLList:Boolean = false;
	isExistsInDLList = downloadManager.isExists(video);
	
	if(isExistsInDLList){
		Alert.show(Message.M_ALREADY_DLLIST_VIDE_EXIST, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
			if(event.detail == Alert.YES){
				downloadManager.add(video, isAutoDownload);
				if(index != -1 && rankingProvider.length > index){
					rankingProvider.setItemAt({
						dataGridColumn_preview: rankingProvider[index].dataGridColumn_preview,
						dataGridColumn_ranking: rankingProvider[index].dataGridColumn_ranking,
						dataGridColumn_videoName: rankingProvider[index].dataGridColumn_videoName,
						dataGridColumn_videoInfo: rankingProvider[index].dataGridColumn_videoInfo,
						dataGridColumn_condition: "DLリストに追加済",
						dataGridColumn_downloadedItemUrl: rankingProvider[index].dataGridColumn_downloadedItemUrl,
						dataGridColumn_nicoVideoUrl: rankingProvider[index].dataGridColumn_nicoVideoUrl
					}, index);
				}
			}
		}, null, Alert.NO);
	}else{
		downloadManager.add(video, isAutoDownload);
		if(index != -1 && rankingProvider.length > index){
			rankingProvider.setItemAt({
				dataGridColumn_preview: rankingProvider[index].dataGridColumn_preview,
				dataGridColumn_ranking: rankingProvider[index].dataGridColumn_ranking,
				dataGridColumn_videoName: rankingProvider[index].dataGridColumn_videoName,
				dataGridColumn_videoInfo: rankingProvider[index].dataGridColumn_videoInfo,
				dataGridColumn_condition: "DLリストに追加済",
				dataGridColumn_downloadedItemUrl: rankingProvider[index].dataGridColumn_downloadedItemUrl,
				dataGridColumn_nicoVideoUrl: rankingProvider[index].dataGridColumn_nicoVideoUrl
			}, index);
		}
	}
}

/**
 * 
 * @param video
 * 
 */
public function addDownloadListForInfoView(video:NNDDVideo):void{
	if(video != null){
		downloadManager.add(video, isAutoDownload);
	}
}

/**
 * 
 * @param video
 * @param index
 * 
 */
public function addDownloadListForSearch(video:NNDDVideo, index:int = -1):void{
	var isExistsInDLList:Boolean = false;
	isExistsInDLList = downloadManager.isExists(video);
	
	if(isExistsInDLList){
		Alert.show(Message.M_ALREADY_DLLIST_VIDE_EXIST, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
			if(event.detail == Alert.YES){
				downloadManager.add(video, isAutoDownload);
				if(index != -1 && searchProvider.length > index){
					searchProvider.setItemAt({
						dataGridColumn_preview: searchProvider[index].dataGridColumn_preview,
						dataGridColumn_ranking: searchProvider[index].dataGridColumn_ranking,
						dataGridColumn_videoName: searchProvider[index].dataGridColumn_videoName,
						dataGridColumn_videoInfo: searchProvider[index].dataGridColumn_videoInfo,
						dataGridColumn_condition: "DLリストに追加済",
						dataGridColumn_downloadedItemUrl: searchProvider[index].dataGridColumn_downloadedItemUrl,
						dataGridColumn_nicoVideoUrl: searchProvider[index].dataGridColumn_nicoVideoUrl
					}, index);
				}
			}
		}, null, Alert.NO);
	}else{
		downloadManager.add(video, isAutoDownload);
		if(index != -1 && searchProvider.length > index){
			searchProvider.setItemAt({
				dataGridColumn_preview: searchProvider[index].dataGridColumn_preview,
				dataGridColumn_ranking: searchProvider[index].dataGridColumn_ranking,
				dataGridColumn_videoName: searchProvider[index].dataGridColumn_videoName,
				dataGridColumn_videoInfo: searchProvider[index].dataGridColumn_videoInfo,
				dataGridColumn_condition: "DLリストに追加済",
				dataGridColumn_downloadedItemUrl: searchProvider[index].dataGridColumn_downloadedItemUrl,
				dataGridColumn_nicoVideoUrl: searchProvider[index].dataGridColumn_nicoVideoUrl
			}, index);
		}
	}
}

/**
 * ムービーのURLが変更されたときはDataGridのフォーカスを外します。
 * @param event
 * 
 */
private function textInputMurlChange(event:Event):void{
	dataGrid_ranking.selectedIndex = -1;
}

/**
 * 
 * @param event
 * 
 */
private function categoryListItemClicked(event:ListEvent):void{
	if(rankingRenewButton.label != Message.L_CANCEL){
		rankingRenewButtonClicked();
	}
}

/**
 * ランキングの更新ボタンが押されたときの動作
 * 
 */
private function rankingRenewButtonClicked(url:String = null):void{
	
	if(rankingRenewButton.label != Message.L_CANCEL){
		if(a2nForRanking == null){

			//選択中の期間、対象を保存
			this.period = int(this.radiogroup_period.selectedValue);
			this.target = int(this.radiogroup_target.selectedValue);
			
			var categoryListIndex:int = list_categoryList.selectedIndex;

			try{
				
//				new RankingListRenewer(logManager, libraryManager);
				
				//ランキングのURL
				var rankingURL:String;
//				ランキングのページ数カウンタ
//				rankingPageCountProvider = new Array();
				
				if(url == null){
					//urlが指定されていなければ
					rankingPageCountProvider = new Array(1);
//					combobox_pageCounter_ranking.selectedIndex = rankingPageCountProvider.indexOf(1);
					this.rankingPageIndex = 1;
					if(this.radiogroup_period.selectedValue != 5){
						//普通のライブラリ更新
						rankingURL = Access2Nico.NICO_RANKING_URLS[this.radiogroup_period.selectedValue][this.radiogroup_target.selectedValue];
						setEnableTargetRadioButtons(true);
					}else{
						//新着の場合は期間を無視
						rankingURL = Access2Nico.NICO_RANKING_URLS[this.radiogroup_period.selectedValue][0];
						setEnableTargetRadioButtons(false);
					}
				}else{
					//urlが指定されていれば
					rankingURL = url;
				}
				
				setEnableRadioButtons(false);
				rankingRenewButton.label = Message.L_CANCEL;
				list_categoryList.enabled = false;
				dataGrid_ranking.enabled = false;
				
				//ローディングウィンドウ
				loading = new LoadingPicture();
				loading.show(dataGrid_ranking, dataGrid_ranking.width/2, dataGrid_ranking.height/2);
				loading.start(360/12);
				
				a2nForRanking = new Access2Nico(null, downloadedListManager, playerController, logManager, playerController.getCommentListProvider());
				a2nForRanking.addEventListener(Access2Nico.RANKING_GET_COMPLETE, function(event:Event):void{
					setEnableRadioButtons(true);
					rankingRenewButton.label = Message.L_RENEW;
					list_categoryList.enabled = true;
					dataGrid_ranking.enabled = true;
					
					categoryList = a2nForRanking.getCategoryTitleList();
					categoryListProvider = new Array(categoryList.length);
					for(var index:int = 0; index<categoryList.length;index++){
						categoryListProvider[index] = categoryList[index][0];
					}
					rankingProvider = a2nForRanking.getRankingList();
					tagsArray = a2nForRanking.getTagArray();
					
					logManager.addLog("ランキング更新:"+rankingURL);
					if(radiogroup_period.selectedValue != 5){
						logManager.addLog("カテゴリ更新:"+rankingURL);
					}
					
					if(rankingURL.indexOf("?") != -1){
						rankingURL = rankingURL.substring(0, rankingURL.lastIndexOf("?"));
					}
					
					if(radiogroup_period.selectedValue != 5){
						//通常のランキングのときのページリンク
//						if(radiogroup_period.selectedValue == 3){
//							rankingPageLinkList = new Array(new Array(rankingURL, "1"));
//						}else{
//							rankingPageLinkList = new Array(new Array(rankingURL, "1"), new Array(rankingURL+"?page=2", "2"), new Array(rankingURL+"?page=3", "3"));
//						}
						rankingPageLinkList = new Array();
					}else{
						var array:Array = new Array();
						for(var j:int=1; j<=30; j++){
							//新着の時のページリンク
							array.push(new Array(rankingURL+"?page=" + j, String(j)));
						}
						rankingPageLinkList = array;
					}
					
//					if(rankingPageLinkList != null){
//						rankingPageCountProvider.splice(0, rankingPageCountProvider.length);
//						for(var i:int=0; i<rankingPageLinkList.length; i++){
//							rankingPageCountProvider.push(rankingPageLinkList[i][1]);
//						}
//					}
					
					if(categoryListIndex != -1 && categoryList.length >= categoryListIndex ){
						list_categoryList.selectedIndex = categoryListIndex;
					}
					
					a2nForRanking = null;
					loading.stop();
					loading.remove();
					loading = null;
				});
				a2nForRanking.addEventListener(Access2Nico.NICO_SEARCH_COMPLETE, function(event:Event):void{
					setEnableRadioButtons(true);
					rankingRenewButton.label = Message.L_RENEW;
					list_categoryList.enabled = true;
					dataGrid_ranking.enabled = true;
					
					categoryList = a2nForRanking.getCategoryTitleList();
					categoryListProvider = new Array(categoryList.length);
					for(var index:int = 0; index<categoryList.length;index++){
						categoryListProvider[index] = categoryList[index][0];
					}
					rankingProvider = a2nForRanking.getRankingNewList();
					tagsArray = a2nForRanking.getTagArray();
					
					if(categoryListIndex != -1 && categoryList.length >= categoryListIndex ){
						list_categoryList.selectedIndex = categoryListIndex;
					}
					
					a2nForRanking = null;
					loading.stop();
					loading.remove();
					loading = null;
				});
				
				
				if(rankingURL.indexOf("?") == -1){
					if(this.radiogroup_period.selectedValue != 5){
						if(categoryListIndex > 0){
							//カテゴリが選択されたとき
							rankingURL = rankingURL.concat();
						}else {
							//カテゴリ以外で、新着でないとき。
							rankingURL = rankingURL.concat("all");
						}
					}
				}
				
				var category:String = "all";
				if(categoryListIndex != -1 && categoryList.length > 0){
					category = categoryList[categoryListIndex][1];
				}
				
				if(period == 5){
					if(category == "all"){
						a2nForRanking.request_search(Access2Nico.TOP_PAGE_URL, Access2Nico.LOGIN_URL, this.MAILADDRESS, this.PASSWORD, "http://www.nicovideo.jp/", "?g=g_ent", rankingProvider, libraryManager, -1, 1);
					}else{
						a2nForRanking.request_search(Access2Nico.TOP_PAGE_URL, Access2Nico.LOGIN_URL, this.MAILADDRESS, this.PASSWORD, "http://www.nicovideo.jp/", "?g=" + category, rankingProvider, libraryManager, -1, 1);
					}
				}else{
					a2nForRanking.request_rankingRenew(period, target, category, rankingProvider, libraryManager, rankingPageIndex, tagsArray);
				}
			}catch(error:Error){
				setEnableRadioButtons(true);
				rankingRenewButton.label = Message.L_RENEW;
				list_categoryList.enabled = true;
				Alert.show("ランキング更新中に想定外の例外が発生しました。\n"+ error + "\nURL:" + rankingURL, "エラー");
				logManager.addLog("ランキング更新中に想定外の例外が発生しました。\n"+ "\nURL:"+rankingURL +error.getStackTrace() );
				a2nForRanking = null;
				loading.stop();
				loading.remove();
				loading = null;
				dataGrid_ranking.enabled = true;
			}
		}else if(rankingRenewButton.label == Message.L_CANCEL){
			a2nForRanking.rankingRenewCancel();
			a2nForRanking = null;
			rankingRenewButton.label = Message.L_RENEW;
			setEnableRadioButtons(true);
			rankingRenewButton.label = Message.L_RENEW;
			list_categoryList.enabled = true;
			dataGrid_ranking.enabled = true;
			
			loading.stop();
			loading.remove();
			loading = null;
		}else{
			Alert.show(Message.M_ALREADY_UPDATE_PROCESS_EXIST, Message.M_MESSAGE);
		}
	} else if(rankingRenewButton.label == Message.L_CANCEL){
		a2nForRanking.rankingRenewCancel();
		a2nForRanking = null;
		rankingRenewButton.label = Message.L_RENEW;
		setEnableRadioButtons(true);
		rankingRenewButton.label = Message.L_RENEW;
		list_categoryList.enabled = true;
		dataGrid_ranking.enabled = true;
		if(loading != null){
			loading.stop();
			loading.remove();
			loading = null;
		}

	}
}

/**
 * 
 * @param index
 * 
 */
private function downLoadedItemDoubleClicked(index:int):void{
	
	if(index > -1){
		this.playingVideoPath = this.downloadedListManager.getVideoPath(index);
		
		if(playListManager.isSelectedPlayList){
			playMovie(this.playingVideoPath, dataGrid_downloaded.selectedIndex, playListManager.getUrlListByIndex(list_playList.selectedIndex), 
				playListManager.getPlayListVideoNameList(list_playList.selectedIndex), playListManager.getPlayListNameByIndex(list_playList.selectedIndex));
		}else{
			playMovie(this.playingVideoPath, index);
		}
	}
}

/**
 * 
 * 
 */
private function downLoadedItemPlay():void{
	
	var index:int = this.dataGrid_downloaded.selectedIndex;
	if(index > -1){
		this.playingVideoPath = this.downloadedListManager.getVideoPath(index);
		playMovie(this.playingVideoPath, index);
	}
	
}

/**
 * 動画の再生を開始します。
 * @param url 動画のURLを指定します。
 * @param startIndex 動画のindexを指定します。これはプレイリストを使った再生の際に指定します。プレイリストを使わない場合は-1を指定してください。
 * @param playList プレイリストを使って再生する場合、プレイリストを指定します。Playerに渡されるプレイリストはこの配列のコピーです。
 * @param videoNameList 
 * 
 */
private function playMovie(url:String, startIndex:int, playList:Array = null, videoNameList:Array = null, playListName:String = null):void{
	
	try{
		if(url.length > 0){
			if(url.indexOf("http") == -1){
				var file:File = new File(url);
				
				if(!file.exists){
					var videoId:String = LibraryManager.getVideoKey(file.nativePath);
					if(videoId != null){
						var video:NNDDVideo = libraryManager.isExist(videoId);
						if(video != null){
							file = new File(video.getDecodeUrl());
						}
					}
				}
				
				if(!file.exists){
					Alert.show(Message.M_FILE_NOT_FOUND_REFRESH + "\n" + file.nativePath, Message.M_ERROR);
					logManager.addLog(Message.M_FILE_NOT_FOUND_REFRESH + "\n" + file.nativePath);
					return;
				}
				url = file.url;
			}else{
//				url = url;
			}
			
			if(!playerController.isOpen()){
				playerController.destructor();
				playerController = null;
				playerController = new PlayerController(logManager, MAILADDRESS, PASSWORD, libraryFile, libraryManager, playListManager)
				playerController.open();
			}
			if(startIndex != -1 && playList != null){
				if(videoNameList != null){
					playerController.playMovie(url, playList.slice(0), videoNameList.slice(0), startIndex, playListName);
				}else{
					playerController.playMovie(url, playList.slice(0), null, startIndex, playListName);
				}
			}else{
				playerController.playMovie(url);
			}
		}
	}catch(error:Error){
		Alert.show("再生に失敗しました\n" + url + "\n" + error, Message.M_ERROR);
		logManager.addLog("再生に失敗しました。\nurl:" + url + "\nError:" + error + ":" + error.getStackTrace());
	}
	
}

/**
 * 
 * 最新のコメントに更新
 */
private function newCommentDownloadButtonClicked(isCommentOnly:Boolean = false):void{
	if(newCommentDownloadButton.enabled == true && newCommentOnlyDownloadButton.enabled == true){
		if(this.newCommentDownloadButton.label != Message.L_CANCEL && this.newCommentOnlyDownloadButton.label != Message.L_CANCEL){
		
			if(this.dataGrid_downloaded.selectedIndex >= 0){
				
				if(isCommentOnly){
					this.newCommentOnlyDownloadButton.label = Message.L_CANCEL;
					this.newCommentDownloadButton.enabled = false;
				}else{
					this.newCommentDownloadButton.label = Message.L_CANCEL;
					this.newCommentOnlyDownloadButton.enabled = false;
				}
				
				var filePath:String = this.downloadedListManager.getVideoPath(this.dataGrid_downloaded.selectedIndex);
				if(filePath.indexOf("http://") == 0){
					newCommentOnlyDownloadButton.label = "コメントのみ更新";
					newCommentDownloadButton.label = "ビデオ以外を更新";
					newCommentOnlyDownloadButton.enabled = true;
					newCommentDownloadButton.enabled = true;
					
					Alert.show("この動画はまだダウンロードされていません。先にダウンロードしてください。", Message.M_MESSAGE);
					return;
				}
				
				var fileName:String = filePath.substring(filePath.lastIndexOf("/")+1);
				
				var videoID:String = PathMaker.getVideoID(fileName);
//				trace(array);
				if(videoID == null){
//					trace(fileName);
					newCommentOnlyDownloadButton.label = "コメントのみ更新";
					newCommentDownloadButton.label = "ビデオ以外を更新";
					newCommentOnlyDownloadButton.enabled = true;
					newCommentDownloadButton.enabled = true;
					if(isCommentOnly){
						logManager.addLog(Message.M_VIDEOID_NOTFOUND_FOR_COMMENT_ONLY + "\n" + filePath);
						Alert.show(Message.M_VIDEOID_NOTFOUND_FOR_COMMENT_ONLY, Message.M_ERROR);
					}else{
						logManager.addLog(Message.M_VIDEOID_NOTFOUND + "\n" + filePath);
						Alert.show(Message.M_VIDEOID_NOTFOUND, Message.M_ERROR);
					}
					return;
				}
				
				if(videoID.length >= 3){
					if(renewDownloadManager == null){
//						trace(videoID);
						fileName = PathMaker.getVideoName(filePath);
						var videoURL:String = "http://www.nicovideo.jp/watch/"+videoID;
						var index:int = this.dataGrid_downloaded.selectedIndex;
						
						if((filePath.substring(filePath.indexOf(this.libraryFile.url)+this.libraryFile.url.length+1)).indexOf("/") != -1){
							var rankingListName:String = filePath.substring(0,filePath.lastIndexOf("/"));
							rankingListName = rankingListName.substring(rankingListName.lastIndexOf("/")+1);
						}
						
						if(isCommentOnly){
							logManager.addLog("***コメントのみを更新***\n" + filePath);
						}else{
							logManager.addLog("***ビデオ以外を更新***\n" + filePath);
						}
						
						renewDownloadManager = new RenewDownloadManager(downloadedProvider, logManager);
						renewDownloadManager.addEventListener(RenewDownloadManager.PROCCESS_FAIL, function(event:Event):void{
							newCommentOnlyDownloadButton.label = "コメントのみ更新";
							newCommentDownloadButton.label = "ビデオ以外を更新";
				
							newCommentOnlyDownloadButton.enabled = true;
							newCommentDownloadButton.enabled = true;
							
							renewDownloadManager = null;
						});
						renewDownloadManager.addEventListener(RenewDownloadManager.PROCCESS_CANCEL, function(event:Event):void{
							newCommentOnlyDownloadButton.label = "コメントのみ更新";
							newCommentDownloadButton.label = "ビデオ以外を更新";
				
							newCommentOnlyDownloadButton.enabled = true;
							newCommentDownloadButton.enabled = true;
							
							renewDownloadManager = null;
						});
						renewDownloadManager.addEventListener(RenewDownloadManager.PROCCESS_COMPLETE, function(event:Event):void{
							
							var video:NNDDVideo = libraryManager.remove(LibraryManager.getVideoKey(filePath), false);
							if(video == null){
								if(!new File(filePath).exists){
									Alert.show("ファイルが見つかりませんでした。\n" + new File(filePath).nativePath, Message.M_ERROR);
									return;
								}
								video = libraryManager.loadInfo(filePath);
								video.modificationDate = new File(filePath).modificationDate;
								video.creationDate = new File(filePath).creationDate;
							}
							var thumbUrl:String = (event.currentTarget as RenewDownloadManager).localThumbUri;
							var isLocal:Boolean = false;
							try{
								//すでにローカルのファイルが設定されてるなら再設定しない。
								var file:File = new File(video.thumbUrl);
								if(file.exists){
									isLocal = true;
								}
							}catch(e:Error){
								trace(e);
							}
							
							//thumbUrlのURLがローカルで無ければ無条件で上書き
							if(!isLocal){
								if(thumbUrl != null){
									//新しく取得したthumbUrlを設定
									video.thumbUrl = thumbUrl;
								}else if (video.thumbUrl == null || video.thumbUrl == ""){
									//thumbUrlが取れない==動画は削除済
									video.thumbUrl = "http://www.nicovideo.jp/img/common/delete.jpg";
								}
							}
							
							libraryManager.add(video, true);
							
							newCommentOnlyDownloadButton.label = "コメントのみ更新";
							newCommentDownloadButton.label = "ビデオ以外を更新";
				
							newCommentOnlyDownloadButton.enabled = true;
							newCommentDownloadButton.enabled = true;
								
							renewDownloadManager = null;
						});
						
						if(isCommentOnly){
							renewDownloadManager.renewForCommentOnly(this.MAILADDRESS, this.PASSWORD, PathMaker.getVideoID(filePath), PathMaker.getVideoName(filePath), new File(filePath.substring(0, filePath.lastIndexOf("/")+1)), this.isReNameOldComment);
						}else{
							renewDownloadManager.renewForOtherVideo(this.MAILADDRESS, this.PASSWORD, PathMaker.getVideoID(filePath), PathMaker.getVideoName(filePath), new File(filePath.substring(0, filePath.lastIndexOf("/")+1)), this.isReNameOldComment);
						}
						
					}else{
						Alert.show("更新が既に進行中です。", Message.M_MESSAGE);
					}
				}else{
					trace(fileName);
					newCommentOnlyDownloadButton.label = "コメントのみ更新";
					newCommentDownloadButton.label = "ビデオ以外を更新";
					newCommentOnlyDownloadButton.enabled = true;
					newCommentDownloadButton.enabled = true;
					if(isCommentOnly){
						logManager.addLog(Message.M_VIDEOID_NOTFOUND_FOR_COMMENT_ONLY + "\n" + filePath);
						Alert.show(Message.M_VIDEOID_NOTFOUND_FOR_COMMENT_ONLY, Message.M_ERROR);
					}else{
						logManager.addLog(Message.M_VIDEOID_NOTFOUND + "\n" + filePath);
						Alert.show(Message.M_VIDEOID_NOTFOUND, Message.M_ERROR);
					}
				}
			}
		}else{
			
			newCommentOnlyDownloadButton.label = "コメントのみ更新";
			newCommentDownloadButton.label = "ビデオ以外を更新";
			
			renewDownloadManager.close();
			renewDownloadManager = null;
			
			newCommentOnlyDownloadButton.enabled = true;
			newCommentDownloadButton.enabled = true;
		}
	}
}

/**
 * 
 * 
 */
private function searchDLListTextInputChange():void{
	this.downloadedListManager.searchAndShow(dataGrid_downloaded, tileList_tag, textInput_searchInDLList.text);
}

/**
 * 
 * 
 */
private function searchTagListTextInputChange():void{
	if(isEnableLibrary){
		var word:String = textInput_searchInTagList.text;
		
		if(word.length > 0){
			this.libraryManager.searchTagAndShow(tileList_tag, textInput_searchInTagList.text);
		}else{
			if(!this.playListManager.isSelectedPlayList){
//				if(isShowOnlyNowLibraryTag){
					if(this.selectedLibraryFile == null){
						libraryManager.tagManager.tagRenew(tileList_tag, this.libraryFile);
					}else{
						libraryManager.tagManager.tagRenew(tileList_tag, this.selectedLibraryFile);
					}
//				}else{
//					libraryManager.tagManager.tagRenew(tileList_tag);
//				}
			}else{
				libraryManager.tagManager.tagRenewOnPlayList(tileList_tag, playListManager.getUrlListByIndex(playListManager.selectedPlayListIndex));
			}
		}
	}
	
}

/**
 * ライブラリのツリーが選択されたときに呼ばれます。
 * 
 */
private function sourceChanged(index:int):void{
	if(isEnableLibrary){
		if(index > -1){
			list_playList.selectedIndex = -1;
			this.playListManager.isSelectedPlayList = false;
			this.selectedLibraryFile = (tree_FileSystem.selectedItem as File);
			this.libraryManager.tagManager.tagRenew(tileList_tag, selectedLibraryFile);
			this.downloadedListManager.updateDownloadedListItems(this.selectedLibraryFile.url);
			searchDLListTextInputChange();
		}else if(index == -1){
			list_playList.selectedIndex = -1;
			this.playListManager.isSelectedPlayList = false;
			this.libraryManager.tagManager.tagRenew(tileList_tag, selectedLibraryFile);
			this.downloadedListManager.updateDownloadedListItems(this.libraryFile.url);
			searchDLListTextInputChange();
		}
		(this.dataGrid_downloaded.dataProvider as ArrayCollection).sort = new Sort();
		(this.dataGrid_downloaded.dataProvider as ArrayCollection).sort.fields = [new SortField(this.libraryDataGridSortFieldName, false, this.libraryDataGridSortDescending)];
		(this.dataGrid_downloaded.dataProvider as ArrayCollection).refresh();
	}
}

/**
 * 
 * @param event
 * 
 */
private function fileNameEditButtonClicked(event:Event):void{
	var file:File = new File(tree_FileSystem.selectedPath);
	var url:String = decodeURIComponent(file.url);
	
	if(url == null || url.length < -1 || libraryFile.url == new File(url).url){
		return;
	}
	
	var nameEditDialog:NameEditDialog = PopUpManager.createPopUp(nndd, NameEditDialog, true) as NameEditDialog;
	nameEditDialog.initNameEditDialog(logManager, libraryManager, url);
	nameEditDialog.addEventListener(Event.COMPLETE, function():void{
		tree_FileSystem.refresh();
	});
	// ダイアログを中央に表示
	PopUpManager.centerPopUp(nameEditDialog);
}

/**
 * 
 * @param event
 * 
 */
private function playListNameEditButtonClicked(event:Event):void{
	var url:String = libraryManager.systemFileDir.url + "/playList/" + list_playList.selectedItem;
	var selectedIndex:int = list_playList.selectedIndex;
	if(!(list_playList.selectedIndex > -1 && (url.indexOf(".m3u") == -1 || url.indexOf(".M3U") == -1))){
		return;
	}
	var nameEditDialog:NameEditDialog = PopUpManager.createPopUp(nndd, NameEditDialog, true) as NameEditDialog;
	nameEditDialog.initNameEditDialog(logManager, libraryManager, url, true);
	nameEditDialog.label_info.text = "新しいプレイリスト名を入力してください。";
	nameEditDialog.addEventListener(Event.COMPLETE, function():void{
		var newUrl:String = nameEditDialog.getNewFilePath();
		if(newUrl.indexOf(".m3u") == -1 && newUrl.indexOf(".M3U") == -1){
			newUrl = newUrl + ".m3u";
		}
		
		trace(newUrl);
		playListManager.reNamePlayList(selectedIndex, decodeURIComponent(newUrl.substring(newUrl.lastIndexOf("/")+1)));
	});
	// ダイアログを中央に表示
	PopUpManager.centerPopUp(nameEditDialog);
}

/**
 * 
 * 
 */
private function addDirectory():void{
	
	var url:String = libraryFile.url;
	if(tree_FileSystem.selectedIndex > -1){
		var tempFile:File = new File(tree_FileSystem.selectedPath);
		url = decodeURIComponent(tempFile.url);
	}
	var pFile:File = new File(url);
	var array:Array = pFile.getDirectoryListing();
	var newFileUrl:String = url + "/新規フォルダ"
	
	var file:File = new File(newFileUrl);
	for(var i:int; i<array.length; i++){
		if(!file.exists){
			break;
		}
		file = new File(newFileUrl+(i+1));
	}
	try{
		file.createDirectory();
		tree_FileSystem.refresh();
		tree_FileSystem.openSubdirectory(file.nativePath);
	}catch(e:Error){
		Alert.show("フォルダの作成に失敗しました。" + e, "エラー");
		logManager.addLog("フォルダの作成に失敗しました:" + e.getStackTrace());
	}
	
}

/**
 * 
 * 
 */
private function deleteDirectory():void{
	var tempFile:File = new File(tree_FileSystem.selectedPath);
	if(tree_FileSystem.selectedIndex > -1 && !(tempFile.url == libraryFile.url)){
		try{
			Alert.show("フォルダ内のすべての項目も同時に削除されます。よろしいですか？", "警告", Alert.YES | Alert.NO, null, function(event:CloseEvent):void{
				if(event.detail == Alert.YES){
					var url:String = decodeURIComponent(tempFile.url);
					var file:File = new File(url);
					file.moveToTrash();
					tree_FileSystem.refresh();
				}
			}, null, Alert.NO);
			
		}catch(e:Error){
			Alert.show("フォルダの削除に失敗しました。" + e, "エラー");
			logManager.addLog("フォルダの削除に失敗しました:" + e.getStackTrace());
		}
	}
}

/**
 * 
 * 
 */
private function logoutButtonClicked():void{
	
	this.logoutButton.enabled = false;
	saveStore();
	this.logout();
}

/**
 * ニコニコ動画からのログアウトを行います。
 * 
 */
private function logout(isBootTime:Boolean = true):void
{
	var loader:URLLoader = new URLLoader();
	
	var login:Login = new Login();
	login.addEventListener(Login.LOGOUT_COMPLETE, function(event:Event):void{
		if(isBootTime){
			readStore(true);
			versionCheck(false);
		}
		logoutButton.enabled = true;
		logoutButton.label = "ログイン";
	});
	
	this.MAILADDRESS = "";
	this.PASSWORD = "";
	
	if(this.downloadManager != null){
		this.downloadManager.stop();
		this.downloadManager.setMailAndPass(this.MAILADDRESS, this.PASSWORD);
	}
	
	login.logout();
	logManager.addLog(logoutButton.label);
	
}

private function windowMove(event:FlexNativeWindowBoundsEvent):void{
	lastRect = event.afterBounds;
}

private function saveStore():void{
	try{
		
		/* 終了前処理 */
		//現在の保存先を保存
		EncryptedLocalStore.removeItem("libraryURL");
		var bytes:ByteArray = new ByteArray();
		bytes.writeUTFBytes(libraryFile.url);
		EncryptedLocalStore.setItem("libraryURL", bytes);
		
		// ウィンドウの位置情報保存
		EncryptedLocalStore.removeItem("windowPosition_x");
		bytes = new ByteArray();
		bytes.writeDouble(lastRect.x);
		EncryptedLocalStore.setItem("windowPosition_x", bytes);
		
		EncryptedLocalStore.removeItem("windowPosition_y");
		bytes = new ByteArray();
		bytes.writeDouble(lastRect.y);
		EncryptedLocalStore.setItem("windowPosition_y", bytes);
		
		EncryptedLocalStore.removeItem("windowPosition_w");
		bytes = new ByteArray();
		bytes.writeDouble(lastRect.width);
		EncryptedLocalStore.setItem("windowPosition_w", bytes);
		
		EncryptedLocalStore.removeItem("windowPosition_h");
		bytes = new ByteArray();
		bytes.writeDouble(lastRect.height);
		EncryptedLocalStore.setItem("windowPosition_h", bytes);
		
		//挨拶
		EncryptedLocalStore.removeItem("isSayHappyNewYear");
		bytes = new ByteArray();
		bytes.writeBoolean(isSayHappyNewYear);
		EncryptedLocalStore.setItem("isSayHappyNewYear", bytes);
		
		//自動DL
		EncryptedLocalStore.removeItem("isAutoDownload");
		bytes = new ByteArray();
		bytes.writeBoolean(isAutoDownload);
		EncryptedLocalStore.setItem("isAutoDownload", bytes);
		
		//エコノミー時の確認有無
		EncryptedLocalStore.removeItem("isEnableEcoCheck");
		bytes = new ByteArray();
		bytes.writeBoolean(isEnableEcoCheck);
		EncryptedLocalStore.setItem("isEnableEcoCheck", bytes);
		
		//選択されているランキング期間
		EncryptedLocalStore.removeItem("rankingTarget");
		bytes = new ByteArray();
		bytes.writeInt(this.target);
		EncryptedLocalStore.setItem("rankingTarget", bytes);
		
		//選択されているランキング対象
		EncryptedLocalStore.removeItem("rankingPeriod");
		bytes = new ByteArray();
		bytes.writeInt(this.period);
		EncryptedLocalStore.setItem("rankingPeriod", bytes);
		
		//起動時更新をしないかどうか
		EncryptedLocalStore.removeItem("isRankingRenewAtStart");
		bytes = new ByteArray();
		bytes.writeBoolean(isRankingRenewAtStart);
		EncryptedLocalStore.setItem("isRankingRenewAtStart", bytes);
		
		/*サイドバーのプレイリストの高さを保存*/
		if(this.lastCanvasPlaylistHight != -1){
			EncryptedLocalStore.removeItem("canvasPlaylistHight");
			bytes = new ByteArray();
			bytes.writeInt(lastCanvasPlaylistHight);
			EncryptedLocalStore.setItem("canvasPlaylistHight", bytes);
		}
		
		/*サムネイルの大きさを保存*/
		EncryptedLocalStore.removeItem("thumbImangeSize");
		bytes = new ByteArray();
		bytes.writeDouble(slider_thumbImageSize.value);
		EncryptedLocalStore.setItem("thumbImangeSize", bytes);
		
		if(this.thumbImgSizeForMyList != -1){
			EncryptedLocalStore.removeItem("thumbImgSizeForMyList");
			bytes = new ByteArray();
			bytes.writeDouble(thumbImgSizeForMyList);
			EncryptedLocalStore.setItem("thumbImgSizeForMyList", bytes);
		}
		
		if(this.thumbImgSizeForSearch != -1){
			EncryptedLocalStore.removeItem("thumbImgSizeForSearch");
			bytes = new ByteArray();
			bytes.writeDouble(thumbImgSizeForSearch);
			EncryptedLocalStore.setItem("thumbImgSizeForSearch", bytes);
		}
		
		/*タグビューの大きさを保存*/
		if(this.lastCanvasTagTileListHight != -1){
			EncryptedLocalStore.removeItem("lastCanvasTagTileListHight");
			bytes = new ByteArray();
			bytes.writeInt(lastCanvasTagTileListHight);
			EncryptedLocalStore.setItem("lastCanvasTagTileListHight", bytes);
		}
		
		/*すべてのタグを表示するか*/
//		EncryptedLocalStore.removeItem("isShowOnlyNowLibraryTag");
//		bytes = new ByteArray();
//		bytes.writeBoolean(isShowOnlyNowLibraryTag);
//		EncryptedLocalStore.setItem("isShowOnlyNowLibraryTag", bytes);
		
		/*常にエコノミーモードでダウンロードするかどうか*/
		EncryptedLocalStore.removeItem("isAlwaysEconomy");
		bytes = new ByteArray();
		bytes.writeBoolean(isAlwaysEconomy);
		EncryptedLocalStore.setItem("isAlwaysEconomy", bytes);
		
		/*表示するタグの大きさ*/
		if(this.lastTagWidth != -1){
			EncryptedLocalStore.removeItem("tagWidth");
			bytes = new ByteArray();
//			bytes.writeDouble(slider_tagWidth.value);
			EncryptedLocalStore.setItem("tagWidth", bytes);
		}
		
		/* ランキングダブルクリックでストリーミング再生するかどうか */
		EncryptedLocalStore.removeItem("isDoubleClickOnStreaming");
		bytes = new ByteArray();
		bytes.writeBoolean(isDoubleClickOnStreaming);
		EncryptedLocalStore.setItem("isDoubleClickOnStreaming", bytes);
		
		/* 外部ストリーミングプレーヤ設定 */
		EncryptedLocalStore.removeItem("isOutStreamingPlayerUse");
		bytes = new ByteArray();
		bytes.writeBoolean(isOutStreamingPlayerUse);
		EncryptedLocalStore.setItem("isOutStreamingPlayerUse", bytes);
		
		/* カテゴリリストの横幅 */
		if(this.lastCategoryListWidth != -1){
			EncryptedLocalStore.removeItem("lastCategoryListWidth");
			bytes = new ByteArray();
			bytes.writeInt(lastCategoryListWidth);
			EncryptedLocalStore.setItem("lastCategoryListWidth", bytes);
		}
		
		/* ライブラリの横幅 */
		if(this.lastLibraryWidth != -1){
			EncryptedLocalStore.removeItem("lastLibraryWidth");
			bytes = new ByteArray();
			bytes.writeInt(lastLibraryWidth);
			EncryptedLocalStore.setItem("lastLibraryWidth", bytes);
		}
		
		/* マイリストの高さ */
		if(this.lastMyListHeight != -1){
			EncryptedLocalStore.removeItem("lastMyListHeight");
			bytes = new ByteArray();
			bytes.writeInt(lastMyListHeight);
			EncryptedLocalStore.setItem("lastMyListHeight", bytes);
		}
		
		/* マイリスト一覧の横幅 */
		if(this.lastMyListSummaryWidth != -1){
			EncryptedLocalStore.removeItem("lastMyListSummaryWidth");
			bytes = new ByteArray();
			bytes.writeInt(lastMyListSummaryWidth);
			EncryptedLocalStore.setItem("lastMyListSummaryWidth", bytes);
		}
		
		/* 検索条件一覧の横幅 */
		if(this.lastSearchItemListWidth != -1){
			EncryptedLocalStore.removeItem("lastSearchItemListWidth");
			bytes = new ByteArray();
			bytes.writeInt(lastSearchItemListWidth);
			EncryptedLocalStore.setItem("lastSearchItemListWidth", bytes);
		}
		
		/* ライブラリを特定のフィールドでソートするかどうか */
		if(this.libraryDataGridSortFieldName != null && this.libraryDataGridSortFieldName != ""){
			EncryptedLocalStore.removeItem("libraryDataGridSortFieldName");
			bytes = new ByteArray();
			bytes.writeUTF(libraryDataGridSortFieldName);
			EncryptedLocalStore.setItem("libraryDataGridSortFieldName", bytes);
		}
		
		/* ライブラリを降順に並べるかどうか */
		EncryptedLocalStore.removeItem("libraryDataGridSortDescending");
		bytes = new ByteArray();
		bytes.writeBoolean(libraryDataGridSortDescending);
		EncryptedLocalStore.setItem("libraryDataGridSortDescending", bytes);
		
		
		/* ライブラリを使うかどうか */
		EncryptedLocalStore.removeItem("isEnableLibrary");
		bytes = new ByteArray();
		bytes.writeBoolean(isEnableLibrary);
		EncryptedLocalStore.setItem("isEnableLibrary", bytes);
		
		/* デフォルトの検索項目が追加済かどうか */
		EncryptedLocalStore.removeItem("isAddedDefSearchItems");
		bytes = new ByteArray();
		bytes.writeBoolean(isAddedDefSearchItems);
		EncryptedLocalStore.setItem("isAddedDefSearchItems", bytes);
		
		/* メインウィンドウを閉じてもアプリケーションを終了しないかどうか*/
		EncryptedLocalStore.removeItem("isDisEnableAutoExit");
		bytes = new ByteArray();
		bytes.writeBoolean(isDisEnableAutoExit);
		EncryptedLocalStore.setItem("isDisEnableAutoExit", bytes);
		
		/* コメントを更新したときに古いファイルを別名保存するかどうか */
		EncryptedLocalStore.removeItem("isReNameOldComment");
		bytes = new ByteArray();
		bytes.writeBoolean(isReNameOldComment);
		EncryptedLocalStore.setItem("isReNameOldComment", bytes);
		
		/*タイマー設定*/
		if(this.scheduleManager != null){
			this.scheduleManager.saveSchedule();
		}
		
		/*ダウンロードリスト保存*/
		if(this.downloadManager != null){
			this.downloadManager.stop();
			this.downloadManager.saveDownloadList();
		}
		
	}catch(error:Error){
		trace(error.getStackTrace());
	}
}

/**
 * 
 * 
 */
public function exitButtonClicked():void{
	
	logManager.addLog("終了処理を開始");
	
	var timer:Timer = new Timer(200, 1);
	
	var loadWindow:LoadWindow = PopUpManager.createPopUp(nndd, LoadWindow, true) as LoadWindow;
	loadWindow.label_loadingInfo.text = "設定を保存しています...";
	loadWindow.progressBar_loading.label = "保存中...";
	PopUpManager.centerPopUp(loadWindow);
	
	playerController.stop();
	
	timer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void{
		
		restore();
		
		playerController.playerExit();
		
		saveStore();
		
		loadWindow.label_loadingInfo.text = "ダウンロードリストを保存しています...";
		loadWindow.validateNow();
		//ダウンロードリスト保存
		downloadManager.stop();
		downloadManager.saveDownloadList();
		
		loadWindow.label_loadingInfo.text = "プレイリストを保存しています...";
		loadWindow.validateNow();
		//プレイリスト保存
		playListManager.saveAllPlayList()
		
		loadWindow.label_loadingInfo.text = "ライブラリを保存しています...";
		loadWindow.validateNow();
		//ライブラリ保存
		libraryManager.saveLibraryFile(libraryManager.systemFileDir);
		
		loadWindow.label_loadingInfo.text = "マイリスト一覧を保存しています...";
		loadWindow.validateNow();
		//マイリストを保存
		_myListManager.saveMyListSummary(libraryManager.systemFileDir);
		
		loadWindow.label_loadingInfo.text = "検索条件を保存しています...";
		loadWindow.validateNow();
		//検索条件を保存
		_searchItemManager.saveSearchItems(libraryManager.systemFileDir);
		
		loadWindow.label_loadingInfo.text = "再生履歴を保存しています...";
		loadWindow.validateNow();
		//再生履歴を保存
		historyManager.saveHistory();
		
		PopUpManager.removePopUp(loadWindow);
		
		_exitProcessCompleted = true;
		
		logManager.addLog("終了処理完了");
		
		exit();
		
	});
	
	timer.start();
	

}

/**
 * 
 * 
 */
private function windowClose(event:Event):void{
	
	if(event.cancelable){
		event.preventDefault();
	}
	
	if(isDisEnableAutoExit && ( NativeApplication.supportsSystemTrayIcon || NativeApplication.supportsDockIcon)){
		
		this.visible = false;
		
	}else{	//システムトレイもDockもサポートしていないときはアプリケーションを終了
		
		exitButtonClicked();
		
	}
}

private function exitingEventHandler(event:Event):void{
	
	logManager.addLog(event.toString());
	
	if(!_exitProcessCompleted){
		
		event.preventDefault();
		
		this.activate();
		
		exitButtonClicked();
		
	}
	
}

/**
 * ニコニコ動画内を検索語で検索します。
 * 
 */
private function searchNicoButtonClicked(url:String = null):void{
	if(a2nForSearch == null){
		if(textInput_NicoSearch.text.length > 0 || url != null){
			
			isRankingWatching = false;
			
			var searchWord:String = this.textInput_NicoSearch.text
			var searchUrl:String = Access2Nico.NICO_SEARCH_TYPE_URL[combobox_serchType.selectedIndex];
			searchPageCountProvider = new Array();
			if(url != null){
				searchWord = url.substring(url.lastIndexOf("/")+1);
			}else{
				searchPageCountProvider.push(1);
				combobox_pageCounter_search.selectedIndex = searchPageCountProvider.indexOf(1);
				searchWord = encodeURIComponent(searchWord);
				this.searchPageIndex = 1;
			}
			
			try{
				
				loading = new LoadingPicture();
				loading.show(dataGrid_search, dataGrid_ranking.width/2, dataGrid_ranking.height/2);
				loading.start(360/12);
				
//				setEnableSearchButton(false);
//				radiogroup_period.enabled = false;
//				radiogroup_target.enabled = false;
//				rankingRenewButton.enabled = false;
//				list_categoryList.enabled = false;
				button_SearchNico.label = Message.L_CANCEL;
				
				a2nForSearch = new Access2Nico(null, downloadedListManager, playerController, logManager, playerController.getCommentListProvider());
				a2nForSearch.addEventListener(Access2Nico.NICO_SEARCH_COMPLETE, function(event:Event):void{
//					setEnableSearchButton(true);
//					radiogroup_period.enabled = true;
//					radiogroup_target.enabled = true;
//					rankingRenewButton.enabled = true;
//					list_categoryList.enabled = true;
					button_SearchNico.label = "検索";
					searchPageLinkList = a2nForSearch.getPageLinkList();
					
					//リンクリストを更新
					if(searchPageLinkList != null){
						searchPageCountProvider.splice(0,searchPageCountProvider.length);
						searchPageCountProvider.push(searchPageIndex);
						for(var i:int=0; i<searchPageLinkList.length/2; i++){
							searchPageCountProvider.push(searchPageLinkList[i][1]);
						}
					}
					label_totalCount.text = "(合計: " + searchPageCountProvider.length + "ページ )";
					logManager.addLog("検索結果を更新:"+ searchUrl + searchWord);
					
					a2nForSearch = null;
					loading.stop();
					loading.remove();
					loading = null;
				});
				a2nForSearch.request_search(Access2Nico.TOP_PAGE_URL, Access2Nico.LOGIN_URL, this.MAILADDRESS, this.PASSWORD, searchUrl, searchWord , searchProvider, libraryManager, comboBox_sortType.selectedIndex, this.searchPageIndex);
			}catch(error:Error){
//				setEnableSearchButton(true);
//				radiogroup_period.enabled = true;
//				radiogroup_target.enabled = true;
//				rankingRenewButton.enabled = true;
//				list_categoryList.enabled = true;
				loading.stop();
				loading.remove();
				loading = null;
				button_SearchNico.label = "検索";
				Alert.show("検索中に想定外の例外が発生しました。\n"+ error + "\nURL:" + searchUrl + encodeURIComponent(searchWord), "エラー");
				logManager.addLog("検索中に想定外の例外が発生しました。\n"+ error +  "\nURL:"+ searchUrl + encodeURIComponent(searchWord) + "\n" + error.getStackTrace() );
				a2nForSearch = null;
			}
		}
	}else if(button_SearchNico.label == Message.L_CANCEL){
		a2nForSearch.searchCancel();
		a2nForSearch = null;
//		setEnableSearchButton(true);
//		radiogroup_period.enabled = true;
//		radiogroup_target.enabled = true;
//		rankingRenewButton.enabled = true;
//		list_categoryList.enabled = true;
		button_SearchNico.label = "検索";
		if(loading != null){
			loading.stop();
			loading.remove();
			loading = null;
		}
	}else{
	}
}

/**
 * 
 * @param event
 * 
 */
private function nicoSearchComboboxClosed(event:Event):void{
	
}

/**
 * 
 * @param event
 * 
 */
private function nicoSearchEnter(event:Event):void{
	searchNicoButtonClicked();
}

/**
 * 
 * 
 */
private function versionCheckCheckBoxChenged():void{
	var bytes:ByteArray = new ByteArray();
	bytes.writeBoolean(checkBox_versionCheck.selected);
	EncryptedLocalStore.setItem("isVersionCheckEnable", bytes);
}

private function disEnableAutoExitCheckBoxChanged(event:Event):void{
	
	this.isDisEnableAutoExit = checkBox_DisEnableAutoExit.selected;
	
	this.autoExit = !isDisEnableAutoExit;
	
}

/**
 * ページ数選択用コンボボックスの値が変更されたときに呼ばれます
 * 
 */
private function rankingPageCountChanged():void{
	if(rankingPageLinkList.length > 0 && combobox_pageCounter_ranking.selectedIndex >= 0 ){
		this.rankingPageIndex = new int(combobox_pageCounter_ranking.selectedLabel);
		
		rankingRenewButtonClicked(rankingPageLinkList[getIndexByPageCountForRanking(rankingPageIndex)][0]);
		
		rankingPageCountProvider.unshift(rankingPageIndex);
		combobox_pageCounter_ranking.selectedIndex = rankingPageCountProvider.indexOf(rankingPageIndex);
	}
}

/**
 * 
 * 
 */
private function searchPageCountChanged():void{
	if(searchPageLinkList.length > 0 && combobox_pageCounter_search.selectedIndex >= 0 ){
		this.searchPageIndex = new int(combobox_pageCounter_search.selectedLabel);
		searchNicoButtonClicked(searchPageLinkList[getIndexByPageCountForSearch(searchPageIndex)][0]);
		
		searchPageCountProvider.unshift(searchPageIndex);
		combobox_pageCounter_search.selectedIndex = searchPageCountProvider.indexOf(searchPageIndex);
	}
}


/**
 * 次へボタンが押されたときに呼ばれるキーリスナーです。
 * 
 */
private function nextButtonClicked():void{
	if(rankingPageCountProvider.length > 0){
		if(rankingPageLinkList != null && rankingPageLinkList.length > 0){
			var index:int = getIndexByPageCountForRanking(rankingPageIndex+1);
			if(index != -1){
				this.rankingPageIndex++;
				
				rankingRenewButtonClicked(rankingPageLinkList[index][0]);
				
				rankingPageCountProvider.push(rankingPageIndex);
				combobox_pageCounter_ranking.selectedIndex = rankingPageCountProvider.indexOf(rankingPageIndex);
			}
		}
	}
}

/**
 * 
 * 
 */
private function searchNextButtonClicked():void{
	if(searchPageCountProvider.length > 0){
		if(searchPageLinkList != null && searchPageLinkList.length > 0){
			var index:int = getIndexByPageCountForSearch(searchPageIndex+1);
			if(index != -1){
				this.searchPageIndex++;
				
				searchNicoButtonClicked(searchPageLinkList[index][0]);
				
				searchPageCountProvider.push(searchPageIndex);
				combobox_pageCounter_search.selectedIndex = searchPageCountProvider.indexOf(searchPageIndex);
			}
		}
	}
}

/**
 * 戻るボタンを押されたときに呼ばれるキーリスナーです。
 * 
 */
private function backButtonClicked():void{
	if(rankingPageCountProvider.length > 0){
		if(rankingPageLinkList != null && rankingPageLinkList.length > 0){
			var index:int = getIndexByPageCountForRanking(rankingPageIndex-1);
			if(index != -1){
				this.rankingPageIndex--;
				rankingRenewButtonClicked(rankingPageLinkList[index][0]);
				rankingPageCountProvider.push(rankingPageIndex);
				combobox_pageCounter_ranking.selectedIndex = rankingPageCountProvider.indexOf(rankingPageIndex);
			}
		}
	}
}

/**
 * 戻るボタンを押されたときに呼ばれるキーリスナーです。
 * 
 */
private function searchBackButtonClicked():void{
	if(searchPageCountProvider.length > 0){
		if(searchPageLinkList != null && searchPageLinkList.length > 0){
			var index:int = getIndexByPageCountForSearch(searchPageIndex-1);
			if(index != -1){
				this.searchPageIndex--;
				searchNicoButtonClicked(searchPageLinkList[index][0]);
				searchPageCountProvider.push(searchPageIndex);
				combobox_pageCounter_search.selectedIndex = searchPageCountProvider.indexOf(searchPageIndex);
			}
		}
	}
}


/**
 * 指定されたページ番号に対応するURLが配列のどのインデックスに格納されているかを返します。
 * @param pageCount
 * @return 
 * 
 */
private function getIndexByPageCountForRanking(pageCount:int):int{
	for(var i:int = 0; i<rankingPageLinkList.length; i++){
		if(rankingPageLinkList[i][1] == pageCount){
			return i;
		}
	}
	return -1;
}

/**
 * 
 * @param pageCount
 * @return 
 * 
 */
private function getIndexByPageCountForSearch(pageCount:int):int{
	for(var i:int = 0; i<searchPageLinkList.length; i++){
		if(searchPageLinkList[i][1] == pageCount){
			return i;
		}
	}
	return -1;
}


/**
 * 検索関係ボタンの有効・無効を一括設定します
 * @param isEnable
 * 
 */
private function setEnableSearchButton(isEnable:Boolean):void{
	button_back.enabled = isEnable;
	button_next.enabled = isEnable;
	combobox_pageCounter_ranking.enabled = isEnable;
}

/**
 * 
 * @param index
 * 
 */
private function playListItemClicked(index:int):void{
	
	playListManager.downLoadedProvider.sort = null;
	playListManager.downLoadedProvider.refresh();
	
	playListManager.isSelectedPlayList = true;
	tree_FileSystem.selectedIndex = -1;
	playListManager.selectedPlayListIndex = index;
	playListManager.showPlayList(playListManager.selectedPlayListIndex);
	libraryManager.tagManager.tagRenewOnPlayList(tileList_tag, playListManager.getPlayListVideoListByIndex(playListManager.selectedPlayListIndex));
	searchDLListTextInputChange();
}

/**
 * 
 * @param event
 * 
 */
private function playListItemDoubleClicked(event:ListEvent):void{
	playListItemClicked(event.rowIndex);
	
	this.playingVideoPath = this.downloadedListManager.getVideoPath(0);
	
	if(this.playingVideoPath != null){
		
		playMovie(this.playingVideoPath, 0, playListManager.getUrlListByIndex(list_playList.selectedIndex), 
			playListManager.getPlayListVideoNameList(list_playList.selectedIndex), playListManager.getPlayListNameByIndex(list_playList.selectedIndex));

	}	
}

/**
 * 
 * 
 */
private function addPlayListButtonClicked():void{
	
	playListManager.addPlayList();
}

/**
 * 
 * 
 */
private function deletePlayListButtonClicked():void{
	if(list_playList.selectedIndex >= 0){
		playListManager.removePlayListByIndex(list_playList.selectedIndex);
	}
}

private function treeItemDragEnter(event:DragEvent):void{
//	if(tree_FileSystem.indexToItemRenderer(tree_FileSystem.calculateDropIndex(event)) != null){
		var initiator:IUIComponent = event.currentTarget as IUIComponent;
		DragManager.acceptDragDrop(initiator);
//	}
}

private function myListItemDroped(event:DragEvent):void{
	
	if(event.dragInitiator == this.dataGrid_downloaded){
	
		//プレイリストに項目を追加します。
		event.preventDefault();
		list_playList.hideDropFeedback(event);
		
		var selectedPlayListIndex:int = this.list_playList.calculateDropIndex(event);
		//		trace(this.dataGrid_downloaded.selectedIndex);
		var selectedItemArray:Array = dataGrid_downloaded.selectedItems;
		var i:int = 0;
		var videos:Array = new Array();
		for(i=0; i<selectedItemArray.length; i++){
			var nnddVideo:NNDDVideo = new NNDDVideo(selectedItemArray[i].dataGridColumn_videoPath);
			videos.push(nnddVideo);
		}
		playListManager.addNNDDVideos(selectedPlayListIndex, videos);
	
	}else{
		//プレイリストの順番を変える（未サポート）
	}
	
}


private function itemDroped(event:DragEvent):void{
	if(event.target == dataGrid_downloaded){
		
		//dataGrid_downloaded内で項目を並べ替えます
		var selectedIndexArray:Array = dataGrid_downloaded.selectedIndices;
		selectedIndexArray.sort();
		var j:int = 0;
		
		//プレイリストの時
		if(this.playListManager.isSelectedPlayList){
			
			var pIndex:int = list_playList.selectedIndex;
			var dropIndex:int = dataGrid_downloaded.calculateDropIndex(event);
			var tempArray:Array = new Array();
			var shiftCount:int = 0;
			
			for(j=0; j<selectedIndexArray.length; j++){
				var nnddVideo:NNDDVideo = new NNDDVideo(downloadedProvider[selectedIndexArray[j]].dataGridColumn_videoPath);
				tempArray.push(nnddVideo);
				if(dropIndex > selectedIndexArray[j]){
					shiftCount++;
				}
			}
			
			playListManager.removePlayListItemByIndex(pIndex, selectedIndexArray);
			playListManager.addNNDDVideos(pIndex, tempArray);
			
			(this.dataGrid_downloaded.dataProvider as ArrayCollection).refresh();
			
			playListManager.downLoadedProvider.sort = null;
			playListManager.downLoadedProvider.refresh();
			
		}else{	//ライブラリの時
			
			//元のDataGridから取り除く。
			for(j=0; j<selectedIndexArray.length; j++){
				downloadedProvider.removeItemAt(selectedIndexArray[j]);
			}
		}
	}else if(event.target == tree_FileSystem && !playListManager.isSelectedPlayList){
		
		event.preventDefault();
//		tree_FileSystem.hideDropFeedback(event);
		
		if(event.dragInitiator == this.tree_FileSystem){
			
			//フォルダの場所を移動します
			var newIndex:int = this.tree_FileSystem.calculateDropIndex(event);
			var oldIndex:int = this.tree_FileSystem.selectedIndex;
			if(oldIndex != newIndex && newIndex != 0){
				try{
					var newFile:File = File(this.tree_FileSystem.indexToItemRenderer(tree_FileSystem.calculateDropIndex(event)).data);
					var oldUrl:String = this.tree_FileSystem.selectedItem.url;
					var newUrl:String = newFile.url + "/" + oldUrl.substring(oldUrl.lastIndexOf("/")+1);
					if(newUrl == oldUrl){
						//階層が上に行くとき
						newFile.url = newFile.url.substring(0, newFile.url.lastIndexOf("/")+1) + "/" + oldUrl.substring(oldUrl.lastIndexOf("/")+1);
					}else{
						//階層が下に行くとき
						newFile.url = newUrl;
					}
					try{
						var loadingWindow:LoadWindow = PopUpManager.createPopUp(this, LoadWindow) as LoadWindow;
						PopUpManager.centerPopUp(loadingWindow);
						loadingWindow.label_loadingInfo.text = "フォルダを移動中...";
						(this.tree_FileSystem.selectedItem as File).moveTo(newFile, false);
						PopUpManager.removePopUp(loadingWindow);
						this.tree_FileSystem.refresh();
						this.tree_FileSystem.openSubdirectory(newFile.nativePath);
						logManager.addLog("フォルダを移動:" + decodeURIComponent(newFile.url));
						// TODO 毎回ライブラリを更新するのはやり過ぎ
//						libraryManager.loadLibraryFile(libraryFile, false, true);
					}catch(error:Error){
						this.tree_FileSystem.refresh();
						PopUpManager.removePopUp(loadingWindow);
						Alert.show("フォルダを移動できませんでした。", "エラー");
						logManager.addLog("フォルダの移動に失敗:" + error.getStackTrace());
					}
				}catch(error:Error){
					this.tree_FileSystem.refresh();
				}
			}
		}else if(event.dragInitiator == this.dataGrid_downloaded && !playListManager.isSelectedPlayList){
			
			//項目の保存されているディレクトリを変更します
			var newFile:File = File(this.tree_FileSystem.indexToItemRenderer(tree_FileSystem.calculateDropIndex(event)).data);
			
			var log:String = "";
			var moveFileName:String = "";
			
			try{
				
				var loadingWindow:LoadWindow = PopUpManager.createPopUp(this, LoadWindow) as LoadWindow;
				PopUpManager.centerPopUp(loadingWindow);
				loadingWindow.label_loadingInfo.text = "ファイルを移動中...";
				
				var selectedItems:Array = dataGrid_downloaded.selectedItems;
				
				for(var k:int=0; k<selectedItems.length; k++){
					
					var oldUrl:String = selectedItems[k].dataGridColumn_videoPath;
					var oldFile:File = new File(oldUrl);
					moveFileName = decodeURIComponent(oldFile.url);
					
					var myNewFile:File = new File(newFile.url + oldFile.url.substring(oldFile.url.lastIndexOf("/")));
					
					if(myNewFile.url == oldFile.url){
						continue;
					}
					
					if(myNewFile.exists){
						Alert.show(Message.M_FILE_ALREADY_EXISTS + ":" + decodeURIComponent(oldFile.url.substring(oldFile.url.lastIndexOf("/")+1)), Message.M_MESSAGE, Alert.YES | Alert.NO, null, function(event:CloseEvent):void{
							if(event.detail == Alert.YES){
								moveFile(oldFile, myNewFile, false);
								PopUpManager.removePopUp(loadingWindow);
							}else{
								tree_FileSystem.refresh();
								sourceChanged(tree_FileSystem.selectedIndex);
							}
						});
					}else{
						moveFile(oldFile, myNewFile, false);
					}
				}
				
				//ライブラリを保存
				libraryManager.saveLibraryFileByDefault();
				
				PopUpManager.removePopUp(loadingWindow);
				
				tree_FileSystem.refresh();
				sourceChanged(tree_FileSystem.selectedIndex);
				
			}catch(error:Error){
				Alert.show("ファイルの移動に失敗:" + error, "エラー");
				logManager.addLog("ファイルの移動に失敗:" + moveFile + "\n" + error.getStackTrace());
				this.tree_FileSystem.refresh();
				sourceChanged(tree_FileSystem.selectedIndex);
				PopUpManager.removePopUp(loadingWindow);
				
			}
		}
	}
	
}

/**
 * oldFileで指定されたビデオをnewFileで指定されたパスへ移動します。
 * @param oldFile 移動前のビデオの場所を表すFile
 * @param newFile 移動後のビデオの場所を表すFile
 * @param isSaveLibrary ファイルを移動した後、ライブラリを保存するかどうかです
 * 
 */
private function moveFile(oldFile:File, newFile:File, isSaveLibrary:Boolean):void{
	try{
		
		//ビデオを移動
		if(newFile.exists){
			newFile.deleteFile();
		}
		oldFile.moveTo(newFile);
		logManager.addLog(Message.MOVE_FILE + ":" + decodeURIComponent(oldFile.url) + " -> " + decodeURIComponent(newFile.url));
		
		//ライブラリを更新
		var key:String = LibraryManager.getVideoKey(decodeURIComponent(oldFile.url));
		var video:NNDDVideo = null;
		
		//videoIDが無ければライブラリの管理対象にならない
		if(key != null){
			
			video = libraryManager.isExist(key);
			
			if(video != null){
				video.uri = newFile.url;			
			}else{
				video = libraryManager.loadInfo(newFile.url);
				logManager.addLog("動画を新たに管理対象に追加:" + video.videoName);
			}
			
			libraryManager.update(video, false);
			logManager.addLog("動画のパスを更新:" + oldFile.nativePath + " -> " + newFile.nativePath);
			
		}
		
		//コメントも移動する
		oldFile.url = oldFile.url.substring(0, oldFile.url.lastIndexOf(".")) + ".xml";
		var moveFileName:String = decodeURIComponent(oldFile.url);
		if(oldFile.exists){
			newFile.url = newFile.url.substring(0, newFile.url.lastIndexOf(".")) + ".xml";
			if(newFile.exists){
				newFile.deleteFile();
			}
			oldFile.moveTo(newFile);
			logManager.addLog(Message.MOVE_FILE + ":" + decodeURIComponent(oldFile.url) + " -> " + decodeURIComponent(newFile.url));
		}
		
		//投稿者コメントも移動する
		oldFile.url = oldFile.url.substring(0, oldFile.url.lastIndexOf(".")) + "[Owner].xml";
		moveFileName = decodeURIComponent(oldFile.url);
		if(oldFile.exists){
			newFile.url = newFile.url.substring(0, newFile.url.lastIndexOf(".")) + "[Owner].xml";
			if(newFile.exists){
				newFile.deleteFile();
			}
			oldFile.moveTo(newFile);
			logManager.addLog(Message.MOVE_FILE + ":" + decodeURIComponent(oldFile.url) + " -> " + decodeURIComponent(newFile.url));
		}

		//サムネイル情報も移動
		//アイドルマスター 伊織 Love You PV風‐ニコニコ動画(秋) - [sm5082988][ThumbInfo].xml
		oldFile.url = oldFile.url.substring(0, oldFile.url.lastIndexOf("Owner")) + "ThumbInfo].xml";
		moveFileName = decodeURIComponent(oldFile.url);
		if(oldFile.exists){
			newFile.url = newFile.url.substring(0, newFile.url.lastIndexOf("Owner")) + "ThumbInfo].xml";
			if(newFile.exists){
				newFile.deleteFile();
			}
			oldFile.moveTo(newFile);
			logManager.addLog(Message.MOVE_FILE + ":" + decodeURIComponent(oldFile.url) + " -> " + decodeURIComponent(newFile.url));
		}

		//市場情報も移動
		var iChibaOldFile:File = new File(oldFile.url.substring(0, oldFile.url.lastIndexOf("ThumbInfo")) + "IchibaInfo].html");
		moveFileName = decodeURIComponent(iChibaOldFile.url);
		if(iChibaOldFile.exists){
			newFile.url = newFile.url.substring(0, newFile.url.lastIndexOf("ThumbInfo")) + "IchibaInfo].html";
			if(newFile.exists){
				newFile.deleteFile();
			}
			iChibaOldFile.moveTo(newFile);
			logManager.addLog(Message.MOVE_FILE + ":" + decodeURIComponent(iChibaOldFile.url) + " -> " + decodeURIComponent(newFile.url));
		}
		
		//サムネ画像も移動
		try{
			var thumbImgFile:File = new File(video.thumbUrl);
		}catch(error:Error){
			thumbImgFile = new File(oldFile.url.substring(0, oldFile.url.lastIndexOf("ThumbInfo")) + "ThumbImg].jpeg");
		}
		moveFileName = decodeURIComponent(thumbImgFile.url);
		if(thumbImgFile.exists){
			newFile.url = newFile.url.substring(0, newFile.url.lastIndexOf("/")) + thumbImgFile.url.substring(thumbImgFile.url.lastIndexOf("/"));
			if(newFile.exists){
				newFile.deleteFile();
			}
			thumbImgFile.moveTo(newFile);
			logManager.addLog(Message.MOVE_FILE + ":" + decodeURIComponent(thumbImgFile.url) + " -> " + decodeURIComponent(newFile.url));
			
			//ライブラリを更新
			key = LibraryManager.getVideoKey(decodeURIComponent(video.getDecodeUrl()));
			var tempVideo:NNDDVideo = null;
			
			//ライブラリのVideoのサムネイル画像を更新
			if(key != null){
				tempVideo = libraryManager.isExist(key);
				if(tempVideo != null){
					tempVideo.thumbUrl = decodeURIComponent(newFile.url);
					if(!libraryManager.update(tempVideo, false)){
						logManager.addLog("動画がすでに登録されています:" + tempVideo.getDecodeUrl());
						trace("動画がすでに登録されている(サムネイル画像更新1)");
					}
				}else{
					video.thumbUrl = decodeURIComponent(newFile.url);
					if(!libraryManager.add(video, false)){
						logManager.addLog("動画がすでに登録されています:" + video.getDecodeUrl());
						trace("動画がすでに登録されている(サムネイル画像更新2)");
					}
				}
			}
		}
		
		//ニコ割も移動
		var nicowariFile:File = new File(decodeURIComponent(oldFile.url).substring(0, decodeURIComponent(oldFile.url).lastIndexOf("/")));
		var myArray:Array = nicowariFile.getDirectoryListing();
		var fileName:String = decodeURIComponent(oldFile.url).substring(decodeURIComponent(oldFile.url).lastIndexOf("/")+1, decodeURIComponent(oldFile.url).lastIndexOf("[ThumbInfo]"));
		for each(var file:File in myArray){
			if(!file.isDirectory){
				var extensions:String = file.nativePath.substr(-4);
				if(extensions == ".swf"){
					if((decodeURIComponent(file.url).indexOf(fileName) != -1) && decodeURIComponent(file.url).match(/\[Nicowari\]/)){
						moveFileName = decodeURIComponent(file.url);
						newFile.url = newFile.url.substring(0, newFile.url.lastIndexOf("/")) + file.url.substring(file.url.lastIndexOf("/"));
						if(file.exists){
							if(newFile.exists){
								newFile.deleteFile();
							}
							file.moveTo(newFile);
							logManager.addLog(Message.MOVE_FILE + ":" + decodeURIComponent(oldFile.url) + " -> " + decodeURIComponent(newFile.url));
						}
					}
				}
			}
		}
		
		if(video != null && isSaveLibrary){
			libraryManager.saveLibraryFileByDefault();
		}
		
	}catch(error:Error){
		logManager.addLog(error + ":" + moveFile + "->" + decodeURIComponent(newFile.url) + "\n" + error.getStackTrace());
		trace(error + ":" + moveFile + "->" + decodeURIComponent(newFile.url) + "\n" + error.getStackTrace());
		throw error;
	}
}


private function windowPositionReset():void{
	// ウィンドウの位置情報を初期化
	try{
		EncryptedLocalStore.removeItem("windowPosition_x");
		EncryptedLocalStore.removeItem("windowPosition_y");
		EncryptedLocalStore.removeItem("windowPosition_w");
		EncryptedLocalStore.removeItem("windowPosition_h");
		
	}catch(error:Error){
		Alert.show(Message.M_LOCAL_STORE_IS_BROKEN, Message.M_ERROR);
		logManager.addLog(Message.M_LOCAL_STORE_IS_BROKEN + error.getStackTrace());
		EncryptedLocalStore.reset();
	}
	
	if(this.nativeWindow != null){
		this.nativeWindow.x = 0;
		this.nativeWindow.y = 0;
	}
	this.width = 850;
	this.height = 600;
	
	playerController.resetWindowPosition();
	
	logManager.addLog(Message.WINDOW_POSITION_RESET);
	Alert.show(Message.WINDOW_POSITION_RESET, Message.M_MESSAGE);
	
}

private function renewLibraryButtonClicked():void{
	
//	Alert.show("動画のエコノミーモードに関する情報が失われます。よろしいですか？","警告", Alert.YES | Alert.NO, null, function(event:CloseEvent):void{
//		if(event.detail == Alert.YES){
			libraryManager.loadLibraryFile(LibraryManager.getInstance().systemFileDir, LibraryManager.getInstance().libraryDir, false, true);
//		}
//	});
}

private function dataGridDownloadedChanged(event:FlexEvent):void{
	if(playListManager.isSelectedPlayList){
		playListManager.downLoadedProvider = this.downloadedProvider;
		(this.dataGrid_downloaded.dataProvider as ArrayCollection).sort = new Sort();
  		(this.dataGrid_downloaded.dataProvider as ArrayCollection).sort.fields = [new SortField(this.libraryDataGridSortFieldName, false, this.libraryDataGridSortDescending)];
		(this.dataGrid_downloaded.dataProvider as ArrayCollection).refresh();
	}
}

private function thumbSizeChanged(event:SliderEvent):void{
	
	dataGrid_ranking.rowHeight = 50*event.value;
	dataGridColumn_thumbImage.width = 60*event.value;
}

private function thumbSizeChangedForSearch(event:SliderEvent):void{
	this.thumbImgSizeForSearch = event.value;
	dataGrid_search.rowHeight = 50*event.value;
	dataGridColumn_thumbImage_Search.width = 60*event.value;
}

private function thumbSizeChangedForMyList(event:SliderEvent):void{
	this.thumbImgSizeForMyList = event.value;
	dataGrid_myList.rowHeight = 50*event.value;
	dataGridColumn_thumbUrl.width = 60*event.value;
}

private function dlButtonClicked():void{
	var a2n:Access2Nico = new Access2Nico(null, null, playerController, logManager, null);
	a2n.request_ichiba(Access2Nico.TOP_PAGE_URL, Access2Nico.LOGIN_URL, this.MAILADDRESS, this.PASSWORD, "sm280671");
}

private function donation():void{
	navigateToURL(new URLRequest("http://d.hatena.ne.jp/MineAP/20080730/donation"));
}

private function checkBoxAutoDLChanged(event:Event):void{
	isAutoDownload = (event.currentTarget as CheckBox).selected;
}

private function checkBoxEcoCheckChanged(event:Event):void{
	isEnableEcoCheck = (event.currentTarget as CheckBox).selected;
	this.downloadManager.isContactTheUser = isEnableEcoCheck;
}

private function downloadListDoubleClicked(event:ListEvent):void{
	//videoIDはあるか？
	var videoId:String = LibraryManager.getVideoKey(event.itemRenderer.data.col_videoName);
	if(videoId != null){
		//ライブラリに登録済か？
		var video:NNDDVideo = libraryManager.isExist(videoId);
		if(video != null){
			this.playMovie(video.getDecodeUrl(), -1);
			return;
		}
	}
	//ファイルを直接見に行く。
	var videoPath:String = event.itemRenderer.data.col_downloadedPath;
	if(videoPath != null && videoPath != "undefined"){
		this.playMovie(videoPath, -1);
		return;
	}
	//ファイルが無い。ストリーミングしとく。
	videoPath = event.itemRenderer.data.col_videoUrl;
	if(videoPath != null && videoPath != "undefined"){
		this.playMovie(videoPath, -1);
		return;
	}
}

private function deleteDLListButtonClicked(event:Event):void{
	downloadManager.deleteSelectedItems(dataGrid_downloadList.selectedIndices);
}

private function addDLListButtonClicked(event:Event = null, clip:Clipboard = null):void{
	var clipboard:Clipboard = Clipboard.generalClipboard;
	if(clip != null){
		clipboard = clip;
	}
	if(MAILADDRESS != "" && PASSWORD != ""){
		if(clipboard.hasFormat(ClipboardFormats.TEXT_FORMAT)){
			var url:String = String(clipboard.getData(ClipboardFormats.TEXT_FORMAT));
			
			var matchResult:Array = url.match(new RegExp("http://www.nicovideo.jp/watch/"));
			if(matchResult != null && matchResult.length > 0){
				var video:NNDDVideo = new NNDDVideo(url, "-");
				downloadManager.add(video, isAutoDownload);
				return;
			}
			
			var videoId:String = LibraryManager.getVideoKey(url);
			if(videoId != null){
				url = "http://www.nicovideo.jp/watch/" + videoId;
				var video:NNDDVideo = new NNDDVideo(url, "-");
				downloadManager.add(video, isAutoDownload);
				return;
			}
			
			Alert.show("動画のURL以外は追加できません。\n" + url, Message.M_ERROR);
			logManager.addLog("動画のURL以外は追加できません:" + url);
			
		}else{
			Alert.show("クリップボードにURLが存在しません。", Message.M_ERROR);
		}
	}
	
}

private function queueKeyDownHandler(event:KeyboardEvent):void{
	if(viewstack1.selectedIndex == DOWNLOAD_LIST_TAB_NUM){
		if(event.ctrlKey){
			isCtrlKeyPush = true;
		}
	}
}

private function queueKeyUpHandler(event:KeyboardEvent):void{
	if(viewstack1.selectedIndex == DOWNLOAD_LIST_TAB_NUM){
		if(event.keyCode == Keyboard.DELETE || event.keyCode == Keyboard.BACKSPACE){
			downloadManager.deleteSelectedItems(dataGrid_downloadList.selectedIndices);
		}else if(isCtrlKeyPush && event.keyCode == Keyboard.V){
			isCtrlKeyPush = false;
			addDLListButtonClicked();
		}
	}
}

private function queueMenuHandler(event:Event):void{
	if(viewstack1.selectedIndex == DOWNLOAD_LIST_TAB_NUM){
		addDLListButtonClicked();
	}
}

public function playerOpenButtonClicked(event:Event):void{
	playerOpen();
}

public function playerOpen():void{
	if(playerController != null && playerController.isOpen()){
		playerController.videoInfoView.activate();
		playerController.videoPlayer.activate();
	}else{
		playerController = null;
		playerController = new PlayerController(logManager, MAILADDRESS, PASSWORD, libraryFile, libraryManager, playListManager)
		playerController.open();
	}
}

private function dlListDroped(event:NativeDragEvent):void{
	if(event.clipboard.hasFormat(ClipboardFormats.TEXT_FORMAT)){
		addDLListButtonClicked(null, event.clipboard);
	}
}

private function dlListDragEnter(event:NativeDragEvent):void{
	if(event.clipboard.hasFormat(ClipboardFormats.TEXT_FORMAT)){
		NativeDragManager.acceptDragDrop(dataGrid_downloadList);
	}
}

private function changeIsRankingRenewAtStart(event:Event):void{
	isRankingRenewAtStart = checkbox_isRankingRenewAtStart.selected;
}

//private function showOnlyNowLibraryTagCheckboxChanged(event:MouseEvent):void{
//	
//	isShowOnlyNowLibraryTag = checkbox_showOnlyNowLibraryTag.selected;
//	
//	if(!this.playListManager.isSelectedPlayList){
//		if((event.currentTarget as CheckBox).selected){
//			if(this.selectedLibraryFile == null){
//				libraryManager.tagManager.tagRenew(tileList_tag, this.libraryFile);
//			}else{
//				libraryManager.tagManager.tagRenew(tileList_tag, this.selectedLibraryFile);
//			}
//		}else{
//			libraryManager.tagManager.tagRenew(tileList_tag);
//		}
//	}else{
//		libraryManager.tagManager.tagRenewOnPlayList(tileList_tag, playListManager.getUrlListByIndex(playListManager.selectedPlayListIndex));
//	}
//	
//}

private function tileListHeightChanged(event:ResizeEvent):void{
	lastCanvasTagTileListHight = (event.currentTarget as Canvas).height;
}

private function tagTileListClicked(event:Event):void{
	
	var array:Array = (event.currentTarget as TileList).selectedItems;
	trace(array);	
	
	if(!playListManager.isSelectedPlayList){
		this.downloadedListManager.searchAndShowByTag(dataGrid_downloaded, array);
	}else{
		this.downloadedListManager.searchAndShowByTag(dataGrid_downloaded, array);
	}
	
	if(textInput_searchInDLList.text.length > 0){
		this.searchDLListTextInputChange();
	}
}

private function checkBoxOutStreamingPlayerChanged(event:Event):void{
	this.isOutStreamingPlayerUse = (event.currentTarget as CheckBox).selected;
}

private function checkBoxDoubleClickOnStreamingChanged(event:Event):void{
	this.isDoubleClickOnStreaming = (event.currentTarget as CheckBox).selected;
}

private function error(event:ErrorEvent):void{
	if(logManager != null){
		logManager.addLog("ハンドルされないエラーです。:" + event + "\ntarget:" + event.target + "\ncurrent:" + event.currentTarget);
	}
	Alert.show("ハンドルされないエラーです。\n" + event);
}


private function addDownloadListButtonClickedForMyList():void{
	
	var index:int = dataGrid_myList.selectedIndex;
	if(index > -1 && index < dataGrid_myList.dataProvider.length){
		
		var videoUrl:String = dataGrid_myList.dataProvider[index].dataGridColumn_videoUrl;
		var videoName:String = dataGrid_myList.dataProvider[index].dataGridColumn_videoName;
		
		if(videoUrl.indexOf("http://www.nicovideo.jp/watch/") != -1){
			//ダウンロード
			var video:NNDDVideo = new NNDDVideo(videoUrl, videoName);
			addDownloadListForMyList(video, index);
		}
		
	}
	
}

private function addDownloadListButtonClickedForSearch():void{
	var index:int = dataGrid_search.selectedIndex;
	if(index > -1 && index < dataGrid_search.dataProvider.length){
		
		var videoUrl:String = dataGrid_search.dataProvider[index].dataGridColumn_nicoVideoUrl;
		var videoName:String = dataGrid_search.dataProvider[index].dataGridColumn_videoName;
		
		if(videoUrl.indexOf("http://www.nicovideo.jp/watch/") != -1){
			//ダウンロード
			var video:NNDDVideo = new NNDDVideo(videoUrl, videoName);
			addDownloadListForSearch(video, index);
		}
		
	}
}


private function videoStreamingPlayButtonClickedForMyList():void{
	var index:int = dataGrid_myList.selectedIndex;
	if(index > -1 && index < dataGrid_myList.dataProvider.length){
		
		var videoUrl:String = dataGrid_myList.dataProvider[index].dataGridColumn_videoUrl;
		var videoName:String = dataGrid_myList.dataProvider[index].dataGridColumn_videoName;
		
		if(videoUrl.indexOf("http://www.nicovideo.jp/watch/") != -1){
			//ストリーミング
			videoStreamingPlayStartButtonClicked(videoUrl);
		}
		
	}
}

private function videoStreamingPlayButtonClickedForSearch():void{
	var index:int = dataGrid_search.selectedIndex;
	if(index > -1 && index < dataGrid_search.dataProvider.length){
		
		var videoUrl:String = dataGrid_search.dataProvider[index].dataGridColumn_nicoVideoUrl;
		var videoName:String = dataGrid_search.dataProvider[index].dataGridColumn_videoName;
		
		if(videoUrl.indexOf("http://www.nicovideo.jp/watch/") != -1){
			//ストリーミング
			videoStreamingPlayStartButtonClicked(videoUrl);
		}
		
	}
}

/**
 * 
 * 
 */
private function myListItemDataGridDoubleClicked():void{
	var index:int = dataGrid_myList.selectedIndex;
	if(index > -1 && index < dataGrid_myList.dataProvider.length){
		
		var videoUrl:String = dataGrid_myList.dataProvider[index].dataGridColumn_videoUrl;
		var videoName:String = dataGrid_myList.dataProvider[index].dataGridColumn_videoName;
		
		if(videoUrl.indexOf("http://www.nicovideo.jp/watch/") != -1){
			//ダウンロード or ストリーミング
			if(isDoubleClickOnStreaming){
				//ストリーミング
				videoStreamingPlayStartButtonClicked(videoUrl);
			}else{
				//ダウンロード
				var video:NNDDVideo = new NNDDVideo(videoUrl, videoName);
				addDownloadListForMyList(video, index);
			}
			
		}
		
	}
}

/**
 * 
 * @param video
 * @param index
 * 
 */
private function addDownloadListForMyList(video:NNDDVideo, index:int = -1):void{
	
	var isExistsInDLList:Boolean = false;
	isExistsInDLList = downloadManager.isExists(video);
	
	if(isExistsInDLList){
		Alert.show(Message.M_ALREADY_DLLIST_VIDE_EXIST, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
			if(event.detail == Alert.YES){
				downloadManager.add(video, isAutoDownload);
				if(index != -1 && myListItemProvider.length > index){
					myListItemProvider.setItemAt({
						dataGridColumn_index: myListItemProvider[index].dataGridColumn_index,
						dataGridColumn_preview: myListItemProvider[index].dataGridColumn_preview,
						dataGridColumn_ranking: myListItemProvider[index].dataGridColumn_ranking,
						dataGridColumn_videoName: myListItemProvider[index].dataGridColumn_videoName,
						dataGridColumn_videoInfo: myListItemProvider[index].dataGridColumn_videoInfo,
						dataGridColumn_condition: "DLリストに追加済",
						dataGridColumn_videoUrl: myListItemProvider[index].dataGridColumn_videoUrl,
						dataGridColumn_downloadedItemUrl: myListItemProvider[index].dataGridColumn_downloadedItemUrl
					}, index);
				}
			}
		}, null, Alert.NO);
	}else{
		downloadManager.add(video, isAutoDownload);
		if(index != -1 && myListItemProvider.length > index){
			myListItemProvider.setItemAt({
				dataGridColumn_index: myListItemProvider[index].dataGridColumn_index,
				dataGridColumn_preview: myListItemProvider[index].dataGridColumn_preview,
				dataGridColumn_ranking: myListItemProvider[index].dataGridColumn_ranking,
				dataGridColumn_videoName: myListItemProvider[index].dataGridColumn_videoName,
				dataGridColumn_videoInfo: myListItemProvider[index].dataGridColumn_videoInfo,
				dataGridColumn_condition: "DLリストに追加済",
				dataGridColumn_videoUrl: myListItemProvider[index].dataGridColumn_videoUrl,
				dataGridColumn_downloadedItemUrl: myListItemProvider[index].dataGridColumn_downloadedItemUrl
			}, index);
		}
	}
}

/**
 * 
 * @param myListId
 * 
 */
public function renewMyList(myListId:String):void{
	
	
	if(viewstack1.selectedIndex != MYLIST_TAB_NUM){
	
		this.canvas_myList.addEventListener(FlexEvent.SHOW, renewMyListInner);
		
		viewstack1.selectedIndex = MYLIST_TAB_NUM;
	
	}else{
		renewMyListInner(null);
	}
	
	function renewMyListInner(event:FlexEvent):void{
		textinput_mylist.text = myListId;
		
		myListRenewButtonClicked(new MouseEvent(MouseEvent.CLICK));
		
		Application.application.activate();
		
		canvas_myList.removeEventListener(FlexEvent.SHOW, renewMyListInner);
	}
}


/**
 * 
 * @param event
 * 
 */
private function myListRenewButtonClicked(event:Event):void{
	try{
	
		var url:String = this.textinput_mylist.text;
		
		if(button_myListRenew.label == "更新" && this._nnddMyListLoader == null){
		
			if(url != null){
				
				tree_myList.enabled = false;
				dataGrid_myList.enabled = false;
				textinput_mylist.enabled = false;
				
				button_myListRenew.label == "キャンセル";
				loading = new LoadingPicture();
				loading.show(dataGrid_myList, dataGrid_myList.width/2, dataGrid_myList.height/2);
				loading.start(360/12);
				
				this._nnddMyListLoader = new NNDDMyListLoader(this.logManager, libraryManager);
				this._nnddMyListLoader.addEventListener(NNDDMyListLoader.DOWNLOAD_PROCESS_COMPLETE, function(myevent:Event):void{
					
					var myListBuilder:MyListBuilder = new MyListBuilder(logManager, libraryManager);
					myListItemProvider.removeAll();
					myListItemProvider.addAll(myListBuilder.getMyListArrayCollection(_nnddMyListLoader.xml));
					
					var text:String = myListBuilder.title + " [" + myListBuilder.creator + "]\n" + myListBuilder.description;
					var title:String = myListBuilder.title + " [" + myListBuilder.creator + "]";
					
					textArea_myList.text = PathMaker.getSpecialCharacterNotIncludedVideoName(decodeURIComponent(text));
					_myListManager.lastTitle = PathMaker.getSpecialCharacterNotIncludedVideoName(decodeURIComponent(title));
					
					button_myListRenew.label == "更新";
					dataGrid_myList.validateNow();
					if(loading != null){
						loading.stop();
						loading.remove();
						loading = null;
					}
					_nnddMyListLoader = null;
					tree_myList.enabled = true;
					dataGrid_myList.enabled = true;
					textinput_mylist.enabled = true;
				});
				this._nnddMyListLoader.addEventListener(NNDDMyListLoader.DOWNLOAD_PROCESS_ERROR, function(myevent:Event):void{
					logManager.addLog("マイリストの更新に失敗:" + url + ":" + myevent);
					Alert.show("マイリストの更新に失敗しました。\n" + myevent, Message.M_ERROR);
					button_myListRenew.label == "更新";
					if(loading != null){
						loading.stop();
						loading.remove();
						loading = null;
					}
					_nnddMyListLoader = null;
					tree_myList.enabled = true;
					dataGrid_myList.enabled = true;
					textinput_mylist.enabled = true;
				});
				this._nnddMyListLoader.addEventListener(NNDDMyListLoader.DOWNLOAD_PROCESS_CANCELD, function(myevent:Event):void{
					logManager.addLog("マイリストの更新をキャンセル:" + url + ":" + myevent);
					button_myListRenew.label == "更新";
					if(loading != null){
						loading.stop();
						loading.remove();
						loading = null;
					}
					_nnddMyListLoader = null;
					tree_myList.enabled = true;
					dataGrid_myList.enabled = true;
					textinput_mylist.enabled = true;
				});
				this._nnddMyListLoader.addEventListener(NNDDMyListLoader.PUBLIC_MY_LIST_GET_FAIL, function(myevent:Event):void{
					logManager.addLog("マイリストの更新に失敗:" + url + ":" + myevent);
					Alert.show("マイリストの更新に失敗しました。\nマイリストが削除されている可能性があります。\n" + myevent, Message.M_ERROR);
					button_myListRenew.label == "更新";
					if(loading != null){
						loading.stop();
						loading.remove();
						loading = null;
					}
					_nnddMyListLoader = null;
					tree_myList.enabled = true;
					dataGrid_myList.enabled = true;
					textinput_mylist.enabled = true;
				});
				
				var myListId:String = NNDDMyListLoader.getMyListId(url);
				if(myListId != null){
					this._nnddMyListLoader.requestDownloadForPublicMyList(this.MAILADDRESS, this.PASSWORD, myListId);
					return;
				}
				
				button_myListRenew.label == "更新";
				loading.stop();
				loading.remove();
				loading = null;
				_nnddMyListLoader = null;
				
				tree_myList.enabled = true;
				dataGrid_myList.enabled = true;
				textinput_mylist.enabled = true;
			}
		}else{
			//キャンセル
			button_myListRenew.label == "更新";
			
			if(loading != null){
				loading.stop();
				loading.remove();
			}
			
			tree_myList.enabled = true;
			dataGrid_myList.enabled = true;
			textinput_mylist.enabled = true;
			
			if(this._nnddMyListLoader != null){
				this._nnddMyListLoader.close(true, false);
				this._nnddMyListLoader = null;
			}
		}
	
	}catch(error:Error){
		
		//キャンセル
		button_myListRenew.label == "更新";
		
		if(loading != null){
			loading.stop();
			loading.remove();
		}
		
		tree_myList.enabled = true;
		dataGrid_myList.enabled = true;
		textinput_mylist.enabled = true;
		
		if(this._nnddMyListLoader != null){
			this._nnddMyListLoader.close(true, false);
		}
		
		Alert.show("マイリストの更新中に予期せぬ例外が発生しました。\n" + error, Message.M_ERROR);
		logManager.addLog("マイリスト更新中に予期せぬ例外が発生しました:" + error + ":" + error.getStackTrace());
	}
}

private function addPublicMyList(event:Event):void{
	
	var myListEditDialog:MyListEditDialog = PopUpManager.createPopUp(this, MyListEditDialog, true) as MyListEditDialog;
	PopUpManager.centerPopUp(myListEditDialog);
	myListEditDialog.initNameEditDialog(logManager);
	var name:String = this._myListManager.lastTitle;
	if(name != null && name.length < 1){
		name = textinput_mylist.text;
	}
	myListEditDialog.textInput_name.text = name;
	myListEditDialog.textInput_url.text = textinput_mylist.text;
	myListEditDialog.title = "マイリストを新規作成";
	myListEditDialog.button_edit.label = "作成";
	myListEditDialog.setDir(false);
	myListEditDialog.addEventListener(Event.COMPLETE, function(event:Event):void{
		var isSuccess:Boolean = _myListManager.addMyList(myListEditDialog.myListUrl, myListEditDialog.myListName, myListEditDialog.getIsDir(), true);
		if(!isSuccess){
			Alert.show("同名のマイリストかフォルダがすでに存在します。別な名前を設定してください。", Message.M_MESSAGE);
			return;
		}
		var openItems:Object = tree_myList.openItems;
		tree_myList.dataProvider = myListProvider;
		tree_myList.validateNow();
		tree_myList.openItems = openItems;
		PopUpManager.removePopUp(myListEditDialog);
	});
	
}

private function removePublicMyList(event:Event):void{
	var selectedItems:Array = tree_myList.selectedItems;
	if(selectedItems != null && selectedItems.length > 0){
		if(selectedItems.length == 1){
			var searchItemName:String = selectedItems[0];
			var label:String = "このマイリストを削除してもよろしいですか？\n";
			if(selectedItems[0].hasOwnProperty("label")){
				searchItemName = selectedItems[0].label;
				label = "このフォルダを削除してもよろしいですか？\n(フォルダ下のマイリストも削除されます。)\n";
			}
			
			Alert.show(label + searchItemName, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
				if(event.detail == Alert.YES){
					_myListManager.removeMyList(searchItemName, true);
					var openItems:Object = tree_myList.openItems;
					tree_myList.dataProvider = myListProvider;
					tree_myList.validateNow();
					tree_myList.openItems = openItems;
				}
			}, null, Alert.NO);
		}else{
			var selectedItemNames:Array = new Array();
			for(var i:int=0; i<selectedItems.length; i++){
				var searchItemName:String = selectedItems[i];
				if(selectedItems[i].hasOwnProperty("label")){
					searchItemName = selectedItems[i].label;
				}
				selectedItemNames.push(searchItemName);
			}
			
			Alert.show("これらのマイリストを削除してもよろしいですか？\n" + selectedItemNames, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
				if(event.detail == Alert.YES){
					for(var i:int=0; i<selectedItemNames.length; i++){
						_myListManager.removeMyList(selectedItemNames[i], true);
					}
					var openItems:Object = tree_myList.openItems;
					tree_myList.dataProvider = myListProvider;
					tree_myList.validateNow();
					tree_myList.openItems = openItems;
				}
			}, null, Alert.NO);
		}
	}
	
}

private function editPublicMyList(event:Event):void{
	var object:Object = tree_myList.selectedItem;
	var index:int = tree_myList.selectedIndex;
	
	if(object != null){
		
		var myListEditDialog:MyListEditDialog = PopUpManager.createPopUp(this, MyListEditDialog, true) as MyListEditDialog;
		PopUpManager.centerPopUp(myListEditDialog);
		myListEditDialog.initNameEditDialog(logManager);
		
		var selectedItem:Object = this.tree_myList.selectedItem;
		var name:String = "";
		if(selectedItem.hasOwnProperty("label")){
			name = selectedItem.label;
		}else{
			name = String(selectedItem);
		}
		myListEditDialog.textInput_name.text = name;
		myListEditDialog.textInput_url.text = _myListManager.getUrl(name);
		myListEditDialog.setDir(_myListManager.getMyListIdDir(name));
		myListEditDialog.comboBox_isFolder.enabled = false;
		myListEditDialog.addEventListener(Event.COMPLETE, function(event:Event):void{
			if(_myListManager.isExsits(myListEditDialog.myListName)){
				Alert.show("同名のマイリストかフォルダがすでに存在します。別な名前を設定してください。", Message.M_MESSAGE);
				return;
			}
			
			var myList:Object = _myListManager.search(name);
			
			if(myList.hasOwnProperty("children")){
				_myListManager.updateMyList(myListEditDialog.myListUrl, myListEditDialog.myListName, myListEditDialog.getIsDir(), true, name, myList.children);
			}else{
				_myListManager.updateMyList(myListEditDialog.myListUrl, myListEditDialog.myListName, myListEditDialog.getIsDir(), true, name, null);
			}
			
			var openItems:Object = tree_myList.openItems;
			tree_myList.dataProvider = myListProvider;
			tree_myList.validateNow();
			tree_myList.openItems = openItems;
			PopUpManager.removePopUp(myListEditDialog);
		});
	}
}

private function myListUrlChanged(event:Event):void{
	this._myListManager.lastTitle = "";
}

private function myListClicked(event:ListEvent):void{
	var name:String = String(event.itemRenderer.data.label);
	textinput_mylist.text = this._myListManager.getUrl(name);
}

private function myListDoubleClicked(event:ListEvent):void{
	var name:String = String(event.itemRenderer.data.label);
	textinput_mylist.text = this._myListManager.getUrl(name);
	
	this.myListRenewButtonClicked(event);
}

private function donationButtonClicked(event:Event):void{
	
	var donationRequest:URLRequest = new URLRequest("https://www.paypal.com/j1/cgi-bin/webscr");
	donationRequest.method = "post";
	
	var variables1:URLVariables = new URLVariables();
	variables1.cmd =  "_donations";
	variables1.business = "mineappproject@me.com";
	variables1.item_name = "MineApplicationProject";
	variables1.item_number = "NNDD";
	variables1.currency_code = "JPY"
	
	donationRequest.data = variables1;
	
	navigateToURL(donationRequest);
}

private function dataGridLibraryHeaderReleaseHandler(event:Event):void{
	if(dataGrid_downloaded != null && (dataGrid_downloaded.dataProvider as ArrayCollection).sort != null){
		if(!playListManager.isSelectedPlayList){
			var sortFiled:SortField = (dataGrid_downloaded.dataProvider as ArrayCollection).sort.fields[0];
			this.libraryDataGridSortDescending = sortFiled.descending;
			this.libraryDataGridSortFieldName = sortFiled.name;
		}
	}
}

private function button_schedule_clickHandler(event:MouseEvent):void
{
	var scheduleWindow:ScheduleWindow = PopUpManager.createPopUp(this, ScheduleWindow, true) as ScheduleWindow;
	var schedule:Schedule = scheduleManager.schedule;
	if(schedule != null){
		scheduleWindow.initSchedule(schedule, scheduleManager.isScheduleEnable);
	}
	PopUpManager.centerPopUp(scheduleWindow);
	
	scheduleWindow.addEventListener(Event.COMPLETE, function(event:Event):void{
		var enable:Boolean = event.currentTarget.isScheduleEnable;
		scheduleManager.schedule = event.currentTarget.schedule;
		if(enable == true){
			//スケジューリング開始
			scheduleManager.isScheduleEnable = true;
			scheduleManager.timerStart();
		}else{
			//スケジューリング停止
			scheduleManager.isScheduleEnable = false;
			scheduleManager.timerStop();
		}
		
		label_nextDownloadTime.text = scheduleManager.scheduleString;
		
		PopUpManager.removePopUp(scheduleWindow);
	});
	scheduleWindow.addEventListener(Event.CANCEL, function(event:Event):void{
		//キャンセルなので操作しない
		PopUpManager.removePopUp(scheduleWindow);
	});
}

/**
 * 
 * @param event
 * 
 */
private function addSearchItem(event:MouseEvent):void{
	var searchItemEdit:SearchItemEdit = PopUpManager.createPopUp(this, SearchItemEdit, true) as SearchItemEdit;
	PopUpManager.centerPopUp(searchItemEdit);
	searchItemEdit.initSearchItem(new SearchItem("新規検索条件", comboBox_sortType.selectedIndex, combobox_serchType.selectedIndex, textInput_NicoSearch.text), true);
	searchItemEdit.addEventListener(Event.COMPLETE, function(event:Event):void{
		if(!_searchItemManager.addSearchItem(searchItemEdit.searchItem, searchItemEdit.searchItem.isDir, true)){
			Alert.show("すでに同名の検索条件が存在します。名前を変更してください。", Message.M_ERROR);
			return;
		}
		var object:Object = tree_SearchItem.openItems;
		tree_SearchItem.dataProvider = searchListProvider;
		tree_SearchItem.validateNow();
		tree_SearchItem.openItems = object;
		PopUpManager.removePopUp(searchItemEdit);
	});
	searchItemEdit.addEventListener(Event.CANCEL, function(event:Event):void{
		PopUpManager.removePopUp(searchItemEdit);
	});
}

/**
 * 
 * @param event
 * 
 */
private function removeSearchItem(event:MouseEvent):void{
	var selectedItems:Array = tree_SearchItem.selectedItems;
	if(selectedItems != null && selectedItems.length > 0){
		var searchItemNameArray:Array = new Array();
		
		for each(var object:Object in selectedItems){
			if(object.hasOwnProperty("label")){
				searchItemNameArray.push(String(object.label));
			}else{
				searchItemNameArray.push(String(object));
			}
		}
		
		if(selectedItems.length == 1){
			
			var item:SearchItem = _searchItemManager.getSearchItem(searchItemNameArray[0]);
			var text:String = "";
			if(item.isDir){
				text = "このフォルダを削除してもよろしいですか？\n" + searchItemNameArray[0];
			}else{
				text = "この検索条件を削除してもよろしいですか？\n" + searchItemNameArray[0];
			}
			
			Alert.show(text, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
				if(event.detail == Alert.YES){
					_searchItemManager.removeSearchItem(String(searchItemNameArray[0]), true);
					var object:Object = tree_SearchItem.openItems;
					tree_SearchItem.dataProvider = searchListProvider;
					tree_SearchItem.validateNow();
					tree_SearchItem.openItems = object;
				}
			}, null, Alert.NO);
		}else{
			
			Alert.show("これらの検索条件・フォルダを削除してもよろしいですか？\n" + searchItemNameArray, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
				if(event.detail == Alert.YES){
					for(var i:int=0; i<selectedItems.length; i++){
						_searchItemManager.removeSearchItem(selectedItems[i], true);
					}
					var object:Object = tree_SearchItem.openItems;
					tree_SearchItem.dataProvider = searchListProvider;
					tree_SearchItem.validateNow();
					tree_SearchItem.openItems = object;
				}
			}, null, Alert.NO);
		}
	}

}

/**
 * 
 * @param event
 * 
 */
private function editSearchItem(event:MouseEvent):void{
	var object:Object = tree_SearchItem.selectedItem;
	var index:int = tree_SearchItem.selectedIndex;
	if(object != null){
		
		var name:String = String(object);
		if(object.hasOwnProperty("label")){
			name = String(object.label);
		}
		
		var searchItemEdit:SearchItemEdit = PopUpManager.createPopUp(this, SearchItemEdit, true) as SearchItemEdit;
		PopUpManager.centerPopUp(searchItemEdit);
		var searchItem:SearchItem = this._searchItemManager.getSearchItem(name);
		searchItemEdit.initSearchItem(searchItem, false);
		searchItemEdit.setDir(searchItem.isDir);
		
		//編集ではフォルダのタイプを変えさせない
		searchItemEdit.comboBox_isFolder.enabled = false;
		
		searchItemEdit.addEventListener(Event.COMPLETE, function(event:Event):void{
			if(_searchItemManager.isExsits(searchItemEdit.searchItem.name)){
				Alert.show("同名の検索項目かフォルダが存在します。別な名前を設定してください。",Message.M_MESSAGE);
				return;
			}
			
			var searchItem:Object = _searchItemManager.search(name);
			
			if(searchItem.hasOwnProperty("children")){
				_searchItemManager.updateMyList(searchItemEdit.searchItem, true, true, name, searchItem.children);
			}else{
				_searchItemManager.updateMyList(searchItemEdit.searchItem, true, true, name, null);
			}
			
			var object:Object = tree_SearchItem.openItems;
			tree_SearchItem.dataProvider = searchListProvider;
			tree_SearchItem.validateNow();
			tree_SearchItem.openItems = object;
			PopUpManager.removePopUp(searchItemEdit);
		});
		searchItemEdit.addEventListener(Event.CANCEL, function(event:Event):void{
			PopUpManager.removePopUp(searchItemEdit);
		});
	}
}

/**
 * 
 * @param event
 * 
 */
private function searchItemClicked(event:ListEvent):void{
	var itemName:String = String(event.itemRenderer.data.label);
	var searchItem:SearchItem = this._searchItemManager.getSearchItem(itemName);
	if(searchItem != null){
		this.combobox_serchType.selectedIndex = searchItem.searchType;
		this.comboBox_sortType.selectedIndex = searchItem.sortType;
		this.textInput_NicoSearch.text = searchItem.searchWord;
	}
}

/**
 * 
 * @param event
 * 
 */
private function searchItemDoubleClicked(event:ListEvent):void{
	var itemName:String = String(event.itemRenderer.data.label);
	var searchItem:SearchItem = this._searchItemManager.getSearchItem(itemName);
	if(searchItem != null){
		this.combobox_serchType.selectedIndex = searchItem.searchType;
		this.comboBox_sortType.selectedIndex = searchItem.sortType;
		this.textInput_NicoSearch.text = searchItem.searchWord;
		this.searchNicoButtonClicked();
	}
}

/**
 * TextInputにフォーカスが設定された際、すでにTextInputのすべてのテキストが選択された状態にします。
 * @param event
 * 
 */
private function textInputForcusEventHandler(event:FocusEvent):void{
	var textInput:TextInput = TextInput(event.currentTarget);
	textInput.selectionBeginIndex = 0;
	textInput.selectionEndIndex = textInput.text.length;
}

/**
 * 
 * @param event
 * 
 */
private function checkBoxEnableLibraryChanged(event:MouseEvent):void{
	
	isEnableLibrary = checkBox_enableLibrary.selected
//	checkbox_showOnlyNowLibraryTag.enabled = isEnableLibrary;
	
}

private function checkBoxAlwaysEcoChanged(event:MouseEvent):void{
	isAlwaysEconomy = checkBox_isAlwaysEconomyMode.selected;
	downloadManager.isAlwaysEconomy = isAlwaysEconomy;
}

/**
 * デフォルトの検索項目を追加します
 * 
 */
private function addDefSearchItems():void{
	isAddedDefSearchItems = true;
	this._searchItemManager.addDefSearchItems();
	Alert.show("検索項目一覧にデフォルトの検索項目を追加しました。", Message.M_MESSAGE);
}

/**
 * 
 * @param searchItem
 * 
 */
public function search(searchItem:SearchItem):void{
	if(viewStack.selectedIndex == SEARCH_TAB_NUM){
		setSearchItemAndStartSearch(searchItem);
	}else{
		canvas_search.addEventListener(FlexEvent.SHOW, showEventListener);
		
		viewStack.selectedIndex = SEARCH_TAB_NUM;
		
		function showEventListener(event:FlexEvent):void{
			if(searchItem != null){
				setSearchItemAndStartSearch(searchItem);
			}
			if(canvas_search.hasEventListener(FlexEvent.SHOW)){
				canvas_search.removeEventListener(FlexEvent.SHOW, showEventListener);
			}
		}
		
	}
	
}

/**
 * 
 * @param searchItem
 * 
 */
public function setSearchItemAndStartSearch(searchItem:SearchItem):void{
	comboBox_sortType.selectedIndex = searchItem.sortType;
	combobox_serchType.selectedIndex = searchItem.searchType;
	textInput_NicoSearch.text = searchItem.searchWord;
	searchNicoButtonClicked();
	Application.application.activate();
}

/**
 * 
 * @param event
 * 
 */
public function tagTileListItemDoubleClickEventHandler(event:ListEvent):void{
	if(event.itemRenderer.data != null){
		if(event.itemRenderer.data is String){
			var word:String = String(event.itemRenderer.data);
			search(new SearchItem(word, SearchSortType.NEW, SearchType.TAG, word));
		}
	}
}

/**
 * 
 * @param event
 * 
 */
public function showMyListOnNico(event:Event):void{
	var id:String = textinput_mylist.text;
	id = NNDDMyListLoader.getMyListId(id);
	if(id != null){
		navigateToURL(new URLRequest("http://www.nicovideo.jp/mylist/" + id));
		logManager.addLog("マイリストをブラウザで表示:" + "http://www.nicovideo.jp/mylist/" + id);
	}
}

/**
 * 
 * @param event
 * 
 */
public function showRankingOnNico(event:Event):void{
	
	var url:String = null;
	
	if(this.radiogroup_period.selectedValue != 5){
		//普通のライブラリ更新
		url = Access2Nico.NICO_RANKING_URLS[this.radiogroup_period.selectedValue][this.radiogroup_target.selectedValue];
	}else{
		//新着の場合は期間を無視
		url = Access2Nico.NICO_RANKING_URLS[this.radiogroup_period.selectedValue][0];
	}
	
	navigateToURL(new URLRequest(url));
	
	logManager.addLog("ランキングをブラウザで表示:" + url);
	
}

/**
 * 
 * @param event
 * 
 */
public function showSearchResultOnNico(event:Event):void{
	
	var searchWord:String = this.textInput_NicoSearch.text
	var searchURL:String = Access2Nico.NICO_SEARCH_TYPE_URL[combobox_serchType.selectedIndex];
	var nicoSearchURL:String = null;
	
	if(searchWord.length > 0){
		
		searchWord = encodeURIComponent(searchWord);
		
		if(searchWord.indexOf("sort=") == -1 && searchWord.indexOf("order=") == -1){
			if(searchWord.indexOf("page=") == -1){
				nicoSearchURL = searchURL + searchWord + Access2Nico.NICO_SEARCH_SORT_VALUE[comboBox_sortType.selectedIndex];
			}else{
				nicoSearchURL = searchURL + searchWord + "&" + (Access2Nico.NICO_SEARCH_SORT_VALUE[comboBox_sortType.selectedIndex] as String).substring(1);
			}
		}else{
			nicoSearchURL = searchURL + searchWord;
		}
		navigateToURL(new URLRequest(nicoSearchURL));
		logManager.addLog("検索結果をブラウザで表示:" + nicoSearchURL);
	}
}

public function connectionStatusViewCreationCompleteHandler(event:FlexEvent):void{
	connectionStatusView.setLogManager(logManager);
}

public function play():void{
	if(this.playerController != null){
		this.playerController.play();
	}
}

public function stop():void{
	if(this.playerController != null){
		this.playerController.stop();
	}
}

private function removeHistory():void{
	historyManager.clear();
}

private function removeHistoryItem(removeItems:Array):void{
	for(var index:int = removeItems.length; index != 0; index--){
		historyManager.remove(historyManager.getIndex(removeItems[index-1].dataGridColumn_videoName));
	}
}

private function historyItemHandler(event:ContextMenuEvent):void{
	var dataGrid:DataGrid = DataGrid(event.contextMenuOwner);
	if(dataGrid != null && dataGrid.dataProvider.length > 0){
		if(event.mouseTarget is DataGridItemRenderer && (event.mouseTarget as DataGridItemRenderer).data != null){
			var videoPath:String = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_url;
			if((event.target as ContextMenuItem).label == DOWNLOADED_MENU_ITEM_LABEL_PLAY){
				playMovie(videoPath, -1);
			}else if((event.target as ContextMenuItem).label == RANKING_MENU_ITEM_LABEL_ADD_DL_LIST){
				
				var items:Array = dataGrid.selectedItems;
				
				var video:NNDDVideo = new NNDDVideo(videoPath);
				
				var isExistsInDLList:Boolean = downloadManager.isExists(video);
				
				if(isExistsInDLList && items.length == 1 ){
					Alert.show(Message.M_ALREADY_DLLIST_VIDE_EXIST, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
						if(event.detail == Alert.YES){
							for each(var item:Object in items){
								video = new NNDDVideo(item.dataGridColumn_url);
								downloadManager.add(video, isAutoDownload);
							}
						}
					});
				}else{
					
					for each(var item:Object in items){
						video = new NNDDVideo(item.dataGridColumn_url);
						downloadManager.add(video, isAutoDownload);
					}
				}
				
			}else if((event.target as ContextMenuItem).label == DOWNLOADED_MENU_ITEM_LABEL_DELETE_BY_QUEUE){
				var items:Array = dataGrid.selectedItems;
				
				for(var index:int = items.length; index != 0; index--){
					historyManager.remove(historyManager.getIndex(items[index-1].dataGridColumn_videoName));
				}
			}
		}
	}
}

private function historyItemPlay(event:Event):void{
	
	var url:String = dataGrid_history.selectedItem.dataGridColumn_url;
	
	playMovie(url, -1);
	
}

private function historyItemDownload(event:Event):void{
	
	var items:Array = dataGrid_history.selectedItems;
	var url:String = dataGrid_history.selectedItem.dataGridColumn_url;
	
	var video:NNDDVideo = new NNDDVideo(url);
	
	var isExistsInDLList:Boolean = downloadManager.isExists(video);
	
	if(isExistsInDLList && items.length == 1 ){
		Alert.show(Message.M_ALREADY_DLLIST_VIDE_EXIST, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
			if(event.detail == Alert.YES){
				for each(var item:Object in items){
					video = new NNDDVideo(item.dataGridColumn_url);
					downloadManager.add(video, isAutoDownload);
				}
			}
		});
	}else{
		
		for each(var item:Object in items){
			video = new NNDDVideo(item.dataGridColumn_url);
			downloadManager.add(video, isAutoDownload);
		}
	}
	
}

private function historyItemDoubleClickEventHandler(event:ListEvent):void{
	
	var myDataGrid:DataGrid = (event.currentTarget as DataGrid);
	
	var mUrl:String = myDataGrid.dataProvider[myDataGrid.selectedIndex].dataGridColumn_url;
	
	if(mUrl != null){
		if(isDoubleClickOnStreaming){
			playMovie(mUrl, -1);
		}else{
			var video:NNDDVideo = new NNDDVideo(mUrl);
			
			var isExistsInDLList:Boolean = downloadManager.isExists(video);
			
			if(isExistsInDLList){
				Alert.show(Message.M_ALREADY_DLLIST_VIDE_EXIST, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
					if(event.detail == Alert.YES){
						downloadManager.add(video, isAutoDownload);
					}
				});
			}else{
				downloadManager.add(video, isAutoDownload);
			}
		}
	}
}

public function get isMouseHide():Boolean{
	return (this.playerController.videoPlayer as VideoPlayer).isMouseHide;
}

private function checkBoxReNameOldCommentChanged(event:Event):void{
	this.isReNameOldComment = event.target.selected;
	if(playerController != null && playerController.videoInfoView != null){
		playerController.videoInfoView.setRenameOldComment(this.isReNameOldComment);
	}
	this.downloadManager.isReNameOldComment = this.isReNameOldComment;
}

public function getReNameOldComment():Boolean{
	return this.isReNameOldComment;
}

public function setRenameOldComment(boolean:Boolean):void{
	this.isReNameOldComment = boolean;
	if(checkBox_isReNameOldComment != null){
		checkBox_isReNameOldComment.selected = boolean;
	}
	this.downloadManager.isReNameOldComment = this.isReNameOldComment;
}
