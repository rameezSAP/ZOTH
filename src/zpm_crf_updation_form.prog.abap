*&**********************************************************************
*&   Author           : Adnan Khan                                  *
*&   Date             : 25.08.2022                               *
*&   Company          : UEP                                         *
*&   Program Name     : ZPM_CRF_UPDATION_FORM                         *
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
REPORT ZPM_CRF_UPDATION_FORM.

INCLUDE:ZPM_CRF_UPDATION_FORM_T01,
        ZPM_CRF_UPDATION_FORM_S01,
        ZPM_CRF_UPDATION_FORM_F01.


START-OF-SELECTION.

  PERFORM GET_DATA.

  PERFORM SET_OUTPUT.
