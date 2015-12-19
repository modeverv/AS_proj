package org.mineap.NNDD
{
	import flash.events.FileListEvent;
	import flash.filesystem.File;
	
	import org.mineap.NNDD.util.PathMaker;
	import org.mineap.NNDD.util.DateUtil
	import org.mineap.NNDD.model.NNDDVideo;
	
	import mx.collections.ArrayCollection;
	import mx.controls.DataGrid;
	import mx.controls.TileList;
	import mx.controls.ToggleButtonBar;

	/**
	 * DownloadedListManager.as
	 * ダウンロード済みアイテム表示用のリストを管理します。
	 * 
	 * Copyright (c) 2008 MAP - MineApplicationProject. All Rights Reserved.
	 * 
	 * @author shiraminekeisuke
	 * 
	 */	
	public class DownloadedListManager
	{
		
		private var bar:ToggleButtonBar;
		private var sorceListArray:ArrayCollection;
		private var downloadedListArray:ArrayCollection;
		private var searchArray:ArrayCollection;
		private var libraryManager:LibraryManager;
		
		public static const SORCE_ALL:int = 0;
		public static const SORCE_SINGLE_DOWNLOAD:int = 1;
		
		
		/**
		 * コンストラクタ。<br>
		 * 与えられた引数を使ってDownloadedListManagerを初期化します。 
		 * @param bar
		 * @param sorceListArray
		 * @param downloadedListArray
		 * 
		 */
		public function DownloadedListManager(bar:ToggleButtonBar, sorceListArray:ArrayCollection, downloadedListArray:ArrayCollection)
		{
			this.bar = bar;
			this.sorceListArray = sorceListArray;
			this.downloadedListArray = downloadedListArray;
			this.libraryManager = LibraryManager.getInstance();
		}
		
		/**
		 * ソースリストとダウンロード済みリストを最新の状態に更新します。
		 * 
		 * @param url 更新対象のディレクトリを示すurlです。。
		 * 
		 */
		public function updateDownLoadedItems(url:String):void{
			
			//updateSorceListItems();
			updateDownloadedListItems(url);
			
		}
		
		/**
		 * ソースリストを最新の状態に更新します。
		 * 
		 */
		public function updateSorceListItems():void{
			
			//this.sorceListArray.refresh();
			
		}
		
		/**
		 * ダウンロード済みリストを最新の状態に更新します。
		 * @param sorceIndex
		 * 
		 */
		public function updateDownloadedListItems(url:String):void{
			this.downloadedListArray.removeAll();
			if(url == null){
				url = libraryManager.libraryDir.url;
			}
			var myFile:File = new File(url);
			var sorceType:int = 0;
			if(-1 == myFile.url.indexOf(libraryManager.libraryDir.url)){
				sorceType = 2;
			}
			addDownLoadedItems(myFile);
		}
		
		/**
		 * 指定されたディレクトリ下にあり、指定したソース番号に該当するファイルを、
		 * ダウンロード済みリストに追加します。
		 * 
		 * @param saveDir
		 * @param isShowAllItems
		 */
		public function addDownLoadedItems(saveDir:File):void{

			var oldDate:Date = new Date();
			trace(oldDate.getTime());

			this.downloadedListArray.addItem({
				dataGridColumn_thumbImage: "",
				dataGridColumn_videoName: "loading...",
				dataGridColumn_date: "",
				dataGridColumn_count: "",
				dataGridColumn_videoPath: "",
				dataGridColumn_condition: ""
			});

			saveDir.addEventListener(FileListEvent.DIRECTORY_LISTING, directoryListingEventHandler, false, 0, true);
			saveDir.getDirectoryListingAsync();
			
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function directoryListingEventHandler(event:FileListEvent):void{
			var fileList:Array = event.files;
			var targetFileList:Vector.<File> = new Vector.<File>();
//			var targetFileList:Array = new Array();
			
			(event.currentTarget as File).removeEventListener(FileListEvent.DIRECTORY_LISTING, directoryListingEventHandler);
			
//			var oldDate:Date = new Date();
//			var newDate:Date = new Date();
//			trace("fileList.length:" + fileList.length);
//			trace(newDate.getTime() - oldDate.getTime() + " ms");
//			oldDate = newDate;
			
			var fileListLen:int = fileList.length;
			var file:File = null;
			var extension:String = null;
			var fileIndex:int = 0;
			for(var index:int = 0; index<fileListLen; index++){
				
				file = File(fileList[index]);
				
				if(!file.isDirectory){
					extension = file.extension;
					if(extension != null){
						extension = extension.toLocaleLowerCase();
						if(extension == LibraryManager.FLV_S || extension == LibraryManager.MP4_S){
							
							targetFileList[fileIndex] = file;
							fileIndex++;
							
						}else if(extension == LibraryManager.SWF_S){
							if(file.nativePath.indexOf(LibraryManager.NICOWARI) == -1){
								targetFileList[fileIndex] = file;
								fileIndex++;
							}
							
						}
					}
				}
				
			}
			
			
//			newDate = new Date();
//			trace("targetFileList.length:" + targetFileList.length);
//			trace(newDate.getTime() - oldDate.getTime() + " ms");
//			oldDate = newDate;
			
			this.downloadedListArray.removeAll();
			
			for(var i:int = 0; i<targetFileList.length; i++){
				
				var myFile:File = targetFileList[i];
				
				if(myFile.exists){
					
					var decodedUrl:String = decodeURIComponent(myFile.url);
					var video:NNDDVideo = libraryManager.isExist(PathMaker.getVideoID(decodedUrl));
					var status:String = "";
					var thumbUrl:String = "";
					var playCount:Number = 0;
					var creationDate:Date = null;
					
					if(video != null){
						thumbUrl = video.thumbUrl;
						playCount = video.playCount;
						creationDate = video.creationDate;
						if(video.isEconomy){
							status = "エコノミー画質";
						}
					}
					
					if(thumbUrl == ""){
						thumbUrl = PathMaker.createThumbImgFilePath(decodedUrl, true);
					}
					if(creationDate == null){
						creationDate = myFile.creationDate;
					}
					
					this.downloadedListArray.addItem({
						dataGridColumn_thumbImage: thumbUrl,
						dataGridColumn_videoName: decodedUrl.substring(decodedUrl.lastIndexOf("/")+1),
						dataGridColumn_date: DateUtil.getDateString(creationDate),
						dataGridColumn_count: playCount,
						dataGridColumn_videoPath: decodedUrl,
						dataGridColumn_condition: status
					});
					
				}
				
			}
			
//			newDate = new Date();
//			trace(newDate.getTime() - oldDate.getTime() + " ms");
//			oldDate = newDate;
				
		}
		
		
		/**
		 * 引数で渡されたファイルがすでにダウンロード済みリストに存在するかどうかを判定する。
		 * @param filePath　判定したいファイルのアドレス。File.urlに格納されている文字列を渡す。
		 * @return 存在する場合はTrue
		 * 
		 */
		private function isListAddedItem(filePath:String):Boolean
		{
			try{
				for(var index:int = 0; index < this.downloadedListArray.length; index++){
					var path:String = this.downloadedListArray.getItemAt(index).dataGridColumn_videoPath.toString;
					
					if(filePath.indexOf(path) != -1){
						return true;
					}
				}
			}catch(error:Error){}
			
			return false;
		}
		
		/**
		 * 引数で渡されたテキストが既にソースリストに存在するかどうかを判定する。
		 * @param text 判定したいテキスト
		 * @return 存在する場合はtrueを返す
		 * 
		 */
		private function isListAddedSorceItem(text:String):Boolean
		{
			for(var index:int = 0; index < this.sorceListArray.length; index++){
				var listText:String = String(this.sorceListArray.getItemAt(index));
				if(listText.indexOf(text) != -1){
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * 現在表示しているダウンロード済みリスト内から引数で指定された文字列に該当するムービー名のムービーを探し、
		 * リストに表示します。<br>
		 * 長さが0以下の文字列を引数に渡すと、初期状態のリストを表示します。
		 * 
		 * @param dataGrid
		 * @param tileList
		 * @param word
		 * 
		 */
		public function searchAndShow(dataGrid:DataGrid, tileList:TileList, word:String):void{
			
			if(word.length > 0){
				
				if(downloadedListArray.length > 0 && downloadedListArray[0].dataGridColumn_videoName != "loading..." ){
					//wordをスペースで分割
					var pattern:RegExp = new RegExp("\\s*([^\\s]*)", "ig");
					var array:Array = word.match(pattern);
					
					this.searchArray = null;
					this.searchArray = new ArrayCollection();
					
					var iSize:int = dataGrid.dataProvider.length;
					for(var i:uint = 0; i < iSize ; i++ ){
						var existCount:int = 0;
						
						var jSize:int = array.length;
						for(var j:uint = 0; j<jSize; j++){
							if(j < 1){
								if(String(dataGrid.dataProvider[i].dataGridColumn_videoName).toUpperCase().indexOf(String(array[j]).toUpperCase()) != -1){
									existCount++;
								}
							}else if(array[j] != " "){
								var tempWord:String = (array[j] as String).substring(1);
								if(String(dataGrid.dataProvider[i].dataGridColumn_videoName).toUpperCase().indexOf(String(tempWord).toUpperCase()) != -1){
									existCount++;
								}
							}else{
								existCount++;
							}
						}
						if(existCount >= jSize){
							searchArray.addItem({
								dataGridColumn_thumbImage:downloadedListArray[i].dataGridColumn_thumbImage,
								dataGridColumn_videoName:dataGrid.dataProvider[i].dataGridColumn_videoName,
								dataGridColumn_date:dataGrid.dataProvider[i].dataGridColumn_date,
								dataGridColumn_condition:dataGrid.dataProvider[i].dataGridColumn_condition,
								dataGridColumn_count:dataGrid.dataProvider[i].dataGridColumn_count,
								dataGridColumn_videoPath:dataGrid.dataProvider[i].dataGridColumn_videoPath,
								dataGridColumn_nicoVideoUrl: dataGrid.dataProvider[i].dataGridColumn_nicoVideoUrl
							});
						}
					}
					
					dataGrid.dataProvider = searchArray;
					
				}else{
					
					dataGrid.dataProvider = null;
					
				}
				
			}else{
				if(tileList.selectedItems.length == 0){
					this.searchArray = null;
					dataGrid.dataProvider = downloadedListArray;
				}else{
					searchAndShowByTag(dataGrid, tileList.selectedItems);
				}
			}
			
		}
		
		/**
		 * 
		 * @param tags
		 * @return 
		 * 
		 */
		public function searchAndShowByTag(dataGrid:DataGrid, tags:Array):void{
			if(tags.length > 0 && tags[0] != "すべて" ){
				
				this.searchArray = null;
				this.searchArray = new ArrayCollection();
				
				var iSize:int = downloadedListArray.length;
				for(var i:int = 0; i < iSize; i++ ){
					var existCount:int = 0;
					var videoName:String = downloadedListArray[i].dataGridColumn_videoName;
					var videoId:String = PathMaker.getVideoID(videoName);
					
					var jSize:int = tags.length;
					for(var j:uint = 0; j<jSize; j++){
						
						var video:NNDDVideo = libraryManager.isExist(videoId);
						if(video != null){
							
							var kSize:int = video.tagStrings.length;
							for(var k:uint = 0; k<kSize; k++){
								if(String(video.tagStrings[k]).toUpperCase().indexOf(String(tags[j]).toUpperCase()) != -1){
									existCount++;
								} 
							}
							
						}
					}
					if(existCount >= jSize){
						searchArray.addItem({
							dataGridColumn_thumbImage:downloadedListArray[i].dataGridColumn_thumbImage,
							dataGridColumn_videoName:downloadedListArray[i].dataGridColumn_videoName,
							dataGridColumn_date:downloadedListArray[i].dataGridColumn_date,
							dataGridColumn_condition:downloadedListArray[i].dataGridColumn_condition,
							dataGridColumn_count:downloadedListArray[i].dataGridColumn_count,
							dataGridColumn_videoPath:downloadedListArray[i].dataGridColumn_videoPath,
							dataGridColumn_nicoVideoUrl: downloadedListArray[i].dataGridColumn_nicoVideoUrl
						});
					}
				}
				
				dataGrid.dataProvider = searchArray;
			}else{
				this.searchArray = null;
				dataGrid.dataProvider = downloadedListArray;
			}
		}
		
		/**
		 * 引数で指定されたインデックスに該当するムービーに対する絶対パスを返します。
		 * @param selectedIndex
		 * @return インデックスに該当するダウンロード済みリストのムービーの絶対パス
		 * 
		 */
		public function getVideoPath(selectedIndex:int):String{
			if(this.searchArray != null){
				if(searchArray.length > selectedIndex){
					return searchArray[selectedIndex].dataGridColumn_videoPath;
				}else{
					return null;
				}
				
			}else{
				if(downloadedListArray.length > selectedIndex){
					return downloadedListArray[selectedIndex].dataGridColumn_videoPath;
				}else{
					return null;
				}
			}
		}
		
		/**
		 * 表示中の項目をリフレッシュします。
		 * 
		 */
		public function refresh():void{
			if(this.downloadedListArray != null){
				this.downloadedListArray.refresh();
			}
			if(this.searchArray != null){
				this.searchArray.refresh();
			}
		}
		
	}
}