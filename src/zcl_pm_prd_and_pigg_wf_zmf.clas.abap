class ZCL_PM_PRD_AND_PIGG_WF_ZMF definition
  public
  final
  create public .

public section.

  interfaces BI_OBJECT .
  interfaces BI_PERSISTENT .
  interfaces IF_WORKFLOW .

  class-data GS_WF_KEY type AUFK-AUFNR .
  class-data GS_OBJ type SIBFLPOR .
  class-data GT_BO_OBJS type SIBFLPORBT .

  events TRIGGER
    exporting
      value(WF_KEY) type AUFK-AUFNR .

  methods CONSTRUCTOR
    importing
      !WF_KEY type AUFK-AUFNR .
  methods TRIGGER_WF
    importing
      value(WF_KEY) type AUFK-AUFNR .
  methods FETCH_DATA
    importing
      value(WF_KEY) type AUFK-AUFNR
      value(INITIATOR) type WFSYST-INITIATOR
    exporting
      value(ET_AGENTS) type ZPM_WORKFLOW_AGENT_TT
      value(T_MESSAGE) type ZT_SOLISTI1
      value(FIORI_INNER) type CHAR255
      value(FIORI_OUTER) type CHAR255
      value(FIORI_INNER1) type CHAR70
      value(FIORI_INNER2) type CHAR70
      value(FIORI_OUTER1) type CHAR70
      value(FIORI_OUTER2) type CHAR70 .
  methods APPROVE
    exporting
      !APP_REJ type ZAPP_REJ .
  methods REJECT
    exporting
      !APP_REJ type ZAPP_REJ .
  methods UPDATES
    importing
      value(WF_KEY) type AUFK-AUFNR
      value(APP_REJ) type ZAPP_REJ
      value(INITIATOR) type WFSYST-INITIATOR
      value(APPROVER) type WFSYST-AGENT
      value(ZWORKITEMID) type SWWWIHEAD-WI_ID .
  methods DISP_ORDER
    importing
      value(WF_KEY) type AUFK-AUFNR .
  methods CREATE_ADHOC_OBJECT
    importing
      value(WF_KEY) type AUFK-AUFNR
    exporting
      !ET_BO_OBJS type SIBFLPORBT .
protected section.
private section.
ENDCLASS.



CLASS ZCL_PM_PRD_AND_PIGG_WF_ZMF IMPLEMENTATION.


  method APPROVE.

    app_rej = '1'.

  endmethod.


  METHOD BI_OBJECT~DEFAULT_ATTRIBUTE_VALUE.
    GET REFERENCE OF ME->GS_WF_KEY INTO RESULT.
  ENDMETHOD.


  method BI_OBJECT~EXECUTE_DEFAULT_METHOD.
  endmethod.


  METHOD BI_OBJECT~RELEASE.
  ENDMETHOD.


  METHOD BI_PERSISTENT~FIND_BY_LPOR.
    DATA:
          INSTANCE TYPE REF TO ZCL_PM_PRD_AND_PIGG_WF_ZMF.

    CREATE OBJECT INSTANCE
      EXPORTING
        WF_KEY = LPOR(12).

    RESULT ?= INSTANCE.
  ENDMETHOD.


  METHOD BI_PERSISTENT~LPOR.

    RESULT = ME->GS_OBJ.

  ENDMETHOD.


  method BI_PERSISTENT~REFRESH.
  endmethod.


  METHOD CONSTRUCTOR.
    GS_OBJ-CATID = 'CL'.
    GS_OBJ-TYPEID = 'ZCL_PM_PRD_AND_PIGG_WF_ZMF'.
    GS_OBJ-INSTID = WF_KEY.
  ENDMETHOD.


  METHOD FETCH_DATA.

    DATA: GO_SEND_REQUEST  TYPE REF TO  CL_BCS,
          GO_DOCUMENT      TYPE REF TO  CL_DOCUMENT_BCS,
          LV_SENT_TO_ALL   TYPE OS_BOOLEAN,
          LO_RECIPIENT     TYPE REF TO  IF_RECIPIENT_BCS,
          LO_BCS_EXCEPTION TYPE REF TO  CX_BCS,
          SENDER1          TYPE REF TO CL_CAM_ADDRESS_BCS..

    TYPES: BEGIN OF TY_AGENT,
             ERNAM TYPE SWP_AGENT,
           END OF TY_AGENT.

    DATA: LT_AGENTS       TYPE STANDARD TABLE OF TY_AGENT,
          LS_AGENTS       TYPE TY_AGENT,
          LT_RECEIVERS    TYPE STANDARD TABLE OF  SOMLRECI1,
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
          LS_WF_NEX       TYPE ZPM_WF_NEX,
          LV_USER         TYPE BAPIBNAME-BAPIBNAME.
    .
    "Fiori Link
    CASE SY-HOST.
      WHEN 'uekhidev'.
     "  FIORI_INNER = 'https://uekhidev.uead.uep.com.pk:44300/sap/bc/ui2/flp?sap-client=110&sap-language=EN#WorkflowTask-displayInbox?allItems=true'.
        FIORI_OUTER = 'https://uekhiwdp.uead.uep.com.pk:44301/sap/bc/ui5_ui5/ui2/ushell/shells/abap/Fiorilaunchpad.html#WorkflowTask-displayInbox?allItems=true&sap-client=110'.
      WHEN 'uekhiqas'.
     "   FIORI_INNER = 'https://uekhiqas.uead.uep.com.pk:44302/sap/bc/ui2/flp?sap-client=200&sap-language=EN#WorkflowTask-displayInbox?allItems=true'.
        FIORI_OUTER = 'https://uekhiwdp.uead.uep.com.pk:44302/sap/bc/ui5_ui5/ui2/ushell/shells/abap/Fiorilaunchpad.html#WorkflowTask-displayInbox?allItems=true&sap-client=200'.
      WHEN 'uekhiprdappv'.
   "     FIORI_INNER = 'https://uekhiwdp.uead.uep.com.pk:44303/sap/bc/ui5_ui5/ui2/ushell/shells/abap/Fiorilaunchpad.html#WorkflowTask-displayInbox?allItems=true'.
        FIORI_OUTER = 'https://uekhiwdp.uead.uep.com.pk:44303/sap/bc/ui5_ui5/ui2/ushell/shells/abap/Fiorilaunchpad.html#WorkflowTask-displayInbox?allItems=true'.
    ENDCASE.

