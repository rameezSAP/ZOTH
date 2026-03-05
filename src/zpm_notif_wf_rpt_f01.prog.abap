*&---------------------------------------------------------------------*
*& Include          ZPM_NOTIF_WF_RPT_F01
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



  DATA: LO_ADDITIONAL_CONDITION TYPE REF TO IF_SALV_IDA_CONDITION,
        LO_CONDITION_FACTORY    TYPE REF TO IF_SALV_IDA_CONDITION_FACTORY,
        LS_PERSISTENCE_KEY      TYPE IF_SALV_GUI_LAYOUT_PERSISTENCE=>YS_PERSISTENCE_KEY.

*  BOC GET CDS VIEW
  O_DATA = CL_SALV_GUI_TABLE_IDA=>CREATE_FOR_CDS_VIEW(
    IV_CDS_VIEW_NAME = 'ZPM_NOT_WF_RPT_CDS'
  ).

**  SET View PARAMETERS ( Defined in CDS View )
*  O_DATA->SET_VIEW_PARAMETERS(
*    IT_PARAMETERS = VALUE #(
*                      ( NAME = 'P_DATE' VALUE = P_DATE )
*                    )
*  ).
  BREAK AC_ADNAN.
**for delete initial value
*  FREE S_TOTAL.
*  S_TOTAL-SIGN = 'E'.
*  S_TOTAL-OPTION = 'EQ'.
*  S_TOTAL-HIGH = '0.00'.
*  S_TOTAL-LOW = '0.00'.
*  APPEND S_TOTAL.

*  Applying FILTERS TO COLUMNS
  DATA(O_SEL) = NEW CL_SALV_RANGE_TAB_COLLECTOR( ).
  O_SEL->ADD_RANGES_FOR_NAME( IV_NAME = 'QMART' IT_RANGES = S_QMART[] ).
  O_SEL->ADD_RANGES_FOR_NAME( IV_NAME = 'CREATE_BY' IT_RANGES = S_CRT_BY[] ).
  O_SEL->ADD_RANGES_FOR_NAME( IV_NAME = 'C_STAT' IT_RANGES = S_USTAT[] ).
  O_SEL->ADD_RANGES_FOR_NAME( IV_NAME = 'IWERK' IT_RANGES = S_IWERK[] ).
  O_SEL->ADD_RANGES_FOR_NAME( IV_NAME = 'INGRP' IT_RANGES = S_INGRP[] ).
  O_SEL->ADD_RANGES_FOR_NAME( IV_NAME = 'ERNAM' IT_RANGES = S_UNAME[] ).
  O_SEL->ADD_RANGES_FOR_NAME( IV_NAME = 'OBJ_DATE' IT_RANGES = S_UDATE[] ).
  O_SEL->ADD_RANGES_FOR_NAME( IV_NAME = 'QMNUM' IT_RANGES = S_QMNUM[] ).
  O_SEL->ADD_RANGES_FOR_NAME( IV_NAME = 'PRIOK' IT_RANGES = S_PRIOK[] ).
*for delete initial value
*  O_SEL->ADD_RANGES_FOR_NAME( IV_NAME = 'TOTAL' IT_RANGES = S_TOTAL[] ).


*GET Name and RANGES
  O_SEL->GET_COLLECTED_RANGES(
    IMPORTING
      ET_NAMED_RANGES = DATA(LT_DEFINE_RAGES)
  ).

*  SET Selected Range To ALV
  O_DATA->SET_SELECT_OPTIONS( IT_RANGES = LT_DEFINE_RAGES ).

*GET Field Catalog reference
  DATA(LO_FLDCATLOG) = O_DATA->FIELD_CATALOG( ).

*GET ALL columns of ALV
  LO_FLDCATLOG->GET_ALL_FIELDS( IMPORTING ETS_FIELD_NAMES = DATA(LTS_FIELD_NAMES) ).

  DELETE LTS_FIELD_NAMES WHERE TABLE_LINE = 'VTWEG'.
  LO_FLDCATLOG->SET_AVAILABLE_FIELDS( LTS_FIELD_NAMES ).

*   add a toolbar button (plus a separator)
  O_DATA->TOOLBAR( )->ADD_BUTTON(
    EXPORTING IV_FCODE      = 'DETAIL_SCREEN'
              IV_ICON       = ICON_REFRESH
              IV_TEXT       = 'Refresh'(001)
              IV_QUICKINFO  = 'Refresh Workflow Details'(002)
              IV_BEFORE_STANDARD_FUNCTIONS = ABAP_TRUE  "= in the left of std toolbar functions
              ).

  LO_EVENT_HANDLER = NEW #( O_DATA ).
*   assign event handler for toolbar function
  SET HANDLER LO_EVENT_HANDLER->TOOLBAR_FUNCTION_SELECTED FOR O_DATA->TOOLBAR( ).


*For Layout
  DATA(L_GLOBAL_SAVE_ALLOWED) = ABAP_TRUE.
  DATA(L_USER_SPECIFIC_SAVE_ALLOWED) = ABAP_TRUE.
  LS_PERSISTENCE_KEY-REPORT_NAME = SY-REPID.
  O_DATA->LAYOUT_PERSISTENCE( )->SET_PERSISTENCE_OPTIONS(
  EXPORTING
    IS_PERSISTENCE_KEY           = LS_PERSISTENCE_KEY
    I_GLOBAL_SAVE_ALLOWED        = L_GLOBAL_SAVE_ALLOWED
    I_USER_SPECIFIC_SAVE_ALLOWED = L_USER_SPECIFIC_SAVE_ALLOWED
  ).

***  Allow Text Search IN GENERAL
**  O_DATA->STANDARD_FUNCTIONS( )->SET_TEXT_SEARCH_ACTIVE( ABAP_TRUE ).
***  "Release Text Search on textual columns
**  O_DATA->FIELD_CATALOG( )->ENABLE_TEXT_SEARCH( 'KUNNR' ).

*  Display ALV IDA
  O_DATA->FULLSCREEN( )->DISPLAY( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_USER_STATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4_USER_STATUS .
  TYPES: BEGIN OF TY_USTAT,
           TXT04 TYPE J_TXT04,
         END OF TY_USTAT.

  DATA: RETURN_TAB  TYPE STANDARD TABLE OF DDSHRETVAL WITH HEADER LINE,
        LT_F4_USTAT TYPE STANDARD TABLE OF TY_USTAT,
        LS_F4_USTAT LIKE LINE OF LT_F4_USTAT.
  BREAK AC_ADNAN.
  FREE: LT_F4_USTAT, LS_F4_USTAT.
  SELECT LSTAT AS TXT04 FROM ZPM_SET_V1 INTO TABLE LT_F4_USTAT
    WHERE QMART EQ S_QMART-LOW.
  SORT LT_F4_USTAT BY TXT04.
  DELETE ADJACENT DUPLICATES FROM LT_F4_USTAT COMPARING TXT04.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     DDIC_STRUCTURE  = ' '
      RETFIELD        = 'TXT04'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = LT_F4_USTAT
      RETURN_TAB      = RETURN_TAB
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2.
  IF SY-SUBRC EQ 0.
    READ TABLE RETURN_TAB INDEX 1.
    IF SY-SUBRC EQ 0.
      S_USTAT-LOW = RETURN_TAB-FIELDVAL.
    ENDIF.
  ENDIF.


ENDFORM.
