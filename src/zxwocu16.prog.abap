*&---------------------------------------------------------------------*
*& Include          ZXWOCU16
*&---------------------------------------------------------------------*
*TABLES:AUFK.
*DATA: zw_desc_display TYPE ztpm0005-zweek_desc.
*TABLES:aufk.

*MOVE-CORRESPONDING AUFK TO COCI_AUFK_EXP.
*break fshaykh.
*TABLES:aufk.

*MOVE-CORRESPONDING AUFK TO COCI_AUFK_EXP.
*DATA: lv_zw_desc_display TYPE ztpm0005-zweek_desc.
*
*IF coci_aufk_exp-zweek_code IS NOT INITIAL.
*  SELECT SINGLE zweek_desc
*    INTO lv_zw_desc_display
*    FROM ztpm0005
*   WHERE zweek_code = coci_aufk_exp-zweek_code.
*
*  coci_aufk_exp-zweek_desc = lv_zw_desc_display.  " Ensure this field exists in CI_AUFK
*ENDIF.
*
*MOVE-CORRESPONDING: aufk TO coci_aufk_exp.

MOVE-CORRESPONDING AUFK TO COCI_AUFK_EXP.
