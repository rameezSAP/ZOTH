"Name: \PR:RIAUFK20\FO:SELECTION_L\SE:END\EI
ENHANCEMENT 0 ZPM_IW39_AND_OTHER_ENCHANCE.
*

    DATA: lv_len TYPE i,
          lv_fl3 TYPE iflo-tplnr,
          lv_fl4 TYPE iflo-tplnr.
    DATA equipment     TYPE bapi_itob_parms-equipment.

    DATA system_status TYPE STANDARD TABLE OF bapi_itob_status.
    DATA user_status   TYPE STANDARD TABLE OF bapi_itob_status.
    DATA: lv_root(1), lv_hequi TYPE equz-hequi, lv_equnr TYPE equz-equnr.

    DATA measurement_point_object TYPE impt-mpobj.
    DATA impt_tab                 TYPE STANDARD TABLE OF impt.

*Split Fuction location DataDeclaration
    DATA:lv_func_chk_3 TYPE string,
         lv_func_chk_4 TYPE string,
         s1            TYPE string,
         s2            TYPE string,
         s3            TYPE string,
         s4            TYPE string,
         s5            TYPE string,
         s6            TYPE string.

    ""Code change value
    IF object_tab[] IS NOT INITIAL.
      SELECT DISTINCT equnr, objnr FROM equi
        FOR ALL ENTRIES IN @object_tab
        WHERE equnr EQ @object_tab-equnr
        INTO TABLE @DATA(lt_equi).

      SELECT DISTINCT equnr, eqart, proid FROM itob FOR ALL ENTRIES IN @object_tab
      WHERE equnr EQ @object_tab-equnr
      AND datbi = ( SELECT MAX( datbi ) FROM itob WHERE equnr EQ @object_tab-equnr )
      INTO TABLE @DATA(lt_eqart).

      SELECT a~aufnr, a~gltrp, b~pernr INTO TABLE @DATA(lt_afko_afvc) FROM afko AS a
        INNER JOIN afvc AS b ON a~aufpl = b~aufpl
        FOR ALL ENTRIES IN @object_tab
        WHERE a~aufnr EQ @object_tab-aufnr.


      SELECT equnr, hequi
        FROM equz
        INTO TABLE @DATA(lt_root)
*        FOR ALL ENTRIES IN @OBJECT_TAB
*        WHERE EQUNR EQ @OBJECT_TAB-EQUNR
        WHERE datbi EQ '99991231'.
*        AND DATBI EQ '99991231'.

      SELECT qmnum, fegrp FROM viqmfe FOR ALL ENTRIES IN @object_tab
        WHERE qmnum EQ @object_tab-qmnum
        AND fegrp NE ''
        INTO TABLE @DATA(lt_viqmfe) .

      SELECT aufnr, a~erdat,zremarks,zlifnr, name1 , name2, ZWEEK_CODE, ZWEEK_DESC FROM aufk AS a
        LEFT OUTER JOIN lfa1 AS b ON a~zlifnr = b~lifnr
        FOR ALL ENTRIES IN @object_tab
        WHERE aufnr = @object_tab-aufnr
        INTO TABLE @DATA(lt_aufk).

      SELECT iwerk, revnr, revtx FROM t352r FOR ALL ENTRIES IN @object_tab
        WHERE iwerk EQ @object_tab-iwerk AND revnr EQ @object_tab-revnr
        INTO TABLE @DATA(lt_t352r).

      SELECT auart, txt FROM t003p FOR ALL ENTRIES IN @object_tab
        WHERE spras EQ 'E'
        AND auart EQ @object_tab-auart
        INTO TABLE @DATA(lt_t003o).

