@AbapCatalog.sqlViewName: 'ZPM_NOT_HST'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PM: Notification History'
define view ZPM_NOT_HST_CDS as select from zpm_wf_hst as _HST
{
  key   _HST.qmnum,
  key   max( _HST.c_stat )  as c_stat,
  key   max( _HST.hst_id )  as hst_id,
  key   max( _HST.remarks ) as remarks,
  key   max( _HST.wfstat )  as wfstat
}
group by _HST.qmnum
