/**
 * Czech Translations
 * Translated by TomÃ¡Å¡ KorÄÃ¡k (72)
 * 2008/02/08 18:02, Ext-2.0.1
 */

Ext.UpdateManager.defaults.indicatorText = '<div class="loading-indicator">ProsÃ­m Äekejte...</div>';

if(Ext.View){
   Ext.View.prototype.emptyText = "";
}

if(Ext.grid.Grid){
   Ext.grid.Grid.prototype.ddText = "{0} vybranÃ½ch Å™Ã¡dkÅ¯";
}

if(Ext.TabPanelItem){
   Ext.TabPanelItem.prototype.closeText = "ZavÅ™Ã­t zÃ¡loÅ¾ku";
}

if(Ext.form.Field){
   Ext.form.Field.prototype.invalidText = "Hodnota v tomto poli je neplatnÃ¡";
}

if(Ext.LoadMask){
    Ext.LoadMask.prototype.msg = "ProsÃ­m Äekejte...";
}

Date.monthNames = [
   "Leden",
   "Ãšnor",
   "BÅ™ezen",
   "Duben",
   "KvÄ›ten",
   "ÄŒerven",
   "ÄŒervenec",
   "Srpen",
   "ZÃ¡Å™Ã­",
   "Å˜Ã­jen",
   "Listopad",
   "Prosinec"
];

Date.getShortMonthName = function(month) {
  return Date.monthNames[month].substring(0, 3);
};

Date.monthNumbers = {
  Jan : 0,
  Feb : 1,
  Mar : 2,
  Apr : 3,
  May : 4,
  Jun : 5,
  Jul : 6,
  Aug : 7,
  Sep : 8,
  Oct : 9,
  Nov : 10,
  Dec : 11
};

Date.getMonthNumber = function(name) {
  return Date.monthNumbers[name.substring(0, 1).toUpperCase() + name.substring(1, 3).toLowerCase()];
};

Date.dayNames = [
   "NedÄ›le",
   "PondÄ›lÃ­",
   "ÃšterÃ½",
   "StÅ™eda",
   "ÄŒtvrtek",
   "PÃ¡tek",
   "Sobota"
];

Date.getShortDayName = function(day) {
  return Date.dayNames[day].substring(0, 3);
};

if(Ext.MessageBox){
   Ext.MessageBox.buttonText = {
      ok     : "OK",
      cancel : "Storno",
      yes    : "Ano",
      no     : "Ne"
   };
}

if(Ext.util.Format){
   Ext.util.Format.date = function(v, format){
      if(!v) return "";
      if(!(v instanceof Date)) v = new Date(Date.parse(v));
      return v.dateFormat(format || "d.m.Y");
   };
}

if(Ext.DatePicker){
   Ext.apply(Ext.DatePicker.prototype, {
      todayText         : "Dnes",
      minText           : "Datum nesmÃ­ bÃ½t starÅ¡Ã­ neÅ¾ je minimÃ¡lnÃ­",
      maxText           : "Datum nesmÃ­ bÃ½t dÅ™Ã­vÄ›jÅ¡Ã­ neÅ¾ je maximÃ¡lnÃ­",
      disabledDaysText  : "",
      disabledDatesText : "",
      monthNames	: Date.monthNames,
      dayNames		: Date.dayNames,
      nextText          : 'NÃ¡sledujÃ­cÃ­ mÄ›sÃ­c (Control+Right)',
      prevText          : 'PÅ™edchÃ¡zejÃ­cÃ­ mÄ›sÃ­c (Control+Left)',
      monthYearText     : 'Zvolte mÄ›sÃ­c (ke zmÄ›nÄ› let pouÅ¾ijte Control+Up/Down)',
      todayTip          : "{0} (Spacebar)",
      format            : "d.m.Y",
      okText            : "&#160;OK&#160;",
      cancelText        : "Storno",
      startDay          : 1
   });
}

