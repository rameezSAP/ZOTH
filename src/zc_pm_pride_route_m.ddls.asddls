@EndUserText.label: 'Pride: Projection View Route'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_PM_PRIDE_ROUTE_M
  provider contract transactional_query
  as projection on ZI_PM_PRIDE_ROUTE_M
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
      _count.pending_count as PendingCount,
      RemainingCount,
      critical,
      _location.Ddtext     as LocationText,
      LastChangeAt,
      Sechedule,
            @ObjectModel.text.element: ['text']
      Active,
      _status.text as text,
      
      //-- rameez BOC 26.feb.2026
      RouteRefID,
      _EmailFilter.Email as Email,
      _EmailFilter,
      //-- rameez EOC 26.feb.2026
      
      /* Associations */
      _details : redirected to composition child Zc_PM_PRIDE_ROUTE_DET_M,
      _location
}
where Active = 'X' or Active = 'I'

