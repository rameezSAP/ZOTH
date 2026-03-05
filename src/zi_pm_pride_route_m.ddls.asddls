@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Pride: Get Routes Data'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define root view entity ZI_PM_PRIDE_ROUTE_M
  as select from zpm_pride_routes as routes
  composition [1..*] of ZI_PM_PRIDE_ROUTE_DET_M as _details
  
  //-- rameez BOC 26.feb.2026 for Mapping from Email
  association [0..1] to ZI_PM_PRIDE_EMAIL_ROUTE_MAP as _EmailFilter 
    on $projection.RouteRefID = _EmailFilter.RouteRefId
  //-- rameez EOC 26.feb.2026 for Mapping from Email
    
  //  association [0..*] to zi_pm_route_details as _details on  $projection.RouteName = _details.RouteName
  //                                                        and $projection.RouteId   = _details.RouteId
  //                                                        and $projection.SDate     = _details.CDate
  //                                                        and $projection.STime     = _details.CTime
  association [1] to zi_pm_loc_txt_r            as _location on $projection.Location = _location.Location
  association [1] to ZC_PM_PRIDE_ROUTE_COUNT    as _count    on $projection.RouteId = _count.RouteId
  association [1] to ztt_pride_status_text      as _status   on $projection.Active = _status.Status  
{
  key route_id                                                                              as RouteId,
      //@ObjectModel.text.association: '_location'

      location                                                                              as Location,
      plant                                                                                 as Plant,
      route_ref_id                                                                          as RouteRefID,
      s_date                                                                                as SDate,
      e_date                                                                                as EDate,
      s_time                                                                                as STime,
      e_time                                                                                as ETime,
      e_time_even                                                                           as ETimeEven,
      route_name                                                                            as RouteName,
      sechedule                                                                             as Sechedule,
      active                                                                                as Active,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_change_at                                                                        as LastChangeAt,
      routes.pending_count                                                                  as RemainingCount,

      case when _count.pending_count = 0 or _count.pending_count is null  then 3 else 1 end as critical,

      _EmailFilter,
      _details,
      _location,
      _count,
      _status
}
