package org.mineap.NNDD.playListManager
{
	import org.mineap.NNDD.LibraryManager;
	import org.mineap.NNDD.LogManager;

	/**
	 * PlayListManager.as<br>
	 * PlayListManagerクラスは、プレイリストを管理するクラスです。<br>
	 * <br>
	 * Copyright (c) 2009 MAP MineApplicationProject. All Rights Reseved. 
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class PlayListManager
	{
		
		private var _libraryManager:LibraryManager;
		private var _playListProvider:Array;
		private var _playListMap:Object;
		private var _logManager:LogManager;
		
		
		/**
		 * コンストラクタ<br>
		 * 
		 * @param libraryManager
		 * @param list_playList
		 * @param logManager
		 * 
		 */
		public function PlayListManager(libraryManager:LibraryManager, playListProvider, logManager:LogManager)
		{
			this._logManager = logManager;
			this._libraryManager = libraryManager;
			this._playListMap = new Object();
			this._playListProvider = playListProvider;
		}
		
		/**
		 * プレイリストを追加します。同名のプレイリストは追加できません。
		 * @param playList
		 * @param isSave
		 * @param index
		 * @return 
		 * 
		 */
		public function addPlayList(playList:PlayList, isSave:Boolean, index:int = -1):Boolean{
			var exsits:Boolean = false;
			for each(var name:String in this._playListProvider){
				if(name == playList.name){
					exsits = true;
					break;
				}
			}
			
			if(!exsits){
				
				if(index != -1){
					this._playListProvider.push(searchItem.name);
				}else{
					this._playListProvider.splice(index, 0, playList);
				}
				
				this._playListMap[playList.name] = searchItem;
				
				if(isSave){
					this.savePlayLists(this._libraryManager.libraryDir);
				}
				
				return true;

			}else{
				return false;
			}
		}
		
		/**
		 * プレイリストを削除します。
		 * @param playListName
		 * @param isSave
		 * @return 
		 * 
		 */
		public function removePlayList(playListName:String, isSave:Boolean):Boolean{
				
			for(var index:int=0; index<this._playListProvider.length; index++){
				if(this._playListProvider[index] == playListName){
					this._playListProvider.splice(index, 1);
					this._playListMap[playListName] = null;
					
					if(isSave){
						this.savePlayLists(this._libraryManager.libraryDir);
					}
					
					return true;
				}
			}
			return false;
		}
		
		/**
		 * 
		 * @param index
		 * @return 
		 * 
		 */
		public function getPlayListName(index:int):String{
			return this._playListProvider[index];
		}
		
		/**
		 * 
		 * @param playListName
		 * @return 
		 * 
		 */
		public function getPlayList(playListName:String):PlayList{
			return this._playListMap[playListName];
		}
		
		
		
	}
}