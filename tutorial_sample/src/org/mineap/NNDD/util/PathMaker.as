package org.mineap.NNDD.util
{
	import flash.filesystem.File;
	
	
	/**
	 * PathMaker.as
	 * Pathの生成を行います。
	 * 
	 * Copyright (c) 2008-2009 MAP - MineApplicationProject. All Rights Reserved.
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class PathMaker
	{
		
		public static const VIDEO_ID_SEARCH_PATTERN_STRING:String = "([A-LN-Za-ln-z0-9][A-Za-z0-9])\\d+";
		
		/**
		 * コンストラクタ
		 * 
		 */
		public function PathMaker()
		{
			/* 何もしない */
		}
		
		/**
		 * 渡されたムービーのパスから通常コメント用のxmlファイルのパスを生成し、返します。
		 * 
		 * 注意：返されたパスが存在するとは限りません。
		 * 
		 * @param videoPath
		 * @return 
		 * 
		 */
		public static function createNomalCommentPathByVideoPath(videoPath:String):String{
			
			var defFilePath:String = videoPath.substring(0,videoPath.lastIndexOf(".")) + ".xml";
			
			try{
				
				try{
					//従来通りの方法で作ったファイルがあるならそれを返す
					if((new File(defFilePath)).exists){
						return defFilePath;
					}
				}catch(error:Error){
					trace(error);
				}
				
				var rootDir:File = new File(videoPath.substring(0, videoPath.lastIndexOf("/")));
				if(!rootDir.exists){
					//そんなディレクトリ存在しない。とりあえず従来の方法で生成したコメントのパスを返す。
					return videoPath.substring(0,videoPath.lastIndexOf(".")) + ".xml";
				}
				
				//videoPathからVideoIDを抽出
				var videoID:String = getVideoID(videoPath);
				if(videoID == null){
					//ビデオIDがついてないので従来の方法で生成したコメントパスを返す。
					return videoPath.substring(0,videoPath.lastIndexOf(".")) + ".xml";
				}
				
				//指定されたファイルがあるディレクトリから対応するコメントファイルを探す
				var fileArray:Array = rootDir.getDirectoryListing();
				var pattern:RegExp = new RegExp(".*[^(Owner)&^(ThumbInfo)]\\.xml");
				for each(var tempFile:File in fileArray){
					var tempPath:String = decodeURIComponent(tempFile.url).substring(decodeURIComponent(tempFile.url).lastIndexOf("/")+1);
					var array:Array = tempPath.match(pattern);
					if(array != null && array.length >= 1){
						if((array[array.length-1] as String).indexOf(videoID) != -1){
							return decodeURIComponent(tempFile.url);
						}
					}
				}
			}catch(error:Error){
				trace(error);
			}
			
			//見つからなかったら従来の方法で生成したコメントパスを返す。
			return defFilePath;
		}
		
		/**
		 * 渡されたムービーのパスから投稿者コメント用のxmlファイルのパスを生成し、返します。
		 * 
		 * 注意：返されたパスが存在するとは限りません。
		 * 
		 * @param videoPath
		 * @return 
		 * 
		 */
		public static function createOwnerCommentPathByVideoPath(videoPath:String):String{
			
			var defFilePath:String = videoPath.substring(0,videoPath.lastIndexOf(".")) + "[Owner].xml";
			
			try{
				
				try{
					//従来通りの方法で作ったファイルがあるならそれを返す
					if((new File(defFilePath)).exists){
						return defFilePath;
					}
				}catch(error:Error){
					trace(error);
				}
				
				var rootDir:File = new File(videoPath.substring(0, videoPath.lastIndexOf("/")));
				if(!rootDir.exists){
					//そんなディレクトリ存在しない。とりあえず従来の方法で生成したコメントのパスを返す。
					return videoPath.substring(0,videoPath.lastIndexOf(".")) + "[Owner].xml";
				}
				
				//videoPathからVideoIDを抽出
				var videoID:String = getVideoID(videoPath);
				if(videoID == null){
					//ビデオIDがついてないので従来の方法で生成したコメントパスを返す。
					return videoPath.substring(0,videoPath.lastIndexOf(".")) + "[Owner].xml";
				}
				
				//指定されたファイルがあるディレクトリから対応するコメントファイルを探す
				var fileArray:Array = rootDir.getDirectoryListing();
				var pattern:RegExp = new RegExp(".*\\[Owner]\\.xml");
				for each(var tempFile:File in fileArray){
					var tempPath:String = decodeURIComponent(tempFile.url).substring(decodeURIComponent(tempFile.url).lastIndexOf("/"));
					var array:Array = tempPath.match(pattern);
					if(array != null && array.length >= 1){
						if((array[array.length-1] as String).indexOf(videoID) != -1){
							return decodeURIComponent(tempFile.url);
						}
					}
				}
			}catch(error:Error){
				trace(error);
			}
			
			//見つからなかったら従来の方法で生成したコメントパスを返す。
			return defFilePath;
		}
		
		/**
		 * 渡されたムービーのパスからサムネイル情報用のxmlファイルのパスを生成し、返します。
		 * 
		 * 注意：返されたパスが存在するとは限りません。
		 * 
		 * @param videoPath
		 * @return 
		 * 
		 */
		public static function createThmbInfoPathByVideoPath(videoPath:String):String{
			
			var defFilePath:String = videoPath.substring(0,videoPath.lastIndexOf(".")) + "[ThumbInfo].xml";
			
			try{
				
				try{
					//従来通りの方法で作ったファイルがあるならそれを返す
					if((new File(defFilePath)).exists){
						return defFilePath;
					}
				}catch(error:Error){
					trace(error);
				}
				
				var rootDir:File = new File(videoPath.substring(0, videoPath.lastIndexOf("/")));
				if(!rootDir.exists){
					//そんなディレクトリ存在しない。とりあえず従来の方法で生成したコメントのパスを返す。
					return videoPath.substring(0,videoPath.lastIndexOf(".")) + "[ThumbInfo].xml";
				}
				
				//videoPathからVideoIDを抽出
				var videoID:String = getVideoID(videoPath);
				if(videoID == null){
					//ビデオIDがついてないので従来の方法で生成したコメントパスを返す。
					return videoPath.substring(0,videoPath.lastIndexOf(".")) + "[ThumbInfo].xml";
				}
				
				//指定されたファイルがあるディレクトリから対応するコメントファイルを探す
				var fileArray:Array = rootDir.getDirectoryListing();
				var pattern:RegExp = new RegExp(".*\\[ThumbInfo]\\.xml");
				for each(var tempFile:File in fileArray){
					var tempPath:String = decodeURIComponent(tempFile.url).substring(decodeURIComponent(tempFile.url).lastIndexOf("/"));
					var array:Array = tempPath.match(pattern);
					if(array != null && array.length >= 1){
						if((array[array.length-1] as String).indexOf(videoID) != -1){
							return decodeURIComponent(tempFile.url);
						}
					}
				}
			
			}catch(error:Error){
				trace(error);
			}
			
			//見つからなかったら従来の方法で生成したコメントパスを返す。
			return defFilePath;
		}
		
		/**
		 * 渡されたムービーのパスから市場情報用のhtmlファイルのパスを生成し、返します。
		 * 
		 * 注意：返されたパスが存在するとは限りません。
		 * 
		 * @param videoPath
		 * @return 
		 * 
		 */
		public static function createNicoIchibaInfoPathByVideoPath(videoPath:String):String{
			
			var defFilePath:String = videoPath.substring(0,videoPath.lastIndexOf(".")) + "[IchibaInfo].html";
			
			try{
				
				try{
					//従来通りの方法で作ったファイルがあるならそれを返す
					if((new File(defFilePath)).exists){
						return defFilePath;
					}
				}catch(error:Error){
					trace(error);
				}
				
				var rootDir:File = new File(videoPath.substring(0, videoPath.lastIndexOf("/")));
				if(!rootDir.exists){
					//そんなディレクトリ存在しない。とりあえず従来の方法で生成したコメントのパスを返す。
					return videoPath.substring(0,videoPath.lastIndexOf(".")) + "[IchibaInfo].html";
				}
				
				//videoPathからVideoIDを抽出
				var videoID:String = getVideoID(videoPath);
				if(videoID == null){
					//ビデオIDがついてないので従来の方法で生成したコメントパスを返す。
					return videoPath.substring(0,videoPath.lastIndexOf(".")) + "[IchibaInfo].html";
				}
				
				//指定されたファイルがあるディレクトリから対応するコメントファイルを探す
				var fileArray:Array = rootDir.getDirectoryListing();
				var pattern:RegExp = new RegExp(".*\\[IchibaInfo]\\.html");
				for each(var tempFile:File in fileArray){
					var tempPath:String = decodeURIComponent(tempFile.url).substring(decodeURIComponent(tempFile.url).lastIndexOf("/"));
					var array:Array = tempPath.match(pattern);
					if(array != null && array.length >= 1){
						if((array[array.length-1] as String).indexOf(videoID) != -1){
							return decodeURIComponent(tempFile.url);
						}
					}
				}
			}catch(error:Error){
				trace(error);
			}
			//見つからなかったら従来の方法で生成したコメントパスを返す。
			return defFilePath;
		}
		
		/**
		 * 渡されたムービーのパスとニコ割ビデオのIDからニコ割ビデオのパスを生成し、返します。
		 * nicowariVideoIDが設定されていない場合は、最初に発見したvideoPathに対応するニコ割を返します。
		 * 
		 * 注意：返されたパスが存在するとは限りません。
		 * 
		 * @param videoPath
		 * @param nicowariVideoID
		 * @return 
		 * 
		 */
		public static function createNicowariPathByVideoPathAndNicowariVideoID(videoPath:String, nicowariVideoID:String = "nm\\d+"):String{
			
			var defFilePath:String = videoPath.substring(0,videoPath.lastIndexOf(".")) + "[Nicowari][" + nicowariVideoID + "].swf";
			
			try{
				
				try{
					//従来通りの方法で作ったファイルがあるならそれを返す
					if((new File(defFilePath)).exists){
						return defFilePath;
					}
				}catch(error:Error){
					trace(error);
				}
			
				var rootDir:File = new File(videoPath.substring(0, videoPath.lastIndexOf("/")));
				if(!rootDir.exists){
					//そんなディレクトリ存在しない。とりあえず従来の方法で生成したコメントのパスを返す。
					return videoPath.substring(0,videoPath.lastIndexOf(".")) + "[Nicowari][" + nicowariVideoID + "].swf";
				}
				
				//videoPathからVideoIDを抽出
				var videoID:String = getVideoID(videoPath);
				if(videoID == null){
					//ビデオIDがついてないので従来の方法で生成したコメントパスを返す。
					return videoPath.substring(0,videoPath.lastIndexOf(".")) + "[Nicowari][" + nicowariVideoID + "].swf";
				}
				
				//指定されたファイルがあるディレクトリから対応するコメントファイルを探す
				var fileArray:Array = rootDir.getDirectoryListing();
				var pattern:RegExp = new RegExp(".*\\[Nicowari]\\[" + nicowariVideoID + "]\\.swf");
				for each(var tempFile:File in fileArray){
					var tempPath:String = decodeURIComponent(tempFile.url).substring(decodeURIComponent(tempFile.url).lastIndexOf("/"));
					var array:Array = tempPath.match(pattern);
					if(array != null && array.length >= 1){
						if((array[array.length-1] as String).indexOf(videoID) != -1){
							return decodeURIComponent(tempFile.url);
						}
					}
				}
			}catch(error:Error){
				trace(error);
			}
			//見つからなかったら従来の方法で生成したコメントパスを返す。
			return defFilePath;
			
		}
		
		/**
		 * 渡されたムービーのパスからサムネイル画像(JPEGファイル)のパスを生成し、返します。
		 * 
		 * 注意：返されたパスが存在するとは限りません。
		 * 
		 * @param videoPath
		 * @param isGetDefPath 従来通りの方法で生成したファイルパスを返します。これがtrueの場合、ほとんどの場合において高速です。
		 * @return 
		 * 
		 */
		public static function createThumbImgFilePath(videoPath:String, isGetDefPath:Boolean = false):String{
			
			var defFilePath:String = videoPath.substring(0,videoPath.lastIndexOf(".")) + "[ThumbImg].jpeg";
			
			try{
				
				try{
					//従来通りの方法で作ったファイルがあるならそれを返す
					if(isGetDefPath || (new File(defFilePath)).exists){
						return defFilePath;
					}
				}catch(error:Error){
					trace(error);
				}
				
				var rootDir:File = new File(videoPath.substring(0, videoPath.lastIndexOf("/")));
				if(!rootDir.exists){
					//そんなディレクトリ存在しない。とりあえず従来の方法で生成したコメントのパスを返す。
					return videoPath.substring(0,videoPath.lastIndexOf(".")) + "[ThumbImg].jpeg";
				}
				
				//videoPathからVideoIDを抽出
				var videoID:String = getVideoID(videoPath);
				if(videoID == null){
					//ビデオIDがついてないので従来の方法で生成したコメントパスを返す。
					return videoPath.substring(0,videoPath.lastIndexOf(".")) + "[ThumbImg].jpeg";
				}
				
				//指定されたファイルがあるディレクトリから対応するコメントファイルを探す
				var fileArray:Array = rootDir.getDirectoryListing();
				var pattern:RegExp = new RegExp(".*\\[ThumbImg]\\.jpeg");
				for each(var tempFile:File in fileArray){
					var tempPath:String = decodeURIComponent(tempFile.url).substring(decodeURIComponent(tempFile.url).lastIndexOf("/"));
					var array:Array = tempPath.match(pattern);
					if(array != null && array.length >= 1){
						if((array[array.length-1] as String).indexOf(videoID) != -1){
							return decodeURIComponent(tempFile.url);
						}
					}
				}
			
			}catch(error:Error){
				trace(error);
			}
			
			//見つからなかったら従来の方法で生成したコメントパスを返す。
			return defFilePath;
			
		}
		
		
		/**
		 * 引数で指定されたVideoPathから動画のタイトルを取得します。
		 * VideoPathはURLで指定します。
		 * 
		 * @param videoPath
		 * @return 
		 * 
		 */
		public static function getVideoName(videoPath:String):String{
			videoPath = decodeURIComponent(videoPath);
			var videoName:String = "";
			var lastIndex:int = videoPath.lastIndexOf("- [");
			if(lastIndex != -1){
				videoName = videoPath.substring(videoPath.lastIndexOf("/")+1, lastIndex-1);
			}else{
				lastIndex = videoPath.lastIndexOf(".");
				videoName = videoPath.substring(videoPath.lastIndexOf("/")+1, lastIndex);
			}
			return videoName;
		}
		
		/**
		 * 引数で指定されたvideoPathからファイル名を取得し、返します。ファイル名にはビデオIDが含まれます。
		 * 
		 * @param videoPath
		 * @return 
		 * 
		 */
		public static function getVideoNameWithVideoID(videoPath:String):String{
			videoPath = decodeURIComponent(videoPath);
			var fileName:String = videoPath.substring(videoPath.lastIndexOf("/")+1);
			
			return fileName;
		}
		
		/**
		 * 渡された動画のタイトルからビデオIDを抽出します。
		 * @param videoTitle
		 * @return ビデオID。存在しない場合はnull。
		 * 
		 */
		public static function getVideoID(videoTitle:String):String{
			//videoPathからVideoIDを抽出
			var pattern:RegExp = new RegExp(VIDEO_ID_SEARCH_PATTERN_STRING, "ig");
			var index:int = videoTitle.lastIndexOf("/");
			var array:Array = null;
			if(index != -1){
				array = videoTitle.substring(videoTitle.lastIndexOf("/")).match(pattern);
			}else{
				array = videoTitle.match(pattern);
			}
			if(array.length >= 1){
				var videoID:String = array[array.length-1];
				return videoID;
			}else{
				return null;
			}
		}
		
		/**
		 * HTML特殊文字を使用していないビデオのタイトルを返します。
		 * @param videoName
		 * @return 
		 * 
		 */
		public static function getSpecialCharacterNotIncludedVideoName(videoName:String):String{
			var tempName:String = videoName;
			
			while(true){
				try{
					videoName = XML(videoName);
				}catch(error:Error){
					trace(error);
					return tempName;
				}
				if(videoName == tempName){
					break;
				}
				tempName = videoName;
				
			}
			
			return tempName;
		}
		
		/**
		 * 拡張子を取得します。
		 * 
		 * @return 
		 * 
		 */
		public static function getExtension(url:String):String{
			if(url.indexOf("%") != -1){
				url = decodeURIComponent(url);
			}
			
			var pattern:RegExp = new RegExp("\\.[A-Za-z0-9]+", "ig");
			var array:Array = url.substring(url.lastIndexOf("/")).match(pattern);
			var extension:String = "";
			if(array.length >= 1){
				return extension = array[array.length-1];
			}else{
				return null;
			}
		}
		
		/**
		 * サムネイル画像のURLを返します。
		 * 
		 * http://tn-skr1.smilevideo.jp/smile?i=7983504
		 * @param videoId 
		 */
		public static function getThumbImgUrl(videoId:String):String{
			
			videoId = getVideoNum(videoId);
			
			//0 <= n < 1
			//num/3
			var num:Number = Math.random();
			num = (num*10)%3 + 1;
			
			var thumbUrl:String = "http://tn-skr" + int(num) + ".smilevideo.jp/smile?i=" + videoId;

//			trace(thumbUrl);
			
			return thumbUrl;
			
		}
		
		/**
		 * 
		 * @param videoId
		 * @return 
		 * 
		 */
		public static function getVideoNum(videoId:String):String{
			
			var videoNum:String = getVideoID(videoId);
			
			videoNum = videoNum.substring(2);
			
			return videoNum;
		}
		
		
		
	}
}