@AbapCatalog.sqlViewName: 'ZPM_FLOC_DIST'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Function Location Dist'
define view ZPM_FUNC_LOC_CDS
  as select distinct from iflo as _IFL
{
  'BLOCK'                  as TYPE,
  substring( tplnr, 1, 3 ) as VALUE
}
where
  spras = $session.system_language
union all select distinct from iflo as _IFL
{
  'ZONE'                   as TYPE,
  substring( tplnr, 8, 3 ) as VALUE
}
where
  spras = $session.system_language
