FUNCTION ZPM_FM_CHECK_WF_SETTING_ORDER.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(WF_ID) TYPE  ZWF_ID
*"     VALUE(CAUFVD) TYPE  CAUFVD OPTIONAL
*"  EXPORTING
*"     REFERENCE(RTYPE) TYPE  SY-MSGTY
*"     REFERENCE(MESSAGE) TYPE  CHAR255
*"----------------------------------------------------------------------
  TYPES: BEGIN OF TY_AGENT,
           ZAGENT TYPE ZAGENT,
         END OF TY_AGENT.
  DATA: LT_AGENTS TYPE STANDARD TABLE OF TY_AGENT,
        LS_AGENTS LIKE LINE OF LT_AGENTS.
break ac_farhan.
  SELECT ERNAM FROM ZPM_ROT INTO TABLE LT_AGENTS
    WHERE ( BLOCK = CAUFVD-TPLNR(3) OR ZZONE = CAUFVD-TPLNR+7(3) ) "Firts 3 Chars to scan
    AND WF_ID EQ WF_ID
    AND LEVELS EQ '0000000002'.

  IF LT_AGENTS[] IS INITIAL.
    RTYPE = 'E'.
    MESSAGE = |Workflow Approval Hierarchy not maintained for Level 2|.
    EXIT.
  ENDIF.

ENDFUNCTION.
