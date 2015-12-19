package
{
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.geom.*;
	import caurina.transitions.*;
	import org.papervision3d.cameras.*;
	import org.papervision3d.view.*;
	import org.papervision3d.materials.*;
	import org.papervision3d.objects.*;
	import org.papervision3d.objects.primitives.*
	
	[SWF(width = "720", height = "480", frameRate = "60", quality = "low")]
	public class Main extends BasicView
	{
		[Embed(source = 'pano.jpg.jpg')] private var BitmapImage:Class;
		
		// 分割数です 5の倍数だと画像が荒れません
		static private const MAX_CELL_W:uint = 20;
		static private const MAX_CELL_H:uint = 15;
		
		// 細切れになった写真の3Dパーツを保存する配列です
		private var planeArr:Array /* type of Array */ = [];
		
		public function Main()
		{
			// BasicViewの初期化します
			super(0, 0, true, false, CameraType.TARGET);
			
			// 画像を分割キャプチャします
			var bitmap:Bitmap = new BitmapImage();
			var bmpDataArr:Array /* type of BitmapData */ = [];
			
			// 二重ループを開始します
			var i:int = 0;
			var j:int = 0;
			for (i = 0; i < MAX_CELL_W; i++ )
			{
				for (j = 0; j < MAX_CELL_H; j++ )
				{
					var bmpData:BitmapData = new BitmapData(
						bitmap.width / MAX_CELL_W, 
						bitmap.height / MAX_CELL_H,
						false, 0xFF000000);
					
					// 行列を用いてキャプチャする画像の原点をずらします
					var matrix:Matrix = new Matrix();
					matrix.translate( 
						- bitmap.width / MAX_CELL_W * i,
						- bitmap.height / MAX_CELL_H * j);

					// 　行列変換を用いてキャプチャします
					bmpData.draw(bitmap, matrix);
					bmpDataArr.push(bmpData);
				}
			}
			
			// 分割平面を作成します
			var wrap:DisplayObject3D = scene.addChild(new DisplayObject3D());
			wrap.x = - bitmap.width / 2;
			wrap.y = - bitmap.height / 2;
			
			for (i = 0; i < MAX_CELL_W; i++ )
			{
				planeArr[i] /* type of Plane */ = [];
				for (j = MAX_CELL_H; j > 0 ; j-- )
				{
					var material:BitmapMaterial = new BitmapMaterial(
						BitmapData(bmpDataArr.shift()));
					
					var plane:Plane = new Plane(
						material,
						bitmap.width / MAX_CELL_W,
						bitmap.height / MAX_CELL_H,
						1, 1);
					plane.x = bitmap.width / MAX_CELL_W * i;
					plane.y = bitmap.height / MAX_CELL_H * j;
					
					planeArr[i][j] = wrap.addChild(plane);
				}
			}
			
			// レンダリングを開始します
			startRendering();
			motion();
			
			// ついでにマウスクリックでモーションを再生できるようにしています
			stage.addEventListener(MouseEvent.CLICK, motion);
			
			// ついでに背景の作成 不要なら以下4行を削除ください
			//var bgMatrix:Matrix = new Matrix();
			//bgMatrix.rotate(90 * Math.PI / 180);
			//graphics.beginGradientFill("linear", [0xFFFFFF, 0x001122], [100, 100], [0, 255], bgMatrix);
			//graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		}
		
		/**
		 * モーションのメソッドです
		 * @param	event
		 */
		private function motion(event:MouseEvent = null):void
		{
			// 二重ループを開始します
			var i:int = 0;
			var j:int = 0;
			
			// 分割平面のモーションを設定します
			for (i = 0; i < planeArr.length; i++ )
			{
				for (j = 1; j < planeArr[i].length ; j++ )
				{
					var plane:Plane = Plane(planeArr[i][j]);
					plane.z = -2000;
					plane.rotationY = 360;
					
					var distance:Number = Math.sqrt(i * i + j * j);
					Tweener.addTween(plane,
					{
						z          : 0,
						time       : .5,
						transition : "easeOutExpo",
						delay      : distance * .01
					});
					/*
					Tweener.addTween(plane,
					{
						rotationY  : 0,
						time       : .75,
						transition : "easeOutExpo",
						delay      : distance * .05  + 0.2
						});
						*/
				}
			}
			
			// カメラのモーションを設定します
			camera.focus = 100;
			camera.zoom  = 2;
			camera.x     = 400;
			camera.y     = 400;
			camera.z     = -1500;
			
			Tweener.addTween(camera,
			{
				x:0, y:0, z:-200,
				time       :0.5,
				transition :"easeInOutExpo"
			});
		}
	}
}