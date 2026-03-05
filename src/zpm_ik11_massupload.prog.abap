*&**********************************************************************
*&   Author           : Adnan Khan                                  *
*&   Date             : 09.08.2022                              *
*&   Company          : UEP                                         *
*&   Program Name     : ZPM_IK11_MASSUPLOAD                         *
*&   LDB Used         :                                                *
*&**********************************************************************
*& Program Definition :          *
*                                                                      *
*&                            ()                             *
*&**********************************************************************
*& PROGRAM CHANGES / Modification Logs :                               *
*&**********************************************************************
*&   Date   I Request    I Programmer   I     Changes                  *
*&+-------------------------------------------------------------------+*
*&          I            I              I                              *
*&+-------------------------------------------------------------------+*
REPORT ZPM_IK11_MASSUPLOAD.
TYPE-POOLS : TRUXS,SLIS,ICON.
TABLES IMRG.

*--------Table definition for entry of data from Excel-------------------"
*--------Used in FM "TEXT_CONVERT_XLS_TO_SAP"----------------------------"

DATA : BEGIN OF ITAB OCCURS 0,  "itab table defines : POINT, ITIME, IDATE, CNTRC, CDIFC, READR, STEXT.
         POINT TYPE CHAR30, " imrg-point,
         ITIME TYPE CHAR30, "imrg-itime,       "Time of Recording
         IDATE TYPE CHAR30, "limrg-idate,       "Data of Recording
         CNTRC TYPE CHAR30, "imrg-readg,       "Counter Value (current reading) *Only used if counter difference field not used
         CDIFC TYPE CHAR30, "imrg-readg,       "Difference in Counter Value from last entry *Only used if Counter value not used
         READR TYPE CHAR30, "imrg-readr,       "Name of Reader
         STEXT TYPE CHAR30, "imrg-mdtxt,
       END OF ITAB.

DATA : WA_ITAB LIKE LINE OF ITAB. "Work Area for table ITAB"

*--------Table definition for Measuring Document Entry-------------------"
*--------Used in FM "MEASUREM_DOCUM_RFC_SINGLE_001"----------------------"

DATA : BEGIN OF LS_IMRG OCCURS 0,  "ls_imrg table defines : POINT, ITIME, IDATE, CNTRC, CDIFC, READR, STEXT.
         POINT(12) TYPE C,
         ITIME     TYPE TIMS, "imrg-itime,       "Time of Recording
         IDATE     TYPE DATS, "imrg-idate,       "Data of Recording
         CNTRC(22) TYPE C,    "Counter Value (current reading) *Only used if counter difference field not used
*         CDIFC(22)  TYPE C,    "Difference in Counter Value from last entry *Only used if Counter value not used
         CDIFC(1)  TYPE C,    "Difference in Counter Value from last entry *Only used if Counter value not used
         READR(12) TYPE C,    "Name of Reader
         STEXT(40) TYPE C,
       END OF LS_IMRG.

DATA: WA_LS_IMRG LIKE LINE OF LS_IMRG. "Work Area for LS_IMRG table"

*---------Table for Result Sheet Display------------"
*---------Used in FORM "F_List_Data"----------------"

DATA : BEGIN OF GT_LIST OCCURS 0, "gt_list table defines : INDEX, POINT, PTTXT (Text for MP Description), ICON, MESSAGE(Return Message)
         INDEX        TYPE I,
         POINT        LIKE IMPTT-POINT,
         PTTXT(20)    TYPE C,
         ICON         TYPE CHAR4,
         MESSAGE(100) TYPE C,
       END OF   GT_LIST.

DATA : WA_GT_LIST LIKE LINE OF  GT_LIST. "Work Area for table GT_LIST"

