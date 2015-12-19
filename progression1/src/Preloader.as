package  
{
	import flash.net.*;
	import jp.progression.casts.*;
	import jp.progression.commands.display.*;
	import jp.progression.commands.lists.*;
	import jp.progression.commands.managers.*;
	import jp.progression.commands.media.*;
	import jp.progression.commands.net.*;
	import jp.progression.commands.tweens.*;
	import jp.progression.commands.*;
	import jp.progression.data.*;
	import jp.progression.events.*;
	import jp.progression.executors.*;
	
	/**
	 * ...
	 * @author modeverv
	 */
	public class Preloader extends CastPreloader 
	{
		
		/**
		 * 新しい Preloader インスタンスを作成します。
		 */
		public function Preloader() 
		{
			// プリローダーが読み込むファイルと、実行形式を指定します。
			super( new URLRequest( "index.swf" ), false, CommandExecutor );
		}
		
		/**
		 * SWF ファイルの読み込みが完了し、stage 及び loaderInfo にアクセス可能になった場合に送出されます。
		 */
		override protected function atReady():void 
		{
		}
		
		/**
		 * オブジェクトが読み込みを開始した瞬間に送出されます。
		 * このイベント処理の実行中には、ExecutorObject を使用した非同期処理が行えます。
		 */
		override protected function atCastLoadStart():void 
		{
			addCommand(
			);
		}
		
		/**
		 * ダウンロード処理を実行中にデータを受信したときに送出されます。
		 */
		override protected function atProgress():void 
		{
		}
		
		/**
		 * オブジェクトが読み込みを完了した瞬間に送出されます。
		 * このイベント処理の実行中には、ExecutorObject を使用した非同期処理が行えます。
		 */
		override protected function atCastLoadComplete():void 
		{
			addCommand(
			);
		}
	}
}
