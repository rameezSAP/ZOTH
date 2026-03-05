*&---------------------------------------------------------------------*
*& Include          ZPM_CRF_REPORT_PRINT_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .
  SELECT * FROM ZPM_CRF_REP_CDS
    INTO TABLE @DATA(LT_DATA)
    WHERE RSNUM  IN @S_RSNUM AND
          AUFNR  IN @S_AUFNR AND
          MATNR  IN @S_MATNR.
  IF LT_DATA IS NOT INITIAL.
    DATA(LT_DATA_TMP) = LT_DATA.
    SORT LT_DATA_TMP BY RSNUM ASCENDING.
    DELETE ADJACENT DUPLICATES FROM LT_DATA_TMP COMPARING RSNUM.
  ENDIF.

  LOOP AT LT_DATA_TMP INTO DATA(LS_DATA_TMP).
    MOVE-CORRESPONDING LS_DATA_TMP TO GS_MAIN.
    GS_MAIN-PRINT_BY = sy-UNAME.
    GS_MAIN-CURRENT_DATE = sy-DATUM.
    GS_MAIN-time = sy-UZEIT.

    LOOP AT LT_DATA INTO DATA(LS_DATA) WHERE RSNUM = LS_DATA_TMP-RSNUM.
      MOVE-CORRESPONDING LS_DATA TO GS_ITEM..
      APPEND GS_ITEM TO GS_MAIN-ITEM.
      CLEAR GS_ITEM.
    ENDLOOP.
    APPEND GS_MAIN TO GT_MAIN..
    CLEAR GS_MAIN.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

FORM SET_OUTPUT .

  DATA: FM_NAME         TYPE RS38L_FNAM,
        FP_DOCPARAMS    TYPE SFPDOCPARAMS,
        FP_OUTPUTPARAMS TYPE SFPOUTPUTPARAMS.



  CALL FUNCTION 'FP_JOB_OPEN'
    CHANGING
      IE_OUTPUTPARAMS = FP_OUTPUTPARAMS
    EXCEPTIONS
      CANCEL          = 1
      USAGE_ERROR     = 2
      SYSTEM_ERROR    = 3
      INTERNAL_ERROR  = 4
      OTHERS          = 5.

  IF SY-SUBRC <> 0.
    " MESSAGE 'Abode Form Server Error' TYPE 'E'.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  break ac_Adnan.
  DATA:LV_FNAME TYPE FPNAME.
    LV_FNAME = 'ZPM_CRF_REPORT_FROM'.
  CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'           "& Form Processing Generation
    EXPORTING
      I_NAME     = LV_FNAME
    IMPORTING
      E_FUNCNAME = FM_NAME.

  CALL FUNCTION FM_NAME
    EXPORTING
      /1BCDWB/DOCPARAMS = FP_DOCPARAMS
      GT_MAIN           = GT_MAIN
*    IMPORTING
*     /1BCDWB/FORMOUTPUT       =
    EXCEPTIONS
      USAGE_ERROR       = 1
      SYSTEM_ERROR      = 2
      INTERNAL_ERROR    = 3.

  IF SY-SUBRC <> 0.
    "MESSAGE 'Abode Form Server Error' TYPE 'E'.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL FUNCTION 'FP_JOB_CLOSE'
*    IMPORTING
*     E_RESULT             =
    EXCEPTIONS
      USAGE_ERROR    = 1
      SYSTEM_ERROR   = 2
      INTERNAL_ERROR = 3
      OTHERS         = 4.

  IF SY-SUBRC <> 0.
    " MESSAGE 'Abode Form Server Error' TYPE 'E'.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.
