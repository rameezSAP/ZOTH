*&**********************************************************************
*&   Author           : Adil Mahmood                                  *
*&   Date             :                              *
*&   Company          : UEP                                         *
*&   Program Name     : ZPM_PRIDE_UPLOAD                         *
*&   LDB Used         :                                                *
*&**********************************************************************
*& Program Definition : This program is to upload the route on Pride Application.          *
*                                                                      *
*&                            ()                             *
*&**********************************************************************
*& PROGRAM CHANGES / Modification Logs :                               *
*&**********************************************************************
*&   Date   I Request    I Programmer   I     Changes                  *
*&+-------------------------------------------------------------------+*
*&          I            I              I                              *
*&+-------------------------------------------------------------------+*
REPORT ZPM_PRIDE_UPLOAD.
TYPE-POOLS : TRUXS,SLIS,ICON.
TABLES IMRG.

*--------Table definition for entry of data from Excel-------------------"
*--------Used in FM "TEXT_CONVERT_XLS_TO_SAP"----------------------------"

DATA : BEGIN OF ITAB OCCURS 0,  "itab table defines : POINT, ITIME, IDATE, CNTRC, CDIFC, READR, STEXT.
         ROUTE_NAME    TYPE  CHAR50,
         FUNC_LOC      TYPE  CHAR30,
         EQUIPMENT     TYPE  CHAR30,
         MEASURE_POINT TYPE  CHAR30,
         VALUE         TYPE  CHAR30,
*         LOCATION      TYPE  CHAR1,
         "         ROUTE_ID      TYPE  CHAR30,
         "         C_DATE        TYPE  CHAR10,
         "         C_TIME        TYPE  CHAR10,
       END OF ITAB.

DATA : WA_ITAB LIKE LINE OF ITAB. "Work Area for table ITAB"

*--------Table definition for Measuring Document Entry-------------------"
*--------Used in FM "MEASUREM_DOCUM_RFC_SINGLE_001"----------------------"

DATA : BEGIN OF LS_IMRG OCCURS 0,  "ls_imrg table defines : POINT, ITIME, IDATE, CNTRC, CDIFC, READR, STEXT.
         POINT(12)     TYPE C,
         ITIME         TYPE TIMS, "imrg-itime,       "Time of Recording
         IDATE         TYPE DATS, "imrg-idate,       "Data of Recording
         CNTRC(22)     TYPE C,    "Counter Value (current reading) *Only used if counter difference field not used
*         CDIFC(22)  TYPE C,    "Difference in Counter Value from last entry *Only used if Counter value not used
         CDIFC(1)      TYPE C,    "Difference in Counter Value from last entry *Only used if Counter value not used
         READR(12)     TYPE C,    "Name of Reader
         STEXT(40)     TYPE C,
         ROUTE_NAME    TYPE  CHAR50,
         ROUTE_ID      TYPE  CHAR30,
         C_DATE        TYPE  CHAR10,
         C_TIME        TYPE  CHAR10,
         FUNC_LOC      TYPE  CHAR30,
         EQUIPMENT     TYPE  CHAR30,
         MEASURE_POINT TYPE  CHAR30,
       END OF LS_IMRG.

DATA: LS_PRIDE_DATA TYPE ZPM_PRIDE_HIER_T. "Work Area for LS_IMRG table"
DATA: LT_PRIDE_DATA LIKE TABLE OF LS_PRIDE_DATA. "Work Area for LS_IMRG table"

DATA: LS_PRIDE_MP_DATA TYPE ZPM_PRIDE_HIER_M. "Work Area for LS_IMRG table"
DATA: LT_PRIDE_MP_DATA LIKE TABLE OF LS_PRIDE_MP_DATA. "Work Area for LS_IMRG table"

*---------Table for Result Sheet Display------------"
*---------Used in FORM "F_List_Data"----------------"

