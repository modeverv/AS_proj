package org.mineap.NNDD
{
	import flash.filesystem.File;
	
	import mx.controls.TileList;
	
	import org.mineap.NNDD.model.NNDDVideo;
	
	/**
	 *
	 * TagManager.as
	 * 
	 * Copyright (c) 2008-2009 MAP - MineApplicationProject. All Rights Reserved.
	 *  
	 * @author shiraminekeisuke
	 * 
	 */
	public class TagManager
	{
		
		public var tagProvider:Array;
		public var tagMap:Object;
		public var tempTagArray:Array;
		private var libraryManager:LibraryManager;
		private var logManager:LogManager;
		
		/**
		 * 
		 * @param dataProvider
		 * @param libraryManager
		 * @param logManager
		 * 
		 */
		public function TagManager(dataProvider:Array, libraryManager:LibraryManager, logManager:LogManager)
		{
			this.tagMap = new Object();
			this.tagProvider = dataProvider;
			this.libraryManager = libraryManager;
			this.logManager = logManager;
		}
		
		/**
		 * 
		 * 
		 */
		public function loadTag():void{
			
			var array:Array = libraryManager.collectTag();
			for(var i:int=0; i<array.length; i++){
				if(!isExists(array[i])){
					tagProvider.push(array[i]);
					tagMap[String(array[i])] = String(array[i]);
				}
			}
			
			tagProvider.sort();
			tagProvider.unshift("すべて");
			
			logManager.addLog("ローカルのタグ情報を表示(すべて):" + tagProvider.length);
		}
		
		/**
		 * 
		 * @param tag
		 * @return 
		 * 
		 */
		public function isExists(tag:String):Boolean{
			if(tagMap[tag] != null){
				return true;
			}
			return false;
		}
		
		/**
		 * 指定されたディレクトリに対応するタグを取得し、表示します。
		 * ディレクトリを指定しない場合はすべてのタグを取得して表示します。
		 * @param dir
		 * 
		 */
		public function tagRenew(tileList:TileList, dir:File = null):void{
			
			tagProvider.splice(0, tagProvider.length);
			tagMap = new Object();
			
			if(dir == null){
				loadTag();
				
			}else{
				var array:Array = libraryManager.collectTag(dir);
				
				for(var i:int=0; i<array.length; i++){
					if(!isExists(array[i])){
						tagProvider.push(array[i]);
						tagMap[String(array[i])] = String(array[i]);
					}
				}
				
				tagProvider.sort();
				tagProvider.unshift("すべて");
				
				logManager.addLog("ローカルのタグ情報を表示(ディレクトリ指定):" + decodeURIComponent(dir.url) + ":" + tagProvider.length);
			}
			
			tileList.dataProvider = tagProvider;
		}
		
		/**
		 * 
		 * @param tileList
		 * @param playList
		 * 
		 */
		public function tagRenewOnPlayList(tileList:TileList, videoArray:Array):void{
			tagProvider.splice(0, tagProvider.length);
			tagMap = new Object();
			
			var videoNameArray:Array = new Array();
			for each(var video:NNDDVideo in videoArray){
				videoNameArray.push(video.getVideoNameWithVideoID());
			}
			
			var array:Array = libraryManager.collectTagByVideoName(videoNameArray);
			for(var i:int=0; i<array.length; i++){
				if(!isExists(array[i])){
					tagProvider.push(array[i]);
					tagMap[String(array[i])] = String(array[i]);
				}
			}
			
			tagProvider.sort();
			tagProvider.unshift("すべて");
			
			logManager.addLog("プレイリストのタグ情報を表示:" + tagProvider.length);
			
			tileList.dataProvider = tagProvider;
		}
		
		
		/**
		 * タグ表示用のTileListを更新します。
		 * @param words
		 * 
		 */
		public function searchTagAndShow(tileList:TileList, words:Array):void{
			
			var newTagProvider:Array = new Array();
			for(var i:int = 0; i < tagProvider.length; i++ ){
				var existCount:int = 0;
				for(var j:int = 0; j<words.length; j++){
					if(j < 1){
						if(tagProvider[i].indexOf(words[j]) != -1){
							existCount++;
						}
					}else if(words[j] != " "){
						var tempWord:String = (words[j] as String).substring(1);
						if(tagProvider[i].indexOf(tempWord) != -1){
							existCount++;
						}
					}else{
						existCount++;
					}
				}
				if(existCount >= words.length){
					//発見した項目を追加
					newTagProvider.push(tagProvider[i]);
				}
			}
			
			newTagProvider.sort();
			tagProvider = newTagProvider;
			
			tileList.dataProvider = tagProvider;
		}
		

	}
}