*    FIORI_INNER1 = FIORI_INNER(70).
*    FIORI_INNER2 = FIORI_INNER+70(70).
    FIORI_OUTER1 = FIORI_OUTER(70).
    FIORI_OUTER2 = FIORI_OUTER+70(70).

    SELECT SINGLE *
      FROM ZPM_ORDER_CDS
      INTO @DATA(LS_ORDER)
      WHERE AUFNR EQ @WF_KEY.

    DATA(LV_WF_ID) = SWITCH #( LS_ORDER-AUART WHEN 'YBA4' THEN |WF-6.1|
                                              WHEN 'YBA9' THEN |WF-6.2| ).

*Read History
    SELECT SINGLE *
      FROM ZPM_WF_HST
      INTO @DATA(LS_WF_HST)
      WHERE WF_ID EQ @LV_WF_ID
      AND LEVELS EQ '0000000001'
      AND AUFNR EQ @WF_KEY
      AND HST_ID = ( SELECT MAX( HST_ID ) FROM ZPM_WF_HST WHERE AUFNR = @WF_KEY AND LEVELS EQ '0000000001' ).
    MOVE-CORRESPONDING LS_WF_HST TO LS_WF_NEX.
    LS_WF_NEX-LEVELS = LS_WF_NEX-LEVELS + 1.

    SELECT ERNAM FROM ZPM_ROT INTO TABLE LT_AGENTS
      WHERE ( BLOCK = LS_ORDER-TPLNR(3) OR ZZONE = LS_ORDER-TPLNR+7(3) ) "Firts 3 Chars to scan
      AND WF_ID EQ LV_WF_ID
      AND LEVELS EQ '0000000002'.

    LOOP AT LT_AGENTS INTO LS_AGENTS.
      DATA: NEXT_APPROVED_BY TYPE CHAR255.
      LS_AGENTS-ERNAM = |US{ LS_AGENTS-ERNAM }|.
      APPEND LS_AGENTS TO ET_AGENTS.
      IF NEXT_APPROVED_BY IS INITIAL.
        NEXT_APPROVED_BY = LS_AGENTS-ERNAM+2.
      ELSE.
        NEXT_APPROVED_BY = |{ NEXT_APPROVED_BY } - { LS_AGENTS-ERNAM+2 }|.
      ENDIF.
      CLEAR LS_AGENTS.
    ENDLOOP.

*--- Send Email to initiator the workflow triggered ---*
    LV_USER = INITIATOR+2.
    CALL FUNCTION 'BAPI_USER_GET_DETAIL'
      EXPORTING
        USERNAME      = LV_USER
        CACHE_RESULTS = 'X'
      TABLES
        RETURN        = LT_RETURN
        ADDSMTP       = LT_ADDSMTP.

**************************************************&--- Assign the Email id and User id to  Whom you want to Send --------&Commit by adnan khan to stop message tp sap inbox
*************************************************    LS_REC-RECEIVER   = LV_USER.  "&----- Assign SAP User Id
*************************************************    LS_REC-REC_TYPE   = 'B'.       "&-- Send to SAP Inbox
*************************************************    LS_REC-COM_TYPE   = 'INT'.
*************************************************    LS_REC-NOTIF_DEL  = 'X'.
*************************************************    LS_REC-NOTIF_NDEL = 'X'.
*************************************************    APPEND LS_REC TO LT_RECEIVERS .

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
      WHERE TPLNR = @LS_ORDER-TPLNR(10)
      AND SPRAS = @SY-LANGU.

