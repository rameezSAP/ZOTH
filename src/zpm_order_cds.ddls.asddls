@AbapCatalog.sqlViewName: 'ZPM_ORDER_DAT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PM: Notification Data'
define view ZPM_ORDER_CDS
  as select from    viaufks as _ord

    left outer join t356_t  as _t356 on  _ord.priok  = _t356.priok
                                     and _t356.spras = $session.system_language
                                     and _ord.artpr  = _t356.artpr

    left outer join t370c_t as _t37  on  _ord.abckz = _t37.abckz
                                     and _t37.spras = $session.system_language

    left outer join equz    as _eq   on  _ord.equnr = _eq.equnr
                                     and _eq.datbi  = '99991231'

    left outer join eqkt    as _eqk  on  _ord.equnr = _eqk.equnr
                                     and _eqk.spras = $session.system_language

    left outer join iflo    as _if   on  _ord.tplnr = _if.tplnr
                                     and _if.spras  = $session.system_language

    left outer join t499s   as _t4   on  _t4.werks = _ord.swerk
                                     and _t4.stand = _ord.stort

    left outer join crhd    as _chd  on  _ord.gewrk = _chd.objid
                                     and _ord.werks = _chd.werks
                                     and _chd.objty = 'A'
                                     and _chd.endda = '99991231'
{
  key _ord.aufnr,
      _ord.ktext,
      _ord.auart,
      _ord.tplnr,
      _chd.arbpl,
      _ord.artpr,
      _ord.priok,
      _t356.priokx,
      _ord.iwerk,
      _ord.ingpr,
      _ord.ilart,
      _ord.iloan,
      _ord.qmnum,
      _t37.abctx, //ABC Indicatior
      _ord.equnr,
      _eqk.eqktx,
      _eq.tidnr, //Equipment
      _if.pltxt, //Functionl Location
      _ord.proid,
      _ord.objnr,
      _ord.ernam,
      _ord.erdat,
      _ord.aedat,
      _t4.ktext as facility
}
