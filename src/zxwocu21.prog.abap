*&---------------------------------------------------------------------*
*& Include          ZXWOCU21
*&---------------------------------------------------------------------*
break ac_Adnan.
IF SY-TCODE = 'IW21' OR SY-TCODE = 'IW31' OR SY-TCODE = 'IP30'   OR SY-TCODE = 'IP41' OR SY-TCODE = 'IP10'.
  e_viqmel-QMNAM = SY-UNAME.
ENDIF.
