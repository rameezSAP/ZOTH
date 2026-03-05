class ZCL_ZC_PM_PRIDE_ROUTE__MPC definition
  public
  inheriting from /IWBEP/CL_MGW_PUSH_ABS_MODEL
  create public .

public section.

  interfaces IF_SADL_GW_MODEL_EXPOSURE_DATA .

  types:
    begin of TS_ZC_PM_PRIDE_ROUTE_DET_MTYPE.
      include type ZC_PM_PRIDE_ROUTE_DET_M.
  types:
      SADL__ETAG type SADL_ETAG,
      A_NOTRUNNING type SADL_GW_DYNAMIC_ACTN_PROPERTY,
      A_RUNNING type SADL_GW_DYNAMIC_ACTN_PROPERTY,
      M_UPDATE type SADL_GW_DYNAMIC_METH_PROPERTY,
      O__DETAILSMP type SADL_GW_DYNAMIC_CBA_PROPERTY,
    end of TS_ZC_PM_PRIDE_ROUTE_DET_MTYPE .
  types:
   TT_ZC_PM_PRIDE_ROUTE_DET_MTYPE type standard table of TS_ZC_PM_PRIDE_ROUTE_DET_MTYPE .
  types:
    begin of TS_ZC_PM_PRIDE_ROUTE_MTYPE.
      include type ZC_PM_PRIDE_ROUTE_M.
  types:
      SADL__ETAG type SADL_ETAG,
      A_COMPLETEROUTE type SADL_GW_DYNAMIC_ACTN_PROPERTY,
      M_UPDATE type SADL_GW_DYNAMIC_METH_PROPERTY,
      O__DETAILS type SADL_GW_DYNAMIC_CBA_PROPERTY,
    end of TS_ZC_PM_PRIDE_ROUTE_MTYPE .
  types:
   TT_ZC_PM_PRIDE_ROUTE_MTYPE type standard table of TS_ZC_PM_PRIDE_ROUTE_MTYPE .
  types:
    begin of TS_ZC_PM_PRIDE_ROUTE_MP_MTYPE.
      include type ZC_PM_PRIDE_ROUTE_MP_M.
  types:
      SADL__ETAG type SADL_ETAG,
      A_INORDER type SADL_GW_DYNAMIC_ACTN_PROPERTY,
      A_OUTOFORDER type SADL_GW_DYNAMIC_ACTN_PROPERTY,
      M_UPDATE type SADL_GW_DYNAMIC_METH_PROPERTY,
    end of TS_ZC_PM_PRIDE_ROUTE_MP_MTYPE .
  types:
   TT_ZC_PM_PRIDE_ROUTE_MP_MTYPE type standard table of TS_ZC_PM_PRIDE_ROUTE_MP_MTYPE .
  types:
    begin of TS_ZC_PM_PRIDE_ROUTE_MP_READTY.
      include type ZC_PM_PRIDE_ROUTE_MP_READ.
  types:
    end of TS_ZC_PM_PRIDE_ROUTE_MP_READTY .
  types:
   TT_ZC_PM_PRIDE_ROUTE_MP_READTY type standard table of TS_ZC_PM_PRIDE_ROUTE_MP_READTY .
  types:
    begin of TS_ZI_PM_EQUIPMENT_TXT_RTYPE.
      include type ZI_PM_EQUIPMENT_TXT_R.
  types:
    end of TS_ZI_PM_EQUIPMENT_TXT_RTYPE .
  types:
   TT_ZI_PM_EQUIPMENT_TXT_RTYPE type standard table of TS_ZI_PM_EQUIPMENT_TXT_RTYPE .
  types:
    begin of TS_ZI_PM_FUNCLOC_TXT_RTYPE.
      include type ZI_PM_FUNCLOC_TXT_R.
  types:
    end of TS_ZI_PM_FUNCLOC_TXT_RTYPE .
  types:
   TT_ZI_PM_FUNCLOC_TXT_RTYPE type standard table of TS_ZI_PM_FUNCLOC_TXT_RTYPE .
  types:
    begin of TS_ZI_PM_LOC_TXT_RTYPE.
      include type ZI_PM_LOC_TXT_R.
  types:
    end of TS_ZI_PM_LOC_TXT_RTYPE .
  types:
   TT_ZI_PM_LOC_TXT_RTYPE type standard table of TS_ZI_PM_LOC_TXT_RTYPE .

  constants GC_ZC_PM_PRIDE_ROUTE_DET_MTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'Zc_PM_PRIDE_ROUTE_DET_MType' ##NO_TEXT.
  constants GC_ZC_PM_PRIDE_ROUTE_MP_MTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'ZC_PM_PRIDE_ROUTE_MP_MType' ##NO_TEXT.
  constants GC_ZC_PM_PRIDE_ROUTE_MP_READTY type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'ZC_PM_PRIDE_ROUTE_MP_READType' ##NO_TEXT.
  constants GC_ZC_PM_PRIDE_ROUTE_MTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'ZC_PM_PRIDE_ROUTE_MType' ##NO_TEXT.
  constants GC_ZI_PM_EQUIPMENT_TXT_RTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'zi_pm_equipment_txt_rType' ##NO_TEXT.
  constants GC_ZI_PM_FUNCLOC_TXT_RTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'zi_pm_funcloc_txt_rType' ##NO_TEXT.
  constants GC_ZI_PM_LOC_TXT_RTYPE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'zi_pm_loc_txt_rType' ##NO_TEXT.

  methods DEFINE
    redefinition .
  methods GET_LAST_MODIFIED
    redefinition .
