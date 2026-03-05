*"* use this source file for your ABAP unit test classes


CLASS ltc_Mmpur_Renegttn_Constants DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
.
*?﻿<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
*?<asx:values>
*?<TESTCLASS_OPTIONS>
*?<TEST_CLASS>ltc_Mmpur_Renegttn_Constants
*?</TEST_CLASS>
*?<TEST_MEMBER>f_Cut
*?</TEST_MEMBER>
*?<OBJECT_UNDER_TEST>CL_MMPUR_RENEGTTN_CONSTANTS
*?</OBJECT_UNDER_TEST>
*?<OBJECT_IS_LOCAL/>
*?<GENERATE_FIXTURE/>
*?<GENERATE_CLASS_FIXTURE/>
*?<GENERATE_INVOCATION/>
*?<GENERATE_ASSERT_EQUAL>X
*?</GENERATE_ASSERT_EQUAL>
*?</TESTCLASS_OPTIONS>
*?</asx:values>
*?</asx:abap>
  PRIVATE SECTION.
    DATA:
      f_Cut TYPE REF TO if_mmpur_renegttnlist_constant.  "class under test
    METHODS: setup.
    METHODS: get_Instance FOR TESTING.
    METHODS: get_Instance_1 FOR TESTING.
ENDCLASS.       "ltc_Mmpur_Renegttn_Constants


CLASS ltc_Mmpur_Renegttn_Constants IMPLEMENTATION.
  METHOD setup.
    f_cut = cl_Mmpur_Renegttn_Constants=>if_mmpur_renegttnlist_constant~get_instance( ).
  ENDMETHOD.
  METHOD get_Instance.


    cl_Abap_Unit_Assert=>assert_bound(
      EXPORTING
        act              = f_cut                                      " Reference variable to be checked
        msg              = 'Initialization failed'                                      " Description
*       level            = if_abap_unit_constant=>severity-medium " Severity
*       quit             = if_abap_unit_constant=>quit-test       " Alter control flow
      RECEIVING
        assertion_failed = DATA(lv_bool)                                       " Condition was not met
    ).
  ENDMETHOD.

  METHOD get_Instance_1.

    cl_Abap_Unit_Assert=>assert_bound(
      EXPORTING
        act              = f_cut                                      " Reference variable to be checked
        msg              = 'Initialization failed'                                      " Description
*       level            = if_abap_unit_constant=>severity-medium " Severity
*       quit             = if_abap_unit_constant=>quit-test       " Alter control flow
      RECEIVING
        assertion_failed = DATA(lv_bool)                                       " Condition was not met
    ).
  ENDMETHOD.
ENDCLASS.
