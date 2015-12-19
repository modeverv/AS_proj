package jp.fores.foresmessenger.renderer
{
	import jp.fores.foresmessenger.dto.ConfigDto;
	import jp.fores.foresmessenger.dto.UserInfoDto;
	import jp.fores.foresmessenger.manager.MessengerManager;
	
	import mx.controls.dataGridClasses.DataGridItemRenderer;
	
	/**
	 * ログイン中の利用者一覧のデータグリッド用のアイテムレンダラー。
	 */
	public class LoginUserDataGridItemRenderer extends DataGridItemRenderer
	{
		//==========================================================
		//フィールド
		
		/**
		 * 自分自身の色
		 * (デフォルト値は赤)
		 */
		public var selfColor :uint = 0xFF0000;
		
		/**
		 * 同じグループの色
		 * (デフォルト値は青)
		 */
		public var groupColor :uint = 0x0000FF;
		
		/**
		 * デフォルトの色
		 * (デフォルト値は黒)
		 */
		public var defaultColor :uint = 0x000000;
		
		
		//==========================================================
		//メソッド

		/**
		 * dataのSetterをオーバーライドします。
		 * 
		 * @param value 値
		 */
		override public function set data(value: Object) :void 
		{
			//==========================================================
			//親クラスの処理を先に呼び出す
			//(これを忘れるとひどいことになるので注意)
			super.data = value;
		
		
			//==========================================================
			//有効なデータかどうかチェック
		
			//データが存在しない場合
			//(このチェックを入れておかないとNullPointerでエラーになることがある)
			if(super.data == null)
			{
				//以降の処理を行わない
				return;
			}
		
			//データが想定している型と異なる場合
			//(データグリッド全体にレンダラーを適用する場合はヘッダ行も対象となるので、このチェックによってヘッダ行を対象から除外する必要がある)
			if(!(super.data is UserInfoDto))
			{
				//以降の処理を行わない
				return;
			}
		
		
			//==========================================================
			//データの内容に応じて処理を切り替える
		
			//データを実際の型にキャスト
			var userInfo :UserInfoDto = super.data as UserInfoDto;
		
			//メッセンジャーのメインの管理クラスのインスタンスを取得
			var messengerManager :MessengerManager = MessengerManager.getInstance();

			//メッセンジャーのメインの管理クラスから設定情報用DTOを取得
			var configDto :ConfigDto = messengerManager.configDto;
			
			//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
			//文字色の設定

			//新しい文字色
			var newColor :uint = 0;

			//ログイン中の利用者情報と利用者IDが一致する場合
			if(userInfo.userID == messengerManager.selfUserInfo.userID)
			{
				//自分自身の色に変える
				newColor = configDto.selfUserColor;
			}
			//ログイン中の利用者情報とグループ名が一致する場合
			else if(userInfo.groupName == messengerManager.selfUserInfo.groupName)
			{
				//同じグループの色に変える
				newColor = configDto.selfGroupColor;
			}
			//それ以外の場合
			else
			{
				//別ののグループの色に変える
				newColor = configDto.otherGroupColor;
			}
			
			//文字色を変更
			setStyle("color", newColor);
			
			
			//_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
			//アルファ値の設定
			
			//新しいアルファ値
			//(基本は透明にしないので1.0)
			var newAlpha :Number = 1.0;

			//設定情報の長時間音沙汰が無い人の表示を徐々に透明にしていくかどうかのフラグがたっていて、かつログイン中の利用者情報と利用者IDが一致しない場合
			//(自分自身のユーザーの情報はアルファ値を変更しない)
			if(configDto.isIdleDisplayTransparent && (userInfo.userID != messengerManager.selfUserInfo.userID))
			{
				//利用者情報のアイドル秒数を取得
				var idleSecond :Number = userInfo.idleSecond;
				
				//アイドル時間が5分(300秒)以上の場合のみ処理を行う
				//(5分未満の場合は無視し、5分を過ぎてから徐々に透明になっていくようにする)
				if(idleSecond >= 300)
				{
					//設定情報の完全に音沙汰が無くなったとみなす時間を分単位から秒単位に変換
					var idleMaxDurationSecond :uint = configDto.idleDisplayMaxDuration * 60;
					
					//それぞれの時間から5分の分を引く
					idleSecond -= 300;
					idleMaxDurationSecond -= 300;
					
					//利用者情報のアイドル時間が完全に音沙汰が無くなったとみなす時間以上の場合
					if(idleSecond >= idleMaxDurationSecond)
					{
						//新しいアルファ値に設定情報の完全に音沙汰が無くなったときのアルファ値を設定
						newAlpha = configDto.idleDisplayAlpha;
					}
					//それ以外の場合
					//(5分　<= アイドル時間 <= 完全に音沙汰が無くなったとみなす時間 の場合)
					else
					{
						//新しいアルファ値を計算
						//(完全に音沙汰が無くなったときのアルファ値 + (1 - (アイドル時間 / 上限) * (1 - 完全に音沙汰が無くなったときのアルファ値))
						newAlpha = configDto.idleDisplayAlpha + (1 - (idleSecond / idleMaxDurationSecond)) * (1 - configDto.idleDisplayAlpha)
					}
				}
			}

			//アルファ値を変更
			this.alpha = newAlpha;
		}

	}
}