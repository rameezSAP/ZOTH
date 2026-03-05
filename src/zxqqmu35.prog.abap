*&---------------------------------------------------------------------*
*& Include          ZXQQMU35
*&---------------------------------------------------------------------*
*BREAK: ac_Adnan..
*IF ( I_VIQMEL-QMART EQ 'M1' OR I_VIQMEL-QMART EQ 'M2' OR I_VIQMEL-QMART EQ 'M7' OR I_VIQMEL-QMART EQ 'M8' OR I_VIQMEL-QMART EQ 'T4' ).
*  APPEND 'AWST'  TO T_EX_FCODE.
*ENDIF.

****break-point.
****LOOP AT SCREEN.
****  IF SCREEN-NAME = 'ANWENDERSTATUS'.
****    SCREEN-INVISIBLE = '1'.
****    MODIFY SCREEN.
****  ENDIF.
****ENDLOOP.
