@AbapCatalog.sqlViewName: 'ZPM_PAP_HST'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Production and Piggind Order WF History'
define view ZPM_PAP_ORD_HST_CDS as select from zpm_wf_hst as _hst
{
  key  _hst.aufnr,
   key   max( _hst.c_stat ) as c_stat,
  key    max( _hst.hst_id ) as HST_ID,
  key    max( _hst.remarks ) as remarks,
  key    max( _hst.wfstat ) as wfstat
}
group by _hst.aufnr