*-------------& EMAIL MESSAGE  &-----------------*
    DATA(LV_DATE) = |{ LS_ORDER-ERDAT+6(2) }.{ LS_ORDER-ERDAT+4(2) }.{ LS_ORDER-ERDAT+0(4) }</td></tr>|.
    DATA(LV_NUM1) = |{ LS_ORDER-AUFNR ALPHA = OUT }|.
    DATA(LV_NUM2) = |{ LS_ORDER-EQUNR ALPHA = OUT }|.

    LV_SUBJECT = |Order { WF_KEY } workflow started|.
    LS_MESSAGE-LINE = '<html><body style="background-color: #FFFFFF;" font-family="arial, verdana, courier;" font-size="2">'.
    APPEND LS_MESSAGE TO LT_MESSAGE.
    LS_MESSAGE-LINE = '<table style="margin: 10px;" border="1px" border-color="#000000" width="100%">'.
    APPEND LS_MESSAGE TO LT_MESSAGE.

    LT_MESSAGE = VALUE #( BASE LT_MESSAGE
    ( LINE = |<tr><td width=25%>Order No.</td><td width=75%>{ WF_KEY }</td></tr>| )
    ( LINE = |<tr><td width=25%>Order Desc</td><td width=75%>{ LS_ORDER-KTEXT }</td></tr>| )
    ( LINE = |<tr><td width=25%>Order Creation Date</td><td width=75%>{ LV_DATE }</td></tr>| )
    ( LINE = |<tr><td width=25%>Priority</td><td width=75%>{ LS_ORDER-PRIOKX }</td></tr>| )
    ( LINE = |<tr><td width=25%>ABC Indicator</td><td width=75%>{ LS_ORDER-ABCTX }</td></tr>| )
    ( LINE = |<tr><td width=25%>User Status</td><td width=75%>{ LS_WF_HST-C_STAT }</td></tr>| )
    ( LINE = |<tr><td width=25%>Status Date</td><td width=75%>{ LV_DATE }</td></tr>| )
    ( LINE = |<tr><td width=25%>Last Approved By</td><td width=75%>   </td></tr>| )
    ( LINE = |<tr><td width=25%>Last Approved By Date</td><td width=75%>   </td></tr>| )
    ( LINE = |<tr><td width=25%>Last Approved By Time</td><td width=75%>   </td></tr>| )
    ( LINE = |<tr><td width=25%>Next Approval By</td><td width=75%>{ NEXT_APPROVED_BY }</td></tr>| )
    ( LINE = |<tr><td width=25%>Equip no</td><td width=75%>{ LV_NUM2 }</td></tr>| )
    ( LINE = |<tr><td width=25%>Equip no Desc</td><td width=75%>{ LS_ORDER-EQKTX }</td></tr>| )
    ( LINE = |<tr><td width=25%>Tech ID</td><td width=75%>{ LS_ORDER-TIDNR }</td></tr>| )
    ( LINE = |<tr><td width=25%>Created By</td><td width=75%>{ INITIATOR+2 }</td></tr>| )
    ( LINE = |<tr><td width=25%>Functional Location Desc</td><td width=75%>{ LS_ORDER-PLTXT }</td></tr>| )
    ( LINE = |<tr><td width=25%>Facility/Remote/Field</td><td width=75%>{  LV_ZONE }</td></tr>| )
    ( LINE = |<tr><td width=25%>Zone</td><td width=75%>{ LS_ORDER-FACILITY }</td></tr>| )
    ).
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
    GD_DOC_DATA-DOC_SIZE = 1.
    GD_DOC_DATA-OBJ_LANGU = SY-LANGU.
    GD_DOC_DATA-OBJ_NAME = 'SAPRPT'.
    GD_DOC_DATA-OBJ_DESCR = LV_SUBJECT.
    GD_DOC_DATA-SENSITIVTY = 'F'.
*------- Describe the body of the message

*Information about structure of data tables
    LS_PACK-TRANSF_BIN = SPACE.
    LS_PACK-HEAD_START = 1.
    LS_PACK-HEAD_NUM = 0.
    LS_PACK-BODY_START = 1.
    DESCRIBE TABLE LT_MESSAGE LINES LS_PACK-BODY_NUM.
    LS_PACK-DOC_TYPE = 'HTML'.
    APPEND LS_PACK TO LT_PACKING_LIST.

*&------ Call the Function Module to send the message to External and SAP Inbox
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
        SENDER1 = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'sap_wfrt@uecom' ).
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



*--- Send to Approver ---*
    CLEAR: LV_USER, LT_RETURN[], LT_ADDSMTP[], LS_ADDSMTP, LS_REC, LT_RECEIVERS[], LS_MESSAGE, LT_MESSAGE[],
           LS_PACK, LT_PACKING_LIST[], GD_DOC_DATA.

    LOOP AT LT_AGENTS INTO LS_AGENTS.
      DATA:LV_XUBNAME TYPE XUBNAME.
      CLEAR LV_XUBNAME.
      LV_XUBNAME = LS_AGENTS-ERNAM.
*      &--- GET USER DETAIL ---&*
      CALL FUNCTION 'BAPI_USER_GET_DETAIL'
        EXPORTING
          USERNAME      = LV_XUBNAME
          CACHE_RESULTS = 'X'
*         EXTUID_GET    =
        TABLES
          RETURN        = LT_RETURN
          ADDSMTP       = LT_ADDSMTP.

*********************************      &--- ASSIGN THE EMAIL ID AND USER ID TO  WHOM YOU WANT TO SEND --------&Commit by adnan khan to stop message tp sap inbox
********************************      LS_REC-RECEIVER   = LS_AGENTS-ERNAM.  "&----- Assign SAP User Id
********************************      LS_REC-REC_TYPE   = 'B'.          "&-- Send to SAP Inbox
********************************      LS_REC-COM_TYPE   = 'INT'.
********************************      LS_REC-NOTIF_DEL  = 'X'.
********************************      LS_REC-NOTIF_NDEL = 'X'.
********************************      APPEND LS_REC TO LT_RECEIVERS .
      BREAK AC_ADNAN.
      CLEAR LS_ADDSMTP.
      LOOP AT LT_ADDSMTP INTO LS_ADDSMTP..
        LS_REC-RECEIVER   = LS_ADDSMTP-E_MAIL.  "&----- Assign SAP User Id
        LS_REC-REC_TYPE   = 'U'.            "&-- Send to SAP Inbox
        LS_REC-COM_TYPE   = 'INT'.
        LS_REC-NOTIF_DEL  = 'X'.
        LS_REC-NOTIF_NDEL = 'X'.
        APPEND LS_REC TO LT_RECEIVERS .
      ENDLOOP.

