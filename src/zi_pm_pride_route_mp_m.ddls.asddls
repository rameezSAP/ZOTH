@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Pride: Route Measuring Points'
@Metadata.ignorePropagatedAnnotations: true
//@OData.publish: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_PM_PRIDE_ROUTE_MP_M
  as select from zpm_pride_hier_m as detailsMP
  association [0..*] to ZC_PM_PRIDE_ROUTE_MP_READ      as _readingMP  on  _readingMP.POINT = $projection.MeasurePoint
  association        to parent ZI_PM_PRIDE_ROUTE_DET_M as _details    on  $projection.RouteId   = _details.RouteId
                                                                      and $projection.Equipment = _details.Equipment
  // and $projection.FuncLoc   = _details.FuncLoc
  association [1..1] to ZI_PM_PRIDE_ROUTE_M            as _routes     on  $projection.RouteId = _routes.RouteId
  association [1..1] to imptt                          as _MeasPoint  on  $projection.MeasurePoint = _MeasPoint.point
  association [0..*] to ZICDS_GET_CODEGRP_VH           as _VALUECODES on  $projection.CodeGroup = _VALUECODES.Codegruppe
  association [1]    to ztt_pride_status_text          as _status     on  $projection.IsActive = _status.Status

{
  key      route_id                                                                                          as RouteId,
  key      equipment                                                                                         as Equipment,
  key      measure_point                                                                                     as MeasurePoint,
           cast( 0 as abap.int4)                                                                             as MPPosition,
           _MeasPoint.psort                                                                                  as MPPositionChar,
           _MeasPoint.pttxt                                                                                  as MPDesc,
           func_loc                                                                                          as FuncLoc,
           @Semantics.systemDateTime.localInstanceLastChangedAt: true
           last_change_at                                                                                    as LastChangeAt,
           value                                                                                             as Value,
           value_char                                                                                        as value_char,
           uom                                                                                               as Uom, 
           c_date                                                                                            as CDate,
           c_time                                                                                            as CTime,
           @Semantics.user.lastChangedBy: true
           created_by                                                                                        as CreatedBy,
           low                                                                                               as LowLimit,
           high                                                                                              as HighLimit,
           @ObjectModel.text.element: ['text']
           detailsMP.active                                                                                  as IsActive,
           case when detailsMP.active = 'X' then 3
                when detailsMP.active = 'O' then 1
                when detailsMP.active = 'N' then 4
                 else 1 end                                                                                  as critical,
           '1'                                                                                               as neg,
           '3'                                                                                               as pos,
           formula_typ,
           formula_main,
           _status.text                                                                                      as text,
           @Consumption.valueHelp: '_ValueCodes'
           case when _MeasPoint.codgr is null or _MeasPoint.codgr = '' then 'NULL' else _MeasPoint.codgr end as CodeGroup,
           formula_mp                                                                                        as formulaMP,
           measuring_doc,
           p2_update,
           p2_ref_id,
           // Association
           _details,
           _routes,
           _MeasPoint,
           _readingMP,
           _VALUECODES

}
