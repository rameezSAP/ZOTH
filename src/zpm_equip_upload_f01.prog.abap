*&---------------------------------------------------------------------*
*& Include          ZPM_PRIDE_TEMPLATE_UPLOAD_F01
*&---------------------------------------------------------------------*

FORM F_GET_DATA.
*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*

  DATA : LV_FNAME LIKE  RLGRAP-FILENAME.
*  DELETE FROM ZPM_PRIDE_ROUT_T WHERE S_DATE IS INITIAL.
*  DELETE FROM ZPM_PRIDE WHERE e_DATE IS INITIAL.

*  COMMIT WORK.
  LV_FNAME = P_LOAD.

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      I_FIELD_SEPERATOR    = 'X'
      I_LINE_HEADER        = 'X'
      I_TAB_RAW_DATA       = IT_RAW
      I_FILENAME           = LV_FNAME
    TABLES
      I_TAB_CONVERTED_DATA = LT_DATA[]
    EXCEPTIONS
      CONVERSION_FAILED    = 1
      OTHERS               = 2.

*----- Converting the format of excel input to the accepted format for FM----------*
*----- Start ----------------------------------------------------------------------*
  LOOP AT ITAB.

    MOVE-CORRESPONDING ITAB TO LS_DATA.
*    MOVE-CORRESPONDING ITAB TO LS_PRIDE_MP_DATA.

    APPEND LS_DATA TO LT_DATA. "Moving Work Area for LS_IMRG to the bottom line of LS_IMRG
*    APPEND LS_PRIDE_MP_DATA TO LT_PRIDE_MP_DATA. "Moving Work Area for LS_IMRG to the bottom line of LS_IMRG

  ENDLOOP.
*----- End ------------------------------------------------------------------------*
*----- Converting the format of excel input to the accepted format for FM----------*

ENDFORM.                    " F_GET_DATA

FORM F_PROCESS_DATA.
*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
  TYPES:BEGIN OF TY_TEXT,
          TEXT TYPE SOTR_TXT,
        END OF TY_TEXT.
  DATA:LT_TEXT TYPE STANDARD TABLE OF TY_TEXT.
  DATA LT_LINES            TYPE STANDARD TABLE OF TLINE.
  DATA LS_LINE            TYPE TLINE.
  DATA HEADER           TYPE THEAD.
  DATA LS_HEADER TYPE THEAD.
  DATA LS_NAME TYPE  THEAD-TDNAME.
  LOOP AT LT_DATA ASSIGNING FIELD-SYMBOL(<FS_DATA>).
    CLEAR: LT_LINES[],LT_TEXT[].
    LS_NAME = <FS_DATA>-EQUIPMENT.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*       CLIENT   = SY-MANDT
        ID       = 'LTXT'
        LANGUAGE = SY-LANGU
        NAME     = LS_NAME
        OBJECT   = 'EQUI'
*       ARCHIVE_HANDLE                = 0
*       LOCAL_CAT                     = ' '
      IMPORTING
        HEADER   = HEADER
*       OLD_LINE_COUNTER              = OLD_LINE_COUNTER
      TABLES
        LINES    = LT_LINES
 EXCEPTIONS
       ID       = 1
       LANGUAGE = 2
       NAME     = 3
       NOT_FOUND                     = 4
       OBJECT   = 5
       REFERENCE_CHECK               = 6
       WRONG_ACCESS_TO_ARCHIVE       = 7
      .


    CALL FUNCTION 'SOTR_SERV_STRING_TO_TABLE'
      EXPORTING
        TEXT                = <FS_DATA>-TEXT
        FLAG_NO_LINE_BREAKS = ' '
        LINE_LENGTH         = 70
*       LANGU               = SY-LANGU
      TABLES
        TEXT_TAB            = LT_TEXT.


    LOOP AT LT_TEXT ASSIGNING FIELD-SYMBOL(<FS_TEXT>).
      LS_LINE-TDLINE = <FS_TEXT>.
      LS_LINE-TDFORMAT = '*'.
      APPEND LS_LINE TO LT_LINES.
    ENDLOOP.

    IF LT_LINES[] IS NOT INITIAL.
*DATA CLIENT TYPE SY-MANDT.

*DATA LINES  TYPE STANDARD TABLE OF TLINE.

      LS_HEADER-TDOBJECT = 'EQUI'.
      LS_HEADER-TDNAME = <FS_DATA>-EQUIPMENT.
      LS_HEADER-TDID = 'LTXT'.
      LS_HEADER-TDSPRAS = 'E'.
