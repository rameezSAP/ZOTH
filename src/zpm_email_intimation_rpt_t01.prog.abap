*&---------------------------------------------------------------------*
*& Include          ZPM_EMAIL_INTIMATION_RPT_T01
*&---------------------------------------------------------------------*
*FOR GT_MAIN DATA
*TYPES: BEGIN OF TY_MAIN,
*         GLTRP(20)       ," TYPE char,  "Basic Finish Date
*         IWERK(20)       ," TYPE STRING,  "Planing Plant
*         AUFNR(10)       ," TYPE C,       "Order No
*         QMNUM(12)       ,"  TYPE C ,      "Notification No
*         WORK_CENTER(20) ," TYPE STRING,  "Work Center
*         PM_NO(20)       ," TYPE STRING,  "PM NO
*         TECHNICAL_ID(20)," TYPE STRING,  "Technical ID
*         ERROR(100)      ," TYPE STRING,  "Error
*
*       END OF TY_MAIN.

*Data Decleration
TYPES: BEGIN OF TY_BINARY,
         LINE TYPE X LENGTH 255,         "Binary Data
       END OF TY_BINARY.

DATA : GT_MAIN        TYPE ZPM_EMAIL_INTIMATION_TT,
       GT_MAIN_TMP    TYPE ZPM_EMAIL_INTIMATION_TT,
       GS_MAIN        TYPE ZPM_EMAIL_INTIMATION_ST,
       W_OTF          TYPE FPFORMOUTPUT,
       SEND_REQUEST   TYPE REF TO CL_BCS,
       MESSAGE_BODY   TYPE BCSY_TEXT,
       W_SUBJECT(50)  TYPE C,
       DOCUMENT       TYPE REF TO CL_DOCUMENT_BCS,
       GV_SEND        TYPE AD_SMTPADR,
       RECIPIENT      TYPE REF TO IF_RECIPIENT_BCS,
       LV_SENT_TO_ALL TYPE OS_BOOLEAN,
       G_OBJCONT      TYPE STANDARD TABLE OF TY_BINARY.
DATA LT_TEMP_MESSAGES           TYPE STANDARD TABLE OF BALM..
DATA LV_CHK(20).
DATA LV_CHK_DATA_DOC(1).
DATA LV_CHK_DATA(20).



*For ALV
DATA: IT_FIELDCAT TYPE LVC_T_FCAT,
      LS_FIELDCAT TYPE LVC_S_FCAT.
DATA:V_FIELDNAME TYPE FIELDNAME,
     V_SELTEXT   TYPE SCRTEXT_L,
     LR_DATA     TYPE REF TO DATA,
     LR_TABDESCR TYPE REF TO CL_ABAP_STRUCTDESCR,
     LT_DFIES    TYPE DDFIELDS,
     LS_DFIES    TYPE DFIES,
     LS_VARIANT  TYPE DISVARIANT.
