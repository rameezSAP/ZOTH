@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Pride : Total Pending Route Count'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_PM_PRIDE_ROUTE_COUNT
  as select from zpm_pride_hier_t  as det
    join         ZC_PM_PRIDE_MP_COUNT as mp on  mp.Equipment = det.equipment
                                         and mp.RouteId  = det.route_id
                                       //  and det.active   = 'X'

{
  key  mp.RouteId,
      sum(mp.remaining_count) as pending_count
}
where
     mp.remaining_count > 0
  or mp.remaining_count is not null
group by
  mp.RouteId
