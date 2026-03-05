@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Pride : Schedule Text'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_PM_SCH_TXT_R as select from dd07t
{
    @ObjectModel.text.element: ['Ddtext']
    key domvalue_l as schedul,
    @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.8
    @Semantics.text: true 
    ddtext as Ddtext
    
    }
where  domname = 'ZPM_PRD_SCHD'
and as4local = 'A'
and ddlanguage = 'E'
