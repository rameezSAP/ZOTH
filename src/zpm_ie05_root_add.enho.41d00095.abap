"Name: \IC:MIEQUI20\EX:MIEQUI20_06\EI
ENHANCEMENT 0 ZPM_IE05_ROOT_ADD.
*  BREAK amahmood.
  TYPES : BEGIN OF ty_equz,
            equnr TYPE equnr,
            hequi TYPE hequi,
            eqtxt TYPE eqtxt,
            spras TYPE spras,
          END OF ty_equz.

  DATA ls_root TYPE ty_equz.
  DATA lt_equz TYPE TABLE OF ty_equz.

  DATA lv_root TYPE char1.
  DATA lv_equnr TYPE equnr.

  SELECT  a~equnr  hequi b~eqktx spras
    FROM equz AS a
    LEFT JOIN eqkt AS b ON a~equnr = b~equnr
    INTO TABLE lt_equz
    WHERE
*      b~spras = 'E'  and
    a~datbi = '99991231'.
  "WHERE
*    A~EQUNR = @ES_HEADER-EQUIPMENT AND
  "b~SPRAS = 'E'
  "AND DATBI = '99991231'.

  SORT lt_equz BY hequi ASCENDING.

  LOOP AT object_tab ASSIGNING FIELD-SYMBOL(<fs_object>) WHERE equnr IS NOT INITIAL.

    CLEAR: lv_root,lv_equnr.

    IF <fs_object>-equnr  IS NOT INITIAL.

      lv_equnr = <fs_object>-equnr.

      WHILE ( lv_root NE 'X' ).
        LOOP AT lt_equz INTO ls_root WHERE equnr EQ lv_equnr AND spras = 'E'.
          IF ls_root-hequi EQ ''.
            lv_root = 'X'.
          ELSE.
            lv_equnr = ls_root-hequi.
          ENDIF.
        ENDLOOP.
        IF sy-subrc NE 0.
          lv_root = 'X'.
        ENDIF.
      ENDWHILE.

      IF lv_equnr NE <fs_object>-equnr.
        MOVE ls_root-equnr TO <fs_object>-zroot.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = <fs_object>-zroot
          IMPORTING
            output = <fs_object>-zroot.

      ENDIF.
    ENDIF.

  ENDLOOP.


ENDENHANCEMENT.
