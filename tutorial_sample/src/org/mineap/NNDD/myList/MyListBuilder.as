package org.mineap.NNDD.myList
{
	import org.mineap.NNDD.LibraryManager;
	import org.mineap.NNDD.LogManager;
	import org.mineap.NNDD.model.NNDDVideo;
	import org.mineap.NNDD.util.PathMaker;
	import org.mineap.NNDD.util.NicoPattern;
	
	import mx.collections.ArrayCollection;
	


	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class MyListBuilder
	{
		private var _logManger:LogManager;
		private var _libraryManager:LibraryManager;
		private var _title:String = "";
		private var _description:String = "";
		private var _creator:String = "";
		
		/**
		 * 
		 * @param logManager
		 * @param libraryManager
		 * 
		 */
		public function MyListBuilder(logManager:LogManager, libraryManager:LibraryManager)
		{
			this._logManger = logManager;
			this._libraryManager = libraryManager;
		}
		
		/**
		 * 渡されたマイリストのRSS(XML)から、表示用のArrayCollectionを生成します。
		 * @param xml
		 * @return 
		 * 
		 */
		public function getMyListArrayCollection(xml:XML):ArrayCollection{
			
			/*
				<channel>
				<rss>
			 	<item>
			      <title>東方VocalSelection “千歳の夢を遠く過ぎても” [原曲 プレインエイジア]</title>
			      <link>http://www.nicovideo.jp/watch/sm4508441</link>
			      <guid isPermaLink="false">tag:nicovideo.jp,2008-09-03:/watch/1220438142</guid>
			      <pubDate>Fri, 24 Apr 2009 22:51:06 +0900</pubDate>
			      <description><![CDATA[
			      <p class="nico-memo"># tr.42</p>
			      <p class="nico-thumbnail"><img alt="東方VocalSelection “千歳の夢を遠く過ぎても” [原曲 プレインエイジア]" src="http://tn-skr2.smilevideo.jp/smile?i=4508441" width="94" height="70" border="0"/></p>
			      <p class="nico-description">夜が明けたら、君のところへ――　　　Circle：IOSYS　　　Album：東方想幽森雛　　　Vocal：あさ��　　　Original：プレインエイジア　　　Blazing：mylist/7121837　　　Twilight：mylist/8446649　　　最後まで再生すると次の動画にジャンプします　　　■想幽森雛収録のRemixシリーズはもっと評価されるべきだと思います。</p>
			      <p class="nico-info"><small><strong class="nico-info-length">5:39</strong>｜<strong class="nico-info-date">2008年09月03日 19：35：42</strong> 投稿</small></p>
			      ]]></description>
			    </item>
			    </channel>
				</rss>
			 */ 
			
			var arrayCollection:ArrayCollection = new ArrayCollection();
			var index:int = 1;
			
			for each(var temp:XML in xml.channel.children()){
				if(temp.name() == "title"){
					this._title = temp.text();
				}else if(temp.name() == "description"){
					this._description = temp.text();
				}else if(temp.name() == "http://purl.org/dc/elements/1.1/::creator"){
					this._creator = temp.text();
				}else if(temp.name() == "item"){
					
					var condition:String = "";
					var videoUrl:String = temp.link.text();
					
					var videoId:String = PathMaker.getVideoID(temp.link.text());
					var video:NNDDVideo = this._libraryManager.isExist(videoId);
					var videoLocalPath:String = "";
					if(video != null){
						condition = "ビデオ保存済\n右クリックから再生できます。";
						videoLocalPath = video.getDecodeUrl();
					}
					
					var thumbUrl:String = "";
					var array:Array = NicoPattern.myListThumbImgUrlPattern.exec(temp.description.text());
					if(array != null && array.length >= 1){
						thumbUrl = array[1];
					}
					
					var info:String = "";
					array = null;
					array = NicoPattern.myListMemoPattern.exec(temp.description.text());
					if(array != null && array.length >= 1){
						info = array[1];
					}
					
					var length:String = "";
					array = null;
					array = NicoPattern.myListLength.exec(temp.description.text());
					if(array != null && array.length >= 1){
						length = "    再生時間 " + array[1];
					}
					
					var date:String = "";
					array = null;
					array = NicoPattern.myListInfoDate.exec(temp.description.text());
					if(array != null && array.length >= 1){
						date = "    投稿日時 " + array[1];
					}
					
					arrayCollection.addItem({
						dataGridColumn_index:index++,
						dataGridColumn_preview:thumbUrl,
						dataGridColumn_videoName:temp.title.text() + "\n" + length + "\n" + date,
						dataGridColumn_videoInfo:info,
						dataGridColumn_condition:condition,
						dataGridColumn_videoUrl:videoUrl,
						dataGridColumn_videoLocalPath:videoLocalPath
					});
					
				}
				
			}
			
			
			return arrayCollection;
		}
		
		public function get title():String{
			return this._title;
		}
		
		public function get description():String{
			return this._description;
		}
		
		public function get creator():String{
			return this._creator;
		}

	}
}