*----- Update ZPM_WF_NEX Table for Order Assigned users -----------*
*      LS_WF_NEX-UNAME = LS_AGENTS-ERNAM+2.
      LS_WF_NEX-UNAME = LS_AGENTS-ERNAM.
      LS_WF_NEX-UDATE = SY-DATUM.
      LS_WF_NEX-UZEIT = SY-UZEIT.
      BREAK AC_ADNAN.
      INSERT ZPM_WF_NEX FROM LS_WF_NEX.

      CLEAR: LS_AGENTS, LT_ADDSMTP[].
    ENDLOOP.

*-------------& EMAIL MESSAGE  &-----------------*
    LV_DATE = |{ LS_ORDER-ERDAT+6(2) }.{ LS_ORDER-ERDAT+4(2) }.{ LS_ORDER-ERDAT+0(4) }</td></tr>|.
    LV_NUM1 = |{ LS_ORDER-AUFNR ALPHA = OUT }|.
    LV_NUM2 = |{ LS_ORDER-EQUNR ALPHA = OUT }|.

    LV_SUBJECT = |Approve or Reject Order { WF_KEY }?|.
    LS_MESSAGE-LINE = '<html><body style="background-color: #FFFFFF;" font-family="arial, verdana, courier;" font-size="2">'.
    APPEND LS_MESSAGE TO LT_MESSAGE.
    LS_MESSAGE-LINE = '<table style="margin: 10px;" border="1px" border-color="#000000" width="100%">'.
    APPEND LS_MESSAGE TO LT_MESSAGE.

    LT_MESSAGE = VALUE #( BASE LT_MESSAGE
    ( LINE = |<tr><td width=25%>Order No.</td><td width=75%>{ WF_KEY }</td></tr>| )
    ( LINE = |<tr><td width=25%>Order Desc</td><td width=75%>{ LS_ORDER-KTEXT }</td></tr>| )
    ( LINE = |<tr><td width=25%>Order Creation Date</td><td width=75%>{ LV_DATE }</td></tr>| )
    ( LINE = |<tr><td width=25%>Priority</td><td width=75%>{ LS_ORDER-PRIOKX }</td></tr>| )
    ( LINE = |<tr><td width=25%>ABC Indicator</td><td width=75%>{ LS_ORDER-ABCTX }</td></tr>| )
    ( LINE = |<tr><td width=25%>User Status</td><td width=75%>{ LS_WF_HST-C_STAT }</td></tr>| )
    ( LINE = |<tr><td width=25%>Status Date</td><td width=75%>{ LV_DATE }</td></tr>| )
    ( LINE = |<tr><td width=25%>Last Approved By</td><td width=75%>   </td></tr>| )
    ( LINE = |<tr><td width=25%>Last Approved By Date</td><td width=75%>   </td></tr>| )
    ( LINE = |<tr><td width=25%>Last Approved By Time</td><td width=75%>   </td></tr>| )
    ( LINE = |<tr><td width=25%>Next Approval By</td><td width=75%>{ NEXT_APPROVED_BY }</td></tr>| )
    ( LINE = |<tr><td width=25%>Equip no</td><td width=75%>{ LV_NUM2 }</td></tr>| )
    ( LINE = |<tr><td width=25%>Equip no Desc</td><td width=75%>{ LS_ORDER-EQKTX }</td></tr>| )
    ( LINE = |<tr><td width=25%>Tech ID</td><td width=75%>{ LS_ORDER-TIDNR }</td></tr>| )
    ( LINE = |<tr><td width=25%>Created By</td><td width=75%>{ INITIATOR+2 }</td></tr>| )
    ( LINE = |<tr><td width=25%>Functional Location Desc</td><td width=75%>{ LS_ORDER-PLTXT }</td></tr>| )
*    ( LINE = |<tr><td width=25%>Facility/Remote/Field</td><td width=75%>   </td></tr>| )
*    ( LINE = |<tr><td width=25%>Zone</td><td width=75%>   </td></tr>| )
    ).
    LS_MESSAGE-LINE = |</table>|.
    APPEND LS_MESSAGE TO LT_MESSAGE.

