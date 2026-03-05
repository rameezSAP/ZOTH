*&---------------------------------------------------------------------*
*& Include          ZXWO1U04
*&---------------------------------------------------------------------*

*BREAK AC_ADNAN.
*SELECT SINGLE * FROM ZPM_WF_HST INTO @DATA(LS_DATA) WHERE QMNUM = @CAUFVD_IMP-QMNUM.
*IF SY-SUBRC = 0.
*  APPEND 'AWST' TO FCODE_EXC_CUST.
*ENDIF.
*
*BREAK ac_Adnan.
*
**BOC By Adnan Khan to check woflfow roughting data based on order number if exsist then hide user status.
*
*
*DATA:LT_FCODE_EXC_CUST TYPE STANDARD TABLE OF  CUAFCODE,
*     LS_FCODE_EXC_CUST LIKE LINE OF FCODE_EXC_CUST.
**FREE LT_FCODE_EXC_CUST.
*CHECK CAUFVD_IMP-AUFNR IS NOT INITIAL.
*SELECT SINGLE * FROM ZPM_WF_HST
*  INTO @DATA(LS_DATA)
*  WHERE AUFNR = @CAUFVD_IMP-AUFNR.
*IF SY-SUBRC = 0.
*  LS_FCODE_EXC_CUST-FCODE = 'ANST'.
*  APPEND LS_FCODE_EXC_CUST TO LT_FCODE_EXC_CUST.
*  CLEAR LS_FCODE_EXC_CUST.
*
*ENDIF.
*
**EOC By Adnan Khan to check woflfow roughting data based on order number if exsist then hide user status.
