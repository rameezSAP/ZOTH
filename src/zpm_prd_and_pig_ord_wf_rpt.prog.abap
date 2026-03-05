*&---------------------------------------------------------------------*
*&   Author           : Muhammad Farakh Murtaza
*&   Date             : 04-10-2022
*&   Company          : UEP
*&   Program Name     : ZPM_PRD_AND_PIG_ORD_WF_RPT
*&   LDB Used         :
*&---------------------------------------------------------------------*
*& Report ZPM_PRD_AND_PIG_ORD_WF_RPT
*&---------------------------------------------------------------------*
REPORT ZPM_PRD_AND_PIG_ORD_WF_RPT.
DATA: O_DATA TYPE REF TO IF_SALV_GUI_TABLE_IDA.
INCLUDE ZPM_CLASS_IMPLT.

INCLUDE: ZPM_PRD_AND_PIG_ORD_WF_T01,
         ZPM_PRD_AND_PIG_ORD_WF_S01,
         ZPM_PRD_AND_PIG_ORD_WF_F01.

START-OF-SELECTION.
  PERFORM GET_DATA.

END-OF-SELECTION.
  PERFORM SET_OUTPUT.
