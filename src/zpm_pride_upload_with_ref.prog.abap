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
REPORT ZPM_PRIDE_UPLOAD_WITH_REF.
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
DATA: G_ID      TYPE VRM_ID,
      G_VALUES  TYPE VRM_VALUES,
      WA_VALUES LIKE LINE OF G_VALUES.
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
  " PARAMETERS: P_LOAD TYPE  RLGRAP-FILENAME OBLIGATORY. "OBLIGATORY DEFAULT 'D:\Users\nouman.butt\Desktop\testload.xls'.
  PARAMETERS: P_LOC TYPE   ZPM_PRIDE_ROUTES-LOCATION AS LISTBOX VISIBLE LENGTH 10 OBLIGATORY. "OBLIGATORY DEFAULT 'D:\Users\nouman.butt\Desktop\testload.xls'.
  PARAMETERS: P_ROUTE TYPE   ZPM_PRIDE_ROUT_T-ROUTE_ID AS LISTBOX VISIBLE LENGTH 50. " OBLIGATORY." OBLIGATORY DEFAULT 'D:\Users\nouman.butt\Desktop\testload.xls'.
  PARAMETERS: P_SDATE TYPE   ZPM_PRIDE_ROUTES-S_DATE ." OBLIGATORY. "OBLIGATORY DEFAULT 'D:\Users\nouman.butt\Desktop\testload.xls'.
  PARAMETERS: P_TIME TYPE   ZPM_PRIDE_ROUTES-S_TIME." OBLIGATORY. "OBLIGATORY DEFAULT 'D:\Users\nouman.butt\Desktop\testload.xls'.
  PARAMETERS: P_EDATE TYPE   ZPM_PRIDE_ROUTES-S_DATE. "  OBLIGATORY. "OBLIGATORY DEFAULT 'D:\Users\nouman.butt\Desktop\testload.xls'.
  PARAMETERS: P_ETIME TYPE   ZPM_PRIDE_ROUTES-S_TIME. " OBLIGATORY. "OBLIGATORY DEFAULT 'D:\Users\nouman.butt\Desktop\testload.xls'.

  PARAMETERS: P_SCH TYPE  ZPM_PRIDE_ROUTES-SECHEDULE AS LISTBOX VISIBLE LENGTH 10." OBLIGATORY. "OBLIGATORY DEFAULT 'D:\Users\nouman.butt\Desktop\testload.xls'.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 1.
    SELECTION-SCREEN COMMENT 10(50) TEXT-001.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 2.
    SELECTION-SCREEN COMMENT 10(48) TEXT-002.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK B1 .
*

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_LOC.
*  PERFORM F4_ROUTE.

AT SELECTION-SCREEN OUTPUT.
*AT SELECTION-SCREEN ON P_LOC.
*  PERFORM F4_ROUTE.
*
*  CALL FUNCTION 'F4_FILENAME'
*    EXPORTING
*      FIELD_NAME = 'P_LOAD'
*    IMPORTING
*      FILE_NAME  = P_LOAD.
  IF P_ROUTE IS  INITIAL AND P_LOC IS NOT INITIAL.
    MESSAGE W023(ZPM_PRIDE_MSG).
    STOP.

    "   MESSAGE 'Please enter Route' TYPE 'W' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF P_EDATE IS  INITIAL AND P_LOC IS NOT INITIAL.
    SET CURSOR FIELD P_LOC.
    MESSAGE W021(ZPM_PRIDE_MSG).
    STOP.
    LEAVE LIST-PROCESSING.
    "   MESSAGE 'Please enter End Date' TYPE 'W' DISPLAY LIKE 'E'.
  ENDIF.

  IF P_SDATE IS  INITIAL AND P_LOC IS NOT INITIAL.
    SET CURSOR FIELD P_LOC.
    MESSAGE W022(ZPM_PRIDE_MSG)." with 'matnr is empty'.
    STOP.

    LEAVE LIST-PROCESSING.
    "  ' MESSAGE 'Please enter start date' TYPE 'W' DISPLAY LIKE 'E'.
  ENDIF.

  IF P_SCH IS  INITIAL AND P_LOC IS NOT INITIAL.
    SET CURSOR FIELD P_LOC.
    MESSAGE W024(ZPM_PRIDE_MSG)." with 'matnr is empty'.
    STOP.

    LEAVE LIST-PROCESSING.
    "   MESSAGE 'Please enter start date' TYPE 'W' DISPLAY LIKE 'E'.
  ENDIF.


