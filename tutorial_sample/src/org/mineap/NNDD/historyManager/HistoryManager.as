package org.mineap.NNDD.historyManager
{
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	
	import org.mineap.NNDD.FileIO;
	import org.mineap.NNDD.LibraryManager;
	import org.mineap.NNDD.LogManager;
	import org.mineap.NNDD.model.NNDDVideo;
	import org.mineap.NNDD.util.DateUtil;
	import org.mineap.NNDD.util.PathMaker;

	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class HistoryManager
	{
		
		private var logger:LogManager = LogManager.getInstance();
		
		private static var historyManager:HistoryManager = null;
		
		private var historyProvider:ArrayCollection;
		
		public static const HISTORY_MAX_COUNT:int = 100;
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public static function getInstance():HistoryManager{
			return historyManager;
		}
		
		/**
		 * 
		 * @param historyProvider
		 * 
		 */
		public static function initialize(historyProvider:ArrayCollection):void{
			historyManager = new HistoryManager(historyProvider);
		}
		
		/**
		 * 
		 * 
		 */
		public function HistoryManager(historyProvider:ArrayCollection)
		{
			this.historyProvider = historyProvider;
		}
		
		/**
		 * 
		 * @param videoId
		 * 
		 */
		public function addVideoByVideoId(videoId:String):void{
			var nnddVideo:NNDDVideo = LibraryManager.getInstance().isExist(videoId);
			
			if(nnddVideo != null){
				addVideoByNNDDVideo(nnddVideo);
			}
		}
		
		/**
		 * 
		 * @param nnddVideo
		 * 
		 */
		public function addVideoByNNDDVideo(nnddVideo:NNDDVideo, playDate:Date = null, isDownloaded:Boolean = true):void{
			
			var date:Date = new Date();
			
			//動画が追加済みだったら削除
			var index:int = getIndex(nnddVideo.getVideoNameWithVideoID());
			if(index != -1){
				remove(index);
			}
				
			if(playDate != null){
				date = playDate;
			}
			
			if(isDownloaded){
				
				historyProvider.addItemAt({
					dataGridColumn_thumbImage:nnddVideo.thumbUrl,
					dataGridColumn_videoName:nnddVideo.getVideoNameWithVideoID(),
					dataGridColumn_playdate:DateUtil.getDateString(date),
					dataGridColumn_condition:"ダウンロード済み",
					dataGridColumn_count:nnddVideo.playCount,
					dataGridColumn_url:nnddVideo.getDecodeUrl()
				}, 0);
				
			}else{
				
				historyProvider.addItemAt({
					dataGridColumn_thumbImage:nnddVideo.thumbUrl,
					dataGridColumn_videoName:nnddVideo.getVideoNameWithVideoID(),
					dataGridColumn_playdate:DateUtil.getDateString(date),
					dataGridColumn_condition:"未ダウンロード",
					dataGridColumn_count:0,
					dataGridColumn_url:nnddVideo.getDecodeUrl()
				}, 0);
				
			}
				
			
			while(historyProvider.length > 100){
				historyProvider.removeItemAt(historyProvider.length-1);
			}
		}
		
		/**
		 * 
		 * 
		 */
		public function saveHistory():void{
			
			var history:XML = <history/>;
			
			for(var i:int = 0; i<historyProvider.length; i++){
				var historyItem:XML = <historyItem/>;
				
				var videoName:String = historyProvider[i].dataGridColumn_videoName;
				var videoId:String = PathMaker.getVideoID(videoName);
				var video:NNDDVideo = null;
				
				if(videoId != null){
					video = LibraryManager.getInstance().isExist(videoId);
					
				}
				
				var date:Date = DateUtil.getDate(historyProvider[i].dataGridColumn_playdate);
				
				var playCount:int = 0;
				if(video != null){
					playCount = video.playCount;
				}
				
				var isDownloaded:Boolean = false;
				if(historyProvider[i].dataGridColumn_condition == "ダウンロード済み"){
					isDownloaded = true;
				}
				
				var url:String = historyProvider[i].dataGridColumn_url;
				if(video != null){
					url = video.getDecodeUrl();
				}
				
				historyItem.@thumbUrl = encodeURIComponent(historyProvider[i].dataGridColumn_thumbImage),
				historyItem.@videoName = encodeURIComponent(historyProvider[i].dataGridColumn_videoName),
				historyItem.@playDate = date.time,
				historyItem.@playCount = playCount,
				historyItem.@condition = isDownloaded,
				historyItem.@url = encodeURIComponent(url)
				
				history.appendChild(historyItem);
			}
			
			var fileIO:FileIO = new FileIO(LogManager.getInstance());
			
			var file:File = new File(LibraryManager.getInstance().systemFileDir.url + "/history.xml");
			
			fileIO.saveXMLSync(file, history);
			
			var oldFile:File = new File(LibraryManager.getInstance().libraryDir.url + "/history.xml");
			if(oldFile.exists){
				oldFile.moveToTrash();
			}
			
		}
		
		/**
		 * 
		 * 
		 */
		public function loadHistory():void{
			
			var fileIO:FileIO = new FileIO(LogManager.getInstance());
			var file:File = LibraryManager.getInstance().systemFileDir;
			
			file.url += "/history.xml";
			
			if(!file.exists){
				file.url = LibraryManager.getInstance().libraryDir.url + "/history.xml";
			}
			
			LogManager.getInstance().addLog("履歴の読み込みを開始:" + file.nativePath);
			
			try{
				
				var historyXml:XML = fileIO.loadXMLSync(file.url, true);
				
				for each(var historyItem:XML in historyXml.children()){
					
					var playDate:Date = new Date(Number(historyItem.@playDate));
					var playCount:int = historyItem.@playCount;
					var url:String = historyItem.@url;
					var isDownloaded:Boolean = new Boolean(historyItem.@condition);
					var condition:String = "未ダウンロード";
					if(isDownloaded){
						condition = "ダウンロード済み";
					}
					
					historyProvider.addItem({
						dataGridColumn_thumbImage:decodeURIComponent(historyItem.@thumbUrl),
						dataGridColumn_videoName:decodeURIComponent(historyItem.@videoName),
						dataGridColumn_playdate:DateUtil.getDateString(playDate),
						dataGridColumn_count:playCount,
						dataGridColumn_condition:condition,
						dataGridColumn_url:decodeURIComponent(url)
					});
					
				}
				
			}catch(error:Error){
				trace(error.getStackTrace());
				LogManager.getInstance().addLog("履歴の読み込みに失敗:" + error + ":" + error.getStackTrace());
			}
			
			LogManager.getInstance().addLog("履歴の読み込み完了");
			
		}
		
		/**
		 * 履歴の内容を更新します。
		 * 
		 */
		public function refresh():void{
			for(var i:int = 0; i<historyProvider.length; i++){
				
				var videoId:String = LibraryManager.getVideoKey(historyProvider[i].dataGridColumn_videoName);
				var video:NNDDVideo = null;
				if(videoId != null){
					video = LibraryManager.getInstance().isExist(videoId);
				}
				videoId = PathMaker.getVideoID(videoId);
				
				if(video != null){
					
					historyProvider.setItemAt({
						dataGridColumn_thumbImage:historyProvider[i].dataGridColumn_thumbImage,
						dataGridColumn_videoName:historyProvider[i].dataGridColumn_videoName,
						dataGridColumn_playdate:historyProvider[i].dataGridColumn_playdate,
						dataGridColumn_condition:"ダウンロード済み",
						dataGridColumn_count:video.playCount,
						dataGridColumn_url:video.getDecodeUrl()
					}, i);
					
				}else if(videoId != null){
					
					historyProvider.setItemAt({
						dataGridColumn_thumbImage:historyProvider[i].dataGridColumn_thumbImage,
						dataGridColumn_videoName:historyProvider[i].dataGridColumn_videoName,
						dataGridColumn_playdate:historyProvider[i].dataGridColumn_playdate,
						dataGridColumn_condition:"未ダウンロード",
						dataGridColumn_count:historyProvider[i].dataGridColumn_count,
						dataGridColumn_url:"http://www.nicovideo.jp/watch/" + videoId
					}, i);
					
				}else{
					
					historyProvider.setItemAt({
						dataGridColumn_thumbImage:historyProvider[i].dataGridColumn_thumbImage,
						dataGridColumn_videoName:historyProvider[i].dataGridColumn_videoName,
						dataGridColumn_playdate:historyProvider[i].dataGridColumn_playdate,
						dataGridColumn_condition:"未ダウンロード",
						dataGridColumn_count:historyProvider[i].dataGridColumn_count,
						dataGridColumn_url:historyProvider[i].dataGridColumn_url
					}, i);
					
				}
			}
		}
		
		/**
		 * 履歴一覧からすべての履歴を取り除きます。
		 * 
		 */
		public function clear():void{
			historyProvider.removeAll();
		}
		
		/**
		 * 履歴一覧から指定されたインデックスの項目を取り除きます。
		 * @param index
		 * 
		 */
		public function remove(index:int):void{
			historyProvider.removeItemAt(index);
		}
		
		/**
		 * 指定された動画の名前の項目があるインデックスを返します。
		 * @param videoName
		 * @return 
		 * 
		 */
		public function getIndex(videoName:String):int{
			for(var i:int = 0; i<historyProvider.length; i++){
				if(historyProvider[i].dataGridColumn_videoName.indexOf(videoName) != -1){
					return i;
				}
			}
			return -1;
		}
		
	}
}