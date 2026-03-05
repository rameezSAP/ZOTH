CLASS lhc_zi_pm_pride_route_det_m DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_pm_pride_route_det_m RESULT result.

*    METHODS GET_INSTANCE_AUTHORIZATIONS FOR INSTANCE AUTHORIZATION
*      IMPORTING KEYS REQUEST REQUESTED_AUTHORIZATIONS FOR ZI_PM_PRIDE_ROUTE_DET_M RESULT RESULT.

    METHODS notrunning FOR MODIFY
      IMPORTING keys FOR ACTION zi_pm_pride_route_det_m~notrunning RESULT result.
    METHODS running FOR MODIFY
      IMPORTING keys FOR ACTION zi_pm_pride_route_det_m~running RESULT result.
    METHODS calccount FOR MODIFY
      IMPORTING keys FOR ACTION zi_pm_pride_route_det_m~calccount.
    METHODS calcfomula FOR MODIFY
      IMPORTING keys FOR ACTION zi_pm_pride_route_det_m~calcfomula.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_pm_pride_route_det_m RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_pm_pride_route_det_m RESULT result.
    METHODS get_global_features FOR GLOBAL FEATURES
      IMPORTING REQUEST requested_features FOR zi_pm_pride_route_det_m RESULT result.
    METHODS onstatuschange FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_pm_pride_route_det_m~onstatuschange.
*    METHODS GET_GLOBAL_FEATURES FOR GLOBAL FEATURES
*      IMPORTING REQUEST REQUESTED_FEATURES FOR ZI_PM_PRIDE_ROUTE_DET_M RESULT RESULT.

*    METHODS GET_INSTANCE_AUTHORIZATIONS FOR INSTANCE AUTHORIZATION
*      IMPORTING KEYS REQUEST REQUESTED_AUTHORIZATIONS FOR ZI_PM_PRIDE_ROUTE_DET_M RESULT RESULT.

ENDCLASS.

CLASS lhc_zi_pm_pride_route_det_m IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF zi_pm_pride_route_m  IN LOCAL MODE
    ENTITY zi_pm_pride_route_det_m ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result_det).

    ""-- commented by rameez 06.02.2026
**    result = VALUE #( FOR ls_result IN lt_result_det ( %tky = ls_result-%tky
**                                                        %action-notrunning = COND #( WHEN ls_result-isactive = 'X'
**                                                                                     THEN  if_abap_behv=>mk-off
**                                                                                     WHEN ls_result-isactive NE 'X'
**                                                                                     THEN if_abap_behv=>mk-on
**                                                                                    )
**                                                        %action-running = COND #( WHEN ls_result-isactive = 'N'
**                                                                                     THEN  if_abap_behv=>mk-off
**                                                                                     WHEN ls_result-isactive NE 'N'
**                                                                                     THEN if_abap_behv=>mk-on
**                                                                                    )
**                                                                                    ) ).
**
**    DATA(has_edit_auth) = abap_false.
***cl_abap_auth_object_factory=>create_single_auth_check(
***        i_auth_object = 'Z_EDIT_AUTH'
***        i_fields      = VALUE #( ( name = 'ACTVT' value = '02' ) )
***      )->is_authorized( ).
**    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
**      IF has_edit_auth = abap_false.
***        // USER LACKS EDIT AUTHORIZATION: MAKE FIELD READ-ONLY
**        APPEND VALUE #( %tky = <ls_key>-%tky %field-PrideDescription = if_abap_behv=>fc-f-read_only ) TO result.
**      ELSE.
***        // USER HAS EDIT AUTHORIZATION: ALLOW EDITING
**        APPEND VALUE #( %tky = <ls_key>-%tky %field-PrideDescription = if_abap_behv=>fc-f-unrestricted ) TO result.
**      ENDIF.
**    ENDLOOP.
    ""-- commented by rameez 06.02.2026

    ""-- BOC by rameez 06.02.2026 (set Status field also read only)
    DATA(has_edit_auth) = abap_false.

    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).
    SELECT SINGLE @abap_true FROM ztpm0008 WHERE api_user = @lv_user INTO @DATA(lv_exists).
    if lv_exists = abap_true.
        data(lv_status_editable) = abap_true.
    else.
        lv_status_editable = abap_false.
    endif.

    result = VALUE #( FOR ls_result IN lt_result_det
          ( %tky = ls_result-%tky

            %action-notrunning = COND #( WHEN ls_result-isactive = 'X'
                                         THEN if_abap_behv=>mk-off
                                         ELSE if_abap_behv=>mk-on )

            %action-running    = COND #( WHEN ls_result-isactive = 'N'
                                         THEN if_abap_behv=>mk-off
                                         ELSE if_abap_behv=>mk-on )


            %field-isActive    = COND #( WHEN lv_status_editable = abap_true
                                         THEN if_abap_behv=>fc-f-unrestricted
                                         ELSE if_abap_behv=>fc-f-read_only )

            %field-PrideDescription = COND #( WHEN has_edit_auth = abap_true
                                              THEN if_abap_behv=>fc-f-unrestricted
                                              ELSE if_abap_behv=>fc-f-read_only )
          ) ).
    ""-- EOC by rameez 06.02.2026 (set Status field also read only)

  ENDMETHOD.

