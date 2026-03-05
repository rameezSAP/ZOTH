class ZCL_PM_SET definition
  public
  final
  create public .

public section.

  interfaces BI_OBJECT .
  interfaces BI_PERSISTENT .
  interfaces IF_WORKFLOW .

  class-data GS_WF_KEY type CHAR14 .
  class-data GS_OBJ type SIBFLPOR .
  class-data GT_BO_OBJS type SIBFLPORBT .

  events TRIGGER
    exporting
      value(WF_KEY) type CHAR14 .

  methods CONSTRUCTOR
    importing
      !WF_KEY type CHAR14 .
  methods FETCH_DATA
    importing
      value(WF_KEY) type CHAR14
      value(INITIATOR) type WFSYST-INITIATOR
    exporting
      value(ZWF_ID) type ZWF_ID
      value(MAX_LEVEL) type ZLEVEL
      value(FIORI_INNER) type CHAR255
      value(FIORI_OUTER) type CHAR255
      value(FIORI_INNER1) type CHAR70
      value(FIORI_INNER2) type CHAR70
      value(FIORI_OUTER1) type CHAR70
      value(FIORI_OUTER2) type CHAR70 .
  methods FETCH_DYN
    importing
      value(WF_KEY) type CHAR14
      value(IM_WF_ID) type ZWF_ID
      value(IM_LEVEL) type ZLEVEL
      value(INITIATOR) type WFSYST-INITIATOR
    exporting
      !NOTI_NO type CHAR12
      !ET_AGENTS type ZPM_WORKFLOW_AGENT_TT
      !T_MESSAGE type ZT_SOLISTI1
      !EV_SUBJECT type STRING .
  methods TRIGGER_WF
    importing
      value(WF_KEY) type CHAR14 .
  methods APPROVE
    exporting
      !APP_REJ type ZAPP_REJ .
  methods UPDATE_STATUS
    importing
      value(WF_KEY) type CHAR14
      value(IM_WF_ID) type ZWF_ID
      value(APP_REJ) type ZAPP_REJ optional
      value(INITIATOR) type WFSYST-INITIATOR optional
      value(IM_MAX_LEVEL) type ZLEVEL optional
      value(IM_APPROVERS) type WFSYST-AGENT optional
      value(IM_WORKITEM_ID) type SWWWIHEAD-WI_ID optional
    changing
      value(IE_LEVEL) type ZLEVEL optional
      value(IE_WF_COMP) type ZWFSTAT optional .
  methods REJECT
    exporting
      !APP_REJ type ZAPP_REJ .
  methods REVERT
    exporting
      value(APP_REJ) type ZAPP_REJ .
  methods SEND_UPDATES
    importing
      value(WF_KEY) type CHAR14
      value(IM_WF_ID) type ZWF_ID
      value(IM_LEVEL) type ZLEVEL
      value(IM_INITIATOR) type WFSYST-INITIATOR .
  methods DISP_NOTIF
    importing
      value(WF_KEY) type CHAR14 .
  methods CREATE_ADHOC_OBJECT
    importing
      value(WF_KEY) type CHAR14 optional
    exporting
      value(ET_BO_OBJS) type SIBFLPORBT .
  PROTECTED SECTION.
private section.
ENDCLASS.



CLASS ZCL_PM_SET IMPLEMENTATION.


  METHOD BI_OBJECT~DEFAULT_ATTRIBUTE_VALUE.
    GET REFERENCE OF ME->GS_WF_KEY INTO RESULT.
  ENDMETHOD.


  METHOD BI_OBJECT~EXECUTE_DEFAULT_METHOD.

  ENDMETHOD.


  METHOD BI_OBJECT~RELEASE.
  ENDMETHOD.


  METHOD BI_PERSISTENT~FIND_BY_LPOR.

    DATA: INSTANCE TYPE REF TO ZCL_PM_SET.

    CREATE OBJECT INSTANCE
      EXPORTING
        WF_KEY = LPOR(14).

    RESULT ?= INSTANCE.

  ENDMETHOD.


  METHOD BI_PERSISTENT~LPOR.

    RESULT = ME->GS_OBJ.

  ENDMETHOD.


  METHOD BI_PERSISTENT~REFRESH.
  ENDMETHOD.


  METHOD CONSTRUCTOR.
    GS_OBJ-CATID = 'CL'.
    GS_OBJ-TYPEID = 'ZCL_PM_SET'.
    GS_OBJ-INSTID = WF_KEY.
  ENDMETHOD.


  METHOD TRIGGER_WF.

* data declarations
    DATA: LV_OBJTYPE          TYPE SIBFTYPEID,
          LV_EVENT            TYPE SIBFEVENT,
          LV_OBJKEY           TYPE SIBFINSTID,
          INSTANCE            TYPE REF TO ZCL_PM_SET,
          LR_EVENT_PARAMETERS TYPE REF TO IF_SWF_IFS_PARAMETER_CONTAINER,
          LV_PARAM_NAME       TYPE SWFDNAME.

*Break ac_abap.

* Setting values of Event Name

    LV_OBJKEY =  GS_OBJ-INSTID.
*    lv_objcateg = gs_obj-catid.
    LV_OBJTYPE = 'ZCL_PM_SET'. "” class name
    LV_EVENT   = 'TRIGGER'.      "” event name.

*    CALL METHOD cl_swf_evt_event=>get_event_container
*      EXPORTING
*        im_objcateg  = cl_swf_evt_event=>mc_objcateg_cl
*        im_objtype   = lv_objtype
*        im_event     = lv_event
*      RECEIVING
*        re_reference = lr_event_parameters.

*lv_param_name  = 'WF_KEY'.  "” parameter name of the event
*
** Add the name/value pair to the event conainer
*    TRY.
*        CALL METHOD lr_event_parameters->set
*          EXPORTING
*            name  = lv_param_name
*            value = wf_key.
*
*      CATCH cx_swf_cnt_cont_access_denied .
*      CATCH cx_swf_cnt_elem_access_denied .
*      CATCH cx_swf_cnt_elem_not_found .
*      CATCH cx_swf_cnt_elem_type_conflict .
*      CATCH cx_swf_cnt_unit_type_conflict .
*      CATCH cx_swf_cnt_elem_def_invalid .
*      CATCH cx_swf_cnt_container .
*    ENDTRY.

* Raise the event passing the prepared event container
    TRY.
        CALL METHOD CL_SWF_EVT_EVENT=>RAISE
          EXPORTING
            IM_OBJCATEG = GS_OBJ-CATID
            IM_OBJTYPE  = LV_OBJTYPE
            IM_EVENT    = LV_EVENT
            IM_OBJKEY   = GS_OBJ-INSTID.
        COMMIT WORK.
*            IM_EVENT_CONTAINER = LR_EVENT_PARAMETERS.
      CATCH CX_SWF_EVT_INVALID_OBJTYPE .
      CATCH CX_SWF_EVT_INVALID_EVENT .
    ENDTRY.
  ENDMETHOD.


  METHOD UPDATE_STATUS.

    DATA: GO_SEND_REQUEST  TYPE REF TO  CL_BCS,
          GO_DOCUMENT      TYPE REF TO  CL_DOCUMENT_BCS,
          LV_SENT_TO_ALL   TYPE OS_BOOLEAN,
          LO_RECIPIENT     TYPE REF TO  IF_RECIPIENT_BCS,
          LO_BCS_EXCEPTION TYPE REF TO  CX_BCS,
          SENDER1          TYPE REF TO CL_CAM_ADDRESS_BCS.

    DATA: LV_PRE_LEVEL    TYPE ZLEVEL,
          LV_OBJNR        TYPE JSTO-OBJNR,
          LV_STATUS       TYPE JEST-STAT,
          STONR           TYPE TJ30-STONR,
          ZDOCID          TYPE SOFOLENTI1-DOC_ID,
          DOCUMENT_DATA   TYPE SOFOLENTI1,
          OBJECT_CONTENT  TYPE STANDARD TABLE OF SOLISTI1,
          OBJECT_HEADER   TYPE STANDARD TABLE OF SOLISTI1,
          ZFILTER         TYPE SOFILTERI1,
          ZRETURN_CODE    TYPE SY-SUBRC,
          ZATTACHMENTS    TYPE STANDARD TABLE OF SWR_OBJECT,
          LT_RECEIVERS    TYPE STANDARD TABLE OF  SOMLRECI1,
          LS_REC          LIKE LINE OF LT_RECEIVERS,
          LT_PACKING_LIST TYPE STANDARD TABLE OF  SOPCKLSTI1,
          LS_PACK         LIKE LINE OF LT_PACKING_LIST,
          GD_DOC_DATA     TYPE SODOCCHGI1,
          LT_MESSAGE      TYPE STANDARD TABLE OF SOLISTI1,
          LS_MESSAGE      LIKE LINE OF LT_MESSAGE,
*          LV_SUBJECT(90)  TYPE C,
          LV_SUBJECT      TYPE STRING,
          LT_ADDSMTP      TYPE TABLE OF BAPIADSMTP,
          LS_ADDSMTP      TYPE BAPIADSMTP,
          LT_RETURN       TYPE TABLE OF BAPIRET2,
          LV_USER         TYPE BAPIBNAME-BAPIBNAME
          .

    DATA(LV_UNAME) = SY-UNAME.
    SY-UNAME = IM_APPROVERS+2.
    DATA(LV_CUR_LEVEL) = IE_LEVEL.
    LV_PRE_LEVEL = IE_LEVEL - 1.

*History Previous
    SELECT SINGLE *
      FROM ZPM_WF_HST
      INTO @DATA(LS_PRE_HST)
      WHERE QMNUM = @WF_KEY(12)
      AND WF_ID EQ @IM_WF_ID
*      AND LEVELS = @LV_PRE_LEVEL
      AND HST_ID = ( SELECT MAX( HST_ID ) FROM ZPM_WF_HST WHERE QMNUM = @WF_KEY(12) ) AND WF_ID = @IM_WF_ID."AND LEVELS = @LV_PRE_LEVEL ).
    DATA(LS_CUR_HST) = LS_PRE_HST.

*Delete Next Table for completed current level
    SELECT SINGLE * FROM ZPM_WF_NEX INTO @DATA(LSNEX)
      WHERE WF_ID = @IM_WF_ID
      AND QMNUM = @WF_KEY(12)
      AND LEVELS = @LV_CUR_LEVEL.
    IF SY-SUBRC EQ 0.
      DELETE FROM ZPM_WF_NEX WHERE WF_ID = IM_WF_ID AND QMNUM = WF_KEY(12) AND LEVELS = LV_CUR_LEVEL.
    ENDIF.

*Get Detail for Routing of current level
    SELECT SINGLE * FROM ZPM_SET_V1 INTO @DATA(LS_SET)
      WHERE WF_ID = @IM_WF_ID
      AND LEVELS = @LV_CUR_LEVEL
      AND QMART = @WF_KEY+12(2).

    SELECT SINGLE * FROM ZPM_NOT_CDS INTO @DATA(LS_NOT)
      WHERE QMNUM = @WF_KEY(12).