AT SELECTION-SCREEN.
*  PERFORM F4_ROUTE.

  "INITIALIZATION.
  TYPE-POOLS: VRM.
  TYPES: BEGIN OF TY_ROUTE,
           ROUTE_ID   TYPE ZPM_PRIDE_ROUT_T-ROUTE_ID,
           ROUTE_NAME TYPE ZPM_PRIDE_ROUT_T-ROUTE_NAME,
         END OF TY_ROUTE.

  DATA LT_ROUTE TYPE STANDARD TABLE OF TY_ROUTE.
  DATA LS_ROUTE TYPE  TY_ROUTE.
  CLEAR G_VALUES[].
  IF P_LOC IS NOT INITIAL.
    SELECT  ROUTE_ID, ROUTE_NAME FROM ZPM_PRIDE_ROUT_T INTO TABLE @LT_ROUTE WHERE LOCATION = @P_LOC. " where ACTIVE = 'X'.
    IF SY-SUBRC = 0.
      LOOP AT LT_ROUTE ASSIGNING FIELD-SYMBOL(<FS_ROUTE>).
        WA_VALUES-KEY = <FS_ROUTE>-ROUTE_ID.
        WA_VALUES-TEXT = <FS_ROUTE>-ROUTE_NAME.
        APPEND WA_VALUES TO G_VALUES.
      ENDLOOP.
      G_ID = 'P_ROUTE'.
      PERFORM LISTBOX.
    ELSE.
      MESSAGE 'No Route present in the selection Location' TYPE 'W' DISPLAY LIKE 'E'.
    ENDIF.
  ELSE.
    MESSAGE 'Please enter Route' TYPE 'W' DISPLAY LIKE 'E'.
  ENDIF.

START-OF-SELECTION.

  PERFORM F_GET_DATA.
  PERFORM F_PROCESS_DATA.
  PERFORM F_LIST_DATA.

END-OF-SELECTION.

FORM LISTBOX.
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID     = G_ID
      VALUES = G_VALUES
*       EXCEPTIONS
*     ID_ILLEGAL_NAME       = 1
*     OTHERS = 2
    .
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.
FORM F_GET_DATA.
*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*

  DATA : LV_FNAME LIKE  RLGRAP-FILENAME.
  SELECT SINGLE * FROM ZPM_PRIDE_ROUT_T INTO @DATA(LS_ROUTE_MAIN)
    WHERE  ROUTE_ID = @P_ROUTE.
  IF SY-SUBRC = 0.
    MOVE-CORRESPONDING LS_ROUTE_MAIN TO LS_PRIDE_DATA.

    SELECT * FROM ZPM_PRIDE_RDET_T
      INTO TABLE @DATA(LT_ROUTE_DETAILS)
      WHERE ROUTE_ID = @LS_PRIDE_DATA-ROUTE_ID
      AND ACTIVE = 'X'.

    IF LT_ROUTE_DETAILS[] IS NOT INITIAL.
*      SELECT * FROM ZPM_PRIDE_HIER_M
**      SELECT * FROM ZI_PM_PRIDE_ROUTE_MP_TEMP_M
*        INTO TABLE @DATA(LT_ROUTE_MP)
*        FOR ALL ENTRIES IN @LT_ROUTE_DETAILS
*        WHERE ROUTEID = @LT_ROUTE_DETAILS-ROUTE_ID
*        AND ISACTIVE = 'X'.
      SELECT mp~* FROM ZPM_PRIDE_ROMP_T AS MP
        JOIN ZPM_PRIDE_RDET_T AS DET ON MP~EQUIPMENT = DET~EQUIPMENT AND MP~ROUTE_ID = DET~ROUTE_ID and det~ACTIVE = 'X'
