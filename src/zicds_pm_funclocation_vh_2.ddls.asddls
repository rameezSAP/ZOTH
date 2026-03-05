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

define view entity ZICDS_PM_FUNCLOCATION_VH_2
  as select from ZICDS_PM_FUNCLOCATION_VH as vh
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @EndUserText.label: 'Technical Object'
      @ObjectModel.text.element: ['Text']
     // @UI.lineItem: [{label: 'Technical Object' }]
  key TechObject,
      @EndUserText.label: 'Description'
      @UI.lineItem: [{label: 'Description' }]
       @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
       @Semantics.text: true
      Text,
      @EndUserText.label: 'Object Type'
      //@UI.lineItem: [{label: 'Object Type' }]
      //@Search.defaultSearchElement: true
      //      @Search.fuzzinessThreshold: 0.8
      @UI.selectionField: [{position: 10 }]
      @Consumption.valueHelpDefinition: [{
        entity: {
            name: 'ZICDS_PM_TECHOBJ_VH',
            element: 'TechObj'
        }
      }]
      Object,
      //      @Search.defaultSearchElement: false
      @EndUserText.label: 'Count'
      //@UI.lineItem: [{label: 'Count' }]
      mpoint
}
