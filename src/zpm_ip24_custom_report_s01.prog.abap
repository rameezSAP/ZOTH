*&---------------------------------------------------------------------*
*& Include          ZFI_VOID_CHECK_REGISTER_S01
*&---------------------------------------------------------------------*
*-------------------------------------------------------------------*
* Datenbanktabellen                                                 *
*-------------------------------------------------------------------*
TABLES: VIMHIO,
        VIMHIO_IFLOS,
        RIHMHIO,
        MPLA,
        RMIPM,
        EQKT,
        IFLOTX,
        ILOA,
        CRHD,
        IFLOS.
*-------------------------------------------------------------------*
* ATAB-Tabellen                                                     *
*-------------------------------------------------------------------*
TABLES: T370A.

*####################################################################*
* Selektionsbild                                                     *
*####################################################################*
SELECTION-SCREEN BEGIN OF BLOCK RIMHIO00_1 WITH FRAME TITLE TEXT-F01.
  SELECT-OPTIONS:
  MITYP      FOR    RMIPM-MPTYP                                        ,
  PLANSORT   FOR     VIMHIO-PLAN_SORT                                  ,
  WARPL      FOR    RIHMHIO-WARPL      MATCHCODE OBJECT MPLA           ,
  WAPOS      FOR     VIMHIO-WAPOS                                      ,
  WSTRA      FOR     VIMHIO-WSTRA      MODIF ID TUT                    ,
  PSTXT      FOR     VIMHIO-PSTXT                                      ,
  TPLNR      FOR     VIMHIO-TPLNR      NO-DISPLAY                      ,
  STRNO      FOR      IFLOS-STRNO      MATCHCODE OBJECT IFLM           ,
  EQUNR      FOR     VIMHIO-EQUNR      MATCHCODE OBJECT EQUI           ,
  BAUTL      FOR    RIHMHIO-BAUTL      MATCHCODE OBJECT MAT1           ,
  SERMAT     FOR     VIMHIO-SERMAT     MATCHCODE OBJECT MAT1           ,
  SERIALNR   FOR     VIMHIO-SERIALNR                                   .
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(31) TEXT-A00.
    PARAMETERS ABREA  RADIOBUTTON GROUP ABRE DEFAULT 'X'.
*SELECTION-SCREEN COMMENT 35(22) text-a01.                      "N744242
    SELECTION-SCREEN COMMENT 35(22) TEXT-A01 FOR FIELD ABREA. "N744242
    PARAMETERS ABREM  RADIOBUTTON GROUP ABRE.
*SELECTION-SCREEN COMMENT 60(08) text-a02.                      "N744242
    SELECTION-SCREEN COMMENT 60(08) TEXT-A02 FOR FIELD ABREM. "N744242
    PARAMETERS ABREO  RADIOBUTTON GROUP ABRE.
*SELECTION-SCREEN COMMENT 71(09) text-a03.                      "N744242
    SELECTION-SCREEN COMMENT 71(09) TEXT-A03 FOR FIELD ABREO. "N744242
  SELECTION-SCREEN END OF LINE.
  PARAMETERS: OBLIS AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK RIMHIO00_1.
*--- Select-Options für MHIO Segment ---------------------------------
SELECTION-SCREEN BEGIN OF BLOCK RIMHIO00_11 WITH FRAME TITLE TEXT-F06.
  SELECT-OPTIONS:
  AUFNR FOR VIMHIO-AUFNR MATCHCODE OBJECT ORDP,
  QMNUM FOR VIMHIO-QMNUM MATCHCODE OBJECT QMEG,
  LBLNI FOR VIMHIO-LBLNI,
  GSTRP FOR RIHMHIO-GSTRP,
  ADDAT FOR RMIPM-ABSDA,
  TSTAT FOR VIMHIO-TSTAT.                "Übergangen/fixiert
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(31) TEXT-T00.
    PARAMETERS TSTAA  RADIOBUTTON GROUP TSTA DEFAULT 'X'.
*SELECTION-SCREEN COMMENT 35(22) text-a01.                      "N744242
    SELECTION-SCREEN COMMENT 35(22) TEXT-A01 FOR FIELD TSTAA. "N744242
    PARAMETERS TSTAM  RADIOBUTTON GROUP TSTA.
*SELECTION-SCREEN COMMENT 60(08) text-a02.                      "N744242
    SELECTION-SCREEN COMMENT 60(08) TEXT-A02 FOR FIELD TSTAM. "N744242
    PARAMETERS TSTAO  RADIOBUTTON GROUP TSTA.
