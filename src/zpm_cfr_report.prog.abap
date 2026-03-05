*&---------------------------------------------------------------------*
*&   Author           : Osama Bin Shahid                               *
*&   Date             : 00-08-2022                                     *
*&   Company          : UEP                                            *
*&   Program Name     : ZPM_CFR_REPORT                                 *
*&   Lead             : Adnan Khan                                     *
*&**********************************************************************
*& Program Definition : Description of the Program                     *
*&                            ()                                       *
*&**********************************************************************
*& PROGRAM CHANGES / Modification Logs :                               *
*&**********************************************************************
*&   Date   I Request    I Programmer   I     Changes                  *
*&---------------------------------------------------------------------*
REPORT ZPM_CFR_REPORT.

INCLUDE : ZPM_CFR_REPORT_S01,
          ZPM_CFR_REPORT_T01,
          ZPM_CFR_REPORT_F01..

START-OF-SELECTION.

  PERFORM GET_DATA.
  PERFORM SET_OUTPUT.
