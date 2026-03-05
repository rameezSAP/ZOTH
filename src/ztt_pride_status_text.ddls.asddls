@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Pride: Text: Status'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ztt_pride_status_text 
as select from dd07t
{
    key domvalue_l as Status,
    @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.8
    @Semantics.text: true
    ddtext as text
    
    }
where  domname = 'ZPM_PRD_STATUS'
and as4local = 'A'
and ddlanguage = 'E'
