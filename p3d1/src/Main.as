package
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;

	import org.papervision3d.cameras.*;
	import org.papervision3d.materials.*;
	import org.papervision3d.objects.*;
	import org.papervision3d.objects.primitives.*
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;
	
    [SWF(width = "450", height = "300", frameRate = "60", backgroundColor = "#000000")]
	
	public class Main extends MovieClip
	{	
		static private const PARTICLE_ROUND   :int = 1000;
		static private const PARTICLE_AMOUNT  :int = 100;

		private var camera:Camera3D;
		private var vp:Viewport3D;
		private var render:BasicRenderEngine
		private var scene:Scene3D;
		
		private var wrap:DisplayObject3D;

		public function Main()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align     = StageAlign.TOP_LEFT;
			stage.quality   = StageQuality.LOW;
	
			scene  = new Scene3D();
			camera = new Camera3D(60, 10, 5000, false, false);
			render = new BasicRenderEngine();
			vp     = new Viewport3D(0, 0, true, false);
			addChild(vp);
			
			//camera
			camera.focus = 500;
			camera.zoom = 1;
			camera.z = -1500;
			
			wrap = new DisplayObject3D();
			scene.addChild(wrap);

			for (var i:int = 0; i < PARTICLE_AMOUNT; i++)
			{
				var material:MovieMaterial = new MovieMaterial(createParticle(), true);
                material.doubleSided = true;
				
                var plane:Plane = new Plane(material, 50, 50, 2, 2);
				
				plane.x = Math.random() * PARTICLE_ROUND - PARTICLE_ROUND / 2;
				plane.y = Math.random() * PARTICLE_ROUND - PARTICLE_ROUND / 2;
				plane.z = Math.random() * PARTICLE_ROUND - PARTICLE_ROUND / 2;
				plane.rotationY = Math.random() * 360;
				
				wrap.addChild(plane);
			}
			
			this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		/**
		 * Render
		 * @param	event
		 */
		private function enterFrameHandler(event:Event):void
		{
			wrap.yaw(1);
			render.renderScene(scene, camera, vp);
		}
	
		/**
		* Create Particle Method
		* @param event
		* @return MovieClip Instance include Text Field
		*/        
		private function createParticle():MovieClip
		{
			var mc:MovieClip = new MovieClip();

			// Create Text Field
			var fmt:TextFormat=new TextFormat();
			fmt.size  = 32;
			fmt.align = TextFormatAlign.LEFT;
			fmt.color = 0xffffff;

			// Random Charcode 
			var charCode:uint = (Math.random() * 25) | 0 + 65;

			// addText
			var tf:TextField = new TextField();
			tf.defaultTextFormat = fmt;
			tf.text = String.fromCharCode(charCode);
			tf.selectable = false;
			tf.x = tf.textWidth;
			tf.y = tf.textHeight;

			mc.addChild(tf);
			mc.scaleX = mc.scaleY = Math.random();
			
			return mc;
		}
	}
}