protected section.
private section.

  methods DEFINE_RDS_4
    raising
      /IWBEP/CX_MGW_MED_EXCEPTION .
  methods GET_LAST_MODIFIED_RDS_4
    returning
      value(RV_LAST_MODIFIED_RDS) type TIMESTAMP .
ENDCLASS.



CLASS ZCL_ZC_PM_PRIDE_ROUTE__MPC IMPLEMENTATION.


  method DEFINE.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS         &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL  &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                   &*
*&                                                                     &*
*&---------------------------------------------------------------------*

model->set_schema_namespace( 'ZC_PM_PRIDE_ROUTE_M_SADL_SRV' ).

define_rds_4( ).
get_last_modified_rds_4( ).
  endmethod.


  method DEFINE_RDS_4.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS          &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL   &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                    &*
*&                                                                     &*
*&---------------------------------------------------------------------*
*   This code is generated for Reference Data Source
*   4
*&---------------------------------------------------------------------*
    TRY.
        if_sadl_gw_model_exposure_data~get_model_exposure( )->expose( model )->expose_vocabulary( vocab_anno_model ).
      CATCH cx_sadl_exposure_error INTO DATA(lx_sadl_exposure_error).
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_med_exception
          EXPORTING
            previous = lx_sadl_exposure_error.
    ENDTRY.
  endmethod.


  method GET_LAST_MODIFIED.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS         &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL  &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                   &*
*&                                                                     &*
*&---------------------------------------------------------------------*


  CONSTANTS: lc_gen_date_time TYPE timestamp VALUE '20241106065025'.                  "#EC NOTEXT
 DATA: lv_rds_last_modified TYPE timestamp .
  rv_last_modified = super->get_last_modified( ).
  IF rv_last_modified LT lc_gen_date_time.
    rv_last_modified = lc_gen_date_time.
  ENDIF.
 lv_rds_last_modified =  GET_LAST_MODIFIED_RDS_4( ).
 IF rv_last_modified LT lv_rds_last_modified.
 rv_last_modified  = lv_rds_last_modified .
 ENDIF .
  endmethod.


  method GET_LAST_MODIFIED_RDS_4.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS          &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL   &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                    &*
