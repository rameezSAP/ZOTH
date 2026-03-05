@AbapCatalog.sqlViewName: 'ZPM_ASBUILD'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PM:AS build CDS'
define view ZPM_AS_BUILD_CDS as select from resb 
left outer join makt
on resb.matnr = makt.matnr

left outer join aufk as AUFK
on resb.aufnr = aufk.aufnr

 left outer join lfa1 as LFA1
    on aufk.zlifnr = lfa1.lifnr

{

resb.rsnum  as RSNUM,
resb.matnr  as MATNR,
  @EndUserText.label: 'Material Descprition'
max(makt.maktx) as MAKTX,
@EndUserText.label: 'Supplier'
max( aufk.zlifnr ) as LIFNR,
@EndUserText.label: 'Name'
 max( lfa1.name1 ) as NAME1,
resb.aufnr  as aufnr,
resb.werks  as WERKS, //CRF: Duplicate entry in CRF Updation Program 
@EndUserText.label: 'Planned Qty'
sum(bdmng) as PLANNED_QTY
}
where resb.bwart = '261'
group by resb.rsnum,resb.matnr,resb.aufnr,resb.werks