*/*** CRF : A column "Final due date" will be added into the IW39 report. " Tuesday, August 8, 2023 9:49 AM by  Khokhar, Zeeshan N <khokhazn@uep.com.pk>
      SELECT aufnr,lacd_date
        FROM afih
        FOR ALL ENTRIES IN @object_tab
        WHERE aufnr = @object_tab-aufnr AND lacd_date IS NOT INITIAL
                INTO TABLE @DATA(lt_final_date).

*/*** CRF : Columns "Addition of Malfunction Start/End Date/Time in IW38 report. " Monday, Jun 23, 2025 3:52 PM by  Faraz Shaykh <shayfa_external@uep.com.pk>
      SELECT qmnum, ausvn, auztv, ausbs,auztb FROM viqmel FOR ALL ENTRIES IN @object_tab
        WHERE qmnum EQ @object_tab-qmnum
        INTO TABLE @DATA(lt_viqmel) .

    ENDIF.
    IF lt_eqart[] IS NOT INITIAL  .
      SELECT * FROM t370k_t INTO TABLE @DATA(lt_eartx) FOR ALL ENTRIES IN @lt_eqart
        WHERE spras EQ 'E' AND eqart EQ @lt_eqart-eqart.
    ENDIF.
    LOOP AT object_tab INTO DATA(ls_tab).
      LOOP AT lt_eqart INTO DATA(ls_eqart) WHERE equnr EQ ls_tab-equnr.
        ls_tab-zzeqart = ls_eqart-eqart.
        ls_tab-zzproid = ls_eqart-proid.
      ENDLOOP.
      LOOP AT lt_eartx INTO DATA(ls_eartx) WHERE eqart EQ ls_tab-zzeqart.
        ls_tab-zzeartx = ls_eartx-eartx.
      ENDLOOP.
      LOOP AT lt_afko_afvc INTO DATA(ls_afko_afvc) WHERE aufnr EQ ls_tab-aufnr.
        ls_tab-zzgltrp = ls_afko_afvc-gltrp.
        ls_tab-zzpernr = ls_afko_afvc-pernr.
      ENDLOOP.
      IF ls_tab-equnr IS NOT INITIAL.
        CLEAR: system_status[], equipment.
        equipment = ls_tab-equnr.
        CALL FUNCTION 'BAPI_EQUI_GETSTATUS'
          EXPORTING
            equipment     = equipment
            language      = sy-langu
          TABLES
            system_status = system_status
            user_status   = user_status.
        LOOP AT system_status INTO DATA(ls_status).
          ls_tab-zztext4 = ls_status-text.
        ENDLOOP.

      ENDIF.
        LOOP AT lt_viqmel ASSIGNING FIELD-SYMBOL(<fs_viqmel>) WHERE qmnum = ls_tab-qmnum.

          ls_tab-zmlf_sdate = <fs_viqmel>-ausbs.
          ls_tab-zmlf_edate = <fs_viqmel>-ausvn.
          ls_tab-zmlf_stime = <fs_viqmel>-auztb.
          ls_tab-zmlf_etime = <fs_viqmel>-auztv.

        ENDLOOP.

      CLEAR: lv_len,lv_fl3,lv_fl4.

      lv_len = strlen( ls_tab-tplnr ).

      IF lv_len IS NOT INITIAL AND lv_len GE 12.
*        LV_FL3 = LS_TAB-TPLNR+0(12).
        SPLIT ls_tab-tplnr AT '-' INTO s1 s2 s3 s4 s5 s6.
        CONCATENATE s1 s2 s3 INTO lv_func_chk_3 SEPARATED BY '-'.
        SELECT SINGLE pltxu INTO  ls_tab-zzfl3 FROM iflo WHERE tplnr = lv_func_chk_3 AND spras EQ 'E'.
*        SELECT SINGLE PLTXT INTO LS_TAB-ZZFL3 FROM IFLO WHERE TPLNR EQ LV_FL3 AND SPRAS EQ 'E'.

        IF lv_len GE 17.
*          LV_FL4 = LS_TAB-TPLNR+0(17).
          CONCATENATE s1 s2 s3 s4 INTO lv_func_chk_4 SEPARATED BY '-'.
          SELECT SINGLE pltxu INTO  ls_tab-zzfl4 FROM iflo WHERE tplnr = lv_func_chk_4 AND spras EQ 'E'.
