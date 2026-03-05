@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Pride: Route Measuring Points'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_PM_PRIDE_ROUTE_MP_TEMP_M
  as select from zpm_pride_romp_t as detailsMP
  association        to parent ZI_PM_PRIDE_ROUTE_DET_TEMP_M as _details   on  $projection.RouteId   = _details.RouteId
                                                                          and $projection.Equipment = _details.Equipment
  //  and $projection.FuncLoc   = _details.FuncLoc
  association [1..1] to ZI_PM_PRIDE_ROUTE__TEMP_M           as _routes    on  $projection.RouteId = _routes.RouteId
  association [1..1] to imptt                               as _MeasPoint on  $projection.MeasurePoint = _MeasPoint.point
  association [1]    to ztt_pride_status_text               as _status    on  $projection.IsActive = _status.Status
{
  key      route_id                                           as RouteId,
  key      equipment                                          as Equipment,
  key      measure_point                                      as MeasurePoint,
           func_loc                                           as FuncLoc,
           last_change_at                                     as LastChangeAt,
           value                                              as Value,
           uom                                                as Uom,
           c_date                                             as CDate,
           c_time                                             as CTime,
           created_by                                         as CreatedBy,
           active                                             as IsActive,
           low                                                as LowLimit,
           high                                               as HighLimit,
           case when detailsMP.active = 'X' then 3 else 1 end as critical,
           formula_typ,
           formula_main,
           // Association
           _status,
           _details,
           _routes,
           _MeasPoint
}
