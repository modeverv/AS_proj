package org.mineap.NNDD.util
{

	import org.mineap.NNDD.Message;
	
	public class ThumbInfoAnalyzer
	{
		private var _tagArray:Array;
		private var _videoId:String;
		private var _title:String;
		private var _description:String;
		private var _viewCounter:String;
		private var _myListNum:String;
		private var _commentNum:String;
		private var _firstRetrieve:String;
		private var _lastResBody:String;
		private var _status:String;
		private var _length:String;
		private var _errorCode:String;
		
		public static const STATUS_OK:String = "ok";
		
		public static const STATUS_FAIL:String = "fail";
		
		public static const ERROR_CODE_DELETED:String = "DELETED";
		
		public static const ERROR_CODE_COMMUNITY:String = "COMMUNITY";
		
		/**
		 * thumbInfo.xmlを解析して、以下の情報を抽出します。
		 * ・タグ
		 * ・投稿者説明文
		 * ・再生数
		 * ・コメント数
		 * ・マイリスト追加数
		 * ・投稿日時
		 * ・最近のレス
		 * 
		 * @param xml
		 */
		public function ThumbInfoAnalyzer(xml:XML)
		{
			this._tagArray = new Array();
			this.analyze(xml);
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get length():String
		{
			return _length;
		}

		
		/**
		 * thumbInfo.xmlを解析して、以下の情報を抽出します。
		 * ・タグ
		 * ・投稿者説明文
		 * ・再生数
		 * ・コメント数
		 * ・マイリスト追加数
		 * ・投稿日時
		 * ・最近のレス
		 * 
		 * 
		 * @param xml
		 * @return 
		 * 
		 */
		public function analyze(xml:XML):Array{
			try{
				
				this._status = xml.@status;
				
				if(this._status == STATUS_OK){
					this._videoId = xml.thumb.video_id;
					this._title = xml.thumb.title;
					this._description = xml.thumb.description;
					this._viewCounter = addComma(xml.thumb.view_counter);
					this._commentNum = addComma(xml.thumb.comment_num);
					this._myListNum = addComma(xml.thumb.mylist_counter);
					this._firstRetrieve = xml.thumb.first_retrieve;
					this._lastResBody = PathMaker.getSpecialCharacterNotIncludedVideoName(xml.thumb.last_res_body.text());
					this._length = xml.thumb.length;
					
					var tags:XMLList = xml.thumb.tags;
					for(var i:int=0; i<tags.tag.length(); i++){
						this._tagArray.push(PathMaker.getSpecialCharacterNotIncludedVideoName((tags.tag[i] as XML).text()));
					}
					if(tags.length() == 0){
						//タグが一つも無い。削除されている模様。
						this._tagArray.push(Message.L_VIDEO_DELETED);
					}
				}else if(this._status == STATUS_FAIL){
					
					if(xml.error != null && xml.error.code != null){
						this._errorCode = xml.error.code;
					}else{
						this._errorCode = "UNKNOWN";
					}
					
					if(xml.error.code == "COMMUNITY"){
						
						this._tagArray = new Array();
						this._tagArray.push("公式動画(COMMUNITY)には非対応");
						
					}else{
						
						this._tagArray = new Array();
						this._tagArray.push("(タグ情報の取得に失敗)");
						
					}
					
				}
			}catch(error:Error){
				trace(error.getStackTrace());
				this._logManager.addLog("タグ情報の取得に失敗:" + error + error.getStackTrace());
				this._tagArray = new Array();
				this._tagArray.push("(タグ情報の取得に失敗)");
			}
			
			return this._tagArray;
		}
		
		/**
		 * 渡された数字に3桁ごとのカンマを追加します。
		 * @param str
		 * @return 
		 * 
		 */
		public function addComma(str:String):String{
			
			var len:int = str.length;
			
			for(var i:int = 1; i<len; i++){
				var index:int = i*(-3)-(i-1);
				var b:String = str.substring(0, len+index);
				var a:String = str.substring(len+index);
				if(b.length == 0){
					break;
				}
				str =  b + "," + a;
				len++;
			}
			
			return str;
			
		}
		
		
		/**
		 * 2009-04-24T22:25:46+09:00
		 * 
		 * @param thumbInfoDateFormatString
		 * @return 
		 * 
		 */
		public function getDateByFirst_retrieve(thumbInfoDateFormatString:String = null):Date{
			if(thumbInfoDateFormatString == null){
				thumbInfoDateFormatString = this._firstRetrieve;
			}
			//2009-04-24T22:25:46+09:00
			var pattern:RegExp = new RegExp("(\\d\\d\\d\\d)-(\\d\\d)-(\\d\\d).(\\d\\d):(\\d\\d):(\\d\\d)([+|-])(\\d\\d):(\\d\\d)", "ig");
			var array:Array = pattern.exec(thumbInfoDateFormatString);
			if(array != null && array.length > 0){
				//1 年
				//2 月
				//3 日
				//4 時
				//5 分
				//6 秒
				//7 GMTとのずれは+か-か
				//8 GMTとのずれ（時）
				//9 GMTとのずれ（分）
				
				//Date#parse()で有効な文字列表現
				//YYYY/MM/DD HH:MM:SS TZD
				var dateString:String = array[1] + "/" + array[2] + "/" + array[3] + " " + 
					array[4] + ":" + array[5] + ":" + array[6] + " GMT" + array[7] + array[8] + array[9];
				
				var date:Date = new Date(dateString);
				return date;
			}else{
				return null;
			}
		}
		
		/**
		 * HTML形式の動画のタイトルを返します。
		 * @return 
		 * 
		 */
		public function get htmlTitle():String{
			if(this._status == "ok"){
				return "<a href=\"http://www.nicovideo.jp/watch/" + _videoId + "\"><u><font color=\"#0000ff\">" + _title + "</font></u></a>";
			}else{
				return "(削除されています)";
			}
		}
		
		/**
		 * 「再生:(数字) コメント:(数字)　マイリスト:(数字)」という形式の文字列を返します。
		 * @return 
		 * 
		 */
		public function get playCountAndCommentCountAndMyListCount():String{
			if(this._status == "ok"){
				return "再生:" + _viewCounter + " コメント:" + _commentNum + " マイリスト:" + _myListNum;
			}else{
				return "再生:- コメント:- マイリスト:-";
			}
			
		}
		
		/**
		 * 投稿者説明文の動画IDおよびマイリストIDをリンクに置き換えた文字列を返します。
		 * @return 
		 * 
		 */
		public function get thumbInfoHtml():String{
			var myLists:Array = new Array();
			
			if(errorCode == "DELETED"){
				returnString = "(削除されています)";
			} if (errorCode == "NOT_FOUND" ){
				returnString = "(見つかりませんでした)";
			}else{
				
				var myList_pattern:RegExp = new RegExp("(mylist/\\d+)", "ig");
				var videoId_pattern:RegExp = new RegExp(PathMaker.VIDEO_ID_SEARCH_PATTERN_STRING, "ig");
				
				var returnString:String = this._description.replace(myList_pattern, replFN_mylist);
				
				function replFN_mylist():String{
					myLists.push(arguments[0]);
					return "<a href=\"event:" + arguments[0] + "\"><u><font color=\"#0000ff\">" + arguments[0] + "</font></u></a>";
				}
				
				
				returnString = returnString.replace(videoId_pattern, replFN);
				
				function replFN():String {
					
					//color="#0000ff"を見つけたときはスキップ
					if(arguments[0] == "0000"){
						return arguments[0];
					}
					
					//マイリストとして登録済みならスキップ
					// TODO この方法だとマイリストと同じ番号を持つ動画にたいしてはリンクが設定されないが、その可能性は低いので問題はないとする。
					for each(var mylist:String in myLists){
						var id:String = mylist.substring(7);
						if(id == arguments[0]){
							return arguments[0];
						}
					}
					
					return "<a href=\"event:watch/" + arguments[0] + "\"><u><font color=\"#0000ff\">" + arguments[0] + "</font></u></a>";
				}
				
			}
			
			return returnString;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get tagArray():Array{
			return this._tagArray;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get title():String{
			return this._title;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get description():String{
			return this._description;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get firstRetrieve():String
		{
			return _firstRetrieve;
		}

		/**
		 * 
		 * @return 
		 * 
		 */
		public function get commentNum():String
		{
			return _commentNum;
		}

		/**
		 * 
		 * @return 
		 * 
		 */
		public function get viewCounter():String
		{
			return _viewCounter;
		}

		/**
		 * 
		 * @return 
		 * 
		 */
		public function get myListNum():String
		{
			return _myListNum;
		}

		/**
		 * 
		 * @return 
		 * 
		 */
		public function get lastResBody():String
		{
			return _lastResBody;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get status():String
		{
			return _status;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get errorCode():String{
			return _errorCode;
		}

	}
}