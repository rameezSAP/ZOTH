@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Order Related DB'
@Metadata.ignorePropagatedAnnotations: true
@OData.publish: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_MAINT_ORDER_DB
  as select distinct  from ZC_MAINT_ORDER_ALL_DB as _header

{
  key MaintenanceOrder,
      MaintenanceOrderType,
      MaintenanceOrderDesc,
      MaintPriority,
      priority_text,
      FunctionalLocation,
      func_loc_text,
      Equipment,
      equipment_name,
      MaintenanceNotification,
      LeadingOrder,
      MaintenancePlannerGroup,
      MaintenancePlanningPlant,
      MaintenanceRevision,
      MaintenancePlan,
      MaintenanceItem,
      MaintenanceOrderPlanningCode,
      MaintenanceActivityType,
      ABCIndicator,
      MaintenancePlant,
      AssetLocation,
      AssetRoom,
      MainWorkCenter,
      MainWorkCenterPlant,
      CostCenter,
      CompanyCode,
      WBSElementInternalID,
      IsMarkedForDeletion,
      CreationDate,
      PlannedStartDate,
      PlannedEndDate,
      basic_start_date,
      basic_end_date,
      ActualStartDate,
      Actual_end_Date,
      CreatedByUser,
      TechnicalObjectType,
      Technical_object_text,
      WorkCenterTypeCode,
      WBSElement,
      CurrencyCode,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      actual_cost,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      plan_cost,
      Vendor,
      remarks,
      system_status,
      user_status,
      root,
      root_text,
      EQUI,
      call_no,
      ref_date,
      last_change_by,
      Personnel_No,
      Personnel_Name,
      final_due_date,
      revision_text,
      problem_code,
      Scheduled_start,
      Scheduled_finish,
      Operation_Text,
      new_status,
      RequiredEndDate,
      RequiredStartDate
}
