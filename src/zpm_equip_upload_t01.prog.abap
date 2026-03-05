*&---------------------------------------------------------------------*
*& Include          ZPM_PRIDE_TEMPLATE_UPLOAD_T01
*&---------------------------------------------------------------------*

TYPE-POOLS : TRUXS,SLIS,ICON,VRM.
TABLES IMRG.

*--------Table definition for entry of data from Excel-------------------"
*--------Used in FM "TEXT_CONVERT_XLS_TO_SAP"----------------------------"

DATA : BEGIN OF ITAB OCCURS 0,
         EQUIPMENT     TYPE  CHAR30,
         MEASURE_POINT TYPE  CHAR30,
         VALUE         TYPE  CHAR30,
       END OF ITAB.

DATA : WA_ITAB LIKE LINE OF ITAB. "Work Area for table ITAB"

*--------Table definition for Measuring Document Entry-------------------"
*--------Used in FM "MEASUREM_DOCUM_RFC_SINGLE_001"----------------------"

DATA : BEGIN OF LS_IMRG OCCURS 0,  "ls_imrg table defines : POINT, ITIME, IDATE, CNTRC, CDIFC, READR, STEXT.
         POINT(12)     TYPE C,
         ITIME         TYPE TIMS, "imrg-itime,       "Time of Recording
         IDATE         TYPE DATS, "imrg-idate,       "Data of Recording
         CNTRC(22)     TYPE C,    "Counter Value (current reading) *Only used if counter difference field not used
         CDIFC(1)      TYPE C,    "Difference in Counter Value from last entry *Only used if Counter value not used
         READR(12)     TYPE C,    "Name of Reader
         STEXT(40)     TYPE C,
         ROUTE_NAME    TYPE  CHAR50,
         ROUTE_ID      TYPE  CHAR30,
         C_DATE        TYPE  CHAR10,
         C_TIME        TYPE  CHAR10,
*         FUNC_LOC      TYPE  CHAR30,
         EQUIPMENT     TYPE  CHAR30,
         MEASURE_POINT TYPE  CHAR30,
       END OF LS_IMRG.

TYPES : BEGIN OF TY_UPLOAD ,  "ls_imrg table defines : POINT, ITIME, IDATE, CNTRC, CDIFC, READR, STEXT.
          EQUIPMENT TYPE  CHAR30,
          TEXT      TYPE STRING,
        END OF TY_UPLOAD.

DATA: LS_DATA TYPE TY_UPLOAD. "Work Area for LS_IMRG table"
DATA: LT_DATA LIKE TABLE OF LS_DATA. "Work Area for LS_IMRG table"

*DATA: LS_PRIDE_MP_DATA TYPE ZPM_PRIDE_ROMP_T. "Work Area for LS_IMRG table"
*DATA: LT_PRIDE_MP_DATA LIKE TABLE OF LS_PRIDE_MP_DATA. "Work Area for LS_IMRG table"

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

DATA: NAME  TYPE VRM_ID,
      LIST  TYPE VRM_VALUES,
      VALUE LIKE LINE OF LIST.
