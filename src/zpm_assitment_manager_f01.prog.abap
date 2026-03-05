*&---------------------------------------------------------------------*
*& Include          ZPM_ASSITMENT_MANAGER_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .
  BREAK AC_ADNAN.


  IF S_WERKS IS INITIAL.
    MESSAGE 'Select any plant!' TYPE 'S' DISPLAY LIKE 'E'.
    LV_CHECK_PERNR = 'X'.
    EXIT.
  ENDIF.
*--- ARBEITSPLATZ LESEN
  DATA:CAUFVD TYPE CAUFVD.
  CALL FUNCTION 'CR_WORKSTATION_CHECK'
    EXPORTING
      ARBPL     = S_VAPLZ-LOW
      WERKS     = S_WERKS-LOW
    IMPORTING
      ARBID     = CAUFVD-GEWRK
      KTEXT     = CAUFVD-VATXT
      OBJTY     = CAUFVD-PM_OBJTY
    EXCEPTIONS
      NOT_FOUND = 01.
  IF SY-SUBRC = 1.
    IF SY-SUBRC = 1.
      MESSAGE 'Work center plant not allowed for Plant Maintenance' TYPE 'S' DISPLAY LIKE 'E'.
      LV_CHECK_PERNR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.

  IF P_PERNR IS NOT INITIAL.
    SELECT SINGLE * FROM PA0001
      INTO  @DATA(LS_PERNR)
      WHERE PERNR = @P_PERNR.
    IF SY-SUBRC  <> 0.
      MESSAGE 'Employee is invalid' TYPE 'S' DISPLAY LIKE 'E'.
      LV_CHECK_PERNR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.

***  LV_CHECK_DATE = 'X'.
***  LV_CHECK_PERNR = 'X'.
***  IF P_FDATE IS NOT INITIAL.
***    CLEAR LV_CHECK_DATE.
***  ENDIF.
***  IF LV_CHECK_DATE IS NOT INITIAL.
***    CLEAR LV_CHECK_DATE.
***  ENDIF.
***  IF P_PERNR IS NOT INITIAL.
***    CLEAR LV_CHECK_PERNR.
***  ENDIF.
***
***  IF LV_CHECK_DATE IS  NOT INITIAL.
***    MESSAGE 'Select last due date' TYPE 'S' DISPLAY LIKE 'E'.
***  ENDIF.
***  IF LV_CHECK_PERNR IS NOT INITIAL.
***    MESSAGE 'Select Assign P.No' TYPE 'S' DISPLAY LIKE 'E'.
***  ENDIF.
*  CHECK LV_CHECK_DATE = '' or LV_CHECK_PERNR = ''.
  CLEAR LV_CHECK_PERNR.

  CLEAR LV_CHECK_PERNR.

  IF S_VAPLZ IS INITIAL.
    MESSAGE 'Select any work center' TYPE 'S' DISPLAY LIKE 'E'.
    LV_CHECK_PERNR = 'X'.
    EXIT.
  ENDIF.

  IF P_FDATE IS INITIAL AND P_PERNR IS INITIAL.
    MESSAGE 'Select any Date or Assign P.No' TYPE 'S' DISPLAY LIKE 'E'.
    LV_CHECK_PERNR = 'X'.
    EXIT.
  ENDIF.
  CHECK LV_CHECK_PERNR <>'X'.
