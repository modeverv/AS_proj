package org.mineap.NNDD.model
{
	import org.mineap.NNDD.util.PathMaker;

	/**
	 * NNDDVideo.as<br>
	 * NNDDVideoクラスは、NNDDが管理するビデオについての情報を格納するクラスです。<br>
	 * <br>
	 * Copyright (c) 2009 MAP - MineApplicationProject. All Rights Reserved.
	 *  
	 * @author shiraminekeisuke
	 * 
	 */	
	public class NNDDVideo
	{
		
		/** ビデオの場所を示すURIです。 */
		private var _uri:String = "";
		
		/** ビデオの名前です。 */
		public var videoName:String = "";
		
		/** このビデオがエコノミーモードで保存されたかどうかを表します。 */
		public var isEconomy:Boolean = false;
		
		/** このビデオに設定されたタグです。 */
		public var tagStrings:Vector.<String> = new Vector.<String>();
		
		/** このビデオが最後に更新された日時です。これはコメントの更新等で変更されます。 */
		public var modificationDate:Date = new Date();
		
		/** このビデオがダウンロードされた日です。 */
		public var creationDate:Date = new Date();
		
		/** このビデオのローカルのサムネイル画像のURLです */
		public var thumbUrl:String = "";
		
		/** このビデオのトータル再生回数です */
		public var playCount:Number = 0;
		
		/** このビデオの長さ（秒）です。 */
		public var time:Number = 0;
		
		/** このビデオが最後に再生された日時です。この値はnullである可能性があります。 */
		public var lastPlayDate:Date = null;
		
		/**
		 * 
		 * コンストラクタ
		 * 
		 * @param uri 
		 * @param videoName
		 * @param isEconomy
		 * @param tags
		 * @param modificationDate
		 * @param creationDate
		 * @param thumbUrl
		 * @param playCount
		 * @param time
		 * @param lastPlayDate
		 * 
		 */
		public function NNDDVideo(uri:String , videoName:String = null, isEconomy:Boolean = false, tags:Vector.<String> = null,
				 modificationDate:Date = null, creationDate:Date = null, thumbUrl:String = null, playCount:Number = 0, time:Number = 0,
				 lastPlayDate:Date = null)
		{
			if(uri.indexOf("%") == -1){
				this._uri = encodeURI(uri);
			}else{
				this._uri = uri;
			}
			if(videoName == null){
				this.videoName = decodeURIComponent(PathMaker.getVideoName(this._uri));
			}else{
				this.videoName = videoName;
			}
			this.isEconomy = isEconomy;
			if(tags != null){
				this.tagStrings = tags;
			}
			if(modificationDate != null){
				this.modificationDate = modificationDate;
			}
			if(creationDate != null){
				this.creationDate = creationDate;
			}
			if(thumbUrl != null){
				this.thumbUrl = thumbUrl;
			}
			if(playCount != 0){
				this.playCount = playCount;
			}
			if(time != 0){
				this.time = time;
			}
			if(lastPlayDate != null){
				this.lastPlayDate = lastPlayDate;
			}
		}
		
		/**
		 * 
		 * @param uri
		 * 
		 */
		public function set uri(uri:String):void{
			
			this._uri = uri;
			this.videoName = decodeURIComponent(PathMaker.getVideoName(uri));
			
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get uri():String{
			return this._uri;
		}
		
		/**
		 * デコードされたURLを返します。
		 * @return 
		 * 
		 */
		public function getDecodeUrl():String{
			var url:String = decodeURIComponent(this._uri);
			return url;
		}
		
		/**
		 * 動画IDを含む動画のタイトルを返します。
		 * @return 
		 * 
		 */
		public function getVideoNameWithVideoID():String{
			var videoTitle:String = this.videoName;
			
			var index:int = videoTitle.lastIndexOf(".");
			if(index != -1 && index > videoTitle.length - 4 ){
				videoTitle = videoTitle.substr(0, index);
			}
			
			var videoId:String = PathMaker.getVideoID(this.getDecodeUrl());
			if(videoId != null){
				if(videoTitle.indexOf(videoId) == -1){
					videoTitle = videoTitle + " - [" + videoId + "]";
				}
			}
			return videoTitle;
		}
		
	}
}