FUNCTION ZFM_PM_NOT_NEXT_USER.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(WF_KEY) TYPE  CHAR14
*"     VALUE(IM_WF_ID) TYPE  ZWF_ID
*"     VALUE(IM_LEVEL) TYPE  ZLEVEL
*"     VALUE(INITIATOR) TYPE  WFSYST-INITIATOR
*"  EXPORTING
*"     REFERENCE(ET_AGENTS) TYPE  ZTT_AGENT
*"----------------------------------------------------------------------

  TYPES: BEGIN OF TY_AGENT,
           ZAGENT TYPE ZAGENT,
         END OF TY_AGENT.
  TYPES: BEGIN OF TY_STR,
           USRID     TYPE CHAR50,
           PLANS     TYPE PLANS,
           SOBID     TYPE SOBID,
           SUP_USRID TYPE CHAR12,
         END OF TY_STR.

  DATA: GO_SEND_REQUEST  TYPE REF TO  CL_BCS,
        GO_DOCUMENT      TYPE REF TO  CL_DOCUMENT_BCS,
        LV_SENT_TO_ALL   TYPE OS_BOOLEAN,
        LO_RECIPIENT     TYPE REF TO  IF_RECIPIENT_BCS,
        LO_BCS_EXCEPTION TYPE REF TO  CX_BCS,
        SENDER1          TYPE REF TO CL_CAM_ADDRESS_BCS..


  DATA: LT_AGENTS            TYPE STANDARD TABLE OF TY_AGENT,
        LS_AGENTS            LIKE LINE OF LT_AGENTS,
        LT_RECEIVERS         TYPE STANDARD TABLE OF  SOMLRECI1,
        LS_REC               LIKE LINE OF LT_RECEIVERS,
        LT_PACKING_LIST      TYPE STANDARD TABLE OF  SOPCKLSTI1,
        LS_PACK              LIKE LINE OF LT_PACKING_LIST,
        GD_DOC_DATA          TYPE SODOCCHGI1,
        LT_MESSAGE           TYPE STANDARD TABLE OF SOLISTI1,
        LS_MESSAGE           LIKE LINE OF LT_MESSAGE,
*          LV_SUBJECT(90)  TYPE C,
        LV_SUBJECT           TYPE STRING,
        LT_ADDSMTP           TYPE TABLE OF BAPIADSMTP,
        LS_ADDSMTP           TYPE BAPIADSMTP,
        LT_RETURN            TYPE TABLE OF BAPIRET2,
        LS_WF_NEX            TYPE ZPM_WF_NEX,
        LV_PRE_LEVEL         TYPE ZLEVEL,
        LV_USER              TYPE BAPIBNAME-BAPIBNAME,
        LT_SOBID             TYPE STANDARD TABLE OF TY_STR,
        LS_SOBID             LIKE LINE OF LT_SOBID,
        LV_NEXT_APPR_BY(100).

  BREAK AC_ADNAN.
  DATA(LV_WF_KEY) = WF_KEY(12).
  LV_PRE_LEVEL = IM_LEVEL - 1.
*History Previous
  SELECT SINGLE *
    FROM ZPM_WF_HST
    INTO @DATA(LS_HST)
    WHERE QMNUM = @WF_KEY(12)
    AND WF_ID EQ @IM_WF_ID
*      AND LEVELS = @LV_PRE_LEVEL
    AND HST_ID = ( SELECT MAX( HST_ID ) FROM ZPM_WF_HST WHERE QMNUM = @WF_KEY(12) AND WF_ID = @IM_WF_ID ).
  DATA(LS_CUR_HST) = LS_HST.


  "Notifiaction Data
  SELECT SINGLE * FROM ZPM_NOT_CDS INTO @DATA(LS_NOT)
    WHERE QMNUM = @WF_KEY(12).

  "Get Detail for Routing of current level
  IF IM_LEVEL = '1'. "level 1 for Initiator
    LS_AGENTS-ZAGENT = INITIATOR+2.
    APPEND LS_AGENTS TO LT_AGENTS.
  ELSE. "For All other Levels

    "IN CASE OF WF-3 with level 5 or 6 this will be 'X'
***      IF IM_WF_ID EQ 'WF-3' AND ( IM_LEVEL EQ 5 OR IM_LEVEL EQ 6 ) AND LS_NOT-INGRP = LS_NOT-ARBPL(3)..
***        DATA(LV_FLAG) = 'X'.
***
***      ELSE.
***        CLEAR LV_FLAG.
***      ENDIF.

