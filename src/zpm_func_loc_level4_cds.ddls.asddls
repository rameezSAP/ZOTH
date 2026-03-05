@AbapCatalog.sqlViewName: 'ZPM_FLOC_L4_DIST'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Function Location Level 4'
define view ZPM_FUNC_LOC_LEVEL4_CDS
  as select from viqmel
{
  key qmnum,
      SUBSTRING( tplnr, 1, 15 ) as TPLNR15
}
