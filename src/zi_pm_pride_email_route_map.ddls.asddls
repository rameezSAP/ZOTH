@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View Pride: Email/_Route Mapp'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_PM_PRIDE_EMAIL_ROUTE_MAP as select from ztpm0009
{
    key email as Email,
    key route_ref_id as RouteRefId
}
