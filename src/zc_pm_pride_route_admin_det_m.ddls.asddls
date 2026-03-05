@EndUserText.label: 'Pride: Projection View Route Details'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_PM_PRIDE_ROUTE_ADMIN_DET_M

  as projection on ZI_PM_PRIDE_ROUTE_DET_M
{
  key RouteId,
      @ObjectModel.text.element: ['EquiText']
  key Equipment,
      @ObjectModel.text.element: ['FLText']
      FuncLoc,
      _funcLocText.Pltxu   as FLText,
      _equipmentText.Text as EquiText,
      LastChangeAt,
      @ObjectModel.text.element: ['text']
      isActive,
      rem_count,
      critical,
      critical_status,
      neg,
      pos,
     formula_typ,
     frequency,
      _status.text         as text,
      /* Associations */
      _equipmentText,
      _funcLocText,
      _routes    : redirected to parent ZC_PM_PRIDE_ROUTE_ADMIN_M,
      _detailsMP : redirected to composition child ZC_PM_PRIDE_ROUTE_ADMIN_MP_M

}
