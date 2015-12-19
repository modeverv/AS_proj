package jp.fores.common.assets
{
	/**
	 * アセット管理用の定数クラス
	 */
	public class AssetsConstant
	{
		//==========================================================
		//最小化ボタン

		[Embed(source="WindowMinButton.gif")]
		public static const WINDOW_MIN_BUTTON_1 :Class;

		[Embed(source="WindowMinButton2.gif")]
		public static const WINDOW_MIN_BUTTON_2 :Class;

		
		//==========================================================
		//最大化ボタン

		[Embed(source="WindowMaxButton.gif")]
		public static const WINDOW_MAX_BUTTON_1 :Class;

		[Embed(source="WindowMaxButton2.gif")]
		public static const WINDOW_MAX_BUTTON_2 :Class;

		
		//==========================================================
		//閉じるボタン

		[Embed(source="WindowCloseButton.gif")]
		public static const WINDOW_CLOSE_BUTTON_1 :Class;

		[Embed(source="WindowCloseButton2.gif")]
		public static const WINDOW_CLOSE_BUTTON_2 :Class;
		
		
		//==========================================================
		//Panel用

		[Embed(source="panelCloseButton.png")]
		public static const PANEL_CLOSE_BUTTON :Class;


		//==========================================================
		//TabNavigator用

		[Embed (source="tabNavigatorAssets.swf", symbol="indicator")]
		public static const TAB_NAVIGATOR_INDICATOR :Class;

		[Embed (source="tabNavigatorAssets.swf", symbol="firefox_close_up")]
		public static const TAB_NAVIGATOR_CLOSE_UP :Class;

		[Embed (source="tabNavigatorAssets.swf", symbol="firefox_close_over")]
		public static const TAB_NAVIGATOR_CLOSE_OVER :Class;

		[Embed (source="tabNavigatorAssets.swf", symbol="firefox_close_down")]
		public static const TAB_NAVIGATOR_CLOSE_DOWN :Class;

		[Embed (source="tabNavigatorAssets.swf", symbol="firefox_close_disabled")]
		public static const TAB_NAVIGATOR_CLOSE_DISABLED :Class;

		[Embed (source="tabNavigatorAssets.swf", symbol="left_arrow")]
		public static const TAB_NAVIGATOR_LEFT_BUTTON :Class;

		[Embed (source="tabNavigatorAssets.swf", symbol="right_arrow")]
		public static const TAB_NAVIGATOR_RIGHT_BUTTON :Class;
		

		//==========================================================
		//ResizeWindow用

		[Embed(source="verticalSize.gif")]
		public static const RESIZE_WINDOW_VERTICAL_SIZE :Class;

		[Embed(source="horizontalSize.gif")]
		public static const RESIZE_WINDOW_HORIZONTAL_SIZE :Class;

		[Embed(source="leftObliqueSize.gif")]
		public static const RESIZE_WINDOW_LEFT_OBLIQUE_SIZE :Class;

		[Embed(source="rightObliqueSize.gif")]
		public static const RESIZE_WINDOW_RIGHT_OBLIQUE_SIZE :Class;


		//==========================================================
		//検索アイコン
		
		[@Embed("searchIcon.png")]
		public static const SEARCH_ICON: Class;
		
	}
}