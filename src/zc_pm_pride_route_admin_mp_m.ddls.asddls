@EndUserText.label: 'Pride: Projection View Route MP Details'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_PM_PRIDE_ROUTE_ADMIN_MP_M
  as projection on ZI_PM_PRIDE_ROUTE_MP_M
{
  key RouteId,
  key Equipment,
      @ObjectModel.text.element: ['MPDesc']
  key MeasurePoint,
      FuncLoc,
      _MeasPoint.pttxt as MPDesc,
      LastChangeAt,
      Value,
      Uom,
      CDate,
      CTime,
      CreatedBy,
      @ObjectModel.text.element: ['text']
      IsActive,
      text,
      critical,
      neg,
      pos,
      LowLimit,
      HighLimit,

      /* Associations */
      _details : redirected to parent ZC_PM_PRIDE_ROUTE_ADMIN_DET_M,
      _routes  : redirected to ZC_PM_PRIDE_ROUTE_ADMIN_M,
      _readingMP
      

}
