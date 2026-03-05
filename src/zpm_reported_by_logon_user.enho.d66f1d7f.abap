"Name: \PR:SAPLIQS0\IC:CLAIM_068\SE:END\EI
ENHANCEMENT 0 ZPM_REPORTED_BY_LOGON_USER.

*BOC To restrict status chnage on notification PM based on workflow
IF SY-TCODE = 'IW22'.
  IF SY-UCOMM = 'AWST' OR SY-UCOMM = 'ANST'.
    SELECT SINGLE * FROM ZPM_SET_V1 INTO @DATA(LS_SET)
      WHERE QMART =  @VIQMEL-QMART.
    IF SY-SUBCS = 0.
      SELECT SINGLE * FROM ZPM_WF INTO @DATA(LS_WF)
           WHERE WF_ID =  @LS_SET-WF_ID.
      IF SY-SUBRC = 0 AND LS_WF-ZACTIVE = 'X'..
        MESSAGE 'Status can not be change' TYPE 'S' DISPLAY LIKE 'I'.
        LEAVE TO SCREEN '7200'.
      ENDIF.
    ENDIF.



    IF SY-UCOMM = 'AWST'  OR SY-UCOMM = 'ANST'.
      CHECK VIQMEL-QMNUM <> '%00000000001'.
      SELECT SINGLE * FROM ZPM_WF_HST
        INTO @DATA(LS_DATA)
        WHERE QMNUM = @VIQMEL-QMNUM.
      IF SY-SUBRC = 0.

        MESSAGE 'Status can not be change' TYPE 'E' DISPLAY LIKE 'I'.
        LEAVE TO SCREEN '7200'.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.
ENDIF.
*EOC To restrict status chnage on notification PM based on workflow
ENDENHANCEMENT.
