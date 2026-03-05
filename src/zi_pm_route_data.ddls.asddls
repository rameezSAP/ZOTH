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

define view entity zi_pm_route_data
  as select from zpm_pride_routes as routes
  association [0..*] to zi_pm_route_details as _details on  
  //$projection.RouteName = _details.RouteName
                                                        $projection.RouteId   = _details.RouteId
   //                                                     and $projection.SDate     = _details.CDate
   //                                                     and $projection.STime     = _details.CTime                                                   
  association [1] to zi_pm_loc_txt_r as _location on $projection.Location = _location.Location  
{
  key route_name as RouteName,
  key route_id   as RouteId,
  @ObjectModel.text.association: '_location'

  key location   as Location,
  key s_date     as SDate,
  key e_date     as EDate,
  key s_time     as STime,
  key e_time     as ETime,
      sechedule  as Sechedule,
      active     as Active,
      last_change_at as LastChangeAt,
      _details,
      _location
}