*SELECTION-SCREEN COMMENT 71(09) text-a03.                      "N744242
    SELECTION-SCREEN COMMENT 71(09) TEXT-A03 FOR FIELD TSTAO. "N744242
  SELECTION-SCREEN END OF LINE.
  PARAMETERS : SPERRE AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK RIMHIO00_11.
SELECTION-SCREEN BEGIN OF BLOCK RIMHIO00_2 WITH FRAME TITLE TEXT-F03.
  SELECT-OPTIONS:
  IWERK      FOR    RIHMHIO-IWERK                                      ,
  WPGRP      FOR     VIMHIO-WPGRP                                      ,
  GSBER      FOR     VIMHIO-GSBER                                      ,
  AUART      FOR     VIMHIO-AUART                                      ,
  QMART      FOR     VIMHIO-QMART                                      ,
  ILART      FOR     VIMHIO-ILART                                      ,
  GEWRK      FOR    RIHMHIO-GEWRK     MATCHCODE OBJECT CRAM            ,
  PLNTY      FOR    RIHMHIO-PLNTY                                      ,
  PLNNR      FOR    RIHMHIO-PLNNR                                      ,
  PLNAL      FOR    RIHMHIO-PLNAL                                      ,
  BSTNR      FOR    RIHMHIO-BSTNR     MATCHCODE OBJECT MEKK            ,
  BSTPO      FOR    RIHMHIO-BSTPO                                      .
SELECTION-SCREEN END OF BLOCK RIMHIO00_2.

SELECTION-SCREEN BEGIN OF BLOCK RIMHIO00_3 WITH FRAME TITLE TEXT-F02.
  SELECT-OPTIONS:
  SWERK      FOR     VIMHIO-SWERK                                      ,
  STORT      FOR     VIMHIO-STORT                                      ,
  MSGRP      FOR     VIMHIO-MSGRP                                      ,
  BEBER      FOR     VIMHIO-BEBER                                      ,
  ARBPL      FOR    RIHMHIO-ARBPL      MATCHCODE OBJECT CRAM           ,
  ABCKZ      FOR     VIMHIO-ABCKZ                                      ,
  EQFNR      FOR     VIMHIO-EQFNR                                      ,
  BUKRS      FOR     VIMHIO-BUKRS                                      ,
  ANLNR      FOR     VIMHIO-ANLNR      MATCHCODE OBJECT AANL           ,
  ANLUN      FOR     VIMHIO-ANLUN                                      ,
  KOKRS      FOR     VIMHIO-KOKRS                                      ,
  KOSTL      FOR     VIMHIO-KOSTL      MATCHCODE OBJECT KOST           ,
  PSPEL      FOR     VIMHIO-PSPEL      MATCHCODE OBJECT PRPM           ,
  DAUFN      FOR     VIMHIO-DAUFN                                      ,
  KDAUF      FOR     VIMHIO-KDAUF      MATCHCODE OBJECT VMVA           ,
  KDPOS      FOR     VIMHIO-KDPOS                                      ,
  VKORG      FOR     VIMHIO-VKORG                                      ,
  VTWEG      FOR     VIMHIO-VTWEG                                      ,
  SPART      FOR     VIMHIO-SPART                                      .
SELECTION-SCREEN END OF BLOCK RIMHIO00_3.
SELECTION-SCREEN BEGIN OF BLOCK RIMHIO00_4 WITH FRAME TITLE TEXT-F05.
  SELECT-OPTIONS:
  ERNAM      FOR     VIMHIO-ERNAM      MATCHCODE OBJECT USER_ADDR      ,
  ERSDT      FOR    RIHMHIO-ERSDT                                      ,
  AENAM      FOR    RIHMHIO-AENAM      MATCHCODE OBJECT USER_ADDR      ,
  AEDAT      FOR    RIHMHIO-AEDAT                                      .
SELECTION-SCREEN END OF BLOCK RIMHIO00_4.

SELECTION-SCREEN BEGIN OF BLOCK RIMPOS00_5 WITH FRAME TITLE TEXT-SON.
  PARAMETERS: VARIANT LIKE DISVARIANT-VARIANT.
SELECTION-SCREEN END OF BLOCK RIMPOS00_5.
PARAMETERS:
  DY_SELM  DEFAULT '0' NO-DISPLAY,
  DY_MODE  DEFAULT ' ' NO-DISPLAY,
  DY_TCODE LIKE SY-TCODE NO-DISPLAY.
