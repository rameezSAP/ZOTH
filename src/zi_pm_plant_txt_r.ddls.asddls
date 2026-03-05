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
define view entity ZI_PM_PLANT_TXT_R
  as select from zpm_pride_plants as plant
    join         dd07t            as Location on plant.location = Location.domvalue_l
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Semantics.text: true
      @ObjectModel.text.element: ['PlantDesc']
  key plant.plant         as Plant,
  key plant.location      as Location,
      Location.ddtext     as LocationDesc,
      Location.domvalue_l as DomvalueL,
      plant.plant_desc    as PlantDesc

}
where
      Location.domname    = 'ZPM_LOCATION'
  and Location.as4local   = 'A'
  and Location.ddlanguage = 'E'