*start of work from farhan
    "IN CASE OF WF-3 with level 5 or 6 this will be 'X'
    DATA:LV_ZWF_AUTH TYPE C LENGTH 4.
    CLEAR LV_ZWF_AUTH.
    IF IM_WF_ID EQ 'WF-3' AND LS_NOT-INGRP = 'MNT' AND LS_NOT-INGRP = LS_NOT-ARBPL(3). "Added on request of farhan PM

      IF IM_LEVEL EQ 5.
        DATA(LV_FLAG) = 'X'.
        LV_ZWF_AUTH = 'MTL'.
      ENDIF.
      IF IM_LEVEL EQ 6.
        LV_FLAG = 'X'.
        CLEAR LV_ZWF_AUTH.
        LV_ZWF_AUTH = 'CMGR'.
      ENDIF.
*        CLEAR LV_ZWF_AUTH.
    ELSEIF IM_WF_ID EQ 'WF-3' AND LS_NOT-INGRP NE 'MNT'. "Added on request of farhan PM
      CLEAR LV_FLAG.
      CLEAR LV_ZWF_AUTH.

      IF IM_LEVEL EQ 5. "Added on request of farhan PM
        LV_ZWF_AUTH = 'PTL'.
      ENDIF.
      IF IM_LEVEL EQ 6.
        LV_ZWF_AUTH = 'ZPM'.
      ENDIF.
    ENDIF.
*end of work from farhan

    SELECT SINGLE *
      FROM ZPM_SET_V1
      INTO @DATA(LS_SET)
      WHERE WF_ID = @IM_WF_ID
      AND LEVELS = @IM_LEVEL
      AND QMART = @LS_NOT-QMART
      AND XFLAG = @LV_FLAG.
    IF LS_SET-WF_DET_KEY = 'AR'.

      SELECT SINGLE PERNR FROM PA0105 INTO @DATA(LV_PERNR)
        WHERE USRID = @INITIATOR+2
        AND USRTY = '0001'
        AND ENDDA = '99991231'.
      IF SY-SUBRC EQ 0.
        SELECT SINGLE PLANS FROM PA0001 INTO @DATA(LV_PLANS)
          WHERE PERNR = @LV_PERNR
          AND ENDDA = '99991231'.

*        SELECT SINGLE SOBID FROM HRP1001 INTO @DATA(LV_SOBID)
        SELECT SOBID AS SOBID FROM HRP1001 INTO CORRESPONDING FIELDS OF TABLE LT_SOBID
          WHERE OBJID = LV_PLANS
          AND OTYPE = 'S'
          AND SCLAS = 'S'
          AND SUBTY = 'A002'
          AND ENDDA = '99991231'.
        IF SY-SUBRC <> 0.
*----- Incase Position to Position heirarchy not maintain ----*
          SELECT ZPOSITION AS SOBID, ZSUP_ID AS SUP_USRID FROM ZSUBCOEMP INTO CORRESPONDING FIELDS OF TABLE @LT_SOBID
*              WHERE ZSAP_ID = LS_HST-ERNAM. *Change by adnan khan 12.08.2022
                  WHERE ( ZSAP_ID = @LS_HST-ERNAM OR ZSAP_ID = @LS_NOT-ERNAM ).
        ENDIF.

        LOOP AT LT_SOBID INTO LS_SOBID.
          IF LS_SOBID-SOBID IS NOT INITIAL.
            CLEAR: LV_PERNR.
            SELECT PERNR AS PERNR FROM PA0001 INTO TABLE @DATA(LT_PERNR)
              WHERE PLANS = @LS_SOBID-SOBID
              AND ENDDA = '99991231'.

            LOOP AT LT_PERNR INTO DATA(LS_PERNR).
              SELECT SINGLE USRID FROM PA0105 INTO @DATA(LV_USRID)
                WHERE PERNR = @LS_PERNR-PERNR
                AND ENDDA = '99991231'
                AND USRTY = '0001'.

              LS_AGENTS-ZAGENT = LV_USRID.
              APPEND LS_AGENTS TO LT_AGENTS.

              CLEAR: LV_USRID, LS_PERNR, LS_AGENTS.
            ENDLOOP.
          ELSEIF LS_SOBID-SUP_USRID IS NOT INITIAL..
            LS_AGENTS-ZAGENT = LS_SOBID-SUP_USRID.
            APPEND LS_AGENTS TO LT_AGENTS.

            CLEAR: LV_USRID, LS_PERNR, LS_AGENTS.
          ENDIF.
          CLEAR: LS_SOBID.
        ENDLOOP.

      ELSE. "if Pernr not found against the SAP user

