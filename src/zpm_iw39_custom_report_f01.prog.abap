*&---------------------------------------------------------------------*
*& Include          ZFI_VOID_CHECK_REGISTER_F01
*&---------------------------------------------------------------------*
FORM GET_DATA.
*--Step insert
*Restrict showing alv
  CL_SALV_BS_RUNTIME_INFO=>SET( EXPORTING DISPLAY  = ABAP_FALSE
                                          METADATA = ABAP_FALSE
                                          DATA     = ABAP_TRUE ).
***TRY.
**  IF SEL_VOID IS INITIAL.
**    SEL_VOID-SIGN = 'I'.
**    SEL_VOID-OPTION = 'NE'.
**    SEL_VOID-LOW = ''.
**    SEL_VOID-HIGH = ''.
**    APPEND SEL_VOID.
**  ENDIF.
*Submit report as job(i.e. in background)
  DATA: JOBNAME LIKE TBTCJOB-JOBNAME VALUE
                               'TRANSFER DATA'.
  DATA: JOBCOUNT LIKE TBTCJOB-JOBCOUNT,
        HOST     LIKE MSXXLIST-HOST.
  DATA: BEGIN OF STARTTIME.
          INCLUDE STRUCTURE TBTCSTRT.
  DATA: END OF STARTTIME.
  DATA: STARTTIMEIMMEDIATE LIKE BTCH0000-CHAR1 VALUE 'X'.

* Insert process into job
  SUBMIT RIAUFK20 VIA SELECTION-SCREEN
*      WITH AUFNR  IN AUFNR
*      WITH AUART  IN AUART
*      WITH STRNO  IN STRNO
*      WITH EQUNR  IN EQUNR
*      WITH SERMAT IN SERMAT
*      WITH QMNUM  IN QMNUM
*      WITH DATUV  EQ DATUV
*      WITH DATUB  EQ DATUB
    AND RETURN.
*  CATCH cx_root INTO oref.
*ENDTRY.
  TRY.
*      CLEAR GV_FLAG.
      CL_SALV_BS_RUNTIME_INFO=>GET_DATA_REF(
        IMPORTING
          R_DATA = LS_DATA ).
      ASSIGN LS_DATA->* TO <LT_DATA>.
      IF <LT_DATA> IS ASSIGNED.
        DATA : L_VAR1 TYPE STRING.
        FIELD-SYMBOLS : <FS> TYPE ANY .
        BREAK-POINT.
        MOVE-CORRESPONDING <LT_DATA> TO OBJECT_TAB[]..
**Get data from AFIH
*        SELECT DISTINCT * FROM AFIH INTO TABLE @DATA(LT_AFIH)
*          FOR ALL ENTRIES IN @OBJECT_TAB
*        WHERE AUFNR = @OBJECT_TAB-AUFNR.
*
*        MOVE-CORRESPONDING LT_AFIH TO OBJECT_TAB[]..

      ELSE.
        MESSAGE 'No Data Found!' TYPE 'E'.
      ENDIF.
    CATCH CX_SALV_BS_SC_RUNTIME_INFO.
      MESSAGE `Unable to retrieve ALV data` TYPE 'E'.
  ENDTRY.

  CLEAR TOTAL.
