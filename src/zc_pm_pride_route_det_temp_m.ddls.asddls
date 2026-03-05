@EndUserText.label: 'Pride: Projection View Route Details'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_PM_PRIDE_ROUTE_DET_TEMP_M

  as projection on ZI_PM_PRIDE_ROUTE_DET_TEMP_M
{
  key RouteId,
      @ObjectModel.text.element: ['EquiText']
  key Equipment,
//      @ObjectModel.text.element: ['FLText']
      FuncLoc,
//      _funcLocText.Pltxu   as FLText,
      pride_desc   as FLText,      
      _equipmentText.Text as EquiText,
      LastChangeAt,
      @ObjectModel.text.element: ['StatusText']
      IsActive,
      _status.text         as StatusText,
      critical,
      formula_typ,
      frequency,
      /* Associations */
      _detailsMP : redirected to composition child ZC_PM_PRIDE_ROUTE_MP_TEMP_M,
      _equipmentText,
      _funcLocText,
      _routes    : redirected to parent ZC_PM_PRIDE_ROUTE__TEMP_M
}
