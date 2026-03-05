*----------------------------------------------------------------------*
***INCLUDE ZXWOCI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0900  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0900 INPUT.
  IF SY-UCOMM = 'CRF'.
    BREAK AC_ADNAN..
    FIELD-SYMBOLS:<FS> TYPE ANY.
    ASSIGN ('(SAPLCOIH)CAUFVD-AUFNR') TO <FS>.
    IF <FS> IS ASSIGNED.
      SET PARAMETER ID 'ZRSNUM' FIELD <FS>.
      CALL TRANSACTION 'ZPM_CRF_UPD' AND SKIP FIRST SCREEN.
    ENDIF.
  ENDIF.

*    LOOP AT SCREEN.
*      IF SCREEN-NAME EQ 'CRF'.
*        SCREEN-INPUT = 0.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.

ENDMODULE.

MODULE STATUS_0900 OUTPUT.
*BOC by adnan khan to disble buttom if order in teco
  DATA:L_AUFNR  TYPE JSTO-OBJNR,
       IT_JEST  TYPE STANDARD TABLE OF JSTAT,
       LV_AUFNR TYPE AUFK-AUFNR.
  GET PARAMETER ID 'ANR' FIELD LV_AUFNR.

  CONCATENATE 'OR' LV_AUFNR INTO L_AUFNR.

  CALL FUNCTION 'STATUS_READ'
    EXPORTING
      OBJNR            = L_AUFNR
      ONLY_ACTIVE      = 'X'
    TABLES
      STATUS           = IT_JEST
    EXCEPTIONS
      OBJECT_NOT_FOUND = 1
      OTHERS           = 2.
  IF SY-SUBRC <> 0.
  ENDIF.
  " to get the texts of statuses
  IF NOT IT_JEST[] IS INITIAL.
    SELECT ISTAT, TXT04
    FROM TJ02T
    INTO TABLE @DATA(IT_TJ02T)
    FOR ALL ENTRIES IN @IT_JEST
    WHERE ISTAT = @IT_JEST-STAT
      AND SPRAS = @SY-LANGU.
  ENDIF.

  DATA(LV_COUNT_DATA) = REDUCE I( INIT I = 0 FOR WA IN IT_TJ02T
     WHERE ( ( TXT04 = 'TECO' ) ) NEXT I = I + 1 ).

  IF LV_COUNT_DATA > 0.
    LOOP AT SCREEN.
      IF SCREEN-NAME EQ 'CRF'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

*EOC by adnan khan to disble buttom if order in teco

ENDMODULE.
