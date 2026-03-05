@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Equipment Text'
@Metadata.ignorePropagatedAnnotations: true
//@Search.searchable: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZICDS_PM_FUNCLOCATION_DET
  as select from imptt  as mp
  //  join equi as equi on equi.equnr = eqkt.equnr
  //  join equz as eq on eq.equnr = eqkt.equnr and eq.datbi = '99991231'
  //  imptt as _MeasPoint on  equi.objnr = _MeasPoint.mpobj
  //  join iloa as il on il.iloan = mp.iloan
  //  join iflot as fl on il.tplnr = fl.tplnr
    join         iflot  as fltxt on mp.mpobj = fltxt.objnr
    join         iflotx as txt   on txt.tplnr = fltxt.tplnr

{

  key   cast(fltxt.tplnr as zpm_prd_tech ) as TechObject,
        txt.pltxu                             as Text,
        @EndUserText.label: 'Functional Location'
        @UI.lineItem: [{label: 'Functional Location' }]

        //        cast(fltxt.tplnr as abap.char( 30 ) ) as tplnr,
        //        ''                                    as Equnr,
        //        @Search.defaultSearchElement: true
        //        @Search.fuzzinessThreshold: 0.8
        //        @Semantics.text: true
        //        ''                                    as Eqktu,
        mp.mpobj,
        mp.mrngu,
        mp.mrmin,
        mp.mrmax,
        mp.decim,
        mp.mrmini,
        mp.mrmaxi,
        //      il.tplnr  as tplnr,
        //        txt.pltxu                             as fltxt,
        mp.point                              as point,
        'FLOCATION'                           as Object
}
where
      mp.mpobj  like 'IF%'
  and txt.spras =    'E'
  and mp.inact != 'X'

union all select from eqkt
  join                equi   as equi       on equi.equnr = eqkt.equnr
  join                equz   as eq         on  eq.equnr = eqkt.equnr
                                           and eq.datbi = '99991231'
  join                imptt  as _MeasPoint on equi.objnr = _MeasPoint.mpobj
  join                iloa   as il         on il.iloan = eq.iloan
//  join iflot as fl on il.tplnr = fl.tplnr
  join                iflotx as fltxt      on il.tplnr = fltxt.tplnr

{
  key  eqkt.equnr       as TechObject,
       eqkt.eqktu       as Text,
       //       cast(il.tplnr as abap.char( 30 ) ) as tplnr,
       _MeasPoint.mpobj,
       _MeasPoint.mrngu,
       _MeasPoint.mrmin,
       _MeasPoint.mrmax,
       _MeasPoint.decim,
       _MeasPoint.mrmini,
       _MeasPoint.mrmaxi,
       //       fltxt.pltxu                        as fltxt,
       _MeasPoint.point as point,
       'EQUIPMENT'      as Object
}
where
      eqkt.spras       =    'E'
  and fltxt.spras      =    'E'
  and _MeasPoint.inact != 'X'
  and _MeasPoint.mpobj like 'IE%'
