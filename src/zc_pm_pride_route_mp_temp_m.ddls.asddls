@EndUserText.label: 'Pride: Project View Route MP Temp Det'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_PM_PRIDE_ROUTE_MP_TEMP_M
  as projection on ZI_PM_PRIDE_ROUTE_MP_TEMP_M
{
  key     RouteId,

  key     Equipment,
          @ObjectModel.text.element: ['MPDesc']
  key     MeasurePoint,
          FuncLoc,
          @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.8
          _MeasPoint.pttxt as MPDesc,
          @ObjectModel.virtualElement: true
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MEAS_TEXT_CALC'
          @UI.multiLineText: true
  virtual LongText : abap.string(0),
          LastChangeAt,
          Value,
          Uom,
          CDate,
          CTime,
          CreatedBy,
          @ObjectModel.text.element: ['statusText']
          IsActive,
          critical,
          LowLimit,
          HighLimit,
          formula_typ,
          formula_main,
          _status.text     as statusText,
          /* Associations */
          _details : redirected to parent ZC_PM_PRIDE_ROUTE_DET_TEMP_M,
          _routes  : redirected to ZC_PM_PRIDE_ROUTE__TEMP_M
}
