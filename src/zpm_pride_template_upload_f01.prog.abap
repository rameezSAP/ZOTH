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

  COMMIT WORK.
  LV_FNAME = P_LOAD.

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      I_FIELD_SEPERATOR    = 'X'
      I_LINE_HEADER        = 'X'
      I_TAB_RAW_DATA       = IT_RAW
      I_FILENAME           = LV_FNAME
    TABLES
      I_TAB_CONVERTED_DATA = ITAB[]
    EXCEPTIONS
      CONVERSION_FAILED    = 1
      OTHERS               = 2.

*----- Converting the format of excel input to the accepted format for FM----------*
*----- Start ----------------------------------------------------------------------*
  LOOP AT ITAB.

    MOVE-CORRESPONDING ITAB TO LS_PRIDE_DATA.
    MOVE ITAB-EQUIPMENT TO LS_PRIDE_DATA-EQUNR.
    MOVE-CORRESPONDING ITAB TO LS_PRIDE_MP_DATA.

    APPEND LS_PRIDE_DATA TO LT_PRIDE_DATA. "Moving Work Area for LS_IMRG to the bottom line of LS_IMRG
    APPEND LS_PRIDE_MP_DATA TO LT_PRIDE_MP_DATA. "Moving Work Area for LS_IMRG to the bottom line of LS_IMRG

  ENDLOOP.
*----- End ------------------------------------------------------------------------*
*----- Converting the format of excel input to the accepted format for FM----------*

ENDFORM.                    " F_GET_DATA

FORM F_PROCESS_DATA.
*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
  DATA : LV_MESSAGE(100) TYPE C,
         DURATION        TYPE INT2,
         UNIT            TYPE  T006-MSEHI.

  DATA: START_TIME TYPE UZEIT,
        END_TIME   TYPE UZEIT,
        END_DATE   TYPE DATUM,
        START_DATE TYPE DATUM.

  DATA: LS_PRIDE_ROUTES TYPE ZPM_PRIDE_ROUT_T. "Work Area for LS_IMRG table"
  DATA: LS_PRIDE_ROUTES_T TYPE ZPM_PRIDE_RDET_T. "Work Area for LS_IMRG table"
  DATA: LT_PRIDE_ROUTES LIKE TABLE OF LS_PRIDE_ROUTES. "Work Area for LS_IMRG table"
  DATA: LT_PRIDE_ROUTES_T LIKE TABLE OF LS_PRIDE_ROUTES_T. "Work Area for LS_IMRG table"
  DATA LV_NUMBER TYPE NR_NUMBER.
  BREAK AC_ADNAN.
  IF LT_PRIDE_DATA[] IS NOT INITIAL.
    SELECT EQUNR,MPOBJ,POINT,MRNGU,MRMIN,MRMINI,MRMAX,MRMAXI,DECIM FROM IMPTT
      JOIN EQUI ON EQUI~OBJNR = IMPTT~MPOBJ
      INTO TABLE @DATA(LT_MPOINT)
      FOR ALL ENTRIES IN @LT_PRIDE_DATA
    WHERE EQUNR = @LT_PRIDE_DATA-EQUNR
      AND INACT NE 'X'
      .

    SELECT * FROM ZI_PM_EQUIPMENT_TXT_R
      INTO TABLE @DATA(LT_EQUI)
    FOR ALL ENTRIES IN @LT_PRIDE_DATA
  WHERE EQUNR = @LT_PRIDE_DATA-EQUNR.
*    AND INACT NE 'X'.

    SELECT SINGLE LOCATION FROM ZPM_PRIDE_PLANTS
      INTO @DATA(LV_LOCATION)
  WHERE PLANT = @P_LOC.

  ENDIF.

  BREAK AMAHMOOD.

  PERFORM NUMBERING CHANGING LV_NUMBER.

  LOOP AT LT_PRIDE_DATA ASSIGNING FIELD-SYMBOL(<FS_PRIDE_DATA>) .
    CLEAR LS_PRIDE_ROUTES.
    MOVE-CORRESPONDING <FS_PRIDE_DATA> TO LS_PRIDE_ROUTES.
    LS_PRIDE_ROUTES-ROUTE_ID = LV_NUMBER+12(8).
    LS_PRIDE_ROUTES-ROUTE_NAME = P_ROUTE.
    LS_PRIDE_ROUTES-S_DATE = P_SDATE.
    LS_PRIDE_ROUTES-E_DATE = P_SDATE.
    LS_PRIDE_ROUTES-S_TIME = P_TIME.
    LS_PRIDE_ROUTES-E_TIME = P_TIME.
    LS_PRIDE_ROUTES-PLANT = LV_LOCATION.
    LS_PRIDE_ROUTES-LOCATION = P_LOC.
    LS_PRIDE_ROUTES-SECHEDULE = P_SCH.
    LS_PRIDE_ROUTES-ACTIVE = 'P'.