*----- Read Attached Doc from Workflow Approval -----*
    CALL FUNCTION 'SAP_WAPI_GET_ATTACHMENTS'
      EXPORTING
        WORKITEM_ID = IM_WORKITEM_ID
      IMPORTING
        RETURN_CODE = ZRETURN_CODE
      TABLES
        ATTACHMENTS = ZATTACHMENTS.
    LOOP AT ZATTACHMENTS ASSIGNING FIELD-SYMBOL(<FS_ATTACH>) WHERE OBJECT_TYP = 'CM'.

      DATA(DOCID) = <FS_ATTACH>-OBJECT_ID.
      REPLACE ALL OCCURRENCES OF 'SOFM' IN DOCID WITH ''.
      CONDENSE DOCID.
      ZDOCID = DOCID.

      ZFILTER-SEND_INFO = 'X'.
      CALL FUNCTION 'SO_DOCUMENT_READ_API1'
        EXPORTING
          DOCUMENT_ID                = ZDOCID
          FILTER                     = ZFILTER
        IMPORTING
          DOCUMENT_DATA              = DOCUMENT_DATA
        TABLES
          OBJECT_HEADER              = OBJECT_HEADER
          OBJECT_CONTENT             = OBJECT_CONTENT
        EXCEPTIONS
          DOCUMENT_ID_NOT_EXIST      = 1
          OPERATION_NO_AUTHORIZATION = 2
          X_ERROR                    = 3.
      LS_CUR_HST-REMARKS =  REDUCE #( INIT TEXT = `` FOR <LINE1> IN OBJECT_CONTENT NEXT  TEXT = TEXT && | | && <LINE1>-LINE  ).

    ENDLOOP.

    DATA(LV_APPROVAL_TEXT) = SWITCH #( APP_REJ WHEN '1' THEN |Approved|
                                               WHEN '2' THEN |Reverted|
                                               WHEN '0' THEN |Rejected| ).

*Get Max History No.
    SELECT MAX( HST_ID ) FROM ZPM_WF_HST INTO @DATA(LV_HST_ID).
    LV_HST_ID = LV_HST_ID + 1.

    LS_CUR_HST-HST_ID = LV_HST_ID.
*    LS_PRE_HST-WF_ID = LV_WF_ID.
    LS_CUR_HST-LEVELS = LV_CUR_LEVEL.
    LS_CUR_HST-P_STAT = LS_PRE_HST-C_STAT.
    LS_CUR_HST-ERNAM = SY-UNAME.
    LS_CUR_HST-OBJ_DATE = SY-DATUM.
    LS_CUR_HST-UZEIT = SY-UZEIT.
    LS_CUR_HST-APP_REJ = APP_REJ.

*----- Set Level of WF itration -----*
    CASE APP_REJ.

      WHEN '1'. "Approved
        IF IE_LEVEL = IM_MAX_LEVEL.
          IE_WF_COMP = LS_CUR_HST-WFSTAT = 'X'.
        ELSE.
          IE_LEVEL = IE_LEVEL + 1.
          IE_WF_COMP = LS_CUR_HST-WFSTAT = ''.
        ENDIF.

*---- Status for current level ----*
        IF ( LS_CUR_HST-C_STAT <> LS_SET-LSTAT ) AND IE_LEVEL <> '1'.
          LS_CUR_HST-C_STAT = LS_SET-LSTAT.

          SELECT SINGLE STSMA FROM JSTO INTO @DATA(LV_STSMA)
            WHERE OBJNR EQ @LS_CUR_HST-OBJNR.

          SELECT SINGLE * FROM TJ30T INTO @DATA(LS_TJ30T)
            WHERE SPRAS EQ @SY-LANGU
            AND TXT04 EQ @LS_CUR_HST-C_STAT
            AND STSMA EQ @LV_STSMA.

          LV_OBJNR = LS_CUR_HST-OBJNR.
          LV_STATUS = LS_TJ30T-ESTAT.

          CALL FUNCTION 'STATUS_CHANGE_EXTERN'
            EXPORTING
*             CHECK_ONLY          = ' '
              CLIENT              = SY-MANDT
              OBJNR               = LV_OBJNR
              USER_STATUS         = LV_STATUS
*             SET_INACT           = ' '
              SET_CHGKZ           = 'X'
              NO_CHECK            = 'X'
            IMPORTING
              STONR               = STONR
            EXCEPTIONS
              OBJECT_NOT_FOUND    = 1
              STATUS_INCONSISTENT = 2
              STATUS_NOT_ALLOWED  = 3.
          IF SY-SUBRC EQ 0.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
          ENDIF.
        ENDIF.
        MODIFY ZPM_WF_HST FROM LS_CUR_HST.

      WHEN '2'. "Reverted
        IE_LEVEL = IE_LEVEL - 1.
        IE_WF_COMP = LS_CUR_HST-WFSTAT = ''.

*Get Detail for Routing of current level
        SELECT SINGLE LSTAT FROM ZPM_SET_V1 INTO LS_CUR_HST-C_STAT
          WHERE WF_ID = IM_WF_ID
          AND LEVELS = IE_LEVEL
          AND QMART = WF_KEY+12(2).
        IF LS_CUR_HST-C_STAT <> LS_PRE_HST-C_STAT.

          SELECT SINGLE STSMA FROM JSTO INTO LV_STSMA
            WHERE OBJNR EQ LS_CUR_HST-OBJNR.

          SELECT SINGLE * FROM TJ30T INTO LS_TJ30T
            WHERE SPRAS EQ SY-LANGU
            AND TXT04 EQ LS_CUR_HST-C_STAT
            AND STSMA EQ LV_STSMA.

          LV_OBJNR = LS_CUR_HST-OBJNR.
          LV_STATUS = LS_TJ30T-ESTAT.

          CALL FUNCTION 'STATUS_CHANGE_EXTERN'
            EXPORTING
              CLIENT              = SY-MANDT
              OBJNR               = LV_OBJNR
              USER_STATUS         = LV_STATUS
              SET_CHGKZ           = 'X'
              NO_CHECK            = 'X'
            IMPORTING
              STONR               = STONR
            EXCEPTIONS
              OBJECT_NOT_FOUND    = 1
              STATUS_INCONSISTENT = 2
              STATUS_NOT_ALLOWED  = 3.
          IF SY-SUBRC EQ 0.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
          ENDIF.
        ENDIF.

        MODIFY ZPM_WF_HST FROM LS_CUR_HST.

      WHEN '0'. "Rejected
        IF IE_LEVEL = IM_MAX_LEVEL  OR IE_LEVEL = '1'.
          IE_WF_COMP = LS_CUR_HST-WFSTAT = 'X'.
        ENDIF.
        LS_CUR_HST-C_STAT = 'CNCL'.

        SELECT SINGLE STSMA FROM JSTO INTO LV_STSMA
          WHERE OBJNR EQ LS_CUR_HST-OBJNR.

        SELECT SINGLE * FROM TJ30T INTO LS_TJ30T
          WHERE SPRAS EQ SY-LANGU
          AND TXT04 EQ LS_CUR_HST-C_STAT
          AND STSMA EQ LV_STSMA.

        LV_OBJNR = LS_CUR_HST-OBJNR.
        LV_STATUS = LS_TJ30T-ESTAT.

        CALL FUNCTION 'STATUS_CHANGE_EXTERN'
          EXPORTING
            CLIENT              = SY-MANDT
            OBJNR               = LV_OBJNR
            USER_STATUS         = LV_STATUS
            SET_CHGKZ           = 'X'
            NO_CHECK            = 'X'
          IMPORTING
            STONR               = STONR
          EXCEPTIONS
            OBJECT_NOT_FOUND    = 1
            STATUS_INCONSISTENT = 2
            STATUS_NOT_ALLOWED  = 3.
        IF SY-SUBRC EQ 0.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
        ENDIF.

*Notification Set Deletion Flag
        DATA: SYSTEMSTATUS TYPE  BAPI2080_NOTADT-SYSTATUS,
              USERSTATUS   TYPE  BAPI2080_NOTADT-USRSTATUS,
              LV_NOTIF     TYPE BAPI2080_NOTHDRE-NOTIF_NO.

        LV_NOTIF = WF_KEY(12).
        CALL FUNCTION 'IBAPI_ALM_NOTIF_SETDELFLAG'
          EXPORTING
            NUMBER       = LS_CUR_HST-QMNUM
            LANGU        = SY-LANGU
*           LANGUISO     = SY-LANGU
*           TESTRUN      = ' '
          IMPORTING
            SYSTEMSTATUS = SYSTEMSTATUS
            USERSTATUS   = USERSTATUS
          TABLES
            RETURN       = LT_RETURN.
        IF SYSTEMSTATUS IS NOT INITIAL..
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
        ENDIF.
        MODIFY ZPM_WF_HST FROM LS_CUR_HST.

    ENDCASE.
    BREAK AC_WF1.
*&--- Get user Detail ---&*
    LV_USER = IM_APPROVERS+2.
    CALL FUNCTION 'BAPI_USER_GET_DETAIL'
      EXPORTING
        USERNAME      = LV_USER
        CACHE_RESULTS = 'X'
      TABLES
        RETURN        = LT_RETURN
        ADDSMTP       = LT_ADDSMTP.

*&--- Assign the Email id and User id to  Whom you want to Send --------& Connit by adnan khan
*****************    LS_REC-RECEIVER   = LV_USER.  "&----- Assign SAP User Id
*****************    LS_REC-REC_TYPE   = 'B'.          "&-- Send to SAP Inbox
*****************    LS_REC-COM_TYPE   = 'INT'.
*****************    LS_REC-NOTIF_DEL  = 'X'.
*****************    LS_REC-NOTIF_NDEL = 'X'.
*****************    APPEND LS_REC TO LT_RECEIVERS .

    LOOP AT LT_ADDSMTP ASSIGNING FIELD-SYMBOL(<LINE>).
      LS_REC-RECEIVER   = <LINE>-E_MAIL.  "&----- Assign SAP User Id
      LS_REC-REC_TYPE   = 'U'.            "&-- Send to Internet email
      LS_REC-COM_TYPE   = 'INT'.
      LS_REC-NOTIF_DEL  = 'X'.
      LS_REC-NOTIF_NDEL = 'X'.
      APPEND LS_REC TO LT_RECEIVERS .
    ENDLOOP.

    "Zone
    SELECT SINGLE PLTXT FROM IFLO INTO @DATA(LV_ZONE)
      WHERE TPLNR = @LS_NOT-TPLNR(10)
      AND SPRAS = @SY-LANGU.

    "Next Approvars
    DATA: NEXT_LEVEL       TYPE ZLEVEL,
          T_AGENTS         TYPE ZTT_AGENT,
          NEXT_APPROVED_BY TYPE CHAR255.

    NEXT_LEVEL = IE_LEVEL.
    CALL FUNCTION 'ZFM_PM_NOT_NEXT_USER'
      EXPORTING
        WF_KEY    = WF_KEY
        IM_WF_ID  = IM_WF_ID
        IM_LEVEL  = NEXT_LEVEL
        INITIATOR = INITIATOR
      IMPORTING
        ET_AGENTS = T_AGENTS.
*    DATA(NEXT_APPROVED_BY) = REDUCE #( INIT TXT = `` FOR LS IN T_AGENTS NEXT TXT = TXT && | | && LS-ZAGENT ).
    LOOP AT T_AGENTS INTO DATA(LS).
      IF NEXT_APPROVED_BY IS INITIAL.
        NEXT_APPROVED_BY = |{ LS-ZAGENT+2 }|.
      ELSE.
        NEXT_APPROVED_BY = |{ NEXT_APPROVED_BY } - { LS-ZAGENT+2 }|.
      ENDIF.
    ENDLOOP.

    "Fiori Link
    CASE SY-HOST.
      WHEN 'uekhidev'.
        DATA(FIORI_INNER) = |"https://uekhiwdp.uead.uep.com.pk:44301/sap/bc/ui5_ui5/ui2/ushell/shells/abap/Fiorilaunchpad.html#WorkflowTask-displayInbox?allItems=true&sap-client=110"|.
        DATA(FIORI_OUTER) = |"https://uekhiwdp.uead.uep.com.pk:44301/sap/bc/ui5_ui5/ui2/ushell/shells/abap/Fiorilaunchpad.html#WorkflowTask-displayInbox?allItems=true&sap-client=110"|.
      WHEN 'uekhiqas'.
        FIORI_INNER = |"https://uekhiwdp.uead.uep.com.pk:44302/sap/bc/ui5_ui5/ui2/ushell/shells/abap/Fiorilaunchpad.html#WorkflowTask-displayInbox?allItems=true&sap-client=200"|.
        FIORI_OUTER = |"https://uekhiwdp.uead.uep.com.pk:44302/sap/bc/ui5_ui5/ui2/ushell/shells/abap/Fiorilaunchpad.html#WorkflowTask-displayInbox?allItems=true&sap-client=200"|.
      WHEN 'uekhiprdappv'.
        FIORI_INNER = |"https://uekhiwdp.uead.uep.com.pk:44303/sap/bc/ui5_ui5/ui2/ushell/shells/abap/Fiorilaunchpad.html#WorkflowTask-displayInbox?allItems=true"|.
        FIORI_OUTER = |"https://uekhiwdp.uead.uep.com.pk:44303/sap/bc/ui5_ui5/ui2/ushell/shells/abap/Fiorilaunchpad.html#WorkflowTask-displayInbox?allItems=true"|.
    ENDCASE.

    DATA(LV_DATE) = |{ LS_NOT-ERDAT+6(2) }.{ LS_NOT-ERDAT+4(2) }.{ LS_NOT-ERDAT+0(4) }</td></tr>|.
    DATA(LV_DATE2) = |{ LS_CUR_HST-OBJ_DATE+6(2) }.{ LS_CUR_HST-OBJ_DATE+4(2) }.{ LS_CUR_HST-OBJ_DATE+0(4) }</td></tr>|.
    DATA(LV_TIME) = |{ LS_CUR_HST-UZEIT+0(2) }:{ LS_CUR_HST-UZEIT+2(2) }:{ LS_CUR_HST-UZEIT+4(2) }</td></tr>|.
    DATA(LV_NUM1) = |{ LS_NOT-QMNUM ALPHA = OUT }|.
    DATA(LV_NUM2) = |{ LS_NOT-EQUNR ALPHA = OUT }|.
