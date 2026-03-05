class ZCL_SEND_OO_EMAIL definition
  public
  final
  create public .

public section.

  methods SEND_EMAIL
    importing
      value(LO_DATA_REF) type ref to DATA optional
      value(LT_BODY) type BCSY_TEXT optional
      value(EMAIL) type CHAR50 optional
      value(NAME) type SO_OBJ_DES optional
      value(FCAT) type LVC_T_FCAT optional
      value(SUBJECT) type SO_OBJ_DES optional .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SEND_OO_EMAIL IMPLEMENTATION.


  METHOD SEND_EMAIL.

    "Get Data
    "   SELECT * FROM ZFI_ASSET_DEP_TB INTO TABLE @DATA(LT_DATA).
*    GET REFERENCE OF GT_MAIN INTO DATA(LO_DATA_REF).
    DATA(LV_XSTRING) = NEW ZCL_ITAB_TO_EXCEL( )->ITAB_TO_XSTRING(
                                                 IR_DATA_REF =  LO_DATA_REF
                                                 LT_FCAT = FCAT ).
*--- Email code starts here
    TRY.
        "Create send request
        DATA(LO_SEND_REQUEST) = CL_BCS=>CREATE_PERSISTENT( ).

        "Create mail body
*        DATA(LT_BODY) = VALUE BCSY_TEXT(
*                          ( LINE = 'Dear Recipient,' ) ( )
*                          ( LINE = 'PFA flight details file.' ) ( )
*                          ( LINE = 'Thank You' )
*                        ).

        "Set up document object
        DATA(LO_DOCUMENT) = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
          I_TYPE    = 'RAW'
          I_TEXT    = LT_BODY
          I_SUBJECT = SUBJECT ).

        "Add attachment
        LO_DOCUMENT->ADD_ATTACHMENT(
          I_ATTACHMENT_TYPE    = 'xls'
          I_ATTACHMENT_SIZE    = CONV #( XSTRLEN( LV_XSTRING ) )
          I_ATTACHMENT_SUBJECT = NAME
          I_ATTACHMENT_HEADER  = VALUE #( ( LINE = 'Data.xlsx' ) )
          I_ATT_CONTENT_HEX    = CL_BCS_CONVERT=>XSTRING_TO_SOLIX( LV_XSTRING )
        ).

        "Add document to send request
        LO_SEND_REQUEST->SET_DOCUMENT( LO_DOCUMENT ).

        "Set sender
        LO_SEND_REQUEST->SET_SENDER(
          CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(
*            I_ADDRESS_STRING = CONV #( 'sap_wfrt@uep.com.pk' )  " Domain Change UEG.COM 11082025
            I_ADDRESS_STRING = CONV #( 'sap_wfrt@ueg.com' )
          )
        ).

        "Set Recipient | This method has options to set CC/BCC as well
        LO_SEND_REQUEST->ADD_RECIPIENT(
          I_RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(
                          I_ADDRESS_STRING = CONV #( EMAIL )
                        )
          I_EXPRESS   = ABAP_TRUE ).

        DATA:BCS_MESS TYPE STRING .
        DATA(LV_SENT_TO_ALL) = LO_SEND_REQUEST->SEND( ).
        COMMIT WORK.

      CATCH CX_SEND_REQ_BCS INTO DATA(LX_REQ_BSC).
        BCS_MESS = LX_REQ_BSC->GET_TEXT( ).
      CATCH CX_DOCUMENT_BCS INTO DATA(LX_DOC_BCS).
        BCS_MESS = LX_DOC_BCS->GET_TEXT( ).
      CATCH CX_ADDRESS_BCS  INTO DATA(LX_ADD_BCS).
        BCS_MESS = LX_ADD_BCS->GET_TEXT( ).
    ENDTRY.



  ENDMETHOD.
ENDCLASS.
