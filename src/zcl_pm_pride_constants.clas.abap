class ZCL_PM_PRIDE_CONSTANTS definition
  public
  final
  create private .

public section.

  constants C_MESSAGEID type SYMSGID value 'ZPM_PRIDE_MSG' ##NO_TEXT.
  constants C_E type SYMSGTY value 'E' ##NO_TEXT.
  constants C_W type SYMSGTY value 'W' ##NO_TEXT.
  constants C_I type SYMSGTY value 'I' ##NO_TEXT.
  constants C_S type SYMSGTY value 'S' ##NO_TEXT.
  constants C_VALIDITYPERIOD type STRING value 'RENEGOTIATIONVALIDITY' ##NO_TEXT.
  constants C_STARTDATE type STRING value 'RENEGOTIATIONSTARTDATE' ##NO_TEXT.
  constants C_ENDDATE type STRING value 'RENEGOTIATIONENDDATE' ##NO_TEXT.
  constants C_DRAFT type STRING value 'DRAFTADMINISTRATIVEDATAUUID' ##NO_TEXT.
  constants C_MYCID_NEGO type ABP_BEHV_CID value 'My%CID_NEGO' ##NO_TEXT.
  constants C_MYCID_NEGOICOND type ABP_BEHV_CID value 'My%CID_NEGOICOND' ##NO_TEXT.
  constants C_NEW type CHAR1 value 'N' ##NO_TEXT.
  constants C_PROCESSED type CHAR1 value 'P' ##NO_TEXT.
  constants C_ERROR type CHAR1 value 'E' ##NO_TEXT.
  constants C_1 type MMPUR_RENEGO_STATUS value '1' ##NO_TEXT.
  constants C_2 type MMPUR_RENEGO_STATUS value '2' ##NO_TEXT.
  constants C_3 type MMPUR_RENEGO_STATUS value '3' ##NO_TEXT.
  constants C_4 type MMPUR_RENEGO_STATUS value '4' ##NO_TEXT.
  constants C_6 type MMPUR_RENEGO_STATUS value '6' ##NO_TEXT.
  constants C_PRICEVALIDTO type DATUM value '99991231' ##NO_TEXT.
  constants C_PERIV type PERIV value 'V3' ##NO_TEXT.
  constants C_OBJECT type BALOBJ_D value 'MMPUR_RENEG' ##NO_TEXT.
  constants C_SUBOBJECT type BALSUBOBJ value 'CNTRLCONTRACT' ##NO_TEXT.
  constants C_LREV_CONSUMER type FIELDNAME value 'LREV' ##NO_TEXT.
  constants C_LREV_CCTR type FIELDNAME value 'CCTR' ##NO_TEXT.
  constants C_LREV_CCTR_MSG_CONTEXT_TYPE type BALTABNAME value 'CMM_CCTR_LOG_MSG_CONTEXT' ##NO_TEXT.
  constants C_INITIATE type SYST-MSGV1 value 'Initiate Renegotiation' ##NO_TEXT.
  constants C_PUBLISH type SYST-MSGV1 value 'Publish to supplier' ##NO_TEXT.
  constants C_RECEIVED type SYST-MSGV1 value 'Follow-on Document received' ##NO_TEXT.
  constants C_CANCELLED type SYST-MSGV1 value 'Cancelled Renegotiation' ##NO_TEXT.
  constants C_RENEGOID type INRI-OBJECT value 'RENEGOID' ##NO_TEXT.
  PROTECTED SECTION.
private section.
ENDCLASS.



CLASS ZCL_PM_PRIDE_CONSTANTS IMPLEMENTATION.
ENDCLASS.
