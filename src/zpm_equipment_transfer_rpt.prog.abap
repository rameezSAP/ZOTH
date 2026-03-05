*&**********************************************************************
*&   Author           : Adnan Khan                                  *
*&   Date             : 14-07-2022                                 *
*&   Company          : UEP                                         *
*&   Program Name     : ZPM_EQUIPMENT_TRANSFER_RPT                         *
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
REPORT ZPM_EQUIPMENT_TRANSFER_RPT.
INCLUDE: ZPM_EQUIPMENT_TRANSFER_RPT_T01,
          ZPM_EQUIPMENT_TRANSFER_RPT_S01,
          ZPM_EQUIPMENT_TRANSFER_RPT_F01.



START-OF-SELECTION.

  PERFORM GET_DATA.
  PERFORM SET_OUTPUT.
