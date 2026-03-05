FUNCTION ZPM_FM_CHECK_WF_SETTING.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(WF_ID) TYPE  ZWF_ID
*"     VALUE(QMNUM) TYPE  QMNUM OPTIONAL
*"     VALUE(AUFNR) TYPE  AUFNR OPTIONAL
*"     VALUE(USER) TYPE  SY-UNAME OPTIONAL
*"  EXPORTING
*"     REFERENCE(RTYPE) TYPE  SY-MSGTY
*"     REFERENCE(MESSAGE) TYPE  CHAR255
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

  DATA: LT_AGENTS    TYPE STANDARD TABLE OF TY_AGENT,
        LS_AGENTS    LIKE LINE OF LT_AGENTS,
        LT_RETURN    TYPE TABLE OF BAPIRET2,
        LS_WF_NEX    TYPE ZPM_WF_NEX,
        LV_PRE_LEVEL TYPE ZLEVEL,
        LV_USER      TYPE BAPIBNAME-BAPIBNAME,
        LT_SOBID     TYPE STANDARD TABLE OF TY_STR,
        LS_SOBID     LIKE LINE OF LT_SOBID,
        IM_LEVEL     TYPE ZLEVEL.

  "Notifiaction Data
  SELECT SINGLE * FROM ZPM_NOT_CDS INTO @DATA(LS_NOT)
    WHERE QMNUM = @QMNUM.

  "IN CASE OF WF-3 with level 5 or 6 this will be 'X'
  IF WF_ID EQ 'WF-3' AND ( IM_LEVEL EQ 5 OR IM_LEVEL EQ 6 ) AND LS_NOT-INGRP = LS_NOT-ARBPL(3)..
    DATA(LV_FLAG) = 'X'.
  ELSE.
    CLEAR LV_FLAG.
  ENDIF.


*--- Setting Table of Workflow ---*
  SELECT * FROM ZPM_SET_V1 INTO TABLE @DATA(LT_SET)
    WHERE WF_ID = @WF_ID.

  LOOP AT LT_SET INTO DATA(LS_SET) WHERE LEVELS <> 1.

    FREE: LT_AGENTS, LS_AGENTS.
    IF LS_SET-WF_DET_KEY = 'AR'.

      SELECT SINGLE PERNR FROM PA0105 INTO @DATA(LV_PERNR)
        WHERE USRID = @USER
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
          AND ( SUBTY = 'A002' OR SUBTY = 'A005' )
          AND ENDDA = '99991231'.
        IF SY-SUBRC = 0.

          LOOP AT LT_SOBID INTO LS_SOBID.
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
            CLEAR: LS_SOBID.
          ENDLOOP.
        ENDIF.

      ELSE. "if Pernr not found against the SAP user

*----- Incase Position to Position heirarchy not maintain ----*
        SELECT ZPOSITION AS SOBID, ZSUP_ID AS SUP_USRID FROM ZSUBCOEMP INTO CORRESPONDING FIELDS OF TABLE @LT_SOBID
          WHERE ZSAP_ID = @USER.
        IF SY-SUBRC = 0.

          LOOP AT LT_SOBID INTO LS_SOBID.
            CLEAR: LV_PERNR.
            IF LS_SOBID-SOBID IS NOT INITIAL.
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

      ENDIF.

    ELSEIF LS_SET-WF_DET_KEY = 'RT'.


      SELECT ERNAM AS ZAGENT FROM ZPM_ROT INTO TABLE LT_AGENTS
           WHERE ( BLOCK = LS_NOT-TPLNR(3) OR ZZONE = LS_NOT-TPLNR+7(3) ) "Firts 3 Chars to scan
           AND WF_ID = WF_ID
           AND  IWERK = LS_NOT-IWERK
           AND LEVELS = LS_SET-LEVELS.
      IF LT_AGENTS[] IS INITIAL.
        SELECT ERNAM AS ZAGENT FROM ZPM_ROT INTO TABLE LT_AGENTS
             WHERE ( BLOCK = LS_NOT-TPLNR(3) OR ZZONE = LS_NOT-TPLNR+7(3) ) "Firts 3 Chars to scan
             AND WF_ID = WF_ID
*             AND  IWERK = LS_NOT-IWERK
             AND LEVELS = LS_SET-LEVELS.

      ENDIF.


***        CASE LS_SET-WF_AUTH.
***          WHEN 'CMGR' OR 'CATL' OR 'CPSE' OR 'CHO' OR 'CHA' OR 'MTL' OR 'CFM'. "Concession Maintenance Manager "Camp Admin Team Leader "Concession Planning Supervisor / Engineer
***            "Concession Head of Operations "Central Head of Assets
***            SELECT ERNAM AS ZAGENT FROM ZPM_ROT INTO TABLE LT_AGENTS
***              WHERE BLOCK = LS_NOT-TPLNR(3) "Firts 3 Chars to scan
***              AND WF_ID = IM_WF_ID
***              AND LEVELS = IM_LEVEL.
***          WHEN 'ZPTL' OR 'ZCRF' OR 'RZS'  OR 'ZPM'. "Zone Production Team Leader  "Zone Construction Manager(CRF wf)
***            SELECT ERNAM AS ZAGENT FROM ZPM_ROT INTO TABLE LT_AGENTS
***              WHERE ZZONE = LS_NOT-TPLNR+7(3) "Third 3 Chars to scan
***              AND WF_ID = IM_WF_ID
***              AND LEVELS = IM_LEVEL.
***        ENDCASE.

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

  ENDLOOP.


*---- Get Agents Ready -----*
  LOOP AT LT_AGENTS INTO LS_AGENTS.
    LV_USER = LS_AGENTS-ZAGENT.
*&--- Get user Detail ---&*
    CALL FUNCTION 'BAPI_USER_GET_DETAIL'
      EXPORTING
        USERNAME      = LV_USER
        CACHE_RESULTS = 'X'
*       EXTUID_GET    =
      TABLES
        RETURN        = LT_RETURN.
*       ADDSMTP          = LT_ADDSMTP.
    LS_AGENTS-ZAGENT = |US{ LS_AGENTS-ZAGENT }|.
*  APPEND LS_AGENTS TO ET_AGENTS.

  ENDLOOP.

  "Zone
  SELECT SINGLE PLTXT FROM IFLO INTO @DATA(LV_ZONE)
    WHERE TPLNR = @LS_NOT-TPLNR(10)
    AND SPRAS = @SY-LANGU.

ENDFUNCTION.
