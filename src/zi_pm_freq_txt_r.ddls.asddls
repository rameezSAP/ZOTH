@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Pride : Location Text'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_PM_FREQ_TXT_R as select from dd07t
{
    @ObjectModel.text.element: ['Ddtext']
    key domvalue_l as Frequency,
    @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.8
    @Semantics.text: true 
    ddtext as Ddtext
    
    }
where  domname = 'ZPM_PRD_FREQ'
and as4local = 'A'
and ddlanguage = 'E'
