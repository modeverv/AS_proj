package org.mineap.NNDD.commentManager
{
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FileListEvent;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	
	import org.mineap.NNDD.event.LocalCommentSearchEvent;
	import org.mineap.NNDD.model.NNDDVideo;
	import org.mineap.NNDD.LogManager;
	
	[Event(name="localCommentSearchComplete", type="LocalCommentSearchEvent")]
	[Event(name="ioError", type="IOErrorEvent")]
	/**
	 * 動画に対応する保存済み動画を管理するクラスです。<br />
	 * 
	 * @author shiraminekeisuke (MineAP)
	 * @eventType LocalCommentSearchEvent.LOCAL_COMMENT_SEARCH_COMPLETE
	 * @eventType IOErrorEvent.IO_ERROR
	 * 
	 */
	public class LocalCommentManager extends EventDispatcher
	{
		
		private var logger:LogManager = null;
		
		private var file:File = null;
		
		private var isStop:Boolean = false;
		
		/**
		 * コンストラクタ
		 * 
		 */
		public function LocalCommentManager()
		{
			logger = LogManager.getInstance();
		}
		
		/**
		 * 
		 * @param video
		 * @return 
		 */
		public function searchLocalComment(video:NNDDVideo):void{
			
			this.file = new File(video.getDecodeUrl());
			this.isStop = false;
			
			var parent:File = file.parent;
			
			parent.addEventListener(FileListEvent.DIRECTORY_LISTING, directoryListingCompleteHandler);
			parent.addEventListener(IOErrorEvent.IO_ERROR, directoryListingErrorHandler);
			parent.getDirectoryListingAsync();
			
		}
		
		/**
		 * 
		 * @param FileListEvent
		 * 
		 */
		private function directoryListingCompleteHandler(event:FileListEvent):void{
			
			removeHanlder(event);
			
			var files:Array = event.files;
			var commentFiles:Vector.<File> = new Vector.<File>();
			
			var searchString:String = this.file.name;
			var dotIndex:int = searchString.indexOf(".");
			if(dotIndex != -1){
				searchString = searchString.substring(0, dotIndex);
			}
			
			for each(var file:File in files){
				if(isStop){
					return;
				}
				
				var extension:String = file.extension;
				if(extension != null && extension.toLocaleLowerCase() == "xml"){
					
					var tempFileName:String = file.name.substr(0, searchString.length);
					
					if(searchString == tempFileName){
						
						if( file.name.length > 15 ){
							if("[ThumbInfo]" != file.name.substr(-15, 11)){
								commentFiles[commentFiles.length] = file;
							}
						}else{
							commentFiles[commentFiles.length] = file;
						}
					}
				}
			}
			
			var myEvent:LocalCommentSearchEvent = new LocalCommentSearchEvent(LocalCommentSearchEvent.LOCAL_COMMENT_SEARCH_COMPLETE, false, false, commentFiles);
			dispatchEvent(myEvent);
			
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function directoryListingErrorHandler(event:IOErrorEvent):void{
			dispatchEvent(event);
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function removeHanlder(event:Event):void{
			(event.currentTarget as File).removeEventListener(FileListEvent.DIRECTORY_LISTING, directoryListingCompleteHandler);
			(event.currentTarget as File).removeEventListener(IOErrorEvent.IO_ERROR, directoryListingErrorHandler);
		}
		
		/**
		 * 
		 * 
		 */
		public function stop():void{
			this.isStop = true;
		}
		
	}
}