DATA: IT_RAW              TYPE TRUXS_T_TEXT_DATA,
      LS_MRECEIPT_LIST_EX TYPE IMRG,
      OUT_RETURN          TYPE IMRG OCCURS 0.

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-003.
  PARAMETERS: P_LOAD TYPE  RLGRAP-FILENAME OBLIGATORY. "OBLIGATORY DEFAULT 'D:\Users\nouman.butt\Desktop\testload.xls'.
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

  LV_FNAME = P_LOAD.

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      I_FIELD_SEPERATOR    = 'X'
      I_LINE_HEADER        = ''
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

    WA_LS_IMRG-POINT = ITAB-POINT. "Copying point value from ITAB to LS_IMRG

    REPLACE ALL OCCURRENCES OF ':' IN ITAB-ITIME WITH ''. "Removing of : from time format
    TRANSLATE ITAB-ITIME USING '0'.
    WA_LS_IMRG-ITIME = ITAB-ITIME. "Copying point value from ITAB to LS_IMRG
*    CONDENSE wa_ls_imrg-itime. "Condensing value in itime variable for spaces

    IF ( ITAB-IDATE+1(1) EQ '.').
      REPLACE ALL OCCURRENCES OF '.' IN ITAB-IDATE WITH ''. "Removing of . from date format
      CONCATENATE ITAB-IDATE+3(4) ITAB-IDATE+1(2) '0' ITAB-IDATE(1) INTO WA_LS_IMRG-IDATE. "Copying idate value from ITAB to LS_IMRG while removing periods and fixing format
    ELSE. " ( itab-idate+1(1)  '.' ).
      REPLACE ALL OCCURRENCES OF '.' IN ITAB-IDATE WITH ''. "Removing of . from date format
      CONCATENATE ITAB-IDATE+4(4) ITAB-IDATE+2(2) ITAB-IDATE(2) INTO WA_LS_IMRG-IDATE. "Copying idate value from ITAB to LS_IMRG while removing periods and fixing format
    ENDIF.

*    wa_ls_imrg-idate = itab-idate.
    WA_LS_IMRG-CNTRC = ITAB-CNTRC. "Copying cntrc value from ITAB to LS_IMRG
    WA_LS_IMRG-CDIFC = ITAB-CDIFC. "Copying cdifc value from ITAB to LS_IMRG
    WA_LS_IMRG-READR = ITAB-READR. "Copying readr value from ITAB to LS_IMRG
    WA_LS_IMRG-STEXT = ITAB-STEXT. "Copying stext value from ITAB to LS_IMRG

    APPEND WA_LS_IMRG TO LS_IMRG. "Moving Work Area for LS_IMRG to the bottom line of LS_IMRG

  ENDLOOP.
*----- End ------------------------------------------------------------------------*
*----- Converting the format of excel input to the accepted format for FM----------*

ENDFORM.                    " F_GET_DATA

FORM F_PROCESS_DATA.
*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
  DATA : LV_MESSAGE(100) TYPE C.
  BREAK AC_ADNAN.
*  DELETE LS_IMRG INDEX 1.
  LOOP AT LS_IMRG.

    CALL FUNCTION 'MEASUREM_DOCUM_RFC_SINGLE_001'
      EXPORTING
        MEASUREMENT_POINT    = LS_IMRG-POINT "ls_mreceipt_list-point
*       secondary_index      = ls_mreceipt_list-secondary_index
        READING_DATE         = LS_IMRG-IDATE "lv_reading_date
        READING_TIME         = LS_IMRG-ITIME "lv_reading_time
        SHORT_TEXT           = LS_IMRG-STEXT "ls_mreceipt_list-mdtxt
        READER               = LS_IMRG-READR "ls_mreceipt_list-readr
        ORIGIN_INDICATOR     = 'A'
*       reading_after_action = ls_mreceipt_list-docaf
*       recorded_unit        = ls_mreceipt_list-recdu
        RECORDED_VALUE       = LS_IMRG-CNTRC "ls_mreceipt_list-recdv
        DIFFERENCE_READING   = LS_IMRG-CDIFC "ls_mreceipt_list-idiff
