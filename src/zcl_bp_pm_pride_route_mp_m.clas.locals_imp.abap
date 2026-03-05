CLASS lhc_zi_pm_pride_route_mp_m DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validateequipment FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_pm_pride_route_mp_m~validateequipment.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_pm_pride_route_mp_m RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_pm_pride_route_mp_m RESULT result.

    METHODS outoforder FOR MODIFY
      IMPORTING keys FOR ACTION zi_pm_pride_route_mp_m~outoforder RESULT result.
    METHODS inorder FOR MODIFY
      IMPORTING keys FOR ACTION zi_pm_pride_route_mp_m~inorder RESULT result.
    METHODS validatereading FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_pm_pride_route_mp_m~validatereading.
    METHODS calculatedetailcount FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_pm_pride_route_mp_m~calculatedetailcount.
    METHODS calculateformula FOR DETERMINE ON SAVE
      IMPORTING keys FOR zi_pm_pride_route_mp_m~calculateformula.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_pm_pride_route_mp_m RESULT result.
    METHODS resetmp FOR MODIFY
      IMPORTING keys FOR ACTION zi_pm_pride_route_mp_m~resetmp.
    METHODS movetovalue FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_pm_pride_route_mp_m~movetovalue.

    METHODS validatereadingchar FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_pm_pride_route_mp_m~validatereadingchar.
    METHODS calculatempformula FOR DETERMINE ON SAVE
      IMPORTING keys FOR zi_pm_pride_route_mp_m~calculatempformula.
    METHODS onmpstatuschange FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_pm_pride_route_mp_m~onMPStatusChange.

ENDCLASS.

CLASS lhc_zi_pm_pride_route_mp_m IMPLEMENTATION.
  METHOD validateequipment.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key>).
      READ ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE ENTITY
      zi_pm_pride_route_det_m ALL FIELDS WITH CORRESPONDING #( keys   )
      RESULT DATA(lt_result).
    ENDLOOP..

*  read entity ZI_PM_PRIDE_ROUTE_M FROM
  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zi_pm_pride_route_m  IN LOCAL MODE
    ENTITY zi_pm_pride_route_mp_m ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result_det).

    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).
    SELECT SINGLE @abap_true FROM ztpm0008 WHERE api_user = @lv_user INTO @DATA(lv_exists).
    IF lv_exists = abap_true.
      DATA(lv_status_editable) = abap_true.
    ELSE.
      lv_status_editable = abap_false.
    ENDIF.

    result = VALUE #( FOR ls_result IN lt_result_det ( %tky = ls_result-%tky
                                                        %action-outoforder = COND #( WHEN ls_result-isactive = 'X'
                                                                                     THEN  if_abap_behv=>mk-off
                                                                                     WHEN ls_result-isactive NE 'X'
                                                                                     THEN if_abap_behv=>mk-on
                                                                                    )
                                                        %action-inorder = COND #( WHEN ls_result-isactive = 'O'
                                                                                     THEN  if_abap_behv=>mk-off
                                                                                     WHEN ls_result-isactive NE 'O'
                                                                                     THEN if_abap_behv=>mk-on
                                                                                    )
                                                       ""-- added by rameez 06.02.2026 (set Status field readonly)
            %field-isActive    = COND #( WHEN lv_status_editable = abap_true
                                         THEN if_abap_behv=>fc-f-unrestricted
                                         ELSE if_abap_behv=>fc-f-read_only )
                                                                                    ) ).


  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD outoforder.

