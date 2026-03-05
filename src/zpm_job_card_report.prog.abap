*&**********************************************************************
*&   Author           : Adnan Khan                                  *
*&   Date             : 14-07-2022                                 *
*&   Company          : UEP                                         *
*&   Program Name     : ZFI_VOID_CHECK_REGISTER                         *
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
REPORT ZPM_JOB_CARD_REPORT.
INCLUDE: ZPM_JOB_CARD_REPORT_T01,
         ZPM_JOB_CARD_REPORT_S01,
         ZPM_JOB_CARD_REPORT_F01.



START-OF-SELECTION.

  PERFORM GET_DATA.
  PERFORM SET_OUTPUT.