*        SELECT SINGLE PLTXT INTO LS_TAB-ZZFL4 FROM IFLO WHERE TPLNR EQ LV_FL4 AND SPRAS EQ 'E'.
        ENDIF.

      ENDIF.
      """ROOT
      CLEAR: lv_root, lv_hequi, lv_equnr.
      lv_equnr = ls_tab-equnr.
      IF lv_equnr IS NOT INITIAL.
        WHILE ( lv_root NE 'X' ).

          LOOP AT lt_root INTO DATA(ls_root) WHERE equnr EQ lv_equnr.
            IF ls_root-hequi EQ ''.
              lv_root = 'X'.
            ELSE.
              lv_equnr = ls_root-hequi.
            ENDIF.
          ENDLOOP.
          IF sy-subrc NE 0.
            lv_root = 'X'.
          ENDIF.
*              read table lt_root into data(ls_root) WITH TABLE KEY equnr
        ENDWHILE.


        CLEAR: system_status[], equipment.
        ls_tab-zzroot = lv_equnr.
*        SELECT SINGLE TIDNR, SHTXT INTO ( @LS_TAB-ZZROOT, @LS_TAB-ZZROOT_DES ) FROM ITOB WHERE EQUNR = @LS_TAB-ZZROOT AND DATBI EQ '99991231'.
        SELECT SINGLE shtxt INTO ( @ls_tab-zzroot_des ) FROM itob WHERE equnr = @ls_tab-zzroot AND datbi EQ '99991231'.
*        EQUIPMENT = LV_EQUNR.
*        CALL FUNCTION 'BAPI_EQUI_GETSTATUS'
*          EXPORTING
*            EQUIPMENT     = EQUIPMENT
*            LANGUAGE      = SY-LANGU
*          TABLES
*            SYSTEM_STATUS = SYSTEM_STATUS
*            USER_STATUS   = USER_STATUS.
*        LOOP AT SYSTEM_STATUS INTO LS_STATUS.
*          LS_TAB-ZZROOT_DES = LS_STATUS-DESCRIPTION.
*        ENDLOOP.
        SHIFT ls_tab-zzroot LEFT DELETING LEADING '0'.

      ENDIF.


      """""""""""""""""""""""""""""""""""""""""METER READING

      READ TABLE lt_equi INTO DATA(ls_equi) WITH KEY equnr = ls_tab-equnr.
      IF sy-subrc EQ 0.
        CLEAR: measurement_point_object.
        measurement_point_object = ls_equi-objnr.

