package org.mineap.NNDD.util
{
	/**
	 * NicoPattern.as
	 * 
	 * Copyright (c) 2008-2009 MAP - MineApplicationProject. All Rights Reserved.
	 *  
	 * @author shiraminekeisuke
	 */
	public class NicoPattern
	{
		
		/**
		 * ランキングから動画のURLとタイトルを抽出する正規表現です。
		 * <a class="video" href="watch/sm6124961">アホな女達の自動車事故、アクシデント集</a>
		 */
		public static var rankingVideoPattern:RegExp = new RegExp("<a class=\"video\" href=\"(watch/[^\"]*)\">([^\<]*)</a>", "ig");
		
		/**
		 * ランキングからカテゴリを抽出する正規表現です。
		 * <a class="tab_a1" href="http://www.nicovideo.jp/ranking/mylist/daily/music"><div>音楽</div></a> 
		 */
		public static var rankingCategoryPattern:RegExp = new RegExp("<a class=\"tab_..\" href=\"http://www.nicovideo.jp/ranking/\\w+/\\w+/([^\"]*)\"><div>([^<]*)</div></a>", "ig");
		
		/**
		 * 検索結果からビデオのURLを抽出する正規表現です。
		 * <a href="watch/sm9069324" class="watch"><span class="vinfo_title">【東方文花帖】禁忌「禁じられた遊び」【EX-2】</span></a>
		 */
		public static var searchVideoUrlAndTitlePattern:RegExp = new RegExp(".*<a href=\"(.*)\" class=\"watch\"><span class=\"vinfo_title\">(.*)</span></a>.*","ig");
		
		/**
		 * 検索結果から次ページへのリンクを抽出する正規表現です。
		 */
		public static var searchPageLinkPattern:RegExp = new RegExp("<a href=\"(http://www.nicovideo.jp/[^/]+/[^\"]*)\">(\\d*)</a>[^</a>]*","ig");
		
		/**
		 * 検索結果から現在のページ番号を抽出する正規表現です。
		 * <span class="in">1</span>
		 */
		public static var searchNowPagePattern:RegExp = new RegExp("<span class=\"in\">(\\d+)</span>", "ig");
		
		/**
		 * マイリストの取得結果の中からサムネイル画像のURLを抽出する正規表現です。
		 */
		public static var myListThumbImgUrlPattern:RegExp = new RegExp("src=\"(http://tn-[^\"]*)\"");
		
		/**
		 * マイリストの取得結果の中からメモを抽出する正規表現です。
		 */
		public static var myListMemoPattern:RegExp = new RegExp("<p class=\"nico-memo\">([^<]*)</p>");
		
		/**
		 * マイリストの取得結果の中から投稿日を抽出する正規表現です
		 * <strong class="nico-info-date">2008年09月03日 19：35：42</strong>
		 */
		public static var myListInfoDate:RegExp = new RegExp("<strong class=\"nico-info-date\">([^<]+)</strong>");
		
		/**
		 * マイリストの取得結果の中から動画の再生時間を抽出する正規表現です。
		 * <strong class="nico-info-length">5:39</strong>
		 */
		public static var myListLength:RegExp = new RegExp("<strong class=\"nico-info-length\">([^<]+)</strong>");
		
		
		public function NicoPattern()
		{
			/* nothing */
		}

	}
}