if(Ext.PagingToolbar){
   Ext.apply(Ext.PagingToolbar.prototype, {
      beforePageText : "Strana",
      afterPageText  : "z {0}",
      firstText      : "PrvnÃ­ strana",
      prevText       : "PÅ™echÃ¡zejÃ­cÃ­ strana",
      nextText       : "NÃ¡sledujÃ­cÃ­ strana",
      lastText       : "PoslednÃ­ strana",
      refreshText    : "Aktualizovat",
      displayMsg     : "Zobrazeno {0} - {1} z celkovÃ½ch {2}",
      emptyMsg       : 'Å½Ã¡dnÃ© zÃ¡znamy nebyly nalezeny'
   });
}

if(Ext.form.TextField){
   Ext.apply(Ext.form.TextField.prototype, {
      minLengthText : "Pole nesmÃ­ mÃ­t mÃ©nÄ› {0} znakÅ¯",
      maxLengthText : "Pole nesmÃ­ bÃ½t delÅ¡Ã­ neÅ¾ {0} znakÅ¯",
      blankText     : "This field is required",
      regexText     : "",
      emptyText     : null
   });
}

if(Ext.form.NumberField){
   Ext.apply(Ext.form.NumberField.prototype, {
      minText : "Hodnota v tomto poli nesmÃ­ bÃ½t menÅ¡Ã­ neÅ¾ {0}",
      maxText : "Hodnota v tomto poli nesmÃ­ bÃ½t vÄ›tÅ¡Ã­ neÅ¾ {0}",
      nanText : "{0} nenÃ­ platnÃ© ÄÃ­slo"
   });
}

if(Ext.form.DateField){
   Ext.apply(Ext.form.DateField.prototype, {
      disabledDaysText  : "NeaktivnÃ­",
      disabledDatesText : "NeaktivnÃ­",
      minText           : "Datum v tomto poli nesmÃ­ bÃ½t starÅ¡Ã­ neÅ¾ {0}",
      maxText           : "Datum v tomto poli nesmÃ­ bÃ½t novÄ›jÅ¡Ã­ neÅ¾ {0}",
      invalidText       : "{0} nenÃ­ platnÃ½m datem - zkontrolujte zda-li je ve formÃ¡tu {1}",
      format            : "d.m.Y",
      altFormats        : "d/m/Y|d-m-y|d-m-Y|d/m|d-m|dm|dmy|dmY|d|Y-m-d"
   });
}

if(Ext.form.ComboBox){
   Ext.apply(Ext.form.ComboBox.prototype, {
      loadingText       : "ProsÃ­m Äekejte...",
      valueNotFoundText : undefined
   });
}

if(Ext.form.VTypes){
   Ext.apply(Ext.form.VTypes, {
      emailText    : 'V tomto poli mÅ¯Å¾e bÃ½t vyplnÄ›na pouze emailovÃ¡ adresa ve formÃ¡tu "uÅ¾ivatel@domÃ©na.cz"',
      urlText      : 'V tomto poli mÅ¯Å¾e bÃ½t vyplnÄ›na pouze URL (adresa internetovÃ© strÃ¡nky) ve formÃ¡tu "http:/'+'/www.domÃ©na.cz"',
      alphaText    : 'Toto pole mÅ¯Å¾e obsahovat pouze pÃ­smena abecedy a znak _',
      alphanumText : 'Toto pole mÅ¯Å¾e obsahovat pouze pÃ­smena abecedy, ÄÃ­sla a znak _'
   });
}

