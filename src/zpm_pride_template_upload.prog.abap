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
REPORT ZPM_PRIDE_TEMPLATE_UPLOAD.

INCLUDE ZPM_PRIDE_TEMPLATE_UPLOAD_T01.
INCLUDE ZPM_PRIDE_TEMPLATE_UPLOAD_S01.
INCLUDE ZPM_PRIDE_TEMPLATE_UPLOAD_F01.





AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_LOAD.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      FIELD_NAME = 'P_LOAD'
    IMPORTING
      FILE_NAME  = P_LOAD.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_LOC.

  SELECT * FROM ZPM_PRIDE_PLANTS INTO TABLE @DATA(LT_PLANT).
  LOOP AT LT_PLANT ASSIGNING FIELD-SYMBOL(<FS_PLANT>).
    VALUE = <FS_PLANT>-PLANT.
    APPEND VALUE TO LIST.
  ENDLOOP.
  NAME = 'P_LOC'.
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID              = NAME
      VALUES          = LIST
    EXCEPTIONS
      ID_ILLEGAL_NAME = 1
      OTHERS          = 2.

START-OF-SELECTION.

  PERFORM F_GET_DATA.
  PERFORM F_PROCESS_DATA.
  PERFORM F_LIST_DATA.

END-OF-SELECTION.
