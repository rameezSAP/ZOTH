@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Get IMMPT data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zicds_pm_get_mp_read as select from imptt
{
    key point as Point
//    mpobj as Mpobj,
//    psort as Psort,
//    psortr as Psortr,
//    pttxt as Pttxt,
//    mlang as Mlang,
//    kzltx as Kzltx,
//    mptyp as Mptyp,
//    irfmp as Irfmp,
//    erdat as Erdat,
//    ernam as Ernam,
//    aedat as Aedat,
//    aenam as Aenam,
//    begru as Begru,
//    inact as Inact,
//    lvorm as Lvorm,
//    locas as Locas,
//    refmp as Refmp,
//    atinn as Atinn,
//    atinnr as Atinnr,
//    expon as Expon,
//    decim as Decim,
//    desir as Desir,
//    desiri as Desiri,
//    desirr as Desirr,
//    dstxt as Dstxt,
//    dstxtr as Dstxtr,
//    mrmin as Mrmin,
//    mrmini as Mrmini,
//    mrmax as Mrmax,
//    mrmaxi as Mrmaxi,
//    mrngu as Mrngu,
//    indct as Indct,
//    indrv as Indrv,
//    indtr as Indtr,
//    trans as Trans,
//    cjump as Cjump,
//    cjumpi as Cjumpi,
//    pyear as Pyear,
//    pyeari as Pyeari,
//    codct as Codct,
//    codgr as Codgr,
//    codgrr as Codgrr,
//    cdsuf as Cdsuf,
//    modtr as Modtr,
//    indtrr as Indtrr,
//    logsys as Logsys,
//    logsys_chg as LogsysChg
}
//group by point, psort 
