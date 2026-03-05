@EndUserText.label: 'Get Equipment Root'
//@ClientDependent: true

define table function ztf_get_euip_root
  //  with parameters
  // @Environment.systemField: #CLIENT
  //            clnt:abap.clnt
  //            equnr : equnr
  //    @Environment.systemField: #CLIENT
  //    p_SAPClient : vdm_v_sap_client
returns
{
  //   @Environment.systemField: #CLIENT
  //    p_SAPClient : vdm_v_sap_client
  client    : s_mandt;
  Equipment : equnr;
  Root      : equnr;
  text      : abap.char( 100 );
  Rank      : equnr;
}
implemented by method
  zcl_amdb_order_dashboard=>get_equi_root;
