package org.mineap.NNDD
{
		
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	import org.mineap.NNDD.model.NNDDVideo;
	import org.mineap.NNDD.util.DateUtil;
	import org.mineap.NNDD.util.PathMaker;

	/**
	 * FileIO.as
	 * 主にNNDDに特化した、ローカルのファイルへのアクセスを提供します。
	 * 
	 * Copyright (c) 2008 MAP - MineApplicationProject. All Rights Reserved.
	 *  
	 * @author shiraminekeisuke
	 * 
	 */	
	public class FileIO extends EventDispatcher
	{
		private var fileStream:FileStream;
		private var file:File;
		private var commentLoader:URLLoader;
		private var playListLoader:URLLoader;
		private var logManager:LogManager;
		
		public static const LIBRARY_LOAD_FAIL:String = "LibraryLoadFail";
		public static const LIBRARY_LOAD_SUCCESS:String = "LibraryLoadSuccess";
		public static const LIBRARY_LOAD_SUCCESS_WITH_VUP:String = "LibraryLoadSuccessWithVup";
		
		
		/**
		 * コンストラクタ<br>
		 * 
		 */
		public function FileIO(logManager:LogManager = null)
		{
			fileStream = new FileStream();
			commentLoader = new URLLoader();
			playListLoader = new URLLoader();
			this.logManager = logManager;
		}
		
		/**
		 * 指定されたURLLoaderのdataを、指定されたファイル名でディスクに書き出します。<br>
		 * このメソッドはdataをバイナリデータとして書き出します。ムービーを書き出すために使用してください。<br>
		 * @param loader URLLoader
		 * @param fileName 保存したいファイル名
		 * @param path 保存先のディレクトリまでの絶対パス。<br>
		 *             最後は/で終わっている必要があります。
		 * @return 保存したビデオのフルパスを返します。このフルパスは禁則文字を置き換え済です。
		 */
		public function saveVideoByURLLoader(loader:URLLoader, fileName:String, path:String):File
		{
			
				
			fileName = getSafeFileName(fileName);
			
			if(path.charAt(path.length) != "/"){
				path += "/";
			}
			
			file = new File(path + fileName);
			
			if(file.exists){
				file.moveToTrash();
			}
			
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeBytes(loader.data);
			fileStream.close();
			
			return file;
			
		}
		
		/**
		 * 禁則文字を全角文字に置換した文字列を返します。
		 * @param fileName
		 * @return 
		 * 
		 */
		public static function getSafeFileName(fileName:String):String{
			
			//禁則文字　/ : ? \ * " % < > | # ;
			
			while(fileName.indexOf("/") != -1){
				fileName = fileName.replace(new RegExp("/"), "／");
			}
			while(fileName.indexOf(":") != -1){
				fileName = fileName.replace(new RegExp(":"), "：");
			}
			while(fileName.indexOf("?") != -1){
				fileName = fileName.replace(new RegExp("\\?"), "？");
			}
			while(fileName.indexOf("\\") != -1){
				fileName = fileName.replace(new RegExp("\\\\"), "＼");
			}
			while(fileName.indexOf("*") != -1){
				fileName = fileName.replace(new RegExp("\\*"), "＊");
			}
			while(fileName.indexOf("\"") != -1){
				fileName = fileName.replace(new RegExp("\""), "”");
			}
			while(fileName.indexOf("%") != -1){
				fileName = fileName.replace(new RegExp("%"), "％");
			}
			while(fileName.indexOf("<") != -1){
				fileName = fileName.replace(new RegExp("<"), "＜");
			}
			while(fileName.indexOf(">") != -1){
				fileName = fileName.replace(new RegExp(">"), "＞");
			}
			while(fileName.indexOf("|") != -1){
				fileName = fileName.replace(new RegExp("\\|"), "｜");
			}
			while(fileName.indexOf("#") != -1){
				fileName = fileName.replace(new RegExp("#"), "＃");
			}
			while(fileName.indexOf(";") != -1){
				fileName = fileName.replace(new RegExp(";"), "；");
			}
			
			return fileName;
		}
		
		/**
		 * 指定された文字列を、指定されたファイル名でディスクに書き出します。<br>
		 * このメソッドはdataをUTFの文字列として書き出します。<br>
		 * @param data String
		 * @param fileName 保存したいファイル名
		 * @param path 保存先のディレクトリまでの絶対パス。<br>
		 *             最後は/で終わっている必要があります。
		 * @param isReNameOldFile 古いファイルがあった場合、そのファイルをリネームして保存するかどうかです。
		 */
		public function saveComment(data:String, fileName:String, path:String, isReNameOldFile:Boolean):File
		{
			fileName = getSafeFileName(fileName);
			
			if(path.charAt(path.length) != "/"){
				path += "/";
			}
			
			file = new File(path + fileName);
			
			if(file.exists && isReNameOldFile){
				var extension:String = fileName.substring(fileName.lastIndexOf("."));
				var date:Date = file.modificationDate;
				var dateString:String = DateUtil.getDateStringForFileName(date);
				file.moveTo(new File(file.nativePath.substr(0, -4) + " (" + dateString + ")" + extension), true);
			}
			
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeUTFBytes(data);
			fileStream.close();
			
			return file;
		}
		
		/**
		 * filePathで指定されたファイルのロードを行います。<br>
		 * 読み込んだ結果はイベントリスナーを登録してチェックする必要があります。
		 * @param filePath
		 * 
		 */
		public function loadComment(filePath:String):Boolean
		{
			try{
			file = new File(filePath);
			
			if(!file.exists){
				return false;
			}
			
			commentLoader.load(new URLRequest(file.url));
			}catch(error:Error){
				return false;
			}
			return true;
		}
		
		
		/**
		 * filePathで指定されたファイルをXMLとしてロードし、指定されたArrayにライブラリの項目一覧として追加します。<br>
		 * @param filePath
		 * @param libraryArray
		 * 
		 */
		public function loadLibraryItem(filePath:String, libraryMap:Object):void{
			file = new File(filePath);
			
			if(!file.exists){
				return;
			}
			
			commentLoader.addEventListener(Event.COMPLETE, function(event:Event):void{
				XML.ignoreWhitespace = true;
				var libraryXML:XML = new XML(commentLoader.data);
				var libraryItemList:XMLList = libraryXML.children();
				var isOldLibrary:Boolean = false;
				for each(var item:XML in libraryItemList){
					if(item != null){
						var video:NNDDVideo;
						//エコノミーモードかどうかを取得
						if((item as XML).@isEconomy != undefined && (item as XML).@isEconomy == "true"){
							video = new NNDDVideo(item.text(), null, true);
						}else{
							video = new NNDDVideo(item.text(), null, false);
						}
						//タグを取得
						if((item as XML).tags != null){
							try{
								var tags:XMLList = item.children()[1].children();
								for(var i:int=0; i<tags.length(); i++){
									var tag:String = (tags[i] as XML).text();
									if(tag.indexOf("&") != -1){
										tag = PathMaker.getSpecialCharacterNotIncludedVideoName(tag);
									}
									video.tagStrings.push(tag);
								}
							}catch(error:Error){
								trace(error);
								trace(item);
								isOldLibrary = true;
							}
						}
						//作成日時取得
						if((item as XML).@creationDate != undefined && (item as XML).@creationDate != ""){
							video.creationDate = new Date(Number(item.@creationDate));
						}else{
							video.creationDate = null
						}
						//編集日時取得
						if((item as XML).@modificationDate != undefined && (item as XML).@modificationDate != ""){
							video.modificationDate = new Date(Number(item.@modificationDate));
						}else{
							video.modificationDate = null;
						}
						//サムネイル画像のURLを取得
						if((item as XML).@thumbImgUrl != undefined && (item as XML).@thumbImgUrl != ""){
							video.thumbUrl = item.@thumbImgUrl;
						}else{
							video.thumbUrl = "";
						}
						//再生回数を取得
						if((item as XML).@playCount != undefined && (item as XML).@playCount != ""){
							video.playCount = Number(item.@playCount);
						}else{
							video.playCount = 0;
						}
						//最終再生時刻を取得
						if((item as XML).@lastPlayDate != undefined && (item as XML).@lastPlayDate != ""){
							video.lastPlayDate = new Date(Number(item.@lastPlayDate));
						}else{
							video.lastPlayDate = null;
						}
						
						var videoId:String = PathMaker.getVideoID(video.getDecodeUrl());
						libraryMap[videoId] = video;
					}
				}
				if(logManager != null){
					if(isOldLibrary){
						logManager.addLog("ライブラリの形式が古かったため変換しました。");
					}
				}
				commentLoader.close();
				libraryXML = null;
				libraryItemList = null;
				
				if(isOldLibrary){
					dispatchEvent(new Event(LIBRARY_LOAD_SUCCESS_WITH_VUP));
				}else{
					dispatchEvent(new Event(LIBRARY_LOAD_SUCCESS));
				}
			});
			
			commentLoader.load(new URLRequest(file.url));
		}
		
		/**
		 * filePathで指定されたファイルをXMLとしてロードし、指定されたプロバイダにNGコメントおよびNGIDとして追加します。<br>
		 * @param filePath
		 */
		public function loadNgList(filePath:String):void
		{
			file = new File(filePath);
			
			if(!file.exists){
				return;
			}
			
			commentLoader.load(new URLRequest(file.url));
			
		}
		
		
		/**
		 * filePathで指定されたファイルをXMLとして開き、指定されたcommentを追加します。
		 * @param filePath
		 * @param comment
		 * @return 
		 * 
		 */
		public function addComment(filePath:String, comment:XML):void{
			file = new File(filePath);
			if(!file.exists){
				return;
			}
			try{	
				
				var commentXML:XML = this.loadXMLSync(file.nativePath, true);
				commentXML.appendChild(comment);
				
				this.saveXMLSync(file, commentXML);		
				logManager.addLog("投稿したコメントをローカルに保存:" + decodeURIComponent(file.url));
				
			}catch(error:Error){
				logManager.addLog("投稿したコメントをローカルに保存できませんでした。:" + file.nativePath + ":" + error);
				Alert.show("投稿したコメントをローカルのコメントXMLに保存できませんでした。"+ error, Message.M_ERROR);
			}
			
		}
		
		/**
		 * 同期的にローカルのXMLファイルを開き、XMLオブジェクトにして返します。
		 * @param localFilePath
		 * @param isIgnoreWhilteSpace 空白ノードを無視するかどうか。
		 * @return 
		 * 
		 */
		public function loadXMLSync(localFilePath:String, isIgnoreWhilteSpace:Boolean):XML{
			file = new File(localFilePath);
			XML.ignoreWhitespace = isIgnoreWhilteSpace;
			
			var xml:XML;
			
			if(file.exists){
				
				fileStream.open(file, FileMode.READ);
				var string:String = fileStream.readUTFBytes(file.size);
				try{
					xml = new XML(string);
				}catch(error:Error){
					xml = null;
				}
				
				fileStream.close();
				
			}
			
			return xml;
				
		}
		
		/**
		 * 渡されたXMLを指定されたFileとして保存します。
		 * @param file
		 * @param xml
		 * 
		 */
		public function saveXMLSync(file:File, xml:XML):void{
			try{
				if(file.exists){
					var newFile:File = new File(file.nativePath + ".back");
					file.copyTo(newFile, true);
					file.deleteFile();
				}
			}catch(error:Error){
				logManager.addLog("一時ファイルの作成に失敗:" + error);
				trace(error.getStackTrace());
			}
			
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeUTFBytes(xml);
			fileStream.close();
			
		}
		
		
		/**
		 * filePathで指定されたファイルにlibraryの要素をXMLとして保存し、セーブします。<br>
		 * この操作は同期されます。
		 * @param filePath
		 * @param libraryMap
		 * 
		 */
		public function saveLibrary(filePath:String, videoMap:Object):void
		{
			file = new File(filePath);
			XML.ignoreWhitespace = true;
			
			if(file.exists){
				file.moveTo(new File(filePath + ".back"), true);
			}
			
			var libraryXML:XML = <libraryItem/>;
			var index:int = 0;
			for each(var video:NNDDVideo in videoMap){
				libraryXML.item[index] = video.getDecodeUrl();
				(libraryXML.item[index] as XML).@isEconomy = video.isEconomy;
				(libraryXML.item[index] as XML).@modificationDate = (video.modificationDate as Date).time;
				(libraryXML.item[index] as XML).@creationDate = (video.creationDate as Date).time;
				(libraryXML.item[index] as XML).@thumbImgUrl = video.thumbUrl;
				(libraryXML.item[index] as XML).@playCount = video.playCount;
				var lastPlayDate:Date = (video.lastPlayDate as Date);
				if(lastPlayDate != null){
					(libraryXML.item[index] as XML).@lastPlayDate = lastPlayDate.time;
				}
				
				libraryXML.item[index].tags = <tags/>;
				for(var i:int = 0; i<video.tagStrings.length; i++){
					var tagString:String = video.tagStrings[i];
					var tagXML:XML = <tag/>;
					tagXML.setChildren(video.tagStrings[i]);
					libraryXML.item[index].tags.tag[i] = tagXML;
				}
				index++;
			}
			
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeUTFBytes(libraryXML);
			fileStream.close();
			
			if(logManager != null){
				logManager.addLog("ライブラリの保存完了:"+decodeURIComponent(file.url));
			}
		}
		
		
		/**
		 * filePathで指定されたファイル名でプレイリストを作成し、保存します。<br>
		 * @param filePath
		 * @param playList
		 * 
		 */
		public function savePlayList(filePath:String, playList:Array):void{
			file = new File(filePath);
			XML.ignoreWhitespace = true;
			
			var buffer:String = "";
			for(var i:int=0; i<playList.length; i++){
				var video:NNDDVideo = playList[i];
				buffer = buffer + video.getDecodeUrl() + "\n" + "#EXTINF:" + video.time + "," + video.getVideoNameWithVideoID() + "\n";
			}
			
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeUTFBytes(buffer);
			fileStream.close();
			if(logManager != null){
				logManager.addLog("プレイリストの保存完了:"+decodeURIComponent(file.url));
			}
		}
		
		/**
		 * 指定されたバイト列を指定されたファイルパスに書き出します。
		 * 
		 * @param filePath
		 * @param bytes
		 * @return 保存したサムネイル画像を表すFileオブジェクトです。
		 */
		public function saveByteArray(fileName:String, path:String, bytes:ByteArray):File{
			
			fileName = getSafeFileName(fileName);
			
			if(path.charAt(path.length) != "/"){
				path += "/";
			}
			
			file = new File(path + fileName);
			
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeBytes(bytes, 0, bytes.length);
			fileStream.close();
			if(logManager != null){
				logManager.addLog("サムネイル画像の保存完了:" + decodeURIComponent(file.url));
			}
			
			return file;
			
		}
		
		
		/**
		 * Fileにリスナーを追加します。<br>
		 * FileI/Oの完了などの通知を得たい場合はリスナーを追加してください。
		 * @param eventType
		 * @param handler
		 * 
		 */
		public function addFileEventListener(eventType:String, handler:Function):void
		{
			file.addEventListener(eventType,handler); 
		}
		
		/**
		 * FileStreamにリスナーを追加します。<br>
		 * FileI/Oの完了などの通知を得たい場合はリスナーを追加してください。
		 * @param eventType
		 * @param handler
		 * 
		 */
		public function addFileStreamEventListener(eventType:String, handler:Function):void
		{
			fileStream.addEventListener(eventType,handler);
		}
		
		/**
		 * URLLoaderにリスナーを追加します<br>
		 * URLLoaderのロード完了などの通知を得たい場合はリスナーを追加してください。
		 * @param eventType
		 * @param handler
		 * 
		 */
		public function addURLLoaderEventListener(eventType:String, handler:Function):void
		{
			commentLoader.addEventListener(eventType,handler);
		}
		
		/**
		 * 開かれているファイルストリームを閉じます。
		 */
		public function closeFileStream():void{
			try{
				this.fileStream.close();
			}catch(error:Error){
				
			}
		}
		
		/**
		 * 指定されたfilePathのファイルにoutで指定された文字列を書き出します。
		 * @param out
		 * @param filePath
		 * 
		 */
		public function addLog(out:String, filePath:String):void{
			try{
			var file:File;
			file = new File(filePath);
			
			fileStream.open(file, FileMode.APPEND);
			fileStream.writeUTFBytes(out);
			fileStream.close();
			}catch (error:Error){
				Alert.show("ログの出力に失敗しました\n" + error);
			}
		}
		
	}
}