*      SELECT * FROM ZI_PM_PRIDE_ROUTE_MP_TEMP_M
        INTO TABLE @DATA(LT_ROUTE_MP)
        FOR ALL ENTRIES IN @LT_ROUTE_DETAILS
        WHERE mp~ROUTE_ID = @LT_ROUTE_DETAILS-ROUTE_ID
        AND mp~ACTIVE = 'X'.
    ENDIF.
  ELSE.
    MESSAGE 'Please select correct RouteID' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

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
*  IF LT_PRIDE_DATA[] IS NOT INITIAL.
*    SELECT EQUNR,MPOBJ,POINT,MRNGU FROM IMPTT
*      JOIN EQUI ON EQUI~OBJNR = IMPTT~MPOBJ
*      INTO TABLE @DATA(LT_MPOINT)
*      FOR ALL ENTRIES IN @LT_PRIDE_DATA
*    WHERE EQUNR = @LT_PRIDE_DATA-EQUIPMENT
*      .
*  ENDIF.

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

*      LOOP AT LT_PRIDE_DATA ASSIGNING FIELD-SYMBOL(<FS_PRIDE_DATA>) .
*      MOVE-CORRESPONDING  to LS_PRIDE_ROUTES

*    DO 4 TIMES.
*        CLEAR LS_PRIDE_ROUTES.
*        MOVE-CORRESPONDING <FS_PRIDE_DATA> TO LS_PRIDE_ROUTES.
      LS_PRIDE_ROUTES-LOCATION  = P_LOC.
      LS_PRIDE_ROUTES-ROUTE_ID = LV_NUMBER+12(8).
      LS_PRIDE_ROUTES-ROUTE_REF_ID = LS_PRIDE_DATA-ROUTE_ID.
      LS_PRIDE_ROUTES-ROUTE_NAME = P_ROUTE.
      LS_PRIDE_ROUTES-S_DATE = END_DATE.
      LS_PRIDE_ROUTES-E_DATE = END_DATE.
      LS_PRIDE_ROUTES-S_TIME = END_TIME.
      LS_PRIDE_ROUTES-E_TIME = END_TIME.
*        LS_PRIDE_ROUTES-LOCATION = P_LOC.
      LS_PRIDE_ROUTES-SECHEDULE = P_SCH.
      MODIFY ZPM_PRIDE_ROUTES FROM LS_PRIDE_ROUTES.

      CLEAR LS_PRIDE_ROUTES_T.
      REFRESH LT_PRIDE_ROUTES_T[].
*      MOVE-CORRESPONDING LT_ROUTE_DETAILS[] TO LT_PRIDE_ROUTES_T[] .
      LOOP AT LT_ROUTE_DETAILS ASSIGNING FIELD-SYMBOL(<FS_RT_DET>).
        MOVE-CORRESPONDING <FS_RT_DET> TO LS_PRIDE_ROUTES_T.
        LS_PRIDE_ROUTES_T-ROUTE_ID = LS_PRIDE_ROUTES-ROUTE_ID.
        LS_PRIDE_ROUTES_T-ACTIVE = 'X'.
        APPEND LS_PRIDE_ROUTES_T TO LT_PRIDE_ROUTES_T.
      ENDLOOP.

