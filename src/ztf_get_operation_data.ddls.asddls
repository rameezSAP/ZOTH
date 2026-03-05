@EndUserText.label: 'PM : Get Order System and User Status'
@ClientHandling.type: #CLIENT_DEPENDENT
define table function ZTF_GET_operation_data
  with parameters
    @Environment.systemField: #CLIENT
    clnt :abap.clnt
returns
{
  mandt : s_mandt;
  aufpl : co_aufpl;
  VORNR : vornr;
  pernr : co_pernr;
  rank  : rank;
  LTXA1 : ltxa1;
}
implemented by method
  zcl_amdb_order_dashboard=>get_operation_data;
