package 
{
	import caurina.transitions.properties.DisplayShortcuts;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import org.papervision3d.core.math.Sphere3D;
	import org.papervision3d.core.proto.DisplayObjectContainer3D;
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.VideoStreamMaterial;
	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.*;
	import org.papervision3d.view.*;
	
	/**
	 * ...
	 * @author modeverv
	 */
	public class Main extends BasicView
	{
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private var wrap:DisplayObject3D; // parent
		private var r:Number = 0;
	
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			wrap = new DisplayObject3D();
			scene.addChild(wrap);
			
			
			var max:int = 10;
			for (var i:int = 0; i < max; i++) {
				var material:WireframeMaterial = new WireframeMaterial(Math.random() * 0xffffff);
				material.doubleSided = true;
			
				var obj:Plane = new Plane(material, 200, 200);
				var rot:Number = 360 * (i / max);
				obj.x = 600 * Math.sin(rot * Math.PI / 180);
				obj.z = 600 * Math.cos(rot * Math.PI / 180);
				obj.lookAt(DisplayObject3D.ZERO);
				wrap.addChild(obj);
			}
			
			var sphere:Sphere = new Sphere(material, 500);
			
			scene.addChild(sphere);

			/* material */
			// color material
			var mC :ColorMaterial = new ColorMaterial(0x0f0f0f, .2);
			var smC:Sphere = new Sphere(mC, 600);
			scene.addChild(smC);
			
			// bitmap file
			var opath:String = "C:/WCworkmyrepo/as3/trunk/myflashlib/assetsfortests/";
			var mBf:BitmapFileMaterial = new BitmapFileMaterial(opath + "whats2.gif");
			var smBf :Sphere = new Sphere(mBf, 100, 15, 15);
			scene.addChild(smBf);
			
			// bitmap
			var plate:Plane = new Plane(mC,500,500,1,1);
			setBitmapMaterial(plate,opath + "whats2.gif",cmpH)
			//setFlvMaterilal(plate,opath + "test.flv");
			scene.addChild(plate);
			
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			startRendering();
			
			addEventListener(Event.ENTER_FRAME, function():void { 
				var tr:Number = (mouseX / stage.stageWidth) * 360; 
				r += (tr- r) * 0.02;
				camera.x = 1000 * Math.sin(r * Math.PI / 180);
				camera.z = 1000 * Math.cos(r * Math.PI / 180);
			});
		}
		
		private function setBitmapMaterial(obj:DisplayObject3D, strpath:String,func:Function) :void{
	  	var loader:Loader = new Loader();
	    loader.contentLoaderInfo.addEventListener(Event.COMPLETE,func(obj,loader));
		  loader.load(new URLRequest(strpath));
	  }
		
	  private function cmpH(obj:DisplayObject3D,loader:Loader) :Function{
		  return function (e:Event):void {
				var bmp:Bitmap = Bitmap(loader.content);
				var bmpData:BitmapData = bmp.bitmapData;
				var material:BitmapMaterial = new BitmapMaterial(bmpData);
				material.doubleSided = true;
				obj.material = material;	
			}
	  }
		
		private function setFlvMaterilal(obj:DisplayObject3D, path:String):void {
			var connect:NetConnection = new NetConnection();
			connect.connect(null);
			var stream:NetStream = new NetStream(connect);
			
			var video:Video = new Video();
			video.attachNetStream(stream);
			stream.play(path);
		  stream.client = { };
			
			var material:VideoStreamMaterial = new VideoStreamMaterial(video, stream);
			material.precise = true;
			material.doubleSided = true;
			
			obj.material = material;
		}
	
		
		
	}
	
	
	
}