*ls_header-TDOBJECT = 'EQUI'.

      CALL FUNCTION 'SAVE_TEXT'
        EXPORTING
*         CLIENT   = SY-MANDT
          HEADER   = LS_HEADER
*         INSERT   = 'X'
         SAVEMODE_DIRECT         = 'X'
*         OWNER_SPECIFIED         = ' '
*         LOCAL_CAT               = ' '
*         KEEP_LAST_CHANGED       = ' '
* IMPORTING
*         FUNCTION = FUNCTION
*         NEWHEADER               = NEWHEADER
        TABLES
          LINES    = LT_LINES
        EXCEPTIONS
          ID       = 1
          LANGUAGE = 2
          NAME     = 3
          OBJECT   = 4.
      IF SY-SUBRC = 0.
        commit WORK.
*         CALL FUNCTION 'COMMIT_TEXT'
*       EXPORTING
*            OBJECT   = LS_HEADER-TDOBJECT
*            NAME     = LS_HEADER-TDNAME
*            ID       = LS_HEADER-TDID
*            LANGUAGE = LS_HEADER-TDSPRAS
*        EXCEPTIONS
*            ERROR_MESSAGE     = 9
*            OTHERS.
        WRITE: <FS_DATA>-EQUIPMENT && ' - ' && 'Done'.
      ENDIF.




    ENDIF.


  ENDLOOP.

ENDFORM.

FORM F_LIST_DATA.
*&---------------------------------------------------------------------*
*&      Form  f_list_data
*&---------------------------------------------------------------------*

  DATA: LS_FCAT TYPE SLIS_T_FIELDCAT_ALV WITH HEADER LINE.
  DATA: LT_FCAT TYPE SLIS_T_FIELDCAT_ALV.

  LS_FCAT-REPTEXT_DDIC = 'Index'.
  LS_FCAT-FIELDNAME = 'Index'.
  LS_FCAT-OUTPUTLEN = '3'.
*  ls_fcat-tabname   = ''.
  APPEND LS_FCAT TO LT_FCAT.

  LS_FCAT-REPTEXT_DDIC = 'ROUTE NAME'.
  LS_FCAT-FIELDNAME = 'ROUTE_NAME'.
  LS_FCAT-OUTPUTLEN = '20'.
  LS_FCAT-TABNAME   = 'ZPM_PRIDE_RDET_T'.
  LS_FCAT-JUST = 'L'.
  LS_FCAT-ICON      = 'X'.
  APPEND LS_FCAT TO LT_FCAT.

  LS_FCAT-REPTEXT_DDIC = 'Created Time'.
  LS_FCAT-FIELDNAME = 'C_TIME'.
  LS_FCAT-OUTPUTLEN = '20'.
  LS_FCAT-TABNAME   = 'ZPM_PRIDE_RDET_T'.
  LS_FCAT-JUST = 'L'.
  LS_FCAT-ICON      = 'X'.
  APPEND LS_FCAT TO LT_FCAT.

  LS_FCAT-REPTEXT_DDIC = 'Created Date'.
  LS_FCAT-FIELDNAME = 'C_DATE'.
  LS_FCAT-OUTPUTLEN = '20'.
  LS_FCAT-TABNAME   = 'ZPM_PRIDE_RDET_T'.
  LS_FCAT-JUST = 'L'.
  LS_FCAT-ICON      = 'X'.
  APPEND LS_FCAT TO LT_FCAT.

  LS_FCAT-REPTEXT_DDIC = 'Equipment'.
  LS_FCAT-FIELDNAME = 'EQUIPMENT'.
  LS_FCAT-OUTPUTLEN = '20'.
  LS_FCAT-TABNAME   = 'ZPM_PRIDE_RDET_T'.
  LS_FCAT-JUST = 'L'.
  LS_FCAT-ICON      = 'X'.
  APPEND LS_FCAT TO LT_FCAT.


  LS_FCAT-REPTEXT_DDIC = 'Functional Location'.
  LS_FCAT-FIELDNAME = 'FUNC_LOC'.
  LS_FCAT-OUTPUTLEN = '20'.
  LS_FCAT-TABNAME   = 'ZPM_PRIDE_RDET_T'.
  LS_FCAT-JUST = 'L'.
  LS_FCAT-ICON      = 'X'.
  APPEND LS_FCAT TO LT_FCAT.


  LS_FCAT-REPTEXT_DDIC = 'MP #'.
  LS_FCAT-FIELDNAME = 'MEASURE_POINT'.
  LS_FCAT-OUTPUTLEN = '4'.
  LS_FCAT-TABNAME   = 'ZPM_PRIDE_RDET_T'.
  LS_FCAT-JUST = 'C'.
  APPEND LS_FCAT TO LT_FCAT.

  LS_FCAT-REPTEXT_DDIC = 'Measuring Point'.
  LS_FCAT-FIELDNAME = 'PTTXT'.
  LS_FCAT-OUTPUTLEN = '20'.
  LS_FCAT-TABNAME   = 'IMPTT'.
  LS_FCAT-JUST = 'L'.
  LS_FCAT-ICON      = 'X'.
  APPEND LS_FCAT TO LT_FCAT.



  LS_FCAT-REPTEXT_DDIC = 'Status'.
  LS_FCAT-FIELDNAME = 'ICON'.
  LS_FCAT-OUTPUTLEN = '5'.
  LS_FCAT-JUST = 'C'.
  LS_FCAT-ICON      = 'X'.
  APPEND LS_FCAT TO LT_FCAT.

  LS_FCAT-REPTEXT_DDIC = 'Message'.
  LS_FCAT-FIELDNAME = 'MESSAGE'.
  LS_FCAT-OUTPUTLEN = '100'.
  LS_FCAT-JUST = 'L'.
  APPEND LS_FCAT TO LT_FCAT.