*/***" CRF: Add remarks(Backlog) on Report Dated: Tuesday, August 8, 2023 9:51 AM Zeeshan Khokhar
  SELECT AUFNR,B~PLTXT,C~EQKTU,ZREMARKS FROM VIAUFKST AS A
    LEFT OUTER JOIN IFLOTX AS B ON A~TPLNR = B~TPLNR
    LEFT OUTER JOIN EQKT AS C ON A~EQUNR = C~EQUNR
    INTO TABLE @DATA(LT_DATA)
    WHERE SOWRK   IN @S_WERKS AND
          VAPLZ   IN @S_VAPLZ AND
          A~TPLNR   IN @S_TPLNR AND
          AUFNR   IN @S_AUFNR AND
          AUART   IN @S_AUART AND
          GLTRP   IN @S_GLTRP AND
          PRIOK   IN @S_PRIOK
    AND B~SPRAS = 'E'
    AND C~SPRAS = 'E'.

  IF LT_DATA IS NOT INITIAL.
    SELECT * FROM T356_T INTO TABLE @DATA(LT_T356_T)
      WHERE SPRAS = @SY-LANGU AND
      ARTPR = 'PM'.
  ENDIF.

  SELECT  A~EQUNR,HEQUI,B~EQKTX FROM EQUZ AS A
    LEFT JOIN EQKT AS B ON A~EQUNR = B~EQUNR
     INTO TABLE @DATA(LT_EQUZ) WHERE
*    A~EQUNR = @ES_HEADER-EQUIPMENT AND
    SPRAS = 'E'
    AND DATBI = '99991231'.

  SORT LT_EQUZ BY HEQUI ASCENDING.

  LOOP AT LT_DATA INTO DATA(LS_DATA).
    NUMBER = LS_DATA-AUFNR.
    CALL FUNCTION 'BAPI_ALM_ORDER_GET_DETAIL'
      EXPORTING
        NUMBER        = NUMBER
      IMPORTING
        ES_HEADER     = ES_HEADER
      TABLES
        ET_PARTNER    = ET_PARTNER_TMP
        ET_OPERATIONS = ET_OPERATIONS_TMP
        ET_COMPONENTS = ET_COMPONENTS_TMP
        ET_OLIST      = ET_OLIST_TMP
        RETURN        = RETURN.
    IF ES_HEADER IS NOT INITIAL.
      APPEND ES_HEADER TO ET_HEADER.

*Append GS_MAIN ES_HEADER.
      MOVE-CORRESPONDING ES_HEADER TO GS_MAIN.

*Function Locatipn Desc

      GS_MAIN-FUNCLDESCR = LS_DATA-PLTXT. "VALUE #( ET_OLIST_TMP[ FUNCT_LOC = ES_HEADER-FUNCT_LOC ]-FUNCLDESCR OPTIONAL ).
      GS_MAIN-EQUIDESCR = LS_DATA-EQKTU. "VALUE #( ET_OLIST_TMP[ EQUIPMENT = ES_HEADER-EQUIPMENT ]-EQUIDESCR OPTIONAL ).
      GS_MAIN-ZREMARKS = LS_DATA-ZREMARKS. " */***" CRF: Add remarks(Backlog) on Report Dated: Tuesday, August 8, 2023 9:51 AM Zeeshan Khokhar
      GS_MAIN-PRIOKX = VALUE #( LT_T356_T[ PRIOK = ES_HEADER-PRIORITY ]-PRIOKX OPTIONAL ).

*/CRF , Chenge the hard coded '0010' to first row. Activity '0010' not present in some operation.
      DATA(LS_OPREATION) = VALUE #( ET_OPERATIONS_TMP[ 1 ] OPTIONAL ).

      MOVE LS_OPREATION-ACTIVITY    TO GS_MAIN-ACTIVITY   .
      MOVE LS_OPREATION-DESCRIPTION TO GS_MAIN-DESCRIPTION.
      MOVE LS_OPREATION-PERS_NO     TO GS_MAIN-PERS_NO    .

*/ Superior Equipment with description
*      IF ES_HEADER-EQUIPMENT IS NOT INITIAL.
*        SELECT SINGLE HEQUI,B~EQKTX FROM EQUZ AS A
*          LEFT JOIN EQKT AS B ON A~HEQUI = B~EQUNR
*           INTO ( @GS_MAIN-EQUIPMENT_SUP , @GS_MAIN-EQUIDESCR_SUP ) WHERE A~EQUNR = @ES_HEADER-EQUIPMENT
*          AND SPRAS = 'E'.
*      ENDIF.
      DATA: LV_ROOT(1).
      DATA: LV_EQUNR TYPE EQUNR.
      CLEAR: LV_EQUNR, LV_ROOT.
      LV_EQUNR = ES_HEADER-EQUIPMENT.

      IF LV_EQUNR  IS NOT INITIAL.
        WHILE ( LV_ROOT NE 'X' ).
          LOOP AT LT_EQUZ INTO DATA(LS_ROOT) WHERE EQUNR EQ LV_EQUNR.
            IF LS_ROOT-HEQUI EQ ''.
              LV_ROOT = 'X'.
            ELSE.
              LV_EQUNR = LS_ROOT-HEQUI.
            ENDIF.
          ENDLOOP.
          IF SY-SUBRC NE 0.
            LV_ROOT = 'X'.
          ENDIF.
        ENDWHILE.
      ENDIF.

      " If root equipment is different than add
      IF LV_EQUNR NE ES_HEADER-EQUIPMENT.
        MOVE LS_ROOT-EQUNR TO GS_MAIN-EQUIPMENT_SUP.
        MOVE LS_ROOT-EQKTX TO GS_MAIN-EQUIDESCR_SUP.
      ENDIF.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = GS_MAIN-EQUIPMENT_SUP
        IMPORTING
          OUTPUT = GS_MAIN-EQUIPMENT_SUP.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = GS_MAIN-EQUIPMENT
        IMPORTING
          OUTPUT = GS_MAIN-EQUIPMENT.

      GS_MAIN-WORK_DURATION = REDUCE ARBEIT( INIT VAL TYPE ARBEIT FOR WA_DED IN  ET_OPERATIONS_TMP
                NEXT VAL = VAL + WA_DED-WORK_ACTIVITY  ).

      APPEND GS_MAIN TO GT_MAIN.
      CLEAR GS_MAIN.
      LS_OPT-AUFNR = NUMBER.
      APPEND LINES OF ET_PARTNER_TMP      TO ET_PARTNER.
