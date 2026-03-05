@EndUserText.label: 'Pride: Projection View Route Details'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity Zc_PM_PRIDE_ROUTE_DET_M

  as projection on ZI_PM_PRIDE_ROUTE_DET_M
{
      //  key RouteName,
  key RouteId,
      //  key CDate,
      //  key CTime,
//      @ObjectModel.text.element: ['EquiText']
  key Equipment,
//      @ObjectModel.text.element: ['FLText']
      FuncLoc,
      _funcLocText.Pltxu   as FLText,
      _equipmentText.Text as EquiText,
      //  key MeasurePoint,
      //  key Location,
      //  key EDate,
      //  key ETime,
      //     Value,
      //     Uom,
      LastChangeAt,
      @ObjectModel.text.element: ['text']
      isActive,
      RemainingCount,
      rem_count,
      critical,
      critical_status,
      neg,
      pos,
      formula_typ,
      formula,
      frequency,
      comments,
      _status.text         as text,
      FormulaText,
      PrideDescription,
      /* Associations */
      _equipmentText,
      _funcLocText,
      _routes    : redirected to parent ZC_PM_PRIDE_ROUTE_M,
      _detailsMP : redirected to composition child ZC_PM_PRIDE_ROUTE_MP_M

}

