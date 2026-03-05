@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Equipment Text'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_PM_EQUIPMENT_LIST_TXT_R
  as select from eqkt
    join         equi   as equi       on equi.equnr = eqkt.equnr
    join         equz   as eq         on  eq.equnr = eqkt.equnr
                                      and eq.datbi = '99991231'
    join         imptt  as _MeasPoint on equi.objnr = _MeasPoint.mpobj
    join         iloa   as il         on il.iloan = eq.iloan
  //  join iflot as fl on il.tplnr = fl.tplnr
    join         iflotx as fltxt      on il.tplnr = fltxt.tplnr

{
  key  eqkt.equnr                         as Equnr,
       @Search.defaultSearchElement: true
       @Search.fuzzinessThreshold: 0.8
       @Semantics.text: true
       eqkt.eqktu                         as Eqktu,
       @EndUserText.label: 'Functional Location'
       @UI.lineItem: [{label: 'Functional Location' }]
       cast(il.tplnr as abap.char( 30 ) ) as tplnr,
       //      il.tplnr  as tplnr,
       fltxt.pltxu                        as fltxt,
       @EndUserText.label: 'Total Count'
       count( distinct(_MeasPoint.point)) as MP_Count,
       'EQUIPMENT'                               as Object
}
where
      eqkt.spras  = 'E'
  and fltxt.spras = 'E'
  and _MeasPoint.inact != 'X'
group by
  eqkt.equnr,
  eqkt.eqktu,
  il.tplnr,
  fltxt.pltxu,
  _MeasPoint.point

//union all select from ZICDS_PM_FUNCLOCATION_VH as FunctionLocation
//{
//
//  key tplnr as Equnr,
//      fltxt as Eqktu,
//      tplnr,
//      fltxt,
//      MP_Count,
//      'FLOCATION'  as Object
//
//}
