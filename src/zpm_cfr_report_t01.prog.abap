*&---------------------------------------------------------------------*
*& Include          ZPM_CFR_REPORT_T01
*&---------------------------------------------------------------------*

*DataDeclaration

DATA:GT_MAIN     TYPE ZPM_CRF_REPORT_F_TT,
     GS_MAIN     LIKE LINE OF GT_MAIN,
     GS_LV_CHECK TYPE ZPM_CRF_REPORT_LV_ST.

*Bapi DataDeclaration

DATA:GS_PO_HEADER                  TYPE  BAPIEKKOL,
     GT_PO_ITEMS                   TYPE STANDARD TABLE OF  BAPIEKPO,
     GT_PO_ITEM_ACCOUNT_ASSIGNMENT TYPE STANDARD TABLE OF  BAPIEKKN,
     GT_PO_ITEM_SERVICES           TYPE STANDARD TABLE OF  BAPIESLL,
     GT_RETURN                     TYPE STANDARD TABLE OF  BAPIRETURN.

*Split Fuction location DataDeclaration

DATA:S1 TYPE STRING,
     S2 TYPE STRING,
     S3 TYPE STRING,
     S4 TYPE STRING,
     S5 TYPE STRING,
     S6 TYPE STRING.



*For Zone Location Text
DATA: FUNCTLOCATION             TYPE BAPI_ITOB_PARMS-FUNCLOC_INT,
      REQUEST_INSTALLATION_DATA TYPE XFELD,
      DATA_GENERAL_EXP          TYPE BAPI_ITOB,
      DATA_SPECIFIC_EXP         TYPE BAPI_ITOB_FL_ONLY,
      RETURN_ZONE               TYPE BAPIRET2,
      DATA_INSTALLATION         TYPE BAPI_ITOB_INSTALLATION_DETAILS,
      EXTENSIONOUT_ZONE         TYPE STANDARD TABLE OF BAPIPAREX,
      LV_ZONE                   TYPE STRING.