*  METHOD GET_INSTANCE_AUTHORIZATIONS.
**   Check if EDIT operation is triggered or not
*    IF requested_authorizations-%update = if_abap_behv=>mk-on OR
*        requested_authorizations-%action-Edit   = if_abap_behv=>mk-on.
*
**     Check method IS_UPDATE_ALLOWED (Authorization simulation Check method)
*      IF is_update_allowed( ) = abap_true.
*
**       update result with EDIT Allowed
*        result-%update = if_abap_behv=>auth-allowed.
*        result-%action-Edit = if_abap_behv=>auth-allowed.
*
*      ELSE.
*
**       update result with EDIT Not Allowed
*        result-%update = if_abap_behv=>auth-unauthorized.
*        result-%action-Edit = if_abap_behv=>auth-unauthorized.
*
*      ENDIF.
*    ENDIF.
*
*  ENDMETHOD.

  METHOD notrunning.

    ""--- commented by rameez 04.02.2026 (using new determination logic)
*    DATA lt_rt_mp_up TYPE TABLE FOR UPDATE zi_pm_pride_route_mp_m.
*    DATA ls_rt_mp_up LIKE LINE OF lt_rt_mp_up.
*
*    READ ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
*    ENTITY zi_pm_pride_route_det_m BY \_detailsmp
*        ALL FIELDS WITH CORRESPONDING #( keys )
*        RESULT DATA(lt_rt_det).
*    LOOP AT lt_rt_det ASSIGNING FIELD-SYMBOL(<fs_rt_mp_dt>) WHERE isactive = 'X'.
*      MOVE-CORRESPONDING <fs_rt_mp_dt> TO ls_rt_mp_up.
*      ls_rt_mp_up-isactive = 'E'.
*      ls_rt_mp_up-%control-isactive = if_abap_behv=>mk-on.
*      APPEND ls_rt_mp_up TO lt_rt_mp_up.
*    ENDLOOP..
*
*    MODIFY ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
*    ENTITY zi_pm_pride_route_det_m UPDATE FIELDS ( isactive )
*      WITH VALUE #( FOR lv_key IN keys ( %tky = lv_key-%tky
*                                         isactive = 'N') )
*    ENTITY zi_pm_pride_route_mp_m UPDATE FIELDS ( isactive )
*    WITH   lt_rt_mp_up
*    FAILED failed
*    REPORTED reported
*    MAPPED mapped .
*
*    READ ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
*    ENTITY zi_pm_pride_route_det_m
*    ALL FIELDS WITH CORRESPONDING #( keys )
*    RESULT DATA(lt_rt_det_up).
*
*    result = VALUE #( FOR ls_rt_det IN lt_rt_det_up ( %tky = ls_rt_det-%tky
*    %param = ls_rt_det ) ).
    ""--- commented by rameez 04.02.2026 (using new determination logic)

    ""-- added by rameez 04.02.2026 (change status to N trigger onStatusChange)
    MODIFY ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
      ENTITY zi_pm_pride_route_det_m
      UPDATE FIELDS ( IsActive )
      WITH VALUE #( FOR key IN keys ( %tky = key-%tky IsActive = 'N' ) ).

    READ ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
      ENTITY zi_pm_pride_route_det_m ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_upd).
    result = VALUE #( FOR ls_upd IN lt_upd ( %tky = ls_upd-%tky %param = ls_upd ) ).
    ""-- added by rameez 04.02.2026 (change status to N trigger onStatusChange)


  ENDMETHOD.

  METHOD running.

    ""--- commented by rameez 04.02.2026 (using new determination logic)
