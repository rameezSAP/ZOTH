*&---------------------------------------------------------------------*
*& Include          ZPM_PRD_AND_PIG_ORD_WF_S01
*&---------------------------------------------------------------------*
TABLES: AUFK, TJ30T, T001W, T024I, USR21.

SELECT-OPTIONS: S_AUART FOR AUFK-AUART,
                S_AUFNR FOR AUFK-AUFNR,
                S_CRT_BY FOR USR21-BNAME ,
                S_USTAT FOR TJ30T-TXT04,
                S_IWERK FOR T001W-IWERK MATCHCODE OBJECT ZSH_PLPL,
                S_INGRP FOR T024I-INGRP,
                S_UNAME FOR USR21-BNAME,
                S_UDATE FOR AUFK-STDAT.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_USTAT-LOW.
  PERFORM F4_USER_STATUS.
