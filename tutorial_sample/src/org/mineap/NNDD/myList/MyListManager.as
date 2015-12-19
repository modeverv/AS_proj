package org.mineap.NNDD.myList
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	
	import org.mineap.NNDD.FileIO;
	import org.mineap.NNDD.LibraryManager;
	import org.mineap.NNDD.LogManager;
	import org.mineap.NNDD.util.TreeDataBuilder;

	/**
	 * MyListManager.as<br>
	 * MyListManagerクラスは、マイリストを管理するクラスです。<br>
	 * <br>
	 * Copyright (c) 2008-2009 MAP - MineApplicationProject. All Rights Reserved.
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class MyListManager extends EventDispatcher
	{
		
		private var _myListMap:Object = new Object();
		private var _libraryManager:LibraryManager;
		private var _tree_MyList:Array;
		private var _logManager:LogManager;
		
		public var lastTitle:String = "";
		
		/**
		 * 
		 * @param libraryManager
		 * @param tree_myList
		 * @param logManager
		 * 
		 */
		public function MyListManager(libraryManager:LibraryManager, tree_myList:Array, logManager:LogManager)
		{
			this._libraryManager = libraryManager;
			this._tree_MyList = tree_myList;
			this._logManager = logManager;
		}
		
		/**
		 * 
		 * @param myListUrl
		 * @param myListName
		 * @param isDir
		 * @param isSave
		 * @param oldName
		 * @param children
		 * @return 
		 * 
		 */
		public function updateMyList(myListUrl:String, myListName:String, isDir:Boolean, isSave:Boolean, oldName:String, children:Array = null):Object{
			
			var myList:MyList = new MyList(myListUrl, myListName, isDir);
			var object:Object = searchByName(oldName, this._tree_MyList);
			
			delete this._myListMap[oldName];
			
			var builder:TreeDataBuilder = new TreeDataBuilder();
			var folder:Object = builder.getFolderObject(myListName);
			
			object.label = myListName;
			if(children != null){
				object.children = children;
			}
			
			this._myListMap[myListName] = myList;
			
			return object;
		}
		
		/**
		 * 
		 * @param name
		 * @return 
		 * 
		 */
		public function search(name:String):Object{
			return searchByName(name, this._tree_MyList);
		}
		
		/**
		 * 
		 * @param myListName
		 * @return 
		 * 
		 */
		public function searchByName(myListName:String, array:Array):Object{
			for(var index:int = 0; index<array.length; index++){
				
				var object:Object = array[index];
				if(object.hasOwnProperty("children")){
					
					if(object.label == myListName){
						return object;
					}else{
						//フォルダのなかの項目かもしれない。探す。
						var tempObject:Object = searchByName(myListName, object.children);
						if(tempObject != null){
							return tempObject;
						}
					}
				}else{
					//ファイル
					if(object.label == myListName){
						return object;
					}
				}
				
			}
			return null;
		}
		
		
		/**
		 * マイリストを追加します。同名のマイリスト名は追加できません。
		 * 
		 * @param myListUrl
		 * @param myListName
		 * @param isDir
		 * @param isSave
		 * @param index
		 * @param children ディレクトリを追加した際に同時に追加する子。
		 * @return 
		 * 
		 */
		public function addMyList(myListUrl:String, myListName:String, isDir:Boolean, isSave:Boolean, index:int = -1, children:Array = null):Object{
			var exsits:Boolean = false;
			var myList:MyList = new MyList(myListUrl, myListName, isDir);
			var addedTreeObject:Object = null;
			
			if(this._myListMap[myListName] != null){
				exsits = true;
			}
			
			if(!exsits){
				
				var builder:TreeDataBuilder = new TreeDataBuilder();
				
				if(isDir){
					
					var folder:Object = builder.getFolderObject(myListName);
					if(children != null){
						folder.children = children;
					}
					
					if(index == -1){
						this._tree_MyList.push(folder);
						this._myListMap[myListName] = myList;
					}else{
						this._tree_MyList.splice(index, 0, folder);
						this._myListMap[myListName] = myList;
					}
					
					addedTreeObject = folder;
					
				}else{
					
					var file:Object = builder.getFileObject(myListName);
					
					if(index == -1){
						this._tree_MyList.push(file);
						this._myListMap[myListName] = myList;
					}else{
						this._tree_MyList.splice(index, 0, file);
						this._myListMap[myListName] = myList;
					}
					
					addedTreeObject = file;
					
				}
				
				if(isSave){
					this.saveMyListSummary(this._libraryManager.systemFileDir);
				}
				
				return addedTreeObject;
			}else{
				return null;
			}
			
		}
		
		
		/**
		 * 指定された名前のマイリストが存在するかどうかを返します。
		 * @param myListName
		 * @return 
		 * 
		 */
		public function isExsits(myListName:String):Boolean{
			
			var object:Object = this._myListMap[myListName];
			if(object != null){
				return true;
			}
			return false;
		}
		
		/**
		 * マイリストを削除します。
		 * 
		 * @param myListName
		 * @return 
		 * 
		 */
		public function removeMyList(myListName:String, isSave:Boolean):Object{
			var deletedObject:Object = deleteMyListItemFromTree(myListName, this._tree_MyList);
			if(deletedObject != null){
				if(isSave){
					this.saveMyListSummary(LibraryManager.getInstance().libraryDir);
				}
				delete this._myListMap[myListName];
				return deletedObject;
			}
			return null;
		}
		
		/**
		 * 指定されたTreeのデータプロバイダであるArrayからmyListNameを探して削除します。
		 * @param myListName
		 * @param myListArray
		 * @return 
		 * 
		 */
		public function deleteMyListItemFromTree(myListName:String, myListArray:Array):Object{
			for(var index:int = 0; index<myListArray.length; index++){
				
				var object:Object = myListArray[index];
				if(object.hasOwnProperty("children") && object.children != null ){
					
					if(object.label == myListName){
						//フォルダそのものを消す
						return myListArray.splice(index, 1)[0];
						
					}else{
						//フォルダのなかの項目かもしれない。探す。
						var deleteObject:Object = deleteMyListItemFromTree(myListName, object.children);
						if(deleteObject != null){
							return deleteObject;
						}
					}
				}else{
					//ファイル
					if(object.label == myListName){
						
						return myListArray.splice(index, 1)[0];
					}
				}
					
			}
			return null;
		}
		
		/**
		 * URLを返します。ただし、http://〜で始まるとは限りません。マイリストの番号である可能性もあります。
		 * @param myListName
		 * @return 
		 * 
		 */
		public function getUrl(myListName:String):String{
			var myList:MyList = MyList(this._myListMap[myListName]);
			if(myList == null || myList.isDir){
				return "";
			}
			return myList.myListUrl;
		}
		
		/**
		 * マイリストのタイトルを返します。
		 * @param index
		 * @return 
		 * 
		 */
		public function getMyListName(index:int):String{
			var object:Object = this._tree_MyList[index];
			if(object.hasOwnProperty("children")){
				return this._tree_MyList[index].label;
			}else{
				return this._tree_MyList[index];
			}
		}
		
		/**
		 * 
		 * @param myListName
		 * @return 
		 * 
		 */
		public function getMyListIdDir(myListName:String):Boolean{
			return MyList(this._myListMap[myListName]).isDir;
		}
		
		/**
		 * 
		 * @param xml
		 * @param myListArray
		 * @param myListMap
		 * 
		 */
		public function addMyListItemFromXML(xml:XML, myListArray:Array, myListMap:Object):void{
			
			for each(var temp:XML in xml.children()){
				
				var name:String = String(temp.@name);
				var myList:MyList = null;
				
				var builder:TreeDataBuilder = new TreeDataBuilder();
				
				if(temp.@isDir != null && temp.@isDir != undefined && temp.@isDir == "true"){
					//ディレクトリの時。
					
					var folder:Object = builder.getFolderObject(name);
					
					myList = new MyList("", name, true);
					myListArray.push(folder);
					myListMap[name] = myList;
					
					if(temp.children().length() > 0){
						addMyListItemFromXML(temp, folder.children, myListMap); 
					}
				}else{
					var url:String = String(temp.@url);
					if(url == null || url == ""){
						url = String(temp.text());
					}
					
					var file:Object = builder.getFileObject(name);
					
					myList = new MyList(url, name);
					myListArray.push(file);
					myListMap[name] = myList;
				}
			}
					
		}
		
		/**
		 * 
		 * @param dir
		 * 
		 */
		public function readMyListSummary(dir:File):Boolean{
			
			var saveFile:File = new File(dir.url + "/myLists.xml");
			
			if(saveFile.exists){
				
				var fileIO:FileIO = new FileIO(LogManager.getInstance());
				var xml:XML = fileIO.loadXMLSync(saveFile.url, true);
				
				addMyListItemFromXML(xml, _tree_MyList, _myListMap);
				
				_logManager.addLog("マイリスト一覧の読み込み完了:" + saveFile.nativePath);
				
				return true;
				
			}else{
				_logManager.addLog("マイリスト一覧が存在しません:" + saveFile.nativePath);
				
				return false;
			}
		}
		
		
		/**
		 * 渡されたXMLに渡されたマイリスト名順にマイリストを追加します。
		 * 
		 * @param xml
		 * @param myListNameArray
		 * @param myListMap
		 * @return 
		 * 
		 */
		public function addMyListItemToXML(xml:XML, myListNameArray:Array, myListMap:Object):XML{
			
			for(var i:int = 0; i<myListNameArray.length; i++){
				
				var myList:MyList = myListMap[myListNameArray[i].label];
				var myListItem:XML = <myList/>;
				
				if(myList != null){
					if(myList.isDir){
						
						//ディレクトリの時
						myList = myListMap[myListNameArray[i].label];
						
						myListItem.@url = "";
						myListItem.@name = myList.myListName;
						myListItem.@isDir = true;
						
						var array:Array = myListNameArray[i].children;
						if(array != null && array.length >= 1){
							myListItem = addMyListItemToXML(myListItem, array, myListMap);
						}
						
					}else{
						myListItem.@url = myList.myListUrl;
						myListItem.@name = myList.myListName;
						myListItem.@isDir = false;
					}
					
					
					xml.appendChild(myListItem);
				}
			}
			
			return xml;
		}
		
		
		/**
		 * 
		 * @param dir
		 * 
		 */
		public function saveMyListSummary(dir:File):void{
			
			var xml:XML = <myLists/>;
			xml = addMyListItemToXML(xml, this._tree_MyList, this._myListMap);
			
			var saveFile:File = new File(dir.url + "/myLists.xml");
			
			var fileIO:FileIO = new FileIO(_logManager);
			fileIO.addFileStreamEventListener(Event.COMPLETE, function(event:Event):void{
				_logManager.addLog("マイリスト一覧を保存:" + dir.nativePath);
				trace(event);
				dispatchEvent(event);
			});
			fileIO.addFileStreamEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
				_logManager.addLog("マイリストの保存に失敗:" + dir.nativePath + ":" + event);
				trace(event + ":" + dir.nativePath);
				dispatchEvent(event);
			});
			fileIO.saveXMLSync(saveFile, xml);
			
		}

	}
}