/**
* ...
* @author Martin Legris ( http://blog.martinlegris.com )
* @version 0.1
*/

package ca.newcommerce.youtube.data
{	
	public class RatingData
	{
		protected var _data:Object;
		
		public function RatingData(data:Object)
		{
			_data = data;

			//エラーになることがあるので仮対処
			if (_data == null) {
				_data = new Object();
				_data.min = 0;
				_data.max = 0;
				_data.numRaters = 0;
				_data.average = 0;
			}
		}
		
		public function get min():Number
		{
			return parseInt(_data.min);
		}
		
		public function get max():Number
		{
			return parseInt(_data.max);
		}
		
		public function get numRaters():Number
		{
			return parseInt(_data.numRaters);
		}
		
		public function get average():Number
		{
			return parseInt(_data.average);
		}
	}
}