*    APPEND LINES OF ET_OPERATIONS_TMP      TO ET_OPERATIONS.
      MOVE-CORRESPONDING ET_OPERATIONS_TMP      TO ET_OPERATIONS_FIELD.

      MODIFY ET_OPERATIONS FROM LS_OPT TRANSPORTING AUFNR WHERE AUFNR IS INITIAL.
      APPEND LINES OF ET_OPERATIONS_FIELD TO ET_OPERATIONS.

      APPEND  LINES OF ET_COMPONENTS_TMP      TO ET_COMPONENTS.
      APPEND  LINES OF ET_OLIST_TMP      TO ET_OLIST.
    ENDIF..
    REFRESH ET_OPERATIONS_TMP.
  ENDLOOP.


  SORT GT_MAIN  BY ORDERID  ASCENDING.
  DELETE GT_MAIN WHERE SYS_STATUS CS 'TECO'.
  DELETE GT_MAIN WHERE SYS_STATUS CS 'CLSD'.
  DELETE GT_MAIN WHERE SYS_STATUS CS 'LKD'.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_OUTPUT .
  DATA : IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.

  DATA:
    LR_TABDESCR TYPE REF TO CL_ABAP_STRUCTDESCR,
    LR_DATA     TYPE REF TO DATA,
    LT_DFIES    TYPE DDFIELDS,
    LS_DFIES    TYPE DFIES,
    LS_FIELDCAT TYPE SLIS_FIELDCAT_ALV,
    LS_VARIANT  TYPE DISVARIANT.

  CLEAR IT_FIELDCAT.
  CREATE DATA LR_DATA LIKE LINE OF GT_MAIN.

*Create Field Cathlog From Internal Table
  LR_TABDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( LR_DATA ).

  LT_DFIES = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LR_TABDESCR ).

  LOOP AT LT_DFIES INTO LS_DFIES.
    CLEAR LS_FIELDCAT.
    MOVE-CORRESPONDING LS_DFIES TO LS_FIELDCAT.
    IF LS_FIELDCAT-FIELDNAME = 'CHK'.
      LS_FIELDCAT-TABNAME   = 'GT_MAIN'.
      LS_FIELDCAT-SELTEXT_L = 'Select'.
      LS_FIELDCAT-CHECKBOX  = 'X'.      " Display this field as a checkbox
      LS_FIELDCAT-EDIT      = 'X'.      " This option ensures that you can
