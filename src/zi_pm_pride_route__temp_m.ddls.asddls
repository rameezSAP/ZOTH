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

define root view entity ZI_PM_PRIDE_ROUTE__TEMP_M
  as select from zpm_pride_rout_t as routes
  composition [1..*] of ZI_PM_PRIDE_ROUTE_DET_TEMP_M as _details
  association [1] to zi_pm_loc_txt_r                 as _location on $projection.Location = _location.Location
  association [1] to ztt_pride_status_text           as _status   on $projection.Active = _status.Status
  association [1] to ZI_PM_SCH_TXT_R                 as _sched on $projection.RouteSchedule = _sched.schedul
{
  key route_id       as RouteId,
      location       as Location,
      plant          as Plant,
      s_date         as SDate,
      e_date         as EDate,
      s_time         as STime,
      e_time         as ETime,
      e_time_even    as ETimeEven,
      route_name     as RouteName,
      active         as Active,
      3              as pos,
      1              as neg,
      case when active = 'S' then 3 else 1 end  as  critical,
      sechedule      as RouteSchedule,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_change_at as LastChangeAt,
      _details,
      _location,
      _status,
      _sched
}