*    READ ENTITIES OF ZI_PM_PRIDE_ROUTE_M  IN LOCAL MODE
*    ENTITY ZI_PM_PRIDE_ROUTE_DET_M ALL FIELDS WITH CORRESPONDING #( KEYS )
*    RESULT DATA(LT_RESULT_DET)
*
*    ENTITY ZI_PM_PRIDE_ROUTE_MP_M ALL FIELDS WITH CORRESPONDING #( KEYS )
*    RESULT DATA(LT_RESULT_MP)
*    FAILED DATA(LT_FAILED)
*    REPORTED DATA(LT_REPORTED).
*
*loop at LT_RESULT_MP ASSIGNING FIELD-SYMBOL(<fs_mp>).
*RESULT = VALUE #( for ls_mp in LT_RESULT_MP ( %tky = ls_mp-%tky %PARAM  )
*
* ).

    MODIFY ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
    ENTITY zi_pm_pride_route_mp_m UPDATE FIELDS ( isactive )
    WITH VALUE #( FOR ls_key IN keys ( %tky = ls_key-%tky isactive = 'O' )  )
    MAPPED DATA(lt_mapped)
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).

    READ ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
    ENTITY zi_pm_pride_route_mp_m ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result (  %tky = ls_result-%tky
                                                     %param = ls_result ) ).

  ENDMETHOD.

  METHOD inorder.
    MODIFY ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
  ENTITY zi_pm_pride_route_mp_m UPDATE FIELDS ( isactive )
  WITH VALUE #( FOR ls_key IN keys ( %tky = ls_key-%tky isactive = 'X' )  )
  MAPPED DATA(lt_mapped)
  FAILED DATA(lt_failed)
  REPORTED DATA(lt_reported).

    READ ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
    ENTITY zi_pm_pride_route_mp_m ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result (  %tky = ls_result-%tky
                                                     %param = ls_result ) ).
  ENDMETHOD.

  METHOD validatereading.

    READ ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
    ENTITY zi_pm_pride_route_det_m BY \_routes
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_results).

    LOOP AT lt_results ASSIGNING FIELD-SYMBOL(<fs_result_route>).
      IF <fs_result_route>-edate < sy-datum OR ( <fs_result_route>-edate = sy-datum AND <fs_result_route>-etime <= sy-uzeit ).
        READ ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
        ENTITY zi_pm_pride_route_mp_m ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_result).

        LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_result>).
          IF <fs_result>-lowlimit IS NOT INITIAL OR <fs_result>-highlimit IS NOT INITIAL.
            IF <fs_result>-value < <fs_result>-lowlimit .
              DATA(lv_msg) =  <fs_result>-measurepoint && '/' && <fs_result>-mpdesc.
              APPEND VALUE #( %tky = <fs_result>-%tky %msg = new_message(
                                       id = zcl_pm_pride_constants=>c_messageid
                                   number = '002'
                                   v1 = <fs_result>-value
                                   v2 = <fs_result>-lowlimit
                                   v3 = lv_msg
                                 severity = if_abap_behv_message=>severity-warning )
                                  %element-value = if_abap_behv=>mk-on  ) TO reported-zi_pm_pride_route_mp_m.
              CLEAR lv_msg.
            ENDIF.


            IF  <fs_result>-value > <fs_result>-highlimit.
              lv_msg =  <fs_result>-measurepoint && '/' && <fs_result>-mpdesc.
              APPEND VALUE #( %tky = <fs_result>-%tky %msg = new_message(
                                       id = zcl_pm_pride_constants=>c_messageid
                                   number = '003'
                                   v1 = <fs_result>-value
                                   v2 = <fs_result>-highlimit
                                   v3 = lv_msg
                                 severity = if_abap_behv_message=>severity-warning )
                                 %element-value = if_abap_behv=>mk-on ) TO reported-zi_pm_pride_route_mp_m.
              CLEAR lv_msg.
            ENDIF.

          ENDIF.
        ENDLOOP.
      ELSE.
        READ ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
    ENTITY zi_pm_pride_route_mp_m ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result_mp).

        LOOP AT lt_result_mp ASSIGNING FIELD-SYMBOL(<fs_result_mp>).

          APPEND VALUE #( %tky = <fs_result_mp>-%tky %msg = new_message(
                                 id = zcl_pm_pride_constants=>c_messageid
                             number = '004'
                             v1 = <fs_result_route>-sdate
                             v2 = <fs_result_route>-stime
                           severity = if_abap_behv_message=>severity-error )
                           %element-value = if_abap_behv=>mk-on ) TO reported-zi_pm_pride_route_mp_m.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD calculatedetailcount.
*    DATA LT_DETAILS TYPE STANDARD TABLE OF ZI_PM_PRIDE_ROUTE_DET_M WITH UNIQUE HASHED KEY KEY COMPONENTS ROUTEID EQUIPMENT.
*    LT_DETAILS = CORRESPONDING #( KEYS DISCARDING DUPLICATES MAPPING ROUTEID = ROUTEID EQUIPMENT = EQUIPMENT ).

    READ ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
    ENTITY zi_pm_pride_route_mp_m BY \_details
    FIELDS ( routeid equipment )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_mp_route).

    MODIFY ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
    ENTITY zi_pm_pride_route_det_m
    EXECUTE calccount
    FROM CORRESPONDING #( lt_mp_route ).


  ENDMETHOD.

  METHOD calculateformula.
    READ ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
  ENTITY zi_pm_pride_route_mp_m BY \_details
  FIELDS ( routeid equipment )
  WITH CORRESPONDING #( keys )
  RESULT DATA(lt_mp_route).

    MODIFY ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
    ENTITY zi_pm_pride_route_det_m
    EXECUTE calcfomula
    FROM CORRESPONDING #( lt_mp_route ).


  ENDMETHOD.

  METHOD get_global_authorizations.

  ENDMETHOD.

  METHOD resetmp.

    READ ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
              ENTITY zi_pm_pride_route_mp_m
              ALL FIELDS WITH CORRESPONDING #( keys )
              RESULT DATA(lt_rt_mp) .