*----- Incase Position to Position heirarchy not maintain ----*
        SELECT ZPOSITION AS SOBID, ZSUP_ID AS SUP_USRID FROM ZSUBCOEMP INTO CORRESPONDING FIELDS OF TABLE @LT_SOBID
*            WHERE ZSAP_ID = LS_HST-ERNAM.added by adnan khan 12.08.2022
              WHERE ( ZSAP_ID = @LS_HST-ERNAM OR ZSAP_ID = @LS_NOT-ERNAM ).

        LOOP AT LT_SOBID INTO LS_SOBID.
          IF LS_SOBID-SOBID IS NOT INITIAL.
            CLEAR: LV_PERNR.
            SELECT PERNR AS PERNR FROM PA0001 INTO TABLE LT_PERNR
              WHERE PLANS = LS_SOBID-SOBID
              AND ENDDA = '99991231'.

            LOOP AT LT_PERNR INTO LS_PERNR.
              SELECT SINGLE USRID FROM PA0105 INTO LV_USRID
                WHERE PERNR = LS_PERNR-PERNR
                AND ENDDA = '99991231'
                AND USRTY = '0001'.

              LS_AGENTS-ZAGENT = LV_USRID.
              APPEND LS_AGENTS TO LT_AGENTS.

              CLEAR: LV_USRID, LS_PERNR, LS_AGENTS.
            ENDLOOP.
          ELSEIF LS_SOBID-SUP_USRID IS NOT INITIAL..
            LS_AGENTS-ZAGENT = LS_SOBID-SUP_USRID.
            APPEND LS_AGENTS TO LT_AGENTS.

            CLEAR: LV_USRID, LS_PERNR, LS_AGENTS.
          ENDIF.
          CLEAR: LS_SOBID.
        ENDLOOP.

      ENDIF.


***      ELSEIF LS_SET-WF_DET_KEY = 'RT'.
***
***        FREE: LT_AGENTS, LS_AGENTS.
***
***        SELECT ERNAM AS ZAGENT FROM ZPM_ROT INTO TABLE LT_AGENTS
***             WHERE ( BLOCK = LS_NOT-TPLNR(3) OR ZZONE = LS_NOT-TPLNR+7(3) ) "Firts 3 Chars to scan
***             AND WF_ID = IM_WF_ID
***             AND LEVELS = IM_LEVEL.


    ELSEIF LS_SET-WF_DET_KEY = 'RT'.

      FREE: LT_AGENTS, LS_AGENTS.
      IF IM_WF_ID NE 'WF-3'.                                                  "Added on request of farhan PM
        SELECT ERNAM AS ZAGENT FROM ZPM_ROT INTO TABLE LT_AGENTS
             WHERE ( BLOCK = LS_NOT-TPLNR(3) OR ZZONE = LS_NOT-TPLNR+7(3) ) "Firts 3 Chars to scan
             AND WF_ID = IM_WF_ID
               AND IWERK = LS_NOT-IWERK
             AND LEVELS = IM_LEVEL.
        IF LT_AGENTS IS INITIAL.
          SELECT ERNAM AS ZAGENT FROM ZPM_ROT INTO TABLE LT_AGENTS
               WHERE ( BLOCK = LS_NOT-TPLNR(3) OR ZZONE = LS_NOT-TPLNR+7(3) ) "Firts 3 Chars to scan
               AND WF_ID = IM_WF_ID
*             AND WF_AUTH = LV_ZWF_AUTH
               AND LEVELS = IM_LEVEL.
        ENDIF.

      ELSEIF IM_WF_ID EQ 'WF-3'. "Added on request of farhan PM
        IF IM_LEVEL = 5 OR IM_LEVEL = 6.
          IF LS_NOT-TPLNR(3) IS NOT INITIAL AND LS_NOT-TPLNR+7(3) IS NOT INITIAL.