*  TOTAL = REDUCE DMSHB( INIT VAL TYPE FAGL_CURRVAL_10 FOR WA IN  GT_MAIN
*                      NEXT VAL = VAL + WA-RWBTR ).
*Restrict showing alv
  CL_SALV_BS_RUNTIME_INFO=>SET( EXPORTING DISPLAY  = ABAP_TRUE
                                          METADATA = ABAP_TRUE
                                          DATA     = ABAP_TRUE ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Include          ZFI_VOID_CHECK_REGISTER_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

FORM SET_OUTPUT .
  CLEAR IT_FIELDCAT.
  CREATE DATA LR_DATA LIKE LINE OF OBJECT_TAB.

*Create Field Cathlog From Internal Table
  LR_TABDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( LR_DATA ).

  LT_DFIES = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LR_TABDESCR ).

  LOOP AT LT_DFIES INTO LS_DFIES.
    CLEAR LS_FIELDCAT.
    MOVE-CORRESPONDING LS_DFIES TO LS_FIELDCAT.
    LS_FIELDCAT-REPTEXT   = LS_DFIES-FIELDTEXT.
    LS_FIELDCAT-SCRTEXT_S = LS_DFIES-FIELDTEXT.
    LS_FIELDCAT-SCRTEXT_L = LS_DFIES-FIELDTEXT.
    LS_FIELDCAT-SCRTEXT_M = LS_DFIES-FIELDTEXT.
    IF LS_DFIES-FIELDNAME = 'DATBW'.
      LS_FIELDCAT-REPTEXT      = 'Loan Date'.
      LS_FIELDCAT-SCRTEXT_S    = 'Loan Date'.
      LS_FIELDCAT-SCRTEXT_L    = 'Loan Date'.
      LS_FIELDCAT-SCRTEXT_M    = 'Loan Date'.
      LS_FIELDCAT-DO_SUM = 'X'.
    ELSEIF LS_DFIES-FIELDNAME = 'TOTAL_INS'.
      LS_FIELDCAT-REPTEXT      = 'Total Installments'.
      LS_FIELDCAT-SCRTEXT_S    = 'Total Installments'.
      LS_FIELDCAT-SCRTEXT_L    = 'Total Installments'.
      LS_FIELDCAT-SCRTEXT_M    = 'Total Installments'.
    ELSEIF LS_DFIES-FIELDNAME = 'DARBT'.
      LS_FIELDCAT-REPTEXT      = 'Loan Amount'.
      LS_FIELDCAT-SCRTEXT_S    = 'Loan Amount'.
      LS_FIELDCAT-SCRTEXT_L    = 'Loan Amount'.
      LS_FIELDCAT-SCRTEXT_M    = 'Loan Amount'.
    ELSEIF LS_DFIES-FIELDNAME = 'TILBT'.
      LS_FIELDCAT-REPTEXT      = 'Installment Amount'.
      LS_FIELDCAT-SCRTEXT_S    = 'Installment Amount'.
      LS_FIELDCAT-SCRTEXT_L    = 'Installment Amount'.
      LS_FIELDCAT-SCRTEXT_M    = 'Installment Amount'.
    ELSEIF LS_DFIES-FIELDNAME = 'BAL_AMT'.
      LS_FIELDCAT-REPTEXT      = 'Balance Amount'.
      LS_FIELDCAT-SCRTEXT_S    = 'Balance Amount'.
      LS_FIELDCAT-SCRTEXT_L    = 'Balance Amount'.
      LS_FIELDCAT-SCRTEXT_M    = 'Balance Amount'.
    ELSEIF LS_DFIES-FIELDNAME = 'BAL_INS'.
      LS_FIELDCAT-REPTEXT      = 'Remaining Installments'.
      LS_FIELDCAT-SCRTEXT_S    = 'Remaining Installments'.
      LS_FIELDCAT-SCRTEXT_L    = 'Remaining Installments'.
      LS_FIELDCAT-SCRTEXT_M    = 'Remaining Installments'.
    ELSEIF LS_DFIES-FIELDNAME = 'NAME'.
      LS_FIELDCAT-REPTEXT      = 'Name'.
      LS_FIELDCAT-SCRTEXT_S    = 'Name'.
      LS_FIELDCAT-SCRTEXT_L    = 'Name'.
      LS_FIELDCAT-SCRTEXT_M    = 'Name'.
    ENDIF.
    DATA LV_LENGTH TYPE I .
    IF LS_DFIES-FIELDTEXT IS INITIAL.
      LV_LENGTH = STRLEN( LS_FIELDCAT-REPTEXT ).
    ELSE.
      LV_LENGTH = STRLEN( LS_DFIES-FIELDTEXT ).
    ENDIF.

    LS_FIELDCAT-OUTPUTLEN = LV_LENGTH.
    APPEND LS_FIELDCAT TO IT_FIELDCAT.
    CLEAR: LS_FIELDCAT,LS_DFIES.
  ENDLOOP.


*Display ALV Report
  CONSTANTS LC_SAVE_ALL TYPE C VALUE 'A'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      I_CALLBACK_PROGRAM     = SY-REPID
      I_CALLBACK_TOP_OF_PAGE = 'TOP_OF_PAGE'
      IT_FIELDCAT_LVC        = IT_FIELDCAT[]
      I_SAVE                 = LC_SAVE_ALL
*     IS_VARIANT             = GX_VARIANT
   "  IT_SORT_LVC            = IT_SORT
    TABLES
      T_OUTTAB               = OBJECT_TAB "Global Table for output
    EXCEPTIONS
      PROGRAM_ERROR          = 1
      OTHERS                 = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here

  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM TOP_OF_PAGE.

  DATA: LT_HEADER TYPE SLIS_T_LISTHEADER,
        LS_HEADER TYPE SLIS_LISTHEADER.

* Set Header in the ALV
  LS_HEADER-TYP  = 'H'.                                                                 "#EC-NOTEXT
  LS_HEADER-INFO = TEXT-001.
  APPEND LS_HEADER TO LT_HEADER.
  CLEAR LS_HEADER.

  LS_HEADER-TYP  = 'S'.
  LS_HEADER-KEY  = TEXT-002.
  LS_HEADER-INFO = SY-DATUM+6(2) && '.' && SY-DATUM+4(2) && '.' && SY-DATUM+0(4).
  APPEND LS_HEADER TO LT_HEADER.
  CLEAR LS_HEADER.


* Set List Comment Output
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = LT_HEADER.

  CLEAR: LS_HEADER, LT_HEADER[].

ENDFORM.