*    DATA lt_rt_mp_up TYPE TABLE FOR UPDATE zi_pm_pride_route_mp_m.
*    DATA ls_rt_mp_up LIKE LINE OF lt_rt_mp_up.
*
*    READ ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
*    ENTITY zi_pm_pride_route_det_m BY \_detailsmp
*        ALL FIELDS WITH CORRESPONDING #( keys )
*        RESULT DATA(lt_rt_det).
*    LOOP AT lt_rt_det ASSIGNING FIELD-SYMBOL(<fs_rt_mp_dt>) WHERE isactive = 'E'.
*      MOVE-CORRESPONDING <fs_rt_mp_dt> TO ls_rt_mp_up.
*      ls_rt_mp_up-isactive = 'X'.
*      ls_rt_mp_up-%control-isactive = if_abap_behv=>mk-on.
*      APPEND ls_rt_mp_up TO lt_rt_mp_up.
*    ENDLOOP..
*
*    MODIFY ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
*    ENTITY zi_pm_pride_route_det_m UPDATE FIELDS ( isactive )
*      WITH VALUE #( FOR lv_key IN keys ( %tky = lv_key-%tky
*                                         isactive = 'X') )
*    ENTITY zi_pm_pride_route_mp_m UPDATE FIELDS ( isactive )
*    WITH   lt_rt_mp_up
*    FAILED failed
*    REPORTED reported
*    MAPPED mapped .
*
*    READ ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
*    ENTITY zi_pm_pride_route_det_m
*    ALL FIELDS WITH CORRESPONDING #( keys )
*    RESULT DATA(lt_rt_det_up).
*
*    result = VALUE #( FOR ls_rt_det IN lt_rt_det_up ( %tky = ls_rt_det-%tky
*    %param = ls_rt_det ) ).
    ""--- commented by rameez 04.02.2026 (using new determination logic)

    ""-- added by rameez 04.02.2026 (change status to X trigger onStatusChange)
    MODIFY ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
      ENTITY zi_pm_pride_route_det_m
      UPDATE FIELDS ( IsActive )
      WITH VALUE #( FOR key IN keys ( %tky = key-%tky IsActive = 'X' ) ).

    READ ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
      ENTITY zi_pm_pride_route_det_m ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_upd).
    result = VALUE #( FOR ls_upd IN lt_upd ( %tky = ls_upd-%tky %param = ls_upd ) ).
    ""-- added by rameez 04.02.2026 (change status to trigger onStatusChange)

  ENDMETHOD.

  METHOD calccount.

    READ ENTITIES OF zi_pm_pride_route_m  IN LOCAL MODE
    ENTITY zi_pm_pride_route_det_m
    FIELDS ( remainingcount isactive )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    READ ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
    ENTITY zi_pm_pride_route_det_m BY \_detailsmp
    FIELDS ( value isactive )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_mp_result).

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_route>).
      <fs_route>-remainingcount =  0.
      LOOP AT lt_mp_result ASSIGNING FIELD-SYMBOL(<fs_route_details>)
      USING KEY entity
      WHERE routeid = <fs_route>-routeid.
        IF <fs_route_details>-isactive = 'X' AND <fs_route_details>-value > 0.
          DATA(lv_count) =  0.
*        ENDIF.

        ELSEIF <fs_route_details>-isactive = 'E'.
          lv_count =  0.
*        ENDIF.

        ELSEIF  <fs_route_details>-isactive = 'O'.
          lv_count =  0.
