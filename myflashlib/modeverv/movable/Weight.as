package modeverv.movable 
{
	/**
	 * ...
	 * @author modeverv
	 */
	public class Weight extends Movable
	{
		public var mass:Number;

		public function Weight(mass:Number=10,_vx:Number = 10, _vy:Number = 10, c:uint = 0xffffff)
		{
			super(_vx, _vy, c);
			this.mass = mass;
		}		
		
	}

}