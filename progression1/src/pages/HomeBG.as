package  pages
{
	import flash.display.Bitmap;
	import jp.progression.casts.*;
	import jp.progression.commands.display.*;
	import jp.progression.commands.lists.*;
	import jp.progression.commands.managers.*;
	import jp.progression.commands.media.*;
	import jp.progression.commands.net.*;
	import jp.progression.commands.tweens.*;
	import jp.progression.commands.*;
	import jp.progression.config.WebConfig;
	import jp.progression.data.*;
	import jp.progression.events.*;
	import jp.progression.scenes.*;
	
	/**
	 * ...
	 * @author modeverv
	 */
	public class HomeBG extends CastSprite 
	{
		[Embed(source = "../images/homeBG.png")]
		private var Emb:Class;
		
		/**
		 * 新しい HomeBG インスタンスを作成します。
		 */
		public function HomeBG( initObject:Object = null ) 
		{
			// 親クラスを初期化します。
			super( initObject );
			
			var img:Bitmap = new Emb() as Bitmap;
			addChild(img);
			
		}
		
		/**
		 * IExecutable オブジェクトが AddChild コマンド、または AddChildAt コマンド経由で表示リストに追加された場合に送出されます。
		 * このイベント処理の実行中には、ExecutorObject を使用した非同期処理が行えます。
		 */
		override protected function atCastAdded():void 
		{
		}
		
		/**
		 * IExecutable オブジェクトが RemoveChild コマンド、または RemoveAllChild コマンド経由で表示リストから削除された場合に送出されます。
		 * このイベント処理の実行中には、ExecutorObject を使用した非同期処理が行えます。
		 */
		override protected function atCastRemoved():void 
		{
		}
	}
}
