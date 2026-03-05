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
define view entity ZI_PM_PRIDE_ROUTE_DET_TEMP_M
  as select from zpm_pride_rdet_t
  composition [0..*] of ZI_PM_PRIDE_ROUTE_MP_TEMP_M as _detailsMP
  association     to parent ZI_PM_PRIDE_ROUTE__TEMP_M   as _routes    on $projection.RouteId = _routes.RouteId
  association [1] to ZICDS_PM_FUNCLOCATION_VH_2     as _equipmentText on  $projection.Equipment = _equipmentText.TechObject  
//  association [1] to zi_pm_equipment_txt_r          as _equipmentText on $projection.Equipment = _equipmentText.Equnr
  association [1] to zi_pm_funcloc_txt_r            as _funcLocText   on $projection.FuncLoc = _funcLocText.Tplnr
  association [1] to ztt_pride_status_text          as _status        on $projection.IsActive = _status.Status
{

  key      route_id                                                  as RouteId,
           //  key      cast(func_loc as abap.char( 30 )) as FuncLoc,
  key      equipment                                                 as Equipment,
           func_loc                                                  as FuncLoc,
           @Semantics.systemDateTime.localInstanceLastChangedAt: true
           last_change_at                                            as LastChangeAt,
           zpm_pride_rdet_t.active                                   as IsActive,
           formula_typ,
           frequency,
           case when zpm_pride_rdet_t.active = 'X' then 3 else 1 end as critical,
           tech_type                                                 as TechType,
           pride_desc,

           _routes,
           _funcLocText,
           _equipmentText,
           _status,
           _detailsMP
}