DATA : BEGIN OF GT_LIST OCCURS 0, "gt_list table defines : INDEX, POINT, PTTXT (Text for MP Description), ICON, MESSAGE(Return Message)
         INDEX         TYPE I,
         POINT         LIKE IMPTT-POINT,
         PTTXT(20)     TYPE C,
         ICON          TYPE CHAR4,
         MESSAGE(100)  TYPE C,
         ROUTE_NAME    TYPE  CHAR50,
         ROUTE_ID      TYPE  CHAR30,
         C_DATE        TYPE  CHAR10,
         C_TIME        TYPE  CHAR10,
         FUNC_LOC      TYPE  CHAR30,
         EQUIPMENT     TYPE  CHAR30,
         MEASURE_POINT TYPE  CHAR30,

       END OF   GT_LIST.

DATA : WA_GT_LIST LIKE LINE OF  GT_LIST. "Work Area for table GT_LIST"

DATA: IT_RAW              TYPE TRUXS_T_TEXT_DATA,
      LS_MRECEIPT_LIST_EX TYPE IMRG,
      OUT_RETURN          TYPE IMRG OCCURS 0.

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-003.
  PARAMETERS: P_LOAD TYPE  RLGRAP-FILENAME OBLIGATORY. "OBLIGATORY DEFAULT 'D:\Users\nouman.butt\Desktop\testload.xls'.
  PARAMETERS: P_ROUTE TYPE   ZPM_PRIDE_ROUTES-ROUTE_NAME OBLIGATORY. "OBLIGATORY DEFAULT 'D:\Users\nouman.butt\Desktop\testload.xls'.
  PARAMETERS: P_SDATE TYPE   ZPM_PRIDE_ROUTES-S_DATE OBLIGATORY. "OBLIGATORY DEFAULT 'D:\Users\nouman.butt\Desktop\testload.xls'.
  PARAMETERS: P_TIME TYPE   ZPM_PRIDE_ROUTES-S_TIME OBLIGATORY. "OBLIGATORY DEFAULT 'D:\Users\nouman.butt\Desktop\testload.xls'.
  PARAMETERS: P_EDATE TYPE   ZPM_PRIDE_ROUTES-S_DATE OBLIGATORY. "OBLIGATORY DEFAULT 'D:\Users\nouman.butt\Desktop\testload.xls'.
  PARAMETERS: P_ETIME TYPE   ZPM_PRIDE_ROUTES-S_TIME OBLIGATORY. "OBLIGATORY DEFAULT 'D:\Users\nouman.butt\Desktop\testload.xls'.
  PARAMETERS: P_LOC TYPE   ZPM_PRIDE_ROUTES-LOCATION AS LISTBOX VISIBLE LENGTH 10 OBLIGATORY. "OBLIGATORY DEFAULT 'D:\Users\nouman.butt\Desktop\testload.xls'.
  PARAMETERS: P_SCH TYPE  ZPM_PRIDE_ROUTES-SECHEDULE AS LISTBOX VISIBLE LENGTH 10 OBLIGATORY. "OBLIGATORY DEFAULT 'D:\Users\nouman.butt\Desktop\testload.xls'.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 1.
    SELECTION-SCREEN COMMENT 10(50) TEXT-001.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 2.
    SELECTION-SCREEN COMMENT 10(48) TEXT-002.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK B1 .

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_LOAD.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      FIELD_NAME = 'P_LOAD'
    IMPORTING
      FILE_NAME  = P_LOAD.

START-OF-SELECTION.

  PERFORM F_GET_DATA.
  PERFORM F_PROCESS_DATA.
  PERFORM F_LIST_DATA.

END-OF-SELECTION.

FORM F_GET_DATA.
*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*

  DATA : LV_FNAME LIKE  RLGRAP-FILENAME.
