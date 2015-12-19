package org.mineap.NNDD
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.SWFLoader;
	import mx.controls.Text;
	import mx.controls.VideoDisplay;
	import mx.controls.videoClasses.VideoError;
	import mx.core.Application;
	import mx.events.AIREvent;
	import mx.events.FlexEvent;
	import mx.events.VideoEvent;
	import mx.formatters.DateFormatter;
	
	import org.libspark.utils.ForcibleLoader;
	import org.mineap.NNDD.commentManager.Command;
	import org.mineap.NNDD.commentManager.CommentManager;
	import org.mineap.NNDD.commentManager.Comments;
	import org.mineap.NNDD.commentManager.LocalCommentManager;
	import org.mineap.NNDD.event.LocalCommentSearchEvent;
	import org.mineap.NNDD.historyManager.HistoryManager;
	import org.mineap.NNDD.model.NNDDComment;
	import org.mineap.NNDD.model.NNDDVideo;
	import org.mineap.NNDD.util.DateUtil;
	import org.mineap.NNDD.util.IchibaBuilder;
	import org.mineap.NNDD.util.PathMaker;
	import org.mineap.NNDD.util.ThumbInfoAnalyzer;
	import org.mineap.NNDD.view.SmoothVideoDisplay;
	import org.mineap.a2n4as.MyListLoader;
	import org.mineap.a2n4as.WatchVideoPage;

	/**
	 * PlayerController.as
	 * ニコニコ動画からのダウンロードを処理およびその他のGUI関連処理を行う。
	 * 
	 * Copyright (c) 2008-2009 MAP - MineApplicationProject. All Rights Reserved.
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class PlayerController extends EventDispatcher
	{
		
		public static const WINDOW_TYPE_SWF:int = 0;
		public static const WINDOW_TYPE_FLV:int = 1;
		
		public static const NG_LIST_RENEW:String = "NgListRenew";
		
		private var commentManager:CommentManager;
		private var comments:Comments;
		
		public var windowType:int = -1;
		public var videoPlayer:VideoPlayer;
		public var videoInfoView:VideoInfoView;
		public var ngListManager:NGListManager;
		public var libraryManager:LibraryManager;
		public var playListManager:PlayListManager;
		private var localCommentManager:LocalCommentManager;
		
		private var windowReady:Boolean = false;
		
		private var swfLoader:SWFLoader = null;
		private var loader:Loader = null;
		private var isMovieClipPlaying:Boolean = false;
		
		private var videoDisplay:SmoothVideoDisplay = null;
		
		private var nicowariSwfLoader:SWFLoader = null;
		
		private var isStreamingPlay:Boolean = false;
		
		private var source:String = "";
		
		private var commentTimer:Timer = new Timer(1000/15);
		private var commentTimerVpos:int = 0;
		
		private var lastSeekTime:Number = new Date().time;
		
		private var time:Number = 0;
		
		private var pausing:Boolean = false;
		
		private var downLoadedURL:String = null;
		
		private var isPlayListingPlay:Boolean = false;
		private var playingIndex:int = 0;
		
		private var logManager:LogManager;
		
		private var mailAddress:String;
		private var password:String;
		
		private var mc:MovieClip;
		private var nicowariMC:MovieClip;
		public var swfFrameRate:Number = 0;
		
		public var sliderChanging:Boolean = false;
		
		private var nicowariTimer:Timer;
		
		private var libraryFile:File;
		
		private var isCounted:Boolean = false;
		
		private var isMovieClipStopping:Boolean = false;
		
		public var isPlayerClosing:Boolean = false;
		
		public var _isEconomyMode:Boolean = false;
		
		private var renewDownloadManager:RenewDownloadManager
		private var nnddDownloaderForStreaming:NNDDDownloader;
		
		public static const NICO_WARI_HEIGHT:int = 56;
		public static const NICO_WARI_WIDTH:int = 544;
		
		public static const NICO_SWF_HEIGHT:int = 384;
		public static const NICO_SWF_WIDTH:int = 512;
		
		public static const NICO_VIDEO_WINDOW_HEIGHT:int = 384;
		public static const NICO_VIDEO_WINDOW_WIDTH:int = 544;
		
		//実行中の時報時刻。実行中でない場合はnull。
		private var playingJihou:String = null;
		
		private var movieEndTimer:Timer = null;
		
		private var isSwfConverting:Boolean = false;
		
		private var streamingProgressCount:int = 0;
		
		private var streamingProgressTimer:Timer = null;
		
		private var _videoID:String = null;
		
		private var _myListAdder:NNDDMyListAdder = null;
		
		private var nnddDownloaderForWatch:NNDDDownloader = null;
		
		private var lastFrame:int = 0;
		
		private var lastNicowariFrame:int = 0;
		
		private var myListLoader:MyListLoader = null;
		
		private var nicowariCloseTimer:Timer = null;
		
		[Embed(source="player/NNDDicons_play_20x20.png")]
        private var icon_Play:Class;
		
		[Embed(source="player/NNDDicons_pause_20x20.png")]
        private var icon_Pause:Class;
		
		[Embed(source="player/NNDDicons_stop_20x20.png")]
        private var icon_Stop:Class;
		
		
		/**
		 * 動画の再生を行うPlayerを管理するPlayerControllerです。<br>
		 * FLVやMP4を再生するためのPlayerとSWFを再生するためのPlayerを管理し、<br>
		 * 必要に応じて切り替えます。<br>
		 * 
		 * @param logManager
		 * @param mailAddress
		 * @param password
		 * @param libraryFile
		 * @param libraryManager
		 * @param playListManager
		 * @param videoPath
		 * @param windowType
		 * @param comments
		 * @param autoPlay
		 * 
		 */
		public function PlayerController(logManager:LogManager, mailAddress:String, password:String, libraryFile:File, 
			libraryManager:LibraryManager, playListManager:PlayListManager, videoPath:String = null, windowType:int = -1, 
			comments:Comments = null, autoPlay:Boolean = false)
		{
			this.logManager = logManager;
			this.mailAddress = mailAddress;
			this.password = password;
			this.libraryFile = libraryFile;
			this.libraryManager = libraryManager;
			this.playListManager = playListManager;
			this.videoPlayer = new VideoPlayer();
			this.videoInfoView = new VideoInfoView();
			this.videoPlayer.init(this, videoInfoView, logManager);
			this.videoInfoView.init(this, videoPlayer, logManager);
			this.videoPlayer.addEventListener(AIREvent.WINDOW_COMPLETE, function():void{
//				dispatchEvent(new Event(Event.ACTIVATE));
				videoInfoView.activate();
				videoPlayer.activate();
			});
			this.ngListManager = new NGListManager(this, videoPlayer, videoInfoView, logManager);
			if(libraryManager != null){
				if(!this.ngListManager.loadNgList(LibraryManager.getInstance().systemFileDir)){
					this.ngListManager.loadNgList(LibraryManager.getInstance().libraryDir);
				}
			}
			this.commentTimer.addEventListener(TimerEvent.TIMER, commentTimerHandler);
			this.commentManager = new CommentManager(videoPlayer, videoInfoView, this);
			if(videoPath != null && windowType != -1 && comments != null){
				this.init(videoPath, windowType, comments, PathMaker.createThmbInfoPathByVideoPath(videoPath), autoPlay);
				this.windowReady = true;
			}
			
		}
		
		/**
		 * デストラクタです。 
		 * Comments、NgListにnullを代入してGCを助けます。
		 * 
		 */
		public function destructor():void{
			
			isMovieClipStopping = false;
			
			if(this.movieEndTimer != null){
				this.movieEndTimer.stop();
				this.movieEndTimer = null;
			}
			
			if(this.commentTimer != null){
				this.commentTimer.stop();
				this.commentTimer.reset()
			}else{
				this.commentTimer = new Timer(1000/15);
				this.commentTimer.addEventListener(TimerEvent.TIMER, commentTimerHandler);
			}
			
			if(this.comments != null){
				this.comments.destructor();
			}
			this.comments = null;
//			this.ngList = null;
			
			if(videoDisplay != null){
				try{
					videoDisplay.stop();
				}catch(error:VideoError){
					trace(error.getStackTrace());
				}
				removeVideoDisplayEventListeners(videoDisplay);
				videoDisplay.source = null;
				videoDisplay = null;
				this.videoPlayer.canvas_video.removeAllChildren();
			}
				
			isMovieClipPlaying = false;
			if(loader != null && !isSwfConverting){
				SoundMixer.stopAll();
				loader.unloadAndStop(true);
//				removeMovieClipEventHandlers(loader);
				loader = null;
				this.videoPlayer.canvas_video.removeAllChildren();
				isSwfConverting = false;
			}
			if(swfLoader != null && !isSwfConverting){
				SoundMixer.stopAll();
				swfLoader.unloadAndStop(true);
				swfLoader = null;
				this.videoPlayer.canvas_video.removeAllChildren();
				isSwfConverting = false;
			}
			
			if(this.nicowariSwfLoader != null){
				videoPlayer.canvas_nicowari.removeAllChildren();
				if(nicowariMC != null){
					this.pauseByNicowari(true);
				}
			}
			
			if(videoPlayer != null && videoPlayer.canvas_nicowari != null){
				videoPlayer.canvas_nicowari.removeAllChildren();
				videoPlayer.canvas_nicowari.setConstraintValue("backgroundColor", new int("0x969696"));
				
			}
			
			if(streamingProgressTimer != null){
				streamingProgressTimer.stop();
				streamingProgressTimer = null;
			}
			streamingProgressCount = 0;
			
			playingJihou = null;
			
			if(nnddDownloaderForWatch != null){
				nnddDownloaderForWatch.close(false, false);
				nnddDownloaderForWatch = null;
			}
			
			if(myListLoader != null){
				myListLoader.close();
				myListLoader = null;
			}
			
			this.lastFrame = 0;
			this.lastNicowariFrame = 0;
			
			isCounted = false;
			
		}
		
		/**
		 * 与えられた引数でPlayerの準備を行います。<br>
		 * autoPlayにtrueを設定した場合、init()の完了後、準備ができ次第再生が行われます。<br>
		 * <b>playMovie()を使ってください。</b>
		 * 
		 * @param videoPath
		 * @param windowType
		 * @param comments
		 * @param thumbInfoPath
		 * @param ngList
		 * @param autoPlay
		 * @param isStreamingPlay
		 * @param downLoadedURL
		 * @param isPlayListingPlay
		 * 
		 */
		private function init(videoPath:String, windowType:int, comments:Comments, thumbInfoPath:String,
				autoPlay:Boolean = false, isStreamingPlay:Boolean = false, 
				downLoadedURL:String = null, isPlayListingPlay:Boolean = false, videoId:String = ""):void
		{
			this.destructor();
			
			if(videoPlayer != null){
				videoPlayer.resetInfo();
				if(videoPlayer.stage.displayState != StageDisplayState.FULL_SCREEN_INTERACTIVE){
					videoPlayer.restore();
				}
			}
			
			if(videoInfoView != null){
				videoInfoView.resetInfo();
				videoInfoView.restore();
			}
			
			videoPlayer.setControllerEnable(false);
			
			this._videoID = null;
			if(videoId != null && videoId != ""){
				this._videoID = videoId;
			}
			
			this.windowReady = false;
			this.source = videoPath;
			this.comments = comments;
			this.time = (new Date).time;
			this.isStreamingPlay = isStreamingPlay;
			this.downLoadedURL = downLoadedURL;
			this.isPlayListingPlay = isPlayListingPlay;
			this.windowType = windowType;
			
			if(!isPlayListingPlay){
				this.videoInfoView.resetPlayList();
			}
			
			this.videoPlayer.videoController.resetAlpha(true);
			
			if(isStreamingPlay){
				if(streamingProgressTimer != null){
					streamingProgressTimer.stop();
					streamingProgressTimer = null;
				}
				streamingProgressCount = 0;
				
				this.videoPlayer.label_playSourceStatus.text = "Streaming:0%   ";
				streamingProgressTimer = new Timer(200);
				streamingProgressTimer.addEventListener(TimerEvent.TIMER, streamingProgressHandler);
				streamingProgressTimer.start();
				
				if(this.videoPlayer.title == null){
					this.videoPlayer.addEventListener(FlexEvent.CREATION_COMPLETE, function():void{
						this.videoPlayer.title = downLoadedURL.substr(downLoadedURL.lastIndexOf("/") + 1);
					});
				}else{
					this.videoPlayer.title = downLoadedURL.substr(downLoadedURL.lastIndexOf("/") + 1);
				}
			}else{
				this.videoPlayer.label_playSourceStatus.text = "[Local]";
				if(this.videoPlayer.title == null){
					this.videoPlayer.addEventListener(FlexEvent.CREATION_COMPLETE, function():void{
						this.videoPlayer.title = videoPath.substr(videoPath.lastIndexOf("/") + 1);
					});
				}else{
					this.videoPlayer.title = videoPath.substr(videoPath.lastIndexOf("/") + 1);
				}
				var file:File = new File(videoPath);
				if(!file.exists){
					Alert.show("ビデオが既に存在しません。\nビデオが移動されたか、削除されている可能性があります。", "エラー");
					logManager.addLog("ビデオが既に存在しません。ビデオが移動されたか、削除されている可能性があります。:" + file.nativePath);
					Application.application.activate();
					return;
				}
				
			}
			
			/* 過去のコメントをリストに追加 */
			var nnddVideo:NNDDVideo = libraryManager.isExist(LibraryManager.getVideoKey(this._videoID));
			if(localCommentManager != null){
				localCommentManager.stop();
				localCommentManager = null;
			}
			if(nnddVideo != null){
			
				localCommentManager = new LocalCommentManager();
				localCommentManager.addEventListener(LocalCommentSearchEvent.LOCAL_COMMENT_SEARCH_COMPLETE, function(event:LocalCommentSearchEvent):void{
					var files:Vector.<File> = event.commentFiles;
					var array:Array = new Array(files.length);
					
					for(var i:int = 0; i<files.length; i++){
						if(files[i].name.indexOf("[Owner]") == -1){
							var date:Date = files[i].creationDate;
							
							var dateString:String = DateUtil.getDateString(date) + " に保存したコメント";
							
							if(i == 0){
								dateString += " (再生中)"
							}
							
							array[i] = dateString;
						}
					}
					
					videoInfoView.savedCommentListProvider = array;
				});
				localCommentManager.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
					videoInfoView.savedCommentListProvider = new Array("(見つかりませんでした)");
				});
				localCommentManager.searchLocalComment(nnddVideo);
				
			}
			
			/* 動画の再生時にコメント・ニコ割を更新するかどうか */
			if(!isStreamingPlay && this.videoInfoView.isRenewCommentEachPlay){
				//ストリーミング再生じゃない時は更新を試みる
				
				logManager.addLog(Message.START_PLAY_EACH_COMMENT_DOWNLOAD);
				videoPlayer.label_downloadStatus.text = Message.START_PLAY_EACH_COMMENT_DOWNLOAD;
				
				if(this._videoID == null){
					this._videoID = PathMaker.getVideoID(videoPath);
				}
				
				if(this._videoID != null && PathMaker.getVideoID(videoPath) == LibraryManager.getVideoKey(videoPath)){
					
					if(mailAddress != null && mailAddress != "" && password != null && password != ""){ 
						
						var videoUrl:String = "http://www.nicovideo.jp/watch/"+PathMaker.getVideoID(this._videoID);
						
						var videoName:String = PathMaker.getVideoName(videoPath);
						
						if(renewDownloadManager != null){
							renewDownloadManager.close();
							renewDownloadManager = null;
						}
						
						renewDownloadManager = new RenewDownloadManager(null, logManager);
						renewDownloadManager.addEventListener(RenewDownloadManager.PROCCESS_COMPLETE, function(event:Event):void{
							var video:NNDDVideo = libraryManager.isExist(PathMaker.getVideoID(videoPath));
							if(video == null){
								try{
									video = libraryManager.loadInfo(videoPath);
									video.creationDate = new File(videoPath).creationDate;
									video.modificationDate = new File(videoPath).modificationDate;
								}catch(error:Error){
									video = new NNDDVideo(videoPath);
								}
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
							
							//ライブラリ保存も実施
							libraryManager.update(video, false);
							
							var commentPath:String = PathMaker.createNomalCommentPathByVideoPath(video.getDecodeUrl());
							var ownerCommentPath:String = PathMaker.createOwnerCommentPathByVideoPath(video.getDecodeUrl());
							comments = new Comments(commentPath, ownerCommentPath, getCommentListProvider(), getOwnerCommentListProvider(), 
								ngListManager, videoInfoView.isShowOnlyPermissionComment, videoInfoView.isHideSekaShinComment, videoInfoView.showCommentCount);
							
							renewDownloadManager = null;
							
							myListGroupUpdate(PathMaker.getVideoID(_videoID));
							
							initStart();
						});
						renewDownloadManager.addEventListener(RenewDownloadManager.PROCCESS_FAIL, function(event:Event):void{
							renewDownloadManager = null;
							videoPlayer.label_downloadStatus.text = Message.FAIL_PLAY_EACH_COMMENT_DOWNLOAD;
							logManager.addLog(Message.FAIL_PLAY_EACH_COMMENT_DOWNLOAD);
							
							var timer:Timer = new Timer(1000, 1);
							timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:Event):void{
								myListGroupUpdate(PathMaker.getVideoID(_videoID));
								initStart();
							});
							timer.start();
						});
						renewDownloadManager.addEventListener(RenewDownloadManager.PROCCESS_CANCEL, function(event:Event):void{
							renewDownloadManager = null;
							videoPlayer.label_downloadStatus.text = Message.PLAY_EACH_COMMENT_DOWNLOAD_CANCEL;
							logManager.addLog(Message.PLAY_EACH_COMMENT_DOWNLOAD_CANCEL);
							
							var timer:Timer = new Timer(1000, 1);
							timer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void{
								myListGroupUpdate(PathMaker.getVideoID(_videoID));
								initStart();
							});
							timer.start();
						});
						
						if(this.videoInfoView.isRenewOtherCommentWithCommentEachPlay){
							renewDownloadManager.renewForOtherVideo(this.mailAddress, this.password, PathMaker.getVideoID(this._videoID), videoName, new File(videoPath.substring(0, videoPath.lastIndexOf("/")+1)), videoInfoView.isReNameOldComment);
						}else{
							renewDownloadManager.renewForCommentOnly(this.mailAddress, this.password, PathMaker.getVideoID(this._videoID), videoName, new File(videoPath.substring(0, videoPath.lastIndexOf("/")+1)), videoInfoView.isReNameOldComment);
						}
						
					}else{
						
						logManager.addLog(Message.FAIL_PLAY_EACH_COMMENT_DOWNLOAD + "(ログインしていません)");
						
					}
					
				}else{
					
					logManager.addLog(Message.FAIL_PLAY_EACH_COMMENT_DOWNLOAD + "(ビデオIDが存在しません)");
					videoPlayer.label_downloadStatus.text = Message.FAIL_PLAY_EACH_COMMENT_DOWNLOAD  + "(ビデオIDが存在しません)";
					
					var timer:Timer = new Timer(1000, 1);
					timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:TimerEvent):void{
						initStart();
						
						timer.stop();
						timer = null;
						
					});
					timer.start();
					
				}
			}else{
				//ストリーミング再生の時は気にしない(マイリストの一覧だけは取りに行く)
			
				this._videoID = videoId;
				
				if(this._videoID == null || this._videoID == ""){
					this._videoID = PathMaker.getVideoID(videoPlayer.title);
				}
				
				logManager.addLog("マイリスト一覧の更新を開始:" + this._videoID);
				
				if(this._videoID != null && this._videoID != ""){
					
					if(this.mailAddress != null && this.mailAddress != "" &&
							this.password != null && this.password != ""){
						
						myListGroupUpdate(PathMaker.getVideoID(this._videoID));
						
					}else{
						//ログインしてください。
						logManager.addLog("マイリスト一覧の更新に失敗(ログインしていない)");
					}
					
				}else{
					//
					logManager.addLog("マイリスト一覧の更新に失敗(動画IDが取得できない)");
				}
				
				initStart();
			}
			
			/**
			 * 匿名メソッド。再生前の初期化を行います。
			 */
			function initStart():void{
				
				try{
					if(_isEconomyMode){
						videoPlayer.label_economyStatus.text = "エコノミーモード";
					}else{
						videoPlayer.label_economyStatus.text = "";
					}
					
					videoPlayer.canvas_video.toolTip = null;
					
					if(isPlayerClosing){
						stop();
						destructor();
						return;
					}
					
					commentTimerVpos = 0;
					
					var text:Text = new Text();
					text.text = "ユーザーニコ割がダウンロード済であれば、この領域で再生されます。\n画面をダブルクリックすると非表示に出来ます。";
					text.setConstraintValue("left", 10);
					text.setConstraintValue("top", 10);
					videoPlayer.canvas_nicowari.addChild(text);
					
					videoPlayer.label_downloadStatus.text = "";
					videoInfoView.image_thumbImg.source = "";
					videoPlayer.videoInfoView.text_info.htmlText ="(タイトルを取得中)<br />(投稿日時を取得中)<br />再生: コメント: マイリスト:"
					
					if(isStreamingPlay){
						//最新の情報はDL済みなのでそれを使う
						setInfo(downLoadedURL, thumbInfoPath, thumbInfoPath.substring(0, thumbInfoPath.lastIndexOf("/")) + "/nndd[IchibaInfo].html", true);
						
						videoInfoView.image_thumbImg.source = thumbInfoPath.substring(0, thumbInfoPath.lastIndexOf("/")) + "/nndd[ThumbImg].jpeg";
					}else{
						setInfo(videoPath, thumbInfoPath, PathMaker.createNicoIchibaInfoPathByVideoPath(videoPath), false);
						
						var nnddVideo:NNDDVideo = libraryManager.isExist(PathMaker.getVideoID(videoPath));
						
						if(nnddVideo != null){
							videoInfoView.image_thumbImg.source = nnddVideo.thumbUrl;
						}
					}
					
					changeFps(videoInfoView.fps);
					
					videoPlayer.videoController.label_time.text = "0:00/0:00";
					videoPlayer.videoController_under.label_time.text = "0:00/0:00";

					if(videoInfoView.isShowAlwaysNicowariArea){
						//ニコ割領域を常に表示する
						videoPlayer.showNicowariArea();
						
					}else{
						//ニコ割は再生時のみ表示
						videoPlayer.hideNicowariArea();
						
					}
					
					
					var video:NNDDVideo = libraryManager.isExist(LibraryManager.getVideoKey(_videoID));
					if(video != null){
						HistoryManager.getInstance().addVideoByNNDDVideo(video);
					}else{
						video = new NNDDVideo("http://www.nicovideo.jp/watch/" + PathMaker.getVideoID(_videoID), videoPlayer.title, false, null, null, null, PathMaker.getThumbImgUrl(PathMaker.getVideoID(_videoID)));
						
						HistoryManager.getInstance().addVideoByNNDDVideo(video);
					}
					
					if(windowType == PlayerController.WINDOW_TYPE_FLV){
						//WINDOW_TYPE_FLVで初期化する場合の処理
						
						isMovieClipPlaying = false;
						
						videoDisplay = new SmoothVideoDisplay();
						
						videoPlayer.label_downloadStatus.text = "";
						
						if(isStreamingPlay){
							videoPlayer.label_downloadStatus.text = "バッファ中...";
							videoDisplay.addEventListener(VideoEvent.PLAYHEAD_UPDATE, bufferingHandler);
						}
						
						videoPlayer.canvas_video.removeAllChildren();
						videoPlayer.canvas_video.addChild(videoDisplay);
						
						videoDisplay.smoothing = true;
						
						videoDisplay.setConstraintValue("bottom", 0);
						videoDisplay.setConstraintValue("left", 0);
						videoDisplay.setConstraintValue("right", 0);
						videoDisplay.setConstraintValue("top", 0);
						videoDisplay.bufferTime = 3;
												
						videoDisplay.autoPlay = autoPlay;
						videoDisplay.source = videoPath;
						videoDisplay.autoRewind = false;
						videoDisplay.volume = videoPlayer.videoController.slider_volume.value;
						videoPlayer.videoController_under.slider_volume.value = videoPlayer.videoController.slider_volume.value;

						commentManager.initComment(comments, videoPlayer.canvas_video, 
							PlayerController.WINDOW_TYPE_FLV);
						commentManager.setCommentAlpha(videoInfoView.commentAlpha/100);
						
						addVideoDisplayEventListeners(videoDisplay);
						
						windowReady = true;
						
						if(autoPlay && !isStreamingPlay){
							time = (new Date).time;
							commentTimer.start();
						}
						
						videoDisplay.addEventListener(VideoEvent.STATE_CHANGE, resizePlayerJustVideoSize);
						videoDisplay.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void{
							event.currentTarget.setFocus();
						});
						
						videoPlayer.videoController.button_play.setStyle("icon", icon_Pause);
						videoPlayer.videoController_under.button_play.setStyle("icon", icon_Pause);
						setVolume(videoPlayer.videoController.slider_volume.value);
						
						videoInfoView.restore();
						if(videoPlayer.stage.displayState != StageDisplayState.FULL_SCREEN_INTERACTIVE){
							videoPlayer.restore();
						}
						
						videoInfoView.activate();
						videoPlayer.activate();
						
						windowResized(false);
						
						videoPlayer.setControllerEnable(true);
						
						return;
					}else if(windowType == PlayerController.WINDOW_TYPE_SWF){
						//WINODW_TYPE_SWFで初期化する場合の処理
						
						isMovieClipPlaying = true;
						isSwfConverting = true;
						
						videoPlayer.label_downloadStatus.text = "SWFを変換しています...";
						
						loader = new Loader();
						loader.contentLoaderInfo.addEventListener(Event.COMPLETE, convertCompleteHandler);
						var fLoader:ForcibleLoader = new ForcibleLoader(loader);
						swfLoader = new SWFLoader();
						swfLoader.addChild(loader);
						
						videoPlayer.canvas_video.removeAllChildren();
						videoPlayer.canvas_video.addChild(swfLoader);
						
						swfLoader.setConstraintValue("bottom", 0);
						swfLoader.setConstraintValue("left", 0);
						swfLoader.setConstraintValue("right", 0);
						swfLoader.setConstraintValue("top", 0);
						
						swfLoader.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void{
							event.currentTarget.setFocus();
						});
						
						commentManager.initComment(comments, videoPlayer.canvas_video, 
							PlayerController.WINDOW_TYPE_SWF);
						commentManager.setCommentAlpha(videoInfoView.commentAlpha/100);
						
						windowReady = true;
						
						if(autoPlay){
							fLoader.load(new URLRequest(videoPath));
						}
						
						var timer:Timer = new Timer(500, 4);
						timer.addEventListener(TimerEvent.TIMER, function():void{
							windowResized(false);
						});
						timer.start();
						
						videoPlayer.videoController_under.button_play.setStyle("icon", icon_Pause);
						videoPlayer.videoController.button_play.setStyle("icon", icon_Pause);
						
						videoInfoView.restore();
						if(videoPlayer.stage.displayState != StageDisplayState.FULL_SCREEN_INTERACTIVE){
							videoPlayer.restore();
						}
						
						videoInfoView.activate();
						videoPlayer.activate();
						
						videoPlayer.setControllerEnable(true);
						
						return;
					}
					return;
				}catch(error:Error){
					trace(error.getStackTrace());
//					destructor();
				}
				
			}
			
		}
		
		/**
		 * 
		 * @param videoId
		 * @return 
		 * 
		 */
		public function myListGroupUpdate(videoId:String):void{
			
			myListLoader = new MyListLoader();
			myListLoader.addEventListener(MyListLoader.GET_MYLISTGROUP_SUCCESS, function(event:Event):void{
				var myLists:Array = myListLoader.getMyLists();
				
				var myListNames:Array = new Array();
				var myListIds:Array = new Array();
				
				for each(var array:Array in myLists){
					myListNames.push(array[0]);
					myListIds.push(array[1]);
				}
				
				videoInfoView.setMyLists(myListNames, myListIds);
				myListLoader.close();
			});
			myListLoader.addEventListener(MyListLoader.GET_MYLISTGROUP_FAILURE, function(event:ErrorEvent):void{
				myListLoader.close();
				logManager.addLog("マイリスト一覧の取得に失敗:" + event + ":" + event.text);
			});
			myListLoader.getMyListGroup(videoId);
			
		}
		
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function bufferingHandler(event:VideoEvent):void{
			if(videoDisplay != null && !isPlayerClosing){
				if(event.state != VideoEvent.BUFFERING){
					videoPlayer.label_downloadStatus.text = "";
					videoDisplay.removeEventListener(VideoEvent.PLAYHEAD_UPDATE, bufferingHandler);
					if(commentTimer != null && !commentTimer.running){
						time = (new Date).time;
						commentTimer.start();
					}
				}
			}else{
				VideoDisplay(event.currentTarget).stop();
				videoDisplay.removeEventListener(VideoEvent.PLAYHEAD_UPDATE, bufferingHandler);
				destructor();
			}
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function convertCompleteHandler(event:Event):void{
			
			isSwfConverting = false;
			
			if(loader != null && !isPlayerClosing){
				
				mc = LoaderInfo(event.currentTarget).loader.content as MovieClip;
				swfFrameRate = LoaderInfo(event.currentTarget).loader.contentLoaderInfo.frameRate;
				setVolume(videoPlayer.videoController.slider_volume.value);
				
				resizePlayerJustVideoSize();
				
				videoPlayer.label_downloadStatus.text = "";
				
				commentTimer.start();
				time = (new Date).time;
				
			}else{
				
				if(mc != null){
					mc.stop();
				}
				destructor();
				if(event.currentTarget as LoaderInfo){
					LoaderInfo(event.currentTarget).loader.unloadAndStop(true);
				}
				
			}
			
			LoaderInfo(event.currentTarget).loader.removeEventListener(Event.COMPLETE, convertCompleteHandler);
			
		}
		
		/**
		 * プレイリストを更新し、動画の再生を開始します。
		 * 
		 * @param videoPath
		 * @param windowType
		 * @param comments
		 * @param ngList
		 * @param playList プレイリスト（m3u形式）
		 * @param videoNameList プレイリストにニコ動のURLが入る場合に変わりに表示させたいプレイリストのタイトル
		 * @param playingIndex 再生開始インデックス
		 * @param autoPlay 自動再生
		 * @param isStreamingPlay ストリーミング再生かどうか
		 * @param downLoadedURL ダウンロード済URL
		 * @return 
		 * 
		 */
		private function initWithPlayList(videoPath:String, windowType:int, comments:Comments, playList:Array, videoNameList:Array, playListName:String, playingIndex:int, 
			autoPlay:Boolean = false, isStreamingPlay:Boolean = false, downLoadedURL:String = null, videoTitle:String = null):void{
			
			this.playingIndex = playingIndex;
			this.isPlayListingPlay = true;
			var videoNameArray:Array = videoNameList;
			if(videoNameArray == null){
				videoNameArray = new Array();
				for(var i:int; i<playList.length; i++){
					var url:String = playList[i];
					videoNameArray.push(url.substring(url.lastIndexOf("/") + 1));
				}
			}
			
			if(downLoadedURL == null){
				downLoadedURL = videoPath;
			}
			
			this.videoInfoView.resetPlayList();
			this.videoInfoView.setPlayList(playList, videoNameArray, playListName);
			
			trace("\t"+playList);
			
			this.init(videoPath, windowType, comments, PathMaker.createThmbInfoPathByVideoPath(downLoadedURL), autoPlay, isStreamingPlay, videoTitle, true, LibraryManager.getVideoKey(videoTitle));
		}
		
		/**
		 * VideoPlayerのプレイリストが選択された際に呼ばれるメソッドです。
		 * 
		 * @param url
		 * @param index
		 * @return 
		 * 
		 */
		public function initForVideoPlayer(url:String, index:int):void{
			playMovie(url, this.videoInfoView.getPlayList(), this.videoInfoView.getNameList(), index, this.videoInfoView.playListName, PathMaker.getVideoName(this.videoInfoView.getPlayListUrl(index)));
		}

		/**
		 * videoDisplayの大きさをビデオにあわせ、同時にウィンドウの大きさを変更します。
		 * フルスクリーン時に呼ばれても何もしません。
		 */		
		public function resizePlayerJustVideoSize(event:Event = null):void{
			
			try{
				
				//再生窓の既定の大きさ
				var videoWindowHeight:int = PlayerController.NICO_VIDEO_WINDOW_HEIGHT;
				var videoWindowWidth:int = PlayerController.NICO_VIDEO_WINDOW_WIDTH;
				
				//ニコ割窓の既定の大きさ
				var nicowariWindowHeight:int = PlayerController.NICO_WARI_HEIGHT;
				var nicowariWindowWidth:int = PlayerController.NICO_WARI_WIDTH;
				
				//InfoViewのプレイリストの項目を選択
				if(isPlayListingPlay){
					if(this.videoInfoView != null){
						videoInfoView.showPlayingTitle(playingIndex);
					}
				}
				
				//フルスクリーンではないか？
				if(this.videoPlayer.stage != null && this.videoPlayer.stage.displayState != StageDisplayState.FULL_SCREEN_INTERACTIVE){
					//再生ごとのリサイズが有効か？
					if(this.videoInfoView.isResizePlayerEachPlay){
						
						if(this.windowType == PlayerController.WINDOW_TYPE_FLV && this.videoDisplay != null){
							//FLV再生か？
							
							if(this.videoInfoView.selectedResizeType == VideoInfoView.RESIZE_TYPE_NICO){
								
								//ビデオの大きさがニコ動の表示窓より小さいとき && ウィンドウの大きさを動画に合わせる
								
								videoWindowHeight = PlayerController.NICO_VIDEO_WINDOW_HEIGHT;
								videoWindowWidth = PlayerController.NICO_VIDEO_WINDOW_WIDTH;
								
								//ビデオそのものはセンターに表示
								this.videoDisplay.setConstraintValue("left", (PlayerController.NICO_VIDEO_WINDOW_WIDTH - PlayerController.NICO_SWF_WIDTH)/2);
								this.videoDisplay.setConstraintValue("right", (PlayerController.NICO_VIDEO_WINDOW_WIDTH - PlayerController.NICO_SWF_WIDTH)/2);
								
								if(videoDisplay.hasEventListener(VideoEvent.STATE_CHANGE)){
									//init後の初回の大きさ合わせが出来れば良いので以降のシークでは呼ばれないようにする
									videoDisplay.removeEventListener(VideoEvent.STATE_CHANGE, resizePlayerJustVideoSize);
								}
								
							}else if(this.videoInfoView.selectedResizeType == VideoInfoView.RESIZE_TYPE_VIDEO && this.videoDisplay.videoHeight > 0){
								
								//ビデオの大きさにウィンドウの大きさを合わせるとき(videoHeightが0の時は動画がまだ読み込まれていないのでスキップ)
								
								videoWindowHeight = this.videoDisplay.videoHeight;
								videoWindowWidth = this.videoDisplay.videoWidth;
								
								this.videoDisplay.setConstraintValue("bottom", 0);
								this.videoDisplay.setConstraintValue("left", 0);
								this.videoDisplay.setConstraintValue("right", 0);
								this.videoDisplay.setConstraintValue("top", 0);
								
								if(videoDisplay.hasEventListener(VideoEvent.STATE_CHANGE)){
									//init後の初回の大きさ合わせが出来れば良いので以降のシークでは呼ばれないようにする
									videoDisplay.removeEventListener(VideoEvent.STATE_CHANGE, resizePlayerJustVideoSize);
								}
							}else{
								//中断。後で呼ばれる事を期待する。
								return;
							}
							
						}else if(this.windowType == PlayerController.WINDOW_TYPE_SWF){
							//SWF再生か？
							
							//SWFの場合は一律でサイズを固定
							videoWindowHeight = PlayerController.NICO_VIDEO_WINDOW_HEIGHT;
							videoWindowWidth = PlayerController.NICO_VIDEO_WINDOW_WIDTH;
							
						}
						
						//TODO 設定されたVideoDisplayの大きさに基づいてニコ割領域の大きさを決定
						
						var rate:Number = PlayerController.NICO_WARI_WIDTH / PlayerController.NICO_WARI_HEIGHT;
						
						if(!videoPlayer.isNicowariShow){
							videoWindowHeight += int(videoWindowWidth / rate);
						}
						
						this.videoPlayer.nativeWindow.height += int(videoWindowHeight - this.videoPlayer.canvas_video_back.height);
						this.videoPlayer.nativeWindow.width += int(videoWindowWidth - this.videoPlayer.canvas_video_back.width);
						
						//ネイティブなウィンドウの大きさと、ウィンドウ内部の利用可能な領域の大きさの差
						var diffH:int = this.videoPlayer.nativeWindow.height - this.videoPlayer.stage.stageHeight;
						var diffW:int = this.videoPlayer.nativeWindow.width - this.videoPlayer.stage.stageWidth;
						
					}
					
				}
			
			}catch(error:Error){	//ウィンドウが閉じられた後に呼ばれるとエラー。停止処理を行う。
				trace(error.getStackTrace());
				stop();
				destructor();
			}
		}
		
		
		/**
		 * 登録されているビデオに対して再生を要求します。
		 * ビデオが再生中で、一時停止が可能であれば、一時停止を要求します。
		 * @return 
		 * 
		 */
		public function play():Boolean
		{
			if(this.windowReady){
				
				videoPlayer.canvas_video_back.setFocus();
				
				var newComments:Comments = null;
				videoPlayer.canvas_video.toolTip = null;
				if(this.windowType == PlayerController.WINDOW_TYPE_FLV){
					if(videoDisplay != null && videoDisplay.playing){
						videoPlayer.videoController.button_play.setStyle("icon", icon_Play);
						videoPlayer.videoController_under.button_play.setStyle("icon", icon_Play);
						this.commentTimer.stop(); 				
						this.commentTimer.reset();
						videoDisplay.pause();
						pausing = true;
					}else{
						videoPlayer.videoController.button_play.setStyle("icon", icon_Pause);
						videoPlayer.videoController_under.button_play.setStyle("icon", icon_Pause);
						if(pausing){
							this.videoPlayer.videoController.slider_timeline.enabled = true;
							this.videoPlayer.videoController_under.slider_timeline.enabled = true;
							this.videoDisplay.play();
							this.time = (new Date).time;
							this.commentTimer.start();
						}else{
							this.videoPlayer.videoController.slider_timeline.enabled = true;
							this.videoPlayer.videoController_under.slider_timeline.enabled = true;
							if(!isStreamingPlay){
								newComments = new Comments(PathMaker.createNomalCommentPathByVideoPath(source), 
									PathMaker.createOwnerCommentPathByVideoPath(source), this.videoPlayer.getCommentListProvider(), this.videoPlayer.videoInfoView.ownerCommentProvider, 
									this.ngListManager, this.videoInfoView.isShowOnlyPermissionComment, this.videoInfoView.isHideSekaShinComment, this.videoInfoView.showCommentCount);
								init(source, PlayerController.WINDOW_TYPE_FLV, newComments, PathMaker.createThmbInfoPathByVideoPath(source), true, isStreamingPlay, null, this.isPlayListingPlay, this._videoID);
							}else{
								this.playMovie(source, null, null, -1, "", this.downLoadedURL);
							}
						}
						pausing = false;
					}
				}else if(this.windowType == PlayerController.WINDOW_TYPE_SWF){
					if(isMovieClipPlaying){
						videoPlayer.videoController.button_play.setStyle("icon", icon_Play);
						videoPlayer.videoController_under.button_play.setStyle("icon", icon_Play);
						this.commentTimer.stop();
						this.commentTimer.reset();
						mc.stop();
						isMovieClipPlaying = false;
						pausing = true;
					}else{	
						videoPlayer.videoController.button_play.setStyle("icon", icon_Pause);
						videoPlayer.videoController_under.button_play.setStyle("icon", icon_Pause);
						if(pausing){
							this.videoPlayer.videoController.slider_timeline.enabled = true;
							this.videoPlayer.videoController_under.slider_timeline.enabled = true;
							mc.play();
							isMovieClipPlaying = true;
							this.time = (new Date).time;
							this.commentTimer.start();
						}else{
							this.videoPlayer.canvas_video.removeAllChildren();
							this.videoPlayer.videoController.slider_timeline.enabled = true;
							this.videoPlayer.videoController_under.slider_timeline.enabled = true;
							if(!isStreamingPlay){
								newComments = new Comments(PathMaker.createNomalCommentPathByVideoPath(source), 
									PathMaker.createOwnerCommentPathByVideoPath(source), this.videoPlayer.getCommentListProvider(),this.videoPlayer.videoInfoView.ownerCommentProvider, 
									this.ngListManager, this.videoInfoView.isShowOnlyPermissionComment, this.videoInfoView.isHideSekaShinComment, this.videoInfoView.showCommentCount);
								init(source, PlayerController.WINDOW_TYPE_SWF, newComments, PathMaker.createThmbInfoPathByVideoPath(source), true, isStreamingPlay, null, this.isPlayListingPlay, this._videoID);
							}else{
								this.playMovie(source, null, null, -1, "",this.downLoadedURL);
							}
						}
						pausing = false;
					}
				}
			}
			return false;
		}
		
		
		/**
		 * 再生しているビデオを停止させます。 
		 * @return 
		 * 
		 */
		public function stop():Boolean
		{
			pausing = false;
			
			if(videoInfoView.isShowAlwaysNicowariArea){
				videoPlayer.showNicowariArea();
			}else{
				videoPlayer.hideNicowariArea();
			}
			
			if(videoPlayer != null && videoPlayer.label_downloadStatus != null){
				videoPlayer.canvas_video_back.setFocus();
				videoPlayer.label_downloadStatus.text = "";
				videoPlayer.canvas_video.toolTip = "ここに動画ファイルをドロップすると動画を再生できます。";
			}
			
			if(this.movieEndTimer != null){
				this.movieEndTimer.stop();
				this.movieEndTimer = null;
			}
			
			if(renewDownloadManager != null){
				try{
					renewDownloadManager.close();
					renewDownloadManager = null;
					logManager.addLog("再生前の情報更新をキャンセルしました。");
				}catch(error:Error){
					trace(error);
				}
				return true;
			}else if(this.windowReady){
				
				this.videoPlayer.videoController.button_play.enabled = true;
				this.videoPlayer.videoController_under.button_play.enabled = true;
				videoPlayer.videoController.button_play.setStyle("icon", icon_Play);
				videoPlayer.videoController_under.button_play.setStyle("icon", icon_Play);
				
				this.videoPlayer.videoController_under.slider_timeline.value = 0;
				this.videoPlayer.videoController.slider_timeline.value = 0;
				
				this.commentTimerVpos = 0;
				this.commentTimer.stop();
				this.commentTimer.reset();
				this.commentManager.removeAll();
				
				//再生関係のコンポーネントを掃除
				this.destructor();
				
				//終了時にニコ割が鳴っていたら止める。
				videoPlayer.canvas_nicowari.removeAllChildren();
				if(nicowariMC != null){
					this.pauseByNicowari(true);
				}
				
				return true;
			}
			
			return false;
		}
		
	
		/**
		 * VideoDisplayに関連するリスナをまとめて登録します。
		 * @param videoDisplay
		 * 
		 */
		private function addVideoDisplayEventListeners(videoDisplay:VideoDisplay):void{
			videoDisplay.addEventListener(VideoEvent.PLAYHEAD_UPDATE, videoProgressHandler);
			videoDisplay.addEventListener(VideoEvent.COMPLETE, videoCompleteHandler);
		}
		
		/**
		 * VideoDisplayに関連するリスナをまとめて削除します。
		 * @param videoDisplay
		 * 
		 */
		private function removeVideoDisplayEventListeners(videoDisplay:VideoDisplay):void{
			if(videoDisplay.hasEventListener(VideoEvent.PLAYHEAD_UPDATE)){
				videoDisplay.removeEventListener(VideoEvent.PLAYHEAD_UPDATE, videoProgressHandler);
			}
			if(videoDisplay.hasEventListener(VideoEvent.STATE_CHANGE)){
				videoDisplay.removeEventListener(VideoEvent.STATE_CHANGE, resizePlayerJustVideoSize);
			}
			if(videoDisplay.hasEventListener(VideoEvent.COMPLETE)){
				videoDisplay.removeEventListener(VideoEvent.COMPLETE, videoCompleteHandler);
			}
		}
		
		/**
		 * 
		 * @param loader
		 * 
		 */
//		private function removeMovieClipEventHandlers(loader:Loader):void{
//			if(loader.hasEventListener(Event.COMPLETE)){
//				loader.removeEventListener(Event.COMPLETE, convertCompleteHandler);
//			}
//		}
		
		/**
		 * ストリーミングのダウンロード状況を百分率で返します。
		 * @return 
		 * 
		 */
		public function getStreamingProgres():int{
			var value:int = 0;
			if(isStreamingPlay){
				if(videoDisplay != null){
					value = (videoDisplay.bytesLoaded*100 / videoDisplay.bytesTotal);
				}else if(loader != null && loader.contentLoaderInfo != null){
					value = (loader.contentLoaderInfo.bytesLoaded*100 / loader.contentLoaderInfo.bytesTotal);
				}else{
					value = 100;
				}
			}else{
				value = 100;
			}
			return value;
		}
		
		private function streamingProgressHandler(event:TimerEvent):void{
			if(isStreamingPlay){
				var value:int = getStreamingProgres();
				if(value >= 100){
					this.videoPlayer.label_playSourceStatus.text = "Streaming:100%";
					streamingProgressCount = 0;
					videoPlayer.videoController.resetStatusAlpha();
					if(streamingProgressTimer != null){
						streamingProgressTimer.stop();
					}
				}else{
					
					var str:String = "   ";
					if(streamingProgressCount <= 10){
						str = ".  ";
					}else if(streamingProgressCount > 10 && streamingProgressCount <= 20){
						str = ".. ";
					}else if(streamingProgressCount > 20 && streamingProgressCount <= 30){
						str = "...";
					}
					
					this.videoPlayer.label_playSourceStatus.text = "Streaming:" + value + "%" + str;
					if(streamingProgressCount >= 30){
						streamingProgressCount = 0;
					}else{
						streamingProgressCount = streamingProgressCount + 2;
					}
				}
			}else{
				if(streamingProgressTimer != null){
					streamingProgressTimer.stop();
				}
			}
		}
		
		/**
		 * ムービーの再生中に呼ばれるハンドラです。
		 * @param evt
		 * 
		 */
		private function videoProgressHandler(evt:VideoEvent = null):void{
			try{
				var allSec:String="00",allMin:String="0";
				var nowSec:String="00",nowMin:String="0";
				
				this.commentTimerVpos = evt.playheadTime*1000;
				
				nowSec = String(int(this.videoDisplay.playheadTime%60));
				nowMin = String(int(this.videoDisplay.playheadTime/60));
				
				allSec = String(int(this.videoDisplay.totalTime%60));
				allMin = String(int(this.videoDisplay.totalTime/60));
				
				if(nowSec.length == 1){
					nowSec = "0" + nowSec;
				}
				if(allSec.length == 1){
					allSec = "0" + allSec;
				}
				
				videoPlayer.videoController_under.slider_timeline.enabled = true;
				videoPlayer.videoController_under.slider_timeline.minimum = 0;
				videoPlayer.videoController_under.slider_timeline.maximum = videoDisplay.totalTime;
				if(!this.sliderChanging){
					
					this.videoPlayer.videoController.slider_timeline.maximum = videoDisplay.totalTime;
					this.videoPlayer.videoController_under.slider_timeline.maximum = videoDisplay.totalTime;
					videoPlayer.videoController_under.slider_timeline.value = videoDisplay.playheadTime;
					
				}
				videoPlayer.videoController_under.label_time.text = nowMin + ":" + nowSec + "/" + allMin + ":" + allSec;
				videoPlayer.videoController_under.slider_timeline.enabled = true;
				
				videoPlayer.videoController.slider_timeline.enabled = true;
				videoPlayer.videoController.slider_timeline.minimum = 0;
				videoPlayer.videoController.slider_timeline.maximum = videoDisplay.totalTime;
				if(!this.sliderChanging){
					videoPlayer.videoController.slider_timeline.value = videoDisplay.playheadTime;
				}
				videoPlayer.videoController.label_time.text = nowMin + ":" + nowSec + "/" + allMin + ":" + allSec;
				videoPlayer.videoController.slider_timeline.enabled = true;
			}catch(error:Error){
				VideoDisplay(evt.currentTarget).stop();
				trace(error.getStackTrace());
			}
		}
		
		/**
		 * ムービーの再生が終了したときに呼ばれるハンドラです。
		 * @param evt
		 * 
		 */
		private function videoCompleteHandler(evt:VideoEvent = null):void{
			
			if(movieEndTimer != null){
				movieEndTimer.stop();
				movieEndTimer = null;
			}
			//残っているコメントが流れ終わるまで待つ
			movieEndTimer = new Timer(2000, 1);
			movieEndTimer.addEventListener(TimerEvent.TIMER_COMPLETE, videoPlayCompleteWaitHandler);
			movieEndTimer.start();
			
		}
		
		/**
		 * 
		 * 
		 */
		private function videoPlayCompleteWaitHandler(event:TimerEvent):void{
			if(!isCounted){
				//再生回数を加算
				var videoId:String = LibraryManager.getVideoKey(this.videoPlayer.title);
				if(videoId != null){
					addVideoPlayCount(videoId, true);
				}
				isCounted = true;
			}
			
			logManager.addLog("***動画の停止***");
			
			if(videoPlayer.videoInfoView.checkbox_repeat.selected){
				if(isPlayListingPlay){
					if(isStreamingPlay){
						logManager.addLog("***動画のリピート(ストリーミング)***");
						this.seek(0);
						if(this.videoDisplay != null){
							this.videoDisplay.play();
						}
					}else{
						logManager.addLog("***動画のリピート(ローカル)***");
						this.stop();
						playMovie(this.videoInfoView.getPlayListUrl(playingIndex), this.videoInfoView.getPlayList(), this.videoInfoView.getNameList(), playingIndex, this.videoInfoView.playListName, this.videoPlayer.title);
						
					}
				}else if(isStreamingPlay){
					logManager.addLog("***動画のリピート(ストリーミング)***");
					this.seek(0);
					if(this.videoDisplay != null){
						this.videoDisplay.play();
					}
				}else{
					logManager.addLog("***動画のリピート(ローカル)***");
					this.stop();
					this.play();
				}
			}else{
				this.stop();
				if(isPlayListingPlay){
					logManager.addLog("***動画の再生(ローカル)***");
					var windowType:int = PlayerController.WINDOW_TYPE_FLV;
					if(playingIndex >= this.videoInfoView.getPlayList().length-1){
						playingIndex = 0;
						if(this.videoPlayer.videoInfoView.isRepeatAll()){
							playMovie(this.videoInfoView.getPlayListUrl(playingIndex), this.videoInfoView.getPlayList(), this.videoInfoView.getNameList(), 
								playingIndex, PathMaker.getVideoName(this.videoInfoView.getPlayListUrl(playingIndex)));
						}
					}else{
						playingIndex++;
						playMovie(this.videoInfoView.getPlayListUrl(playingIndex), this.videoInfoView.getPlayList(), this.videoInfoView.getNameList(), 
							playingIndex, this.videoInfoView.playListName, PathMaker.getVideoName(this.videoInfoView.getPlayListUrl(playingIndex)));
					}
				}
			}
		}
		
		
		/**
		 * SWFの再生が完了したときに呼ばれるハンドラです。 
		 * 
		 */
		private function movieClipCompleteHandler():void{
			
			this.lastFrame = 0;
			this.lastNicowariFrame = 0;
			
			if(movieEndTimer != null){
				movieEndTimer.stop();
				movieEndTimer = null;
			}
			//残っているコメントが流れ終わるまで待つ
			movieEndTimer = new Timer(2000, 1);
			movieEndTimer.addEventListener(TimerEvent.TIMER_COMPLETE, movieClipPlayCompleteWaitHandler);
			movieEndTimer.start();
			
			
		}
		
		/**
		 * 
		 * 
		 */
		private function movieClipPlayCompleteWaitHandler(event:TimerEvent):void{
			if(!isCounted){
				//再生回数を加算
				var videoId:String = LibraryManager.getVideoKey(this.source);
				if(videoId != null){
					addVideoPlayCount(videoId, true);
				}
				isCounted = true;
			}
			
			logManager.addLog("***動画の停止***");
			this.lastFrame = 0;
			this.lastNicowariFrame = 0;
			
			if(videoPlayer.videoInfoView.checkbox_repeat.selected){
				if(isPlayListingPlay){
					if(isStreamingPlay){
						logManager.addLog("***動画のリピート(ストリーミング)***");
						this.seek(0);
					}else{
						logManager.addLog("***動画のリピート(ローカル)***");
						this.stop();
						mc.gotoAndStop(0);
						playMovie(this.videoInfoView.getPlayListUrl(playingIndex), this.videoInfoView.getPlayList(), this.videoInfoView.getNameList(), 
							playingIndex, this.videoInfoView.playListName, this.videoPlayer.title);
					}
				}else if(isStreamingPlay){
					logManager.addLog("***動画のリピート(ストリーミング)***");
					this.seek(0);
				}else{
					logManager.addLog("***動画のリピート(ローカル)***");
					this.stop();
					mc.gotoAndStop(0);
					this.play();
				}
			}else{
				this.stop();
				mc.gotoAndStop(0);
				if(isPlayListingPlay){
					logManager.addLog("***動画の再生(ローカル)***");
					var windowType:int = PlayerController.WINDOW_TYPE_FLV;
					if(playingIndex >= this.videoInfoView.getPlayList().length-1){
						playingIndex = 0;
						if(this.videoPlayer.videoInfoView.isRepeatAll()){
							playMovie(this.videoInfoView.getPlayListUrl(playingIndex), this.videoInfoView.getPlayList(), this.videoInfoView.getNameList(), playingIndex, PathMaker.getVideoName(this.videoInfoView.getPlayListUrl(playingIndex)));
						}
					}else{
						playingIndex++;
						playMovie(this.videoInfoView.getPlayListUrl(playingIndex), this.videoInfoView.getPlayList(), this.videoInfoView.getNameList(), 
							playingIndex, this.videoInfoView.playListName, PathMaker.getVideoName(this.videoInfoView.getPlayListUrl(playingIndex)));
					}
				}
			}
			
			isMovieClipStopping = false;
		}
		
		
		/**
		 * 指定された動画IDで、ライブラリに存在する動画の再生回数を1加算します
		 * @param videoId 再生回数をインクリメントする動画のID
		 * @param isSave ライブラリを保存するかどうかです。
		 */
		private function addVideoPlayCount(videoId:String, isSave:Boolean):void{
			var nnddVideo:NNDDVideo = libraryManager.isExist(videoId);
			if(nnddVideo != null){
				nnddVideo.playCount = nnddVideo.playCount + 1;
				libraryManager.update(nnddVideo, isSave);
				trace("再生回数を加算:" + nnddVideo.videoName + "," + nnddVideo.playCount);
			}else{
				//存在しない
				trace("指定された動画は存在せず:" + videoId);
			}
		}
		
		/**
		 * コメント表示用のタイマーです。
		 * swfの再生中はSWFのタイムラインヘッダを更新します。
		 * 
		 * @param event
		 * 
		 */
		private function commentTimerHandler(event:TimerEvent):void{
			
			if(isPlayerClosing){
				if(commentTimer != null){
					commentTimer.stop();
					commentTimer.reset();
				}
				return;
			}
			
//			音量を反映
			this.setVolume(this.videoPlayer.videoController.slider_volume.value);
			
			var nowSec:String="00",nowMin:String="0";
			nowSec = String(int(commentTimerVpos/1000%60));
			nowMin = String(int(commentTimerVpos/1000/60));
			if(nowSec.length == 1){
				nowSec = "0" + nowSec; 
			}
			var nowTime:String = nowMin + ":" + nowSec;
			
			var allSec:String="00",allMin:String="0"
			if(this.windowType==PlayerController.WINDOW_TYPE_SWF && this.mc != null){
				allSec = String(int(mc.totalFrames/swfFrameRate%60));
				allMin = String(int(mc.totalFrames/swfFrameRate/60));
			}else if(this.windowType==PlayerController.WINDOW_TYPE_FLV && this.videoDisplay != null){
				allSec = String(int(videoDisplay.totalTime%60));
				allMin = String(int(videoDisplay.totalTime/60));
			}
			if(allSec.length == 1){
				allSec = "0" + allSec;
			}
			var allTime:String = allMin +":" + allSec;
			
			if(!isCounted && commentTimerVpos > 10000){
				//再生回数を加算
				var videoId:String = LibraryManager.getVideoKey(this.videoPlayer.title);
				if(videoId != null){
					addVideoPlayCount(videoId, false);
				}
				isCounted = true;
			}
			
			//SWF再生時のタイムラインヘッダ移動・動画の終了判定
			if(isMovieClipPlaying && this.windowType==PlayerController.WINDOW_TYPE_SWF && this.mc != null){
				
				videoPlayer.videoController_under.slider_timeline.enabled = true;
				videoPlayer.videoController_under.slider_timeline.minimum = 0;
				videoPlayer.videoController_under.slider_timeline.maximum = mc.totalFrames;
				
				videoPlayer.videoController.slider_timeline.enabled = true;
				videoPlayer.videoController.slider_timeline.minimum = 0;
				videoPlayer.videoController.slider_timeline.maximum = mc.totalFrames;
				
				if(!this.sliderChanging){
					videoPlayer.videoController_under.slider_timeline.value = mc.currentFrame;
					videoPlayer.videoController.slider_timeline.value = mc.currentFrame;
				}
				
//				trace(nowMin + "/" + nowSec);
				
				videoPlayer.videoController_under.label_time.text = nowTime + "/"+ allTime;
				videoPlayer.videoController.label_time.text = nowTime + "/"+ allTime;
				
				if(mc.currentFrame >= mc.totalFrames-1 || mc.currentFrame == this.lastFrame ){
					this.lastFrame = mc.currentFrame;
					//すでにmovieClipの終了呼び出しが行われているかどうか
					if(!isMovieClipStopping){
						isMovieClipStopping = true;
						movieClipCompleteHandler();
					}
					return;
				}else{
					if(!isMovieClipStopping){
						this.lastFrame = mc.currentFrame;
					}
				}
			}
			
			var tempTime:Number = (new Date).time;
			
			//SWF再生の時はここでコメントタイマーの時間を更新
			if(this.windowType == PlayerController.WINDOW_TYPE_SWF){
				this.commentTimerVpos += (tempTime - this.time);
			}
			
			//コメントを更新
			var commentArray:Vector.<NNDDComment> = this.commentManager.setComment(commentTimerVpos, (tempTime - this.time)*3, this.videoPlayer.videoInfoView.checkbox_showComment.selected);
			this.commentManager.moveComment(tempTime/1000 - this.time/1000, videoInfoView.showCommentSec);
			this.commentManager.removeComment(commentTimerVpos, videoInfoView.showCommentSec * 1000);
			this.time = tempTime;
			
			//コメントリストと同期させる場合の処理
			if(videoPlayer.videoInfoView.checkbox_SyncComment.selected 
//					&& (videoPlayer.stage.displayState != StageDisplayState.FULL_SCREEN_INTERACTIVE
//							&& videoInfoView.isActive)
							){
				
				var lastMin:String = commentManager.getComments().lastMin;
				
				var tempNowTime:String = nowTime;
				if(lastMin.length == 3){
					//最後の分が3桁（合計は:も含めて６桁）
					if(tempNowTime.length == 4){
						//現在時刻が:を含めて4桁
						tempNowTime = "00" + tempNowTime;
					}else if(tempNowTime.length == 5){
						//現在時刻が:を含めて5桁
						tempNowTime = "0" + tempNowTime;
					}
				}else if(lastMin.length == 2){
					//最後の分が2桁（合計は:も含めて5桁）
					if(tempNowTime.length == 4){
						//現在時刻が:を含めて4桁
						tempNowTime = "0" + tempNowTime;
					}
					
				}else if(lastMin.length == 1){
					//最後の分が1桁（合計は:も含めて4桁）
					
				}
				
				if(tempNowTime.length > lastMin.length+3){
					tempNowTime = tempNowTime.substring(1);
				}
				
				
				var index:int = 0;
				if(commentArray.length > 0 && comments != null){
					var myComment:NNDDComment = commentArray[0];
					for each(var comment:NNDDComment in commentArray){
						if(comment.vpos > myComment.vpos){
							myComment = comment;
						}
					}
					index = comments.getCommentIndex(tempNowTime, myComment.text);
					
					if(this.videoPlayer.videoInfoView.dataGrid_comment.verticalScrollPosition < index){
						index -= (this.videoPlayer.videoInfoView.dataGrid_comment.rowCount - 1);
						if(index > 0){
							if(index < this.videoPlayer.videoInfoView.dataGrid_comment.maxVerticalScrollPosition){
								this.videoPlayer.videoInfoView.dataGrid_comment.verticalScrollPosition = index;
							}else{
								this.videoPlayer.videoInfoView.dataGrid_comment.verticalScrollPosition = this.videoPlayer.videoInfoView.dataGrid_comment.maxVerticalScrollPosition;
							}
						}
					}
				}
			}
			
			
			//時報再生チェック
			var date:Date = new Date();
			var hh:String = new String(int(date.getHours()));
			var mm:String = new String(int(date.getMinutes()));
			if(hh.length == 1){
				hh = "0" + hh;
			}
			if(mm.length == 1){
				mm = "0" + mm;
			}
			var jihouResult:Array = commentManager.isJihouSettingTime(hh + mm);
			if(jihouResult != null && playingJihou == null){
				//時報実行
				playingJihou = hh+mm;
				playNicowari(jihouResult[0], jihouResult[1]);
			}
			if(playingJihou != null && playingJihou != (hh+mm)){
				playingJihou = null;
			}
			
			if(!this.videoPlayer.videoInfoView.checkbox_showComment.selected){
				this.commentManager.removeAll();
			}
			
		}
		
		/**
		 * 引数で指定された実数をつかって音量を設定します。
		 * @param volume 0から1までの間で指定できる音量です。
		 * @return 対応するビデオの音量です。
		 * 
		 */
		public function setVolume(volume:Number):Number{
			if(this.windowReady){
				if(this.windowType == PlayerController.WINDOW_TYPE_FLV){
					if(videoDisplay != null){
						videoDisplay.volume = volume;
						this.videoPlayer.videoController.slider_volume.value = volume;
						this.videoPlayer.videoController_under.slider_volume.value = volume;
						return videoDisplay.volume;
					}
				}else if(this.windowType == PlayerController.WINDOW_TYPE_SWF){
					if(mc != null){
						var transForm:SoundTransform = new SoundTransform(volume, 0);
						mc.soundTransform = transForm;
						this.videoPlayer.videoController.slider_volume.value = volume;
						this.videoPlayer.videoController_under.slider_volume.value = volume;
						return mc.soundTransform.volume;
					}
				}
			}
			return 0;
		}
		
		/**
		 * PlayerControllerが保持するCommentManagerを返します。
		 * @return 
		 * 
		 */
		public function getCommentManager():CommentManager{
			return commentManager;
		}
		
		/**
		 * ウィンドウがリサイズされた際、コメントの表示位置をリセットします。
		 * また、SWFを再生中は、ウィンドウサイズが変更された場合に、Loaderコンポーネントの大きさを変更します。 
		 */
		public function windowResized(isCommentRemove:Boolean = true):void{
			
			if(this.windowReady){
				
				//SWFLoaderのコンポーネント大きさ調節
				if(swfLoader != null && this.windowType == PlayerController.WINDOW_TYPE_SWF){
					//スケール調節
					
					(swfLoader.getChildAt(0) as Loader).x = 0;
					(swfLoader.getChildAt(0) as Loader).y = 0;
					var flashDistX:int = (swfLoader.getChildAt(0) as Loader).width - PlayerController.NICO_SWF_WIDTH;
					var flashDistY:int = (swfLoader.getChildAt(0) as Loader).height - PlayerController.NICO_SWF_HEIGHT;
					var scaleX:Number = swfLoader.width / ((swfLoader.getChildAt(0) as Loader).width - flashDistX);
					var scaleY:Number = swfLoader.height / ((swfLoader.getChildAt(0) as Loader).height - flashDistY);
					if(scaleX < scaleY){
						(swfLoader.getChildAt(0) as Loader).scaleX = scaleX;
						(swfLoader.getChildAt(0) as Loader).scaleY = scaleX;
						var centorY:int = swfLoader.height / 2;
						var newY:int = centorY - (PlayerController.NICO_SWF_HEIGHT*scaleX)/2;
//						trace("newY:"+newY);
						if(newY > 0){
							(swfLoader.getChildAt(0) as Loader).y = newY;
						}
					}else{
						(swfLoader.getChildAt(0) as Loader).scaleX = scaleY;
						(swfLoader.getChildAt(0) as Loader).scaleY = scaleY;
						var centorX:int = swfLoader.width / 2;
						var newX:int = centorX - (PlayerController.NICO_SWF_WIDTH*scaleY)/2;
//						trace("newX:"+newX);
						if(newX > 0){
							(swfLoader.getChildAt(0) as Loader).x = newX;
						}
					}
					
				}
				
				//ニコ割SWFのコンポーネントの大きさ調節
				if(nicowariSwfLoader != null){
					
					(nicowariSwfLoader.getChildAt(0) as Loader).x = 0;
					(nicowariSwfLoader.getChildAt(0) as Loader).y = 0;
					
					var nicowariDistX:Number = (nicowariSwfLoader.getChildAt(0) as Loader).width - PlayerController.NICO_WARI_WIDTH;
					var nicowariDistY:Number = (nicowariSwfLoader.getChildAt(0) as Loader).height - PlayerController.NICO_WARI_HEIGHT;
					
					var nicowariScaleX:Number = nicowariSwfLoader.width / ((nicowariSwfLoader.getChildAt(0) as Loader).width - nicowariDistX);
					var nicowariScaleY:Number = nicowariSwfLoader.height / ((nicowariSwfLoader.getChildAt(0) as Loader).height - nicowariDistY);
					if(nicowariScaleX < nicowariScaleY){
						(nicowariSwfLoader.getChildAt(0) as Loader).scaleX = nicowariScaleX;
						(nicowariSwfLoader.getChildAt(0) as Loader).scaleY = nicowariScaleX;
						centorY = nicowariSwfLoader.height / 2;
						newY = centorY - (PlayerController.NICO_WARI_HEIGHT*nicowariScaleX)/2;
//						trace("newY:"+newY);
						if(newY > 0){
							(nicowariSwfLoader.getChildAt(0) as Loader).y = newY;
						}
					}else{
						(nicowariSwfLoader.getChildAt(0) as Loader).scaleX = nicowariScaleY;
						(nicowariSwfLoader.getChildAt(0) as Loader).scaleY = nicowariScaleY;
						centorX = nicowariSwfLoader.width / 2;
						newX = centorX - (PlayerController.NICO_WARI_WIDTH*nicowariScaleY)/2;
//						trace("newX:"+newX);
						if(newX > 0){
							(nicowariSwfLoader.getChildAt(0) as Loader).x = newX;
						}
					}
				}
				
				//コメントをすべて除去。
				if(isCommentRemove){
					commentManager.removeAll();
				}
			}
		}
		
		/**
		 * 指定されたseekTimeまでムービーのヘッドを移動させます。
		 * @param seekTime タイムライン用のスライダが保持する値を設定します。単位はミリ秒です。
		 * 
		 */
		public function seek(seekTime:Number):void{
			trace(seekTime);
			if(this.windowReady){
				if((new Date().time)-lastSeekTime > 1000){
					if((videoDisplay != null && videoDisplay.initialized && videoDisplay.totalTime > 0) || (swfLoader != null && swfLoader.initialized)){
						
						
						trace("seekStart:" + seekTime);
						this.commentTimer.stop();
						this.commentTimer.reset();
						
						//各コメントの表示可否フラグをリセット
						commentManager.getComments().resetEnableShowFlag();
						
						//コメントスクロール位置リセット
						this.videoPlayer.videoInfoView.dataGrid_comment.verticalScrollPosition = 0;
						
						if(this.windowType == PlayerController.WINDOW_TYPE_FLV){
							videoDisplay.playheadTime = seekTime;
							commentTimerVpos = seekTime*1000;
						}else if(this.windowType == PlayerController.WINDOW_TYPE_SWF){
							mc.gotoAndPlay(int(seekTime));
							commentTimerVpos = (seekTime/swfFrameRate)*1000;
						}
						
						commentManager.removeAll();

						if(!this.pausing || this.windowType == PlayerController.WINDOW_TYPE_SWF){
							commentTimer.start();
						}
						lastSeekTime = new Date().time;
						

						
					}
				}
			}
		}
		
		
		/**
		 * 現在Playerが開いているかどうかを返します。 
		 * @return Playerが開いている場合はtrue、開いていない場合はfalse。
		 * 
		 */
		public function isOpen():Boolean{
			if(this.videoPlayer.nativeWindow != null){
				return !this.videoPlayer.closed;
			}
			return false;
		}
		
		/**
		 * PlayerウィンドウをOpenします。
		 * 
		 */
		public function open():Boolean{
			if(this.videoPlayer != null){
				this.videoPlayer.open();
			}else{
				return false;
			}
			if(this.videoInfoView != null){
				this.videoInfoView.open();
			}else{
				return false;
			}
			return true;
		}
		
		/**
		 * 現在開いているPlayerの修了処理を行います
		 * 
		 */		
		public function playerExit():void{
			
			this.stop();
			if(this.videoPlayer != null && this.videoPlayer.nativeWindow != null && !this.videoPlayer.closed){
				this.videoPlayer.restore();
				this.videoPlayer.saveStore();
//				this.videoPlayer.close();
			}
			if(this.videoPlayer != null && this.videoInfoView.nativeWindow != null && !this.videoInfoView.closed){
				this.saveNgList();
				this.videoInfoView.restore();
				this.videoInfoView.saveStore();
//				this.videoInfoView.close();
			}
		}
		
		/**
		 * 現状のNGリストを書き出します。
		 * 
		 */
		public function saveNgList():void{
			this.ngListManager.saveNgList(LibraryManager.getInstance().systemFileDir);
		}
		
		public function getCommentListProvider():ArrayCollection{
			return this.videoPlayer.getCommentListProvider();
		}
		
		public function getOwnerCommentListProvider():ArrayCollection{
			return this.videoPlayer.videoInfoView.ownerCommentProvider;
		}
		
		
		/**
		 * コメントを、NGリストを元にして最新に更新します。
		 * 
		 */
		public function renewComment():void{
			if(this.videoInfoView.ngListProvider != null){
				if(!this.isStreamingPlay && this.source != null){
					comments = new Comments(PathMaker.createNomalCommentPathByVideoPath(source), 
						PathMaker.createOwnerCommentPathByVideoPath(source), videoPlayer.getCommentListProvider(), this.videoPlayer.videoInfoView.ownerCommentProvider, 
						this.ngListManager, this.videoInfoView.isShowOnlyPermissionComment, this.videoInfoView.isHideSekaShinComment, this.videoInfoView.showCommentCount);
				}else if(this.isStreamingPlay){
					comments = new Comments(PathMaker.createNomalCommentPathByVideoPath(LibraryManager.getInstance().tempDir.url + "/nndd.flv"), 
						PathMaker.createOwnerCommentPathByVideoPath(LibraryManager.getInstance().tempDir.url + "/nndd.flv"), this.videoPlayer.getCommentListProvider(), this.videoPlayer.videoInfoView.ownerCommentProvider, 
						this.ngListManager, videoInfoView.isShowOnlyPermissionComment, this.videoInfoView.isHideSekaShinComment, this.videoInfoView.showCommentCount);
				}
				commentManager.setComments(comments);
			}
			this.windowResized();
			
		}
		
		/**
		 * サムネイル情報及び市場情報をセットします。
		 * @param videoPath
		 * 
		 */
		private function setInfo(videoPath:String, thumbInfoPath:String, ichibaInfoPath:String, isStreaming:Boolean):void{
			
			if(!isStreaming){ //ストリーミング再生では無い場合は、ローカル以外にもニコ動から取得したデータを設定する
				var videoID:String = PathMaker.getVideoID(videoPath);
				var ichibaBuilder:IchibaBuilder = new IchibaBuilder(logManager);
				if(videoID != null && mailAddress != null && mailAddress != "" && password != null && password != "" ){
					videoInfoView.ichibaNicoProvider.addItem({
						col_image:"",
						col_info:"市場情報を取得中です",
						col_link:""
					});
					var a2nForIchiba:Access2Nico = new Access2Nico(null, null, this, logManager, null);
					a2nForIchiba.addEventListener(Access2Nico.NICO_ICHIBA_INFO_GET_COMPLETE, function():void{
						videoInfoView.ichibaNicoProvider = ichibaBuilder.makeIchibaInfo(a2nForIchiba.getIchibaHTML());
						videoInfoView.ichibaNicoProvider.refresh();
					});
					a2nForIchiba.request_ichiba(Access2Nico.TOP_PAGE_URL, Access2Nico.LOGIN_URL, mailAddress, password, videoID);
				}else{
					videoInfoView.ichibaNicoProvider.addItem({
						col_image:"",
						col_info:"市場情報を取得できませんでした。",
						col_link:""
					});
				}
				
				if(videoID != null && mailAddress != null && mailAddress != "" && password != null && password != "" ){	//ストリーミングじゃない時
					videoPlayer.videoInfoView.owner_text_nico = "";
					var a2nForThumb:Access2Nico = new Access2Nico(null, null, this, logManager, null);
					a2nForThumb.addEventListener(Access2Nico.NICO_SINGLE_THUMB_INFO_GET_COMPLETE, function():void{
						videoPlayer.videoInfoView.nicoTagProvider = a2nForThumb.getTag();
						videoPlayer.setTagArray(a2nForThumb.getTag());
						
						if(a2nForThumb.getTag().length == 0 && videoPlayer.videoInfoView.localTagProvider.length > 0){
							videoPlayer.videoInfoView.nicoTagProvider = videoPlayer.videoInfoView.localTagProvider;
							videoPlayer.videoInfoView.nicoTagProvider.push("(取得できなかったためローカルのデータを使用)");
							videoPlayer.setTagArray(videoPlayer.videoInfoView.nicoTagProvider);
						}
						
						var analyzer:ThumbInfoAnalyzer = a2nForThumb.getThumbInfoAnalzyer();
						var dateString:String = "(投稿日時の取得に失敗)";
						var ownerText:String = "(投稿者説明文の取得に失敗)";
						var htmlInfo:String = "";
						
						if(analyzer != null){
							var dateFormatter:DateFormatter = new DateFormatter();
							dateFormatter.formatString = "YYYY/MM/DD JJ:NN:SS";
							var date:Date = analyzer.getDateByFirst_retrieve();
							dateString = "投稿日:(削除されています)";
							if(date != null){
								dateString = "投稿日:" + dateFormatter.format(date);
							}
							htmlInfo = analyzer.htmlTitle + "<br />" + dateString + "<br />" + analyzer.playCountAndCommentCountAndMyListCount;
							
							ownerText = a2nForThumb.getThumbInfoAnalzyer().thumbInfoHtml;
						}else{
							
							if(videoPlayer.videoInfoView.owner_text_local.length > 1){
								ownerText = videoPlayer.videoInfoView.owner_text_local + "\n(ローカルのデータを使用)";
							}
							
							htmlInfo = "(タイトルの取得に失敗)<br />" + dateString + "<br />(再生回数等の取得に失敗)";
						}
						
						videoPlayer.videoInfoView.text_info.htmlText = htmlInfo;
						
//						if(videoPlayer.videoInfoView.owner_text_nico.length == 0){
							videoPlayer.videoInfoView.owner_text_nico = ownerText;
//						}
						
					});
					a2nForThumb.request_thumbInfo(Access2Nico.TOP_PAGE_URL, Access2Nico.LOGIN_URL, mailAddress, password, videoID, new Array());
					
					// ログインしないとダメ
//					var watchVideoPage:WatchVideoPage = new WatchVideoPage();
//					watchVideoPage.addEventListener(WatchVideoPage.WATCH_SUCCESS, function(event:Event):void{
//						videoPlayer.videoInfoView.owner_text_nico = (event.currentTarget as WatchVideoPage).getDescription();
//					});
//					watchVideoPage.addEventListener(WatchVideoPage.WATCH_FAIL, function(event:ErrorEvent):void{
//						logManager.addLog("投稿者説明文の取得に失敗:" + this._videoID + ":" + event.text);
//					});
//					watchVideoPage.watchVideo(this._videoID);
					
				}else{
					
					//TODO ローカルのデータを使う
					videoPlayer.videoInfoView.text_info.htmlText = "(タイトルの取得に失敗)<br />(投稿日時の取得に失敗)<br />(再生回数等の取得に失敗)";
					videoPlayer.videoInfoView.owner_text_nico = "(取得できませんでした)";
					
					videoPlayer.videoInfoView.nicoTagProvider = videoPlayer.videoInfoView.localTagProvider;
					videoPlayer.videoInfoView.nicoTagProvider.push("(取得できなかったためローカルのデータを使用)");
					videoPlayer.setTagArray(videoPlayer.videoInfoView.nicoTagProvider);
					
					
				}
				
				
			}
			
			setLocalIchibaInfo(ichibaInfoPath, isStreaming);
			setLocalThumbInfo(videoID, thumbInfoPath, isStreaming);
			
		}
		
		/**
		 * 市場情報をセットします。
		 * @param ichibaInfoPath
		 * @param isStreaming trueの時は「ニコ動に市場情報」に指定された市場情報を設定します。
		 * 
		 */
		private function setLocalIchibaInfo(ichibaInfoPath:String, isStreaming:Boolean):void{
			
			var ichibaBuilder:IchibaBuilder = new IchibaBuilder(logManager);
			
			var fileIO:FileIO = new FileIO(logManager);
			fileIO.addURLLoaderEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
				logManager.addLog("市場情報の読み込みに失敗:" + event);
				videoInfoView.ichibaLocalProvider.removeAll();
				
				if(isStreaming){
					videoInfoView.ichibaNicoProvider.removeAll();
				}
				
			});
			fileIO.addURLLoaderEventListener(Event.COMPLETE, function(event:Event):void{
				if(!isStreaming){
					videoInfoView.ichibaLocalProvider = ichibaBuilder.makeIchibaInfo(event.target.data);
				}else{
					videoInfoView.ichibaNicoProvider = ichibaBuilder.makeIchibaInfo(event.target.data);
				}
			});
			if(!fileIO.loadComment(ichibaInfoPath)){
				if(isStreaming){
					videoInfoView.ichibaNicoProvider.removeAll();
					videoInfoView.ichibaNicoProvider.addItem({
						col_image:"",
						col_info:"(市場情報の取得に失敗)",
						col_link:""
					});
				}else{
					videoInfoView.ichibaLocalProvider.removeAll();
					videoInfoView.ichibaLocalProvider.addItem({
						col_info:"(ローカルに市場情報が存在しません)"
					});
				}
			}
			
		}
		
		/**
		 * サムネイル情報をセットします。
		 * 
		 * @param thumbInfoPath
		 * @param isStreaming trueの時は「ニコ動のデータ」として指定されたサムネイル情報を設定します。
		 * 
		 */
		private function setLocalThumbInfo(videoId:String, thumbInfoPath:String, isStreaming:Boolean):void{
			
			var fileIO:FileIO = new FileIO(logManager);
			fileIO.addURLLoaderEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
				logManager.addLog("サムネイル情報の読み込みに失敗:" + event);
			});
			fileIO.addURLLoaderEventListener(Event.COMPLETE, function(event:Event):void{
				
				trace(event);
				
				var thumbInfoXML:XML = new XML(event.target.data);
				
				var thumbInfoAnalyzer:ThumbInfoAnalyzer = new ThumbInfoAnalyzer(thumbInfoXML);
				
				//ライブラリの情報をローカルのThumbInfo.xmlのタグ情報で更新
				//ストリーミングの時はわたってくるvideoPathが純粋にビデオの名前なのでスキップ
				try{
					
					//タグをライブラリに反映
					var video:NNDDVideo = libraryManager.isExist(videoId);
					if(video != null){
						var tagStrings:Vector.<String> = new Vector.<String>();
						var tags:Array = thumbInfoAnalyzer.tagArray;
						for(var i:int=0; i<tags.length; i++){
							tagStrings.push(tags[i]);
						}
						video.tagStrings = tagStrings;
						//再生に時間がかかるのでライブラリの更新はしない
						libraryManager.update(video, false);
					}
					
				}catch(error:ArgumentError){
					trace(error);
				}
				
				if(!isStreaming){
					videoPlayer.videoInfoView.localTagProvider = thumbInfoAnalyzer.tagArray;
					videoPlayer.videoInfoView.owner_text_local = thumbInfoAnalyzer.thumbInfoHtml;
				}else{
					var dateFormatter:DateFormatter = new DateFormatter();
					dateFormatter.formatString = "YYYY/MM/DD JJ:NN:SS";
					var date:Date = thumbInfoAnalyzer.getDateByFirst_retrieve();
					var dateString:String = "投稿日:(削除されています)";
					if(date != null){
						dateString = "投稿日:" + dateFormatter.format(date);
					}
					videoPlayer.videoInfoView.nicoTagProvider = thumbInfoAnalyzer.tagArray;
					videoPlayer.videoInfoView.owner_text_nico = thumbInfoAnalyzer.thumbInfoHtml;
					videoPlayer.setTagArray(thumbInfoAnalyzer.tagArray);
					videoPlayer.videoInfoView.text_info.htmlText = thumbInfoAnalyzer.htmlTitle + "<br />" + dateString + "<br />" + thumbInfoAnalyzer.playCountAndCommentCountAndMyListCount;
				}
			});
			
			if(!fileIO.loadComment(thumbInfoPath)){
				
				if(isStreaming){
					videoPlayer.videoInfoView.text_info.htmlText = videoPlayer.title + "<br />(投稿日の取得に失敗)<br />(再生回数等の取得に失敗)";
					videoPlayer.videoInfoView.nicoTagProvider = new Array("タグ情報の取得に失敗");
					videoPlayer.videoInfoView.owner_text_nico = "(投稿者説明文の取得に失敗)";
					videoPlayer.setTagArray(new Array("(タグ情報の取得に失敗)"));
				}else{
					var array:Array = new Array();
					array.push("(ローカルにタグ情報無し)");
					videoPlayer.videoInfoView.localTagProvider = array;
					videoPlayer.videoInfoView.owner_text_local = "(ローカルに投稿者説明無し)";
				}
				
			}
		}
		
		
		/**
		 * ユーザーニコ割の再生を行います。
		 * 
		 * @param nivowariVideoID ユーザーニコ割ビデオID
		 * @param isStop ニコ割時に再生中の動画を停止するかどうか。
		 * 
		 */
		public function playNicowari(nicowariVideoID:String, isStop:int = Command.NICOWARI_PLAY):void{
			
			//ニコ割領域を隠す設定になっていれば、再生前に表示。
			if(!videoInfoView.isShowAlwaysNicowariArea){
				videoPlayer.showNicowariArea();
			}
			
			var mySource:String = this.source;
			if(isStreamingPlay){
				mySource = libraryManager.tempDir.url + "/nndd.flv";
			}
			
			var nicoPath:String = PathMaker.createNicowariPathByVideoPathAndNicowariVideoID(mySource, nicowariVideoID);
			
			if(nicowariTimer != null){
				pauseByNicowari(true);
				nicowariTimer.stop();
				nicowariTimer = null;
			}
			nicowariTimer = new Timer(100);
			
			var file:File = new File(nicoPath);
			if(!file.exists){
				logManager.addLog("ユーザーニコ割がダウンロードされていない\nファイル:"+decodeURIComponent(file.url));
				videoPlayer.canvas_nicowari.removeAllChildren();
				videoPlayer.canvas_nicowari.setConstraintValue("backgroundColor", new int("0x969696"));
				var text:Text = new Text();
				text.text = "ユーザーニコ割がダウンロードされていません。(次のファイルを探しましたが発見できませんでした。)\n"+decodeURIComponent(file.url).substring(decodeURIComponent(file.url).lastIndexOf("/")+1);
				text.setConstraintValue("left", 10);
				text.setConstraintValue("top", 10);
				videoPlayer.canvas_nicowari.addChild(text);
				nicowariCloseTimer = new Timer(5000, 1);
				nicowariCloseTimer.addEventListener(TimerEvent.TIMER_COMPLETE, hideNicowari);
				nicowariCloseTimer.start();
				return;
			}
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event:Event):void{
				nicowariMC = loader.content as MovieClip;
				if(nicowariMC != null){
					var transForm:SoundTransform = new SoundTransform(videoPlayer.videoController.slider_volume.value, 0);
					nicowariMC.soundTransform = transForm;
					windowResized(false);
					nicowariTimer.start();
				}
			});
			
			var fLoader:ForcibleLoader = new ForcibleLoader(loader);
			nicowariSwfLoader = new SWFLoader();
			nicowariSwfLoader.addChild(loader);
			nicowariSwfLoader.addEventListener(FlexEvent.UPDATE_COMPLETE, function():void{
				windowResized(false);
			});
			this.videoPlayer.canvas_nicowari.setConstraintValue("backgroundColor", new int("0x000000"));
			this.videoPlayer.canvas_nicowari.removeAllChildren();
			this.videoPlayer.canvas_nicowari.addChild(nicowariSwfLoader);
			
			
			if(isStop == Command.NICOWARI_STOP){
				pauseByNicowari();
			}
			
			nicowariSwfLoader.setConstraintValue("bottom", 0);
			nicowariSwfLoader.setConstraintValue("left", 0);
			nicowariSwfLoader.setConstraintValue("right", 0);
			nicowariSwfLoader.setConstraintValue("top", 0);
			
			fLoader.load(new URLRequest(nicoPath));
			
			nicowariTimer.addEventListener(TimerEvent.TIMER, function():void{
				
				//ニコ割終了判定
				if(nicowariMC != null){
					var transForm:SoundTransform = new SoundTransform(videoPlayer.videoController.slider_volume.value, 0);
					nicowariMC.soundTransform = transForm;
					if(nicowariMC.currentFrame >= nicowariMC.totalFrames-1 || nicowariMC.currentFrame == lastNicowariFrame ){
						lastNicowariFrame = nicowariMC.currentFrame;
						//ニコ割終了
						pauseByNicowari(true);
						nicowariTimer.stop();
						
						//ニコ割領域を常時表示する設定か？
						if(!videoInfoView.isShowAlwaysNicowariArea){
							//隠す設定なら5秒後にニコ割領域を隠す
							videoPlayer.hideNicowariArea();
						}
					}else{
						lastNicowariFrame = nicowariMC.currentFrame;
					}	
				}
			});
			
		}
		
		private function hideNicowari(event:TimerEvent):void{
			
			(event.currentTarget as Timer).removeEventListener(TimerEvent.TIMER_COMPLETE, hideNicowari);
			
			//ニコ割領域を常時表示する設定になっているか？
			if(!videoInfoView.isShowAlwaysNicowariArea){
				//隠す設定なら5秒後にニコ割領域を隠す
				videoPlayer.hideNicowariArea();
			}
			
			nicowariCloseTimer = null;
		}
		
	
		/**
		 * ニコ割による停止時に呼ばれます。
		 * また、ニコ割による停止が解除された時にも呼ばれます。解除の際はisResetがtrueに設定されます。
		 * 
		 * @param isReset
		 * 
		 */
		private function pauseByNicowari(isReset:Boolean = false):void{
			if(!isReset){
				if(!pausing){
					//一時停止していないので一時停止する
					this.play();	
				}
				
				//再生ボタンを使えなくする
				this.videoPlayer.videoController.button_play.enabled = false;
				this.videoPlayer.videoController.button_stop.enabled = false;
				this.videoPlayer.videoController.slider_timeline.enabled = false;
				
				this.videoPlayer.videoController_under.button_play.enabled = false;
				this.videoPlayer.videoController_under.button_stop.enabled = false;
				this.videoPlayer.videoController_under.slider_timeline.enabled = false;
				
				trace("ニコ割再生");
				
			}else if(this.nicowariSwfLoader != null){
				//ニコ割終了
				if(pausing){
					//一時停止していれば再生する
					this.play();
				}
				
				this.videoPlayer.canvas_nicowari.setConstraintValue("backgroundColor", new int("0x969696"));
				
				if(nicowariMC != null){
					nicowariMC.stop();
				}
				(this.nicowariSwfLoader.getChildAt(0) as Loader).unloadAndStop(true);
				this.nicowariSwfLoader = null;
				this.videoPlayer.canvas_nicowari.removeAllChildren();
				nicowariMC = null;
				
				//元に戻す
				this.videoPlayer.videoController.button_play.enabled = true;
				this.videoPlayer.videoController.button_stop.enabled = true;
				
				this.videoPlayer.videoController_under.button_play.enabled = true;
				this.videoPlayer.videoController_under.button_stop.enabled = true;
				
				trace("ニコ割停止");
			}
		}
		
		/**
		 * 
		 * @param vpos
		 * 
		 */
		public function seekOperation(vpos:Number):void{
			if(videoInfoView.isEnableJump){
				this.seek(vpos/100);
			}else{
				logManager.addLog("ジャンプ命令を無視(ジャンプ先:" + vpos/100 + ")");
			}
		}
		
		
		/**
		 * 指定されたvideoIDの動画に、メソッドが呼び出された3秒後にジャンプします。
		 * messageが設定されている場合は、messageを画面に表示します。
		 * 
		 * @param videoId
		 * @param message
		 * @return 
		 * 
		 */
		public function jump(videoId:String, message:String):void{
			
			//ジャンプ命令は有効か？
			if(videoInfoView.isEnableJump){
				
				//ジャンプ命令の際にユーザーに問い合わせる設定か？
				if(videoInfoView.isAskToUserOnJump){
					
					if(!pausing){
						this.play();
					}
					if(nicowariMC != null){
						this.pauseByNicowari(true);
					}
					
					videoPlayer.videoController.resetAlpha(true);
					
					//問い合わせダイアログ表示
					videoPlayer.showAskToUserOnJump(function():void{
						jumpStart(videoId, message);
					}, function():void{
						play();
						logManager.addLog("ジャンプ命令をキャンセル(ジャンプ先:" + videoId + ")");
					}, videoId);
					
				}else{
					jumpStart(videoId, message);
				}
				
			}else{
				logManager.addLog("ジャンプ命令を無視(ジャンプ先:" + videoId + ")");
			}
			
			
		}
		
		/**
		 * 
		 * @param videoId
		 * @param message
		 * 
		 */
		private function jumpStart(videoId:String, message:String):void{
			
			this.stop();
			
			trace("@ジャンプ:videoId=" + videoId + ", message=" + message);
			
			if(message != null && message != ""){
				videoPlayer.label_downloadStatus.text = message + "(" + videoId + "にジャンプします...)";
			}else{
				videoPlayer.label_downloadStatus.text = videoId + "にジャンプします...";
			}
			logManager.addLog("ジャンプ命令:ジャンプ先=" + videoId + ", メッセージ=" + message);
			
			var timer:Timer = new Timer(3000, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:TimerEvent):void{
				videoPlayer.label_downloadStatus.text = "";
				
				var url:String = "";
				var video:NNDDVideo = libraryManager.isExist(videoId);
				if(video == null){
					//無いときはニコ動にアクセス
					url = "http://www.nicovideo.jp/watch/" + videoId;
				}else{
					url = video.getDecodeUrl();
				}
				
				playMovie(url);
			});
			
			timer.start();
		}
		
		/**
		 * PlayerとInfoViewのウィンドウの位置をリセットします。
		 * 
		 */
		public function resetWindowPosition():void{
			videoPlayer.resetWindowPosition();
			videoInfoView.resetWindowPosition();
		}
		
		/**
		 * コメントのFPSを変更します。
		 * @param fps
		 * 
		 */
		public function changeFps(fps:Number):void{
			this.commentTimer.delay = 1000/fps;
		}
		
		/**
		 * 引数で指定された文字列とコマンドを使ってニコニコ動画へコメントをポストします。
		 * @param postMessage
		 * @param command
		 * 
		 */
		public function postMessage(postMessage:String, command:String):void{
			
			logManager.addLog("***コメント投稿開始***");
			
			var videoID:String = null;
			if(isStreamingPlay){
				//ストリーミング再生時はsorceにvideoIDが入っていないのでPlayerのタイトルから取得
				videoID = PathMaker.getVideoID(videoPlayer.title);
			}else{
				videoID = PathMaker.getVideoID(source);
			}
			
			if(videoID != null){
//				var commentPost:CommentPost = new CommentPost();
//				commentPost.postComment(videoID, command, postMessage, commentTimerVpos/10);
				
				
				var a2n:Access2Nico = new Access2Nico(null, null, this, logManager, null);
				a2n.addEventListener(Access2Nico.NICO_POST_COMMENT_COMPLETE, function():void{
					var post:XML = a2n.getPostComment();
					if(!isStreamingPlay){
						var path:String = PathMaker.createNomalCommentPathByVideoPath(source);
						(new FileIO(logManager)).addComment(path, post);
					}
					commentManager.addPostComment(new NNDDComment(Number(post.attribute("vpos")), String(post.text()), String(post.attribute("mail")), String(post.attribute("user_id")), Number(post.attribute("no")), String(post.attribute("thread")), true));
					logManager.addLog("***コメント投稿完了***");
					
				});
				a2n.addEventListener(Access2Nico.NICO_POST_COMMENT_FAIL, function():void{
					var post:XML = a2n.getPostComment();
					if(!isStreamingPlay){
						var path:String = PathMaker.createNomalCommentPathByVideoPath(source);
						(new FileIO(logManager)).addComment(path, post);
					}
					commentManager.addPostComment(new NNDDComment(Number(post.attribute("vpos")), String(post.text()), String(post.attribute("mail")), String(post.attribute("user_id")), Number(post.attribute("no")), String(post.attribute("thread")), true));
					logManager.addLog("***コメント投稿失敗***");
				});
				a2n.postMessage(Access2Nico.TOP_PAGE_URL, Access2Nico.LOGIN_URL, this.mailAddress, this.password, postMessage, command, videoID, commentTimerVpos/10);
				
			}else{
				//ビデオIDがついてないのでPostできなかった
				logManager.addLog("ファイル名にビデオIDが無いためコメントを投稿できませんでした。");
				logManager.addLog("***コメント投稿失敗***");
			}
			
		}
		
		/**
		 * 再生したいURLを渡すだけで一発再生！あら簡単！
		 * @param url 再生したい動画のURL（ローカルの場合でもURL形式ならば有効）
		 * @param playList プレイリスト再生の場合はPlayListを指定
		 * @param videoNameList プレイリスト再生で、プレイリストとは別に表示用のURLを指定したい場合はココに設定
		 * @param playListIndex プレイリストの中でどの項目を再生するか指定します
		 * @param playListName プレイリストの名前を設定します
		 * @param videoTitle ストリーミング再生等で動画のタイトルを取得するのが難しい場合は動画のタイトルを指定します。
		 * 
		 */
		public function playMovie(url:String, playList:Array = null, videoNameList:Array = null, playListIndex:int = -1, playListName:String = "", videoTitle:String = "", isEconomy:Boolean = false):void{
			
			try{
				
				this._isEconomyMode = isEconomy;
				
				url = decodeURIComponent(url);
				
				libraryFile = libraryManager.libraryDir;
				
				if(url.indexOf("http://") == -1){
					videoPlayer.setControllerEnable(true);
					logManager.addLog("***動画の再生(ローカル)***");
					var file:File = new File(url);
					
					var videoId:String = LibraryManager.getVideoKey(decodeURIComponent(file.url));
					var videoTitle:String = videoId;
					if(videoId != null){
						var video:NNDDVideo = null;
						
						video = libraryManager.isExist(videoId);
						if(video != null){
							videoTitle = video.getVideoNameWithVideoID();
							if(file.exists){
								//ファイルが存在して、動画も存在するなら動画のURLを更新しておく
								video.uri = file.url;
								libraryManager.update(video, false);
								file = new File(video.getDecodeUrl());
							}
							
							this._isEconomyMode = video.isEconomy;
							
						}else{
							if(file.exists){
								//ファイルが存在して、動画が存在しないなら新しく登録
								video = new NNDDVideo(file.url, file.name);
								libraryManager.add(video, false);
								logManager.addLog("動画を管理対象に追加:" + file.nativePath);
							}
						}
					}
					
					if(!file.exists){
						Alert.show(Message.M_FILE_NOT_FOUND_REFRESH + "\n" + file.nativePath, Message.M_ERROR);
						logManager.addLog(Message.M_FILE_NOT_FOUND_REFRESH + "\n" + file.nativePath);
						Application.application.activate();
						return;
					}
					
					var commentPath:String = PathMaker.createNomalCommentPathByVideoPath(url);
					var ownerCommentPath:String = PathMaker.createOwnerCommentPathByVideoPath(url);
					var comments:Comments = new Comments(commentPath, ownerCommentPath, this.getCommentListProvider(), this.getOwnerCommentListProvider(), 
							this.ngListManager, this.videoInfoView.isShowOnlyPermissionComment, this.videoInfoView.isHideSekaShinComment, this.videoInfoView.showCommentCount);
					if(url.indexOf(".swf") != -1 || url.indexOf(".SWF") != -1){
						if(playList != null && playListIndex != -1){
							this.initWithPlayList(url, PlayerController.WINDOW_TYPE_SWF, comments, playList, videoNameList, playListName, playListIndex, true, false, null, videoTitle);
						}else{
							this.isPlayListingPlay = false;
							this.init(url, PlayerController.WINDOW_TYPE_SWF, comments, PathMaker.createThmbInfoPathByVideoPath(url), true, false, null, false, videoTitle);
						}
					}else if(url.indexOf(".mp4") != -1 || url.indexOf(".MP4") != -1 || url.indexOf(".flv") != -1 || url.indexOf(".FLV") != -1){
						if(playList != null && playListIndex != -1){
							this.initWithPlayList(url, PlayerController.WINDOW_TYPE_FLV, comments, playList, videoNameList, playListName, playListIndex, true, false, null, videoTitle);
						}else{
							this.isPlayListingPlay = false;
							this.init(url, PlayerController.WINDOW_TYPE_FLV, comments, PathMaker.createThmbInfoPathByVideoPath(url), true, false, null, false, videoTitle);
						}
					}
				}else if(url.match(new RegExp("http://smile")) != null){
					logManager.addLog("***動画の再生(ストリーミング)***");
					var commentPath:String = libraryManager.tempDir.url + "/nndd.xml";
					var ownerCommentPath:String = libraryManager.tempDir.url + "/nndd[Owner].xml";
					var comments:Comments = new Comments(commentPath, ownerCommentPath, this.getCommentListProvider(), this.getOwnerCommentListProvider(), 
							this.ngListManager, this.videoInfoView.isShowOnlyPermissionComment, this.videoInfoView.isHideSekaShinComment, this.videoInfoView.showCommentCount);
					
					videoPlayer.label_downloadStatus.text = "";
					
					//ストリーミング再生のときはthis.vieoURL（videoIDが含まれる方）を使う。
					if(videoTitle.indexOf(".swf") != -1 || videoTitle.indexOf(".SWF") != -1){
						
						if(playList != null && playListIndex != -1){
							this.initWithPlayList(url, PlayerController.WINDOW_TYPE_SWF, comments, playList, videoNameList, playListName, playListIndex, true, true, libraryFile.url + "/temp/nndd.flv", videoTitle);
						}else{
							this.isPlayListingPlay = false;
							this.init(url, WINDOW_TYPE_SWF, comments, libraryManager.tempDir.url + "/nndd[ThumbInfo].xml", true, true, videoTitle, false, videoTitle);
						}
					}else if(videoTitle.indexOf(".mp4") != -1 || videoTitle.indexOf(".MP4") != -1 || videoTitle.indexOf(".flv") != -1 || videoTitle.indexOf(".FLV") != -1){
						if(playList != null && playListIndex != -1){
							this.initWithPlayList(url, PlayerController.WINDOW_TYPE_FLV, comments, playList, videoNameList, playListName, playListIndex, true, true, libraryFile.url + "/temp/nndd.flv", videoTitle);
						}else{
							this.isPlayListingPlay = false;
							this.init(url, WINDOW_TYPE_FLV, comments, libraryManager.tempDir.url + "/nndd[ThumbInfo].xml", true, true, videoTitle, false, videoTitle);
						}
					}
				}else if(url.match(new RegExp("http://www.nicovideo.jp/watch/")) != null){
					logManager.addLog("***ストリーミング再生の準備***");
					if(mailAddress == "" || password == ""){
						Alert.show("ニコニコ動画にログインしてください。", Message.M_ERROR);
						logManager.addLog("ニコニコ動画にログインしてください。");
						Application.application.activate();
						return;
					}
					
					videoPlayer.setControllerEnable(false);
					
					try{
						
						destructor();
						videoPlayer.label_downloadStatus.text = "ニコニコ動画にアクセスしています...";
						
						var tempDir:File = new File(libraryManager.libraryDir.url + "/temp/");
						if(tempDir.exists){
							tempDir.moveToTrash();
						}
						
						tempDir = new File(libraryManager.tempDir.url);
						if(tempDir.exists){
							var itemList:Array = tempDir.getDirectoryListing();
							for each(var tempFile:File in itemList){
								if(!tempFile.isDirectory){
									try{
										tempFile.deleteFile();
									}catch(error:Error){
										trace(error.getStackTrace());
									}
								}
							}
						}
						
						
						
						if(nnddDownloaderForStreaming != null){
							nnddDownloaderForStreaming.close(true, false);
							nnddDownloaderForStreaming = null;
						}
						
						nnddDownloaderForStreaming = new NNDDDownloader(logManager);
						nnddDownloaderForStreaming.addEventListener(NNDDDownloader.DOWNLOAD_PROCESS_COMPLETE, function(event:Event):void{
							playMovie((event.target as NNDDDownloader).streamingUrl, playList, videoNameList, playListIndex, playListName, (event.target as NNDDDownloader).nicoVideoName, nnddDownloaderForStreaming.isEconomyMode);
							removeStreamingPlayHandler(event);
							nnddDownloaderForStreaming = null;
						});
						nnddDownloaderForStreaming.addEventListener(NNDDDownloader.COMMENT_GET_FAIL, getFailListener);
						nnddDownloaderForStreaming.addEventListener(NNDDDownloader.GETFLV_API_ACCESS_FAIL, getFailListener);
						nnddDownloaderForStreaming.addEventListener(NNDDDownloader.ICHIBA_INFO_GET_FAIL, getFailListener);
						nnddDownloaderForStreaming.addEventListener(NNDDDownloader.LOGIN_FAIL, getFailListener);
						nnddDownloaderForStreaming.addEventListener(NNDDDownloader.NICOWARI_GET_FAIL, getFailListener);
						nnddDownloaderForStreaming.addEventListener(NNDDDownloader.OWNER_COMMENT_GET_FAIL, getFailListener);
						nnddDownloaderForStreaming.addEventListener(NNDDDownloader.THUMB_IMG_GET_FAIL, getFailListener);
						nnddDownloaderForStreaming.addEventListener(NNDDDownloader.THUMB_INFO_GET_FAIL, getFailListener);
						nnddDownloaderForStreaming.addEventListener(NNDDDownloader.VIDEO_GET_FAIL, getFailListener);
						nnddDownloaderForStreaming.addEventListener(NNDDDownloader.WATCH_FAIL, getFailListener);
						nnddDownloaderForStreaming.addEventListener(NNDDDownloader.DOWNLOAD_PROCESS_ERROR, streamingPlayFailListener);
						nnddDownloaderForStreaming.addEventListener(NNDDDownloader.DOWNLOAD_PROCESS_CANCELD, streamingPlayFailListener);
						nnddDownloaderForStreaming.requestDownloadForStreaming(this.mailAddress, this.password, PathMaker.getVideoID(url), tempDir, videoInfoView.isAlwaysEconomyForStreaming);
						
					}catch(e:Error){
						videoPlayer.label_downloadStatus.text = "";
						videoPlayer.setControllerEnable(true);
						
						Alert.show("ストリーミング再生中に予期せぬ例外が発生しました。\nError:" + e, Message.M_ERROR);
						logManager.addLog("ストリーミング再生中に予期せぬ例外が発生しました。\nError:" + e + ":" + e.getStackTrace());
						Application.application.activate();
						nnddDownloaderForStreaming.close(true, true);
						nnddDownloaderForStreaming = null;
						
					}
					
				}
				
				logManager.addLog(Message.PLAY_VIDEO + ":" + decodeURIComponent(url));
				
			}catch(error:Error){
				
				videoPlayer.setControllerEnable(true);
				Alert.show(url + "を再生できませんでした。\n" + error, Message.M_ERROR);
				logManager.addLog("再生できませんでした:url=[" + url + "]\n" + error.getStackTrace());
				Application.application.activate();
			}
		}
		
		/**
		 * 取得失敗系リスナー
		 * @param event
		 * 
		 */
		public function getFailListener(event:IOErrorEvent):void{
			var status:String = "";
			if(event.type == NNDDDownloader.LOGIN_FAIL){
				status = "ログイン失敗";
			}else if(event.type == NNDDDownloader.WATCH_FAIL){
				status = "動画ページアクセス失敗";
			}else if(event.type == NNDDDownloader.GETFLV_API_ACCESS_FAIL){
				status = "APIアクセス失敗";
			}else if(event.type == NNDDDownloader.COMMENT_GET_FAIL){
				status = "コメント取得失敗";
			}else if(event.type == NNDDDownloader.OWNER_COMMENT_GET_FAIL){
				status = "投稿者コメント取得失敗";
			}else if(event.type == NNDDDownloader.NICOWARI_GET_FAIL){
				status = "ニコ割取得失敗";
			}else if(event.type == NNDDDownloader.THUMB_INFO_GET_FAIL){
				status = "サムネイル情報取得失敗";
			}else if(event.type == NNDDDownloader.THUMB_IMG_GET_FAIL){
				status = "サムネイル画像取得失敗";
			}else if(event.type == NNDDDownloader.ICHIBA_INFO_GET_FAIL){
				status = "市場情報取得失敗";
			}else if(event.type == NNDDDownloader.VIDEO_GET_FAIL){
				status = "動画取得失敗";
			} 
			
			logManager.addLog("\t" + status + ":" + event.type + ":" + event.text);
			videoPlayer.label_downloadStatus.text = status;
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		public function streamingPlayFailListener(event:Event):void{
			if(event.type == NNDDDownloader.DOWNLOAD_PROCESS_CANCELD){
				stop();
				videoPlayer.label_downloadStatus.text = "アクセスをキャンセルしました。";
				logManager.addLog("***ストリーミング再生をキャンセル***");
			}else if(event.type == NNDDDownloader.DOWNLOAD_PROCESS_ERROR){
				stop();
				videoPlayer.label_downloadStatus.text = "動画を取得できませんでした。\n" + event + ":" + (event as IOErrorEvent).text;
				logManager.addLog(NNDDDownloader.DOWNLOAD_PROCESS_ERROR + ":" + event + ":" + (event as IOErrorEvent).text);
				logManager.addLog("***ストリーミング再生に失敗***");
			}
			removeStreamingPlayHandler(event);
			this.nnddDownloaderForStreaming = null;
		}
		
		/**
		 * ストリーミング再生のURL取得に使うNNDDDownloaderからリスナを除去します。
		 * @param event
		 * 
		 */
		public function removeStreamingPlayHandler(event:Event):void{
//			(event.target as NNDDDownloader).removeEventListener(NNDDDownloader.DOWNLOAD_PROCESS_COMPLETE, stremaingPlayStartSuccess);
			(event.target as NNDDDownloader).removeEventListener(NNDDDownloader.DOWNLOAD_PROCESS_CANCELD, streamingPlayFailListener);
			(event.target as NNDDDownloader).removeEventListener(NNDDDownloader.DOWNLOAD_PROCESS_ERROR, streamingPlayFailListener);
			(event.target as NNDDDownloader).removeEventListener(NNDDDownloader.COMMENT_GET_FAIL, getFailListener);
			(event.target as NNDDDownloader).removeEventListener(NNDDDownloader.GETFLV_API_ACCESS_FAIL, getFailListener);
			(event.target as NNDDDownloader).removeEventListener(NNDDDownloader.ICHIBA_INFO_GET_FAIL, getFailListener);
			(event.target as NNDDDownloader).removeEventListener(NNDDDownloader.LOGIN_FAIL, getFailListener);
			(event.target as NNDDDownloader).removeEventListener(NNDDDownloader.NICOWARI_GET_FAIL, getFailListener);
			(event.target as NNDDDownloader).removeEventListener(NNDDDownloader.OWNER_COMMENT_GET_FAIL, getFailListener);
			(event.target as NNDDDownloader).removeEventListener(NNDDDownloader.THUMB_IMG_GET_FAIL, getFailListener);
			(event.target as NNDDDownloader).removeEventListener(NNDDDownloader.THUMB_INFO_GET_FAIL, getFailListener);
			(event.target as NNDDDownloader).removeEventListener(NNDDDownloader.VIDEO_GET_FAIL, getFailListener);
			(event.target as NNDDDownloader).removeEventListener(NNDDDownloader.WATCH_FAIL, getFailListener);
		}
		
		/**
		 * プレイリスト一覧をロードし直します。
		 */
		public function loadPlayListSummry():void{
			playListManager.readPlayListSummary(libraryFile.url + "/playList");
		}
		
		/**
		 * 指定されたインデックスのプレイリストを再度読み込みます
		 * @param index
		 * 
		 */
		public function loadPlayList(index:int = -1):void{
			playListManager.showPlayList(index);
		}
		
		/**
		 * 指定された名前のプレイリストのインデックスを返します。
		 * @param title
		 * @return 
		 * 
		 */
		public function getPlayListIndexByName(title:String):int{
			return playListManager.getPlayListIndexByName(title);
		}
		
		/**
		 * プレイリストを新規作成します。
		 * @param name
		 * 
		 */
		public function addNewPlayList(urlArray:Array, videoNameArray:Array):String{
			//プレイリスト新規作成
			var title:String = playListManager.addPlayList(null);
			var index:int = playListManager.getPlayListIndexByName(title);
			
			var videoArray:Array = new Array();
			for(var i:int = 0; i<urlArray.length; i++){
				var nnddVideo:NNDDVideo = new NNDDVideo(urlArray[i], videoNameArray[i]);
				videoArray.push(nnddVideo);
			}
			
			playListManager.addNNDDVideos(index, videoArray, 0);
			
			if(playListManager.isSelectedPlayList && index == playListManager.selectedPlayListIndex && index != -1){
				playListManager.showPlayList(index, true);
			}
			
			return title;
		}
		
		/**
		 * 指定されたタイトルのプレイリストを上書きします。プレイリストが存在しない場合は新規作成します。
		 * @param title
		 * @param urlArray
		 * @param videoNameArray
		 * 
		 */
		public function updatePlayList(title:String, urlArray:Array, videoNameArray:Array):void{
			var index:int = playListManager.getPlayListIndexByName(title);
			if(index == -1){
				addNewPlayList(urlArray, videoNameArray);
			}else{
				playListManager.updatePlayList(title, urlArray);
				playListManager.readPlayListSummary(libraryFile.url + "/playList");
				
				if(playListManager.isSelectedPlayList && index == playListManager.selectedPlayListIndex){
					playListManager.showPlayList(index, false);
				}
			}
		}
		
		/**
		 * 
		 * 
		 */
		public function watchOnWeb():void{
			var videoId:String = PathMaker.getVideoID(this.videoPlayer.title);
			if(videoId != null){
				navigateToURL(new URLRequest(WatchVideoPage.WATCH_VIDEO_PAGE_URL + videoId));
				logManager.addLog("ウェブブラウザで開く:" + WatchVideoPage.WATCH_VIDEO_PAGE_URL + videoId);
			}else{
				Alert.show("ビデオIDが見つからないため、URLを特定できませんでした。", Message.M_ERROR);
				logManager.addLog("DLリストへの追加失敗:ビデオIDが見つからないため、URLを特定できませんでした。")
			}
		}
		
		/**
		 * 
		 * 
		 */
		public function addDlList():void{
			var videoId:String = PathMaker.getVideoID(this.videoPlayer.title);
			if(videoId != null){
				var video:NNDDVideo = new NNDDVideo(WatchVideoPage.WATCH_VIDEO_PAGE_URL + videoId, this.videoPlayer.title);
				Application.application.addDownloadListForInfoView(video);
				logManager.addLog("InfoViewからDLリストへ追加:" + video.getDecodeUrl());
			}else{
				Alert.show("ビデオIDが見つからないため、DLリストに追加できませんでした。", Message.M_ERROR);
				logManager.addLog("DLリストへの追加失敗:ビデオIDが見つからないため、DLリストに動画を追加できませんでした。");
			}
		}
		
		
		/**
		 * 表示するコメントの太字を切り替えます。
		 * @param isFontBold
		 * 
		 */
		public function setCommentFontBold(isFontBold:Boolean):void{
			commentManager.setCommentBold(isFontBold);
		}
		
		/**
		 * 
		 * @param myListId
		 * 
		 */
		public function addMyList(myListId:String):void{
			var videoTitle:String = videoPlayer.title;
			
			logManager.addLog("***マイリストへの追加***");
			
			if(this._myListAdder == null){
				
				if(myListId == null || myListId == ""){
					Alert.show("マイリストが選択されていません。", Message.M_ERROR);
					logManager.addLog("***マイリストへの追加失敗***");
					Application.application.activate();
					return;
				}
				if(this.mailAddress == null || this.mailAddress == "" || this.password == null || this.password == ""){
					Alert.show("ニコニコ動画にログインできません。ユーザー名とパスワードを設定してください。");
					logManager.addLog("***マイリストへの追加失敗***");
					Application.application.activate();
					return;
				}
				var videoId:String = PathMaker.getVideoID(videoTitle);
				if(videoId == null){
					Alert.show("動画のIDが取得できませんでした。動画を再生し直した後、もう一度試してみてください。", Message.M_ERROR);
					logManager.addLog("***マイリストへの追加失敗***");
					Application.application.activate();
					return;
				}
				
				this._myListAdder = new NNDDMyListAdder(this.logManager);
				
				this._myListAdder.addEventListener(NNDDMyListAdder.ADD_MYLIST_SUCESS, function(event:Event):void{
					logManager.addLog("次の動画をマイリストに追加:" + videoTitle);
					logManager.addLog("***マイリストへの追加成功***");
					Alert.show("次の動画をマイリストに追加しました\n" + videoTitle, Message.M_MESSAGE);
					_myListAdder.close();
					_myListAdder = null;
				});
				this._myListAdder.addEventListener(NNDDMyListAdder.ADD_MYLIST_DUP, function(event:Event):void{
					logManager.addLog("次の動画はすでにマイリストに登録済:" + videoTitle);
					logManager.addLog("***マイリストへの追加失敗***");
					Alert.show("次の動画は既にマイリストに追加されています\n" + videoTitle, Message.M_MESSAGE);
					_myListAdder.close();
					_myListAdder = null;
				});
				this._myListAdder.addEventListener(NNDDMyListAdder.ADD_MYLSIT_FAIL, function(event:ErrorEvent):void{
					logManager.addLog("マイリストへの登録に失敗:" + videoTitle + ":" + event);
					logManager.addLog("***マイリストへの追加失敗***");
					Alert.show("マイリストへの登録に失敗\n" + event, Message.M_ERROR);
					Application.application.activate();
					_myListAdder.close();
					_myListAdder = null;
				});
				this._myListAdder.addEventListener(NNDDMyListAdder.LOGIN_FAIL, function(event:Event):void{
					logManager.addLog("マイリストへの登録に失敗:" + videoTitle + ":" + event);
					logManager.addLog("***マイリストへの追加失敗***");
					Alert.show("マイリストへの登録に失敗\n" + event, Message.M_ERROR);
					Application.application.activate();
					_myListAdder.close();
					_myListAdder = null;
				});
				this._myListAdder.addEventListener(NNDDMyListAdder.GET_MYLISTGROUP_FAIL, function(event:Event):void{
					logManager.addLog("マイリストへの登録に失敗:" + videoTitle + ":" + event);
					logManager.addLog("***マイリストへの追加失敗***");
					Alert.show("マイリストへの登録に失敗\n" + event, Message.M_ERROR);
					Application.application.activate();
					_myListAdder.close();
					_myListAdder = null;
				});
				
				_myListAdder.addMyList("http://www.nicovideo.jp/watch/" + videoId, myListId, this.mailAddress, this.password);	
				
			}else{
				
				logManager.addLog("マイリストへの登録をキャンセル:" + videoTitle);
				logManager.addLog("***マイリストへの追加失敗***");
				
				try{
					_myListAdder.close();
				}catch(error:Error){
					trace(error.getStackTrace());
				}
				_myListAdder = null;
			}
			
		}
		
		/**
		 * 現在再生しているコメントに日付情報を付加して退避します。
		 * 
		 */
		public function saveComment():void{
			
			
			
		}
		
	}
	
}