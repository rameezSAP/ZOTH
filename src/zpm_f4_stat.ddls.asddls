@AbapCatalog.sqlViewName: 'ZPM_F4_STAT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PM: User Status F4'
define view ZPM_F4_STAT_CDS as select from tj30t as _tj3
    {
    key _tj3.stsma,
    _tj3.estat,
    _tj3.spras,
    _tj3.txt04,
    _tj3.txt30
    }
    where _tj3.stsma = 'PMORD-PP'
    and _tj3.spras = $session.system_language
