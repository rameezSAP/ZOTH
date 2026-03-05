class ZCL_IM_IWO1_SCREEN_MODIFY definition
  public
  final
  create public .

public section.

  interfaces IF_EX_IWO1_SCREEN_MODIFY .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_IWO1_SCREEN_MODIFY IMPLEMENTATION.


  METHOD IF_EX_IWO1_SCREEN_MODIFY~CHANGE_SCREEN.

    IF SY-TCODE = 'IW32' OR SY-TCODE = 'IW32' .
      SELECT SINGLE * FROM ZPM_SET_V1 INTO @DATA(LS_SET)
        WHERE AUART =  @IS_CAUFVD-AUART.
      IF SY-SUBRC = 0.
        SELECT SINGLE * FROM ZPM_WF INTO @DATA(LS_WF)
             WHERE WF_ID =  @LS_SET-WF_ID.
        IF SY-SUBRC = 0 AND LS_WF-ZACTIVE = 'X'..
          IF I_SCREEN_NAME = '%#AUTOTEXT001'  OR I_SCREEN_NAME = 'BUTTON_STATUS'.
*        BREAK AC_ADNAN.
            I_SCREEN_INVISIBLE = '1'.
          ENDIF.
        ENDIF.
      ENDIF.




*BOC By Adnan Khan to check woflfow roughting data based on order number if exsist then hide user status.
      CHECK IS_CAUFVD-AUFNR IS NOT INITIAL.
      SELECT SINGLE * FROM ZPM_WF_HST
        INTO @DATA(LS_DATA)
        WHERE AUFNR = @IS_CAUFVD-AUFNR.
      IF SY-SUBRC = 0.

        IF I_SCREEN_NAME = '%#AUTOTEXT001' OR I_SCREEN_NAME = 'BUTTON_STATUS'.
*        BREAK AC_ADNAN.
          I_SCREEN_INVISIBLE = '1'.
        ENDIF.

      ENDIF.
    ENDIF.

*EOC By Adnan Khan to check woflfow roughting data based on order number if exsist then hide user status.




  ENDMETHOD.
ENDCLASS.
