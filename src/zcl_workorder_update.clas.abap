class ZCL_WORKORDER_UPDATE definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_WORKORDER_UPDATE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_WORKORDER_UPDATE IMPLEMENTATION.


  method IF_EX_WORKORDER_UPDATE~ARCHIVE_OBJECTS.
  endmethod.


  method IF_EX_WORKORDER_UPDATE~AT_DELETION_FROM_DATABASE.
  endmethod.


  METHOD IF_EX_WORKORDER_UPDATE~AT_SAVE.
    DATA: lt_cobra TYPE TABLE OF cobra , "OCCURS 1 WITH HEADER LINE,
          lt_cobrb TYPE TABLE OF cobrb . "OCCURS 2 WITH HEADER LINE.


    CHECK SY-TCODE = 'IW21' OR  SY-TCODE = 'IW22' OR  SY-TCODE = 'IW31' OR  SY-TCODE = 'IW32'  OR  SY-TCODE = 'IW34'.
    DATA:SYSTEM_STATUS_LINE TYPE  BSVX-STTXT.
    BREAK AC_ADNAN.
    IMPORT SYSTEM_STATUS_LINE TO SYSTEM_STATUS_LINE FROM MEMORY ID 'SYSTEM_STATUS_ORDER'.
    FREE MEMORY ID 'SYSTEM_STATUS_ORDER'.

*Check Notification Type
    SELECT SINGLE QMART FROM VIQMEL
      INTO @DATA(LV_QMART)
      WHERE QMNUM =  @IS_HEADER_DIALOG-QMNUM.

    IF SYSTEM_STATUS_LINE cs 'TECO' AND ( LV_QMART = 'M1' OR LV_QMART = 'M2' ).
      FIELD-SYMBOLS:<FS> TYPE ANY.
      ASSIGN ('(SAPLIQS0)VIQMFE-FEGRP') TO <FS>.
      IF <FS> IS ASSIGNED.
        IF <FS> IS INITIAL.
          MESSAGE ' Damage Code required at time of document complete' TYPE 'I' RAISING ERROR_WITH_MESSAGE.
        ENDIF.
      ENDIF.
      UNASSIGN <FS>.

      ASSIGN ('(SAPLIQS0)VIQMFE-OTGRP') TO <FS>.
      IF <FS> IS ASSIGNED.
        IF <FS> IS INITIAL.
          MESSAGE ' Object Part required at time of document complete' TYPE 'I' RAISING ERROR_WITH_MESSAGE.
          LEAVE TO TRANSACTION sy-tcode AND SKIP FIRST SCREEN.
        ENDIF.
      ENDIF.
      UNASSIGN <FS>.

      ASSIGN ('(SAPLIQS0)VIQMFE-FECOD') TO <FS>.
      IF <FS> IS ASSIGNED.
        IF <FS> IS INITIAL.
          MESSAGE 'Damage Code required at time of document complete'  TYPE 'I' RAISING ERROR_WITH_MESSAGE.
        ENDIF.
      ENDIF.
      UNASSIGN <FS>.

*      ASSIGN ('(SAPLIQS0)VIQMUR-URGRP') TO <FS>.
*      IF <FS> IS ASSIGNED.
*        IF <FS> IS INITIAL.
*          MESSAGE 'Cause Code required at time of document complete' TYPE 'I' RAISING ERROR_WITH_MESSAGE.
*        ENDIF.
*      ENDIF.
*      UNASSIGN <FS>.
*
*      ASSIGN ('(SAPLIQS0)VIQMUR-URCOD') TO <FS>.
*      IF <FS> IS ASSIGNED.
*        IF <FS> IS INITIAL.
*          MESSAGE 'Cause Code required at time of document complete'  TYPE 'I' RAISING ERROR_WITH_MESSAGE.
*        ENDIF.
*      ENDIF.
*      UNASSIGN <FS>.
    ENDIF.

" CRF : WBS should be same across order: Approved by Inamullah Khan, Aug29, 2023

    " CRF : WBS should be same across order:
    IF   is_header_dialog-pspel NE is_header_dialog-proid.
      MESSAGE 'Please maintain same WBS on Addtional/Lcoation Tab'  TYPE 'I' RAISING error_with_message.
    ENDIF.

    CALL FUNCTION 'K_SETTLEMENT_RULE_GET'
      EXPORTING
        objnr     = is_header_dialog-objnr
      TABLES
        e_cobra   = lt_cobra
        e_cobrb   = lt_cobrb
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.

    IF sy-subrc IS INITIAL.
