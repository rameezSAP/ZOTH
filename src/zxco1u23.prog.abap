*&---------------------------------------------------------------------*
*& Include          ZXCO1U23
*&---------------------------------------------------------------------*
BREAK: AC_ADNAN, AC_WASEEM.

"Deletion of items(In process and approved)
IF SY-UCOMM = 'LOEA'.
*  SELECT SINGLE * FROM ZMM_WF_HST_V INTO @DATA(LS_HST)
*    WHERE RSNUM = @IS_COMPONENT-RSNUM
*    AND RSPOS = @IS_COMPONENT-RSPOS
*    AND ( XWAOK EQ 'X' ).
*  IF SY-SUBRC = 0.
*    MESSAGE |Deletion of item { IS_COMPONENT-POSNR } is not allowed| TYPE 'W'.
*    RAISE NO_CHANGES_ALLOWED.
*  ENDIF.

  SELECT SINGLE * FROM ZMM_WF_HST_V INTO @DATA(LS_HST)
    WHERE RSNUM = @IS_COMPONENT-RSNUM
    AND RSPOS = @IS_COMPONENT-RSPOS
    AND LEVELS = ( SELECT MAX( LEVELS ) FROM ZMM_WF_HST_V WHERE RSNUM = @IS_COMPONENT-RSNUM AND RSPOS = @IS_COMPONENT-RSPOS ).
  IF SY-SUBRC = 0.
    IF ( LS_HST-XWAOK = 'X' ) OR ( LS_HST-WFSTAT <> 'X').
      MESSAGE |Deletion of item { IS_COMPONENT-POSNR } is not allowed| TYPE 'W'.
      RAISE NO_CHANGES_ALLOWED.
    ENDIF.
  ENDIF.

ENDIF.

"Change of items(In process and approved)
IF IS_COMPONENT-MENGE <> IS_COMPONENT_OLD-MENGE.
  CLEAR LS_HST.
  SELECT SINGLE * FROM ZMM_WF_HST_V INTO LS_HST
    WHERE RSNUM = IS_COMPONENT-RSNUM
    AND RSPOS = IS_COMPONENT-RSPOS
    AND LEVELS = ( SELECT MAX( LEVELS ) FROM ZMM_WF_HST_V WHERE RSNUM = IS_COMPONENT-RSNUM AND RSPOS = IS_COMPONENT-RSPOS ).
  IF SY-SUBRC EQ 0.
    IF ( LS_HST-XWAOK = 'X' ) OR ( LS_HST-WFSTAT <> 'X').
      MESSAGE |Deletion of item { IS_COMPONENT-POSNR } is in approval mode| TYPE 'W'.
      RAISE NO_CHANGES_ALLOWED.
    ENDIF.
  ENDIF.
ENDIF.
