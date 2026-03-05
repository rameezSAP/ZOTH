CLASS lhc_route DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR route RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR route RESULT result.

    METHODS completeroute FOR MODIFY
      IMPORTING keys FOR ACTION route~completeroute RESULT result.
    METHODS reopenroute FOR MODIFY
      IMPORTING keys FOR ACTION route~reopenroute RESULT result.
    METHODS checkduplicate FOR VALIDATE ON SAVE
      IMPORTING keys FOR route~checkduplicate.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR route RESULT result.
    METHODS get_global_features FOR GLOBAL FEATURES
      IMPORTING REQUEST requested_features FOR route RESULT result.
    METHODS routefield FOR VALIDATE ON SAVE
      IMPORTING keys FOR route~routefield.
    METHODS clearmp FOR DETERMINE ON SAVE
      IMPORTING keys FOR route~clearmp.
    METHODS moveactualdate FOR DETERMINE ON SAVE
      IMPORTING keys FOR route~moveactualdate.
    METHODS createNewRoute FOR DETERMINE ON MODIFY
      IMPORTING keys FOR route~createNewRoute.

*    METHODS EARLYNUMBERING_CBA_DETAILS FOR NUMBERING
*      IMPORTING ENTITIES FOR CREATE ROUTE\_DETAILS.
*    METHODS EARLYNUMBERING_CREATE FOR NUMBERING
*      IMPORTING ENTITIES FOR CREATE ROUTE.

    ""-- data BOA  by rameez 04.02.2026
    CLASS-DATA: gv_new_route_id TYPE zpm_pride_routes-route_id.
    ""-- data EOA  by rameez 04.02.2026

ENDCLASS.

CLASS lhc_route IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

*  METHOD EARLYNUMBERING_CREATE.
*    DATA(LT_ENTITIES) = ENTITIES.
*    DATA LT_ROUTES_M TYPE TABLE FOR MAPPED EARLY ZI_PM_PRIDE_ROUTE_M.
*    DATA LS_ROUTES_M LIKE LINE OF LT_ROUTES_M.
*
*
*    DELETE LT_ENTITIES WHERE ROUTEID IS NOT INITIAL.
*    TRY.
*        CL_NUMBERRANGE_RUNTIME=>NUMBER_GET(
*          EXPORTING
**           IGNORE_BUFFER     = IGNORE_BUFFER
*            NR_RANGE_NR       = '01'
*            OBJECT            = 'ZPM_ROUTE'
*            QUANTITY          = CONV #( LINES( LT_ENTITIES ) )
**           SUBOBJECT         = SUBOBJECT
**           TOYEAR            = TOYEAR
*          IMPORTING
*            NUMBER            = DATA(LV_NUM)
*            RETURNCODE        = DATA(LV_CODE)
*            RETURNED_QUANTITY = DATA(LV_QTY)
*        ).
*      CATCH CX_NR_OBJECT_NOT_FOUND.
*      CATCH CX_NUMBER_RANGES INTO DATA(LO_NUMRANGE).
*
*        LOOP AT LT_ENTITIES INTO DATA(LS_EXT).
*          APPEND VALUE #( %CID = LS_EXT-%CID
*                          %KEY = LS_EXT-%KEY
*                            ) TO FAILED-ROUTE.
*
*          APPEND VALUE #( %CID = LS_EXT-%CID
*                          %KEY = LS_EXT-%KEY
*                          %MSG = LO_NUMRANGE  ) TO REPORTED-ROUTE.
*
*        ENDLOOP.
*        EXIT.
*    ENDTRY.
*
*    ASSERT LV_QTY = LINES( LT_ENTITIES ).
*
*    DATA(LV_CURR_COUNT) = LV_NUM - LV_QTY.
*
*    LOOP AT LT_ENTITIES INTO DATA(LS_ENTITY).
*      LV_CURR_COUNT = LV_CURR_COUNT + 1.
*
*      LS_ROUTES_M = VALUE #( %CID = LS_ENTITY-%CID
*                              ROUTEID = LV_CURR_COUNT
**                              EDate = LS_ENTITY-SDate
**                              ETime = LS_ENTITY-STime
**                              SDate = LS_ENTITY-SDate
**                              STime = LS_ENTITY-STime
**                              RouteName = LS_ENTITY-RouteName
**                                    Location = LS_ENTITY-Location
*                               ).
*
*      APPEND LS_ROUTES_M TO MAPPED-ROUTE.
*    ENDLOOP.
*
*  ENDMETHOD.
*
  METHOD get_instance_features.
    DATA lv_count TYPE i.
