@AbapCatalog.sqlViewName: 'ZPM_SYSTEM_STAT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PM:Job Card System Status'
define view ZPM_JOB_CARD_SYS_STATUS_CDS as select from aufk as A
left outer join jcds as j
on A.objnr = j.objnr

left outer join tj02t as T
on j.stat = T.istat
and T.spras = $session.system_language
 {
    key A.aufnr,
    key j.udate,
    key j.utime,
      j.stat as stat,
       A.objnr,
      T.txt04,
      T.txt30   
}

where j.inact <> 'X'
and j.stat like 'I%'

