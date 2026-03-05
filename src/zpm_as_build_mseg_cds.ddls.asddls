@AbapCatalog.sqlViewName: 'ZPM_ASBUILD_MSEG'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PM:AS build MSGES CDS'
define view ZPM_AS_BUILD_MSEG_CDS as select from matdoc  as M
{
M.rsnum,
M.matnr,
M.aufnr,
M.charg,
sum( M.menge ) as ISSUED_QTY
    
}
where  M.bwart = '261'
and

M.record_type = 'MDOC' and
         M.cancelled         <> 'X'
 and    M.reversal_movement <> 'X'
  or(
         M.sjahr             =  '0000'
    and(
         M.mjahr             =  '0000'
      or M.mjahr             is null
    )
    and(
         M.sjahr             =  '0000'
      or M.sjahr             is null
    )
  )

group by M.rsnum,M.matnr,M.aufnr,M.charg