*      LS_FIELDCAT-COL_POS = 1.
    ELSEIF LS_FIELDCAT-FIELDNAME = 'MESSAGE'.

      LS_FIELDCAT-SELTEXT_L = 'Message'.
      LS_FIELDCAT-SELTEXT_M = 'Message'.
      LS_FIELDCAT-SELTEXT_S = 'Message'.
      LS_FIELDCAT-REPTEXT_DDIC = 'Message'.
      LS_FIELDCAT-OUTPUTLEN = 100.

    ELSEIF LS_FIELDCAT-FIELDNAME = 'EQUIPMENT_SUP'.
      LS_FIELDCAT-SELTEXT_L = 'ROOT'.
      LS_FIELDCAT-SELTEXT_M = 'ROOT'.
      LS_FIELDCAT-SELTEXT_S = 'ROOT'.
      LS_FIELDCAT-REPTEXT_DDIC = 'ROOT'.

    ELSEIF LS_FIELDCAT-FIELDNAME = 'WORK_DURATION'.
      LS_FIELDCAT-SELTEXT_L = 'Work Duration'.
      LS_FIELDCAT-SELTEXT_M = 'Work Duration'.
      LS_FIELDCAT-SELTEXT_S = 'Work Dur'.
      LS_FIELDCAT-REPTEXT_DDIC = 'Work Duration'.

    ELSEIF LS_FIELDCAT-FIELDNAME = 'EQUIDESCR'.
      LS_FIELDCAT-SELTEXT_L = 'Equip Description'.
      LS_FIELDCAT-SELTEXT_M = 'Equip Description'.
      LS_FIELDCAT-SELTEXT_S = 'Equip Des'.
      LS_FIELDCAT-REPTEXT_DDIC = 'Equip Description'.

    ELSEIF LS_FIELDCAT-FIELDNAME = 'EQUIDESCR_SUP'.
      LS_FIELDCAT-SELTEXT_L = 'Root Description'.
      LS_FIELDCAT-SELTEXT_M = 'Root Description'.
      LS_FIELDCAT-SELTEXT_S = 'Root Description'.
      LS_FIELDCAT-REPTEXT_DDIC = 'Root Description'.


    ENDIF.
    APPEND LS_FIELDCAT TO IT_FIELDCAT.
    CLEAR: LS_FIELDCAT,LS_DFIES.
  ENDLOOP.
*  DELETE IT_FIELDCAT WHERE FIELDNAME = 'CHK'.
  DELETE IT_FIELDCAT WHERE FIELDNAME = 'PRIORITY'.
  CLEAR LS_FIELDCAT.

  DATA: I_LAYOUT   TYPE SLIS_LAYOUT_ALV.
*Display ALV Report
  I_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
*  I_LAYOUT-EDIT = 'X'.
  .
  CONSTANTS LC_SAVE_ALL TYPE C VALUE 'A'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = SY-REPID
      I_CALLBACK_USER_COMMAND  = 'USER_COMMAND'   "see FORM
      I_GRID_TITLE             = 'Assignment Manager'
      IS_LAYOUT                = I_LAYOUT
      IT_FIELDCAT              = IT_FIELDCAT
      I_CALLBACK_PF_STATUS_SET = 'PFSTAT'
      I_SAVE                   = 'A'
    TABLES
      T_OUTTAB                 = GT_MAIN
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       TOP OF THE PAGE
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM TOP_OF_PAGE.

  DATA: LT_HEADER TYPE SLIS_T_LISTHEADER,
        LS_HEADER TYPE SLIS_LISTHEADER.
  DATA: TEXT TYPE STRING.
* Set Header in the ALV
  LS_HEADER-TYP  = 'H'. "#EC
  LS_HEADER-INFO = 'Assignment Manager'.
  APPEND LS_HEADER TO LT_HEADER.
  CLEAR LS_HEADER.

  CLEAR TEXT.

  LS_HEADER-TYP  = 'S'.
  LS_HEADER-KEY  = 'Report Runs On'.
  LS_HEADER-INFO = SY-DATUM+6(2) && '.' && SY-DATUM+4(2) && '.' && SY-DATUM+0(4).
  APPEND LS_HEADER TO LT_HEADER.
  CLEAR LS_HEADER.


* Set List Comment Output
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = LT_HEADER.

  CLEAR: LS_HEADER, LT_HEADER[].

ENDFORM.

FORM USER_COMMAND USING R_UCOMM LIKE SY-UCOMM
                  RS_SELFIELD TYPE SLIS_SELFIELD.
* Check function code

  RS_SELFIELD-REFRESH = 'X' .
  DATA REF1 TYPE REF TO CL_GUI_ALV_GRID.

  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      E_GRID = REF1.

  CALL METHOD REF1->CHECK_CHANGED_DATA.
  CASE R_UCOMM.
    WHEN '&IC1'.

      READ TABLE GT_MAIN INDEX RS_SELFIELD-TABINDEX INTO DATA(WA).
      IF RS_SELFIELD-FIELDNAME = 'ORDERID'.
        SET PARAMETER ID 'ANR' FIELD WA-ORDERID.
        CALL TRANSACTION 'IW33' AND SKIP FIRST SCREEN.
      ENDIF.
