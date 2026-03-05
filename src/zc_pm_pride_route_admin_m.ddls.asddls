@EndUserText.label: 'Pride: Projection View Route'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_PM_PRIDE_ROUTE_ADMIN_M
  provider contract transactional_query
  as projection on ZI_PM_PRIDE_ROUTE_M
{

  key RouteId,
      @ObjectModel.text.element: ['LocationText']
      Location,
      SDate,
      EDate,
      STime,
      ETime,
      RouteName,
      _count.pending_count as PendingCount,
      critical,
      _location.Ddtext     as LocationText,
      LastChangeAt,
      Sechedule,
            @ObjectModel.text.element: ['text']
      Active,
      _status.text as text,
      /* Associations */
      _details : redirected to composition child ZC_PM_PRIDE_ROUTE_ADMIN_DET_M,
      _location
}
//where Active = 'C'

