package jp.fores.foresmessenger.manager
{
	import flash.filesystem.File;
	
	import jp.fores.common.utils.ArrayUtil;
	import jp.fores.common.utils.FileUtil;
	import jp.fores.common.utils.StringUtil;
	import jp.fores.foresmessenger.dto.AttachmentFileDto;
	import jp.fores.foresmessenger.dto.SendingMessageDto;
	import jp.fores.foresmessenger.dto.UserInfoDto;
	
	import mx.controls.Alert;
	
	/**
	 * ログ管理クラス。
	 */
	public class LogManager
	{
		//==========================================================
		//メソッド
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//クラスメソッド
		
		/**
		 * 送信メッセージの内容をログファイルに出力します。
		 * 
		 * @param file 出力先のファイル
		 * @param message 送信メッセージ情報用DTO
		 * @param userInfoArray 利用者情報の配列
		 */
		public static function writeSendMessageLog(file :File, message :SendingMessageDto, userInfoArray :Array) :void
		{
			//実際に処理を行うメソッドを呼び出す
			writeMessageLog(file, message, true, userInfoArray);
		}
		
		/**
		 * 受信メッセージの内容をログファイルに出力します。
		 * 
		 * @param file 出力先のファイル
		 * @param message 送信メッセージ情報用DTO
		 */
		public static function writeReceiveMessageLog(file :File, message :SendingMessageDto) :void
		{
			//実際に処理を行うメソッドを呼び出す
			writeMessageLog(file, message, false, [message.sendUserInfo]);
		}
		
		/**
		 * ログファイルの内容を画面表示用の文字列に加工して取得します。
		 * 
		 * @param file 読み込むログファイル
		 * @return ログファイルの内容を画面表示用に加工した文字列
		 */
		public static function readLogFileForDisplay(file :File) :String
		{
			//ファイルが存在しない場合
			if(!file.exists)
			{
				//どうしようもないので空文字列を返す
				return "";
			}
			
			try
			{
				//指定されたファイルの内容を読み込んで文字列として取得する
				var str :String = FileUtil.readFileToString(file);
				
				//「\r\n」または「\r」を「\n」に変換することにより改行文字を補正する
				str = str.replace(/\r\n?/g, "\n");

				//リンクの色を明るい水色に変更
				StringUtil.linkColor = "#d8fbff";
				
				//XMLの特殊文字をエスケープした後、URLをリンクに変換する
				str = StringUtil.convertURLToLink(StringUtil.escapeXML(str));

				//取得した文字列を返す
				return str;
			}
			//例外処理
			catch(e :Error)
			{
				//エラーメッセージを表示
				Alert.show("ログファイルの読み込みに失敗しました:" + e);
				
				//どうしようもないので空文字列を返す
				return "";
			}

			//ここに来ることはないはずだが、とりあえず空文字列を返す
			return "";
		}
		
		
		//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
		//内部処理用
		
		/**
		 * 実際にメッセージの内容をログファイルに出力します。
		 * 
		 * @param file 出力先のファイル
		 * @param message 送信メッセージ情報用DTO
		 * @param isSend 送信かどうかのフラグ(true=送信, false=受信)
		 * @param userInfoArray 利用者情報の配列
		 */
		private static function writeMessageLog(file :File, message :SendingMessageDto, isSend :Boolean, userInfoArray :Array) :void
		{
			//本文の改行コードをOSの改行コードに補正する
			//(改行コードは「\r\n」または「\r」の両方を対象とする)
			var bodyText :String = message.bodyText.replace(/\r\n?/g, File.lineEnding);
			
			//FromまたはToの文字列
			var fromToStr :String = "From";
			
			//送信の場合
			if(isSend)
			{
				//FromまたはToの文字列を「To」に変更
				fromToStr = "To";
			}
			
			
			//==========================================================
			//ファイルに書き込む文字列の作成
			//(本当はJavaのStringBuilderのようなクラスを使いたいのですが、ActionScriptだと無いようなので仕方なくStringで行っています)
			var str :String = "";
			
			//ヘッダの上の区切りの行
			str += "=====================================" + File.lineEnding;
			
			//利用者情報の配列の全ての要素に対して処理を行う
			for each(var userInfo :UserInfoDto in userInfoArray)
			{
				//FromまたはToと利用者情報
				//( FromまたはTo: 利用者名 (グループ名/IPアドレス))
				str += " " + fromToStr + ": " + userInfo.userName + " (" + userInfo.groupName + "/" + userInfo.ipAddress + ")" + File.lineEnding;
			}

			//送信日時
			//(  at EEE MMM DD JJ:NN:SS YYYY)
			//(IP Messenger互換の日付形式にする)
			str += "  at " + StringUtil.formatTime(message.sendTime, "EEE MMM DD JJ:NN:SS YYYY") + File.lineEnding;

			//添付ファイル情報用Dtoの配列が存在する場合
			if(!ArrayUtil.isBlank(message.attachmentFileArray))
			{
				//添付ファイルの行の最初の文字列
				str += "  (添付) ";
				
				//最初の要素かどうかのフラグ
				var isFirstElement :Boolean = true;
				
				//添付ファイル情報用Dtoの配列の全ての要素に対して処理を行う
				for each(var attachmentFileDto :AttachmentFileDto in message.attachmentFileArray)
				{
					//最初の要素の場合
					if(isFirstElement)
					{
						//最初の要素かどうかのフラグをfalseにする
						isFirstElement = false;
					}
					//それ以外の場合
					else
					{
						//前の要素との区切りの文字列を追加
						str += ", ";
					}
					
					//ファイル名
					str += attachmentFileDto.fileName;
				}
				
				//改行
				str += File.lineEnding;
			}

			//ヘッダの下の区切りの行
			str += "-------------------------------------" + File.lineEnding;

			//改行コードを補正した本文
			str += bodyText;

			//最後の改行(2行分)
			str += File.lineEnding + File.lineEnding;
			//==========================================================
			
			try
			{
				//作成した文字列をファイルに追記モードで書き込む
				FileUtil.writeStringToFile(str, file, true);
			}
			//例外処理
			catch(e :Error)
			{
				//エラーメッセージを表示
				Alert.show("ログファイルの書き込みに失敗しました:" + e);
			}
		}
	}
}