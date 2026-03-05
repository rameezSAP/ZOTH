@EndUserText.label: 'Pride: Projection View Route MP Details'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@OData.publish: true
@Metadata.allowExtensions: true
define view entity ZC_PM_PRIDE_ROUTE_MP_M
  as projection on ZI_PM_PRIDE_ROUTE_MP_M
{
  key     RouteId,
  key     Equipment,
          @ObjectModel.text.element: ['MPDesc']
  key     MeasurePoint,
          //      @ObjectModel.readOnly: true
          @ObjectModel.virtualElement: true
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_PRD_GET_MP_POSITION'
          @ObjectModel.sort.transformedBy: 'ABAP:ZCL_PRD_GET_MP_POSITION'
  virtual MPPosition : abap.int4,
          //      @ObjectModel.readOnly: true
          @ObjectModel.virtualElement: true
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_PRD_GET_MP_POSITION'
//          @ObjectModel.sort.transformedBy: 'ABAP:ZCL_PRD_GET_MP_POSITION'
  virtual CalcReading : imrc_cjump, // abap.int4,
  
          MPPositionChar,
          FuncLoc,
          MPDesc,
          LastChangeAt,
          Value,
          @Consumption.valueHelp: '_VALUECODES'
          value_char,
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
          formula_typ,
          formula_main,
          CodeGroup,
          formulaMP,
          /* Associations */
          _details : redirected to parent Zc_PM_PRIDE_ROUTE_DET_M,
          _routes  : redirected to ZC_PM_PRIDE_ROUTE_M,
          _readingMP,
          _VALUECODES


}
where
  IsActive != 'E'
