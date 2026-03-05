*&---------------------------------------------------------------------*
*& Include          ZPM_NOTIF_WF_RPT_S01
*&---------------------------------------------------------------------*
TABLES: VIQMEL, TJ30T, T001W, T024I, USR21.

SELECT-OPTIONS: S_QMART FOR VIQMEL-QMART,
                S_CRT_BY FOR USR21-BNAME DEFAULT SY-UNAME,
                S_USTAT FOR TJ30T-TXT04 ,
                S_IWERK FOR T001W-IWERK MATCHCODE OBJECT ZSH_PLPL ,
                S_INGRP FOR T024I-INGRP,
                S_UNAME FOR USR21-BNAME,
                S_UDATE FOR VIQMEL-AEDAT,
                S_QMNUM FOR VIQMEL-QMNUM,
                S_PRIOK FOR VIQMEL-PRIOK.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_USTAT-LOW.
  PERFORM F4_USER_STATUS.