if(Ext.form.HtmlEditor){
  Ext.apply(Ext.form.HtmlEditor.prototype, {
    createLinkText : 'Zadejte URL adresu odkazu:',
    buttonTips : {
      bold : {
        title: 'TuÄnÃ© (Ctrl+B)',
        text: 'OznaÄÃ­ vybranÃ½ text tuÄnÄ›.',
        cls: 'x-html-editor-tip'
      },
      italic : {
        title: 'KurzÃ­va (Ctrl+I)',
        text: 'OznaÄÃ­ vybranÃ½ text kurzÃ­vou.',
        cls: 'x-html-editor-tip'
      },
      underline : {
        title: 'PodtrÅ¾enÃ­ (Ctrl+U)',
        text: 'Podtrhne vybranÃ½ text.',
        cls: 'x-html-editor-tip'
      },
      increasefontsize : {
        title: 'ZvÄ›tÅ¡it pÃ­smo',
        text: 'ZvÄ›tÅ¡Ã­ velikost pÃ­sma.',
        cls: 'x-html-editor-tip'
      },
      decreasefontsize : {
        title: 'ZÃºÅ¾it pÃ­smo',
        text: 'ZmenÅ¡Ã­ velikost pÃ­sma.',
        cls: 'x-html-editor-tip'
      },
      backcolor : {
        title: 'Barva zvÃ½raznÄ›nÃ­ textu',
        text: 'OznaÄÃ­ vybranÃ½ text tak, aby vypadal jako oznaÄenÃ½ zvÃ½razÅˆovaÄem.',
        cls: 'x-html-editor-tip'
      },
      forecolor : {
        title: 'Barva pÃ­sma',
        text: 'ZmÄ›nÃ­ barvu textu.',
        cls: 'x-html-editor-tip'
      },
      justifyleft : {
        title: 'Zarovnat text vlevo',
        text: 'ZarovnÃ¡ text doleva.',
        cls: 'x-html-editor-tip'
      },
      justifycenter : {
        title: 'Zarovnat na stÅ™ed',
        text: 'ZarovnÃ¡ text na stÅ™ed.',
        cls: 'x-html-editor-tip'
      },
      justifyright : {
        title: 'Zarovnat text vpravo',
        text: 'ZarovnÃ¡ text doprava.',
        cls: 'x-html-editor-tip'
      },
      insertunorderedlist : {
        title: 'OdrÃ¡Å¾ky',
        text: 'ZaÄne seznam s odrÃ¡Å¾kami.',
        cls: 'x-html-editor-tip'
      },
      insertorderedlist : {
        title: 'ÄŒÃ­slovÃ¡nÃ­',
        text: 'ZaÄne ÄÃ­slovanÃ½ seznam.',
        cls: 'x-html-editor-tip'
      },
      createlink : {
        title: 'InternetovÃ½ odkaz',
        text: 'Z vybranÃ©ho textu vytvoÅ™Ã­ internetovÃ½ odkaz.',
        cls: 'x-html-editor-tip'
      },
      sourceedit : {
        title: 'ZdrojovÃ½ kÃ³d',
        text: 'PÅ™epne do mÃ³du Ãºpravy zdrojovÃ©ho kÃ³du.',
        cls: 'x-html-editor-tip'
      }
    }
  });
}

if(Ext.grid.GridView){
   Ext.apply(Ext.grid.GridView.prototype, {
      sortAscText  : "Å˜adit vzestupnÄ›",
      sortDescText : "Å˜adit sestupnÄ›",
      lockText     : "Ukotvit sloupec",
      unlockText   : "Uvolnit sloupec",
      columnsText  : "Sloupce"
   });
}

if(Ext.grid.GroupingView){
  Ext.apply(Ext.grid.GroupingView.prototype, {
    emptyGroupText : '(Å½Ã¡dnÃ¡ data)',
    groupByText    : 'Seskupit dle tohoto pole',
    showGroupsText : 'Zobrazit ve skupinÄ›'
  });
}

if(Ext.grid.PropertyColumnModel){
   Ext.apply(Ext.grid.PropertyColumnModel.prototype, {
      nameText   : "NÃ¡zev",
      valueText  : "Hodnota",
      dateFormat : "j.m.Y"
   });
}

if(Ext.layout.BorderLayout.SplitRegion){
   Ext.apply(Ext.layout.BorderLayout.SplitRegion.prototype, {
      splitTip            : "Tahem zmÄ›nit velikost.",
      collapsibleSplitTip : "Tahem zmÄ›nit velikost. Dvojklikem skrÃ½t."
   });
}
