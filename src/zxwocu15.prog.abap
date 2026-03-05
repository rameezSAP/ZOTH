*&---------------------------------------------------------------------*
*& Include          ZXWOCU15
*&---------------------------------------------------------------------*
TABLES:AUFK.
MOVE-CORRESPONDING COCI_AUFK_IMP TO AUFK.

IF aufk-zweek_code IS NOT INITIAL.
  SELECT SINGLE zweek_desc
    INTO @DATA(lv_zw_desc_display)
    FROM ztpm0005
   WHERE zweek_code = @aufk-zweek_code.

IF aufk-zweek_desc <> lv_zw_desc_display.
  aufk-zweek_desc = lv_zw_desc_display.
ENDIF.
ENDIF.

*
*MODULE week_code_desc_get INPUT.
*
*  DATA: lv_week_code TYPE ztpm0005-week_code,
*        lv_week_desc TYPE ztpm0005-week_desc.
*
*  lv_week_code = ztpm0005-week_code.
*
*  IF NOT aufk-zweek_code IS INITIAL.
*    SELECT SINGLE zweek_desc
*      INTO @DATA(lv_zw_desc_display)
*      FROM ztpm0005
*      WHERE zweek_code = @aufk-zweek_code.
*
*    zworkorder-week_desc = lv_week_desc.
*  ELSE.
*    CLEAR zworkorder-week_desc.
*  ENDIF.
*
*ENDMODULE.
