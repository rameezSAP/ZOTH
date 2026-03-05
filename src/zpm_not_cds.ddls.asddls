@AbapCatalog.sqlViewName: 'ZPM_NOT_DAT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PM: Notification Data'
define view ZPM_NOT_CDS
  as select from    viqmel                  as _not

    left outer join t356_t                  as _t356 on  _not.priok  = _t356.priok
                                                     and _t356.spras = $session.system_language
                                                     and _not.artpr  = _t356.artpr

    left outer join t370c_t                 as _t37  on  _not.abckz = _t37.abckz
                                                     and _t37.spras = $session.system_language

    left outer join equz                    as _eq   on  _not.equnr = _eq.equnr
                                                     and _eq.datbi  = '99991231'

    left outer join eqkt                    as _eqk  on  _not.equnr = _eqk.equnr
                                                     and _eqk.spras = $session.system_language

    left outer join ZPM_FUNC_LOC_LEVEL4_CDS as _TPL4 on _TPL4.qmnum = _not.qmnum

    left outer join iflo                    as _if   on  _if.tplnr = _TPL4.TPLNR15
                                                     and _if.spras = $session.system_language

    left outer join t499s                   as _t4   on  _t4.werks = _not.swerk
                                                     and _t4.stand = _not.stort

    left outer join crhd                    as _chd  on  _not.arbpl     = _chd.objid
                                                     and _not.arbplwerk = _chd.werks
                                                     and _chd.endda     = '99991231'
                                                     and _chd.objty     = 'A'
{
  key _not.qmnum,
      _not.qmtxt,
      _not.qmart,
      _not.tplnr,
      _chd.arbpl,
      _not.artpr,
      _not.priok,
      _t356.priokx,
      _not.iwerk,
      _not.ingrp,
      _not.ilart,
      _not.iloan,
      _not.aufnr,
      _t37.abctx, //ABC Indicatior
      _not.equnr,
      _eqk.eqktx,
      _eq.tidnr, //Equipment
      _if.pltxt, //Functionl Location
      _not.proid,
      _not.objnr,
      _not.zqmtxt,
      _not.ernam,
      _not.erdat,
      _not.aedat,
      _t4.ktext //Facility
}
