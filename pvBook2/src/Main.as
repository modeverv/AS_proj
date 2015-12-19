package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import caurina.transitions.*;//tweener
	import org.papervision3d.materials.special.Letter3DMaterial;
	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.typography.fonts.HelveticaBold;
	import org.papervision3d.typography.Text3D;
	import org.papervision3d.view.BasicView;
	import flash.utils.*;
	
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
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);

			// entry point
			for (var i:int = 0; i < 400; i++) {
				var material :WireframeMaterial = new WireframeMaterial(0xFFFFFF * Math.random());
				material.doubleSided = true;
				var plane:Plane = new Plane(material, 200, 200);
				scene.addChild(plane);
				plane.x = Math.floor(i / 20 -10) * 400;//yoko
				plane.z = (i % 20 -10) * 400;//okuyuki
				plane.y = Math.random() * 300;//takasa
				plane.rotationX = 90;
			}
			
			startRendering();
			
			Tweener.addTween(camera, {
				x:0, y:5000, z: -5000,//mokuhyou
			time:1, delay:0, transition:"easeInOutExpo" } );
			
			Tweener.addTween(camera, {
				x: -5000, y:2000, z:5000,
				time:3,
				delay:0.5,
				transition:"easeInOutExpo",
			  onComplete:function():void{
			     var matL:Letter3DMaterial = new Letter3DMaterial(0x006699);
			     matL.doubleSided = true;
			     // make vector text
			     var font:HelveticaBold = new HelveticaBold();
			     // object3D
			     var word:Text3D = new Text3D('Papervision3D Tweener', font, matL);
			     scene.addChild(word);
			     addEventListener(Event.ENTER_FRAME, function():void {
				   camera.x = 500 * Math.sin(getTimer() / 1000);
				   camera.z = 500 * Math.cos(getTimer() / 1000);
				   camera.y = 500 * Math.sin(getTimer() / 1000);
				   });
				 }
			 });
		}
	}
}