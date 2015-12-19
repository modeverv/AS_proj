package org.mineap.NNDD
{
	import flash.display.DisplayObjectContainer;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.utils.Timer;
	
	import mx.controls.Alert;
	import mx.controls.TileList;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import org.mineap.NNDD.model.NNDDVideo;
	import org.mineap.NNDD.util.PathMaker;

	/**
	 *
	 * LibraryManager.as
	 * ライブラリを管理するクラスです。
	 * 
	 * Copyright (c) 2008-2009 MAP - MineApplicationProject. All Rights Reserved.
	 *  
	 * @author shiraminekeisuke
	 * 
	 */
	public class LibraryManager extends EventDispatcher
	{
		
		public static const ITEM_LOADING_EVENT:String = "ItemLoadingEvent";
		public static const ITEM_LOAD_COMPLETE_EVENT:String = "ItemLoadCompleteEvent";
		
		public static const DELETED_IMAGE_URL:String = "http://www.nicovideo.jp/img/common/delete.jpg";
		
		private var nndd:DisplayObjectContainer;
		
		private var logManager:LogManager;
		
		private var loadWindow:LoadWindow;
		
//		/** NNDDVideoオブジェクトを入れる */
//		public var videoLibraries:Vector.<NNDDVideo> = new Vector.<NNDDVideo>();
		
		/** NNDDVideoオブジェクト用Map */
		private var libraryMap:Object = new Object();
		
		public var tagManager:TagManager;
		
		public static const LIBRARY_FILE_NAME:String = "library.xml";
		
		private var fileCount:int = 0;
		
		private var _libraryFile:File = null;
		private var _libraryDir:File = null;
				
		private static var libraryManager:LibraryManager = null;
		
		public static const SWF_S:String = "swf";
		public static const SWF_L:String = "SWF";
		public static const FLV_S:String = "flv";
		public static const FLV_L:String = "FLV";
		public static const MP4_S:String = "mp4";
		public static const MP4_L:String = "MP4";
		public static const NICOWARI:String = "[Nicowari]";
		
		
		/**
		 * 唯一のインスタンスの生成
		 * 
		 * @param nndd
		 * @param tagProvider
		 * 
		 */
		public static function initialize(nndd:DisplayObjectContainer, tagProvider:Array):void{
			libraryManager = new LibraryManager(nndd, tagProvider, LogManager.getInstance());
		}
		
		/**
		 * シングルトンパターン。先に initialize() を呼ぶ事。
		 * @return 
		 * 
		 */
		public static function getInstance():LibraryManager{
			return libraryManager;
		}
		
		/**
		 * 
		 * @param nndd
		 * @param logManager
		 * 
		 */
		public function LibraryManager(nndd:DisplayObjectContainer, tagProvider:Array, logManager:LogManager)
		{
			this.nndd = nndd;
			this.tagManager = new TagManager(tagProvider, this, logManager);
			this.logManager = logManager;
		}
		
		/**
		 * 
		 * @param libFileDir ライブラリファイルの保存先ディレクトリ
		 * @param libDir 動画の保存先ディレクトリ
		 * @param isBootTime
		 * @param isRenew
		 * 
		 */
		public function loadLibraryFile(libFileDir:File, libDir:File, isBootTime:Boolean, isRenew:Boolean = false):void{
			var timer:Timer = new Timer(200, 1);
			
			this._libraryFile = new File(libFileDir.url + "/" + LIBRARY_FILE_NAME);
			this._libraryDir = libDir;
			
			if(!_libraryFile.exists && isBootTime){
				Alert.show("ライブラリファイルがありません。\n今すぐライブラリを更新しますか？\n" + _libraryDir.nativePath, "確認", (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
					if(event.detail == Alert.YES){
						
						loadWindow = PopUpManager.createPopUp(nndd, LoadWindow, true) as LoadWindow;
						loadWindow.label_loadingInfo.text = "ライブラリを更新中";
						loadWindow.progressBar_loading.label = "更新中...";
						PopUpManager.centerPopUp(loadWindow);
						
						timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:TimerEvent):void{
						
							try{
								if(_libraryDir.exists){
									addEventListener(ITEM_LOADING_EVENT, function(event:Event):void{
										loadWindow.label_loadingInfo.text = "ライブラリを更新中:" + fileCount + "件完了";
										loadWindow.validateNow();
									});
									renewLibrary(libraryDir.url);
								}
								PopUpManager.removePopUp(loadWindow);
								logManager.addLog("ライブラリを更新:" + _libraryDir.nativePath);
								
								Alert.show("ライブラリの更新が完了しました。", "通知");
								
							}catch(error:Error){
								PopUpManager.removePopUp(loadWindow);
								logManager.addLog("ライブラリの更新中に予期せぬエラーが発生しました。\n" + error.getStackTrace());
								Alert.show("ライブラリの更新中に予期せぬエラーが発生しました。\n" + error, Message.M_ERROR);
							}
							
							//タグ登録
							tagManager.loadTag();
							
						});
						
						timer.start();
						
					}
				}, null, Alert.YES);
				return;
			}else if(isRenew){
				loadWindow = PopUpManager.createPopUp(nndd, LoadWindow, true) as LoadWindow;
				loadWindow.label_loadingInfo.text = "ライブラリを更新中";
				loadWindow.progressBar_loading.label = "更新中...";
				PopUpManager.centerPopUp(loadWindow);
				
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:TimerEvent):void{
					addEventListener(ITEM_LOADING_EVENT, function(event:Event):void{
						loadWindow.label_loadingInfo.text = "ライブラリを更新中:" + fileCount + "件完了";
						loadWindow.validateNow();
					});
					renewLibrary(_libraryDir.url);
					
					//タグ登録
					tagManager.loadTag();
					
					PopUpManager.removePopUp(loadWindow);
					logManager.addLog("ライブラリを更新:" + _libraryDir.nativePath);
					
					Alert.show("ライブラリの更新が完了しました。", "通知");
				});
				
				timer.start();
			}else{
				loadWindow = PopUpManager.createPopUp(nndd, LoadWindow, true) as LoadWindow;
				loadWindow.label_loadingInfo.text = "ライブラリをロード中";
				loadWindow.progressBar_loading.label = "ロード中...";
				PopUpManager.centerPopUp(loadWindow);
				
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:TimerEvent):void{
					var fileIO:FileIO = new FileIO(logManager);
					fileIO.addEventListener(FileIO.LIBRARY_LOAD_SUCCESS, function(event:Event):void{
						
						PopUpManager.removePopUp(loadWindow);
						logManager.addLog("ライブラリファイルを読み込み:" + _libraryFile.nativePath);
						
						//タグ登録
						tagManager.loadTag();
						
					});
					fileIO.addEventListener(FileIO.LIBRARY_LOAD_SUCCESS_WITH_VUP, function(event:Event):void{
						PopUpManager.removePopUp(loadWindow);
						logManager.addLog("ライブラリファイルを読み込み:" + _libraryFile.nativePath);
						
						//タグ登録
						tagManager.loadTag();
						
						Alert.show("NNDD v1.10以降ではサムネイル画像を管理できます。ダウンロード済みのビデオからサムネイル画像情報を収集しますか？\n情報の収集が完了するまで時間がかかる事があります。", 
								"確認", (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
							if(event.detail == Alert.YES){
								
								loadWindow = PopUpManager.createPopUp(nndd, LoadWindow, true) as LoadWindow;
								loadWindow.label_loadingInfo.text = "情報を収集中";
								loadWindow.progressBar_loading.label = "収集中...";
								PopUpManager.centerPopUp(loadWindow);
								
								var myTimer:Timer = new Timer(200,1);
								
								myTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:TimerEvent):void{
									
									try{
									
										if(_libraryDir.exists){
											addEventListener(ITEM_LOADING_EVENT, function(event:Event):void{
												loadWindow.label_loadingInfo.text = "情報を収集中:" + fileCount + "件完了";
												loadWindow.validateNow();
											});
											renewLibrary(_libraryDir.url);
										}
										PopUpManager.removePopUp(loadWindow);
										logManager.addLog("バージョンアップ後のライブラリ更新:" + _libraryDir.nativePath);
										
										Alert.show("ライブラリの更新が完了しました。", "通知");
										
									}catch(error:Error){
										PopUpManager.removePopUp(loadWindow);
										logManager.addLog("バージョンアップ後のライブラリ更新中に予期せぬエラーが発生しました。\n" + error.getStackTrace());
										Alert.show("バージョンアップ後のライブラリ更新中に予期せぬエラーが発生しました。\n" + error, Message.M_ERROR);
									}
									
									//タグ登録
									tagManager.loadTag();
									
								});
								
								myTimer.start();
							}
						}, null, Alert.YES);
								
					});
					fileIO.addURLLoaderEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
					fileIO.addURLLoaderEventListener(IOErrorEvent.NETWORK_ERROR, loadErrorHandler);
					fileIO.addURLLoaderEventListener(IOErrorEvent.VERIFY_ERROR, loadErrorHandler);
					fileIO.loadLibraryItem(_libraryFile.url, libraryMap);
				});
				
				timer.start();
			}
		}
		
		/**
		 * ライブラリファイルの場所を返します。
		 * @return 
		 * 
		 */
		public function get libraryFile():File{
			return this._libraryFile;
		}
		
		/**
		 * 現在のライブラリディレクトリを返します。
		 * @return 
		 * 
		 */
		public function get libraryDir():File{
			return this._libraryDir;
		}
		
		/**
		 * NNDDのシステムディレクトリを返します。
		 * @return 
		 * 
		 */
		public function get systemFileDir():File{
			var systemDir:File = new File(libraryDir.url + "/system/");
			return systemDir;
		}
		
		/**
		 * NNDDの一時ファイル保存ディレクトリを返します。
		 * @return 
		 * 
		 */
		public function get tempDir():File{
			var tempDir:File = new File(systemFileDir.url + "/temp/");
			return tempDir;
		}
		
		/**
		 * 
		 * @param dir ライブラリ保存先ディレクトリ
		 * 
		 */
		public function saveLibraryFile(dir:File):void{
			
			try{
				
				var filePath:String = dir.url;
				
				loadWindow = PopUpManager.createPopUp(nndd, LoadWindow, true) as LoadWindow;
				loadWindow.label_loadingInfo.text = "ライブラリを保存中";
				loadWindow.progressBar_loading.label = "保存中...";
				PopUpManager.centerPopUp(loadWindow);
				
				var fileIO:FileIO = new FileIO(logManager);
				fileIO.saveLibrary(filePath + "/" + LIBRARY_FILE_NAME, libraryMap);
				
				PopUpManager.removePopUp(loadWindow);
				logManager.addLog("ライブラリを保存:" + new File(filePath + "/" + LIBRARY_FILE_NAME).nativePath);
				fileIO.closeFileStream();
				
			}catch(ioError:IOError){
				logManager.addLog("ライブラリの保存に失敗:" + ioError + ":" + ioError.getStackTrace());
				Alert.show("ライブラリの保存に失敗しました。" + ioError);
				
				if(loadWindow != null){
					PopUpManager.removePopUp(loadWindow);
				}
			}
			
		}
		
		/**
		 * LibraryManagerが保持するライブラリパスにライブラリファイルを保存します。
		 * 
		 */
		public function saveLibraryFileByDefault():void{
			try{
				var fileIO:FileIO = new FileIO(logManager);
				fileIO.addFileStreamEventListener(IOErrorEvent.IO_ERROR, saveErrorHandler);
				fileIO.addFileStreamEventListener(IOErrorEvent.NETWORK_ERROR, saveErrorHandler);
				fileIO.saveLibrary(this._libraryFile.url, libraryMap);
				
				logManager.addLog("ライブラリを保存:" + this._libraryFile.nativePath);
				fileIO.closeFileStream();
			}catch(ioError:IOError){
				logManager.addLog("ライブラリの保存に失敗:" + ioError + ":" + ioError.getStackTrace());
				Alert.show("ライブラリの保存に失敗しました。" + ioError);
			}
		}
		
		/**
		 * ライブラリファイルの保存場所を更新します。
		 * 
		 * @param libraryDir
		 * 
		 */
		public function changeLibraryDir(libraryDir:File, isSave:Boolean = true):void{
			if(libraryDir.isDirectory){
				this._libraryDir = libraryDir;
				if(isSave){
					this.saveLibraryFileByDefault();
				}
			}
		}
		
		/**
		 * 指定されたVideoIDをもつビデオを削除します。
		 * 
		 * @param videoId
		 * @param isSaveLibraryFile ライブラリファイルを保存するかどうか
		 * @return 
		 * 
		 */
		public function remove(videoId:String, isSaveLibraryFile:Boolean):NNDDVideo{
			
			var video:NNDDVideo = libraryMap[videoId];
			
			delete libraryMap[videoId];
			
			if(isSaveLibraryFile){
				saveLibraryFileByDefault();
			}
			
			return video;
		}
		
		/**
		 * 指定されたNNDDVideoでライブラリの動画を更新します。
		 * 
		 * @param video
		 * @param isSaveLibraryFile
		 * @return 
		 * 
		 */
		public function update(video:NNDDVideo, isSaveLibraryFile:Boolean):Boolean{
			
			var key:String = getVideoKey(video.getDecodeUrl());
			
			if(key != null){
				libraryMap[key] = video;
				return true;
			}else{
				return false;
			}
		}
		
		/**
		 * 指定されたNNDDVideoをライブラリに追加します。
		 * 
		 * @param video
		 * @param isSaveLibraryFile ライブラリファイルを保存するかどうか
		 * @param isOverWrite 動画が登録済の場合に上書きするかどうか
		 * @return 
		 * 
		 */
		public function add(video:NNDDVideo, isSaveLibraryFile:Boolean, isOverWrite:Boolean = false):Boolean{
			var url:String = video.getDecodeUrl();
			
			if(!url.match(/\[Nicowari\]/)){
				var key:String = getVideoKey(video.getDecodeUrl());
				if(key != null && isExist(key) == null){
					
					libraryMap[key] = video;
					
					if(isSaveLibraryFile){
						saveLibraryFileByDefault();
					}
					
					return true;
				}else{
					if(isOverWrite){
						libraryMap[key] = video;
						if(isSaveLibraryFile){
							saveLibraryFileByDefault();
						}
						
						return true;
					}else{
						return false;
					}
				}

			}else{
				return false;
			}
		}
		
		/**
		 * 指定された動画IDの動画が存在するかどうかを調べます。
		 * 
		 * @param videoId
		 * @return 
		 * 
		 */
		public function isExistByVideoId(videoId:String):NNDDVideo{
			var nnddVideo:NNDDVideo = null;
			if(videoId != null){
				nnddVideo = libraryMap[videoId];
			}
			return nnddVideo;
		}
		
		/**
		 * 指定されたキーの動画が存在するかどうか調べます。<br />
		 * キーは {@link #getVideoKey()} で取得した値です。
		 * @param key
		 * @return 
		 * 
		 */
		public function isExist(key:String):NNDDVideo{
			var nnddVideo:NNDDVideo = null;
			if(key != null){
				nnddVideo = libraryMap[key];
			}
			return nnddVideo;
		}
		
		/**
		 * ライブラリの更新を行います。
		 * 
		 * @param libraryFilePath
		 * @return 
		 * 
		 */
		private function renewLibrary(libraryFilePath:String):void{
			
			fileCount = 0;
			
			var saveDir:File = new File(libraryFilePath);
			addDownLoadedItems(saveDir, true);
			
			saveLibraryFileByDefault();
		}
		
		
		/**
		 * 指定されたディレクトリ下にあり、指定したソース番号に該当するファイルを、
		 * ダウンロード済みリストに追加します。
		 * 
		 * @param saveDir
		 * @param isShowAllItems
		 * @param newMap
		 * 
		 */
		private function addDownLoadedItems(saveDir:File, isShowAllItems:Boolean):void{
			
			var fileList:Array = saveDir.getDirectoryListing();
			
			var videoList:Array = new Array();
			
			for(var index:int = 0; index<fileList.length;index++){
				if(isShowAllItems && fileList[index].isDirectory){
					addDownLoadedItems(fileList[index], isShowAllItems);
				}else if(!fileList[index].isDirectory){
					
					var extension:String = (fileList[index] as File).extension;
					if(extension == LibraryManager.FLV_S || extension == LibraryManager.MP4_S 
						|| extension == LibraryManager.FLV_L || extension == LibraryManager.MP4_L){
						
						videoList.push(fileList[index].url);
						
					}else if(extension == LibraryManager.SWF_S || extension == LibraryManager.SWF_L){
						if((fileList[index] as File).nativePath.indexOf(LibraryManager.NICOWARI) == -1){
							videoList.push(fileList[index].url);
						}
						
					}
				}
			}
			
			fileCount += videoList.length;
			trace(fileCount);
			
			for(var i:int = 0; i<videoList.length; i++){
				
				var key:String = getVideoKey(videoList[i]);
				
				libraryMap[key] = loadInfo(videoList[i]);
				if(i%10 == 0){
					dispatchEvent(new Event(ITEM_LOADING_EVENT));
				}
			}
			
			dispatchEvent(new Event(ITEM_LOAD_COMPLETE_EVENT));
		}
		
		/**
		 * ライブラリへの登録に必要な情報をロードし、その情報を格納したNNDDVideoオブジェクトを返します。
		 * また、古いライブラリ情報から動画がエコノミーモードかどうかもチェックし、該当するVideoがあればそのデータを反映します。
		 * 
		 * @param filePath
		 * @return 
		 * 
		 */
		public function loadInfo(filePath:String):NNDDVideo{
			var fileIO:FileIO = new FileIO(logManager);
			var thumbInfoXML:XML = fileIO.loadXMLSync(PathMaker.createThmbInfoPathByVideoPath(filePath), true);
			
			var thumbUrl:String = LibraryManager.DELETED_IMAGE_URL;
			var tagArray:Vector.<String> = new Vector.<String>;
			if(thumbInfoXML != null && thumbInfoXML.attribute("status") == "ok"){
				var tags:XMLList = thumbInfoXML.thumb.tags;
				for(var i:int=0; i<tags.tag.length(); i++){
					tagArray.push((tags.tag[i] as XML).toString());
				}
				thumbUrl = thumbInfoXML.thumb.thumbnail_url;
			}else{
				// サムネイル情報が存在しない時、もしくは動画が削除されているときは、既存の動画からタグ情報を取得
				var tempVideo:NNDDVideo = this.isExist(LibraryManager.getVideoKey(decodeURIComponent(filePath)));
				if(tempVideo != null){
					tagArray = tempVideo.tagStrings;
				}
			}
			
			var video:NNDDVideo = new NNDDVideo(filePath, null, false, tagArray);
			var file:File = new File(filePath);
			if(file.exists){
				video.creationDate = file.creationDate;
				video.modificationDate = file.modificationDate;
			}else{
				video.creationDate = new Date();
				video.modificationDate = new Date();
			}
			
			//thumbUrlが指定されていなければThumbXMLの値を設定
			var localThumbUrl:String = PathMaker.createThumbImgFilePath(video.getDecodeUrl());
			if((new File(localThumbUrl)).exists){
				//ローカルにサムネイルがあればそれを使う
				video.thumbUrl = localThumbUrl;
			}else{
				//無ければthumbXMLのurlを使う
				video.thumbUrl = thumbUrl;
			}
			
			var key:String = getVideoKey(video.getDecodeUrl());
			if(key != null){
				var oldVideo:NNDDVideo = libraryMap[key];
				if(oldVideo != null){
					video.isEconomy = oldVideo.isEconomy;
					video.playCount = oldVideo.playCount;
				}
			}
			
			return video;
			
		}
		
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function loadErrorHandler(event:Event):void{
			if(loadWindow != null){
				PopUpManager.removePopUp(loadWindow);
			}
			Alert.show("ライブラリの読み込みに失敗しました。" + event, Message.M_ERROR);
			logManager.addLog("ライブラリの読み込みに失敗:" + event);
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function saveErrorHandler(event:Event):void{
			if(loadWindow != null){
				PopUpManager.removePopUp(loadWindow);
			}
			Alert.show("ライブラリの読み込みに失敗しました。" + event, Message.M_ERROR);
			logManager.addLog("ライブラリの保存に失敗:" + event);
		}
		
		/**
		 * タグ情報を取得します。
		 * 
		 * @param dir タグ情報を収集するディレクトリ。nullの場合はライブラリのルートディレクトリ。
		 * @return 
		 * 
		 */
		public function collectTag(dir:File = null):Array{
			var array:Array = new Array();
			var map:Object = new Object();
			
			for each(var video:NNDDVideo in libraryMap){
				if(dir != null && (decodeURIComponent(dir.url) == video.getDecodeUrl().substr(0, video.getDecodeUrl().lastIndexOf("/")))){
					for each(var tag:String in video.tagStrings){
						if(map[tag] == null){
							array.push(tag);
							map[tag] = tag;
						}
					}
				}else if(dir == null){
					for each(var tag:String in video.tagStrings){
						if(map[tag] == null){
							array.push(tag);
							map[tag] = tag;
						}
					}
				}
			}
			return array;
		}
		
		/**
		 * arrayで指定された名前のビデオがもつタグを返します。
		 * 
		 * @param array
		 * @return 
		 * 
		 */
		public function collectTagByVideoName(nameArray:Array):Array{
			var tagArray:Array = new Array();
			var tagMap:Object = new Object();
			
			for each(var videoName:String in nameArray){
				var key:String = getVideoKey(videoName);
				if(key != null){
					var video:NNDDVideo = isExist(key);
					if(video != null){
						for each(var tag:String in video.tagStrings){
							if(tagMap[tag] == null){
								tagArray.push(tag);
								tagMap[tag] = tag;
							}
						}
					}
				}
			}
			
			return tagArray;
		}
		
		/**
		 * 渡された文字列からタグを検索し、Tagビューに反映します。
		 * 
		 * @param tileList
		 * @param word
		 * 
		 */
		public function searchTagAndShow(tileList:TileList, word:String):void{
			
			//wordをスペースで分割
			var pattern:RegExp = new RegExp("\\s*([^\\s]*)", "ig");
			var array:Array = word.match(pattern);
			
			tagManager.searchTagAndShow(tileList, array);
				
		}
		
		
		/**
		 * ディレクトリのパスが変わったときに呼ばれます。
		 * ライブラリに登録されている項目で、oldDirUrlを含むビデオのパスを、newDirUrlに変更します。
		 * @param oldDirUrl デコード済の変更前ディレクトリURL
		 * @param newDirUrl でコード済の変更後ディレクトリURL
		 */
		public function changeDirName(oldDirUrl:String, newDirUrl:String):void{
			try{
				var oldPattern:RegExp = new RegExp(oldDirUrl);
				var isFailed:Boolean = false;
				
				var key:String = getVideoKey(oldDirUrl);
				if(key != null){
					var video:NNDDVideo = libraryMap[key];
					if(video != null && video.getDecodeUrl().indexOf(oldDirUrl) != -1){
						var url:String = video.getDecodeUrl().replace(oldPattern, newDirUrl);
						var newVideo:NNDDVideo = new NNDDVideo(encodeURI(url), null, video.isEconomy, video.tagStrings, video.modificationDate, video.creationDate, video.thumbUrl, video.playCount);
						libraryMap[key] = newVideo;
						
						//ライブラリ保存
						saveLibraryFileByDefault();
					}
				}
				
				logManager.addLog("ライブラリを更新:" + new File(newDirUrl).nativePath);
			}catch(error:Error){
				logManager.addLog("フォルダ名の変更をライブラリに反映できませんでした。「設定 > 更新」からライブラリを更新し直してください。\n" + error.getStackTrace());
				Alert.show("フォルダ名の変更をライブラリに反映できませんでした。「設定 > 更新」からライブラリを更新し直してください。:" + error ,Message.M_ERROR);
			}
		}
		
		/**
		 * saveDirで指定されたディレクトリ下に存在するビデオを返します。
		 * 
		 * @param saveDir
		 * @param isShowAll tureに設定すると、saveDir下のすべてのビデオを返します。
		 * @return 
		 * 
		 */
		public function getNNDDVideoArray(saveDir:File, isShowAll:Boolean):Vector.<NNDDVideo>{
			
			var saveUrl:String = decodeURIComponent(saveDir.url);
			var videos:Vector.<NNDDVideo> = new Vector.<NNDDVideo>();
			
			if(saveUrl.lastIndexOf("/") != saveUrl.length-1){
				saveUrl += "/";
			}
			var pattern:RegExp = new RegExp(saveUrl);
			
			for each(var video:NNDDVideo in libraryMap){
				var index:int = video.getDecodeUrl().indexOf(saveUrl);
				if(index != -1){
					if(!isShowAll){
						var url:String = video.getDecodeUrl().replace(pattern, "");
						if(url.indexOf("/") == -1){
							videos.push(video);
						}
					}else{
						videos.push(video);
					}
				}
			}
			
			return videos;
		}
		
		/**
		 * LibraryManagerからNNDDオブジェクトを探すためのキーを返します。<br />
		 * 動画IDが存在すれば動画IDを、存在しなければ拡張子を除いた動画のタイトルをかえします。
		 * 
		 * @param videoTitle
		 * @return 
		 */
		public static function getVideoKey(videoTitle:String):String{
			var videoId:String = PathMaker.getVideoID(videoTitle);
			if(videoId == null){
				videoId = videoTitle;
				var index:int = videoTitle.lastIndexOf("/");
				if(index != -1){
					videoId = videoTitle.substring(index+1);
				}
				//拡張子を取り除く
				index = videoId.lastIndexOf(".");
				if(index != -1){
					videoId = videoId.substring(0, index);
				}
			}
			return videoId;
		}

	}
}