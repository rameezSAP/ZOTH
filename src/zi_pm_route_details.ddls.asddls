@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Pride: Route Details'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Search.searchable: true
define view entity zi_pm_route_details
  as select from zpm_pride_hier_t
  association [1] to zi_pm_equipment_txt_r as _equipmentText on $projection.Equipment = _equipmentText.Equnr
  association [1] to zi_pm_funcloc_txt_r   as _funcLocText   on $projection.FuncLoc = _funcLocText.Tplnr

{
      //    @UI.lineItem: [{position: 10 }]
 // key route_name                        as RouteName,
      //    @UI.lineItem: [{position: 20 }]
  key route_id                          as RouteId,
      //    @UI.lineItem: [{position: 30 }]
 // key c_date                            as CDate,
      //    @UI.lineItem: [{position: 40 }]
 // key c_time                            as CTime,
      @ObjectModel.text.association: '_funcLocText'
      @UI.lineItem: [{position: 50 }]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
  key cast(func_loc as abap.char( 30 )) as FuncLoc,
      @ObjectModel.text.association: '_equipmentText'
      @UI.lineItem: [{position: 60 }]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
  key equipment                         as Equipment,
      @UI.lineItem: [{position: 70 }]
//  key measure_point                     as MeasurePoint,
//  route_name                        as RouteName,
 //     @UI.lineItem: [{position: 80 }]
//      value                             as Value,
//      @UI.lineItem: [{position: 90 }]
//      uom                               as Uom,
      @Search.defaultSearchElement: true
      _funcLocText,
      @Search.defaultSearchElement: true
      _equipmentText

}