*    LS_MESSAGE-LINE = '<table style="margin: 10px;" width="100%">'.
*    APPEND LS_MESSAGE TO LT_MESSAGE.
*    LS_MESSAGE-LINE = |<tr><td width=100%><a href={ FIORI_INNER }>Fiori within UEP Primise</a></td></tr>|.
*    APPEND LS_MESSAGE TO LT_MESSAGE.
*    LS_MESSAGE-LINE = |<tr><td width=100%><a href={ FIORI_OUTER }>Fiori outside UEP Primise</a></td></tr>|.
*    APPEND LS_MESSAGE TO LT_MESSAGE.
*    LS_MESSAGE-LINE = |</table>|.
*    APPEND LS_MESSAGE TO LT_MESSAGE.

    LS_MESSAGE-LINE = |</body></html>|.
    APPEND LS_MESSAGE TO LT_MESSAGE.

    T_MESSAGE[] = LT_MESSAGE[].

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
        SENDER1 = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'sap_wfrt@ueg.com' ).
        CALL METHOD GO_SEND_REQUEST->SET_SENDER
          EXPORTING
            I_SENDER = SENDER1.

        SORT LT_ADDSMTP.
        DELETE LT_ADDSMTP WHERE E_MAIL IS INITIAL.
     "   DATA:LV_EMAIL TYPE ADR6-SMTP_ADDR.
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
*****************    GD_DOC_DATA-DOC_SIZE = 1.
*****************    GD_DOC_DATA-OBJ_LANGU = SY-LANGU.
*****************    GD_DOC_DATA-OBJ_NAME = 'SAPRPT'.
*****************    GD_DOC_DATA-OBJ_DESCR = LV_SUBJECT.
*****************    GD_DOC_DATA-SENSITIVTY = 'F'.
******************------- Describe the body of the message
*****************
******************Information about structure of data tables
*****************    LS_PACK-TRANSF_BIN = SPACE.
*****************    LS_PACK-HEAD_START = 1.
*****************    LS_PACK-HEAD_NUM = 0.
*****************    LS_PACK-BODY_START = 1.
*****************    DESCRIBE TABLE LT_MESSAGE LINES LS_PACK-BODY_NUM.
*****************    LS_PACK-DOC_TYPE = 'HTML'.
*****************    APPEND LS_PACK TO LT_PACKING_LIST.
*****************
******************&------ Call the Function Module to send the message to External and SAP Inbox
*****************    CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
*****************      EXPORTING
*****************        DOCUMENT_DATA              = GD_DOC_DATA
*****************        PUT_IN_OUTBOX              = 'X'
*****************        COMMIT_WORK                = 'X'
*****************      TABLES
*****************        PACKING_LIST               = LT_PACKING_LIST
*****************        CONTENTS_TXT               = LT_MESSAGE
*****************        RECEIVERS                  = LT_RECEIVERS
*****************      EXCEPTIONS
*****************        TOO_MANY_RECEIVERS         = 1
*****************        DOCUMENT_NOT_SENT          = 2
*****************        DOCUMENT_TYPE_NOT_EXIST    = 3
*****************        OPERATION_NO_AUTHORIZATION = 4
*****************        PARAMETER_ERROR            = 5
*****************        X_ERROR                    = 6
*****************        ENQUEUE_ERROR              = 7
*****************        OTHERS                     = 8.
*****************    IF SY-SUBRC <> 0.
*****************      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*****************              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*****************    ENDIF.


  ENDMETHOD.


  method REJECT.

    app_rej = '0'.

  endmethod.


  METHOD TRIGGER_WF.

* Data Declarations
    DATA: LV_OBJTYPE          TYPE SIBFTYPEID,
          LV_EVENT            TYPE SIBFEVENT
          .

* Setting values of Event Name
    LV_OBJTYPE = 'ZCL_PM_PRD_AND_PIGG_WF_ZMF'. "class name
    LV_EVENT   = 'TRIGGER'.    "event name.


* Raise the event passing the prepared event container
    TRY.
        CALL METHOD CL_SWF_EVT_EVENT=>RAISE
          EXPORTING
            IM_OBJCATEG = GS_OBJ-CATID
            IM_OBJTYPE  = LV_OBJTYPE
            IM_EVENT    = LV_EVENT
            IM_OBJKEY   = WF_KEY.
        COMMIT WORK.
*            IM_EVENT_CONTAINER = LR_EVENT_PARAMETERS.
      CATCH CX_SWF_EVT_INVALID_OBJTYPE .
      CATCH CX_SWF_EVT_INVALID_EVENT .
    ENDTRY.

  ENDMETHOD.


  METHOD UPDATES.
*Data Declarations
    DATA: GO_SEND_REQUEST  TYPE REF TO  CL_BCS,
          GO_DOCUMENT      TYPE REF TO  CL_DOCUMENT_BCS,
          LV_SENT_TO_ALL   TYPE OS_BOOLEAN,
          LO_RECIPIENT     TYPE REF TO  IF_RECIPIENT_BCS,
          LO_BCS_EXCEPTION TYPE REF TO  CX_BCS,
          SENDER1          TYPE REF TO CL_CAM_ADDRESS_BCS..

    DATA(LV_UNAME) = SY-UNAME.
    SY-UNAME = APPROVER+2.
    DATA: LV_WF_ID        TYPE ZPM_ROT-WF_ID,
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
          LT_RETURN       TYPE TABLE OF BAPIRET2
          .


    SELECT SINGLE *
      FROM ZPM_ORDER_CDS
      INTO @DATA(LS_ORDER)
      WHERE AUFNR EQ @WF_KEY.

    LV_WF_ID = SWITCH #( LS_ORDER-AUART WHEN 'YBA4' THEN |WF-6.1|
*                                       WHEN 'YBA6' THEN |WF-6.2| ).
                                       WHEN 'YBA9' THEN |WF-6.2| ).

    SELECT SINGLE *
      FROM ZPM_SET_V1
      INTO @DATA(LS_ZPM_SET_V1)
      WHERE WF_ID EQ @LV_WF_ID
      AND LEVELS EQ '0000000002'.

*Read History
    SELECT SINGLE *
      FROM ZPM_WF_HST
      INTO @DATA(LS_WF_HST)
      WHERE WF_ID EQ @LV_WF_ID
      AND LEVELS EQ '0000000001'
      AND AUFNR EQ @WF_KEY
      AND HST_ID = ( SELECT MAX( HST_ID ) FROM ZPM_WF_HST WHERE AUFNR = @WF_KEY AND LEVELS EQ '1' ).

*Delete Next Table for completed current level
    SELECT SINGLE * FROM ZPM_WF_NEX INTO @DATA(LSNEX)
      WHERE WF_ID = @LV_WF_ID
      AND AUFNR = @WF_KEY
      AND LEVELS = '0000000002'.
    IF SY-SUBRC EQ 0.
      DELETE FROM ZPM_WF_NEX WHERE WF_ID = LV_WF_ID AND AUFNR = WF_KEY AND LEVELS = 2.
    ENDIF.

