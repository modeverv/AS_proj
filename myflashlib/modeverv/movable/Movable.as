package modeverv.movable {
	import modeverv.Obj;
	
	public class Movable extends Obj {
		public var vx:Number = 0;
		public var vy:Number = 0;
		public var ax:Number = 0;
		public var ay:Number = 0;
		
		public function Movable(_vx:Number = 10, _vy:Number = 10, c:uint = 0xffffff) {
			super(c);
			this.vx = _vx;
			this.vy = _vy;
		}
		
		public function move():void {
			this.x += vx;
			this.y += vy;
		}
		
		public function axelle(xdegree:Number = 0 , ydegree:Number = 0):void {
			this.vx *= 1.0 + xdegree; 
			this.vy *= 1.0 + ydegree;
		}
		
		public function fliction(f:Number):void {
			vx *= f;
			vy *= f;
		}
		
		public function gravity(gx:Number, gy:Number):void {
			vx += gx;
			vy += gy;
		}
	}
}