*&                                                                     &*
*&---------------------------------------------------------------------*
*   This code is generated for Reference Data Source
*   4
*&---------------------------------------------------------------------*
*    @@TYPE_SWITCH:
    CONSTANTS: co_gen_date_time TYPE timestamp VALUE '20241106065025'.
    TRY.
        rv_last_modified_rds = CAST cl_sadl_gw_model_exposure( if_sadl_gw_model_exposure_data~get_model_exposure( ) )->get_last_modified( ).
      CATCH cx_root ##CATCH_ALL.
        rv_last_modified_rds = co_gen_date_time.
    ENDTRY.
    IF rv_last_modified_rds < co_gen_date_time.
      rv_last_modified_rds = co_gen_date_time.
    ENDIF.
  endmethod.


  method IF_SADL_GW_MODEL_EXPOSURE_DATA~GET_MODEL_EXPOSURE.
    CONSTANTS: co_gen_timestamp TYPE timestamp VALUE '20241106065025'.
    DATA(lv_sadl_xml) =
               |<?xml version="1.0" encoding="utf-16"?>|  &
               |<sadl:definition xmlns:sadl="http://sap.com/sap.nw.f.sadl" syntaxVersion="" >|  &
               | <sadl:dataSource type="CDS" name="ZC_PM_PRIDE_ROUTE_DET_M" binding="ZC_PM_PRIDE_ROUTE_DET_M" />|  &
               | <sadl:dataSource type="CDS" name="ZC_PM_PRIDE_ROUTE_M" binding="ZC_PM_PRIDE_ROUTE_M" />|  &
               | <sadl:dataSource type="CDS" name="ZC_PM_PRIDE_ROUTE_MP_M" binding="ZC_PM_PRIDE_ROUTE_MP_M" />|  &
               | <sadl:dataSource type="CDS" name="ZC_PM_PRIDE_ROUTE_MP_READ" binding="ZC_PM_PRIDE_ROUTE_MP_READ" />|  &
               | <sadl:dataSource type="CDS" name="ZI_PM_EQUIPMENT_TXT_R" binding="ZI_PM_EQUIPMENT_TXT_R" />|  &
               | <sadl:dataSource type="CDS" name="ZI_PM_FUNCLOC_TXT_R" binding="ZI_PM_FUNCLOC_TXT_R" />|  &
               | <sadl:dataSource type="CDS" name="ZI_PM_LOC_TXT_R" binding="ZI_PM_LOC_TXT_R" />|  &
               |<sadl:resultSet>|  &
               |<sadl:structure name="Zc_PM_PRIDE_ROUTE_DET_M" dataSource="ZC_PM_PRIDE_ROUTE_DET_M" maxEditMode="RO" exposure="TRUE" >|  &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               | <sadl:association name="TO_DETAILSMP" binding="_DETAILSMP" target="ZC_PM_PRIDE_ROUTE_MP_M" cardinality="zeroToMany" />|  &
               | <sadl:association name="TO_EQUIPMENTTEXT" binding="_EQUIPMENTTEXT" target="zi_pm_equipment_txt_r" cardinality="zeroToOne" />|  &
               | <sadl:association name="TO_FUNCLOCTEXT" binding="_FUNCLOCTEXT" target="zi_pm_funcloc_txt_r" cardinality="zeroToOne" />|  &
               | <sadl:association name="TO_ROUTES" binding="_ROUTES" target="ZC_PM_PRIDE_ROUTE_M" cardinality="one" />|  &
               |</sadl:structure>|  &
               |<sadl:structure name="ZC_PM_PRIDE_ROUTE_M" dataSource="ZC_PM_PRIDE_ROUTE_M" maxEditMode="RO" exposure="TRUE" >|  &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               | <sadl:association name="TO_DETAILS" binding="_DETAILS" target="Zc_PM_PRIDE_ROUTE_DET_M" cardinality="oneToMany" />|  &
               | <sadl:association name="TO_LOCATION" binding="_LOCATION" target="zi_pm_loc_txt_r" cardinality="zeroToOne" />|  &
               |</sadl:structure>|  &
               |<sadl:structure name="ZC_PM_PRIDE_ROUTE_MP_M" dataSource="ZC_PM_PRIDE_ROUTE_MP_M" maxEditMode="RO" exposure="TRUE" >|  &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               | <sadl:association name="TO_DETAILS" binding="_DETAILS" target="Zc_PM_PRIDE_ROUTE_DET_M" cardinality="one" />|  &
               | <sadl:association name="TO_READINGMP" binding="_READINGMP" target="ZC_PM_PRIDE_ROUTE_MP_READ" cardinality="zeroToMany" />|  &
               | <sadl:association name="TO_ROUTES" binding="_ROUTES" target="ZC_PM_PRIDE_ROUTE_M" cardinality="one" />|  &
               |</sadl:structure>|  &
               |<sadl:structure name="ZC_PM_PRIDE_ROUTE_MP_READ" dataSource="ZC_PM_PRIDE_ROUTE_MP_READ" maxEditMode="RO" exposure="TRUE" >|  &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               |</sadl:structure>|  &
               |<sadl:structure name="zi_pm_equipment_txt_r" dataSource="ZI_PM_EQUIPMENT_TXT_R" maxEditMode="RO" exposure="TRUE" >|  &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               |</sadl:structure>|  &
               |<sadl:structure name="zi_pm_funcloc_txt_r" dataSource="ZI_PM_FUNCLOC_TXT_R" maxEditMode="RO" exposure="TRUE" >|  &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               |</sadl:structure>|  &
               |<sadl:structure name="zi_pm_loc_txt_r" dataSource="ZI_PM_LOC_TXT_R" maxEditMode="RO" exposure="TRUE" >|  &
               | <sadl:query name="SADL_QUERY">|  &
               | </sadl:query>|  &
               |</sadl:structure>|  &
               |</sadl:resultSet>|  &
               |</sadl:definition>| .

   ro_model_exposure = cl_sadl_gw_model_exposure=>get_exposure_xml( iv_uuid      = CONV #( 'ZC_PM_PRIDE_ROUTE_M_SADL' )
                                                                    iv_timestamp = co_gen_timestamp
                                                                    iv_sadl_xml  = lv_sadl_xml ).
  endmethod.
ENDCLASS.
