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
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZICDS_PM_TECHOBJ_VH
 as select from dd07t
{
    @ObjectModel.text.element: ['Ddtext']
    key domvalue_l as TechObj,
    @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.8
    @Semantics.text: true 
    ddtext as Ddtext
    
    }
where  domname = 'ZD_PM_PRD_TECH'
and as4local = 'A'
and ddlanguage = 'E'
//  as select from imptt  as mp
//  //  join equi as equi on equi.equnr = eqkt.equnr
//  //  join equz as eq on eq.equnr = eqkt.equnr and eq.datbi = '99991231'
//  //  imptt as _MeasPoint on  equi.objnr = _MeasPoint.mpobj
//  //  join iloa as il on il.iloan = mp.iloan
//  //  join iflot as fl on il.tplnr = fl.tplnr
//    join         iflot  as fltxt on mp.mpobj = fltxt.objnr
//    join         iflotx as txt   on txt.tplnr = fltxt.tplnr
//
//{
//        @EndUserText.label: 'Functional Location'
//        @UI.lineItem: [{label: 'Functional Location' }]
//  key   cast(fltxt.tplnr as abap.char( 30 ) ) as tplnr,
////        ''                                    as Equnr,
////        @Search.defaultSearchElement: true
////        @Search.fuzzinessThreshold: 0.8
////        @Semantics.text: true
////        ''                                    as Eqktu,
//
//        //      il.tplnr  as tplnr,
//        txt.pltxu                             as fltxt,
//        @EndUserText.label: 'Total Count'
//        count( distinct(mp.point))            as MP_Count
//}
//where
//      mp.mpobj  like 'IF%'
//  and txt.spras =    'E'
//  and mp.inact != 'X'
//group by
//  fltxt.tplnr,
//  txt.pltxu