*-----Read Attached Doc from Workflow Approval
    CALL FUNCTION 'SAP_WAPI_GET_ATTACHMENTS'
      EXPORTING
        WORKITEM_ID = ZWORKITEMID
      IMPORTING
        RETURN_CODE = ZRETURN_CODE
      TABLES
        ATTACHMENTS = ZATTACHMENTS.
    LOOP AT ZATTACHMENTS ASSIGNING FIELD-SYMBOL(<FS_ATTACH>) where object_typ = 'CM'.

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
      LS_WF_HST-REMARKS =  REDUCE #( INIT TEXT = `` FOR <LINE1> IN OBJECT_CONTENT NEXT  TEXT = TEXT && | | && <LINE1>-LINE  ).

    ENDLOOP.

*Get Max History No.
    SELECT MAX( HST_ID ) FROM ZPM_WF_HST INTO @DATA(LV_HST_ID).
    LV_HST_ID = LV_HST_ID + 1.

    LS_WF_HST-HST_ID = LV_HST_ID.
*    LS_WF_HST-WF_ID = LV_WF_ID.
    LS_WF_HST-LEVELS = '0000000002'.
*    LS_WF_HST-AUFNR = I_AUFNR.
    LS_WF_HST-P_STAT = LS_WF_HST-C_STAT.
    LS_WF_HST-WFSTAT = 'X'.
    LS_WF_HST-ERNAM = SY-UNAME.
    LS_WF_HST-OBJ_DATE = SY-DATUM.
    LS_WF_HST-UZEIT = SY-UZEIT.
    LS_WF_HST-APP_REJ = APP_REJ.

    LS_WF_HST-C_STAT = SWITCH #( APP_REJ WHEN '1' THEN |COMP|
                                         WHEN '0' THEN |CNCL| ).
    DATA(LV_APP_REJ_TEXT) = SWITCH #( APP_REJ WHEN '1' THEN |Approved|
                                              WHEN '0' THEN |Rejected| ).

*---Update Status
    SELECT SINGLE STSMA FROM JSTO INTO @DATA(LV_STSMA) WHERE OBJNR EQ @LS_ORDER-OBJNR.

    SELECT SINGLE * FROM TJ30T
      INTO @DATA(LS_TJ30T)
      WHERE SPRAS EQ @SY-LANGU
      AND TXT04 EQ @LS_WF_HST-C_STAT
      AND STSMA EQ @LV_STSMA.

    LV_OBJNR = LS_ORDER-OBJNR.
    LV_STATUS = LS_TJ30T-ESTAT.

    CALL FUNCTION 'STATUS_CHANGE_EXTERN'
      EXPORTING
*       CHECK_ONLY          = ' '
        CLIENT              = SY-MANDT
        OBJNR               = LV_OBJNR
        USER_STATUS         = LV_STATUS
*       SET_INACT           = ' '
        SET_CHGKZ           = 'X'
        NO_CHECK            = 'X'
      IMPORTING
        STONR               = STONR
      EXCEPTIONS
        OBJECT_NOT_FOUND    = 1
        STATUS_INCONSISTENT = 2
        STATUS_NOT_ALLOWED  = 3.
    IF SY-SUBRC EQ 0.
*LS_WF_HST-OBJNR = LV_OBJNR.
*LS_WF_HST-order = LS_ORDER-aufnr.


      MODIFY ZPM_WF_HST FROM LS_WF_HST.
break amehmood.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'. " Change by Adil to Insert the table after commit : 09062023
************************* EMAIL *************************
      BREAK AC_ADNAN.
*&--- Get user Detail ---&*
      DATA:LV_INIT TYPE BAPIBNAME-BAPIBNAME.
      CLEAR LV_INIT.
      LV_INIT =  INITIATOR+2.
      CALL FUNCTION 'BAPI_USER_GET_DETAIL'
        EXPORTING
          USERNAME      = LV_INIT
          CACHE_RESULTS = 'X'
*         EXTUID_GET    =
        TABLES
          RETURN        = LT_RETURN
          ADDSMTP       = LT_ADDSMTP.

*&--- Assign the Email id and User id to  Whom you want to Send --------&
      FREE: LS_REC, LT_RECEIVERS[].

****      LS_REC-RECEIVER   = INITIATOR+2.  "&----- Assign SAP User Id
****      LS_REC-REC_TYPE   = 'B'.          "&-- Send to SAP Inbox
****      LS_REC-COM_TYPE   = 'INT'.
****      LS_REC-NOTIF_DEL  = 'X'.
****      LS_REC-NOTIF_NDEL = 'X'.
****      APPEND LS_REC TO LT_RECEIVERS .

      LOOP AT LT_ADDSMTP ASSIGNING FIELD-SYMBOL(<LINE>).
        LS_REC-RECEIVER   = <LINE>-E_MAIL.  "&----- Assign SAP User Id
        LS_REC-REC_TYPE   = 'U'.            "&-- Send to SAP Inbox
        LS_REC-COM_TYPE   = 'INT'.
        LS_REC-NOTIF_DEL  = 'X'.
        LS_REC-NOTIF_NDEL = 'X'.
        APPEND LS_REC TO LT_RECEIVERS .
      ENDLOOP.

      FREE: LT_ADDSMTP.
      CLEAR LV_INIT.
      LV_INIT = APPROVER+2.
      CALL FUNCTION 'BAPI_USER_GET_DETAIL'
        EXPORTING
          USERNAME      = LV_INIT
          CACHE_RESULTS = 'X'
