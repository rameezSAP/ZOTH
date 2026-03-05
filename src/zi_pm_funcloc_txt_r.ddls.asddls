@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FL Text'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zi_pm_funcloc_txt_r
  as select from iflotx
{
  key cast(tplnr as abap.char( 30 ) ) as Tplnr,
      @Search.defaultSearchElement: true
            @Search.fuzzinessThreshold: 0.8
      @Semantics.text: true
      pltxu as Pltxu
}
where
  spras = 'E'
