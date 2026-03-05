@AbapCatalog.sqlViewName: 'ZPM_NOT_WF_RPT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PM: Notification Workflow Report'
define view ZPM_NOT_WF_RPT_CDS
  as select from    zpm_wf_hst   as _hst

    left outer join ZPM_NOT_CDS  as _not on _hst.qmnum = _not.qmnum

    left outer join ZPM_PLPL_CDS as _PL  on _not.iwerk = _PL.iwerk

    left outer join t024i        as _t24 on  _not.ingrp = _t24.ingrp
                                         and _not.iwerk = _t24.iwerk

    left outer join t353i_t      as _t35 on  _not.ilart = _t35.ilart
                                         and _t35.spras = $session.system_language

    left outer join jsto         as _jst on _not.objnr = _jst.objnr

    left outer join tj30t        as _tj3 on  _jst.stsma  = _tj3.stsma
                                         and _hst.c_stat = _tj3.txt04
                                         and _tj3.spras  = $session.system_language
                                         
                                         
    left outer join viqmel   as VIQMEL on VIQMEL.qmnum = _hst.qmnum
   
                                         
                                         
                                         
{
  _not.qmnum,
  @EndUserText:{ label: 'Created By', quickInfo: 'Created By' }
  VIQMEL.ernam as create_by,
  @EndUserText:{ label: 'WF Level', quickInfo: 'WF Level' }
  _hst.levels,
  @EndUserText:{ label: 'User Notif Status', quickInfo: 'User Notif Status' }
  _hst.c_stat,
  @EndUserText:{ label: 'Status Desc', quickInfo: 'Status Desc' }
  _tj3.txt30,
  @EndUserText:{ label: 'Notification Desc', quickInfo: 'Notification Desc' }
  _not.qmtxt,
  _not.qmart,
      @EndUserText:{ label: 'Priority', quickInfo: 'Priority' }
  _not.priok,
  @EndUserText:{ label: 'Priority', quickInfo: 'Priority' }
  _not.priokx,
  _not.ingrp,
  @EndUserText:{ label: 'Requester Department', quickInfo: 'Requester Department' }
  _t24.innam,
  @EndUserText:{ label: 'W.Flow Note Short Desc', quickInfo: 'W.Flow Note Short Desc' }
  _hst.remarks,
  @EndUserText:{ label: 'Assigned To', quickInfo: 'Assigned To' }
  //_nex.uname,
  _hst.ernam,
  @EndUserText:{ label: 'Assign Date', quickInfo: 'Assign Date' }
  _hst.obj_date,
  @EndUserText:{ label: 'Assign Time', quickInfo: 'Assign Time' }
  _hst.uzeit,
  @EndUserText:{ label: 'ABC Indication', quickInfo: 'ABC Indication' }
  _not.abctx,
  @EndUserText:{ label: 'Equipment', quickInfo: 'Equipment' }
  _not.tidnr,
  @EndUserText:{ label: 'Function Location Desc', quickInfo: 'Function Location Desc' }
  _not.pltxt,
  _not.iwerk,
  @EndUserText:{ label: 'Planning Plant Desc', quickInfo: 'Planning Plant Desc' }
  _PL.name1,
  @EndUserText:{ label: 'Work Center', quickInfo: 'Work Center' }
  _not.arbpl,
  @EndUserText:{ label: 'Activity Type', quickInfo: 'Activity Type' }
  _t35.ilatx,
  @EndUserText:{ label: 'WF Completion', quickInfo: 'WF Completion' }
  _hst.wfstat
}
union all select from zpm_wf_nex   as _NEX
//inner join          zpm_wf_hst   as _HST on _HST.qmnum = _NEX.qmnum

  left outer join     ZPM_NOT_CDS  as _not on _NEX.qmnum = _not.qmnum

  left outer join     ZPM_PLPL_CDS as _PL  on _not.iwerk = _PL.iwerk

  left outer join     t024i        as _t24 on  _not.ingrp = _t24.ingrp
                                           and _not.iwerk = _t24.iwerk

  left outer join     t353i_t      as _t35 on  _not.ilart = _t35.ilart
                                           and _t35.spras = $session.system_language
                                           
 left outer join viqmel   as VIQMEL on VIQMEL.qmnum = _NEX.qmnum
                                            
{
  _not.qmnum,
    @EndUserText:{ label: 'Created By', quickInfo: 'Created By' }
  VIQMEL.ernam as create_by,

  @EndUserText:{ label: 'WF Level', quickInfo: 'WF Level' }
  _NEX.levels,
  @EndUserText:{ label: 'User Notif Status', quickInfo: 'User Notif Status' }
  ''         as c_stat,
  @EndUserText:{ label: 'Status Desc', quickInfo: 'Status Desc' }
  ''         as txt30,
  @EndUserText:{ label: 'Notification Desc', quickInfo: 'Notification Desc' }
  _not.qmtxt,
  _not.qmart,
    @EndUserText:{ label: 'Priority', quickInfo: 'Priority' }
  _not.priok,
  @EndUserText:{ label: 'Priority', quickInfo: 'Priority' }
  _not.priokx,
  _not.ingrp,
  @EndUserText:{ label: 'Requester Department', quickInfo: 'Requester Department' }
  _t24.innam,
  @EndUserText:{ label: 'W.Flow Note Short Desc', quickInfo: 'W.Flow Note Short Desc' }
  ''         as remarks,
  @EndUserText:{ label: 'Assigned To', quickInfo: 'Assigned To' }
  _NEX.uname as ERNAM,
  //'' as ernam,
  @EndUserText:{ label: 'Assign Date/Time', quickInfo: 'Assign Date/Time' }
  _NEX.udate as obj_date,
  @EndUserText:{ label: 'Assign Time', quickInfo: 'Assign Time' }
  _NEX.uzeit,
  @EndUserText:{ label: 'ABC Indication', quickInfo: 'ABC Indication' }
  _not.abctx,
  @EndUserText:{ label: 'Equipment', quickInfo: 'Equipment' }
  _not.tidnr,
  @EndUserText:{ label: 'Function Location Desc', quickInfo: 'Function Location Desc' }
  _not.pltxt,
  _not.iwerk,
  @EndUserText:{ label: 'Planning Plant Desc', quickInfo: 'Planning Plant Desc' }
  _PL.name1,
  @EndUserText:{ label: 'Work Center', quickInfo: 'Work Center' }
  _not.arbpl,
  @EndUserText:{ label: 'Activity Type', quickInfo: 'Activity Type' }
  _t35.ilatx,
  @EndUserText:{ label: 'WF Completion', quickInfo: 'WF Completion' }
  ''         as wfstat
}
