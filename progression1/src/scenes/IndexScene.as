package scenes 
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
	import jp.progression.loader.*;
	import jp.progression.*;
	import jp.progression.scenes.*;
	
	import ui.*;
	import scenes.*;
	/**
	 * ...
	 * @author modeverv
	 */
	public class IndexScene extends SceneObject 
	{
		// scene
		private var aboutScene:scenes.AboutScene;
		private var galleryScene:scenes.GalleryScene;

		// ui
		private var homeButton:ui.HomeButton;
		private var aboutButton:ui.AboutButton;
		private var galleryButton:ui.GalleryButton;
		private var progressionButton:ui.ProgressionButton;		
		
		/**
		 * 新しい IndexScene インスタンスを作成します。
		 */
		public function IndexScene( name:String = null, initObject:Object = null ) 
		{
			// 親クラスを初期化する
			super( name, initObject );
			
			// シーンタイトルを設定します。
			title = "Index";
			aboutScene = new scenes.AboutScene();
			aboutScene.name = "about";
			addScene(aboutScene);
			
			galleryScene = new scenes.GalleryScene();
			galleryScene.name = "gallery";
			addScene(galleryScene);
			
			// インスタンスを生成します。
			homeButton = new HomeButton();
			homeButton.x = 0;
			homeButton.y = 150;
  
			aboutButton = new AboutButton();
			aboutButton.x = 0;
			aboutButton.y = 202;
			
			galleryButton = new GalleryButton();
			galleryButton.x = 0;
			galleryButton.y = 254;
  
			progressionButton = new ProgressionButton();
			progressionButton.x = 10;
			progressionButton.y = 446;
		}
		
		/**
		 * シーン移動時に目的地がシーンオブジェクト自身もしくは子階層だった場合に、階層が変更された直後に送出されます。
		 * このイベント処理の実行中には、ExecutorObject を使用した非同期処理が行えます。
		 */
		override protected function atSceneLoad():void 
		{
				// 表示処理を設定します。
				addCommand(
						new AddChild( container , homeButton ),
						new AddChild( container , aboutButton ),
						new AddChild( container , galleryButton ),
						new AddChild( container , progressionButton )
				);			
		}
		
		/**
		 * シーンオブジェクト自身が目的地だった場合に、到達した瞬間に送出されます。
		 * このイベント処理の実行中には、ExecutorObject を使用した非同期処理が行えます。
		 */
		override protected function atSceneInit():void 
		{
		}
		
		/**
		 * シーンオブジェクト自身が出発地だった場合に、移動を開始した瞬間に送出されます。
		 * このイベント処理の実行中には、ExecutorObject を使用した非同期処理が行えます。
		 */
		override protected function atSceneGoto():void 
		{
		}
		
		/**
		 * シーン移動時に目的地がシーンオブジェクト自身もしくは親階層だった場合に、階層が変更される直前に送出されます。
		 * このイベント処理の実行中には、ExecutorObject を使用した非同期処理が行えます。
		 */
		override protected function atSceneUnload():void 
		{
				// 削除処理を設定します。
				addCommand(
						new RemoveChild( container , homeButton ),
						new RemoveChild( container , aboutButton ),
						new RemoveChild( container , galleryButton ),
						new RemoveChild( container , progressionButton )
				);			
		}
	}
}
