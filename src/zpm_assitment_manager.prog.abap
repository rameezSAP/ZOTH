*&**********************************************************************
*&   Author           : Adnnan Khan                              *
*&   Date             : 30.08.2022 11:38:46 AM                           *
*&   Company          : UEP                                         *
*&   Program Name     :ZPM_ASSITMENT_MANAGER               *
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
*&---------------------------------------------------------------------*
*& Report ZPM_ASSITMENT_MANAGER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZPM_ASSITMENT_MANAGER.

INCLUDE:ZPM_ASSITMENT_MANAGER_T01,
        ZPM_ASSITMENT_MANAGER_S01,
        ZPM_ASSITMENT_MANAGER_F01.


START-OF-SELECTION.

  PERFORM GET_DATA.
  IF LV_CHECK_PERNR <> 'X'.
    PERFORM SET_OUTPUT.
  ENDIF.