*      SELECT * FROM cobrb INTO TABLE @DATA(lt_sr) WHERE objnr = @is_header_dialog-objnr.
      LOOP AT lt_cobrb ASSIGNING FIELD-SYMBOL(<fs_sr>).
        IF <fs_sr>-ps_psp_pnr NE is_header_dialog-pspel.
          MESSAGE 'Please maintain same WBS on Settlement Rule'  TYPE 'E'." RAISING DO_NOT_BUILD_SETTLEMENTRULE.
        ENDIF.
      ENDLOOP.
    ELSE.
      clear lt_cobrb.

      SELECT * FROM cobrb WHERE objnr = @is_header_dialog-objnr INTO TABLE @lt_cobrb.
      LOOP AT lt_cobrb ASSIGNING <fs_sr>.
        IF <fs_sr>-ps_psp_pnr NE is_header_dialog-pspel.
          MESSAGE 'Please maintain same WBS on Settlement Rule'  TYPE 'E'." RAISING DO_NOT_BUILD_SETTLEMENTRULE.
        ENDIF.
      ENDLOOP.
    ENDIF.

*Check WBS ON Order Screen Based On Notification
    BREAK AC_ADNAN.
*    IF  IS_HEADER_DIALOG-PRODI IS INITIAL. "IS_HEADER_DIALOG-QMNUM IS NOT INITIAL AND
    IF   ( IS_HEADER_DIALOG-PSPEL IS INITIAL OR IS_HEADER_DIALOG-PROID IS INITIAL ) AND IS_HEADER_DIALOG-KOSTL IS INITIAL. "IS_HEADER_DIALOG-QMNUM IS NOT INITIAL AND
      MESSAGE 'Please maintain Work Breakdown Structure Element or Cost Center'  TYPE 'I' RAISING ERROR_WITH_MESSAGE.
    ENDIF.


    IF   IS_HEADER_DIALOG-PROID IS NOT INITIAL.
      SELECT SINGLE PBUKR FROM PRPS INTO @DATA(LV_BUKRS)
  WHERE PSPNR = @IS_HEADER_DIALOG-PROID.
      IF SY-SUBRC = 0.
        IF LV_BUKRS NE IS_HEADER_DIALOG-BUKRS.
          MESSAGE 'WBS pertains to different Company Code.' TYPE 'I' RAISING ERROR_WITH_MESSAGE.
        ENDIF.
      ENDIF.
    ENDIF.

" CRF : Check company code in Cost center is same.

    IF   is_header_dialog-kostl IS NOT INITIAL.
      SELECT SINGLE BUKRS FROM CSKS INTO @DATA(BUKRS)
  WHERE KOKRS = @is_header_dialog-KOKRS and kostl = @is_header_dialog-kostl and DATBI = '99991231'.
      IF sy-subrc = 0.
        IF BUKRS NE is_header_dialog-bukrs.
          MESSAGE 'Cost Center pertains to different Company Code.' TYPE 'I' RAISING error_with_message.
        ENDIF.
      ENDIF.
    ENDIF.


        IF   IS_HEADER_DIALOG-PSPEL IS NOT INITIAL.
      SELECT SINGLE PBUKR FROM PRPS INTO @LV_BUKRS
  WHERE PSPNR = @IS_HEADER_DIALOG-PSPEL.
      IF SY-SUBRC = 0.
        IF LV_BUKRS NE IS_HEADER_DIALOG-BUKRS.
          MESSAGE 'WBS pertains to different Company Code.' TYPE 'I' RAISING ERROR_WITH_MESSAGE.
        ENDIF.
      ENDIF.
    ENDIF.

    IF  IS_HEADER_DIALOG-PSPEL IS NOT  INITIAL OR IS_HEADER_DIALOG-PROID IS NOT INITIAL. "IS_HEADER_DIALOG-QMNUM IS NOT INITIAL AND
      SELECT SINGLE * FROM ZPM_ORD_WBS INTO @DATA(LS_WBS)
             WHERE AUART = @IS_HEADER_DIALOG-AUART
             AND ILART =  @IS_HEADER_DIALOG-ILART.
      IF SY-SUBRC = 0.

        SELECT * FROM ZPM_ORD_WBS INTO TABLE @DATA(LT_ACT)
          WHERE AUART = @IS_HEADER_DIALOG-AUART
          AND ( PROID = @IS_HEADER_DIALOG-PSPEL AND PROID = @IS_HEADER_DIALOG-PROID )
          AND ILART =  @IS_HEADER_DIALOG-ILART.
        DATA : LV_COUNT TYPE I.
        CLEAR LV_COUNT.
        LV_COUNT = LINES( LT_ACT ).

        IF LV_COUNT <= 0.
          MESSAGE 'Structure Element (WBS Element) is restrict'  TYPE 'I' RAISING ERROR_WITH_MESSAGE.
        ENDIF.
      ENDIF.
    ENDIF.
