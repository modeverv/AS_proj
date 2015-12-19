package pages 
{
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
	import jp.progression.scenes.*;
	import flash.display.Bitmap;
	/**
	 * ...
	 * @author modeverv
	 */
	public class AboutPage extends CastSprite 
	{
		// Embedタグを使用して画像と関連付けます。
		[Embed(source = "../images/aboutPage.png")]
		private var Emb:Class		
		
		/**
		 * 新しい AboutPage インスタンスを作成します。
		 */
		public function AboutPage( initObject:Object = null ) 
		{
			// 親クラスを初期化します。
			super( initObject );
			
    var img:Bitmap = new Emb() as Bitmap;
    addChild( img );			
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
