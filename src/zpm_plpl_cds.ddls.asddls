@AbapCatalog.sqlViewName: 'ZPM_PLPL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PM: Planning Plant view'
define view ZPM_PLPL_CDS as select distinct from t001w as _T1

left outer join t001w as _t2
on _T1.iwerk = _t2.werks
{
    _T1.iwerk,
    _t2.name1
}
where _T1.iwerk <> ''
and _T1.iwerk <> '1710'