*      MOVE-CORRESPONDING LT_ROUTE_MP TO LT_PRIDE_MP_DATA[] .
      REFRESH LT_PRIDE_MP_DATA[].
      LOOP AT LT_ROUTE_MP ASSIGNING FIELD-SYMBOL(<FS_RT_DET_MP>).
        MOVE-CORRESPONDING <FS_RT_DET_MP> TO LS_PRIDE_MP_DATA.
        LS_PRIDE_MP_DATA-ROUTE_ID = LS_PRIDE_ROUTES-ROUTE_ID.
        LS_PRIDE_MP_DATA-FUNC_LOC = <FS_RT_DET_MP>-FUNC_LOC.
        LS_PRIDE_MP_DATA-ACTIVE = 'X'.
        APPEND LS_PRIDE_MP_DATA TO LT_PRIDE_MP_DATA.
      ENDLOOP.

*        LS_PRIDE_ROUTES_T-ROUTE_ID = LS_PRIDE_ROUTES-ROUTE_ID.
*        LS_PRIDE_ROUTES_T-FUNC_LOC = <FS_PRIDE_DATA>-FUNC_LOC.
*        LS_PRIDE_ROUTES_T-EQUIPMENT = <FS_PRIDE_DATA>-EQUIPMENT.
      IF LT_PRIDE_ROUTES_T[] IS NOT INITIAL.
        MODIFY ZPM_PRIDE_HIER_T FROM TABLE LT_PRIDE_ROUTES_T.
      ENDIF.
      IF LT_PRIDE_MP_DATA[] IS NOT INITIAL.
        MODIFY ZPM_PRIDE_HIER_M FROM TABLE LT_PRIDE_MP_DATA.
      ENDIF.

*      PERFORM NUMBERING CHANGING LV_NUMBER.




*        LOOP AT LT_MPOINT ASSIGNING FIELD-SYMBOL(<FS_MPOINT>) WHERE EQUNR = <FS_PRIDE_DATA>-EQUIPMENT .
*          CLEAR LS_PRIDE_MP_DATA.
*          LS_PRIDE_MP_DATA-ROUTE_ID = LS_PRIDE_ROUTES-ROUTE_ID.
*          LS_PRIDE_MP_DATA-EQUIPMENT = <FS_PRIDE_DATA>-EQUIPMENT.
*          LS_PRIDE_MP_DATA-FUNC_LOC = <FS_PRIDE_DATA>-FUNC_LOC.
*          LS_PRIDE_MP_DATA-MEASURE_POINT = <FS_MPOINT>-POINT.
*          LS_PRIDE_MP_DATA-UOM = <FS_MPOINT>-MRNGU.
*
*          MODIFY ZPM_PRIDE_HIER_M FROM LS_PRIDE_MP_DATA.
*
*
*
*        ENDLOOP.
      LOOP AT LT_PRIDE_MP_DATA ASSIGNING FIELD-SYMBOL(<FS_PRIDE_DATA>).

*        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
*             INTO LV_MESSAGE. "Moving error message to variable lv_message
*        LV_MESSAGE = 'Route Name: ' && <FS_PRIDE_DATA>-ROUTE_ID && 'Func Location : ' &&  <FS_PRIDE_DATA>-FUNC_LOC && 'Equipment: ' && <FS_PRIDE_DATA>-FUNC_LOC.
**      MOVE LV_MESSAGE TO WA_GT_LIST-MESSAGE. "Moving lv_message variable to work area for gt_list
*        MOVE <FS_PRIDE_DATA>-ROUTE_ID TO WA_GT_LIST-POINT. "Moving point variable value to corresponding in gt_list work area
*        WA_GT_LIST-INDEX = WA_GT_LIST-INDEX + 1.
*
*        IF SY-MSGTY EQ 'E'. "Error light Icon
*          WRITE ICON_RED_LIGHT AS ICON TO WA_GT_LIST-ICON.
*        ELSEIF SY-MSGTY EQ 'W' OR SY-MSGTY EQ 'I'. "Warning Light Icon
*          WRITE ICON_YELLOW_LIGHT AS ICON TO WA_GT_LIST-ICON.
*        ELSE.
*          WRITE ICON_GREEN_LIGHT AS ICON TO WA_GT_LIST-ICON. "OK / Success, Green ligtht Icon
*        ENDIF.
*
*      ELSE. "If NO error Occurred
        MOVE-CORRESPONDING LS_PRIDE_MP_DATA TO WA_GT_LIST.
        MOVE LS_PRIDE_ROUTES-S_DATE TO WA_GT_LIST-C_DATE.
        MOVE LS_PRIDE_ROUTES-S_TIME TO WA_GT_LIST-C_TIME.
