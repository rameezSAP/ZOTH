class ZCL_ZPM_PRIDE_OPERATOR_DPC_EXT definition
  public
  inheriting from ZCL_ZPM_PRIDE_OPERATOR_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~PATCH_ENTITY
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZPM_PRIDE_OPERATOR_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~patch_entity.
**TRY.
*CALL METHOD SUPER->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~PATCH_ENTITY
*  EXPORTING
**    iv_entity_name          =
**    iv_entity_set_name      =
**    iv_source_name          =
*    IO_DATA_PROVIDER        =
**    it_key_tab              =
**    it_navigation_path      =
**    io_tech_request_context =
**  IMPORTING
**    er_entity               =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.

    DATA: ls_keys TYPE zcl_zpm_pride_operator_mpc=>ts_route,
          ls_data TYPE zcl_zpm_pride_operator_mpc=>ts_route.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_data ).

    io_tech_request_context->get_converted_keys( IMPORTING es_key_values = ls_keys ).

    CHECK ls_keys-route_id IS NOT INITIAL.
    SELECT FROM zpm_pride_routes
      FIELDS *
      WHERE route_id = @ls_keys-route_id
      INTO TABLE @DATA(lt_route).

    GET TIME STAMP FIELD DATA(l_changedatetime).

    UPDATE zpm_pride_routes
    SET active = ls_data-active
        last_change_at = l_changedatetime
    WHERE route_id = ls_keys-route_id.
    COMMIT WORK.

    LOOP AT lt_route INTO DATA(ls_route).
      IF ls_route-active = 'X'.
        CALL METHOD zcl_pm_pride=>create_with_ref
          EXPORTING
            route_id     = ls_route-route_id
            start_date   = ls_route-e_date
            schedule     = ls_route-sechedule
            start_time   = ls_route-e_time
          IMPORTING
            new_route_id = DATA(l_new_route).
      ENDIF.
    ENDLOOP.

    COMMIT WORK.
    SELECT SINGLE FROM zpm_pride_routes
      FIELDS *
      WHERE route_id = @l_new_route
      INTO @DATA(ls_new_route_data).

    copy_data_to_ref(
            EXPORTING
              is_data = ls_new_route_data
            CHANGING
              cr_data = er_entity
          ).

  ENDMETHOD.
ENDCLASS.
