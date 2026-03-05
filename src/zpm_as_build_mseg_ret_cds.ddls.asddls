@AbapCatalog.sqlViewName: 'ZPM_ASBULD_R_MSG'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PM:AS build MSGES Rteurn CDS'
define view ZPM_AS_BUILD_MSEG_RET_CDS as select from nsdm_v_mseg  as M

{
M.rsnum,
M.matnr,
M.aufnr,
sum( M.menge ) as RETURN_QTY
    
}
where  M.bwart = '262'
and M.smbln = ''
group by M.rsnum,M.matnr,M.aufnr
