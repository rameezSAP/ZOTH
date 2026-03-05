@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Equipment Text'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zi_pm_equipment_txt_r
  as select from ZI_PM_EQUIPMENT_LIST_TXT_R

{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
  key Equnr,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Semantics.text: true
      Eqktu,
      @EndUserText.label: 'Functional Location'
      tplnr,
      fltxt,
      sum(MP_Count) as co
}

group by
  Equnr,
  Eqktu,
  tplnr,
  fltxt
