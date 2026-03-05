@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Order Related DB'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_MAINT_ORDER_ALL_DB
  as select  from    I_MaintOrderTechObjCube                        as _header
    left outer join afih                                           as _afih          on _header.MaintenanceOrder = _afih.aufnr
    left outer join zi_plan_actual_cost                            as _act_plan_cost on _header.MaintenanceOrder = _act_plan_cost.MaintenanceOrder
    left outer join aufk                                           as _aufk          on _aufk.aufnr = _header.MaintenanceOrder
    left outer join afko                                           as _afko          on _afko.aufnr = _header.MaintenanceOrder
    left outer join ZTF_GET_operation_data( clnt: $session.client) as _afvc          on _afvc.aufpl = _afko.aufpl
    left outer join ztf_get_order_statuse( clnt: $session.client)  as _status        on _header.MaintenanceOrderInternalID = _status.objnr
    left outer join ztf_get_euip_root                              as _root_euqi     on _header.Equipment = _root_euqi.Equipment
    left outer join t352r                                          as _rev_text      on  _header.MaintenanceRevision      = _rev_text.revnr
                                                                                     and _header.MaintenancePlanningPlant = _rev_text.iwerk
    left outer join t356_t                                         as _prio_txt      on  _prio_txt.priok = _header.MaintPriority
                                                                                     and _prio_txt.artpr = _header.MaintPriorityType
                                                                                     and _prio_txt.spras = 'E'
    left outer join pa0002                                         as _pa0002        on  _pa0002.pernr = _afvc.pernr
                                                                                     and _pa0002.endda = '99991231'
    left outer join eqkt                                           as _text          on _text.equnr = _root_euqi.Root
    left outer join I_MaintNotificationItemData                    as _item          on  _item.MaintenanceNotification     = _header.MaintenanceNotification
                                                                                     and _item.MaintenanceNotificationItem = '0001'
{
  key _header.MaintenanceOrder,
      _header.MaintenanceOrderType,
      _header.MaintenanceOrderDesc,
      _header.MaintPriority,
      _prio_txt.priokx                                                                                                     as priority_text,
      _header.FunctionalLocation,
      _header._FunctionalLocationData._FunctionalLocationText[1: Language=$session.system_language].FunctionalLocationName as func_loc_text,
      _header.Equipment,
      _header._EquipmentData._EquipmentText[1: Language=$session.system_language].EquipmentName                            as equipment_name,
      _header.MaintenanceNotification,
      _header.LeadingOrder,
      _header.MaintenancePlannerGroup,
      _header.MaintenancePlanningPlant,
      _header.MaintenanceRevision,
      _header.MaintenancePlan,
      _header.MaintenanceItem,
      _header.MaintenanceOrderPlanningCode,
      _header.MaintenanceActivityType,
      _header.ABCIndicator,
      _header.MaintenancePlant,
      _header.AssetLocation,
      _header.AssetRoom,
      _header.MainWorkCenter,
      _header.MainWorkCenterPlant,
      _header.CostCenter,
      _header.CompanyCode,
      _header.WBSElementInternalID,
      _header.IsMarkedForDeletion,
      //      _header.CreationDate,
      case _header.CreationDate
           when  '00000000' then cast(  ''   as abap.char( 10 ) )
      else
      cast( _header.CreationDate  as abap.char( 10 ) )  end                                                                as CreationDate,

      case _header.PlannedStartDate
            when  '00000000' then cast(  ''   as abap.char( 10 ) )
      else
       cast( _header.PlannedStartDate  as abap.char( 10 ) )   end                                                          as PlannedStartDate,

      case _header.PlannedEndDate
                  when  '00000000' then cast(  ''   as abap.char( 10 ) )
      else
       cast( _header.PlannedEndDate  as abap.char( 10 ) )   end                                                            as PlannedEndDate,

      case _afko.gstrp
                 when  '00000000' then cast(  ''   as abap.char( 10 ) )
      else
      cast( _afko.gstrp  as abap.char( 10 ) )  end                                                                         as basic_start_date,

      case _afko.gltrp
                when  '00000000' then cast(  ''   as abap.char( 10 ) )
      else
      cast( _afko.gltrp  as abap.char( 10 ) )   end                                                                        as basic_end_date,

      case _header.ActualStartDate
                when  '00000000' then cast(  ''   as abap.char( 10 ) )
      else
      cast( _header.ActualStartDate  as abap.char( 10 ) )   end                                                            as ActualStartDate,


      case _header.ConfirmedEndDate
                   when  '00000000' then cast(  ''   as abap.char( 10 ) )
       else
        cast( _header.ConfirmedEndDate   as abap.char( 10 ) )   end                                                        as Actual_end_Date,

      _header.CreatedByUser,
      //      _header.TechnicalObject,
      _header.TechnicalObjectType,
      _header._TechnicalObjectType._Text.TechnicalObjectTypeDesc                                                           as Technical_object_text,
      _header.WorkCenterTypeCode,
      _header._WBSElementBasicData.WBSElement,
      _act_plan_cost.CurrencyCode,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      _act_plan_cost.tot_act_cost                                                                                          as actual_cost,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      _act_plan_cost.tot_plan_cost                                                                                         as plan_cost,
      _aufk.zlifnr                                                                                                         as Vendor,
      _aufk.zremarks                                                                                                       as remarks,
      _status.system_status                                                                                                as system_status,
      _status.user_status                                                                                                  as user_status,
      _root_euqi.Root                                                                                                      as root,
      _text.eqktx                                                                                                          as root_text,
      _root_euqi.Equipment                                                                                                 as EQUI,
      _afih.abnum                                                                                                          as call_no,
      case  _afih.addat
      when  '00000000' then cast(  ''   as abap.char( 10 ) )
      else
       cast( _afih.addat   as abap.char( 10 ) )   end                                                                      as ref_date,
      _aufk.aenam                                                                                                          as last_change_by,
      _afvc.pernr                                                                                                          as Personnel_No,
      concat(_pa0002.vorna,_pa0002.nachn)                                                                                  as Personnel_Name,
      case _afih.lacd_date
      when  '00000000' then cast(  ''   as abap.char( 10 ) )
      else
      cast(  _afih.lacd_date   as abap.char( 10 ) ) end                                                                    as final_due_date,
      //      cast(  _afih.lacd_date   as abap.char( 10 ) )                                  as final_due_date,
      _rev_text.revtx                                                                                                      as revision_text,
      _item.MaintNotifObjPrtCodeGroup                                                                                      as problem_code,
      case _afko.gstrs
                 when  '00000000' then cast(  ''   as abap.char( 10 ) )
      else
      cast( _afko.gstrs as abap.char( 10 ) )  end                                                                          as Scheduled_start,
      case _afko.gltrs
           when  '00000000' then cast(  ''   as abap.char( 10 ) )
      else
      cast( _afko.gltrs as abap.char( 10 ) )  end                                                                          as Scheduled_finish,
      _afvc.LTXA1 as Operation_Text,
      _status.new_status,
      _item._MaintenanceNotification.RequiredStartDate,
      _item._MaintenanceNotification.RequiredEndDate

}
