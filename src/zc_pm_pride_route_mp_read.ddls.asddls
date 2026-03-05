@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Pride: Read the MP reading'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity ZC_PM_PRIDE_ROUTE_MP_READ
  as select from ZTF_PM_PRIDE_ROUTE_MP_READ( clnt:$session.client )
  //  association[]  ZI_PM_PRIDE_ROUTE_MP_M as _detailMP on $projection.POINT = _detailMP.MeasurePoint
{
  key MDOCM,
      POINT,
      IDATE,
      ITIME,
      ERDAT,
      ERUHR,
//      READG,
      RECDV,
      RECDU
//      CNTRR,
//      CDIFF,
//      IDIFF
      //  ,
      //_detailMP
}
