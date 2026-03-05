@AbapCatalog.sqlViewName: 'ZPM_CRF_REP_CDS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PM CRF Report'
define view ZPM_CRF_REPORYT_CDS as select from zpm_built as _BU 
inner join rkpf as _RKPF 
on _RKPF.rsnum = _BU.rsnum
left outer join caufv as _ord
on _ord.aufnr = _BU.aufnr
left outer join lfa1 as _lfa1
on _lfa1.lifnr = _BU.lifnr
left outer join makt as _makt
on _makt.matnr = _BU.matnr and _makt.spras = $session.system_language
left outer join viaufkst as _vi
on _vi.aufnr = _BU.aufnr
left outer join prps as _wb
on _vi.pspel = _wb.pspnr

{
   key _BU.rsnum as Rsnum,
   key _BU.aufnr as Aufnr,
   _ord.ktext,
   _RKPF.usnam as Usnam,
   _RKPF.bwart as Bwart,
   _BU.matnr as Matnr,
   _makt.maktx as maktx,
   _BU.unit_cost as UNIT_COST,
   _BU.asbuilt_qty as ASBUILT_QTY,
   _BU.asbuilt_date as ASBUILT_DATE,
   _BU.issued_qty as ISSUED_QTY,
   _BU.return_qty as RETURN_QTY,
   _BU.balance_qty as BALANCE_QTY,
   _BU.asbuilt_cost as ASBUILT_COST,
   _BU.outstanding_qty as OUTSTANDING_QTY,
   _BU.outstanding_cost as OUTSTANDING_COST,
   _BU.uname as Uname,
   _BU.lifnr as Lifnr,
   _lfa1.name1 as name1,
   _BU.cpudt as Cpudt,
   _BU.cputm as Cputm,
   _BU.waers as Waers,
   _vi.eqfnr,
   _vi.proid,
   _wb.post1

}
