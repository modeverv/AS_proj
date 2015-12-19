package
{
	import flash.display.*;
	import flash.events.*;
	
	import org.papervision3d.cameras.*;
	import org.papervision3d.view.*;
	import org.papervision3d.materials.*;
	import org.papervision3d.objects.*;
	import org.papervision3d.objects.primitives.*
	import org.papervision3d.materials.utils.*;
	
	[SWF(width = "720", height = "480", frameRate = "60", backgroundColor = "#000000")]
	
	public class Main extends BasicView 
	{	
		// 3Dオブジェクト
		private var sphere:Sphere;
		private var wire:Sphere;

		/**
		 * コンストラクタ
		 */
		public function Main()
		{
			// BasicViewの初期化
			super(0, 0, true, false, CameraType.FREE);
			
			// init swf
			stage.quality = StageQuality.LOW;
			
			// カメラ
			camera.x = camera.y = camera.z = 0;
			camera.focus = 300;
			camera.zoom = 1;
			
			// 定数
			var size :Number = 25000;
			var quality :Number = 30;
			
			var sphereMaterial:BitmapFileMaterial = new BitmapFileMaterial("pano.jpg", false);
			sphereMaterial.opposite = true;
			sphereMaterial.smooth = true;
			
			var wireMaterial:WireframeMaterial = new WireframeMaterial(0xFF0000);
			wireMaterial.opposite = true;
			
			// キューブを作成
			sphere = new Sphere(
				sphereMaterial,
				size, 
				quality, 
				quality);
			wire = new Sphere(
				wireMaterial,
				size,
				quality,
				quality);
			wire.visible = true;
			
			// シーンに追加
			scene.addChild(sphere);
			//scene.addChild(wire);
			
			// マウスのインタラクティブを設定しています
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			//stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);
			//stage.addEventListener(MouseEvent.MOUSE_UP, mouseHandler);
			
			// レンダリングを開始します
			startRendering();
		}
		
		/**
		 * マウスの位置に応じてインタラクティブを設定しています
		 * @param	event
		 */
		private function enterFrameHandler(event:Event):void
		{
			// Pan
			camera.rotationY += (480 * mouseX/(stage.stageWidth) - camera.rotationY) * .1;
			camera.rotationX += (180 * mouseY/(stage.stageHeight) - 90 - camera.rotationX) * .1;
		}
		
		/**
		 * マウスを話したときにワイヤーフレームが非表示になるように設定しています
		 * @param	event
		 */
		private function mouseHandler(event:MouseEvent):void 
		{
			wire.visible = !wire.visible;
		}
	}
}
