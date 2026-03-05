"Name: \PR:RIMPOS00\IC:EAMCC3_MIOLXF14_01\SE:END\EI
ENHANCEMENT 0 ZPM_IP18_IP17_CUSTOM_FIELD.
*BOC IP18 Report, additional columns Cycle and Cycle unit to be included  PM Module
  IF ( SY-TCODE EQ 'IP17' OR SY-TCODE EQ 'IP18' ) AND SY-REPID EQ 'RIMPOS00'.
    DATA: LT_CYCLES                TYPE STANDARD TABLE OF MPLAN_MMPT.
    LOOP AT OBJECT_TAB[] ASSIGNING FIELD-SYMBOL(<FS_UPD>).

      CALL FUNCTION 'MPLAN_READ'
        EXPORTING
          MPLAN  = <FS_UPD>-WARPL
        TABLES
          CYCLES = LT_CYCLES.
      LOOP AT LT_CYCLES INTO DATA(LS_CYCLES) .
        CALL FUNCTION 'MC_FLTP_CHAR'
          EXPORTING
            FC_A_FLD = LS_CYCLES-ZYKL1
          IMPORTING
            FC_R_FLD = <FS_UPD>-ZZFC_R_FLD.
*For Convertion Of UNIT
        CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
          EXPORTING
            INPUT          = LS_CYCLES-ZEIEH
            LANGUAGE       = SY-LANGU
          IMPORTING
*           LONG_TEXT      = LONG_TEXT
            OUTPUT         = <FS_UPD>-ZEIEH
*           SHORT_TEXT     = SHORT_TEXT
          EXCEPTIONS
            UNIT_NOT_FOUND = 1.
*<FS_UPD>-ZEIEH = LS_CYCLES-ZEIEH.




      ENDLOOP.
      FREE LT_CYCLES.
    ENDLOOP.
  ENDIF.
*BOC IP18 Report, additional columns Cycle and Cycle unit to be included PM Module
ENDENHANCEMENT.
