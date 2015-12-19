package org.mineap.NNDD.model
{

	/**
	 * SearchItem.as<br>
	 * SearchItemクラスは、検索条件を保持するクラスです。<br>
	 * <br>
	 * Copyright (c) 2009 MAP - MineApplicationProject. All Rights Reserved.
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class SearchItem
	{
		
		/**
		 * 検索条件名
		 */
		public var name:String = "検索条件";
		
		/**
		 * 検索結果のソート種別
		 */
		public var sortType:int = SearchSortType.NICO_SEARCH_SORT_TEXT[0];
		
		/**
		 * 検索の種別（キーワード、タグ）
		 */
		public var searchType:int = SearchType.NICO_SEARCH_TYPE_TEXT[0];
		
		/**
		 * 検索対象文字列
		 */
		public var searchWord:String = "";
		
		/**
		 * この検索項目がディレクトリを表すかどうか
		 */
		public var isDir:Boolean = false;
		
		/**
		 * コンストラクタ<br>
		 * @param name
		 * @param sortType
		 * @param searchType
		 * @param searchWord
		 * @param isDir
		 * 
		 */
		public function SearchItem(name:String, sortType:int, searchType:int, searchWord:String, isDir:Boolean = false)
		{
			this.name = name;
			this.sortType = sortType;
			this.searchType = searchType;
			this.searchWord = searchWord;
			this.isDir = isDir;
		}
	}
}