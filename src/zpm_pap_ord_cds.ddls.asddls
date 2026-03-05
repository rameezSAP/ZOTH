@AbapCatalog.sqlViewName: 'ZPM_PAP_CDS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Production and Piggind Order WF Report'
define view ZPM_PAP_ORD_CDS
  as select from    zpm_wf_hst    as _hst

    left outer join ZPM_ORDER_CDS as _ord on _hst.aufnr = _ord.aufnr

  //left outer join ZPM_PAP_ORD_HST_CDS as _hst  on _ord.aufnr = _hst.aufnr
    left outer join ZPM_PLPL_CDS  as _PL  on _ord.iwerk = _PL.iwerk

    left outer join t024i         as _t24 on  _ord.ingpr = _t24.ingrp
                                          and _ord.iwerk = _t24.iwerk

    left outer join t353i_t       as _t35 on  _ord.ilart = _t35.ilart
                                          and _t35.spras = $session.system_language

    left outer join jsto          as _jst on _ord.objnr = _jst.objnr

    left outer join tj30t         as _tj3 on  _jst.stsma  = _tj3.stsma
                                          and _hst.c_stat = _tj3.txt04
                                          and _tj3.spras  = $session.system_language
                                          
     left outer join viaufkst   as VIAUFKST on viaufkst.aufnr = _hst.aufnr                                     

{
  _ord.aufnr,
  @EndUserText:{ label: 'Created By', quickInfo: 'Created By' }
  viaufkst.ernam as create_by,
  @EndUserText:{ label: 'WF Level', quickInfo: 'WF Level' }
  _hst.levels,
  @EndUserText:{ label: 'User Order Status', quickInfo: 'User Order Status' }
  _hst.c_stat,
  @EndUserText:{ label: 'Status Desc', quickInfo: 'Status Desc' }
  _tj3.txt30,
  @EndUserText:{ label: 'Order Desc', quickInfo: 'Order Desc' }
  _ord.ktext,
  _ord.auart,
  @EndUserText:{ label: 'Priority', quickInfo: 'Priority' }
  _ord.priokx,
  _ord.ingpr,
  @EndUserText:{ label: 'Requester Department', quickInfo: 'Requester Department' }
  _t24.innam,
  @EndUserText:{ label: 'Requester Department', quickInfo: 'W.Flow Note Short Desc' }
  _hst.remarks,
  @EndUserText:{ label: 'Assigned To', quickInfo: 'Assigned To' }
  _hst.ernam,
  @EndUserText:{ label: 'Assign Date', quickInfo: 'Assign Date' }
  _hst.obj_date,
  @EndUserText:{ label: 'Assign Time', quickInfo: 'Assign Time' }
  _hst.uzeit,
  @EndUserText:{ label: 'ABC Indication', quickInfo: 'ABC Indication' }
  _ord.abctx,
  @EndUserText:{ label: 'Equipment', quickInfo: 'Equipment' }
  _ord.tidnr,
  @EndUserText:{ label: 'Function Location Desc', quickInfo: 'Function Location Desc' }
  _ord.pltxt,
  _ord.iwerk,
  @EndUserText:{ label: 'Planning Plant Desc', quickInfo: 'Planning Plant Desc' }
  _PL.name1,
  @EndUserText:{ label: 'Work Center', quickInfo: 'Work Center' }
  _ord.arbpl,
  @EndUserText:{ label: 'Activity Type', quickInfo: 'Activity Type' }
  _t35.ilatx,
  @EndUserText:{ label: 'W.Flow Status', quickInfo: 'W.Flow Status' }
  _hst.wfstat
}
union all select from zpm_wf_nex    as _nex

  left outer join     ZPM_ORDER_CDS as _ord on _nex.aufnr = _ord.aufnr

//left outer join ZPM_PAP_ORD_HST_CDS as _hst  on _ord.aufnr = _hst.aufnr
  left outer join     ZPM_PLPL_CDS  as _PL  on _ord.iwerk = _PL.iwerk

  left outer join     t024i         as _t24 on  _ord.ingpr = _t24.ingrp
                                            and _ord.iwerk = _t24.iwerk

  left outer join     t353i_t       as _t35 on  _ord.ilart = _t35.ilart
                                            and _t35.spras = $session.system_language

     left outer join viaufkst   as VIAUFKST on viaufkst.aufnr = _nex.aufnr    

{
  _ord.aufnr,
   @EndUserText:{ label: 'Created By', quickInfo: 'Created By' }
  viaufkst.ernam as create_by,
  @EndUserText:{ label: 'WF Level', quickInfo: 'WF Level' }
  _nex.levels,
  @EndUserText:{ label: 'User Order Status', quickInfo: 'User Order Status' }
  ''         as c_stat,
  @EndUserText:{ label: 'Status Desc', quickInfo: 'Status Desc' }
  ''         as txt30,
  @EndUserText:{ label: 'Order Desc', quickInfo: 'Order Desc' }
  _ord.ktext,
  _ord.auart,
  @EndUserText:{ label: 'Priority', quickInfo: 'Priority' }
  _ord.priokx,
  _ord.ingpr,
  @EndUserText:{ label: 'Requester Department', quickInfo: 'Requester Department' }
  _t24.innam,
  @EndUserText:{ label: 'Requester Department', quickInfo: 'W.Flow Note Short Desc' }
  ''         as remarks,
  @EndUserText:{ label: 'Assigned To', quickInfo: 'Assigned To' }
  _nex.uname as ernam,
  @EndUserText:{ label: 'Assign Date', quickInfo: 'Assign Date' }
  _nex.udate as obj_date,
  @EndUserText:{ label: 'Assign Time', quickInfo: 'Assign Time' }
  _nex.uzeit,
  @EndUserText:{ label: 'ABC Indication', quickInfo: 'ABC Indication' }
  _ord.abctx,
  @EndUserText:{ label: 'Equipment', quickInfo: 'Equipment' }
  _ord.tidnr,
  @EndUserText:{ label: 'Function Location Desc', quickInfo: 'Function Location Desc' }
  _ord.pltxt,
  _ord.iwerk,
  @EndUserText:{ label: 'Planning Plant Desc', quickInfo: 'Planning Plant Desc' }
  _PL.name1,
  @EndUserText:{ label: 'Work Center', quickInfo: 'Work Center' }
  _ord.arbpl,
  @EndUserText:{ label: 'Activity Type', quickInfo: 'Activity Type' }
  _t35.ilatx,
  @EndUserText:{ label: 'W.Flow Status', quickInfo: 'W.Flow Status' }
  ''         as wfstat
}
