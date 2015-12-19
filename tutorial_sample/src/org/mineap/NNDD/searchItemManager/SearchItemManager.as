package org.mineap.NNDD.searchItemManager
{
	import flash.filesystem.File;
	
	import mx.controls.Alert;
	
	import org.mineap.NNDD.FileIO;
	import org.mineap.NNDD.LibraryManager;
	import org.mineap.NNDD.LogManager;
	import org.mineap.NNDD.model.SearchItem;
	import org.mineap.NNDD.model.SearchSortType;
	import org.mineap.NNDD.model.SearchType;
	import org.mineap.NNDD.util.TreeDataBuilder;

	/**
	 * SearchItemManager.as<br>
	 * SaerchItemManagerクラスは、検索条件を管理します。<br>
	 * <br>
	 * Copyright (c) 2009 MAP - MineApplicationProject. All Rights Reserved.
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class SearchItemManager
	{
		
		/**
		 * デフォルトの検索項目です
		 */
		public static const DEF_SEARCH_ITEMS:Array = new Array(
			new SearchItem("#音楽", SearchSortType.COMMENT_NEW, SearchType.TAG, "音楽"),
			new SearchItem("#エンターテイメント", SearchSortType.COMMENT_NEW, SearchType.TAG, "エンターテイメント"),
			new SearchItem("#アニメ", SearchSortType.COMMENT_NEW, SearchType.TAG, "アニメ"),
			new SearchItem("#ゲーム", SearchSortType.COMMENT_NEW, SearchType.TAG, "ゲーム"),
			new SearchItem("#ラジオ", SearchSortType.COMMENT_NEW, SearchType.TAG, "ラジオ"),
			new SearchItem("#スポーツ", SearchSortType.COMMENT_NEW, SearchType.TAG, "スポーツ"),
			new SearchItem("#科学", SearchSortType.COMMENT_NEW, SearchType.TAG, "科学"),
			new SearchItem("#料理", SearchSortType.COMMENT_NEW, SearchType.TAG, "料理"),
			new SearchItem("#政治", SearchSortType.COMMENT_NEW, SearchType.TAG, "政治"),
			new SearchItem("#動物", SearchSortType.COMMENT_NEW, SearchType.TAG, "動物"),
			new SearchItem("#歴史", SearchSortType.COMMENT_NEW, SearchType.TAG, "歴史"),
			new SearchItem("#自然", SearchSortType.COMMENT_NEW, SearchType.TAG, "自然"),
			new SearchItem("#ニコニコ動画講座", SearchSortType.COMMENT_NEW, SearchType.TAG, "ニコニコ動画講座"),
			new SearchItem("#演奏してみた", SearchSortType.COMMENT_NEW, SearchType.TAG, "演奏してみた"),
			new SearchItem("#歌ってみた", SearchSortType.COMMENT_NEW, SearchType.TAG, "歌ってみた"),
			new SearchItem("#踊ってみた", SearchSortType.COMMENT_NEW, SearchType.TAG, "踊ってみた"),
			new SearchItem("#投稿者コメント", SearchSortType.COMMENT_NEW, SearchType.TAG, "投稿者コメント"),
			new SearchItem("#日記", SearchSortType.COMMENT_NEW, SearchType.TAG, "日記"),
			new SearchItem("#アンケート", SearchSortType.COMMENT_NEW, SearchType.TAG, "アンケート"),
			new SearchItem("#チャット", SearchSortType.COMMENT_NEW, SearchType.TAG, "チャット"),
			new SearchItem("#テスト", SearchSortType.COMMENT_NEW, SearchType.TAG, "テスト"),
			new SearchItem("#ニコニ・コモンズ", SearchSortType.COMMENT_NEW, SearchType.TAG, "ニコニ・コモンズ"),
			new SearchItem("#ひとこと動画", SearchSortType.COMMENT_NEW, SearchType.TAG, "ひとこと動画"),
			new SearchItem("#その他", SearchSortType.COMMENT_NEW, SearchType.TAG, "その他"),
			new SearchItem("#R-18", SearchSortType.COMMENT_NEW, SearchType.TAG, "R-18")
		);
		
		/**
		 * ライブラリマネージャーです。
		 */
		private var _libraryManager:LibraryManager;
		
		/**
		 * 画面上の検索条件のリストのデータプロバイダーです
		 */
		private var _searchItemProvider:Array;
		
		/**
		 * 画面上の検索条件のリストに対応するSearchItemのリストです
		 */
		private var _searchItemMap:Object;
		
		/**
		 * 
		 */
		private var _logManager:LogManager;
		
		/**
		 * コンストラクタ
		 * @param libraryManager
		 * @param searchItemProvider
		 * @param logManager
		 * 
		 */
		public function SearchItemManager(libraryManager:LibraryManager, searchItemProvider:Array, logManager:LogManager)
		{
			this._libraryManager = libraryManager;
			this._searchItemMap = new Object();
			this._searchItemProvider = searchItemProvider;
			this._logManager = logManager;
		}
		
		/**
		 * 
		 * @param searchItem
		 * @param isDir
		 * @param isSave
		 * @param oldName
		 * @param children
		 * @return 
		 * 
		 */
		public function updateMyList(searchItem:SearchItem, isDir:Boolean, isSave:Boolean, oldName:String, children:Array = null):Object{
			
			var object:Object = searchByName(oldName, this._searchItemProvider);
			
			delete this._searchItemMap[oldName];
			
			var builder:TreeDataBuilder = new TreeDataBuilder();
			var folder:Object = builder.getFolderObject(searchItem.name);
			
			object.label = searchItem.name;
			if(children != null){
				object.children = children;
			}
			
			this._searchItemMap[searchItem.name] = searchItem;
			
			return object;
		}
		
		/**
		 * 検索条件を追加します。同名の検索条件は追加できません。
		 * @param searchItem 追加する検索条件
		 * @param searchItemName 検索条件名
		 * @param isDir ディレクトリかどうか
		 * @param isSave 保存するかどうか
		 * @param index 追加するインデックス。-1の時は最後に追加。
		 * @param children ディレクトリを追加した際に同時に追加する子。
		 * 
		 */
		public function addSearchItem(searchItem:SearchItem, isDir:Boolean, isSave:Boolean, index:int = -1, children:Array = null):Object{
			var exsits:Boolean = false;
			var item:SearchItem = this._searchItemMap[searchItem.name];
			var addedTreeObject:Object = null;
			
			if(item != null){
				exsits = true;
			}
			
			if(!exsits){
				
				var builder:TreeDataBuilder = new TreeDataBuilder();
				
				if(isDir){
					
					var folder:Object = builder.getFolderObject(searchItem.name);
					if(children != null){
						folder.children = children;
					}
					
					if(index == -1){
						this._searchItemProvider.push(folder);
						this._searchItemMap[searchItem.name] = searchItem;
					}else{
						this._searchItemProvider.splice(index, 0, folder);
						this._searchItemMap[searchItem.name] = searchItem;
					}
					
					addedTreeObject = folder;
					
				}else{
					
					var file:Object = builder.getFileObject(searchItem.name);
					
					if(index == -1){
						this._searchItemProvider.push(file);
						this._searchItemMap[searchItem.name] = searchItem;
					}else{
						this._searchItemProvider.splice(index, 0, file);
						this._searchItemMap[searchItem.name] = searchItem;
					}
					
					addedTreeObject = file;
					
				}
				
				if(isSave){
					this.saveSearchItems(this._libraryManager.libraryDir);
				}
				
				return addedTreeObject;
			}else{
				return null;
			}
		}
		
		/**
		 * 
		 * @param name
		 * @return 
		 * 
		 */
		public function search(name:String):Object{
			return searchByName(name, this._searchItemProvider);
		}
		
		/**
		 * 
		 * @param searchItemName
		 * @return 
		 * 
		 */
		public function searchByName(searchItemName:String, array:Array):Object{
			for(var index:int = 0; index<array.length; index++){
				
				var object:Object = array[index];
				if(object.hasOwnProperty("children")){
					
					if(object.label == searchItemName){
						return object;
					}else{
						//フォルダのなかの項目かもしれない。探す。
						var tempObject:Object = searchByName(searchItemName, object.children);
						if(tempObject != null){
							return tempObject;
						}
					}
				}else{
					//ファイル
					if(object.label == searchItemName){
						return object;
					}
				}
				
			}
			return null;
		}
		
		/**
		 * 
		 * @param searchItemName
		 * @return 
		 * 
		 */
		public function isExsits(searchItemName:String):Boolean{
			
			var object:Object = this._searchItemMap[searchItemName];
			if(object != null){
				return true;
			}
			return false;
		}
		
		/**
		 * 検索条件を削除します。
		 * @param searchItemName
		 * @return 削除したTreeの項目
		 * 
		 */
		public function removeSearchItem(searchItemName:String, isSave:Boolean):Object{
			var deleteObject:Object = deleteSearchItemFromTree(searchItemName, this._searchItemProvider);
			if(deleteObject != null){
				if(isSave){
					this.saveSearchItems(LibraryManager.getInstance().libraryDir);
				}
				delete this._searchItemMap[searchItemName];
				return deleteObject;
			}
			return null;
		}
		
		/**
		 * 
		 * @param searchItemName
		 * @param searchItemArray
		 * @return 
		 * 
		 */
		public function deleteSearchItemFromTree(searchItemName:String, searchItemArray:Array):Object{
			for(var index:int = 0; index<searchItemArray.length; index++){
				
				var object:Object = searchItemArray[index];
				if(object.hasOwnProperty("children") && object.children != null){
					
					if(object.label == searchItemName){
						//フォルダそのものを消す
						return searchItemArray.splice(index, 1)[0];
												
					}else{
						//フォルダのなかの項目かもしれない。探す。
						var deleteObject:Object = deleteSearchItemFromTree(searchItemName, object.children);
						if(deleteObject != null){
							return deleteObject;
						}
					}
				}else{
					//ファイル
					if(object.label == searchItemName){
						
						return searchItemArray.splice(index, 1)[0];
						
					}
				}
					
			}
			return null;
		}
		
		
		/**
		 * 
		 * @param searchItemName
		 * @return 
		 * 
		 */
		public function getSearchItem(searchItemName:String):SearchItem{
			return this._searchItemMap[searchItemName];
		}
		
		/**
		 * デフォルトの検索項目をトップに追加します。
		 * 
		 */
		public function addDefSearchItems():void{
			
			var addCount:int = 0;
			
			for each(var searchItem:SearchItem in DEF_SEARCH_ITEMS){
				
				if(addSearchItem(searchItem, false, false, addCount)){
					addCount++;
				}
				
			}
			
		}
		
		/**
		 * 
		 * @param xml
		 * @param searchItemArray
		 * @param searchItemMap
		 * 
		 */
		public function addSearchItemFromXML(xml:XML, searchItemArray:Array, searchItemMap:Object):void{
			for each(var temp:XML in xml.children()){
				
				var name:String = String(temp.@name);
				var searchItem:SearchItem = null;
				
				var builder:TreeDataBuilder = new TreeDataBuilder();
				
				if(temp.@isDir != null && temp.@isDir != undefined && temp.@isDir == "true"){
					//ディレクトリの時
					var folder:Object = builder.getFolderObject(name);
					
					searchItem = new SearchItem(name, SearchSortType.COMMENT_COUNT_ASCENDING, SearchType.KEY_WORD, "", true);
					
					if(temp.children().length() > 0){
						addSearchItemFromXML(temp, folder.children, searchItemMap);
					}
					
					searchItemArray.push(folder);
					searchItemMap[name] = searchItem;
					
				}else{
					var sortType:int = 0;
					if(temp.@sortType == null || temp.@sortType == undefined || temp.@sortType == "" ){
						sortType = int(temp.sortType);
					}else{
						sortType = int(temp.@sortType);
					}
					var searchType:int = 0;
					if(temp.@searchType == null || temp.@searchType == undefined || temp.@searchType == "" ){
						searchType = int(temp.searchType);
					}else{
						searchType = int(temp.@searchType);
					}
					var searchWord:String = null;
					if(temp.@searchWord == null || temp.@searchWord == undefined || temp.@searchWord == "" ){
						searchWord = String(temp.searchWord);
					}else{
						searchWord = String(temp.@searchWord);
					}
					
					var file:Object = builder.getFileObject(name);
					
					searchItem = new SearchItem(name, sortType, searchType, searchWord);
					searchItemArray.push(file);
					searchItemMap[searchItem.name] = searchItem;
				}
			}
		}
		
		/**
		 * 検索条件ファイルを読み出します。
		 * @param dir
		 * 
		 */
		public function readSearchItems(dir:File):Boolean{
			
			try{
				
				var saveFile:File = new File(dir.url + "/searchItems.xml");
				
				if(saveFile.exists){
					var fileIO:FileIO = new FileIO(this._logManager);
					var xml:XML = fileIO.loadXMLSync(saveFile.url, true);
				
					addSearchItemFromXML(xml, this._searchItemProvider, this._searchItemMap);
					
					this._logManager.addLog("検索条件の読み込み完了:" + saveFile.nativePath);
					
					return true;
					
				}else{
					this._logManager.addLog("検索条件ファイルが存在しません:" + saveFile.nativePath);
					
					return false;
				}
				
			}catch(error:Error){
				Alert.show("検索条件ファイルの読み込みに失敗しました:" + dir.url + "/searchItems.xml" + "\n" + error);
				this._logManager.addLog("検索条件ファイルの読み込みに失敗" + dir.url + "/searchItems.xml" + "\n" + error + ":" + error.getStackTrace());
			}
			return false;
		}
		
		/**
		 * 
		 * @param saveXML
		 * @param searchItemArray
		 * @param searchItemMap
		 * @return 
		 * 
		 */
		public function addSearchItemToXML(saveXML:XML, searchItemArray:Array, searchItemMap:Object):XML{
			
			for(var i:int = 0; i<searchItemArray.length; i++){
				
				var searchItem:SearchItem = searchItemMap[searchItemArray[i].label];
				var xml:XML = <searchItem/>;
				
				if(searchItem != null){
					
					if(searchItem.isDir){
						xml.@name = searchItem.name;
						xml.@searchWord = "";
						xml.@isDir = true;
						
						var array:Array = searchItemArray[i].children;
						if(array != null && array.length >= 1){
							xml = addSearchItemToXML(xml, array, searchItemMap);
						}
					}else{
						var name:String = searchItemArray[i].label;
						xml.@name = searchItemMap[name].name;
						xml.@sortType = searchItemMap[name].sortType;
						xml.@searchType = searchItemMap[name].searchType;
						xml.@searchWord = searchItemMap[name].searchWord;
						xml.@isDir = false;
					}
					saveXML.appendChild(xml);
					
				}
			}
			
			return saveXML;
		}
		
		/**
		 * 検索条件ファイルを保存します。
		 * @param dir
		 * 
		 */
		public function saveSearchItems(dir:File):void{
			
			try{
				var saveFile:File = new File(dir.url + "/searchItems.xml");
				
				var saveXML:XML = <searchItems/>;
				saveXML = addSearchItemToXML(saveXML, this._searchItemProvider, this._searchItemMap);
				
				var fileIO:FileIO = new FileIO(this._logManager);
				fileIO.saveXMLSync(saveFile, saveXML);
				
				this._logManager.addLog("検索条件を保存:" + saveFile.nativePath);
				
			}catch(error:Error){
				Alert.show("検索条件ファイルの保存に失敗しました:" + dir.url + "/searchItems.xml" + "\n" + error);
				this._logManager.addLog("検索条件ファイルの保存に失敗" + dir.url + "/searchItems.xml" + "\n" + error + ":" + error.getStackTrace());
			}
			
		}
		
	}
}