*       code_catalogue       = ls_mreceipt_list-codct
*       code_group           = ls_mreceipt_list-codgr
*       valuation_code       = ls_mreceipt_list-vlcod
*       code_version         = ls_mreceipt_list-cvers
*       check_custom_duprec  = ls_mreceipt_list-check_custom_duprec
        PREPARE_UPDATE       = 'X'
        COMMIT_WORK          = 'X'
        WAIT_AFTER_COMMIT    = 'X'
*       create_notification  = ls_mreceipt_list-create_notification
*       notification_type    = ls_mreceipt_list-notification_type
*       notification_prio    = ls_mreceipt_list-notification_prio
      IMPORTING
        COMPLETE_DOCUMENT    = LS_MRECEIPT_LIST_EX
      EXCEPTIONS
        NO_AUTHORITY         = 1
        POINT_NOT_FOUND      = 2
        INDEX_NOT_UNIQUE     = 3
        TYPE_NOT_FOUND       = 4
        POINT_LOCKED         = 5
        POINT_INACTIVE       = 6
        TIMESTAMP_IN_FUTURE  = 7
        TIMESTAMP_DUPREC     = 8
        UNIT_UNFIT           = 9
        VALUE_NOT_FLTP       = 10
        VALUE_OVERFLOW       = 11
        VALUE_UNFIT          = 12
        VALUE_MISSING        = 13
        CODE_NOT_FOUND       = 14
        NOTIF_TYPE_NOT_FOUND = 15
        NOTIF_PRIO_NOT_FOUND = 16
        NOTIF_GENER_PROBLEM  = 17
        UPDATE_FAILED        = 18
        OTHERS               = 19.

*----- Exception Handling from the FM ---------------------------------------------*
*----- Start ----------------------------------------------------------------------*

    IF SY-SUBRC <> 0. "If error occured

      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
           INTO LV_MESSAGE. "Moving error message to variable lv_message

      MOVE LV_MESSAGE TO WA_GT_LIST-MESSAGE. "Moving lv_message variable to work area for gt_list
      MOVE LS_IMRG-POINT TO WA_GT_LIST-POINT. "Moving point variable value to corresponding in gt_list work area
      WA_GT_LIST-INDEX = WA_GT_LIST-INDEX + 1.

      IF SY-MSGTY EQ 'E'. "Error light Icon
        WRITE ICON_RED_LIGHT AS ICON TO WA_GT_LIST-ICON.
      ELSEIF SY-MSGTY EQ 'W' OR SY-MSGTY EQ 'I'. "Warning Light Icon
        WRITE ICON_YELLOW_LIGHT AS ICON TO WA_GT_LIST-ICON.
      ELSE.
        WRITE ICON_GREEN_LIGHT AS ICON TO WA_GT_LIST-ICON. "OK / Success, Green ligtht Icon
      ENDIF.

    ELSE. "If NO error Occurred

      MOVE LS_IMRG-POINT TO WA_GT_LIST-POINT. "Moving point variable value to corresponding in gt_list work area
      WRITE ICON_GREEN_LIGHT AS ICON TO WA_GT_LIST-ICON. "OK / Success, Green ligtht Icon
      WRITE 'Success' TO WA_GT_LIST-MESSAGE. "Moving error message to work are variable for message
      WA_GT_LIST-INDEX = WA_GT_LIST-INDEX + 1.

    ENDIF.

    UNPACK WA_GT_LIST-POINT TO WA_GT_LIST-POINT. "----Adding the leading zeros to read data from IMPTT table----"

    SELECT SINGLE PTTXT FROM IMPTT INTO WA_GT_LIST-PTTXT
      WHERE POINT EQ WA_GT_LIST-POINT.

    PACK WA_GT_LIST-POINT TO WA_GT_LIST-POINT. "----Removing the additional zeros added before----"

    APPEND WA_GT_LIST TO GT_LIST.

*----- End ------------------------------------------------------------------------*
*----- Exception Handling from the FM ---------------------------------------------*

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

  LS_FCAT-REPTEXT_DDIC = 'MP #'.
  LS_FCAT-FIELDNAME = 'point'.
  LS_FCAT-OUTPUTLEN = '4'.
  LS_FCAT-TABNAME   = 'IMPTT'.
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