*  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
*    EXPORTING
*      IT_FIELDCAT = LT_FCAT
*    TABLES
*      T_OUTTAB    = GT_LIST.

ENDFORM.                    " F_LIST_DATA
*&---------------------------------------------------------------------*
*& Form numbering
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_NUMBER
*&---------------------------------------------------------------------*
FORM NUMBERING  CHANGING P_LV_NUMBER TYPE NR_NUMBER.
  TRY.
      CL_NUMBERRANGE_RUNTIME=>NUMBER_GET(
        EXPORTING
*         IGNORE_BUFFER     = IGNORE_BUFFER
          NR_RANGE_NR       = '01'
          OBJECT            = 'ZPM_ROUTE'
*         QUANTITY          = 1
*         SUBOBJECT         = SUBOBJECT
*         TOYEAR            = TOYEAR
        IMPORTING
          NUMBER            = DATA(LV_NUM)
          RETURNCODE        = DATA(LV_CODE)
          RETURNED_QUANTITY = DATA(LV_QTY)
      ).
      P_LV_NUMBER = LV_NUM.
    CATCH CX_NR_OBJECT_NOT_FOUND.
    CATCH CX_NUMBER_RANGES INTO DATA(LO_NUMRANGE).
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form convert_to_char
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> MIN
*&      --> MAX
*&      --> DEC
*&      --> MINI
*&      --> MAXI
*&      <-- LS_PRIDE_MP_DATA_LOW
*&---------------------------------------------------------------------*
FORM CONVERT_TO_CHAR  USING    P_MIN TYPE IMRC_MRMIN
                               P_MRNGU TYPE IMRC_MRNGU
                               P_DEC TYPE IMRC_DECIM
                               P_MINI TYPE IVALU
*                               P_MAXI TYPE IMRC_MRMAXI
                      CHANGING LV_VALUE TYPE ZPM_PRD_MAX.

  DATA LV_CHAR TYPE EAML_START_POINT.

  CALL FUNCTION 'FLTP_CHAR_CONVERSION_FROM_SI'
    EXPORTING
      CHAR_UNIT        = P_MRNGU
      UNIT_IS_OPTIONAL = ' '
      DECIMALS         = P_DEC
      EXPONENT         = 0
      FLTP_VALUE_SI    = P_MIN
      INDICATOR_VALUE  = P_MINI
      MASC_SYMBOL      = ' '
    IMPORTING
      CHAR_VALUE       = LV_CHAR
    EXCEPTIONS
      NO_UNIT_GIVEN    = 1
      UNIT_NOT_FOUND   = 2
      OTHERS           = 3.

  CONDENSE LV_CHAR.
  MOVE LV_CHAR TO LV_VALUE.


ENDFORM.