*/**** Check the planning plant is maintainaed on zpm_rot then route as per planning plant
            SELECT ERNAM AS ZAGENT FROM ZPM_ROT INTO TABLE LT_AGENTS
                 WHERE ( BLOCK = LS_NOT-TPLNR(3) OR ZZONE = LS_NOT-TPLNR+7(3) ) "Firts 3 Chars to scan
                 AND WF_ID = IM_WF_ID
                 AND IWERK = LS_NOT-IWERK
                 AND WF_AUTH = LV_ZWF_AUTH
                 AND LEVELS = IM_LEVEL.

            IF LT_AGENTS[] IS INITIAL. " If agent not found than get the agent as per block and zone.
              SELECT ERNAM AS ZAGENT FROM ZPM_ROT INTO TABLE LT_AGENTS
                   WHERE ( BLOCK = LS_NOT-TPLNR(3) OR ZZONE = LS_NOT-TPLNR+7(3) ) "Firts 3 Chars to scan
                   AND WF_ID = IM_WF_ID
                   AND WF_AUTH = LV_ZWF_AUTH
                   AND LEVELS = IM_LEVEL.
            ENDIF.

          ELSEIF LS_NOT-TPLNR(3) IS NOT INITIAL AND LS_NOT-TPLNR+7(3) IS INITIAL.
            SELECT ERNAM AS ZAGENT FROM ZPM_ROT INTO TABLE LT_AGENTS
              WHERE ( BLOCK = LS_NOT-TPLNR(3) ) "Firts 3 Chars to scan
              AND WF_ID = IM_WF_ID
              AND  IWERK = LS_NOT-IWERK
              AND LEVELS = IM_LEVEL.

            IF LT_AGENTS[] IS INITIAL.
              SELECT ERNAM AS ZAGENT FROM ZPM_ROT INTO TABLE LT_AGENTS
                WHERE ( BLOCK = LS_NOT-TPLNR(3) ) "Firts 3 Chars to scan
                AND WF_ID = IM_WF_ID
*              AND  IWERK = LS_NOT-IWERK
                AND LEVELS = IM_LEVEL.

            ENDIF.

          ENDIF.
        ELSE.
          SELECT ERNAM AS ZAGENT FROM ZPM_ROT INTO TABLE LT_AGENTS
                       WHERE ( BLOCK = LS_NOT-TPLNR(3) OR ZZONE = LS_NOT-TPLNR+7(3) ) "Firts 3 Chars to scan
                       AND WF_ID = IM_WF_ID
                       AND  IWERK = LS_NOT-IWERK
                       AND LEVELS = IM_LEVEL.
          IF LT_AGENTS[] IS INITIAL.
            SELECT ERNAM AS ZAGENT FROM ZPM_ROT INTO TABLE LT_AGENTS
                         WHERE ( BLOCK = LS_NOT-TPLNR(3) OR ZZONE = LS_NOT-TPLNR+7(3) ) "Firts 3 Chars to scan
                         AND WF_ID = IM_WF_ID
*             AND WF_AUTH = LV_ZWF_AUTH
                         AND LEVELS = IM_LEVEL.
          ENDIF.
        ENDIF.
      ENDIF.


*        CASE LS_SET-WF_AUTH.
*          WHEN 'CMGR' OR 'CATL' OR 'CPSE' OR 'CHO' OR 'CHA' OR 'MTL' OR 'CFM'. "Concession Maintenance Manager "Camp Admin Team Leader "Concession Planning Supervisor / Engineer
*            "Concession Head of Operations "Central Head of Assets
*            SELECT ERNAM AS ZAGENT FROM ZPM_ROT INTO TABLE LT_AGENTS
*              WHERE BLOCK = LS_NOT-TPLNR(3) "Firts 3 Chars to scan
*              AND WF_ID = IM_WF_ID
*              AND LEVELS = IM_LEVEL.
*          WHEN 'ZPTL' OR 'ZCRF' OR 'RZS'  OR 'ZPM'. "Zone Production Team Leader  "Zone Construction Manager(CRF wf)
*            SELECT ERNAM AS ZAGENT FROM ZPM_ROT INTO TABLE LT_AGENTS
*              WHERE ZZONE = LS_NOT-TPLNR+7(3) "Third 3 Chars to scan
*              AND WF_ID = IM_WF_ID
*              AND LEVELS = IM_LEVEL.
*        ENDCASE.

    ELSEIF LS_SET-WF_DET_KEY = 'WD'. "WBS Budget Owner
      BREAK AC_WF1.
      DATA WBS_AGENTS     TYPE ZTT_AGENTS.
      CALL FUNCTION 'ZFM_MM_BUDGET_OWNER'
        EXPORTING
          PS_PSP_PNR = LS_NOT-PROID
        TABLES
          AGENTS     = WBS_AGENTS.

      LT_AGENTS = CORRESPONDING #( WBS_AGENTS MAPPING ZAGENT = AGENT ).

    ENDIF.

  ENDIF. "IM_LEVEL

  LOOP AT LT_AGENTS INTO LS_AGENTS.

    LS_AGENTS-ZAGENT = |US{ LS_AGENTS-ZAGENT }|.
    APPEND LS_AGENTS TO ET_AGENTS.

    CLEAR: LS_AGENTS, LT_ADDSMTP[].
  ENDLOOP.


ENDFUNCTION.