*         EXTUID_GET    =
        TABLES
          RETURN        = LT_RETURN
          ADDSMTP       = LT_ADDSMTP.

**************************************************************************      LS_REC-RECEIVER   = APPROVER+2.  "&----- Assign SAP User IdCommit by adnan khan to stop message tp sap inbox
**************************************************************************      LS_REC-REC_TYPE   = 'B'.          "&-- Send to SAP Inbox
**************************************************************************      LS_REC-COM_TYPE   = 'INT'.
**************************************************************************      LS_REC-NOTIF_DEL  = 'X'.
**************************************************************************      LS_REC-NOTIF_NDEL = 'X'.
**************************************************************************      APPEND LS_REC TO LT_RECEIVERS .

      LOOP AT LT_ADDSMTP INTO  LS_ADDSMTP.
        LS_REC-RECEIVER   = LS_ADDSMTP-E_MAIL.  "&----- Assign SAP User Id
        LS_REC-REC_TYPE   = 'U'.            "&-- Send to SAP Inbox
        LS_REC-COM_TYPE   = 'INT'.
        LS_REC-NOTIF_DEL  = 'X'.
        LS_REC-NOTIF_NDEL = 'X'.
        APPEND LS_REC TO LT_RECEIVERS .
      ENDLOOP.

      "Zone
      SELECT SINGLE PLTXT FROM IFLO INTO @DATA(LV_ZONE)
        WHERE TPLNR = @LS_ORDER-TPLNR(10)
        AND SPRAS = @SY-LANGU.

      "Fiori Link
      CASE SY-HOST.
        WHEN 'uekhidev'.
    "      DATA(FIORI_INNER) = |"https://uekhidev.uead.uep.com.pk:44300/sap/bc/ui2/flp?sap-client=110&sap-language=EN#WorkflowTask-displayInbox?allItems=true"|.
          DATA(FIORI_OUTER) = |"https://uekhiwdp.uead.uep.com.pk:44301/sap/bc/ui5_ui5/ui2/ushell/shells/abap/Fiorilaunchpad.html#WorkflowTask-displayInbox?allItems=true&sap-client=110"|.
        WHEN 'uekhiqas'.
      "    FIORI_INNER = |"https://uekhiqas.uead.uep.com.pk:44302/sap/bc/ui2/flp?sap-client=200&sap-language=EN#WorkflowTask-displayInbox?allItems=true"|.
          FIORI_OUTER = |"https://uekhiwdp.uead.uep.com.pk:44302/sap/bc/ui5_ui5/ui2/ushell/shells/abap/Fiorilaunchpad.html#WorkflowTask-displayInbox?allItems=true&sap-client=200"|.
        WHEN 'uekhiprdappv'.
    "      FIORI_INNER = |"https://uekhiwdp.uead.uep.com.pk:44303/sap/bc/ui5_ui5/ui2/ushell/shells/abap/Fiorilaunchpad.html#WorkflowTask-displayInbox?allItems=true"|.
          FIORI_OUTER = |"https://uekhiwdp.uead.uep.com.pk:44303/sap/bc/ui5_ui5/ui2/ushell/shells/abap/Fiorilaunchpad.html#WorkflowTask-displayInbox?allItems=true"|.
      ENDCASE.

*-------------& Send EMAIL MESSAGE  &-----------------*
      DATA(LV_DATE) = |{ LS_ORDER-ERDAT+6(2) }.{ LS_ORDER-ERDAT+4(2) }.{ LS_ORDER-ERDAT+0(4) }|.
      DATA(LV_NUM1) = |{ LS_ORDER-AUFNR ALPHA = OUT }|.
      DATA(LV_NUM2) = |{ LS_ORDER-EQUNR ALPHA = OUT }|.

      LV_SUBJECT = |Order { WF_KEY } { LV_APP_REJ_TEXT } by { APPROVER+2 }|.
      LS_MESSAGE-LINE = '<html><body style="background-color: #FFFFFF;" font-family="arial, verdana, courier;" font-size="2">'.
      APPEND LS_MESSAGE TO LT_MESSAGE.
      LS_MESSAGE-LINE = '<table style="margin: 10px;" border="1px" border-color="#000000" width="100%">'.
      APPEND LS_MESSAGE TO LT_MESSAGE.

      LT_MESSAGE = VALUE #( BASE LT_MESSAGE
      ( LINE = |<tr><td width=25%>Order No.</td><td width=75%>{ WF_KEY }</td></tr>| )
      ( LINE = |<tr><td width=25%>Order Desc</td><td width=75%>{ LS_ORDER-KTEXT }</td></tr>| )
      ( LINE = |<tr><td width=25%>Order Creation Date</td><td width=75%>{ LV_DATE }</td></tr>| )
      ( LINE = |<tr><td width=25%>Priority</td><td width=75%>{ LS_ORDER-PRIOKX }</td></tr>| )
      ( LINE = |<tr><td width=25%>ABC Indicator</td><td width=75%>{ LS_ORDER-ABCTX }</td></tr>| )
      ( LINE = |<tr><td width=25%>User Status</td><td width=75%>{ LS_WF_HST-C_STAT }</td></tr>| )
      ( LINE = |<tr><td width=25%>Status Date</td><td width=75%>{ LV_DATE }</td></tr>| )
      ( LINE = |<tr><td width=25%>Last Approved By</td><td width=75%>{ APPROVER+2 }</td></tr>| )
      ( LINE = |<tr><td width=25%>Last Approved By Date</td><td width=75%>{ LS_WF_HST-OBJ_DATE }</td></tr>| )
      ( LINE = |<tr><td width=25%>Last Approved By Time</td><td width=75%>{ LS_WF_HST-UZEIT }</td></tr>| )
