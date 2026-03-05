@EndUserText.label: 'Pride : Projection View Route'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_PM_PRIDE_ROUTE__TEMP_M
  provider contract transactional_query
  as projection on ZI_PM_PRIDE_ROUTE__TEMP_M
{
  key RouteId,
      @ObjectModel.text.element: ['LocationText']
      Location,
      Plant,      
      SDate,
      EDate,
      STime,
      ETime,
      ETimeEven,
      RouteName,
      @ObjectModel.text.element: ['text']
      Active,
      _location.Ddtext as LocationText,
      LastChangeAt,
      neg,
      pos,
      critical,
      _sched.Ddtext    as ScheduleText,
      @ObjectModel.text.element: ['ScheduleText']
      RouteSchedule,
      _status.text     as text,

      /* Associations */
      _details : redirected to composition child ZC_PM_PRIDE_ROUTE_DET_TEMP_M,
      _location
}