*        LOOP AT LT_RT_MP ASSIGNING FIELD-SYMBOL(<FS_MP>).
*
*        ENDLOOP.

    MODIFY ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
     ENTITY zi_pm_pride_route_mp_m UPDATE FIELDS ( value_char value  isactive )
     WITH VALUE #( FOR ls_key IN lt_rt_mp ( %tky = ls_key-%tky value_char = '' value = 0 isactive = COND #( WHEN  ls_key-isactive = 'R' THEN 'R'
                                                                                            ELSE                             'X'  )  )  )

     MAPPED DATA(lt_mapped)
     FAILED DATA(lt_failed)
     REPORTED DATA(lt_reported).

  ENDMETHOD.

  METHOD movetovalue.
    DATA lv_flp TYPE f.
    READ ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
  ENTITY zi_pm_pride_route_mp_m
  ALL FIELDS WITH CORRESPONDING #( keys )
  RESULT DATA(lt_results).

    LOOP AT lt_results ASSIGNING FIELD-SYMBOL(<fs_result_route>).

      CALL FUNCTION 'CHAR_FLTP_CONVERSION'
        EXPORTING
*         DYFLD              = SPACE
*         MASKN              = SPACE
*         MAXDEC             = '16'
*         MAXEXP             = '59+'
*         MINEXP             = '60-'
          string             = <fs_result_route>-value_char
*         MSGTYP_DECIM       = 'W'
*         STRICT_CHECK       = SPACE
        IMPORTING
*         DECIM              = DECIM
*         EXPON              = EXPON
          flstr              = <fs_result_route>-value
*         IVALU              = IVALU
        EXCEPTIONS
          exponent_too_big   = 1
          exponent_too_small = 2
          string_not_fltp    = 3
          too_many_decim     = 4
          OTHERS             = 5.

      <fs_result_route>-CDate = sy-datum.
      <fs_result_route>-CTime = sy-uzeit.
*          <FS_RESULT_ROUTE>-
      IF sy-subrc <> 0.
      ELSE.

      ENDIF.

    ENDLOOP.
    MODIFY ENTITIES OF zi_pm_pride_route_m
     IN LOCAL MODE
     ENTITY zi_pm_pride_route_mp_m
     UPDATE FIELDS ( value CDate CTime )
     WITH VALUE #( FOR ls_key IN lt_results ( %tky = ls_key-%tky value = ls_key-value CDate = ls_key-CDate CTime = ls_key-CTime ) )
*    ENTITY ZI_PM_PRIDE_ROUTE_MP_M UPDATE FIELDS ( Value )
*    WITH VALUE( %TKY = <FS_RESULT_ROUTE>-%TKY Value = LV_FLP )
      MAPPED DATA(lt_mapped)
      FAILED DATA(lt_failed)
      REPORTED DATA(lt_reported).
  ENDMETHOD.

  METHOD validatereadingchar.

    DATA lv_flp TYPE f.

    READ ENTITY IN LOCAL MODE zi_pm_pride_route_m
*           ENTITY ZI_PM_PRIDE_ROUTE_MP_M
          ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(lt_results_routes).

    LOOP AT lt_results_routes ASSIGNING FIELD-SYMBOL(<fs_routes>).

      SELECT SINGLE * FROM zi_pm_pride_route_m  INTO @DATA(ls_route)
      WHERE routeid = @<fs_routes>-routeid.
      IF sy-subrc = 0.
        IF ( ls_route-edate = <fs_routes>-edate AND ls_route-etime = <fs_routes>-etime AND ls_route-etimeeven = <fs_routes>-etimeeven ) AND ( ls_route-active = <fs_routes>-active ).

          READ ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
                ENTITY zi_pm_pride_route_mp_m
                ALL FIELDS WITH CORRESPONDING #( keys )
                RESULT DATA(lt_results).

          LOOP AT lt_results ASSIGNING FIELD-SYMBOL(<fs_result_route>).

            IF <fs_result_route>-codegroup IS NOT INITIAL AND <fs_result_route>-codegroup NE 'NULL' AND <fs_result_route>-isactive = 'X'.
              SELECT SINGLE code FROM zicds_get_codegrp_vh
                INTO @DATA(ls_code)
                WHERE codegruppe = @<fs_result_route>-codegroup
                AND code = @<fs_result_route>-value_char.
              IF ls_code IS INITIAL.



                DATA(lv_msg) =  <fs_result_route>-measurepoint && '/' && <fs_result_route>-mpdesc.
                APPEND VALUE #( %tky = <fs_result_route>-%tky %msg = new_message(
                                         id = zcl_pm_pride_constants=>c_messageid
                                     number = '013'
                                     v1 = <fs_result_route>-value_char
