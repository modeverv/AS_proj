package org.mineap.NNDD.commentManager
{
	import flash.filesystem.File;
	
	import org.mineap.NNDD.model.NNDDComment;
	import org.mineap.NNDD.FileIO;
	import org.mineap.NNDD.NGListManager;
	import org.mineap.NNDD.LibraryManager;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	/**
	 * Comments.as
	 * 
	 * Copyright (c) 2008-2009 MAP - MineApplicationProject. All Rights Reserved.
	 *  
	 * @author shiraminekeisuke
	 * 
	 */	
	public class Comments
	{
		
		public static const NG_KIND_ARRAY:Array = new Array("ID","単語","許可ID");
		public static const NG_ID:int = 0;
		public static const NG_WORD:int = 1;
		public static const PERMISSION_ID:int = 2;
		public static const NG_COMMAND:int = 3;
		
		private var comments:XML;
		private var ownerComments:XML;
		private var commentArray:Vector.<NNDDComment> = new Vector.<NNDDComment>();
		private var ownerCommentArray:Vector.<NNDDComment> = new Vector.<NNDDComment>();
		private var commentListProvider:ArrayCollection;
		private var commentMap:Object;
		private var _lastMin:String = "0";
		private var _isShowOnlyPermissionIdComment:Boolean;
		private var _hideSekaShinComment:Boolean;
		private var _ngListManager:NGListManager;
		
		private var _commentPath:String = null;
		private var _ownerCommentPath:String = null;
		
		/**
		 * コンストラクタ<br>
		 * 引数で渡されたコメントに対するパスを使って初期化を行います。
		 * @param commentXMLPath 通常のコメントファイルへのパス
		 * @param ownerCommentXMLPath 投稿者コメントファイルへのパス
		 * @param commentListProvider ロードしたコメントを追加するプロバイダ
		 * @param ownerCommentListProvider 投稿者コメントを追加するプロバイダ
		 * @param ngList ngリスト
		 * @param showOnlyPermissionIDComment
		 * @param loadCommentCount
		 * 
		 */
		public function Comments(commentXMLPath:String, ownerCommentXMLPath:String, commentListProvider:ArrayCollection, ownerCommentListProvider:ArrayCollection, ngListManager:NGListManager, showOnlyPermissionIDComment:Boolean, hideSekaShinComment:Boolean, loadCommentCount:int)
		{
			_isShowOnlyPermissionIdComment = showOnlyPermissionIDComment;
			_hideSekaShinComment = hideSekaShinComment;
			_ngListManager = ngListManager;
			
			this._commentPath = commentXMLPath;
			this._ownerCommentPath = ownerCommentXMLPath;
			
			if(commentListProvider != null){
				commentListProvider.removeAll();
			}
			if(ownerCommentListProvider != null){
				ownerCommentListProvider.removeAll();
			}
			
			if(new File(commentXMLPath).exists){
				var commentFileIO:FileIO = new FileIO();
				this.comments = commentFileIO.loadXMLSync(commentXMLPath, false);
				trace("Comments:通常コメントロード完了")
				commentArray = new Vector.<NNDDComment>();
				commentArray = loadCommentByXML(comments, commentArray, loadCommentCount);
				trace("commentCount:" + commentArray.length);
				if(commentListProvider != null){
					addCommentToArrayCollection(commentListProvider, ngListManager, showOnlyPermissionIDComment, hideSekaShinComment);
				}
			}
			if(new File(ownerCommentXMLPath).exists){
				var ownerCommentFileIO:FileIO = new FileIO();
				this.ownerComments = ownerCommentFileIO.loadXMLSync(ownerCommentXMLPath, false);
				trace("Comments:投稿者コメントロード完了")
				ownerCommentArray = new Vector.<NNDDComment>();
				ownerCommentArray = loadCommentByXML(ownerComments, ownerCommentArray, 1000);
				trace("commentCount:" + ownerCommentArray.length);
				if(commentListProvider != null && ownerCommentListProvider != null){
					addOwnerCommentToArrayCollection(commentListProvider, ownerCommentListProvider);
				}else if(commentListProvider != null){
					addOwnerCommentToArrayCollection(commentListProvider);
				}
			}
			this.commentListProvider = commentListProvider;
		}
		
		/**
		 * Commentsが保持する配列の参照をnullにしてGCを助けます。 
		 * 
		 */
		public function destructor():void{
			this.commentArray = null;
			this.commentListProvider = null;
			this.comments = null;
			this.ownerCommentArray = null;
			this.ownerComments = null;
		}
		
		/**
		 * 引数のvposに対応するCommentとCommandをArrayに格納して返します。
		 * @param vpos 現在再生中の時間(=vpos)です。
		 * @param interval vposの±intervalミリ秒の範囲でCommentを返すように設定します。
		 * @return 指定されたvposに対応するCommentを格納するArrayです。<br>
		 *         対応するCommentがない場合は空のArrayを返します。
		 * 
		 */
		public function getComment(vpos:int, interval:int):Vector.<NNDDComment>
		{
			var afterDiff:int = vpos - interval*2;
			var beforeDiff:int = vpos + interval;
			
			var returnCommentArray:Vector.<NNDDComment> = new Vector.<NNDDComment>();
			var index:int = 0;
			var commentVpos:int = 0;
			if(commentArray != null){
				for(index = 0; index < commentArray.length; index++){
					commentVpos = commentArray[index].vpos * 10;
					
					if(commentArray[index].isShow && commentVpos <= beforeDiff && commentVpos >= afterDiff){
						returnCommentArray.push(commentArray[index]);

						//一度表示したコメントを出力しないようにする処理
						commentArray[index].isShow = false;
					}
				}
			}
			if(ownerCommentArray != null){
				for(index = 0; index < ownerCommentArray.length; index++){
					commentVpos = ownerCommentArray[index].vpos * 10;
					
					if(ownerCommentArray[index].isShow && commentVpos <= beforeDiff && commentVpos >= afterDiff){
						
						returnCommentArray.push(ownerCommentArray[index]);
						
						//一度表示したコメントを出力しないようにする処理
						ownerCommentArray[index].isShow = false;
					}
				}
			}
			
			return returnCommentArray;
		}
		
		/**
		 * xmlから抽出したコメントをcommentArrayに追加します。
		 * @param xml
		 * @param commentArray
		 * 
		 */
		private function loadCommentByXML(xml:XML, commentArray:Vector.<NNDDComment>, loadCommentCount:int = 250):Vector.<NNDDComment>{
			trace("Comments.loadCommentByXML:コメントをXMLから配列に格納");
			var items:XMLList = xml.chat;
			
			var breakCount:int = items.length()-250;
			if(breakCount < 0){
				breakCount = 0;
			}
			
			for(var i:int = items.length()-1, j:int = 0; i>=0 && j<loadCommentCount ; i--, j++){
				var p:XML = items[i];
				commentArray.push(new NNDDComment(Number(p.attribute("vpos")), String(p.text()), String(p.attribute("mail")), String(p.attribute("user_id")), Number(p.attribute("no")), String(p.attribute("thread")),  true));
			}

			return commentArray;
		}
		
		/**
		 * 
		 * 
		 */
		public function resetEnableShowFlag():void{
			if(this.commentArray != null){
				for(var i:int = 0; i<this.commentArray.length; i++){
					this.commentArray[i].isShow = true;
				}
			}
			
			if(this.ownerCommentArray != null){
				for(i = 0; i<this.ownerCommentArray.length; i++){
					this.ownerCommentArray[i].isShow = true;
				}
			}
		}
		
		/**
		 * 引数で渡されたArrayCollectionにvposとcommentを追加します。<br>
		 * @param array
		 * 
		 */
		private function addCommentToArrayCollection(array:ArrayCollection, ngListManager:NGListManager, showOnlyPermissionIDComment:Boolean = false, isHideSekaShinComment:Boolean = false):void{
			var index:int = 0;
			
			//NGワード文字列
			var ngWordList:Array = ngListManager.getNgWordList();
			
			var lastTime:int = 0;
			for(var j:int=0; j<this.commentArray.length; j++){
				var tempTime:int = this.commentArray[j].vpos/100;
				if(tempTime > lastTime){
					lastTime = tempTime;
				}
			}
			
			var tempLastMin:String = String(int(lastTime/60));
			if(tempLastMin.length > this._lastMin.length){
				this._lastMin = tempLastMin;
			}
			
			for(index = 0; index < this.commentArray.length; index++){
				var comment:String = this.commentArray[index].text;
				var id:String = this.commentArray[index].user_id;
				
				if(ngListManager != null){
					
					//許可ユーザーのみ表示か？
					if(showOnlyPermissionIDComment){
						if(ngListManager.isNgId(id, Comments.NG_KIND_ARRAY[Comments.PERMISSION_ID])){
							//許可IDだった。何もしない。
						}else{
							//許可されていないID。
							this.commentArray[index].text = "";
							comment = "#---- このコメントは表示されません(非許可ID) ----#";
						}
					}else{
						
						if(ngListManager.isNgId(id, Comments.NG_KIND_ARRAY[Comments.NG_ID])){
							//NGIDだった。
							this.commentArray[index].text = "";
							comment = "#---- このコメントは表示されません(NGID) ----#";
						}else{
							//NGIDではない。
							
							//NGワードか？
							for each(var ngword:String in ngWordList){
								if(comment.indexOf(ngword) != -1){
									this.commentArray[index].text = "";
									comment = "#---- このコメントは表示されません(NGワード) ----#";
									break;
								}
							}
						}
					}
				}
				
				if(isHideSekaShinComment){
					if((this.commentArray[index] as NNDDComment).mail.indexOf(Command.SEKAINO_SHINCHAKU_COMMENT) != -1){
						this.commentArray[index].text = "";
						comment = "#---- このコメントは表示されません(世界の新着) ----#";
					}
				}
				
				//表示する時間
				var nowTime:int = commentArray[index].vpos/100;
				var nowSec:String="00",nowMin:String="0";
				nowSec = String(int(nowTime%60));
				nowMin = String(int(nowTime/60));
				
				if(nowSec.length == 1){
					nowSec = "0" + nowSec; 
				}
				if(nowMin.length == 1){
					//最後の分の桁数は？
					if(lastMin.length == 2){
						//２桁です
						nowMin = "0" + nowMin;
					}else if(lastMin.length == 3){
						//3桁です
						nowMin = "00" + nowMin;
					}
				}else if(nowMin.length == 2){
					//最後の分が3桁の時は0を追加
					if(lastMin.length == 3){
						nowMin = "0" + nowMin;
					}
				}
				
				array.addItem({
					vpos_column:nowMin + ":" + nowSec,
					comment_column:comment,
					user_id_column:commentArray[index].user_id,
					time_column:commentArray[index].vpos,
					no_column:commentArray[index].no
				});
			}
			array.sort = new Sort();
			array.sort.fields = [new SortField("vpos_column", false, false), new SortField("time_column", false, false)];
			array.refresh();
			
			commentMap = new Object();
			for(index = 0; index < array.length; index++){
				commentMap[array[index].vpos_column + array[index].comment_column] = index;
			}
			
		}
		
		/**
		 * 指定された時刻のコメントが、コメントリストの何行目にあるか返します。
		 * @param time
		 * @param comment
		 * @return 
		 * 
		 */
		public function getCommentIndex(time:String, comment:String):int{
			var index:int = commentMap[time+comment];
			return index;
		}
		
		/**
		 * 引数で渡されたArrayCollectionにvposと投稿者のcommentを追加します。<br>
		 * @param array
		 * 
		 */
		private function addOwnerCommentToArrayCollection(array:ArrayCollection, ownerArray:ArrayCollection = null):void{
			var index:int = 0;
			
			var lastTime:int = 0;
			for(var j:int=0; j<this.ownerCommentArray.length; j++){
				var tempTime:int = this.ownerCommentArray[j].vpos/100;
				if(tempTime > lastTime){
					lastTime = tempTime;
				}
			}
			
			var tempLastMin:String = String(int(lastTime/60));
			if(tempLastMin.length > this._lastMin.length){
				this._lastMin = tempLastMin;
				//lastMinの長さが変わったら通常コメントを再読み込み
				array.removeAll();
				addCommentToArrayCollection(array, _ngListManager, _isShowOnlyPermissionIdComment, _hideSekaShinComment);
			}
			
			for(index = 0; index < this.ownerCommentArray.length; index++){
				
				var nowTime:int = this.ownerCommentArray[index].vpos/100;
				var nowSec:String="00",nowMin:String="0";
				nowSec = String(int(nowTime%60));
				nowMin = String(int(nowTime/60));
				
				if(nowSec.length == 1){
					nowSec = "0" + nowSec; 
				}
				if(nowMin.length == 1){
					//最後の分の桁数は？
					if(lastMin.length == 2){
						//２桁です
						nowMin = "0" + nowMin;
					}else if(lastMin.length == 3){
						//3桁です
						nowMin = "00" + nowMin;
					}
				}else if(nowMin.length == 2){
					//最後の分が3桁の時は0を追加
					if(lastMin.length == 3){
						nowMin = "0" + nowMin;
					}
				}
				
				array.addItem({
					vpos_column:nowMin + ":" + nowSec,
					comment_column:ownerCommentArray[index].text,
					user_id_column:"OWNER",
					time_column:ownerCommentArray[index].vpos,
					no_column:ownerCommentArray[index].no
				});
				if(ownerArray != null){
					ownerArray.addItem({
						vpos_column:nowMin + ":" + nowSec,
						command_column:(ownerCommentArray[index] as NNDDComment).mail,
						comment_column:ownerCommentArray[index].text
					});
				}
			}
			
			if(array.length >= 1){
				
				array.sort = new Sort();
				array.sort.fields = [new SortField("vpos_column", false, false), new SortField("time_column", false, false)];
				array.refresh();
				
			}
			
			if(ownerArray != null){
				if(ownerArray.length >= 1){
					ownerArray.sort = new Sort();
					ownerArray.sort.fields = [new SortField("vpos_column", false, false), new SortField("time_column", false, false)];
					ownerArray.refresh();
				}
			}
			
			
			//投コメが入るとインデックスが変わるので作り直し
			commentMap = new Object();
			for(index = 0; index < array.length; index++){
				commentMap[array[index].vpos_column + array[index].comment_column] = index;
			}
			
		}
		
		/**
		 * 一番最後のコメントが表示される分を返します。
		 * @return 
		 * 
		 */
		public function get lastMin():String{
			return this._lastMin;
		}
		
		/**
		 * 読み込んだコメントファイルです。
		 * @return 
		 * 
		 */
		public function get commentFile():File{
			var file:File = LibraryManager.getInstance().tempDir;
			file.url = file.url + "nndd.xml";
			try{
				file = new File(this._commentPath);
			}catch(error:Error){
				trace(error);
			}
			return file;
		}
		
		/**
		 * 読み込んだ投稿者コメントファイルです。
		 * @return 
		 * 
		 */
		public function get ownerCommentFile():File{
			
			var file:File = LibraryManager.getInstance().tempDir;
			file.url = file.url + "nndd[Owner].xml";
			try{
				file = new File(this._ownerCommentPath);
			}catch(error:Error){
				trace(error);
			}
			return file;
		}
		
	}
}