*      ( LINE = |<tr><td width=25%>Next Approval By</td><td width=75%>   </td></tr>| )
      ( LINE = |<tr><td width=25%>Equip no</td><td width=75%>{ LV_NUM2 }</td></tr>| )
      ( LINE = |<tr><td width=25%>Equip no Desc</td><td width=75%>{ LS_ORDER-EQKTX }</td></tr>| )
      ( LINE = |<tr><td width=25%>Tech ID</td><td width=75%>{ LS_ORDER-TIDNR }</td></tr>| )
      ( LINE = |<tr><td width=25%>Created By</td><td width=75%>{ INITIATOR+2 }</td></tr>| )
      ( LINE = |<tr><td width=25%>Functional Location Desc</td><td width=75%>{ LS_ORDER-PLTXT }</td></tr>| )
      ( LINE = |<tr><td width=25%>Facility/Remote/Field</td><td width=75%>{  LV_ZONE }</td></tr>| )
      ( LINE = |<tr><td width=25%>Zone</td><td width=75%>{ LS_ORDER-FACILITY }</td></tr>| )
      ).
      LS_MESSAGE-LINE = |</table>|.
      APPEND LS_MESSAGE TO LT_MESSAGE.

      LS_MESSAGE-LINE = '<table style="margin: 10px;" width="100%">'.
      APPEND LS_MESSAGE TO LT_MESSAGE.
*      LS_MESSAGE-LINE = |<tr><td width=100%><a href={ FIORI_INNER }>Fiori within UEP Primise</a></td></tr>|.
*      APPEND LS_MESSAGE TO LT_MESSAGE.
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
*           i_length  = '12'
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
*          SENDER1 = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( 'sap_wfrt@uep.com.pk' ).
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

********************************************************Populate the subject/generic message attributes --- Attributes of new document
*******************************************************      GD_DOC_DATA-DOC_SIZE = 1.
*******************************************************      GD_DOC_DATA-OBJ_LANGU = SY-LANGU.
*******************************************************      GD_DOC_DATA-OBJ_NAME = 'SAPRPT'.
*******************************************************      GD_DOC_DATA-OBJ_DESCR = LV_SUBJECT.
*******************************************************      GD_DOC_DATA-SENSITIVTY = 'F'.
********************************************************------- Describe the body of the message
*******************************************************
********************************************************Information about structure of data tables
*******************************************************      CLEAR LS_PACK.
*******************************************************      REFRESH LT_PACKING_LIST.
*******************************************************      LS_PACK-TRANSF_BIN = SPACE.
*******************************************************      LS_PACK-HEAD_START = 1.
*******************************************************      LS_PACK-HEAD_NUM = 0.
*******************************************************      LS_PACK-BODY_START = 1.
*******************************************************      DESCRIBE TABLE LT_MESSAGE LINES LS_PACK-BODY_NUM.
*******************************************************      LS_PACK-DOC_TYPE = 'HTML'.
*******************************************************      APPEND LS_PACK TO LT_PACKING_LIST.
*******************************************************
********************************************************&------ Call the Function Module to send the message to External and SAP Inbox
*******************************************************      CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
*******************************************************        EXPORTING
*******************************************************          DOCUMENT_DATA              = GD_DOC_DATA
*******************************************************          PUT_IN_OUTBOX              = 'X'
*******************************************************          COMMIT_WORK                = 'X'
*******************************************************        TABLES
*******************************************************          PACKING_LIST               = LT_PACKING_LIST
*******************************************************          CONTENTS_TXT               = LT_MESSAGE
*******************************************************          RECEIVERS                  = LT_RECEIVERS
*******************************************************        EXCEPTIONS
*******************************************************          TOO_MANY_RECEIVERS         = 1
*******************************************************          DOCUMENT_NOT_SENT          = 2
*******************************************************          DOCUMENT_TYPE_NOT_EXIST    = 3
*******************************************************          OPERATION_NO_AUTHORIZATION = 4
*******************************************************          PARAMETER_ERROR            = 5
*******************************************************          X_ERROR                    = 6
*******************************************************          ENQUEUE_ERROR              = 7
*******************************************************          OTHERS                     = 8.
*******************************************************      IF SY-SUBRC <> 0.
*******************************************************        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*******************************************************                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*******************************************************      ENDIF.
*******************************************************
    ENDIF.
    SY-UNAME = LV_UNAME.

  ENDMETHOD.


  METHOD CREATE_ADHOC_OBJECT.

    DATA: LS_OBJS TYPE SIBFLPORB,
          LT_OBJS TYPE TABLE OF SIBFLPORB.

    LS_OBJS-CATID = 'BO'.
    LS_OBJS-TYPEID = 'BUS2007'.
    LS_OBJS-INSTID = WF_KEY.
    APPEND LS_OBJS TO LT_OBJS.

    ET_BO_OBJS[] = LT_OBJS[].

  ENDMETHOD.


  METHOD DISP_ORDER.

    SET PARAMETER ID 'ANR' FIELD WF_KEY.
    CALL TRANSACTION 'IW33' AND SKIP FIRST SCREEN.

  ENDMETHOD.
ENDCLASS.
