package org.mineap.NNDD
{
	public class Message
	{
		/* ラベル用 */
		public static const L_PLAY:String = "再生";
		public static const L_PAUSE:String = "一時停止";
		public static const L_STOP:String = "停止";
		public static const L_RENEW:String = "更新";
		
		public static const L_DOWNLOAD:String = "ダウンロード";
		public static const L_CANCEL:String = "キャンセル";
		
		public static const L_SHORTCUT_INFO:String = "Ctrl(Cmd)+F:スクリーン切替";
		public static const L_SHOW_UNDER_CONTROLLER:String = "下のコントローラを表示しない";
		
		public static const L_FULL:String = "FULL";
		public static const L_NORMAL:String = "NORMAL";
		
		public static const L_COMMENT_FILE_NOT_FOUND:String = "コメントが見つかりません";
		
		public static const L_LIBRARY_LOADING:String = "ライブラリを読み込んでいます。";
		public static const L_LIBRARY_RENEWING:String = "ライブラリを更新しています。";
		
		public static const L_VIDEO_DELETED:String = "削除されています。";
		
		/*主にメッセージ出力*/
		public static const M_LOCAL_STORE_IS_BROKEN:String = "ローカルストアが破損している可能性があったため、ローカルストアのデータをリセットしました。";
		public static const M_FAIL_VIDEO_DELETE:String = "ビデオの削除に失敗しました。ファイルが開かれていない状態でもう一度試してください。";
		public static const M_FAIL_OTHER_DELETE:String = "削除できなかった項目があります。";
		public static const M_FAIL_MOVE_FILE:String = "ファイルの移動に失敗しました。";
		public static const M_FILE_NOT_FOUND_REFRESH:String = "ファイルが存在しません。設定 > 保存先の内容を更新 でライブラリを更新するか、再生しようとした動画が存在する事を確認してください。";
		public static const M_FAIL_ARGUMENT_BOOT:String = "引数で指定された値を使ってビデオを再生しようとしましたが失敗しました。";
		
		public static const M_ALREADY_UPDATE_PROCESS_EXIST:String = "他の更新が進行中です。";
		public static const M_ALREADY_DOWNLOAD_PROCESS_EXIST:String = "他のダウンロードが進行中です。";
		
		public static const M_ALREADY_DOWNLOADED_VIDE_EXIST:String = "既にダウンロード済みです。もう一度ダウンロードしますか？";
		public static const M_ALREADY_DLLIST_VIDE_EXIST:String = "既にダウンロードリストに追加済みです。もう一度追加しますか？";
		
		public static const M_ECONOMY_MODE_NOW:String = "現在エコノミーモードです。ダウンロードしますか？";
		
		public static const M_NOT_NICO_URL:String = "指定されたURLはニコニコ動画のURLではありません。";
		
		public static const M_VIDEOID_NOTFOUND:String = "このビデオのファイル名にはビデオIDが存在しないため、コメント・サムネイル情報・ユーザーニコ割をダウンロードできません。";
		public static const M_VIDEOID_NOTFOUND_FOR_COMMENT_ONLY:String = "このビデオのファイル名にはビデオIDが存在しないため、コメントをダウンロードできません。";
		
		public static const M_DOWNLOAD_PROCESSING:String = "未完了のダウンロードを含めてリストを空にしようとしています。よろしいですか？";
		
		public static const M_THIS_ITEM_IS_DOWNLOADING:String = "ダウンロードが進行中です。削除してもよろしいですか？";
		
		public static const M_FILE_ALREADY_EXISTS:String = "移動先に同名のファイルが存在します。上書きしますか？";
		
		public static const M_OUT_PLAYER_NOT_FOUND:String = "外部プレーヤが見つかりませんでした。「設定」タブで外部プレーヤのパスを設定し直すか、外部プレーヤを使用しない設定に変更してください。";
		
		public static const M_ERROR:String = "エラー";
		public static const M_MESSAGE:String = "通知";
		
		/*主にログ出力*/
		public static const BOOT_TIME_LOG:String = "アプリケーションの起動 - NNDD\n" + 
				"\t***** NNDDはMineAppProjectが作成しています。 *****\n" + 
				"\tMineAppProjectブログ\thttp://d.hatena.ne.jp/MineAP/\n" + 
				"\tNNDDホームページ\thttp://d.hatena.ne.jp/MineAP/20080730/1217412550\n" + 
				"\t*********************************************";
		
		public static const DELETE_FILE:String = "ファイルを削除";
		public static const MOVE_FILE:String = "ファイルを移動";
		
		public static const PLAY_VIDEO:String = "ビデオを再生";
		public static const INVOKE_ARGUMENT:String = "引数で値が渡されました";
		
		public static const SUCCESS_NICOCHART_ACCESS:String = "ニコニコチャートランキングの取得完了";
		public static const SUCCESS_SEARTCH:String = "検索結果を更新";
		public static const SUCCESS_RANKING_RENEW:String = "ランキングを更新"
		
		public static const SUCCESS_ACCESS_TO_NICONICODOUGA:String = "ニコニコ動画との接続に成功";
		public static const SUCCESS_ACCESS_TO_NICOAPI:String = "APIからアドレスの取得に成功";
		
		public static const SUCCESS_DOWNLOAD_USER_COMMENT:String = "ユーザーコメントXMLのダウンロードに成功";
		public static const SUCCESS_DOWNLOAD_OWNER_COMMENT:String = "投稿者コメントXMLのダウンロードに成功";
		public static const SUCCESS_DOWNLOAD_NICOWARI:String = "ユーザーニコ割のダウンロードに成功"
		public static const SUCCESS_DOWNLOAD_VIDEO:String = "ビデオのダウンロードに成功"
		
		public static const SUCCESS_SAVE_USER_COMMENT:String = "ユーザーコメントXMLの保存に成功";
		public static const FAIL_SAVE_USER_COMMENT:String = "ユーザーコメントXMLの保存に失敗";
		
		public static const SUCCESS_SAVE_OWNER_COMMENT:String = "投稿者コメントXMLの保存に成功";
		public static const FAIL_SAVE_OWNER_COMMENT:String = "投稿者コメントXMLの保存に失敗";
		
		public static const SUCCESS_SAVE_NICOWARI:String = "ユーザーニコ割の保存に成功";
		public static const FAIL_SAVE_NICOWARI:String = "ユーザーニコ割の保存に失敗";
		
		public static const SUCCESS_SAVE_VIDEO:String = "ビデオの保存に成功";
		public static const FAIL_SAVE_VIDEO:String = "ビデオの保存に失敗";
		
		public static const FAIL_LIBRARY_UNCONFORMITY_WAS_FOUND:String = "ライブラリファイルと実際のファイル構成に不整合があります。";
		
		public static const FILE_NOT_FOUND:String = "次のファイルが見つかりませんでした。"
		
		public static const ERROR:String = "エラーが発生しました。";
		
		public static const WINDOW_POSITION_RESET:String = "ウィンドウ位置をリセットしました。";
		
		public static const START_PLAY_EACH_COMMENT_DOWNLOAD:String = "コメント・サムネイル・ニコ割を更新しています...";
		public static const COMPLETE_PLAY_EACH_COMMENT_DOWNLOAD:String = "コメント・サムネイル・ニコ割を更新が完了しました";
		public static const PLAY_EACH_COMMENT_DOWNLOAD_CANCEL:String = "コメント・サムネイル・ニコ割がキャンセルされました";
		public static const FAIL_PLAY_EACH_COMMENT_DOWNLOAD:String = "コメント・サムネイル・ニコ割の更新に失敗しました";
		
		public static const FAIL_LOAD_LOCAL_STORE_FOR_NNDD_MAIN_WINDOW:String = "NNDDメインウィンドウのローカルストア情報読み込みに失敗";
		public static const FAIL_LOAD_LOCAL_STORE_FOR_VIDEO_CONTROLLER:String = "VideoControllerのローカルストア情報読み込みに失敗";
		public static const FAIL_LOAD_LOCAL_STORE_FOR_VIDEO_PLAYER:String = "VideoPlayerのローカルストア情報読み込みに失敗";
		public static const FAIL_LOAD_LOCAL_STORE_FOR_VIDEO_INFO_VIEW:String = "VideoInfoViewのローカルストア情報読み込みに失敗";
		public static const FAIL_MOVE_FILE:String = "ファイルの移動に失敗";
		public static const FAIL_ARGUMENT_BOOT:String = "引数で指定された値を使ったビデオの再生に失敗";

		public static const ARGUMENT_FORMAT:String = "例)nndd.exe -d http://www.nicovideo.jp/watch/ex0000\n※-dオプションをつけるとDLリストに追加、つけないとストリーミング再生。"
		
		public static const DONOT_USE_CHAR_FOR_FILE_NAME:String = "/ : ? \\ * \" % < > | # ;";
		
		public function Message()
		{
		}

	}
}