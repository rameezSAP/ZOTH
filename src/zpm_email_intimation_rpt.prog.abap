*&**********************************************************************
*&   Author           : OSAMA Bin Shahid                               *
*&   Date             : 13-10-2022                                     *
*&   Company          : UEP                                            *
*&   Program Name     : ZPM_EMAIL_INTIMATION_RPT                       *
*&   Lead             : Adnan Khan                                               *
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
REPORT ZPM_EMAIL_INTIMATION_RPT.

INCLUDE: ZPM_EMAIL_INTIMATION_RPT_T01,
          ZPM_EMAIL_INTIMATION_RPT_F01.


START-OF-SELECTION.

PERFORM GET_DATA.

END-OF-SELECTION.


  IF GT_MAIN IS NOT INITIAL.

    PERFORM SET_OUTPUT.

  ENDIF.