*-------------& EMAIL MESSAGE  &-----------------*
    LV_SUBJECT = |Notification { WF_KEY } has been { LV_APPROVAL_TEXT } by you and forwarded to next authority|.
    LS_MESSAGE-LINE = '<html><body style="background-color: #FFFFFF;" font-family="arial, verdana, courier;" font-size="2">'.
    APPEND LS_MESSAGE TO LT_MESSAGE.
    LS_MESSAGE-LINE = '<table style="margin: 10px;" border="1px" border-color="#000000" width="100%">'.
    APPEND LS_MESSAGE TO LT_MESSAGE.

    LT_MESSAGE = VALUE #( BASE LT_MESSAGE
    ( LINE = |<tr><td width=25%>Notification No.</td><td width=100%>{ LV_NUM1 }</td></tr>| )
    ( LINE = |<tr><td width=25%>Notification Desc</td><td width=100%>{ LS_NOT-QMTXT }</td></tr>| )
    ( LINE = |<tr><td width=25%>Notification Creation Date</td><td width=100%>{ LV_DATE }</td></tr>| )
    ( LINE = |<tr><td width=25%>Priority</td><td width=100%>{ LS_NOT-PRIOKX }</td></tr>| )
    ( LINE = |<tr><td width=25%>ABC Indicator</td><td width=100%>{ LS_NOT-ABCTX }</td></tr>| )
    ( LINE = |<tr><td width=25%>User Status</td><td width=100%>{ LS_CUR_HST-C_STAT }</td></tr>| )
    ( LINE = |<tr><td width=25%>Status Date</td><td width=100%>{ LS_CUR_HST-OBJ_DATE }</td></tr>| )
    ( LINE = |<tr><td width=25%>Last Approved By</td><td width=100%>{ LV_USER }</td></tr>| )
    ( LINE = |<tr><td width=25%>Last Approved By Date</td><td width=100%>{ LV_DATE2 }</td></tr>| )
    ( LINE = |<tr><td width=25%>Last Approved By Time</td><td width=100%>{ LV_TIME }</td></tr>| )
    ( LINE = |<tr><td width=25%>Next Approval By</td><td width=100%>{ NEXT_APPROVED_BY }</td></tr>| )
    ( LINE = |<tr><td width=25%>Equip no</td><td width=100%>{ LV_NUM2 }</td></tr>| )
    ( LINE = |<tr><td width=25%>Equip no Desc</td><td width=100%>{ LS_NOT-EQKTX }</td></tr>| )
    ( LINE = |<tr><td width=25%>Tech ID</td><td width=100%>{ LS_NOT-TIDNR }</td></tr>| )
    ( LINE = |<tr><td width=25%>Created By</td><td width=100%>{ INITIATOR+2 }</td></tr>| )
    ( LINE = |<tr><td width=25%>Functional Location Desc</td><td width=100%>{ LS_NOT-PLTXT }</td></tr>| )
    ( LINE = |<tr><td width=25%>Facility/Remote/Field</td><td width=100%>{ LS_NOT-KTEXT }</td></tr>| )
    ( LINE = |<tr><td width=25%>Zone</td><td width=100%>{ LV_ZONE }</td></tr>| )
*    ( LINE = |<tr><td width=100%><a href={ FIORI_INNER }>Fiori within UEP Primise</a></td></tr>| )
*    ( LINE = |<tr><td width=100%><a href={ FIORI_OUTER }>Fiori outside UEP Primise</a></td></tr>| )
    )..
    IF LS_NOT-QMART = 'M8'.
      LS_MESSAGE-LINE  = |<tr><td width=25%>Target Function Location</td><td width=100%>{ LS_NOT-ZQMTXT }</td></tr>| .
      APPEND LS_MESSAGE TO LT_MESSAGE.
    ENDIF.

    LS_MESSAGE-LINE = |</table>|.
    APPEND LS_MESSAGE TO LT_MESSAGE.

    LS_MESSAGE-LINE = '<table style="margin: 10px;" width="100%">'.
    APPEND LS_MESSAGE TO LT_MESSAGE.
*    LS_MESSAGE-LINE = |<tr><td width=100%><a href={ FIORI_INNER }>Fiori within UEP Primise</a></td></tr>|.
*    APPEND LS_MESSAGE TO LT_MESSAGE.
    LS_MESSAGE-LINE = |<tr><td width=100%><a href={ FIORI_OUTER }>SAP S/4 HANA</a></td></tr>|.
    APPEND LS_MESSAGE TO LT_MESSAGE.
    LS_MESSAGE-LINE = |</table>|.
    APPEND LS_MESSAGE TO LT_MESSAGE.

    LS_MESSAGE-LINE = |</body></html>|.
    APPEND LS_MESSAGE TO LT_MESSAGE.


    TRY.
*     -------- create persistent send request ------------------------
        GO_SEND_REQUEST = CL_BCS=>CREATE_PERSISTENT( ).



*     -------- create and set document -------------------------------
*     create document from internal table with text

        GO_DOCUMENT = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
          I_TYPE    = 'HTM'
          I_TEXT    = LT_MESSAGE
*         i_length  = '12'
          I_SUBJECT = '' ).             "'


        CALL METHOD GO_SEND_REQUEST->SET_MESSAGE_SUBJECT
          EXPORTING
            IP_SUBJECT = LV_SUBJECT.

*      IF C_NOTICE IS NOT INITIAL.
*        LV_ATT_NAME = 'Notice of Termination'.
*      ENDIF.

*      IF NOT LI_CONTENT_HEX IS INITIAL.
*        GO_DOCUMENT->ADD_ATTACHMENT(
*             I_ATTACHMENT_TYPE      = 'PDF'
*             I_ATTACHMENT_SUBJECT   = LV_ATT_NAME    "gv_title   "attachment subject
*             I_ATTACHMENT_SIZE      = LV_LEN
*             I_ATT_CONTENT_HEX      = LI_CONTENT_HEX ).
*      ENDIF.

        CALL METHOD GO_SEND_REQUEST->SET_DOCUMENT( GO_DOCUMENT ).


*** Send mail using Email_ID
*      SENDER1 = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'zafar.k@xrbia.com' ).
        SENDER1 = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'sap_wfrt@ueg.com' ).
        CALL METHOD GO_SEND_REQUEST->SET_SENDER
          EXPORTING
            I_SENDER = SENDER1.

        SORT LT_ADDSMTP.
        DELETE LT_ADDSMTP WHERE E_MAIL IS INITIAL.
        DATA:LV_EMAIL TYPE ADR6-SMTP_ADDR.
        LV_EMAIL = VALUE #( LT_ADDSMTP[ 1 ]-E_MAIL OPTIONAL  ).

        LO_RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(
          LV_EMAIL ).

*     add recipient with its respective attributes to send request
        CALL METHOD GO_SEND_REQUEST->ADD_RECIPIENT
          EXPORTING
            I_RECIPIENT = LO_RECIPIENT
            I_EXPRESS   = 'X'.

* set outbox flag
*  try.
*      if outbox = 'X'.
        CALL METHOD GO_SEND_REQUEST->SEND_REQUEST->SET_LINK_TO_OUTBOX( 'X' ).
*      endif.
*    catch cx_bcs.
*  endtry.


*     ---------- send document ---------------------------------------
*    TRY.
        CALL METHOD GO_SEND_REQUEST->SET_SEND_IMMEDIATELY
          EXPORTING
            I_SEND_IMMEDIATELY = 'X'.
*     CATCH cx_send_req_bcs .
*    ENDTRY.

        CALL METHOD GO_SEND_REQUEST->SEND(
          EXPORTING
            I_WITH_ERROR_SCREEN = 'X'
          RECEIVING
            RESULT              = LV_SENT_TO_ALL ).

        IF LV_SENT_TO_ALL = 'X'.
          MESSAGE S000(8I) WITH 'Email send successfully'.
        ELSEIF LV_SENT_TO_ALL IS INITIAL.
          MESSAGE S000(8I) WITH 'Email not send'.
        ENDIF.

        COMMIT WORK.

      CATCH CX_BCS INTO LO_BCS_EXCEPTION.

    ENDTRY.



*****************************************************************************************************************************Populate the subject/generic message attributes --- Attributes of new document
****************************************************************************************************************************    GD_DOC_DATA-DOC_SIZE = 1.
****************************************************************************************************************************    GD_DOC_DATA-OBJ_LANGU = SY-LANGU.
****************************************************************************************************************************    GD_DOC_DATA-OBJ_NAME = 'SAPRPT'.
****************************************************************************************************************************    GD_DOC_DATA-OBJ_DESCR = LV_SUBJECT.
****************************************************************************************************************************    GD_DOC_DATA-SENSITIVTY = 'F'.
*****************************************************************************************************************************------- Describe the body of the message
****************************************************************************************************************************
*****************************************************************************************************************************Information about structure of data tables
****************************************************************************************************************************    CLEAR LS_PACK.
****************************************************************************************************************************    REFRESH LT_PACKING_LIST.
****************************************************************************************************************************    LS_PACK-TRANSF_BIN = SPACE.
****************************************************************************************************************************    LS_PACK-HEAD_START = 1.
****************************************************************************************************************************    LS_PACK-HEAD_NUM = 0.
****************************************************************************************************************************    LS_PACK-BODY_START = 1.
****************************************************************************************************************************    DESCRIBE TABLE LT_MESSAGE LINES LS_PACK-BODY_NUM.
****************************************************************************************************************************    LS_PACK-DOC_TYPE = 'HTML'.
****************************************************************************************************************************    APPEND LS_PACK TO LT_PACKING_LIST.
****************************************************************************************************************************
*****************************************************************************************************************************&------ Call the Function Module to send the message to External and SAP Inbox
****************************************************************************************************************************    CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
****************************************************************************************************************************      EXPORTING
****************************************************************************************************************************        DOCUMENT_DATA              = GD_DOC_DATA
****************************************************************************************************************************        PUT_IN_OUTBOX              = 'X'
****************************************************************************************************************************        COMMIT_WORK                = 'X'
****************************************************************************************************************************      TABLES
****************************************************************************************************************************        PACKING_LIST               = LT_PACKING_LIST
****************************************************************************************************************************        CONTENTS_TXT               = LT_MESSAGE
****************************************************************************************************************************        RECEIVERS                  = LT_RECEIVERS
****************************************************************************************************************************      EXCEPTIONS
****************************************************************************************************************************        TOO_MANY_RECEIVERS         = 1
****************************************************************************************************************************        DOCUMENT_NOT_SENT          = 2
****************************************************************************************************************************        DOCUMENT_TYPE_NOT_EXIST    = 3
****************************************************************************************************************************        OPERATION_NO_AUTHORIZATION = 4
****************************************************************************************************************************        PARAMETER_ERROR            = 5
****************************************************************************************************************************        X_ERROR                    = 6
****************************************************************************************************************************        ENQUEUE_ERROR              = 7
****************************************************************************************************************************        OTHERS                     = 8.
****************************************************************************************************************************    IF SY-SUBRC <> 0.
****************************************************************************************************************************      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
****************************************************************************************************************************              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
****************************************************************************************************************************    ENDIF.



  ENDMETHOD.


  METHOD FETCH_DYN.
    TYPES: BEGIN OF TY_AGENT,
             ZAGENT TYPE ZAGENT,
           END OF TY_AGENT.
    TYPES: BEGIN OF TY_STR,
             USRID TYPE CHAR50,
             PLANS TYPE PLANS,
             SOBID TYPE SOBID,
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
    SELECT SINGLE * FROM ZPM_WF_HST INTO @DATA(LS_HST)
      WHERE QMNUM = @WF_KEY(12)
      AND WF_ID EQ @IM_WF_ID
