@EndUserText.label: 'PM : Get Order System and User Status'
@ClientHandling.type: #CLIENT_DEPENDENT
define table function ztf_get_order_statuse
  with parameters
    @Environment.systemField: #CLIENT
    clnt :abap.clnt
returns
{
  mandt          : s_mandt;
  objnr          : j_objnr;
  status_profile : j_stsma;
  system_status  : char60;
  user_status    : char60;
  new_status     : j_txt04;
}
implemented by method
  zcl_amdb_order_dashboard=>get_status_text;
