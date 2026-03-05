@AbapCatalog.sqlViewName: 'ZPM_AS_PM_BUILT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PM:AS build PM_BUILT'
define view ZPM_AS_BUILD_PM_BUILT_CDS as select from zpm_built {
    
rsnum,
matnr,
aufnr,
sum( asbuilt_qty ) as ASBUILT_QTY,
max( asbuilt_date ) as ASBUILT_DATE,
max( uname ) as UNAME,
max( cpudt ) as CPUDT  ,
max( cputm ) as CPUTM  
}
group by rsnum,matnr,aufnr