*    READ ENTITIES OF ZI_PM_PRIDE_ROUTE_M  IN LOCAL MODE
*
*    ENTITY ZI_PM_PRIDE_ROUTE_DET_M
*    FIELDS ( EQUIPMENT REM_COUNT ISACTIVE ) WITH CORRESPONDING #( KEYS )
*    RESULT DATA(LT_RESULT).
    READ ENTITY IN LOCAL MODE zi_pm_pride_route_m BY \_details
    FIELDS ( equipment rem_count isactive ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    CLEAR lv_count.



    READ ENTITY IN LOCAL MODE zi_pm_pride_route_m
    ALL FIELDS WITH   CORRESPONDING #( keys )
        RESULT DATA(lt_result_route).

    LOOP AT lt_result_route ASSIGNING FIELD-SYMBOL(<fs_rt>).
      CLEAR lv_count.
      LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_result>) WHERE routeid = <fs_rt>-routeid.
        lv_count = <fs_result>-rem_count  + lv_count.
      ENDLOOP.
      APPEND VALUE #(  %tky = <fs_rt>-%tky
                                                         %features-%action-completeroute = COND #( WHEN lv_count = 0
                                                                                              THEN if_abap_behv=>mk-off
                                                                                              WHEN lv_count > 0
                                                                                              THEN if_abap_behv=>mk-on   ) ) TO result.

*    RESULT  = VALUE #( FOR LV_RT_D IN LT_RESULT_ROUTE (  %TKY = LV_RT_D-%TKY
*                                                   %FEATURES-%ACTION-COMPLETEROUTE = COND #( WHEN LV_COUNT = 0
*                                                                                        THEN IF_ABAP_BEHV=>MK-OFF
*                                                                                        WHEN LV_COUNT > 0
*                                                                                        THEN IF_ABAP_BEHV=>MK-ON   ) ) ).
    ENDLOOP..

  ENDMETHOD.

  METHOD completeroute.

    CLEAR: gv_new_route_id.

    "-- commented by rameez 04.02.2026
*    READ ENTITY IN LOCAL MODE zi_pm_pride_route_m
*        ALL FIELDS WITH CORRESPONDING #( keys )
*        RESULT DATA(lt_rt_det_before) .
    "-- commented by rameez 04.02.2026

    MODIFY ENTITY  IN LOCAL MODE zi_pm_pride_route_m
        UPDATE FIELDS ( active )
        WITH VALUE #( FOR lv_key IN keys ( %tky    = lv_key-%tky
                                            active = 'C') ) .

    APPEND VALUE #( %tky = keys[ 1 ]-%tky
    %msg        = new_message(
                             id = zcl_pm_pride_constants=>c_messageid
                         number = '010'
                         v1 = gv_new_route_id
                       severity = if_abap_behv_message=>severity-success )

    %element-routeid = if_abap_behv=>mk-on   ) TO reported-route.


    READ ENTITY IN LOCAL MODE zi_pm_pride_route_m
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_rt_det) .

    result = VALUE #( FOR ls_rt_det IN lt_rt_det ( %tky = ls_rt_det-%tky
    %param = ls_rt_det ) ).


    ""--- commented by rameez 04.02.2026 ( call new determination as single entry point)