*                                   V2 = <FS_RESULT_ROUTE>-LOWLIMIT
                                     v3 = lv_msg
                                   severity = if_abap_behv_message=>severity-error )
                                    %element-value_char = if_abap_behv=>mk-on  ) TO reported-zi_pm_pride_route_mp_m.
                CLEAR lv_msg.
              ENDIF.

            ELSE.
              CALL FUNCTION 'CHAR_FLTP_CONVERSION'
                EXPORTING
*                 DYFLD              = SPACE
*                 MASKN              = SPACE
*                 MAXDEC             = '16'
*                 MAXEXP             = '59+'
*                 MINEXP             = '60-'
                  string             = <fs_result_route>-value_char
*                 MSGTYP_DECIM       = 'W'
*                 STRICT_CHECK       = SPACE
                IMPORTING
*                 DECIM              = DECIM
*                 EXPON              = EXPON
                  flstr              = lv_flp
*                 IVALU              = IVALU
                EXCEPTIONS
                  exponent_too_big   = 1
                  exponent_too_small = 2
                  string_not_fltp    = 3
                  too_many_decim     = 4.
              IF sy-subrc <> 0.
                CLEAR lv_msg.
                lv_msg =  <fs_result_route>-measurepoint && '/' && <fs_result_route>-mpdesc.
                APPEND VALUE #( %tky = <fs_result_route>-%tky %msg = new_message(
                                         id = zcl_pm_pride_constants=>c_messageid
                                     number = '009'
                                     v1 = <fs_result_route>-value_char
*                                   V2 = <FS_RESULT_ROUTE>-LOWLIMIT
                                     v3 = lv_msg
                                   severity = if_abap_behv_message=>severity-error )
                                    %element-value_char = if_abap_behv=>mk-on  ) TO reported-zi_pm_pride_route_mp_m.
                CLEAR lv_msg.
              ENDIF.

            ENDIF.

          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD calculatempformula.
    READ ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
     ENTITY zi_pm_pride_route_mp_m "BY \_DETAILS
     FIELDS ( routeid measurepoint value_char )
     WITH CORRESPONDING #( keys )
     RESULT DATA(lt_mp_route).

    LOOP AT lt_mp_route ASSIGNING FIELD-SYMBOL(<fs_mp>).

      zcl_pm_pride=>get_mp_formula(
        EXPORTING
          iv_routeid = <fs_mp>-routeid
          iv_value   = <fs_mp>-value_char
          iv_mp      = <fs_mp>-measurepoint
        IMPORTING
          ev_value   = DATA(ev_value)
      ).
      <fs_mp>-formulamp = ev_value.

    ENDLOOP.

    MODIFY ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
    ENTITY zi_pm_pride_route_mp_m UPDATE FIELDS ( formulaMP )
    WITH  CORRESPONDING #( lt_mp_route ).


  ENDMETHOD.

  METHOD onMPStatusChange.

    DATA lt_parent_keys TYPE TABLE FOR ACTION IMPORT zi_pm_pride_route_det_m~calcCount.

    READ ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
      ENTITY zi_pm_pride_route_mp_m
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_mp_details).

    lt_parent_keys = CORRESPONDING #( lt_mp_details
                       MAPPING
*                       %tky      = %tky
                               routeid   = routeid
                               equipment = equipment ).
    DELETE ADJACENT DUPLICATES FROM lt_parent_keys COMPARING routeid equipment.

    IF lt_parent_keys IS NOT INITIAL.
      MODIFY ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
        ENTITY zi_pm_pride_route_det_m
        EXECUTE calcCount FROM CORRESPONDING #( lt_parent_keys )
        EXECUTE calcFomula FROM CORRESPONDING #( lt_parent_keys ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
