package
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import org.papervision3d.cameras.Camera3D;
	
	import org.papervision3d.view.*;
	import org.papervision3d.materials.*;
	import org.papervision3d.objects.*;
	import org.papervision3d.objects.primitives.*
	
    [SWF(width = "720", height = "480", frameRate = "60", backgroundColor = "#FFFFFF")]
	public class Main extends BasicView 
	{	
		// const vars
		static private const CIRCLE_RANGE :int = 150;
		static private const OBJ_LENGTH   :int = 30;
		static private const OBJ_HEIGHT   :int = 20;
		static private const RASEN_LENGTH :int = 2;
		static private const RASEN_RANGE  :int = 500;
		static private const FOCUS_POS    :int = 600;
		
		// 3d vars
		private var list   :Array = [];
		private var rasens :Array = [];
		private var wrap   :DisplayObject3D;

		/**
		 * Constructor
		 */
		public function Main()
		{
			super(450, 250);
			
			// init swf
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align     = StageAlign.TOP_LEFT;
			stage.quality   = StageQuality.HIGH;
			
			init();
		}
		
		public function init():void
		{
			//camera
			camera.focus     = 600;
			camera.zoom      = 1;
			camera.x         = 0;
			camera.y         = 0;
			camera.z         = 1000;
			
			// wrap
			wrap = new DisplayObject3D();
			scene.addChild(wrap);
			
			for (var i:int = 0; i < RASEN_LENGTH; i++ )
			{
				var rasen:DisplayObject3D = new DisplayObject3D();
				var rasenRot:Number = 360 * (i / RASEN_LENGTH)* Math.PI / 180;
				rasen.x = RASEN_RANGE * Math.sin(rasenRot);
				rasen.z = RASEN_RANGE * Math.cos(rasenRot);
				wrap.addChild(rasen);
				rasens.push(rasen);
				
				for (var j:int = 0; j < OBJ_LENGTH; j++)
				{
					var rot:Number = 360 * (j / 20) ;  
					
					var m:WireframeMaterial = new WireframeMaterial(0x003399);
					m.doubleSided = true;  
					
					var o:Plane = new Plane(m, 50, 50, 1, 1);
					
					o.x = CIRCLE_RANGE * Math.sin(rot * Math.PI / 180)
					o.y = OBJ_HEIGHT * j - OBJ_HEIGHT * OBJ_LENGTH /2;
					o.z = CIRCLE_RANGE * Math.cos(rot * Math.PI / 180)
					o.rotationY = rot;
					o.useOwnContainer = true; //ココ重要
					
					rasen.addChild(o);
					list.push(o);
				}
			}
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			startRendering(); 
		}
		
		private function enterFrameHandler(event:Event):void
		{
			// マウスのインタラクティブ
			wrap.rotationY += ((mouseX / stage.stageWidth * 480) - wrap.rotationY) * .1;
			camera.y += ((mouseY / stage.stageHeight * 2000) - 1000 - camera.y) * .1;
			
			// 螺旋の回転
			for (var i:int = 0; i < rasens.length; i++)
			{
				rasens[i].yaw(-3);
			}
			
			// 被写界深度フィルターの適用
			for (i = 0; i < list.length; i++)
			{
				var o:DisplayObject3D = list[i] as DisplayObject3D;
				
				// 距離の算出
				var deg:Number = Math.abs(calcPointDistanceFromCamera(o) - FOCUS_POS);
				
				// ぼかしの適用値
				var blurVal:int = Math.min(64, deg * .02 << 1 );
				var blurFilter:BlurFilter = new BlurFilter(blurVal, blurVal, 1);
				
				// 明度の適用値
				var blightness:Number = deg / 6;
				var blightnessArr:Array =
				[
					1, 0, 0, 0, blightness,
					0, 1, 0, 0, blightness,
					0, 0, 1, 0, blightness,
					0, 0, 0, 1, 0
				];
				var blightnessFilter:ColorMatrixFilter = new ColorMatrixFilter(blightnessArr);
				
				// フィルター適用
				o.filters = [blurFilter, blightnessFilter];
			}
		}
		
		/**
		 * カメラからの距離を算出します
		 * @param	obj 計測したいオブジェクト
		 * @return	カメラからの距離(3D空間内のpx値)
		 */
		private function calcPointDistanceFromCamera(obj:DisplayObject3D):Number
		{
			var vecX:Number = obj.sceneX - camera.x;
			var vecY:Number = obj.sceneY - camera.y;
			var vecZ:Number = obj.sceneZ - camera.z;
			return Math.sqrt((vecX * vecX) + (vecY * vecY) + (vecZ * vecZ));
		}

	}
}