*        ENDIF.

        ELSE.
          lv_count =  1 .
        ENDIF.
        <fs_route>-remainingcount += lv_count.
        CLEAR lv_count.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
      ENTITY zi_pm_pride_route_det_m
      UPDATE FIELDS ( remainingcount )
      WITH CORRESPONDING #( lt_result ).

  ENDMETHOD.

  METHOD calcfomula.
    DATA : in    TYPE f VALUE 16,
           out   TYPE f,
           lt_gf TYPE TABLE FOR READ RESULT zi_pm_pride_route_det_m\_detailsmp.
    CONSTANTS: lc_coefficient     TYPE  zpm_prd_cons VALUE 'CF',
               lc_cof_diff        TYPE  zpm_prd_cons VALUE 'CD',
               lc_actual_pressure TYPE  zpm_prd_cons VALUE 'SP',
               lc_dif_pressure    TYPE  zpm_prd_cons VALUE 'DP',
               lc_gas_flow        TYPE  zpm_prd_cons VALUE 'GF',
               lc_cor_diff        TYPE  zpm_prd_cons VALUE 'CD'.

    CLEAR lt_gf[].
    READ ENTITIES OF zi_pm_pride_route_m  IN LOCAL MODE
     ENTITY zi_pm_pride_route_det_m
     FIELDS ( formula_typ isactive )
     WITH CORRESPONDING #( keys )
     RESULT DATA(lt_result).

    READ ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
    ENTITY zi_pm_pride_route_det_m BY \_detailsmp
    FIELDS ( value formula_typ formula_main )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_mp_result).

    READ ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
    ENTITY zi_pm_pride_route_det_m BY \_routes
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_route_result).

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_route>) WHERE formula_typ = lc_gas_flow.
      <fs_route>-formula =  0.
      LOOP AT lt_mp_result ASSIGNING FIELD-SYMBOL(<fs_route_details>)
      USING KEY entity
      WHERE routeid = <fs_route>-routeid
      AND formula_typ IS NOT INITIAL.
        IF <fs_route_details>-formula_typ = lc_actual_pressure AND <fs_route_details>-value > 0.
          DATA(lv_actual_pressure) =  <fs_route_details>-value .
*          <FS_ROUTE>-FORMULA += <FS_ROUTE_DETAILS>-VALUE .

        ENDIF.

        IF <fs_route_details>-formula_typ = lc_dif_pressure AND <fs_route_details>-value > 0..
          DATA(lv_diff_pressure) =  <fs_route_details>-value .

        ENDIF.

*        IF <FS_ROUTE_DETAILS>-FORMULA_TYP = LC_COR_DIFF AND <FS_ROUTE_DETAILS>-VALUE > 0..
*          DATA(LV_COR_DIFF) =  <FS_ROUTE_DETAILS>-VALUE .
*
*        ENDIF.
      ENDLOOP.

      IF lv_actual_pressure IS NOT INITIAL AND lv_diff_pressure IS NOT INITIAL.
        CLEAR in.
        CLEAR out.

*          <FS_ROUTE>-FORMULA = OUT .
        READ TABLE lt_route_result WITH KEY routeid = <fs_route>-routeid INTO DATA(ls_route).
        IF ls_route IS NOT INITIAL.
          SELECT  * FROM zpm_prd_constant
          INTO TABLE @DATA(lt_constant_cd) WHERE for_type = @lc_cof_diff
          AND equnr = @<fs_route>-equipment
          AND begda LE @ls_route-edate
          AND endda GE @ls_route-edate.

          LOOP AT lt_constant_cd INTO DATA(ls_constant_cd).
            DATA(lv_route_enddate) = ls_route-edate && ls_route-etime.
            DATA(lv_const_startdate) = ls_constant_cd-begda && ls_constant_cd-bedgt.
            DATA(lv_const_enddate) = ls_constant_cd-endda && ls_constant_cd-endt.

            IF lv_const_startdate LE lv_route_enddate AND lv_const_enddate GE lv_route_enddate.
              EXIT.
            ENDIF.

          ENDLOOP.
*
          IF ls_constant_cd-value IS NOT INITIAL.
            DATA(lv_cor_diff) = ls_constant_cd-value.
          ENDIF.


