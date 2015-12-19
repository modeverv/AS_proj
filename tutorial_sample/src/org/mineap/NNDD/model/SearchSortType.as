package org.mineap.NNDD.model
{
	/**
	 * SearchSortType.as<br>
	 * SearchSortTypeクラスは、検索結果のソート順に関する定数を保持するクラスです。<br>
	 * <br>
	 * Copyright (c) 2009 MAP - MineApplicationProject. All Rights Reserved.<br>
	 *  
	 * @author shiraminekeisuke
	 * 
	 */
	public class SearchSortType
	{
		
		/**
		 * 投稿が新しい順です
		 */
		public static const NEW:int = 0;
		/**
		 * 投稿が古い順です
		 */
		public static const OLD:int = 1;
		/**
		 * 再生数が多い順です
		 */
		public static const PLAY_COUNT_ASCENDING:int = 2;
		/**
		 * 再生数が少ない順です
		 */
		public static const PLAY_COUNT_DESCENDING:int = 3;
		/**
		 * コメントが新しい順です
		 */
		public static const COMMENT_NEW:int = 4;
		/**
		 * コメントが古い順です
		 */
		public static const COMMENT_OLD:int = 5;
		/**
		 * コメントが多い順です
		 */
		public static const COMMENT_COUNT_ASCENDING:int = 6;
		/**
		 * コメントが少ない順です
		 */
		public static const COMMENT_COUNT_DESCENDING:int = 7;
		/**
		 * マイリストが多い順です
		 */
		public static const MYLIST_COUNT_MANY:int = 8;
		/**
		 * マイリストが少ない順です
		 */
		public static const MYLIST_COUNT_FEW:int = 9;
		/**
		 * 再生時間が長い順です
		 */
		public static const PLAY_TIME_LONG:int = 10;
		/**
		 * 再生時間が短い順です
		 */
		public static const PLAY_TIME_SHORT:int = 11;
		
		/**
		 * 検索結果のソート順の文字列表現です
		 */
		public static const NICO_SEARCH_SORT_TEXT:Array = new Array(
			"投稿が新しい順","投稿が古い順","再生が多い順","再生が少ない順","コメントが新しい順","コメントが古い順","コメントが多い順","コメントが少ない順","マイリストが多い順","マイリストが少ない順","再生時間が長い順","再生時間が短い順"
		);
		
		public function SearchSortType()
		{
		}
	}
}