*/**** Restrict the Field based on Authorization - ZPM_ORD
*/******* Check the Firld Authorizatioin in Order Change********
   IF sy-tcode = 'IW32'.

      SELECT SINGLE * FROM caufv INTO @DATA(ls_caufv) WHERE aufnr = @is_header_dialog-aufnr.
      SELECT SINGLE * FROM AFIH INTO @DATA(ls_AFIH) WHERE aufnr = @is_header_dialog-aufnr.

      IF sy-subrc = 0.

        IF ls_caufv-pspel NE is_header_dialog-pspel.
          AUTHORITY-CHECK OBJECT 'ZPM_ORD' "authorization object that we’ve created
                ID 'ZPM_ORD' FIELD 'PSPEL'. "Field that we wants to check for authorization
          IF sy-subrc NE 0.
            MESSAGE 'You are not authorized to change WBS'  TYPE 'I' RAISING error_with_message.
          ENDIF.
        ENDIF.

        IF LS_AFIH-PRIOK NE is_header_dialog-PRIOK.
          AUTHORITY-CHECK OBJECT 'ZPM_ORD' "authorization object that we’ve created
                ID 'ZPM_ORD' FIELD 'PRIOK'. "Field that we wants to check for authorization
          IF sy-subrc NE 0.
            MESSAGE 'You are not authorized to change Priority'  TYPE 'I' RAISING error_with_message.
          ENDIF.
        ENDIF.

        IF ls_caufv-GLTRP NE is_header_dialog-GLTRP.
          AUTHORITY-CHECK OBJECT 'ZPM_ORD' "authorization object that we’ve created
                ID 'ZPM_ORD' FIELD 'GLTRP'. "Field that we wants to check for authorization
          IF sy-subrc NE 0.
            MESSAGE 'You are not authorized to change Basic Finish Date'  TYPE 'I' RAISING error_with_message.
          ENDIF.
        ENDIF.


      ENDIF.

    ENDIF.