*      AND LEVELS = @LV_PRE_LEVEL
      AND HST_ID = ( SELECT MAX( HST_ID ) FROM ZPM_WF_HST WHERE QMNUM = @WF_KEY(12) AND WF_ID = @IM_WF_ID ).
    DATA(LS_CUR_HST) = LS_HST.

*----- Update ZPM_WF_NEX Table for Order Assigned users -----------*
    MOVE-CORRESPONDING LS_HST TO LS_WF_NEX.
    LS_WF_NEX-LEVELS = IM_LEVEL.

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

      SELECT SINGLE * FROM ZPM_SET_V1 INTO @DATA(LS_SET)
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
            AND SUBTY IN ( 'A002', 'A005' )
            AND ENDDA = '99991231'.
          IF SY-SUBRC <> 0.
*----- Incase Position to Position heirarchy not maintain ----*
            SELECT ZPOSITION AS SOBID FROM ZSUBCOEMP INTO CORRESPONDING FIELDS OF TABLE LT_SOBID
*              WHERE ZSAP_ID = LS_HST-ERNAM. *Change by adnan khan 12.08.2022
              WHERE ( ZSAP_ID = LS_HST-ERNAM OR ZSAP_ID = LS_NOT-ERNAM )
              AND ZPOSITION <> '00000000'.
            IF SY-SUBRC <> 0. "In case of contractual supervisor
              SELECT ZSUP_ID AS ZAGENT FROM ZSUBCOEMP INTO CORRESPONDING FIELDS OF TABLE LT_AGENTS
                  WHERE ( ZSAP_ID = LS_HST-ERNAM OR ZSAP_ID = LS_NOT-ERNAM ).
            ENDIF.
          ENDIF.

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

        ELSE. "if Pernr not found against the SAP user

*----- Incase Position to Position heirarchy not maintain ----*
          SELECT ZPOSITION AS SOBID FROM ZSUBCOEMP INTO CORRESPONDING FIELDS OF TABLE LT_SOBID
*            WHERE ZSAP_ID = LS_HST-ERNAM.added by adnan khan 12.08.2022
            WHERE ( ZSAP_ID = LS_HST-ERNAM OR ZSAP_ID = LS_NOT-ERNAM )
            AND ZPOSITION <> '00000000'.
          IF SY-SUBRC <> 0.
            SELECT ZSUP_ID AS ZAGENT FROM ZSUBCOEMP INTO CORRESPONDING FIELDS OF TABLE LT_AGENTS
              WHERE ( ZSAP_ID = LS_HST-ERNAM OR ZSAP_ID = LS_NOT-ERNAM ).
          ENDIF.

          LOOP AT LT_SOBID INTO LS_SOBID.
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
        IF IM_WF_ID NE 'WF-3'.                                               "Added on request of farhan PM
          IF LS_NOT-TPLNR(3) IS NOT INITIAL AND LS_NOT-TPLNR+7(3) IS NOT INITIAL.

            SELECT ERNAM AS ZAGENT FROM ZPM_ROT INTO TABLE LT_AGENTS
              WHERE ( BLOCK = LS_NOT-TPLNR(3) OR ZZONE = LS_NOT-TPLNR+7(3) ) "Firts 3 Chars to scan
              AND WF_ID = IM_WF_ID
                 AND IWERK = LS_NOT-IWERK
*             AND WF_AUTH = LV_ZWF_AUTH
               AND LEVELS = IM_LEVEL.
            IF LT_AGENTS IS INITIAL.

              SELECT ERNAM AS ZAGENT FROM ZPM_ROT INTO TABLE LT_AGENTS
               WHERE ( BLOCK = LS_NOT-TPLNR(3) OR ZZONE = LS_NOT-TPLNR+7(3) ) "Firts 3 Chars to scan
               AND WF_ID = IM_WF_ID
*                           AND WF_AUTH = LV_ZWF_AUTH
                AND LEVELS = IM_LEVEL.

            ENDIF.


          ELSEIF LS_NOT-TPLNR(3) IS NOT INITIAL AND LS_NOT-TPLNR+7(3) IS INITIAL.
            SELECT ERNAM AS ZAGENT FROM ZPM_ROT INTO TABLE LT_AGENTS
              WHERE ( BLOCK = LS_NOT-TPLNR(3) ) "Firts 3 Chars to scan
              AND WF_ID = IM_WF_ID
                 AND IWERK = LS_NOT-IWERK
              AND LEVELS = IM_LEVEL.
            IF LT_AGENTS IS INITIAL.
              SELECT ERNAM AS ZAGENT FROM ZPM_ROT INTO TABLE LT_AGENTS
                WHERE ( BLOCK = LS_NOT-TPLNR(3) ) "Firts 3 Chars to scan
                AND WF_ID = IM_WF_ID
                AND LEVELS = IM_LEVEL.
            ENDIF.
          ENDIF.

        ELSEIF IM_WF_ID EQ 'WF-3'. "Added on request of farhan PM
          IF IM_LEVEL = 5 OR IM_LEVEL = 6.
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

          ELSE.
            SELECT ERNAM AS ZAGENT FROM ZPM_ROT INTO TABLE LT_AGENTS
                         WHERE ( BLOCK = LS_NOT-TPLNR(3) OR ZZONE = LS_NOT-TPLNR+7(3) ) "Firts 3 Chars to scan
                         AND WF_ID = IM_WF_ID
                         AND IWERK = LS_NOT-IWERK
*             AND WF_AUTH = LV_ZWF_AUTH
                         AND LEVELS = IM_LEVEL.
            IF LT_AGENTS IS INITIAL.
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
* CRF : Include hte COst center agent determination logic
*        CALL FUNCTION 'ZFM_MM_BUDGET_OWNER'
*          EXPORTING
*            PS_PSP_PNR = LS_NOT-PROID
*          TABLES
*            AGENTS     = WBS_AGENTS.
        SELECT SINGLE * FROM VIQMEL INTO @DATA(LS_VIQMEL) WHERE QMNUM = @WF_KEY(12).

        CALL FUNCTION 'ZFM_MM_BUDGET_OWNER'
          EXPORTING
            PS_PSP_PNR = LS_VIQMEL-PROID
            KOSTL      = LS_VIQMEL-KOSTL
            KOKRS      = LS_VIQMEL-KOKRS "ls_not-kokrs
          TABLES
            AGENTS     = WBS_AGENTS.

        LT_AGENTS = CORRESPONDING #( WBS_AGENTS MAPPING ZAGENT = AGENT ).

      ENDIF.

    ENDIF. "IM_LEVEL

*---- Get Agents Ready -----*
    LOOP AT LT_AGENTS INTO LS_AGENTS.
      LV_USER = LS_AGENTS-ZAGENT.
*&--- Get user Detail ---&*
      CALL FUNCTION 'BAPI_USER_GET_DETAIL'
        EXPORTING
          USERNAME      = LV_USER
          CACHE_RESULTS = 'X'
*         EXTUID_GET    =
        TABLES
          RETURN        = LT_RETURN
          ADDSMTP       = LT_ADDSMTP.

      LS_AGENTS-ZAGENT = |US{ LS_AGENTS-ZAGENT }|.
      APPEND LS_AGENTS TO ET_AGENTS.
**************************************************************&--- Assign the Email id and User id to  Whom you want to Send --------& Commit by adnan khan to stop message tp sap inbox
*************************************************************      LS_REC-RECEIVER   = LS_AGENTS-ZAGENT+2.  "&----- Assign SAP User Id
*************************************************************      LS_REC-REC_TYPE   = 'B'.          "&-- Send to SAP Inbox
*************************************************************      LS_REC-COM_TYPE   = 'INT'.
*************************************************************      LS_REC-NOTIF_DEL  = 'X'.
*************************************************************      LS_REC-NOTIF_NDEL = 'X'.
*************************************************************      APPEND LS_REC TO LT_RECEIVERS .

      LOOP AT LT_ADDSMTP ASSIGNING FIELD-SYMBOL(<LINE>).
        LS_REC-RECEIVER   = <LINE>-E_MAIL.  "&----- Assign SAP User Id
        LS_REC-REC_TYPE   = 'U'.            "&-- Send to Internet email
        LS_REC-COM_TYPE   = 'INT'.
        LS_REC-NOTIF_DEL  = 'X'.
        LS_REC-NOTIF_NDEL = 'X'.
        APPEND LS_REC TO LT_RECEIVERS .
      ENDLOOP.

*----- Update ZPM_WF_NEX Table for Order Assigned users -----------*
      IF LV_NEXT_APPR_BY IS INITIAL.
        LV_NEXT_APPR_BY = |{ LS_AGENTS-ZAGENT+2 }|.
      ELSE.
        LV_NEXT_APPR_BY = |{ LV_NEXT_APPR_BY } - { LS_AGENTS-ZAGENT+2 }|.
      ENDIF.
      LS_WF_NEX-UNAME = LS_AGENTS-ZAGENT+2.
      LS_WF_NEX-UDATE = SY-DATUM.
      LS_WF_NEX-UZEIT = SY-UZEIT.
      INSERT ZPM_WF_NEX FROM LS_WF_NEX.

      CLEAR: LS_AGENTS, LT_ADDSMTP[].
    ENDLOOP.

    "Zone
    SELECT SINGLE PLTXT FROM IFLO INTO @DATA(LV_ZONE)
      WHERE TPLNR = @LS_NOT-TPLNR(10)
      AND SPRAS = @SY-LANGU.

