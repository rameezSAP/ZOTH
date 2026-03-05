@AbapCatalog.sqlViewName: 'ZPM_SUP_EQUIP'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PM:Superior Equipment for Search Help'
define view ZPM_SUPERIOR_EQUIPMENT
  as select from    equz as eq
    left outer join equz as sp on eq.hequi = sp.equnr

{
  @EndUserText.label: 'Superord.Equip.'
  eq.hequi,
  @EndUserText.label: 'Superord.Equip. Tech Id.'
  sp.tidnr as sp_tidnr,
  eq.equnr,
  eq.tidnr,
  eq.datbi

}
where
      eq.hequi <> ''
  and eq.datbi =  '99991231'
  and sp.datbi =  '99991231'