*    LOOP AT lt_rt_det_before ASSIGNING FIELD-SYMBOL(<fs_routes>).
*      IF <fs_routes>-active = 'X'.
*
**/***** Create the new route with reference to current route.
*
*        zcl_pm_pride=>create_with_ref(
*          EXPORTING
*            route_id     = <fs_routes>-routeid
**           START_DATE   = <FS_ROUTES>-SDATE
*            start_date   = <fs_routes>-edate
*            schedule     = <fs_routes>-sechedule
**           START_TIME   = <FS_ROUTES>-STIME
*            start_time   = <fs_routes>-etime
*          IMPORTING
*            new_route_id = DATA(new_route_id)
*        ).
*
*        APPEND VALUE #( %tky = <fs_routes>-%tky
*        %msg        = new_message(
*                                 id = zcl_pm_pride_constants=>c_messageid
*                             number = '010'
*                             v1 = new_route_id
*                           severity = if_abap_behv_message=>severity-success )
*
*        %element-routeid = if_abap_behv=>mk-on   ) TO reported-route.
*      ENDIF.
*    ENDLOOP..
    ""--- commented by rameez 04.02.2026 ( call new determination as single entry point)

  ENDMETHOD.

*  METHOD earlynumbering_cba_Details.
*  ENDMETHOD.

  METHOD reopenroute.
    MODIFY ENTITY  IN LOCAL MODE zi_pm_pride_route_m
"    ENTITY ZI_PM_PRIDE_ROUTE_DET_M
UPDATE FIELDS ( active )
WITH VALUE #( FOR lv_key IN keys ( %tky = lv_key-%tky
                                    active = 'I') ) .

    READ ENTITY IN LOCAL MODE zi_pm_pride_route_m
 "   ENTITY ZI_PM_PRIDE_ROUTE_M
 ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_rt_det) .

    result = VALUE #( FOR ls_rt_det IN lt_rt_det ( %tky = ls_rt_det-%tky
    %param = ls_rt_det ) ).

  ENDMETHOD.

*  METHOD CHECKDUPLICATE.
*    READ ENTITY IN LOCAL MODE ZI_PM_PRIDE_ROUTE_M
*"   ENTITY ZI_PM_PRIDE_ROUTE_M
*ALL FIELDS WITH CORRESPONDING #( KEYS )
*RESULT DATA(LT_RT_DET_BEFORE) .
*
*    LOOP AT LT_RT_DET_BEFORE ASSIGNING FIELD-SYMBOL(<FS_ROUTE>).
*      SELECT SINGLE * FROM ZI_PM_PRIDE_ROUTE_M WHERE ROUTEREFID = <FS_ROUTE>-ROUTEREFID AND EDATE = <FS_ROUTE>-EDATE AND ETIME = <FS_ROUTE>-ETIME.
*      IF SY-SUBRC = 0.
*
*      ELSE.
*
*      ENDIF.
*    ENDMETHOD.

  METHOD checkduplicate.
    READ ENTITY IN LOCAL MODE zi_pm_pride_route_m
"   ENTITY ZI_PM_PRIDE_ROUTE_M
ALL FIELDS WITH CORRESPONDING #( keys )
RESULT DATA(lt_rt_det_before) .

    LOOP AT lt_rt_det_before ASSIGNING FIELD-SYMBOL(<fs_route>).
      SELECT SINGLE * FROM zi_pm_pride_route_m  INTO @DATA(ls_route)
      WHERE routerefid = @<fs_route>-routerefid AND edate = @<fs_route>-edate AND etime = @<fs_route>-etime.
      IF sy-subrc = 0.

*              DATA(LV_MSG) =  <FS_ROUTE>-MEASUREPOINT && '/' && <FS_RESULT>-MPDESC.
        APPEND VALUE #( %tky = <fs_route>-%tky %msg = new_message(
                                 id = zcl_pm_pride_constants=>c_messageid
                                 number = '005'
                                 v1 = <fs_route>-edate
                                 v2 = <fs_route>-etime
*                                       V3 = LV_MSG
                           severity = if_abap_behv_message=>severity-error )
                            %element-value = if_abap_behv=>mk-on  ) TO reported-zi_pm_pride_route_mp_m.
*              CLEAR LV_MSG.
      ELSE.

*        READ ENTITIES OF ZI_PM_PRIDE_ROUTE_M IN LOCAL MODE
*            ENTITY ZI_PM_PRIDE_ROUTE_MP_M
*            ALL FIELDS WITH CORRESPONDING #( KEYS )
*            RESULT DATA(LT_RT_MP) .
*
*        LOOP AT LT_RT_MP ASSIGNING FIELD-SYMBOL(<FS_MP>).
*
*        ENDLOOP.
*
*        MODIFY ENTITIES OF ZI_PM_PRIDE_ROUTE_M IN LOCAL MODE
*         ENTITY ZI_PM_PRIDE_ROUTE_MP_M UPDATE FIELDS ( VALUE )
*         WITH VALUE #( FOR LS_KEY IN LT_RT_MP ( %TKY = LS_KEY-%TKY VALUE = 0 )  )
*         MAPPED DATA(LT_MAPPED)
*         FAILED DATA(LT_FAILED)
*         REPORTED DATA(LT_REPORTED).
*
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.

  ENDMETHOD.

  METHOD get_global_features.


    result-%assoc-_details = if_abap_behv=>auth-unauthorized.
*         = if_abap_behv=>auth-unauthorized.

  ENDMETHOD.

  METHOD routefield.

    READ ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
  ENTITY route
  ALL FIELDS WITH CORRESPONDING #( keys )
  RESULT DATA(lt_results).

    LOOP AT lt_results ASSIGNING FIELD-SYMBOL(<fs_result_route>).

      IF <fs_result_route>-routename IS INITIAL.
        APPEND VALUE #( %tky = <fs_result_route>-%tky %msg = new_message(
                               id = zcl_pm_pride_constants=>c_messageid
                           number = '006'
                           v1 = <fs_result_route>-sdate
                           v2 = <fs_result_route>-stime
                         severity = if_abap_behv_message=>severity-error )
                         %element-routename = if_abap_behv=>mk-on ) TO reported-route.

      ELSEIF <fs_result_route>-sechedule IS INITIAL.

        APPEND VALUE #( %tky = <fs_result_route>-%tky %msg = new_message(
                               id = zcl_pm_pride_constants=>c_messageid
                           number = '008'
                           v1 = <fs_result_route>-sdate
                           v2 = <fs_result_route>-stime
                         severity = if_abap_behv_message=>severity-error )
                         %element-sechedule = if_abap_behv=>mk-on ) TO reported-route.

      ELSEIF <fs_result_route>-sdate IS INITIAL.
        APPEND VALUE #( %tky = <fs_result_route>-%tky %msg = new_message(
                         id = zcl_pm_pride_constants=>c_messageid
                     number = '022'
                     v1 = <fs_result_route>-sdate
                     v2 = <fs_result_route>-stime
                   severity = if_abap_behv_message=>severity-error )
                   %element-sdate = if_abap_behv=>mk-on ) TO reported-route.

      ELSEIF <fs_result_route>-location IS INITIAL.
        APPEND VALUE #( %tky = <fs_result_route>-%tky %msg = new_message(
                               id = zcl_pm_pride_constants=>c_messageid
                           number = '007'
                           v1 = <fs_result_route>-sdate
                           v2 = <fs_result_route>-stime
                         severity = if_abap_behv_message=>severity-error )
                         %element-location = if_abap_behv=>mk-on ) TO reported-route.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD clearmp.
    DATA ls_route_header TYPE zi_pm_pride_route_m.
    DATA ls_create_mp TYPE STRUCTURE FOR CREATE zi_pm_pride_route_det_m\_detailsmp.
    DATA lt_create_mp_t LIKE ls_create_mp-%target.
    DATA ls_create_mp_t LIKE LINE OF lt_create_mp_t.
    DATA ls_create_det TYPE STRUCTURE FOR CREATE zi_pm_pride_route_m\_details.
    DATA lt_create_det_t LIKE ls_create_det-%target.
    DATA ls_create_det_t LIKE LINE OF lt_create_det_t.

    READ ENTITY IN LOCAL MODE zi_pm_pride_route_m
  "   ENTITY ZI_PM_PRIDE_ROUTE_M
  ALL FIELDS WITH CORRESPONDING #( keys )
  RESULT DATA(lt_rt_det_before) .

    LOOP AT lt_rt_det_before ASSIGNING FIELD-SYMBOL(<fs_route>).
      SELECT SINGLE * FROM zi_pm_pride_route_m  INTO @DATA(ls_route)
      WHERE routerefid = @<fs_route>-routerefid AND edate = @<fs_route>-edate AND etime = @<fs_route>-etime.
      IF sy-subrc = 0.
*
**              DATA(LV_MSG) =  <FS_ROUTE>-MEASUREPOINT && '/' && <FS_RESULT>-MPDESC.
*        APPEND VALUE #( %TKY = <FS_ROUTE>-%TKY %MSG = NEW_MESSAGE(
*                                 ID = ZCL_PM_PRIDE_CONSTANTS=>C_MESSAGEID
*                                 NUMBER = '005'
*                                 V1 = <FS_ROUTE>-EDATE
*                                 V2 = <FS_ROUTE>-ETIME
**                                       V3 = LV_MSG
*                           SEVERITY = IF_ABAP_BEHV_MESSAGE=>SEVERITY-ERROR )
*                            %ELEMENT-VALUE = IF_ABAP_BEHV=>MK-ON  ) TO REPORTED-ZI_PM_PRIDE_ROUTE_MP_M.
*              CLEAR LV_MSG.
      ELSE.


        MOVE-CORRESPONDING <fs_route> TO ls_route_header.

        zcl_pm_pride=>change_data_after_date_change(
          EXPORTING
            is_route_header = ls_route_header
          IMPORTING
            et_mp           = DATA(lt_mp)
            et_det          = DATA(lt_det)
        ).

        SELECT * FROM zi_pm_pride_route_det_m INTO TABLE @DATA(lt_route_det) WHERE routeid = @ls_route_header-routeid.
        SELECT * FROM zi_pm_pride_route_mp_m INTO TABLE @DATA(lt_route_mp) WHERE routeid = @ls_route_header-routeid.


        MODIFY ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
             ENTITY zi_pm_pride_route_det_m
*             DELETE FROM VALUE #( ( ROUTEID = LS_ROUTE_HEADER-ROUTEID ) )
             DELETE FROM VALUE #( FOR row IN lt_route_det ( %tky-routeid = row-routeid %tky-equipment = row-equipment ) )
*             UPDATE FIELDS ( ISACTIVE )
*             WITH VALUE #( FOR LS_KEY IN LT_RT_MP ( %TKY = LS_KEY-%TKY ISACTIVE = 'X'  )  )
             MAPPED DATA(lt_mapped1)
             FAILED DATA(lt_failed1)
             REPORTED DATA(lt_reported1).

        MODIFY ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
             ENTITY zi_pm_pride_route_mp_m
             DELETE FROM VALUE #( FOR row_mp IN lt_route_mp ( %tky-routeid = row_mp-routeid %tky-equipment = row_mp-equipment %tky-measurepoint = row_mp-measurepoint ) )
*             UPDATE FIELDS ( ISACTIVE )
*             WITH VALUE #( FOR LS_KEY IN LT_RT_MP ( %TKY = LS_KEY-%TKY ISACTIVE = 'X'  )  )
             MAPPED DATA(lt_mapped2)
             FAILED DATA(lt_failed2)
             REPORTED DATA(lt_reported2).


*/*********************** Update the Equipments***********************
        LOOP AT lt_det ASSIGNING FIELD-SYMBOL(<fs_det>).
          ls_create_det_t =  VALUE #( %cid = <fs_det>-equipment && <fs_det>-routeid
                                          %control-equipment = if_abap_behv=>mk-on
                                          %control-formulatext = if_abap_behv=>mk-on
                                          %control-funcloc = if_abap_behv=>mk-on
                                          %control-pridedescription = if_abap_behv=>mk-on
                                          %control-routeid = if_abap_behv=>mk-on
                                          %control-techtype = if_abap_behv=>mk-on
                                          %control-critical = if_abap_behv=>mk-on
                                          %control-formula = if_abap_behv=>mk-on
                                          %control-formula_typ = if_abap_behv=>mk-on
                                          %control-frequency = if_abap_behv=>mk-on
                                          %control-isactive = if_abap_behv=>mk-on
                                          %control-neg = if_abap_behv=>mk-on
                                          %control-pos = if_abap_behv=>mk-on
                                          ) .
          MOVE-CORRESPONDING <fs_det> TO ls_create_det_t.
          APPEND ls_create_det_t  TO  lt_create_det_t.
        ENDLOOP.

        IF lt_create_det_t IS NOT INITIAL.
          MODIFY ENTITY IN LOCAL MODE zi_pm_pride_route_m
                  CREATE BY \_details
                                FROM VALUE #( ( %key = <fs_route>-%key
                                %target = lt_create_det_t   ) )
                    MAPPED DATA(mapped)
                    FAILED DATA(failed)
                    REPORTED DATA(lt_c_reported).

        ENDIF.


        READ ENTITIES OF  zi_pm_pride_route_m IN LOCAL MODE
        ENTITY route BY \_details
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_det_data) .