*      DATA:LT_MM_ITEM TYPE STANDARD TABLE OF .


    WHEN 'SAVE'.
      DATA: LS_HEAD_GET TYPE BAPI_ALM_ORDER_HEADER_E.
      DATA: LV_AUFNR TYPE AUFNR.

      LOOP AT GT_MAIN ASSIGNING FIELD-SYMBOL(<LS_DATA>) WHERE CHK = 'X'.
        FREE:LT_METHODS,
            LT_HEADER,
            LT_HEADER_UP,
            LT_HEADER_SRV,
            LT_HEADER_SRV_UP,
            LT_PARTNER,
            LT_OPERATION,
            LT_OPERATION_UP,
            LT_OBJECTLIST,
            LT_RETURN,
            LT_NUMBERS.
        LV_AUFNR = <LS_DATA>-ORDERID.

        CALL FUNCTION 'BAPI_ALM_ORDER_GET_DETAIL'
          EXPORTING
            NUMBER        = LV_AUFNR
          IMPORTING
            ES_HEADER     = LS_HEAD_GET
          TABLES
            ET_PARTNER    = LT_PART_GET
            ET_OPERATIONS = LT_OP_GET
            ET_OLIST      = LT_OBJ_GET
            RETURN        = LT_RETURN.
        READ TABLE LT_RETURN INTO DATA(LS_RETURN)
        WITH KEY TYPE = 'E'.
        IF SY-SUBRC NE 0.
          CALL FUNCTION 'BUFFER_REFRESH_ALL'.

          CALL FUNCTION 'CO_ZF_DATA_RESET_COMPLETE'
            EXPORTING
              I_NO_OCM_RESET = ' '
              I_STATUS_RESET = 'X'.

          REFRESH: LT_RETURN.
          DATA: LV_POSNR TYPE VORNR,
                LV_COUNT TYPE OBJZA..
          MOVE-CORRESPONDING LS_HEAD_GET TO LS_HEADER.


          " IF LS_HEADER-LACD_DATE IS  INITIAL.

          LS_HEADER-LACD_DATE    = P_FDATE.

          LS_HEADER_UP-LACD_DATE    = 'X'.

          "ENDIF.
          APPEND LS_HEADER TO LT_HEADER.
          APPEND LS_HEADER_UP TO LT_HEADER_UP.

          CLEAR LV_COUNT.
*          BREAK-POINT.
          LOOP AT LT_OP_GET INTO DATA(LS_OP_GET).
            MOVE-CORRESPONDING LS_OP_GET TO LS_OPERATION.
            " IF LS_OPERATION-PERS_NO IS INITIAL.
            LS_OPERATION-PERS_NO    = P_PERNR.
            LS_OP_UP-PERS_NO    = 'X'.
            "ENDIF.
            APPEND LS_OPERATION TO LT_OPERATION.
            APPEND LS_OP_UP TO LT_OPERATION_UP.
            LV_COUNT = LV_COUNT + 1.
            LS_METHODS-METHOD = 'CHANGE'.

            CONCATENATE LS_HEAD_GET-ORDERID LS_OPERATION-ACTIVITY INTO LS_METHODS-OBJECTKEY.
            LS_METHODS-OBJECTTYPE = 'OPERATION'.
            LS_METHODS-REFNUMBER = LV_COUNT.  "“‘1’.
            APPEND LS_METHODS TO LT_METHODS.
            CLEAR LS_METHODS.
*      CLEAR: LS_METHODS.
          ENDLOOP.

          LS_METHODS-METHOD = 'CHANGE'.
          LS_METHODS-OBJECTKEY(12) = LS_HEAD_GET-ORDERID.
          LS_METHODS-OBJECTTYPE = 'HEADER'.
          LS_METHODS-REFNUMBER = '000001'.
          APPEND LS_METHODS TO LT_METHODS.
*Methods
          CLEAR LS_METHODS.
          LS_METHODS-METHOD = 'SAVE'.
          LS_METHODS-OBJECTKEY(12) = LS_HEAD_GET-ORDERID.
*      LS_METHODS-OBJECTTYPE = 'HEADER'.
          LS_METHODS-REFNUMBER = '1'.
          APPEND LS_METHODS TO LT_METHODS.
          CLEAR: LS_METHODS.
        ENDIF..

        IF LS_HEAD_GET-NOTIF_NO IS NOT INITIAL.
          SELECT SINGLE * FROM VIQMEL INTO @DATA(LS_NOTIFICATION)
            WHERE QMNUM = @LS_HEAD_GET-NOTIF_NO.
