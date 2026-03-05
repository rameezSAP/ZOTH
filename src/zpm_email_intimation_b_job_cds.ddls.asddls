@AbapCatalog.sqlViewName: 'ZPM_E_INT_CDS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'PM : Email INTIMATION BACKGROUND JOB CDS'
define view ZPM_Email_INTIMATION_B_JOB_CDS  as select from viaufkst as _hd

left outer join equz as _EQ
on _EQ.equnr = _hd.equnr
 {
    _hd.gltrp,
    _hd.iwerk,
    _hd.aufnr,
   @EndUserText.label: 'Notification Number'
    _hd.qmnum ,
   @EndUserText.label: 'Work Center'
    _hd.vaplz as work_center,
    _hd.warpl as PM_NO,
   @EndUserText.label: 'Technical ID'
    _EQ.tidnr
    }

where _hd.erdat = $session.system_date 
 and _hd.qmnum is initial 

union 
select from viqmel as _VQ

left outer join equz as _EQ
on _EQ.equnr = _VQ.equnr

{
    '' as gltrp,
    _VQ.iwerk,
    '' as aufnr,
   @EndUserText.label: 'Notification Number'
    _VQ.qmnum ,
   @EndUserText.label: 'Work Center'
    _VQ.arbpl as work_center,
    _VQ.warpl as PM_NO,
   @EndUserText.label: 'Technical ID'
    _EQ.tidnr
} where _VQ.erdat =  $session.system_date 
  and _VQ.aufnr is initial 