*/*********************** Update the Measuring Point***********************
        LOOP AT lt_det_data ASSIGNING FIELD-SYMBOL(<fs_det_upd>).

          LOOP AT lt_mp ASSIGNING FIELD-SYMBOL(<fs_mp>) WHERE equipment = <fs_det_upd>-equipment.
            ls_create_mp_t =  VALUE #( %cid = <fs_mp>-measurepoint
                                              measurepoint = <fs_mp>-measurepoint
                                              value = '0'
                                              uom = <fs_mp>-uom
                                              isactive = 'X'
                                            %control-measurepoint = if_abap_behv=>mk-on
                                            %control-value = if_abap_behv=>mk-on
                                            %control-uom = if_abap_behv=>mk-on
                                            %control-isactive = if_abap_behv=>mk-on
                                            %control-highlimit = if_abap_behv=>mk-on
                                            %control-lowlimit = if_abap_behv=>mk-on
                                            %control-funcloc = if_abap_behv=>mk-on
                                            %control-CodeGroup = if_abap_behv=>mk-on
                                            %control-MPDesc = if_abap_behv=>mk-on
                                            %control-MPPosition = if_abap_behv=>mk-on
                                            %control-MPPositionChar = if_abap_behv=>mk-on
                                            %control-critical = if_abap_behv=>mk-on
                                            %control-formula_typ = if_abap_behv=>mk-on
                                            %control-formula_main = if_abap_behv=>mk-on
                                            %control-formulaMP = if_abap_behv=>mk-on

                                            ) .
            MOVE-CORRESPONDING <fs_mp> TO ls_create_mp_t.
            APPEND ls_create_mp_t  TO  lt_create_mp_t.
          ENDLOOP.

          IF lt_create_mp_t IS NOT INITIAL.
            MODIFY ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
               ENTITY zi_pm_pride_route_det_m
               CREATE BY \_detailsmp
                        FROM VALUE #( ( %key = <fs_det_upd>-%key
                        %target = lt_create_mp_t   ) )
            MAPPED mapped
            FAILED failed
            REPORTED DATA(lt_c_reported1).

            CLEAR lt_create_mp_t.
          ENDIF.
        ENDLOOP.
*          MODIFY ENTITY IN LOCAL MODE ZI_PM_PRIDE_ROUTE_M
*          CREATE BY \_DETAILS
*               AUTO FILL CID
**            CREATE FIELDS ( Equipment )
*              WITH CORRESPONDING #( LT_DET )
*              REPORTED DATA(LS_REPORTED)
*              FAILED   DATA(LS_FAILED).
*
*
*
*          MODIFY ENTITIES OF ZI_PM_PRIDE_ROUTE_M IN LOCAL MODE
*          ENTITY ZI_PM_PRIDE_ROUTE_DET_M
*              CREATE BY \_DETAILSMP
*               AUTO FILL CID
**            CREATE FIELDS ( Equipment )
*              WITH CORRESPONDING #( LT_MP )
*              REPORTED DATA(LS_REPORTED1)
*              FAILED   DATA(LS_FAILED1).

*COMMIT ENTITIES RESPONSE OF ZI_PM_PRIDE_ROUTE_M

*        READ ENTITIES OF ZI_PM_PRIDE_ROUTE_M IN LOCAL MODE
*            ENTITY ROUTE BY \_DETAILS  " ZI_PM_PRIDE_ROUTE_MP_M
*            FIELDS ( ROUTEID EQUIPMENT )
*             WITH CORRESPONDING #( KEYS )
*            RESULT DATA(LT_RT_MP).
*
*        READ ENTITIES OF ZI_PM_PRIDE_ROUTE_M IN LOCAL MODE
*            ENTITY ZI_PM_PRIDE_ROUTE_DET_M BY \_DETAILSMP
*            ALL FIELDS WITH CORRESPONDING #( LT_RT_MP )
*            RESULT DATA(LT_MP).
*
*
*        LOOP AT LT_RT_MP ASSIGNING FIELD-SYMBOL(<FS_MP>).
*
*        ENDLOOP.
*        MODIFY ENTITIES OF ZI_PM_PRIDE_ROUTE_M IN LOCAL MODE
*             ENTITY ZI_PM_PRIDE_ROUTE_DET_M UPDATE FIELDS ( ISACTIVE )
*             WITH VALUE #( FOR LS_KEY IN LT_RT_MP ( %TKY = LS_KEY-%TKY ISACTIVE = 'X'  )  )
*             MAPPED DATA(LT_MAPPED1)
*             FAILED DATA(LT_FAILED1)
*             REPORTED DATA(LT_REPORTED1).
*        .
*
*        MODIFY ENTITIES OF ZI_PM_PRIDE_ROUTE_M IN LOCAL MODE
*         ENTITY ZI_PM_PRIDE_ROUTE_MP_M
*         EXECUTE RESETMP
*         FROM CORRESPONDING #( LT_MP )
*         MAPPED DATA(LT_MAPPED)
*         FAILED DATA(LT_FAILED)
*         REPORTED DATA(LT_REPORTED).

*        MODIFY ENTITIES OF ZI_PM_PRIDE_ROUTE_M IN LOCAL MODE
*         ENTITY ZI_PM_PRIDE_ROUTE_MP_M UPDATE FIELDS ( VALUE )
*         WITH VALUE #( FOR LS_KEY IN LT_RT_MP ( %TKY = LS_KEY-%TKY VALUE = 0 )  )
*         MAPPED DATA(LT_MAPPED)
*         FAILED DATA(LT_FAILED)
*         REPORTED DATA(LT_REPORTED).

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD moveactualdate.


    READ ENTITY IN LOCAL MODE zi_pm_pride_route_m
     ALL FIELDS WITH CORRESPONDING #( keys )
     RESULT DATA(lt_rt_det) .

    LOOP AT lt_rt_det ASSIGNING FIELD-SYMBOL(<fs_rt_det>).
      DATA lv_time_char TYPE char6.
      <fs_rt_det>-etimeeven = <fs_rt_det>-ETime(2).
*      LV_TIME_CHAR =  <FS_RT_DET>-ETIMEEVEN && '0000'.
*      MOVE LV_TIME_CHAR TO <FS_RT_DET>-ETIME.
    ENDLOOP.

    MODIFY ENTITY  IN LOCAL MODE zi_pm_pride_route_m
        UPDATE FIELDS ( etimeeven )
        WITH VALUE #( FOR lv_key IN lt_rt_det ( %tky = lv_key-%tky
                                      etimeeven = lv_key-etimeeven ) ) .
*    LOOP AT LT_RT_DET ASSIGNING FIELD-SYMBOL(<FS_RT_DET>).
*      DATA LV_TIME_CHAR TYPE CHAR6.
*
*      LV_TIME_CHAR =  <FS_RT_DET>-ETIMEEVEN && '0000'.
*      MOVE LV_TIME_CHAR TO <FS_RT_DET>-ETIME.
*    ENDLOOP.
*
*    MODIFY ENTITY  IN LOCAL MODE ZI_PM_PRIDE_ROUTE_M
*        UPDATE FIELDS ( ETIME )
*        WITH VALUE #( FOR LV_KEY IN LT_RT_DET ( %TKY = LV_KEY-%TKY
*                                      ETIME = LV_KEY-ETIME ) ) .


  ENDMETHOD.

  METHOD createNewRoute.

    READ ENTITIES OF zi_pm_pride_route_m IN LOCAL MODE
      ENTITY route
      FIELDS ( Active RouteId EDate ETime Sechedule )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_routes).

    LOOP AT lt_routes ASSIGNING FIELD-SYMBOL(<fs_route>).
      IF <fs_route>-Active = 'C'.

        zcl_pm_pride=>create_with_ref(
          EXPORTING
            route_id     = <fs_route>-RouteId
            start_date   = <fs_route>-EDate
            schedule     = <fs_route>-Sechedule
            start_time   = <fs_route>-ETime
          IMPORTING
            new_route_id = DATA(lv_new_id)
        ).

        gv_new_route_id = lv_new_id.

*        APPEND VALUE #( %tky = <fs_route>-%tky
*                        %msg = new_message(
*                                 id       = zcl_pm_pride_constants=>c_messageid
*                                 number   = '010'
*                                 v1       = lv_new_id
*                                 severity = if_abap_behv_message=>severity-success )
*                      ) TO reported-route.
      ENDIF.
    ENDLOOP..

  ENDMETHOD.

ENDCLASS.