*/// Reservation Commnet
*    TYPES: BEGIN OF TY_RESB,
*             MATNR TYPE RESB-MATNR,
*             RSPOS TYPE RESB-RSPOS,
*           END OF TY_RESB.
*
*    DATA: IT_RESB           TYPE TABLE OF TY_RESB,
*          LT_COMP           TYPE STANDARD TABLE OF RESBB,
*          WA_RESB           LIKE LINE OF IT_RESB,
*          LV_DISMM          TYPE MARC-DISMM,
*          LV_AMOUNT         TYPE ZPR_LIMIT,
*          AMOUNT            TYPE ZPR_LIMIT,
*          AGENTS            TYPE ZTT_AGENTS,
*          USNAM             TYPE USNAM,
*          MESSAGE_TEXT(100),
*          PASS(1)
*          .
*
*    FIELD-SYMBOLS: <FS_RESB> TYPE ANY.
*
**BREAK-POINT.
*    ASSIGN ('(SAPLCOBC)resb_bt[]') TO <FS_RESB>.
*    IF <FS_RESB> IS ASSIGNED.
*      MOVE-CORRESPONDING <FS_RESB> TO LT_COMP[].
*      DELETE LT_COMP WHERE XLOEK = 'X'.
*      DELETE LT_COMP WHERE SHKZG = 'S'.
*
*      READ TABLE LT_COMP INTO DATA(LS_COMP) INDEX 1.
*      SELECT * FROM ZMM_WF_HST_V INTO TABLE @DATA(LT_HST) WHERE WF_ID = 'WF-9.1' AND RSNUM = @LS_COMP-RSNUM AND LEVELS = 0.
*      LOOP AT LT_HST INTO DATA(LS_HST).
*        DELETE LT_COMP[] WHERE RSNUM = LS_HST-RSNUM AND RSPOS = LS_HST-RSPOS.
*        CLEAR LS_HST.
*      ENDLOOP.
*
*      IF LT_COMP[] IS NOT INITIAL.
*        SELECT * FROM MBEW FOR ALL ENTRIES IN @LT_COMP
*          WHERE MATNR = @LT_COMP-MATNR
*          AND BWKEY = @LT_COMP-WERKS
*          AND BWTAR = ''
** AND BWKEY = '1001' """"""""""""""""""""""""""""""""""""CHANGE (Confirm from MM).
*          INTO TABLE @DATA(LT_MBEW).
*
*        DATA: LV_CURR(1),
*              CON_CURRENCY TYPE RESB-WAERS.
*        LOOP AT LT_COMP INTO DATA(LS_RESB).
*          IF LS_RESB-WAERS NE 'USD'.
*            CON_CURRENCY = LS_RESB-WAERS.
*          ENDIF.
*          LOOP AT LT_MBEW INTO DATA(LS_MEBW)."VERPR
*            LV_AMOUNT = LV_AMOUNT + ( LS_MEBW-VERPR * LS_RESB-BDMNG ).
*          ENDLOOP.
*        ENDLOOP.
*
*        DATA: LV_CONVERT_DATE(8).
*        LV_CONVERT_DATE = '99999999' - SY-DATUM.
*        IF CON_CURRENCY NE 'USD' AND CON_CURRENCY IS NOT INITIAL.
*          SELECT SINGLE * FROM TCURR INTO @DATA(LS_TCURR)
*            WHERE KURST = 'M'
*            AND FCURR EQ @CON_CURRENCY
*            AND TCURR EQ 'USD'
*            AND GDATU = ( SELECT MIN( GDATU ) FROM TCURR WHERE KURST = 'M'
*            AND FCURR EQ @CON_CURRENCY
*            AND TCURR EQ 'USD'
*            AND GDATU LE @LV_CONVERT_DATE ).
*          IF SY-SUBRC EQ 0.
*            IF LS_TCURR-UKURS LT 0.
*              LV_AMOUNT = LV_AMOUNT / ( LS_TCURR-UKURS * -1 ).
*            ELSE.
*              LV_AMOUNT = LV_AMOUNT * LS_TCURR-UKURS .
*            ENDIF.
*          ENDIF.
*        ENDIF.
*
*        IF LV_AMOUNT GT 5000.
*          CALL FUNCTION 'ZFM_MM_BUDGET_OWNER'
*            EXPORTING
*              AUFNR        = IS_HEADER_DIALOG-AUFNR
*              PS_PSP_PNR   = IS_HEADER_DIALOG-PSPEL
*              KOSTL        = IS_HEADER_DIALOG-AKSTL
*              KOKRS        = IS_HEADER_DIALOG-KOKRS
*            IMPORTING
*              MESSAGE_TEXT = MESSAGE_TEXT
*            TABLES
*              AGENTS       = AGENTS.
*          IF MESSAGE_TEXT IS NOT INITIAL.
*            MESSAGE MESSAGE_TEXT TYPE 'I' RAISING ERROR_WITH_MESSAGE.
*            DATA(LV_USER_ERROR) = 'X'.
*          ENDIF.
*          CLEAR: AGENTS[].
*        ENDIF.
*        IF LV_USER_ERROR <> 'X'.
*          USNAM = SY-UNAME.
*          AMOUNT = LV_AMOUNT.
*          CALL FUNCTION 'ZFM_MM_DOFA'
*            EXPORTING
*              USNAM        = USNAM
*              AMOUNT       = AMOUNT
*              WF_ID        = 'WF-9.1'
*            IMPORTING
*              PASS         = PASS
*              MESSAGE_TEXT = MESSAGE_TEXT
*            TABLES
*              AGENTS       = AGENTS.
*          IF MESSAGE_TEXT IS NOT INITIAL.
*            MESSAGE MESSAGE_TEXT TYPE 'I' RAISING ERROR_WITH_MESSAGE.
*          ENDIF.
*        ENDIF."IF LV_USER_ERROR <> 'X'.
*      ENDIF.
*
*    ENDIF.
*/***** Reservation Comment by Adil


**    DELETE LT_COMPONENT WHERE XLOEK = 'X'.
**              DELETE LT_COMPONENT WHERE SHKZG = 'S'.

*For Restriction of Activity Type
    "IF SYSTEM_STATUS_LINE = 'TECO'.
*    IF IS_HEADER_DIALOG-ILART IS INITIAL.
*      MESSAGE 'Maintenance activity type required at time of document save'  TYPE 'I' RAISING ERROR_WITH_MESSAGE.
*    ENDIF..
*    ENDIF.

  ENDMETHOD.


  METHOD IF_EX_WORKORDER_UPDATE~BEFORE_UPDATE.
    DATA:SYSTEM_STATUS_LINE TYPE BSVX-STTXT.
    BREAK AC_ADNAN.
    IF SY-TCODE = 'IW31' OR SY-TCODE = 'IW32' OR SY-TCODE = 'IP41' OR  SY-TCODE = 'IP10' OR  SY-TCODE = 'IP30' .
      BREAK AC_ADNAN.
      FIELD-SYMBOLS:<FS> TYPE CAUFVD.
      DATA: LV_WF_ID  TYPE ZPM_ROT-WF_ID,
            LS_WF_HST TYPE ZPM_WF_HST.
      DATA:CAUFVD TYPE CAUFVD.
      ASSIGN ('(SAPLCOIH)CAUFVD') TO <FS>.
      IF <FS> IS ASSIGNED.
        MOVE-CORRESPONDING <FS> TO CAUFVD.
      ENDIF.
      UNASSIGN <FS>.

      IF CAUFVD-AUART EQ 'YBA4' OR CAUFVD-AUART EQ 'YBA9'.
        LV_WF_ID = SWITCH #( CAUFVD-AUART WHEN 'YBA4' THEN |WF-6.1|
                                          WHEN 'YBA9' THEN |WF-6.2| ).
        EXPORT GV_CAUFVD = CAUFVD TO MEMORY ID 'MEMORY_CAUFVD'.
        SELECT SINGLE * FROM ZPM_WF_HST INTO @DATA(LS_WFHST)
          WHERE AUFNR = @CAUFVD-AUFNR.
        IF SY-SUBRC <> 0.
          IMPORT SYSTEM_STATUS_LINE TO SYSTEM_STATUS_LINE FROM MEMORY ID 'SYSTEM_STATUS_LINE_ORD'.
*          IF SYSTEM_STATUS_LINE = 'REL'.
          IF SYSTEM_STATUS_LINE CS 'REL'.
            SELECT SINGLE ZACTIVE FROM ZPM_WF INTO @DATA(LV_STATUS)
            WHERE WF_ID EQ @LV_WF_ID.
            IF LV_STATUS <> 'X'.
              MESSAGE 'Work Flow ID is inactive'  TYPE 'W'.
            ELSE.
              CALL FUNCTION 'ZPM_FM_PIGG_WORKFLOW' IN UPDATE TASK "DESTINATION 'NONE'
                EXPORTING
                  CAUFVD = CAUFVD.
            ENDIF.
          ENDIF. "IF SYSTEM_STATUS_LINE = 'REL'.
        ENDIF.
      ENDIF.
    ENDIF.
**Trigger MIV
    IF SY-TCODE = 'IW31' OR SY-TCODE = 'IW32'  OR SY-TCODE = 'IW21' OR SY-TCODE = 'IW22' .
      BREAK AC_ADNAN.
      BREAK AC_WASEEM.
      READ TABLE IT_HEADER INTO DATA(LS_HEADER) INDEX 1.
      IF LS_HEADER-RSNUM IS NOT INITIAL.
        SELECT * FROM ZMM_WF_HST_V INTO TABLE @DATA(LT_HST) WHERE WF_ID = 'WF-9.1' AND RSNUM = @LS_HEADER-RSNUM AND LEVELS = 0.
        IF SY-SUBRC EQ 0.
          DATA(LV_WF_EXE_CHECK) = 'X'.
        ELSE.
          IMPORT SYSTEM_STATUS_LINE TO SYSTEM_STATUS_LINE FROM MEMORY ID 'SYSTEM_STATUS_LINE_ORD'.
           IF SYSTEM_STATUS_LINE CS 'REL'.
            LV_WF_EXE_CHECK = 'X'.
          ELSE.
            CLEAR LV_WF_EXE_CHECK.
          ENDIF.
        ENDIF.

        IF LV_WF_EXE_CHECK = 'X'.
          DATA(LT_COMPONENT) = IT_COMPONENT[].
          IF SY-TCODE = 'IW32' OR SY-TCODE = 'IW22'.
            IF LT_COMPONENT[] IS NOT INITIAL.
*            SELECT MAX( WF_REQ ) FROM ZMM_WF_HST_V INTO @DATA(LV_WF_REQ) WHERE WF_ID = 'WF-9.1' AND RSNUM = @LS_HEADER-RSNUM.

              DELETE LT_COMPONENT WHERE XLOEK = 'X'.
              DELETE LT_COMPONENT WHERE SHKZG = 'S'.
              DATA(LV_LINES_NEW) = LINES( LT_COMPONENT ).
              DATA(LV_LINES_OLD) = LINES( LT_HST ).
              IF LV_LINES_NEW = LV_LINES_OLD.
                DATA(WF_NOT_CHECK) = 'X'.
              ELSE.
                CLEAR WF_NOT_CHECK.
                LOOP AT LT_HST INTO DATA(LS_HST).
                  DELETE LT_COMPONENT[] WHERE RSNUM = LS_HST-RSNUM AND RSPOS = LS_HST-RSPOS.
                  CLEAR LS_HST.
                ENDLOOP.
              ENDIF.
            ENDIF.
          ENDIF.

          IF WF_NOT_CHECK <> 'X'.
            SELECT SINGLE * FROM ZPM_WF INTO @DATA(ZPM_WF) WHERE WF_ID = 'WF-9.1'.
            IF ZPM_WF-ZACTIVE EQ 'X'.
              IF LT_COMPONENT IS NOT INITIAL.
                DATA: WF_KEY    TYPE RSNUM.
                WF_KEY = LS_HEADER-RSNUM.
                CALL FUNCTION 'ZMM_FM_RES_WORKFLOW' IN UPDATE TASK
                  EXPORTING
                    WF_KEY       = WF_KEY
                  TABLES
                    IT_COMPONENT = LT_COMPONENT.
              ENDIF.
*
*          COMMIT WORK.
            ENDIF.
          ENDIF.

        ENDIF. "IF LV_WF_EXE_CHECK = 'X'.

      ENDIF.

    ENDIF.
*     MESSAGE ' Damage Code required at time of document complete' TYPE 'I' RAISING ERROR_WITH_MESSAGE.



*    IF SY-TCODE = 'IW31'.
*        BREAK AC_ADNAN.
*      FIELD-SYMBOLS:<FS> TYPE CAUFVD.
*      DATA:CAUFVD TYPE CAUFVD.
*      ASSIGN ('(SAPLCOIH)CAUFVD') TO <FS>.
*      IF <FS> IS ASSIGNED.
*        MOVE-CORRESPONDING <FS> TO CAUFVD.
*      ENDIF.
*      UNASSIGN <FS>.
*
*
*      BREAK AC_ADNAN.
*      CALL FUNCTION 'ZTEST' "IN UPDATE TASK
*        EXPORTING
*          ES_DATA = CAUFVD.
*
*    ENDIF.
  ENDMETHOD.


  method IF_EX_WORKORDER_UPDATE~CMTS_CHECK.
  endmethod.


  METHOD IF_EX_WORKORDER_UPDATE~IN_UPDATE.
    BREAK amehmood.

  ENDMETHOD.


  METHOD IF_EX_WORKORDER_UPDATE~AT_RELEASE.
    BREAK AC_WASEEM.
  ENDMETHOD.


  method IF_EX_WORKORDER_UPDATE~INITIALIZE.
  endmethod.


  method IF_EX_WORKORDER_UPDATE~NUMBER_SWITCH.
  endmethod.


  method IF_EX_WORKORDER_UPDATE~REORG_STATUS_ACTIVATE.
  endmethod.


  method IF_EX_WORKORDER_UPDATE~REORG_STATUS_ACT_CHECK.
  endmethod.


  method IF_EX_WORKORDER_UPDATE~REORG_STATUS_REVOKE.
  endmethod.
ENDCLASS.