*        LS_PRIDE_ROUTES-SECHEDULE = P_SCH.
    MODIFY ZPM_PRIDE_ROUT_T FROM LS_PRIDE_ROUTES.

    CLEAR LS_PRIDE_ROUTES_T.

    LS_PRIDE_ROUTES_T-ROUTE_ID = LS_PRIDE_ROUTES-ROUTE_ID.
    IF LINE_EXISTS( LT_EQUI[ EQUNR = <FS_PRIDE_DATA>-EQUIPMENT ] ).
      LS_PRIDE_ROUTES_T-FUNC_LOC = LT_EQUI[ EQUNR = <FS_PRIDE_DATA>-EQUIPMENT ]-TPLNR.
      <FS_PRIDE_DATA>-FUNC_LOC = LS_PRIDE_ROUTES_T-FUNC_LOC.
    ENDIF.

    LS_PRIDE_ROUTES_T-FUNC_LOC = <FS_PRIDE_DATA>-FUNC_LOC.
    LS_PRIDE_ROUTES_T-EQUIPMENT = <FS_PRIDE_DATA>-EQUIPMENT.
    LS_PRIDE_ROUTES_T-ACTIVE = 'X'.
    MODIFY ZPM_PRIDE_RDET_T FROM LS_PRIDE_ROUTES_T.

    LOOP AT LT_MPOINT ASSIGNING FIELD-SYMBOL(<FS_MPOINT>) WHERE EQUNR = <FS_PRIDE_DATA>-EQUIPMENT .
      CLEAR LS_PRIDE_MP_DATA.
      LS_PRIDE_MP_DATA-ROUTE_ID = LS_PRIDE_ROUTES-ROUTE_ID.
      LS_PRIDE_MP_DATA-EQUIPMENT = <FS_PRIDE_DATA>-EQUIPMENT.
      LS_PRIDE_MP_DATA-FUNC_LOC = <FS_PRIDE_DATA>-FUNC_LOC.
      LS_PRIDE_MP_DATA-MEASURE_POINT = <FS_MPOINT>-POINT.
      LS_PRIDE_MP_DATA-UOM = <FS_MPOINT>-MRNGU.
      LS_PRIDE_MP_DATA-ACTIVE = 'X'.
      PERFORM CONVERT_TO_CHAR USING <FS_MPOINT>-MRMIN <FS_MPOINT>-MRNGU <FS_MPOINT>-DECIM <FS_MPOINT>-MRMINI CHANGING LS_PRIDE_MP_DATA-LOW.
      PERFORM CONVERT_TO_CHAR USING <FS_MPOINT>-MRMAX <FS_MPOINT>-MRNGU <FS_MPOINT>-DECIM <FS_MPOINT>-MRMAXI CHANGING LS_PRIDE_MP_DATA-HIGH.


      MODIFY ZPM_PRIDE_ROMP_T FROM LS_PRIDE_MP_DATA.

      IF SY-SUBRC <> 0. "If error occured

        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
             INTO LV_MESSAGE. "Moving error message to variable lv_message
        LV_MESSAGE = 'Route Name: ' && <FS_PRIDE_DATA>-ROUTE_ID && 'Func Location : ' &&  <FS_PRIDE_DATA>-FUNC_LOC && 'Equipment: ' && <FS_PRIDE_DATA>-FUNC_LOC.
*      MOVE LV_MESSAGE TO WA_GT_LIST-MESSAGE. "Moving lv_message variable to work area for gt_list
        MOVE <FS_PRIDE_DATA>-ROUTE_ID TO WA_GT_LIST-POINT. "Moving point variable value to corresponding in gt_list work area
        WA_GT_LIST-INDEX = WA_GT_LIST-INDEX + 1.

        IF SY-MSGTY EQ 'E'. "Error light Icon
          WRITE ICON_RED_LIGHT AS ICON TO WA_GT_LIST-ICON.
        ELSEIF SY-MSGTY EQ 'W' OR SY-MSGTY EQ 'I'. "Warning Light Icon
          WRITE ICON_YELLOW_LIGHT AS ICON TO WA_GT_LIST-ICON.
        ELSE.
          WRITE ICON_GREEN_LIGHT AS ICON TO WA_GT_LIST-ICON. "OK / Success, Green ligtht Icon
        ENDIF.

      ELSE. "If NO error Occurred
        MOVE-CORRESPONDING LS_PRIDE_MP_DATA TO WA_GT_LIST.
        WA_GT_LIST-ROUTE_NAME = P_ROUTE.
*          MOVE <FS_PRIDE_DATA>- TO WA_GT_LIST.

        MOVE LS_IMRG-POINT TO WA_GT_LIST-POINT. "Moving point variable value to corresponding in gt_list work area
        WRITE ICON_GREEN_LIGHT AS ICON TO WA_GT_LIST-ICON. "OK / Success, Green ligtht Icon
        WRITE 'Success' TO WA_GT_LIST-MESSAGE. "Moving error message to work are variable for message
        WA_GT_LIST-INDEX = WA_GT_LIST-INDEX + 1.

      ENDIF.

      APPEND WA_GT_LIST TO GT_LIST.

    ENDLOOP.

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

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      IT_FIELDCAT = LT_FCAT
    TABLES
      T_OUTTAB    = GT_LIST.

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