*-------------& EMAIL MESSAGE  &-----------------*
*/*** CRF : M7 Budget Owner Email subject need to be changed.
    IF LS_SET-WF_DET_KEY = 'WD'. "WBS Budget Owner
      LV_SUBJECT = |BE CAREFUL YOU ARE PROVIDING APPROVAL AS A BUDGET OWNER Notification { WF_KEY }?|.
    ELSE.
      LV_SUBJECT = |Do you Want to Approve or Reject Notification { WF_KEY }?|.
    ENDIF.
*    EV_SUBJECT = LV_SUBJECT.

    DATA(LV_DATE) = |{ LS_NOT-ERDAT+6(2) }.{ LS_NOT-ERDAT+4(2) }.{ LS_NOT-ERDAT+0(4) }</td></tr>|.
    DATA(LV_DATE2) = |{ LS_HST-OBJ_DATE+6(2) }.{ LS_HST-OBJ_DATE+4(2) }.{ LS_HST-OBJ_DATE+0(4) }</td></tr>|.
    DATA(LV_TIME) = |{ LS_HST-UZEIT+0(2) }:{ LS_HST-UZEIT+2(2) }:{ LS_HST-UZEIT+4(2) }</td></tr>|.
    DATA(LV_NUM1) = |{ LS_NOT-QMNUM ALPHA = OUT }|.
    DATA(LV_NUM2) = |{ LS_NOT-EQUNR ALPHA = OUT }|.

    DATA(APPROVED_BY) = LS_HST-ERNAM.
    DATA(APPROVED_DATE) = LV_DATE2.

*--- Clear last Approved by for very first aapprover ---*
    IF LS_HST-P_STAT IS INITIAL AND IM_LEVEL EQ 2.
      CLEAR: APPROVED_BY, APPROVED_DATE, LV_TIME.
    ENDIF.

    LS_MESSAGE-LINE = '<html><body style="background-color: #FFFFFF;" font-family="arial, verdana, courier;" font-size="2">'.
    APPEND LS_MESSAGE TO LT_MESSAGE.
    LS_MESSAGE-LINE = '<table style="margin: 10px;" border="1px" border-color="#000000" width="100%">'.
    APPEND LS_MESSAGE TO LT_MESSAGE.

    LT_MESSAGE = VALUE #( BASE LT_MESSAGE
    ( LINE = |<tr><td width=25%>Notification No.</td><td width=100%>{ LV_NUM1 }</td></tr>| )
    ( LINE = |<tr><td width=25%>Notification Desc</td><td width=100%>{ LS_NOT-QMTXT }</td></tr>| )
    ( LINE = |<tr><td width=25%>Notification Creation Date</td><td width=100%>{ LV_DATE }</td></tr>| )
    ( LINE = |<tr><td width=25%>Priority</td><td width=100%>{ LS_NOT-PRIOKX }</td></tr>| )
    ( LINE = |<tr><td width=25%>ABC Indicator</td><td width=100%>{ LS_NOT-ABCTX }</td></tr>| )
    ( LINE = |<tr><td width=25%>User Status</td><td width=100%>{ LS_HST-C_STAT }</td></tr>| )
    ( LINE = |<tr><td width=25%>Status Date</td><td width=100%>{ LV_DATE2 }</td></tr>| )
    ( LINE = |<tr><td width=25%>Last Approved By</td><td width=100%>{ APPROVED_BY }</td></tr>| )
    ( LINE = |<tr><td width=25%>Last Approved By Date</td><td width=100%>{ APPROVED_DATE }</td></tr>| )
    ( LINE = |<tr><td width=25%>Last Approved By Time</td><td width=100%>{ LV_TIME }</td></tr>| )
    ( LINE = |<tr><td width=25%>Next Approval By</td><td width=100%>{ LV_NEXT_APPR_BY }</td></tr>| )
    ( LINE = |<tr><td width=25%>Equip no</td><td width=100%>{ LV_NUM2 }</td></tr>| )
    ( LINE = |<tr><td width=25%>Equip no Desc</td><td width=100%>{ LS_NOT-EQKTX }</td></tr>| )
    ( LINE = |<tr><td width=25%>Tech ID</td><td width=100%>{ LS_NOT-TIDNR }</td></tr>| )
    ( LINE = |<tr><td width=25%>Created By</td><td width=100%>{ INITIATOR+2 }</td></tr>| )
    ( LINE = |<tr><td width=25%>Functional Location Desc</td><td width=100%>{ LS_NOT-PLTXT }</td></tr>| )
    ( LINE = |<tr><td width=25%>Facility/Remote/Field</td><td width=100%>{ LS_NOT-KTEXT }</td></tr>| )
    ( LINE = |<tr><td width=25%>Zone</td><td width=100%>{ LV_ZONE }</td></tr>| )
    ).
    IF LS_NOT-QMART = 'M8'.
      LS_MESSAGE-LINE  = |<tr><td width=25%>Target Function Location</td><td width=100%>{ LS_NOT-ZQMTXT }</td></tr>| .
      APPEND LS_MESSAGE TO LT_MESSAGE.
    ENDIF.
    LS_MESSAGE-LINE = |</table>|.
    APPEND LS_MESSAGE TO LT_MESSAGE.
    LS_MESSAGE-LINE = |</body></html>|.
    APPEND LS_MESSAGE TO LT_MESSAGE.

    T_MESSAGE[] = LT_MESSAGE[].

    TRY.
*     -------- create persistent send request ------------------------
        GO_SEND_REQUEST = CL_BCS=>CREATE_PERSISTENT( ).

*     -------- create and set document -------------------------------
*     create document from internal table with text

        GO_DOCUMENT = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
          I_TYPE    = 'HTM'
          I_TEXT    = LT_MESSAGE
*         i_length  = '12'
          I_SUBJECT = '' ).             "'


        CALL METHOD GO_SEND_REQUEST->SET_MESSAGE_SUBJECT
          EXPORTING
            IP_SUBJECT = LV_SUBJECT.

        CALL METHOD GO_SEND_REQUEST->SET_DOCUMENT( GO_DOCUMENT ).


*** Send mail using Email_ID
*      SENDER1 = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'zafar.k@xrbia.com' ).
        SENDER1 = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'sap_wfrt@ueg.com' ).
        CALL METHOD GO_SEND_REQUEST->SET_SENDER
          EXPORTING
            I_SENDER = SENDER1.

        SORT LT_ADDSMTP.
        DELETE LT_ADDSMTP WHERE E_MAIL IS INITIAL.
        DATA:LV_EMAIL TYPE ADR6-SMTP_ADDR.
        LV_EMAIL = VALUE #( LT_ADDSMTP[ 1 ]-E_MAIL OPTIONAL  ).

        LO_RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(
          LV_EMAIL ).

*     add recipient with its respective attributes to send request
        CALL METHOD GO_SEND_REQUEST->ADD_RECIPIENT
          EXPORTING
            I_RECIPIENT = LO_RECIPIENT
            I_EXPRESS   = 'X'.

* set outbox flag
*  try.
*      if outbox = 'X'.
        CALL METHOD GO_SEND_REQUEST->SEND_REQUEST->SET_LINK_TO_OUTBOX( 'X' ).
*      endif.
*    catch cx_bcs.
*  endtry.


*     ---------- send document ---------------------------------------
*    TRY.
        CALL METHOD GO_SEND_REQUEST->SET_SEND_IMMEDIATELY
          EXPORTING
            I_SEND_IMMEDIATELY = 'X'.
*     CATCH cx_send_req_bcs .
*    ENDTRY.

        CALL METHOD GO_SEND_REQUEST->SEND(
          EXPORTING
            I_WITH_ERROR_SCREEN = 'X'
          RECEIVING
            RESULT              = LV_SENT_TO_ALL ).

        IF LV_SENT_TO_ALL = 'X'.
          MESSAGE S000(8I) WITH 'Email send successfully'.
        ELSEIF LV_SENT_TO_ALL IS INITIAL.
          MESSAGE S000(8I) WITH 'Email not send'.
        ENDIF.

        COMMIT WORK.

      CATCH CX_BCS INTO LO_BCS_EXCEPTION.

    ENDTRY.










*********Populate the subject/generic message attributes --- Attributes of new document
********    GD_DOC_DATA-DOC_SIZE = 1.
********    GD_DOC_DATA-OBJ_LANGU = SY-LANGU.
********    GD_DOC_DATA-OBJ_NAME = 'SAPRPT'.
********    GD_DOC_DATA-OBJ_DESCR = LV_SUBJECT.
********    GD_DOC_DATA-SENSITIVTY = 'F'.
*********------- Describe the body of the message
********
*********Information about structure of data tables
********    CLEAR LS_PACK.
********    REFRESH LT_PACKING_LIST.
********    LS_PACK-TRANSF_BIN = SPACE.
********    LS_PACK-HEAD_START = 1.
********    LS_PACK-HEAD_NUM = 0.
********    LS_PACK-BODY_START = 1.
********    DESCRIBE TABLE LT_MESSAGE LINES LS_PACK-BODY_NUM.
********    LS_PACK-DOC_TYPE = 'HTML'.
********    APPEND LS_PACK TO LT_PACKING_LIST.
********
*********&------ Call the Function Module to send the message to External and SAP Inbox
********    CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
********      EXPORTING
********        DOCUMENT_DATA              = GD_DOC_DATA
********        PUT_IN_OUTBOX              = 'X'
********        COMMIT_WORK                = 'X'
********      TABLES
********        PACKING_LIST               = LT_PACKING_LIST
********        CONTENTS_TXT               = LT_MESSAGE
********        RECEIVERS                  = LT_RECEIVERS
********      EXCEPTIONS
********        TOO_MANY_RECEIVERS         = 1
********        DOCUMENT_NOT_SENT          = 2
********        DOCUMENT_TYPE_NOT_EXIST    = 3
********        OPERATION_NO_AUTHORIZATION = 4
********        PARAMETER_ERROR            = 5
********        X_ERROR                    = 6
********        ENQUEUE_ERROR              = 7
********        OTHERS                     = 8.
********    IF SY-SUBRC <> 0.
********      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
********              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
********    ENDIF.

    NOTI_NO  = WF_KEY(12).



  ENDMETHOD.


  method APPROVE.
"Order Approved
    APP_REJ = '1'.

  endmethod.


  method REJECT.
"Order Rejected
    APP_REJ = '0'.

  endmethod.


  METHOD FETCH_DATA.

    DATA: GO_SEND_REQUEST  TYPE REF TO  CL_BCS,
          GO_DOCUMENT      TYPE REF TO  CL_DOCUMENT_BCS,
          LV_SENT_TO_ALL   TYPE OS_BOOLEAN,
          LO_RECIPIENT     TYPE REF TO  IF_RECIPIENT_BCS,
          LO_BCS_EXCEPTION TYPE REF TO  CX_BCS,
          SENDER1          TYPE REF TO CL_CAM_ADDRESS_BCS.

    DATA: LT_RECEIVERS    TYPE STANDARD TABLE OF  SOMLRECI1,
          LS_REC          LIKE LINE OF LT_RECEIVERS,
          LT_PACKING_LIST TYPE STANDARD TABLE OF  SOPCKLSTI1,
          LS_PACK         LIKE LINE OF LT_PACKING_LIST,
          GD_DOC_DATA     TYPE SODOCCHGI1,
          LT_MESSAGE      TYPE STANDARD TABLE OF SOLISTI1,
          LS_MESSAGE      LIKE LINE OF LT_MESSAGE,
          LV_SUBJECT      TYPE STRING,
*          LV_SUBJECT(90)  TYPE C,
          LT_ADDSMTP      TYPE TABLE OF BAPIADSMTP,
          LS_ADDSMTP      TYPE BAPIADSMTP,
          LT_RETURN       TYPE TABLE OF BAPIRET2,
          LV_PRE_LEVEL    TYPE ZLEVEL,
          LV_USER         TYPE BAPIBNAME-BAPIBNAME.
data lv_arbpl TYPE CR_OBJID.
    "Fiori Link
    CASE SY-HOST.
      WHEN 'uekhidev'.
        "    FIORI_INNER = 'https://uekhidev.uead.uep.com.pk:44300/sap/bc/ui2/flp?sap-client=110&sap-language=EN#WorkflowTask-displayInbox?allItems=true'.
        FIORI_OUTER = 'https://uekhiwdp.uead.uep.com.pk:44301/sap/bc/ui5_ui5/ui2/ushell/shells/abap/Fiorilaunchpad.html#WorkflowTask-displayInbox?allItems=true&sap-client=110'.
      WHEN 'uekhiqas'.
        "FIORI_INNER = 'https://uekhiqas.uead.uep.com.pk:44302/sap/bc/ui2/flp?sap-client=200&sap-language=EN#WorkflowTask-displayInbox?allItems=true'.
        FIORI_OUTER = 'https://uekhiwdp.uead.uep.com.pk:44302/sap/bc/ui5_ui5/ui2/ushell/shells/abap/Fiorilaunchpad.html#WorkflowTask-displayInbox?allItems=true&sap-client=200'.
      WHEN 'uekhiprdappv'.
        "  FIORI_INNER = 'https://uekhiwdp.uead.uep.com.pk:44303/sap/bc/ui5_ui5/ui2/ushell/shells/abap/Fiorilaunchpad.html#WorkflowTask-displayInbox?allItems=true'.
        FIORI_OUTER = 'https://uekhiwdp.uead.uep.com.pk:44303/sap/bc/ui5_ui5/ui2/ushell/shells/abap/Fiorilaunchpad.html#WorkflowTask-displayInbox?allItems=true'.
    ENDCASE.
    FIORI_INNER1 = FIORI_INNER(70).
    FIORI_INNER2 = FIORI_INNER+70(70).
    FIORI_OUTER1 = FIORI_OUTER(70).
    FIORI_OUTER2 = FIORI_OUTER+70(70).

    SELECT SINGLE * FROM ZPM_NOT_CDS INTO @DATA(LS_NOT)
       WHERE QMNUM EQ @WF_KEY(12).

    IF ( ( LS_NOT-QMART EQ 'M1' OR LS_NOT-QMART EQ 'M2' )  AND  LS_NOT-INGRP <> 'PRD'  AND  LS_NOT-ARBPL(2) <> 'FA' ).
      ZWF_ID = 'WF-1.1'.
    ELSEIF ( ( LS_NOT-QMART EQ 'M1' OR LS_NOT-QMART EQ 'M2' )  AND  LS_NOT-INGRP EQ 'PRD'  AND  LS_NOT-ARBPL(2) <> 'FA' ).
      ZWF_ID = 'WF-1.2'.
    ELSEIF ( LS_NOT-QMART EQ 'M1'  AND  LS_NOT-INGRP <> 'PRD'  AND  LS_NOT-ARBPL(2) EQ 'FA' ).
      ZWF_ID = 'WF-1.3'.
    ELSEIF ( LS_NOT-QMART EQ 'M1'  AND  LS_NOT-INGRP EQ 'PRD'  AND  LS_NOT-ARBPL(2) EQ 'FA' ).
      ZWF_ID = 'WF-1.4'.
    ELSEIF ( LS_NOT-QMART EQ 'M8'  AND  LS_NOT-TPLNR(3) EQ LS_NOT-ZQMTXT(3) )."LS_NOT-INGRP EQ 'MNT'  AND  LS_NOT-ARBPL(3) EQ 'MNT' ).
      ZWF_ID = 'WF-3'. "Inter Concession
    ELSEIF ( LS_NOT-QMART EQ 'M8'  AND  LS_NOT-TPLNR(3) NE LS_NOT-ZQMTXT(3) ).
      ZWF_ID = 'WF-4'. "Intra Concession
    ELSEIF ( LS_NOT-QMART EQ 'T4'  AND  LS_NOT-INGRP EQ 'MNT'  AND  LS_NOT-ARBPL(3) EQ 'MNT' ).
      ZWF_ID = 'WF-5'.
    ELSEIF ( LS_NOT-QMART EQ 'M7' ).
      ZWF_ID = 'WF-7'.
    ENDIF.

    SELECT MAX( LEVELS )
      FROM ZPM_ROT
      INTO MAX_LEVEL
      WHERE WF_ID = ZWF_ID.

    SELECT SINGLE * FROM ZPM_WF_HST INTO @DATA(LS_HST)
      WHERE WF_ID  = @ZWF_ID
      AND QMNUM = @WF_KEY(12)
      AND LEVELS = '1'
      AND HST_ID = ( SELECT MAX( HST_ID ) FROM ZPM_WF_HST WHERE QMNUM = @WF_KEY(12) AND WF_ID = @ZWF_ID ).
*&--- Get user Detail ---&*
    LV_USER = INITIATOR+2.
    CALL FUNCTION 'BAPI_USER_GET_DETAIL'
      EXPORTING
        USERNAME      = LV_USER
        CACHE_RESULTS = 'X'
      TABLES
        RETURN        = LT_RETURN
        ADDSMTP       = LT_ADDSMTP.


*&--- Assign the Email id and User id to  Whom you want to Send --------&
    LS_REC-RECEIVER   = LV_USER.  "&----- Assign SAP User Id
    LS_REC-REC_TYPE   = 'B'.          "&-- Send to SAP Inbox
    LS_REC-COM_TYPE   = 'INT'.
    LS_REC-NOTIF_DEL  = 'X'.
    LS_REC-NOTIF_NDEL = 'X'.
    APPEND LS_REC TO LT_RECEIVERS .

    LOOP AT LT_ADDSMTP ASSIGNING FIELD-SYMBOL(<LINE>).
      LS_REC-RECEIVER   = <LINE>-E_MAIL.  "&----- Assign SAP User Id
      LS_REC-REC_TYPE   = 'U'.            "&-- Send to Internet email
      LS_REC-COM_TYPE   = 'INT'.
      LS_REC-NOTIF_DEL  = 'X'.
      LS_REC-NOTIF_NDEL = 'X'.
      APPEND LS_REC TO LT_RECEIVERS .
    ENDLOOP.

*--- Get Email Distribution list if Piriority is '1' ---*
    IF LS_NOT-PRIOK EQ '1' AND ( ZWF_ID EQ 'WF-1.1' OR ZWF_ID EQ 'WF-1.2' ).
*move LS_NOT-arbpl to LV_ARBPL.
*      SELECT SINGLE ARBPL INTO @DATA(LV_WC) FROM CRHD
*        WHERE OBJID = @LV_ARBPL AND OBJTY = 'A'.

      SELECT * FROM ZPM_DIST_LIST INTO TABLE @DATA(LT_LIST)
        WHERE WF_ID = @ZWF_ID
        AND IWERK = @LS_NOT-IWERK
        AND ARBPL = @LS_NOT-ARBPL.
      IF LT_LIST IS INITIAL.
*        SELECT * FROM ZPM_DIST_LIST INTO TABLE @LT_LIST
*          WHERE WF_ID = @ZWF_ID.
*        and IWERK = @LS_NOT-iwerk.
      ENDIF.

      DELETE ADJACENT DUPLICATES FROM LT_LIST COMPARING EMAIL.

      LOOP AT LT_LIST INTO DATA(LS_LIST).
        LS_REC-RECEIVER   = LS_LIST-EMAIL.  "&----- Assign SAP User Id
        LS_REC-REC_TYPE   = 'U'.            "&-- Send to Internet email
        LS_REC-COM_TYPE   = 'INT'.
        LS_REC-NOTIF_DEL  = 'X'.
        LS_REC-NOTIF_NDEL = 'X'.
        APPEND LS_REC TO LT_RECEIVERS .
      ENDLOOP.
    ENDIF.

    "Zone
    SELECT SINGLE PLTXT FROM IFLO INTO @DATA(LV_ZONE)
      WHERE TPLNR = @LS_NOT-TPLNR(10)
      AND SPRAS = @SY-LANGU.

    "Next Approvars
    DATA: NEXT_LEVEL       TYPE ZLEVEL,
          T_AGENTS         TYPE ZTT_AGENT,
          NEXT_APPROVED_BY TYPE CHAR255.
    NEXT_LEVEL = 2.
    CALL FUNCTION 'ZFM_PM_NOT_NEXT_USER'
      EXPORTING
        WF_KEY    = WF_KEY
        IM_WF_ID  = ZWF_ID
        IM_LEVEL  = NEXT_LEVEL
        INITIATOR = INITIATOR
      IMPORTING
        ET_AGENTS = T_AGENTS.
*    DATA(NEXT_APPROVED_BY) = REDUCE #( INIT TXT = `` FOR LS IN T_AGENTS NEXT TXT = TXT && | | && LS-ZAGENT ).
    LOOP AT T_AGENTS INTO DATA(LS).
      IF NEXT_APPROVED_BY IS INITIAL.
        NEXT_APPROVED_BY = |{ LS-ZAGENT+2 }|.
      ELSE.
        NEXT_APPROVED_BY = |{ NEXT_APPROVED_BY } - { LS-ZAGENT+2 }|.
      ENDIF.
    ENDLOOP.

    DATA(LV_DATE) = |{ LS_NOT-ERDAT+6(2) }.{ LS_NOT-ERDAT+4(2) }.{ LS_NOT-ERDAT+0(4) }</td></tr>|.
    DATA(LV_NUM1) = |{ LS_NOT-QMNUM ALPHA = OUT }|.
    DATA(LV_NUM2) = |{ LS_NOT-EQUNR ALPHA = OUT }|.
*-------------& EMAIL MESSAGE  &-----------------*
    LV_SUBJECT = |Notification { WF_KEY } workflow started|.
    LS_MESSAGE-LINE = '<html><body style="background-color: #FFFFFF;" font-family="arial, verdana, courier;" font-size="2">'.
    APPEND LS_MESSAGE TO LT_MESSAGE.
    LS_MESSAGE-LINE = '<table style="margin: 10px;" border="1px" border-color="#000000" width="100%">'.
    APPEND LS_MESSAGE TO LT_MESSAGE.

    LT_MESSAGE = VALUE #( BASE LT_MESSAGE
    ( LINE = |<tr><td width=25%>Notification No.</td><td width=100%>{ LV_NUM1 }</td></tr>| )
    ( LINE = |<tr><td width=25%>Notification Desc</td><td width=100%>{ LS_NOT-QMTXT }</td></tr>| )
    ( LINE = |<tr><td width=25%>Notification Creation Date</td><td width=100%>{ LV_DATE }</td></tr>| )
    ( LINE = |<tr><td width=25%>Priority</td><td width=100%>{ LS_NOT-PRIOKX }</td></tr>| )
    ( LINE = |<tr><td width=25%>ABC Indicator</td><td width=100%>{ LS_NOT-ABCTX }</td></tr>| )
    ( LINE = |<tr><td width=25%>User Status</td><td width=100%>{ LS_HST-C_STAT }</td></tr>| )
    ( LINE = |<tr><td width=25%>Status Date</td><td width=100%>{ LV_DATE }</td></tr>| )
    ( LINE = |<tr><td width=25%>Last Approved By</td><td width=100%>   </td></tr>| )
    ( LINE = |<tr><td width=25%>Last Approved By Date</td><td width=100%>   </td></tr>| )
    ( LINE = |<tr><td width=25%>Last Approved By Time</td><td width=100%>   </td></tr>| )
    ( LINE = |<tr><td width=25%>Next Approval By</td><td width=100%>{ NEXT_APPROVED_BY }</td></tr>| )
    ( LINE = |<tr><td width=25%>Equip no</td><td width=100%>{ LV_NUM2 }</td></tr>| )
    ( LINE = |<tr><td width=25%>Equip no Desc</td><td width=100%>{ LS_NOT-EQKTX }</td></tr>| )
    ( LINE = |<tr><td width=25%>Tech ID</td><td width=100%>{ LS_NOT-TIDNR }</td></tr>| )
    ( LINE = |<tr><td width=25%>Created By</td><td width=100%>{ INITIATOR+2 }</td></tr>| )
    ( LINE = |<tr><td width=25%>Functional Location Desc</td><td width=100%>{ LS_NOT-PLTXT }</td></tr>| )
    ( LINE = |<tr><td width=25%>Facility/Remote/Field</td><td width=100%>{ LS_NOT-KTEXT }</td></tr>| )
    ( LINE = |<tr><td width=25%>Zone</td><td width=100%>{ LV_ZONE }</td></tr>| )
    ).
    IF LS_NOT-QMART = 'M8'.
      LS_MESSAGE-LINE  = |<tr><td width=25%>Target Function Location</td><td width=100%>{ LS_NOT-ZQMTXT }</td></tr>| .
      APPEND LS_MESSAGE TO LT_MESSAGE.
    ENDIF.
    LS_MESSAGE-LINE = |</table>|.
    APPEND LS_MESSAGE TO LT_MESSAGE.

    LS_MESSAGE-LINE = '<table style="margin: 10px;" width="100%">'.
    APPEND LS_MESSAGE TO LT_MESSAGE.
*    LS_MESSAGE-LINE = |<tr><td width=100%><a href={ FIORI_INNER }>Fiori within UEP Primise</a></td></tr>|.
*    APPEND LS_MESSAGE TO LT_MESSAGE.
    LS_MESSAGE-LINE = |<tr><td width=100%><a href={ FIORI_OUTER }>SAP S/4 HANA</a></td></tr>|.
    APPEND LS_MESSAGE TO LT_MESSAGE.
    LS_MESSAGE-LINE = |</table>|.
    APPEND LS_MESSAGE TO LT_MESSAGE.

    LS_MESSAGE-LINE = |</body></html>|.
    APPEND LS_MESSAGE TO LT_MESSAGE.
*Populate the subject/generic message attributes --- Attributes of new document

    TRY.
*     -------- create persistent send request ------------------------
        GO_SEND_REQUEST = CL_BCS=>CREATE_PERSISTENT( ).

*     -------- create and set document -------------------------------
*     create document from internal table with text

        GO_DOCUMENT = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
          I_TYPE    = 'HTM'
          I_TEXT    = LT_MESSAGE
*         i_length  = '12'
          I_SUBJECT = '' ).             "'


        CALL METHOD GO_SEND_REQUEST->SET_MESSAGE_SUBJECT
          EXPORTING
            IP_SUBJECT = LV_SUBJECT.

        CALL METHOD GO_SEND_REQUEST->SET_DOCUMENT( GO_DOCUMENT ).


*** Send mail using Email_ID
*      SENDER1 = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'zafar.k@xrbia.com' ).
*        SENDER1 = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'sap_wfrt@uep.com.pk' ).
        SENDER1 = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'sap_wfrt@ueg.com' ).
        CALL METHOD GO_SEND_REQUEST->SET_SENDER
          EXPORTING
            I_SENDER = SENDER1.

        SORT LT_ADDSMTP.
        DELETE LT_ADDSMTP WHERE E_MAIL IS INITIAL.
        DATA:LV_EMAIL TYPE ADR6-SMTP_ADDR.
        LV_EMAIL = VALUE #( LT_ADDSMTP[ 1 ]-E_MAIL OPTIONAL  ).

        LO_RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(
          LV_EMAIL ).

*     add recipient with its respective attributes to send request
        CALL METHOD GO_SEND_REQUEST->ADD_RECIPIENT
          EXPORTING
            I_RECIPIENT = LO_RECIPIENT
            I_EXPRESS   = 'X'.

        LOOP AT LT_RECEIVERS ASSIGNING FIELD-SYMBOL(<FS_REC>).
          CLEAR: LO_RECIPIENT, LV_EMAIL.
          TRY.
              LV_EMAIL = <FS_REC>-RECEIVER.
              LO_RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(
                LV_EMAIL ).

              CALL METHOD GO_SEND_REQUEST->ADD_RECIPIENT
                EXPORTING
                  I_RECIPIENT = LO_RECIPIENT
                  I_EXPRESS   = 'X'.
            CATCH CX_BCS INTO LO_BCS_EXCEPTION.

          ENDTRY.
        ENDLOOP.

* set outbox flag
        TRY.
*      if outbox = 'X'.
            CALL METHOD GO_SEND_REQUEST->SEND_REQUEST->SET_LINK_TO_OUTBOX( 'X' ).
*      endif.
          CATCH CX_BCS.
        ENDTRY.


*     ---------- send document ---------------------------------------
        TRY.
            CALL METHOD GO_SEND_REQUEST->SET_SEND_IMMEDIATELY
              EXPORTING
                I_SEND_IMMEDIATELY = 'X'.
          CATCH CX_SEND_REQ_BCS .
        ENDTRY.

        CALL METHOD GO_SEND_REQUEST->SEND(
          EXPORTING
            I_WITH_ERROR_SCREEN = 'X'
          RECEIVING
            RESULT              = LV_SENT_TO_ALL ).

        IF LV_SENT_TO_ALL = 'X'.
          MESSAGE S000(8I) WITH 'Email send successfully'.
        ELSEIF LV_SENT_TO_ALL IS INITIAL.
          MESSAGE S000(8I) WITH 'Email not send'.
        ENDIF.

        COMMIT WORK.

      CATCH CX_BCS INTO LO_BCS_EXCEPTION.

    ENDTRY.



**********    GD_DOC_DATA-DOC_SIZE = 1.
**********    GD_DOC_DATA-OBJ_LANGU = SY-LANGU.
**********    GD_DOC_DATA-OBJ_NAME = 'SAPRPT'.
**********    GD_DOC_DATA-OBJ_DESCR = LV_SUBJECT.
**********    GD_DOC_DATA-SENSITIVTY = 'F'.
***********------- Describe the body of the message
**********
***********Information about structure of data tables
**********    CLEAR LS_PACK.
**********    REFRESH LT_PACKING_LIST.
**********    LS_PACK-TRANSF_BIN = SPACE.
**********    LS_PACK-HEAD_START = 1.
**********    LS_PACK-HEAD_NUM = 0.
**********    LS_PACK-BODY_START = 1.
**********    DESCRIBE TABLE LT_MESSAGE LINES LS_PACK-BODY_NUM.
**********    LS_PACK-DOC_TYPE = 'HTML'.
**********    APPEND LS_PACK TO LT_PACKING_LIST.
**********
***********&------ Call the Function Module to send the message to External and SAP Inbox
**********    CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
**********      EXPORTING
**********        DOCUMENT_DATA              = GD_DOC_DATA
**********        PUT_IN_OUTBOX              = 'X'
**********        COMMIT_WORK                = 'X'
**********      TABLES
**********        PACKING_LIST               = LT_PACKING_LIST
**********        CONTENTS_TXT               = LT_MESSAGE
**********        RECEIVERS                  = LT_RECEIVERS
**********      EXCEPTIONS
**********        TOO_MANY_RECEIVERS         = 1
**********        DOCUMENT_NOT_SENT          = 2
**********        DOCUMENT_TYPE_NOT_EXIST    = 3
**********        OPERATION_NO_AUTHORIZATION = 4
**********        PARAMETER_ERROR            = 5
**********        X_ERROR                    = 6
**********        ENQUEUE_ERROR              = 7
**********        OTHERS                     = 8.
**********    IF SY-SUBRC <> 0.
**********      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**********              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
**********    ENDIF.

  ENDMETHOD.


  METHOD REVERT.
"Order Reverted
    APP_REJ = '2'.

  ENDMETHOD.


  METHOD SEND_UPDATES.

    DATA: GO_SEND_REQUEST  TYPE REF TO  CL_BCS,
          GO_DOCUMENT      TYPE REF TO  CL_DOCUMENT_BCS,
          LV_SENT_TO_ALL   TYPE OS_BOOLEAN,
          LO_RECIPIENT     TYPE REF TO  IF_RECIPIENT_BCS,
          LO_BCS_EXCEPTION TYPE REF TO  CX_BCS,
          SENDER1          TYPE REF TO CL_CAM_ADDRESS_BCS..


    DATA:
      LT_RECEIVERS    TYPE STANDARD TABLE OF  SOMLRECI1,
      LS_REC          LIKE LINE OF LT_RECEIVERS,
      LT_PACKING_LIST TYPE STANDARD TABLE OF  SOPCKLSTI1,
      LS_PACK         LIKE LINE OF LT_PACKING_LIST,
      GD_DOC_DATA     TYPE SODOCCHGI1,
      LT_MESSAGE      TYPE STANDARD TABLE OF SOLISTI1,
      LS_MESSAGE      LIKE LINE OF LT_MESSAGE,
*      LV_SUBJECT(90)  TYPE C,
      LV_SUBJECT      TYPE STRING,
      LT_ADDSMTP      TYPE TABLE OF BAPIADSMTP,
      LS_ADDSMTP      TYPE BAPIADSMTP,
      LT_RETURN       TYPE TABLE OF BAPIRET2,
      LS_WF_NEX       TYPE ZPM_WF_NEX,
      LV_USER         TYPE BAPIBNAME-BAPIBNAME
      .

    "History Previous
    SELECT SINGLE * FROM ZPM_WF_HST INTO @DATA(LS_HST)
      WHERE QMNUM = @WF_KEY(12)
      AND WF_ID EQ @IM_WF_ID
      AND LEVELS = @IM_LEVEL
      AND HST_ID = ( SELECT MAX( HST_ID ) FROM ZPM_WF_HST WHERE QMNUM = @WF_KEY(12) AND LEVELS = @IM_LEVEL ).

    "Notifiaction Data
    SELECT SINGLE * FROM ZPM_NOT_CDS INTO @DATA(LS_NOT)
      WHERE QMNUM = @WF_KEY(12).

    LV_USER = IM_INITIATOR+2.
*&--- Get user Detail ---&*
    CALL FUNCTION 'BAPI_USER_GET_DETAIL'
      EXPORTING
        USERNAME      = LV_USER
        CACHE_RESULTS = 'X'
*       EXTUID_GET    =
      TABLES
        RETURN        = LT_RETURN
        ADDSMTP       = LT_ADDSMTP.

**************&--- Assign the Email id and User id to  Whom you want to Send --------&
*************    LS_REC-RECEIVER   = IM_INITIATOR+2.  "&----- Assign SAP User Id
*************    LS_REC-REC_TYPE   = 'B'.          "&-- Send to SAP Inbox
*************    LS_REC-COM_TYPE   = 'INT'.
*************    LS_REC-NOTIF_DEL  = 'X'.
*************    LS_REC-NOTIF_NDEL = 'X'.
*************    APPEND LS_REC TO LT_RECEIVERS .
    LOOP AT LT_ADDSMTP ASSIGNING FIELD-SYMBOL(<LINE>).
      LS_REC-RECEIVER   = <LINE>-E_MAIL.  "&----- Assign SAP User Id
      LS_REC-REC_TYPE   = 'U'.            "&-- Send to SAP Inbox
      LS_REC-COM_TYPE   = 'INT'.
      LS_REC-NOTIF_DEL  = 'X'.
      LS_REC-NOTIF_NDEL = 'X'.
      APPEND LS_REC TO LT_RECEIVERS .
    ENDLOOP.

    DATA(LV_APPROVAL_TEXT) = SWITCH #( LS_HST-APP_REJ WHEN '1' THEN |Approved|
                                                      WHEN '2' THEN |Reverted|
                                                      WHEN '0' THEN |Rejected| ).

    "Zone
    SELECT SINGLE PLTXT FROM IFLO INTO @DATA(LV_ZONE)
      WHERE TPLNR = @LS_NOT-TPLNR(10)
      AND SPRAS = @SY-LANGU.

    "Fiori Link
    CASE SY-HOST.
      WHEN 'uekhidev'.
        DATA(FIORI_INNER) = |"https://uekhiwdp.uead.uep.com.pk:44301/sap/bc/ui5_ui5/ui2/ushell/shells/abap/Fiorilaunchpad.html#WorkflowTask-displayInbox?allItems=true&sap-client=110"|.
        DATA(FIORI_OUTER) = |"https://uekhiwdp.uead.uep.com.pk:44301/sap/bc/ui5_ui5/ui2/ushell/shells/abap/Fiorilaunchpad.html#WorkflowTask-displayInbox?allItems=true&sap-client=110"|.
      WHEN 'uekhiqas'.
        FIORI_INNER = |"https://uekhiwdp.uead.uep.com.pk:44302/sap/bc/ui5_ui5/ui2/ushell/shells/abap/Fiorilaunchpad.html#WorkflowTask-displayInbox?allItems=true&sap-client=200"|.
        FIORI_OUTER = |"https://uekhiwdp.uead.uep.com.pk:44302/sap/bc/ui5_ui5/ui2/ushell/shells/abap/Fiorilaunchpad.html#WorkflowTask-displayInbox?allItems=true&sap-client=200"|.
      WHEN 'uekhiprdappv'.
        FIORI_INNER = |"https://uekhiwdp.uead.uep.com.pk:44303/sap/bc/ui5_ui5/ui2/ushell/shells/abap/Fiorilaunchpad.html#WorkflowTask-displayInbox?allItems=true"|.
        FIORI_OUTER = |"https://uekhiwdp.uead.uep.com.pk:44303/sap/bc/ui5_ui5/ui2/ushell/shells/abap/Fiorilaunchpad.html#WorkflowTask-displayInbox?allItems=true"|.
    ENDCASE.

*-------------& EMAIL MESSAGE  &-----------------*
    LV_SUBJECT = |Notification { WF_KEY } has been { LV_APPROVAL_TEXT }|.

    DATA(LV_DATE) = |{ LS_NOT-ERDAT+6(2) }.{ LS_NOT-ERDAT+4(2) }.{ LS_NOT-ERDAT+0(4) }</td></tr>|.
    DATA(LV_DATE2) = |{ LS_HST-OBJ_DATE+6(2) }.{ LS_HST-OBJ_DATE+4(2) }.{ LS_HST-OBJ_DATE+0(4) }</td></tr>|.
    DATA(LV_TIME) = |{ LS_HST-UZEIT+0(2) }:{ LS_HST-UZEIT+2(2) }:{ LS_HST-UZEIT+4(2) }</td></tr>|.
    DATA(LV_NUM1) = |{ LS_NOT-QMNUM ALPHA = OUT }|.
    DATA(LV_NUM2) = |{ LS_NOT-EQUNR ALPHA = OUT }|.

    LS_MESSAGE-LINE = '<html><body style="background-color: #FFFFFF;" font-family="arial, verdana, courier;" font-size="2">'.
    APPEND LS_MESSAGE TO LT_MESSAGE.
    LS_MESSAGE-LINE = '<table style="margin: 10px;" border="1px" border-color="#000000" width="100%">'.
    APPEND LS_MESSAGE TO LT_MESSAGE.

    LT_MESSAGE = VALUE #( BASE LT_MESSAGE
    ( LINE = |<tr><td width=25%>Notification No.</td><td width=75%>{ LV_NUM1 }</td></tr>| )
    ( LINE = |<tr><td width=25%>Notification Desc</td><td width=75%>{ LS_NOT-QMTXT }</td></tr>| )
    ( LINE = |<tr><td width=25%>Notification Creation Date</td><td width=75%>{ LV_DATE }</td></tr>| )
    ( LINE = |<tr><td width=25%>Priority</td><td width=75%>{ LS_NOT-PRIOKX }</td></tr>| )
    ( LINE = |<tr><td width=25%>ABC Indicator</td><td width=75%>{ LS_NOT-ABCTX }</td></tr>| )
    ( LINE = |<tr><td width=25%>User Status</td><td width=75%>{ LS_HST-C_STAT }</td></tr>| )
    ( LINE = |<tr><td width=25%>Status Date</td><td width=75%>{ LV_DATE2 }</td></tr>| )
    ( LINE = |<tr><td width=25%>Last Approved By</td><td width=75%>{ LS_HST-ERNAM }</td></tr>| )
    ( LINE = |<tr><td width=25%>Last Approved By Date</td><td width=75%>{ LV_DATE2 }</td></tr>| )
    ( LINE = |<tr><td width=25%>Last Approved By Time</td><td width=75%>{ LV_TIME }</td></tr>| )
*    ( LINE = |<tr><td width=25%>Next Approval By</td><td width=75%>   </td></tr>| )
    ( LINE = |<tr><td width=25%>Equip no</td><td width=75%>{ LV_NUM2 }</td></tr>| )
    ( LINE = |<tr><td width=25%>Equip no Desc</td><td width=75%>{ LS_NOT-EQKTX }</td></tr>| )
    ( LINE = |<tr><td width=25%>Tech ID</td><td width=75%>{ LS_NOT-TIDNR }</td></tr>| )
    ( LINE = |<tr><td width=25%>Created By</td><td width=75%>{ IM_INITIATOR+2 }</td></tr>| )
    ( LINE = |<tr><td width=25%>Functional Location Desc</td><td width=75%>{ LS_NOT-PLTXT }</td></tr>| )
    ( LINE = |<tr><td width=25%>Facility/Remote/Field</td><td width=75%>{ LS_NOT-KTEXT }</td></tr>| )
    ( LINE = |<tr><td width=25%>Zone</td><td width=75%>{ LV_ZONE }</td></tr>| )
    ).
    LS_MESSAGE-LINE = |</table>|.
    APPEND LS_MESSAGE TO LT_MESSAGE.

    LS_MESSAGE-LINE = '<table style="margin: 10px;" width="100%">'.
    APPEND LS_MESSAGE TO LT_MESSAGE.
****    LS_MESSAGE-LINE = |<tr><td width=100%><a href={ FIORI_INNER }>Fiori within UEP Primise</a></td></tr>|.
****    APPEND LS_MESSAGE TO LT_MESSAGE.
    LS_MESSAGE-LINE = |<tr><td width=100%><a href={ FIORI_OUTER }>SAP S/4 HANA</a></td></tr>|.
    APPEND LS_MESSAGE TO LT_MESSAGE.
    LS_MESSAGE-LINE = |</table>|.
    APPEND LS_MESSAGE TO LT_MESSAGE.

    LS_MESSAGE-LINE = |</body></html>|.
    APPEND LS_MESSAGE TO LT_MESSAGE.

    TRY.
*     -------- create persistent send request ------------------------
        GO_SEND_REQUEST = CL_BCS=>CREATE_PERSISTENT( ).

*     -------- create and set document -------------------------------
*     create document from internal table with text

        GO_DOCUMENT = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
          I_TYPE    = 'HTM'
          I_TEXT    = LT_MESSAGE
*         i_length  = '12'
          I_SUBJECT = '' ).             "'


        CALL METHOD GO_SEND_REQUEST->SET_MESSAGE_SUBJECT
          EXPORTING
            IP_SUBJECT = LV_SUBJECT.

*      IF C_NOTICE IS NOT INITIAL.
*        LV_ATT_NAME = 'Notice of Termination'.
*      ENDIF.

*      IF NOT LI_CONTENT_HEX IS INITIAL.
*        GO_DOCUMENT->ADD_ATTACHMENT(
*             I_ATTACHMENT_TYPE      = 'PDF'
*             I_ATTACHMENT_SUBJECT   = LV_ATT_NAME    "gv_title   "attachment subject
*             I_ATTACHMENT_SIZE      = LV_LEN
*             I_ATT_CONTENT_HEX      = LI_CONTENT_HEX ).
*      ENDIF.

        CALL METHOD GO_SEND_REQUEST->SET_DOCUMENT( GO_DOCUMENT ).


*** Send mail using Email_ID
*      SENDER1 = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'zafar.k@xrbia.com' ).
*        SENDER1 = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'sap_wfrt@uep.com.pk' ).
        SENDER1 = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'sap_wfrt@ueg.com' ).
        CALL METHOD GO_SEND_REQUEST->SET_SENDER
          EXPORTING
            I_SENDER = SENDER1.

        SORT LT_ADDSMTP.
        DELETE LT_ADDSMTP WHERE E_MAIL IS INITIAL.
        DATA:LV_EMAIL TYPE ADR6-SMTP_ADDR.
        LV_EMAIL = VALUE #( LT_ADDSMTP[ 1 ]-E_MAIL OPTIONAL  ).

        LO_RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(
          LV_EMAIL ).

*     add recipient with its respective attributes to send request
        CALL METHOD GO_SEND_REQUEST->ADD_RECIPIENT
          EXPORTING
            I_RECIPIENT = LO_RECIPIENT
            I_EXPRESS   = 'X'.

* set outbox flag
*  try.
*      if outbox = 'X'.
        CALL METHOD GO_SEND_REQUEST->SEND_REQUEST->SET_LINK_TO_OUTBOX( 'X' ).
*      endif.
*    catch cx_bcs.
*  endtry.


*     ---------- send document ---------------------------------------
*    TRY.
        CALL METHOD GO_SEND_REQUEST->SET_SEND_IMMEDIATELY
          EXPORTING
            I_SEND_IMMEDIATELY = 'X'.
*     CATCH cx_send_req_bcs .
*    ENDTRY.

        CALL METHOD GO_SEND_REQUEST->SEND(
          EXPORTING
            I_WITH_ERROR_SCREEN = 'X'
          RECEIVING
            RESULT              = LV_SENT_TO_ALL ).

        IF LV_SENT_TO_ALL = 'X'.
          MESSAGE S000(8I) WITH 'Email send successfully'.
        ELSEIF LV_SENT_TO_ALL IS INITIAL.
          MESSAGE S000(8I) WITH 'Email not send'.
        ENDIF.

        COMMIT WORK.

      CATCH CX_BCS INTO LO_BCS_EXCEPTION.

    ENDTRY.












****************************************************Populate the subject/generic message attributes --- Attributes of new document
***************************************************    GD_DOC_DATA-DOC_SIZE = 1.
***************************************************    GD_DOC_DATA-OBJ_LANGU = SY-LANGU.
***************************************************    GD_DOC_DATA-OBJ_NAME = 'SAPRPT'.
***************************************************    GD_DOC_DATA-OBJ_DESCR = LV_SUBJECT.
***************************************************    GD_DOC_DATA-SENSITIVTY = 'F'.
****************************************************------- Describe the body of the message
***************************************************
****************************************************Information about structure of data tables
***************************************************    CLEAR LS_PACK.
***************************************************    REFRESH LT_PACKING_LIST.
***************************************************    LS_PACK-TRANSF_BIN = SPACE.
***************************************************    LS_PACK-HEAD_START = 1.
***************************************************    LS_PACK-HEAD_NUM = 0.
***************************************************    LS_PACK-BODY_START = 1.
***************************************************    DESCRIBE TABLE LT_MESSAGE LINES LS_PACK-BODY_NUM.
***************************************************    LS_PACK-DOC_TYPE = 'HTML'.
***************************************************    APPEND LS_PACK TO LT_PACKING_LIST.
***************************************************
****************************************************&------ Call the Function Module to send the message to External and SAP Inbox
***************************************************    CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
***************************************************      EXPORTING
***************************************************        DOCUMENT_DATA              = GD_DOC_DATA
***************************************************        PUT_IN_OUTBOX              = 'X'
***************************************************        COMMIT_WORK                = 'X'
***************************************************      TABLES
***************************************************        PACKING_LIST               = LT_PACKING_LIST
***************************************************        CONTENTS_TXT               = LT_MESSAGE
***************************************************        RECEIVERS                  = LT_RECEIVERS
***************************************************      EXCEPTIONS
***************************************************        TOO_MANY_RECEIVERS         = 1
***************************************************        DOCUMENT_NOT_SENT          = 2
***************************************************        DOCUMENT_TYPE_NOT_EXIST    = 3
***************************************************        OPERATION_NO_AUTHORIZATION = 4
***************************************************        PARAMETER_ERROR            = 5
***************************************************        X_ERROR                    = 6
***************************************************        ENQUEUE_ERROR              = 7
***************************************************        OTHERS                     = 8.
***************************************************    IF SY-SUBRC <> 0.
***************************************************      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
***************************************************              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
***************************************************    ENDIF.

  ENDMETHOD.


  METHOD DISP_NOTIF.

    SET PARAMETER ID 'IQM' FIELD WF_KEY(12).
    CALL TRANSACTION 'IW23'  AND SKIP FIRST SCREEN.

  ENDMETHOD.


  METHOD CREATE_ADHOC_OBJECT.

    DATA: LS_OBJS TYPE SIBFLPORB,
          LT_OBJS TYPE TABLE OF SIBFLPORB.

    LS_OBJS-CATID = 'BO'.
    LS_OBJS-TYPEID = 'BUS2038'.
    LS_OBJS-INSTID = WF_KEY(12).
    APPEND LS_OBJS TO LT_OBJS.

    ET_BO_OBJS[] = LT_OBJS[].

  ENDMETHOD.
ENDCLASS.
