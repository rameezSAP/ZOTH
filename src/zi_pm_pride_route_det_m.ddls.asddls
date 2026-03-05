@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Pride: Route Details'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
//@Search.searchable: true
define view entity ZI_PM_PRIDE_ROUTE_DET_M
  as select from zpm_pride_hier_t
  composition [0..*] of ZI_PM_PRIDE_ROUTE_MP_M  as _detailsMP
  association     to parent ZI_PM_PRIDE_ROUTE_M     as _routes    on  $projection.RouteId = _routes.RouteId
  //                                                                    and $projection.RouteId   = _routes.RouteId
  //                                                                    and $projection.CDate     = _routes.SDate
  //                                                                    and $projection.CTime     = _routes.STime
  //                                                                    and $projection.EDate     = _routes.EDate
  //                                                                    and $projection.ETime     = _routes.ETime
  //                                                                    and $projection.Location  = _routes.Location
  //  association [1] to zi_pm_equipment_txt_r     as _equipmentText on  $projection.Equipment = _equipmentText.Equnr
  association [1] to ZICDS_PM_FUNCLOCATION_VH_2 as _equipmentText on  $projection.Equipment = _equipmentText.TechObject
  association [1] to zi_pm_funcloc_txt_r        as _funcLocText   on  $projection.FuncLoc = _funcLocText.Tplnr
  association [1] to ZC_PM_PRIDE_MP_COUNT       as _count         on
                                                                      //$projection.FuncLoc   = _count.FuncLoc
                                                                      $projection.RouteId   = _count.RouteId
                                                                  and $projection.Equipment = _count.Equipment
  association [1] to ztt_pride_status_text      as _status        on  $projection.isActive = _status.Status
{

  key      route_id                                                                                  as RouteId,
  key      equipment                                                                                 as Equipment,
           func_loc                                                                                  as FuncLoc,
           @Semantics.systemDateTime.localInstanceLastChangedAt: true
           last_change_at                                                                            as LastChangeAt,
           zpm_pride_hier_t.active                                                                   as isActive,
           _count.remaining_count                                                                    as rem_count,
           case when _count.remaining_count = 0 or _count.remaining_count is null  then 3 else 1 end as critical,
           case when active = 'N' then 2 else 5 end                                                  as critical_status,
           '1'                                                                                       as neg,
           '3'                                                                                       as pos,
           formula_typ,
           formula,
           frequency,
           pending_count                                                                             as RemainingCount,
           comments,
           tech_type                                                                                 as TechType,
           for_text                                                                                  as FormulaText,
           pride_desc                                                                                as PrideDescription,
           _routes,
           _status,
           _funcLocText,
           _equipmentText,
           _detailsMP,
           _count

}