*
          DATA INDUPD     TYPE RIUPD-INDUPD.
          DATA VIQMEL_NEW TYPE VIQMEL.
          DATA VIQMEL_OLD TYPE VIQMEL.
          DATA CHG_DOC    TYPE RIUPD-INDUPD.

          MOVE-CORRESPONDING LS_NOTIFICATION TO VIQMEL_NEW.
          VIQMEL_NEW-LACD_DATE = P_FDATE.
          MOVE-CORRESPONDING LS_NOTIFICATION TO VIQMEL_OLD.

          CALL FUNCTION 'VIQMEL_POST'
            EXPORTING
              INDUPD     = 'U'
              VIQMEL_NEW = VIQMEL_NEW
              VIQMEL_OLD = VIQMEL_OLD
              CHG_DOC    = 'U'.
        ENDIF.
*UPDATE Service Order
        CALL FUNCTION 'BAPI_ALM_ORDER_MAINTAIN'
          EXPORTING
            IV_MMSRV_EXTERNAL_MAINTENACE = 'X'
          TABLES
            IT_METHODS                   = LT_METHODS
            IT_HEADER                    = LT_HEADER
            IT_HEADER_UP                 = LT_HEADER_UP
            IT_HEADER_SRV                = LT_HEADER_SRV
            IT_HEADER_SRV_UP             = LT_HEADER_SRV_UP
            IT_PARTNER                   = LT_PARTNER
            IT_OPERATION                 = LT_OPERATION
            IT_OPERATION_UP              = LT_OPERATION_UP
            IT_OBJECTLIST                = LT_OBJECTLIST
            RETURN                       = LT_RETURN
            ET_NUMBERS                   = LT_NUMBERS.

        READ TABLE LT_RETURN INTO DATA(LS_RET)
        WITH KEY TYPE = 'E'.
        IF SY-SUBRC NE 0.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              WAIT = 'X'.
          DATA:LV_STRING TYPE XSTRING.
          <LS_DATA>-MESSAGE = REDUCE #( INIT TEXT = `` FOR <LINE> IN LT_RETURN
          WHERE ( ID CS 'IW' AND TYPE = 'S' )
          NEXT  TEXT = TEXT && | | && <LINE>-MESSAGE  ).
          IF <LS_DATA>-MESSAGE IS INITIAL.
            <LS_DATA>-MESSAGE = REDUCE #( INIT TEXT = `` FOR <LINE> IN LT_RETURN
                     WHERE (  TYPE = 'E' )
                     NEXT  TEXT = TEXT && | | && <LINE>-MESSAGE  ).
          ENDIF.
          CALL FUNCTION 'DEQUEUE_ALL'
            EXPORTING
              _SYNCHRON = 'X'.
          COMMIT WORK AND WAIT.
        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          CALL FUNCTION 'DEQUEUE_ALL'
            EXPORTING
              _SYNCHRON = 'X'.
          COMMIT WORK AND WAIT.
          "ES_HEADER-MSG_TYPE = 'E'.
          <LS_DATA>-MESSAGE = REDUCE #( INIT TEXT = `` FOR <LINE> IN LT_RETURN
         WHERE ( ID CS 'IW' AND TYPE = 'E' )
         NEXT  TEXT = TEXT && | | && <LINE>-MESSAGE  ).
        ENDIF.
        CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
          IMPORTING
            E_GRID = REF1.

        CALL METHOD REF1->CHECK_CHANGED_DATA.
        FREE:LT_METHODS,
             LT_HEADER,
             LT_HEADER_UP,
             LT_HEADER_SRV,
             LT_HEADER_SRV_UP,
             LT_PARTNER,
             LT_OPERATION,
             LT_OPERATION_UP,
             LT_OBJECTLIST,
             LT_RETURN,
             LT_NUMBERS.
      ENDLOOP.


  ENDCASE.
ENDFORM.

FORM PFSTAT USING P_EXTAB TYPE SLIS_T_EXTAB.

*- Pf status
  SET PF-STATUS 'ZSTANDARD' OF PROGRAM 'ZPM_CRF_UPDATION_FORM'.
  "it is having all you want
ENDFORM.