*/***** Check the Coefficient Formula.


          SELECT  * FROM zpm_prd_constant
          INTO TABLE @DATA(lt_constant) WHERE for_type = @lc_coefficient
          AND equnr = @<fs_route>-equipment
          AND begda LE @ls_route-edate
          AND endda GE @ls_route-edate.

          LOOP AT lt_constant INTO DATA(ls_constant).
            lv_route_enddate = ls_route-edate && ls_route-etime.
            lv_const_startdate = ls_constant-begda && ls_constant-bedgt.
            lv_const_enddate = ls_constant-endda && ls_constant-endt.

            IF lv_const_startdate LE lv_route_enddate AND lv_const_enddate GE lv_route_enddate.
              EXIT.
            ENDIF.

          ENDLOOP.

          IF lv_cor_diff IS INITIAL OR lv_cor_diff = 0.
            lv_cor_diff = 1.
          ENDIF.

          in = lv_actual_pressure * lv_diff_pressure * lv_cor_diff.

          CALL METHOD cl_foev_builtins=>square_root
            EXPORTING
              im_number = in
            IMPORTING
              ex_result = out.
          IF ls_constant-value IS NOT INITIAL.
            <fs_route>-formula = out * ls_constant-value.
          ENDIF.

        ENDIF.
      ENDIF.

      LOOP AT lt_mp_result ASSIGNING FIELD-SYMBOL(<fs_route_gf>)
      USING KEY entity WHERE routeid = <fs_route>-routeid
      AND formula_main = lc_gas_flow.
        IF sy-subrc = 0.
          SELECT SINGLE * FROM zpm_pride_hier_m
          INTO @DATA(ls_mp_act)
          WHERE route_id = @<fs_route_gf>-routeid AND measure_point = @<fs_route_gf>-measurepoint.
          IF ( <fs_route>-formula NE <fs_route_gf>-value_char ) OR ( <fs_route_gf>-value_char IS INITIAL  ) .
            IF <fs_route>-formula IS NOT INITIAL OR <fs_route>-formula > 0.
              <fs_route_gf>-value_char = <fs_route>-formula.
*        <FS_ROUTE_GF>-value_char = <FS_ROUTE>-formula.
              APPEND <fs_route_gf> TO lt_gf.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
      IF lt_gf[] IS NOT INITIAL.
        IF <fs_route>-formula IS NOT INITIAL OR <fs_route>-formula > 0.

          MODIFY ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
            ENTITY zi_pm_pride_route_mp_m
            UPDATE FIELDS ( value_char )
            WITH CORRESPONDING #( lt_gf ).
        ENDIF.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
      ENTITY zi_pm_pride_route_det_m
      UPDATE FIELDS ( formula )
      WITH CORRESPONDING #( lt_result ).
  ENDMETHOD.

*  METHOD get_global_features.
*  ENDMETHOD.
*
*  METHOD get_instance_authorizations.
*  ENDMETHOD.

  METHOD get_instance_authorizations.

  ENDMETHOD.

  METHOD get_global_authorizations.

*   = if_abap_behv=>auth-unauthorized.
*  if REQUESTED_AUTHORIZATIONS-%ACTION-
**   Check if EDIT operation is triggered or not
*    IF requested_authorizations-% = if_abap_behv=>mk-on OR
*        requested_authorizations-%action-Edit   = if_abap_behv=>mk-on.
*
**     Check method IS_UPDATE_ALLOWED (Authorization simulation Check method)
*      IF is_update_allowed( ) = abap_true.
*
**       update result with EDIT Allowed
*        result-%update = if_abap_behv=>auth-allowed.
*        result-%action-Edit = if_abap_behv=>auth-allowed.
*
*      ELSE.
*
**       update result with EDIT Not Allowed
*        result-%update = if_abap_behv=>auth-unauthorized.
*        result-%action-Edit = if_abap_behv=>auth-unauthorized.
*
*      ENDIF.
*    ENDIF.

  ENDMETHOD.

  METHOD get_global_features.
    result-%assoc-_detailsmp = if_abap_behv=>auth-unauthorized.
  ENDMETHOD.

  METHOD onStatusChange.

    READ ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
      ENTITY zi_pm_pride_route_det_m
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_details).

    READ ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
      ENTITY zi_pm_pride_route_det_m BY \_detailsmp
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_mp_details).

    DATA lt_mp_update TYPE TABLE FOR UPDATE zi_pm_pride_route_mp_m.

    LOOP AT lt_details ASSIGNING FIELD-SYMBOL(<fs_det>).

      "Sync child Measuring Points based on Parent Status
      LOOP AT lt_mp_details ASSIGNING FIELD-SYMBOL(<fs_mp>)
      USING KEY entity
       WHERE routeid = <fs_det>-routeid.
        IF <fs_det>-IsActive = 'X' AND <fs_mp>-IsActive = 'E'.
          APPEND VALUE #( %tky = <fs_mp>-%tky IsActive = 'X' ) TO lt_mp_update.
        ELSEIF <fs_det>-IsActive = 'N' AND <fs_mp>-IsActive = 'X'.
          APPEND VALUE #( %tky = <fs_mp>-%tky IsActive = 'E' ) TO lt_mp_update.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    "updates Measuring Points
    IF lt_mp_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
        ENTITY zi_pm_pride_route_mp_m
        UPDATE FIELDS ( IsActive ) WITH lt_mp_update.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