**********        CALL FUNCTION 'MEASUREM_POINTS_READ_TO_OBJECT'
**********          EXPORTING
**********            MEASUREMENT_POINT_OBJECT = MEASUREMENT_POINT_OBJECT
**********          TABLES
**********            IMPT_TAB                 = IMPT_TAB
**********          EXCEPTIONS
**********            NO_ENTRY_FOUND           = 1.
**********
**********        SORT IMPT_TAB DESCENDING BY POINT.
**********        READ TABLE IMPT_TAB INTO DATA(LS_IMPT) INDEX 1.
**********        LS_TAB-ZZMETER_READING = LS_IMPT-POINT.
**********        LS_TAB-ZZMETER_DESC = LS_IMPT-PTTXT.
**********        LS_TAB-ZZMETER_UPDATE = LS_IMPT-ERDAT.
***********        LS_TAB-ZZMETER_NAME = LS_IMPT-POINT.
**********        LS_TAB-ZZMETER_NAME = LS_IMPT-PSORT.
**********        CONDENSE LS_TAB-ZZMETER_NAME.
**********        SHIFT LS_TAB-ZZMETER_NAME LEFT DELETING LEADING '0'.
**********
**********        SELECT SINGLE RECDV INTO @DATA(ls_RECDV) FROM IMRG WHERE POINT EQ @LS_IMPT-POINT AND MDOCM = ( SELECT MAX( MDOCM ) FROM IMRG WHERE POINT = @LS_IMPT-POINT  ).
**********
**********        DATA I_NUMBER_OF_DIGITS       TYPE CHA_CLASS_DATA-STELLEN.
**********        DATA I_FLTP_VALUE             TYPE CHA_CLASS_DATA-SOLLWERT.
**********        DATA I_VALUE_NOT_INITIAL_FLAG TYPE CHA_CLASS_DATA-SOLLWNI.
**********        DATA I_SCREEN_FIELDLENGTH     TYPE ICON-OLENG.
**********        DATA E_CHAR_FIELD             TYPE CHA_CLASS_VIEW-SOLLWERT.
**********        I_NUMBER_OF_DIGITS = 2.
**********        CALL FUNCTION 'QSS0_FLTP_TO_CHAR_CONVERSION'
**********          EXPORTING
**********            I_NUMBER_OF_DIGITS = I_NUMBER_OF_DIGITS
**********            I_FLTP_VALUE       = ls_RECDV
***********           I_VALUE_NOT_INITIAL_FLAG       = 'X'
***********           I_SCREEN_FIELDLENGTH           = 16
**********          IMPORTING
**********            E_CHAR_FIELD       = E_CHAR_FIELD.
**********        LS_TAB-ZZMETER_READING = E_CHAR_FIELD.



        CLEAR: impt_tab[], ls_equi, impt_tab, measurement_point_object.
      ENDIF.

      READ TABLE lt_t352r INTO DATA(ls_t352r1) WITH KEY iwerk = ls_tab-iwerk revnr = ls_tab-revnr.
      IF sy-subrc EQ 0.
        ls_tab-zzrevtx = ls_t352r1-revtx.
      ENDIF.

      READ TABLE lt_t003o INTO DATA(ls_t003o) WITH KEY auart = ls_tab-auart.
      IF sy-subrc EQ 0.
        CONCATENATE ls_t003o-auart ls_t003o-txt INTO ls_tab-zzwork_type SEPARATED BY '-'.
      ENDIF.

      READ TABLE lt_viqmfe INTO DATA(ls_viqmfe) WITH KEY qmnum = ls_tab-qmnum.
      IF sy-subrc EQ 0.
        ls_tab-zzfegrp = ls_viqmfe-fegrp.
      ENDIF.

*/*** CRF : A column "Final due date" will be added into the IW39 report. " Tuesday, August 8, 2023 9:49 AM by  Khokhar, Zeeshan N <khokhazn@uep.com.pk>
      ls_tab-zlacd_date = VALUE #( lt_final_date[ aufnr = ls_tab-aufnr ]-lacd_date DEFAULT '').
      .
      READ TABLE lt_aufk INTO DATA(ls_aufk) WITH KEY aufnr = ls_tab-aufnr.
      IF sy-subrc EQ 0.
        ls_tab-zzreport_date = ls_aufk-erdat.
        ls_tab-zzremarks = ls_aufk-zremarks.
        ls_tab-zzlifnr  = ls_aufk-zlifnr.
        ls_tab-zzlifnr_text  = ls_aufk-name1 && ls_aufk-name2.
        ls_tab-zZWEEK_CODE = ls_aufk-ZWEEK_CODE.
        ls_tab-zZWEEK_DESC = ls_aufk-ZWEEK_DESC.
      ENDIF.
      ls_tab-zzsupervisor = ls_tab-arbpl.
      CLEAR: ls_viqmfe.
      MODIFY object_tab FROM ls_tab.
      CLEAR: impt_tab[], ls_equi, impt_tab, measurement_point_object.
    ENDLOOP.
    CLEAR: impt_tab[], ls_equi, impt_tab, measurement_point_object.

    DELETE object_tab WHERE zzpernr NOT IN s_pernr.
    DELETE object_tab WHERE zzmeter_update NOT IN s_meter.
    DELETE object_tab WHERE zztext4 NOT IN s_zztext.

ENDENHANCEMENT.