*  DELETE FROM ZPM_PRIDE_ROUTES WHERE S_DATE IS INITIAL.
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

  DATA: LS_PRIDE_ROUTES TYPE ZPM_PRIDE_ROUTES. "Work Area for LS_IMRG table"
  DATA: LS_PRIDE_ROUTES_T TYPE ZPM_PRIDE_HIER_T. "Work Area for LS_IMRG table"
  DATA: LT_PRIDE_ROUTES LIKE TABLE OF LS_PRIDE_ROUTES. "Work Area for LS_IMRG table"
  DATA: LT_PRIDE_ROUTES_T LIKE TABLE OF LS_PRIDE_ROUTES_T. "Work Area for LS_IMRG table"
  DATA LV_NUMBER TYPE NR_NUMBER.
  BREAK AC_ADNAN.
  IF LT_PRIDE_DATA[] IS NOT INITIAL.
    SELECT EQUNR,MPOBJ,POINT,MRNGU FROM IMPTT
      JOIN EQUI ON EQUI~OBJNR = IMPTT~MPOBJ
      INTO TABLE @DATA(LT_MPOINT)
      FOR ALL ENTRIES IN @LT_PRIDE_DATA
    WHERE EQUNR = @LT_PRIDE_DATA-EQUIPMENT
      .
  ENDIF.

*  COMMIT WORK.

  IF P_SCH = '1'.
    DURATION = 30.
    UNIT = 'MIN'.
  ELSEIF P_SCH = '2'.
    DURATION = 2.
    UNIT = 'H'.
  ENDIF.

  BREAK AMAHMOOD.

  START_DATE = P_SDATE.
  END_DATE = P_SDATE.
  START_TIME = P_TIME.
  END_TIME = P_TIME.
  DO.
    IF ( START_DATE = P_EDATE AND START_TIME <= P_ETIME ) OR START_DATE < P_EDATE.

      PERFORM NUMBERING CHANGING LV_NUMBER.

      LOOP AT LT_PRIDE_DATA ASSIGNING FIELD-SYMBOL(<FS_PRIDE_DATA>) .


*    DO 4 TIMES.
        CLEAR LS_PRIDE_ROUTES.
        MOVE-CORRESPONDING <FS_PRIDE_DATA> TO LS_PRIDE_ROUTES.
        LS_PRIDE_ROUTES-ROUTE_ID = LV_NUMBER+12(8).
        LS_PRIDE_ROUTES-ROUTE_NAME = P_ROUTE.
        LS_PRIDE_ROUTES-S_DATE = END_DATE.
        LS_PRIDE_ROUTES-E_DATE = END_DATE.
        LS_PRIDE_ROUTES-S_TIME = END_TIME.
        LS_PRIDE_ROUTES-E_TIME = END_TIME.
        LS_PRIDE_ROUTES-LOCATION = P_LOC.
        LS_PRIDE_ROUTES-SECHEDULE = P_SCH.
        MODIFY ZPM_PRIDE_ROUTES FROM LS_PRIDE_ROUTES.

        CLEAR LS_PRIDE_ROUTES_T.

        LS_PRIDE_ROUTES_T-ROUTE_ID = LS_PRIDE_ROUTES-ROUTE_ID.
        LS_PRIDE_ROUTES_T-FUNC_LOC = <FS_PRIDE_DATA>-FUNC_LOC.
        LS_PRIDE_ROUTES_T-EQUIPMENT = <FS_PRIDE_DATA>-EQUIPMENT.
        MODIFY ZPM_PRIDE_HIER_T FROM LS_PRIDE_ROUTES_T.


*      PERFORM NUMBERING CHANGING LV_NUMBER.




        LOOP AT LT_MPOINT ASSIGNING FIELD-SYMBOL(<FS_MPOINT>) WHERE EQUNR = <FS_PRIDE_DATA>-EQUIPMENT .
          CLEAR LS_PRIDE_MP_DATA.
          LS_PRIDE_MP_DATA-ROUTE_ID = LS_PRIDE_ROUTES-ROUTE_ID.
          LS_PRIDE_MP_DATA-EQUIPMENT = <FS_PRIDE_DATA>-EQUIPMENT.
          LS_PRIDE_MP_DATA-FUNC_LOC = <FS_PRIDE_DATA>-FUNC_LOC.
          LS_PRIDE_MP_DATA-MEASURE_POINT = <FS_MPOINT>-POINT.
          LS_PRIDE_MP_DATA-UOM = <FS_MPOINT>-MRNGU.

          MODIFY ZPM_PRIDE_HIER_M FROM LS_PRIDE_MP_DATA.



        ENDLOOP.
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

