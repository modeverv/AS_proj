package 
{
	import flash.display.Sprite;
	import flash.events.Event;//リスナ/ハンドラ
	import flash.events.KeyboardEvent;//リスナ/ハンドラ
	import flash.events.MouseEvent;//リスナ/ハンドラ
	import flash.net.URLLoader;//ロード用
	import net.hires.debug.Stats;//ステイタス表示 for debug
	import flash.system.Security;//webAPI使うときは要りそうだけど使い方わかんない！
	import flash.net.URLRequest;//xmlロード用
	import flash.display.Loader;//(現状ローカルなので)imgロード用
	import fortest.XMLLoader;
	
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;	
	
	/**
	 * ...
	 * @author modeverv
	 */
	public class Main extends Sprite 
	{
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private var srclist:Array;
		private var sig:String = 'http://feedmaker.ssig33.com/pixiv/ranking/daily?format=atom';
		//private var sig:String = 'http://feedmaker.ssig33.com/pixiv/member/122694?format=atom';
        private var loader:URLLoader;
        private var xml:XML;
		private var xmlloader:XMLLoader;
		private var loader_obj:Loader;
		private var _sp:Sprite;
		
		private function onMD(e:MouseEvent):void {
			nextImg();
		}
		private function onKeyRight(e:KeyboardEvent):void {
			nextImg();
		}
		private var done:Boolean = false;
		
		private function nextImg():void{
			var src:String = srclist.pop() as String;
			if(src != null){
				//簡単実装
				//現状はプールは一切入れていないので
				//戻る/進むように先読みや履歴データを持っておくとレスポンスが良くなるはず
				if (loader_obj != null && stage.contains(loader_obj)) {
					_sp.removeChild(loader_obj);
					loader_obj.unload();
				}
				if (_sp != null && stage.contains(_sp)) {
					stage.removeChild(_sp);
					//メモリ解放はGCにお任せ。stageから抜いて
					//あとでnewしているから適当にやってくれるよね？
				}
				_sp = new Sprite();//トランジション用にスプライトにまとめた方がいいよねー
				//_sp.x = stage.stageWidth / 2;//noScaleしてないからウィンドウサイズ非追従だけどまぁ、ステージの真ん中配置で
				//_sp.y = stage.stageHeight / 2 ;
				stage.addChild(_sp);
				loader_obj = new Loader();
				var url : URLRequest = new URLRequest(src);
				loader_obj.load(url);
				_sp.addChild(loader_obj);
				trace(srclist.length);
				trace(done);
				if (srclist.length < 20 && done == false ) {
					getList();
					done = true;
				}
			}else { 
				trace("null");
				
			}
		}
		
		//気合いでxmlをロードするの図。
		//イベントバインドの位置はいつも悩む
		//形になってしまっているけど、その辺どうなんでしょう。画像データで履歴+先読みを入れるでしょうし。
		//XMLロード全体が同期処理になってしまっているのを何とかしたい。つまる。
		
		private function onXMLloaded(e:Event):void {
			xml = xmlloader.rawXML;

			var ns:Namespace = new Namespace("http://www.w3.org/2005/Atom");
			trace(xml.ns::entry);

			//http://www.w3.org/2005/Atom
			var pattern:RegExp = /http\:\/\/feedmaker\.ssig33\.com\/pixiv\/[0-9]+\.jpg/;
			for each(var item:XML in xml.ns::entry) {
				var resultObject:Object = pattern.exec(item.ns::content.toString());
				srclist.unshift(resultObject.toString());
			}
			done  = false;
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			//ステージサイズ・スケールをウィンドウ追従に
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			//デバッグ表示
			var stats:Stats = new Stats()
			stats.y = 800;
			addChild(stats);
			
			//xmlloader = new XMLLoader(sig);
			//trace(xmlloader.rawXML);
			//xmlloader.addEventListener(XMLLoader.LOAD_COMPLETE, onXMLloaded);
			
			srclist = new Array();
			
			getList();
			
			addEventListener(Event.ENTER_FRAME, onEF);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMD);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyRight);		
		}
		private function getList():void {
			//GCまかせ
			xmlloader = new XMLLoader(sig);
			trace(xmlloader.rawXML);
			xmlloader.addEventListener(XMLLoader.LOAD_COMPLETE, onXMLloaded);
	
		}
		
		//適当な効果とかの実験 enterflameで対応予定。
		private function onEF(e:Event):void {
			if (_sp != null) {
				_sp.rotation += 0 ;//かいてんですね。
			}
		}
	}
}