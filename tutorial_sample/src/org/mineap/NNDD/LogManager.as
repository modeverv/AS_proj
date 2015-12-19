package org.mineap.NNDD
{
	import flash.filesystem.File;
	import flash.system.Capabilities;
	
	import mx.controls.TextArea;
	import mx.formatters.DateFormatter;
	
	/**
	 * LogManager.as
	 * ログ出力用のクラスです。
	 * 
	 * Copyright (c) 2008 MAP - MineApplicationProject. All Rights Reserved.
	 *  
	 * @author shiraminekeisuke
	 * 
	 */	
	public class LogManager
	{
		
		private var logString:String;
		private var textArea:TextArea;
		private var logDir:File;
		
		private static var logManager:LogManager = null;
		
		/**
		 * 
		 * @param textArea
		 * 
		 */
		public static function initialize(textArea:TextArea):void{
			logManager = new LogManager(textArea, null);
		}
		
		/**
		 * シングルトンパターン
		 * 
		 * @return 
		 * 
		 */
		public static function getInstance():LogManager{
			return logManager;
		}
		
		/**
		 * コンストラクタ。
		 * 
		 */
		public function LogManager(textArea:TextArea, logDir:File = null)
		{
			var df:DateFormatter = new DateFormatter();
			df.formatString = "YYYYMMDDJJNNSS";
			var dateString:String = df.format(new Date());
			
			this.logDir = logDir;
			this.textArea = textArea;
			this.logString = dateString + ":" + Message.BOOT_TIME_LOG +
					"\n\tFlashPlayerバージョン:" + Capabilities.version +
					"\n\tデバッガバージョン:" + Capabilities.isDebugger +
					"\n\tプレイヤータイプ:" + Capabilities.playerType + 
					"\n\tオペレーティングシステム:" + Capabilities.os;
			
			if(logDir != null){
				
				var logFile:File = new File(logDir.url + "/nndd.log");
				if(logFile.exists){
					if(logFile.size > 250000){
						this.logString += "\nログファイルが250KBを超えていたので削除しました。";
						logFile.deleteFile();
					}
				}
				
				var fileIO:FileIO = new FileIO();
				fileIO.addLog(this.logString, logDir.url + "/nndd.log");
			}
		}

		/**
		 * 
		 * @param logDir
		 * 
		 */
		public function setLogDir(logDir:File):void{
			this.logDir = logDir;
			
			var logFile:File = new File(logDir.url + "/nndd.log");
			var isDelete:Boolean = false;
			if(logFile.exists){
				if(logFile.size > 1000000){
					isDelete = true;
					logFile.moveTo(new File(logDir.url + "/nndd(old).log"), true);
				}
			}
			
			var fileIO:FileIO = new FileIO();
			fileIO.addLog(this.logString, logFile.url);
			
		}

		/**
		 * ログを追加します。<br>
		 * ログは、既存のログの最後に空白行を付加した後に追加されます。
		 * 
		 * @param ログに追加したい文字列。
		 * 
		 */
		public function addLog(log:String):void
		{
//			trace("log added:"+logString)
	
			var df:DateFormatter = new DateFormatter();
			df.formatString = "YYYYMMDDJJNNSS";
			var dateString:String = df.format(new Date());
			
			log = log.replace(new RegExp("\n", "ig"), "\n\t");
			
			this.logString = this.logString + "\n"+ dateString + ":\t" + log;
			
			showLog(this.textArea);
			
			var fileIO:FileIO = new FileIO();
			fileIO.addLog("\n\n"+ dateString + ":" + log, this.logDir.url + "/nndd.log");
			
		}
		
		/**
		 * 現在のログ文字列を返します。
		 * 
		 * @return 起動から現在までのログ文字列。
		 */
		public function getLog():String
		{
			return new String(logString);
		}
		
		/**
		 * ログをTextAreaに出力します。
		 */
		public function showLog(textArea:TextArea):void
		{
			if(textArea != null){
				textArea.text = logString;
			}
		}

	}
}