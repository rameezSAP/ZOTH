class ZCL_IM_NOTIF_ACTIONBOX definition
  public
  final
  create public .

public section.

  interfaces IF_EX_NOTIF_ACTIONBOX .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_NOTIF_ACTIONBOX IMPLEMENTATION.


  METHOD IF_EX_NOTIF_ACTIONBOX~SELECT_FUNCTION.
*    BREAK-POINT.
*
*
*    CHECK I_VIQMEL-QMNUM IS NOT INITIAL.
*    SELECT SINGLE * FROM ZPM_WF_HST
*      INTO @DATA(LS_DATA)
*      WHERE QMNUM = @I_VIQMEL-QMNUM.
*    IF SY-SUBRC = 0.
*
*      IF I_OKCODE = 'AWST'.
**        BREAK AC_ADNAN.
*        E_DISPLAY_FUNCTION = 'X'.
*      ENDIF.

*    ENDIF.


  ENDMETHOD.
ENDCLASS.
