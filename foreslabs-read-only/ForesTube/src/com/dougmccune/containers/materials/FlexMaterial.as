package com.dougmccune.containers.materials
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	import mx.core.Container;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import org.papervision3d.materials.MovieMaterial;

	public class FlexMaterial extends MovieMaterial
	{
		public function FlexMaterial(movieAsset:DisplayObject=null, transparent:Boolean=true)
		{
			if(movieAsset is UIComponent) {
				addUpdateListeners(UIComponent(movieAsset));
			}
			
			super(movieAsset, transparent, false);	
		}
		
		private function addUpdateListeners(component:UIComponent):void {
			component.addEventListener(FlexEvent.UPDATE_COMPLETE, handleUpdateComplete, false, 10, true);
			
			if(component is Container) {
				var n:int = Container(component).numChildren;
				
				for(var i:int=0; i<n; i++) {
					var child:DisplayObject = component.getChildAt(i);
					
					if(child is UIComponent) {
						addUpdateListeners(UIComponent(child));
					}
				}
			}
		}
		
		override public function drawBitmap():void
		{
			bitmap.fillRect( bitmap.rect, this.fillColor );

			var mtx:Matrix = new Matrix();
			mtx.scale( movie.scaleX, movie.scaleY );

			bitmap.draw( movie, mtx, movie.transform.colorTransform );
		}
		
		private function handleUpdateComplete(event:Event):void {
			if(bitmap)
			{
				//==========================================================
				//元ネタではそのままupdateBitmap()を呼んでいたが、
				//それだとViewStackの裏側に表示する場合にエラーが大量に発生するので、
				//なるべくチェックをかけたあとtry-catchでエラーをもみ消す
				//==========================================================
				
				//イベントの発生元のコンテナを取得
				var container :Container = event.currentTarget as Container;
				
				//取得したコンテナがnullでなく、初期化が完了している場合のみ処理を行う
				if((container != null) && container.initialized)
				{
					//どうしようもないので、try-catchでエラーをもみ消す
					try
					{
						//親のビットマップの更新処理を呼び出す
						super.updateBitmap();
					}
					catch(e :Error)
					{
					}
				}
			}
		}
		
	}
}