*    UNPACK WA_GT_LIST-POINT TO WA_GT_LIST-POINT. "----Adding the leading zeros to read data from IMPTT table----"

*    SELECT SINGLE PTTXT FROM IMPTT INTO WA_GT_LIST-PTTXT
*      WHERE POINT EQ WA_GT_LIST-POINT.

*    PACK WA_GT_LIST-POINT TO WA_GT_LIST-POINT. "----Removing the additional zeros added before----"

        APPEND WA_GT_LIST TO GT_LIST.

*----- End ------------------------------------------------------------------------*
*----- Exception Handling from the FM ---------------------------------------------*

*    END_TIME = P_TIME.

*    ENDDO.

      ENDLOOP.
    ELSE.
      EXIT.
    ENDIF.
    CL_BS_PERIOD_TOOLSET_BASICS=>ADD_MINUTES_TO_DATE(
      EXPORTING
        IV_DATE    = START_DATE
        IV_TIME    = START_TIME
        IV_MINUTES = 120
      IMPORTING
        EV_DATE    = END_DATE
        EV_TIME    = END_TIME ).


    START_DATE = END_DATE.
*    END_DATE = P_SDATE.
    START_TIME = END_TIME.

  ENDDO.
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
  LS_FCAT-TABNAME   = 'ZPM_PRIDE_HIER_T'.
  LS_FCAT-JUST = 'L'.
  LS_FCAT-ICON      = 'X'.
  APPEND LS_FCAT TO LT_FCAT.

  LS_FCAT-REPTEXT_DDIC = 'Created Time'.
  LS_FCAT-FIELDNAME = 'C_TIME'.
  LS_FCAT-OUTPUTLEN = '20'.
  LS_FCAT-TABNAME   = 'ZPM_PRIDE_HIER_T'.
  LS_FCAT-JUST = 'L'.
  LS_FCAT-ICON      = 'X'.
  APPEND LS_FCAT TO LT_FCAT.

  LS_FCAT-REPTEXT_DDIC = 'Created Date'.
  LS_FCAT-FIELDNAME = 'C_DATE'.
  LS_FCAT-OUTPUTLEN = '20'.
  LS_FCAT-TABNAME   = 'ZPM_PRIDE_HIER_T'.
  LS_FCAT-JUST = 'L'.
  LS_FCAT-ICON      = 'X'.
  APPEND LS_FCAT TO LT_FCAT.

*      LS_FCAT-REPTEXT_DDIC = 'Created Date'.
*  LS_FCAT-FIELDNAME = 'C_DATE'.
*  LS_FCAT-OUTPUTLEN = '20'.
*  LS_FCAT-TABNAME   = 'ZPM_PRIDE_HIER_T'.
*  LS_FCAT-JUST = 'L'.
*  LS_FCAT-ICON      = 'X'.
*  APPEND LS_FCAT TO LT_FCAT.


  LS_FCAT-REPTEXT_DDIC = 'Equipment'.
  LS_FCAT-FIELDNAME = 'EQUIPMENT'.
  LS_FCAT-OUTPUTLEN = '20'.
  LS_FCAT-TABNAME   = 'ZPM_PRIDE_HIER_T'.
  LS_FCAT-JUST = 'L'.
  LS_FCAT-ICON      = 'X'.
  APPEND LS_FCAT TO LT_FCAT.


  LS_FCAT-REPTEXT_DDIC = 'Functional Location'.
  LS_FCAT-FIELDNAME = 'FUNC_LOC'.
  LS_FCAT-OUTPUTLEN = '20'.
  LS_FCAT-TABNAME   = 'ZPM_PRIDE_HIER_T'.
  LS_FCAT-JUST = 'L'.
  LS_FCAT-ICON      = 'X'.
  APPEND LS_FCAT TO LT_FCAT.


  LS_FCAT-REPTEXT_DDIC = 'MP #'.
  LS_FCAT-FIELDNAME = 'MEASURE_POINT'.
  LS_FCAT-OUTPUTLEN = '4'.
  LS_FCAT-TABNAME   = 'ZPM_PRIDE_HIER_T'.
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
