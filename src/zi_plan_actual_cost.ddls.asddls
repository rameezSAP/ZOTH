@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PM : Order Planned and Actual'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zi_plan_actual_cost
  as select from I_MaintOrdActlPlndCostCube
{
  I_MaintOrdActlPlndCostCube.MaintenanceOrder,
  CompanyCodeCurrency                                        as CurrencyCode,
  @Semantics.amount.currencyCode: 'CurrencyCode'
  sum(I_MaintOrdActlPlndCostCube.ActualMaintAmountInCoCrcy)  as tot_act_cost,
  @Semantics.amount.currencyCode: 'CurrencyCode'
  sum(I_MaintOrdActlPlndCostCube.PlannedMaintAmountInCoCrcy) as tot_plan_cost

}
where
      Ledger             = '0L'
  and GLAccountHierarchy = 'ZUEP'
group by
  I_MaintOrdActlPlndCostCube.MaintenanceOrder,
  CompanyCodeCurrency