*        move LS_PRIDE_ROUTES-S_DATE to WA_GT_LIST-.
        WA_GT_LIST-ROUTE_NAME = P_ROUTE.
*          MOVE <FS_PRIDE_DATA>- TO WA_GT_LIST.

        MOVE LS_IMRG-POINT TO WA_GT_LIST-POINT. "Moving point variable value to corresponding in gt_list work area
        WRITE ICON_GREEN_LIGHT AS ICON TO WA_GT_LIST-ICON. "OK / Success, Green ligtht Icon
        WRITE 'Success' TO WA_GT_LIST-MESSAGE. "Moving error message to work are variable for message
        WA_GT_LIST-INDEX = WA_GT_LIST-INDEX + 1.
      ENDLOOP.
*        ENDIF.

*    UNPACK WA_GT_LIST-POINT TO WA_GT_LIST-POINT. "----Adding the leading zeros to read data from IMPTT table----"

*    SELECT SINGLE PTTXT FROM IMPTT INTO WA_GT_LIST-PTTXT
*      WHERE POINT EQ WA_GT_LIST-POINT.

*    PACK WA_GT_LIST-POINT TO WA_GT_LIST-POINT. "----Removing the additional zeros added before----"

      APPEND WA_GT_LIST TO GT_LIST.

*----- End ------------------------------------------------------------------------*
*----- Exception Handling from the FM ---------------------------------------------*

*    END_TIME = P_TIME.

*    ENDDO.

*      ENDLOOP.
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
*  LOOP AT ITAB.
*
*    MOVE-CORRESPONDING ITAB TO LS_PRIDE_DATA.
*    MOVE-CORRESPONDING ITAB TO LS_PRIDE_MP_DATA.
*
*    APPEND LS_PRIDE_DATA TO LT_PRIDE_DATA. "Moving Work Area for LS_IMRG to the bottom line of LS_IMRG
*    APPEND LS_PRIDE_MP_DATA TO LT_PRIDE_MP_DATA. "Moving Work Area for LS_IMRG to the bottom line of LS_IMRG
*
*  ENDLOOP.
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
*        LS_PRIDE_ROUTES-LOCATION = P_LOC.
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
*&---------------------------------------------------------------------*
*& Form f4_route
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4_ROUTE .
*SELECT sprsl sptxt
*FROM t002t
*INTO CORRESPONDING FIELDS OF TABLE itab_language WHERE spras = ‘EN’.
*IF sy-subrc = 0.
*CALL FUNCTION ‘F4IF_INT_TABLE_VALUE_REQUEST’
*EXPORTING
*retfield        = ‘SPRSL’
*value_org       = ‘S’
*TABLES
*value_tab       = itab_language
*EXCEPTIONS
*parameter_error = 1
*no_values_found = 2
*OTHERS          = 3.
*ELSE.
*EXIT.
*MESSAGE ‘Error’ TYPE ‘S’ DISPLAY LIKE ‘E’.
*ENDIF.
*
*ENDMODULE.

*  LOOP AT LT_ROUTE ASSIGNING FIELD-SYMBOL(<FS_ROUTE>).
  REFRESH G_VALUES[].
  WA_VALUES-KEY = 'BD'.
  WA_VALUES-TEXT = 'BADIN'.
  APPEND WA_VALUES TO G_VALUES.

  G_ID = 'P_LOC'.
  PERFORM LISTBOX.
  SELECT ROUTE_ID ,ROUTE_NAME   FROM ZPM_PRIDE_ROUT_T INTO TABLE @DATA(LT_ROUTE) .

ENDFORM.
