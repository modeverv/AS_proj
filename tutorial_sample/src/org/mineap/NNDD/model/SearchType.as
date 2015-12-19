package org.mineap.NNDD.model
{
	/**
	 * SearchType.as<br>
	 * SearchTypeクラスは、検索種別を表す定数を保持するクラスです。<br>
	 * <br>
	 * Copyright (c) 2009 MAP - MineApplicationProject. All Rights Reserved.<br>
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class SearchType
	{
		/**
		 * 検索種別がキーワードである事を表す定数です
		 */
		public static const KEY_WORD:int = 0;
		/**
		 * 検索種別がタグによる検索である事を表す定数です
		 */
		public static const TAG:int = 1;
		
		/**
		 * 検索種別の文字列表現です
		 */
		public static const NICO_SEARCH_TYPE_TEXT:Array = new Array(
			"キーワード", "タグ"//, "タグを"
		);
		
		public function SearchType()
		{
		}
	}
}