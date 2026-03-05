*&**********************************************************************
*&   Author           : Adnan Khan                                  *
*&   Date             : 14-07-2022                                 *
*&   Company          : UEP                                         *
*&   Program Name     : ZPM_IP24_CUSTOM_REPORT                         *
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
REPORT ZPM_IP24_CUSTOM_REPORT_NEW.

INCLUDE: ZPM_IP24_CUSTOM_REPORT_T01,
          ZPM_IP24_CUSTOM_REPORT_S01,
          ZPM_IP24_CUSTOM_REPORT_F01.


START-OF-SELECTION.

  PERFORM GET_DATA.
  PERFORM SET_OUTPUT.
