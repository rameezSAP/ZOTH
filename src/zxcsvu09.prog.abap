*&---------------------------------------------------------------------*
*& Include          ZXCSVU09
*&---------------------------------------------------------------------*

BREAK AC_OWAIS.

*loop at IT_FIELDCAT[] ASSIGNING <FS>.
LOOP AT IT_FIELDCAT INTO DATA(LS_FIELDCAT) WHERE FIELDNAME EQ 'ZZEQART' OR FIELDNAME EQ 'ZZTEXT4' OR FIELDNAME EQ 'ZZEQFNR' OR FIELDNAME EQ 'ZZGLTRS'
  OR FIELDNAME EQ 'ZZEARTX' OR FIELDNAME EQ 'ZZGLTRP' OR FIELDNAME EQ 'ZZPERNR' OR FIELDNAME EQ 'ERNAM' OR FIELDNAME EQ 'ZZFL3' OR FIELDNAME EQ 'ZZFL4'
  OR FIELDNAME EQ 'ZZROOT' OR FIELDNAME EQ 'ZZROOT_DES' OR FIELDNAME EQ 'ZZPROID' OR FIELDNAME EQ 'ZZPLTXT'
  OR FIELDNAME EQ 'ZZMETER_READING' OR FIELDNAME EQ 'ZZMETER_DESC' OR FIELDNAME EQ 'ZZMETER_UPDATE' OR FIELDNAME EQ 'ZZFEGRP' OR FIELDNAME EQ 'ZZREPORT_DATE'
  OR FIELDNAME EQ 'ZZMETER_NAME' OR FIELDNAME EQ 'ZZSUPERVISOR' OR FIELDNAME EQ 'ZZREVTX' OR FIELDNAME EQ 'ZZWORK_TYPE'. "ZZWORK_TYPE
  IF LS_FIELDCAT-FIELDNAME EQ 'ZZEQART'.
    LS_FIELDCAT-SELTEXT_L = 'Equipment Category(Object Type)'.
    LS_FIELDCAT-SELTEXT_M = 'Equipment Category(Object Type)'.
    LS_FIELDCAT-SELTEXT_S = 'Equipment Category(Object Type)'.
  ENDIF.
  IF LS_FIELDCAT-FIELDNAME EQ 'ZZTEXT4'.
    LS_FIELDCAT-SELTEXT_L = 'Equipment Status'.
    LS_FIELDCAT-SELTEXT_M = 'Equipment Status'.
    LS_FIELDCAT-SELTEXT_S = 'Equipment Status'.
  ENDIF.
  IF LS_FIELDCAT-FIELDNAME EQ 'ZZEARTX'.
    LS_FIELDCAT-SELTEXT_L = 'Equip Category Desc'.
    LS_FIELDCAT-SELTEXT_M = 'Equip Category Desc'.
    LS_FIELDCAT-SELTEXT_S = 'Equip Category Desc'.
  ENDIF.
  IF LS_FIELDCAT-FIELDNAME EQ 'ZZGLTRP'.
    LS_FIELDCAT-SELTEXT_L = 'Job Required Date'.
    LS_FIELDCAT-SELTEXT_M = 'Job Required Date'.
    LS_FIELDCAT-SELTEXT_S = 'Job Required Date'.
  ENDIF.
  IF LS_FIELDCAT-FIELDNAME EQ 'ZZPERNR'.
    LS_FIELDCAT-SELTEXT_L = 'Personnel no.'.
    LS_FIELDCAT-SELTEXT_M = 'Personnel no.'.
    LS_FIELDCAT-SELTEXT_S = 'Personnel no.'.
  ENDIF.
  IF LS_FIELDCAT-FIELDNAME EQ 'ERNAM'.
    LS_FIELDCAT-SELTEXT_L = 'Reported by'.
    LS_FIELDCAT-SELTEXT_M = 'Reported by'.
    LS_FIELDCAT-SELTEXT_S = 'Reported by'.
  ENDIF.
  IF LS_FIELDCAT-FIELDNAME EQ 'ZZFL3'.
    LS_FIELDCAT-SELTEXT_L = 'Zone'.
    LS_FIELDCAT-SELTEXT_M = 'Zone'.
    LS_FIELDCAT-SELTEXT_S = 'Zone'.
  ENDIF.
  IF LS_FIELDCAT-FIELDNAME EQ 'ZZFL4'.
    LS_FIELDCAT-SELTEXT_L = 'Equipment location description'.
    LS_FIELDCAT-SELTEXT_M = 'Equipment location description'.
    LS_FIELDCAT-SELTEXT_S = 'Equipment location description'.
  ENDIF.
  IF LS_FIELDCAT-FIELDNAME EQ 'ZZROOT'.
    LS_FIELDCAT-SELTEXT_L = 'Root'.
    LS_FIELDCAT-SELTEXT_M = 'Root'.
    LS_FIELDCAT-SELTEXT_S = 'Root'.
  ENDIF.
  IF LS_FIELDCAT-FIELDNAME EQ 'ZZROOT_DES'.
    LS_FIELDCAT-SELTEXT_L = 'Root Description'.
    LS_FIELDCAT-SELTEXT_M = 'Root Description'.
    LS_FIELDCAT-SELTEXT_S = 'Root Description'.
  ENDIF.
  if ls_fieldcat-fieldname EQ 'ZZEQFNR'.
    ls_fieldcat-seltext_l = 'Job Assigned'.
    ls_fieldcat-seltext_m = 'Job Assigned'.
    ls_fieldcat-seltext_s = 'Job Assigned'.
  endif.
  if ls_fieldcat-fieldname EQ 'ZZGLTRS'.
    ls_fieldcat-seltext_l = 'Schedule End Date'.
    ls_fieldcat-seltext_m = 'Schedule End Date'.
    ls_fieldcat-seltext_s = 'Schedule End Date'.
  endif.
  if ls_fieldcat-fieldname EQ 'ZZPROID'.
    ls_fieldcat-seltext_l = 'Equip Location'.
    ls_fieldcat-seltext_m = 'Equip Location'.
    ls_fieldcat-seltext_s = 'Equip Location'.
  endif.
  if ls_fieldcat-fieldname EQ 'ZZPLTXT'.
    ls_fieldcat-seltext_l = 'Equip Location Desc'.
    ls_fieldcat-seltext_m = 'Equip Location Desc'.
    ls_fieldcat-seltext_s = 'Equip Location Desc'.
  endif.
  if ls_fieldcat-fieldname EQ 'ZZMETER_READING'.
    ls_fieldcat-seltext_l = 'Meter Reading'.
    ls_fieldcat-seltext_m = 'Meter Reading'.
    ls_fieldcat-seltext_s = 'Meter Reading'.
  endif.
  if ls_fieldcat-fieldname EQ 'ZZMETER_DESC'.
    ls_fieldcat-seltext_l = 'Meter Name'.
    ls_fieldcat-seltext_m = 'Meter Name'.
    ls_fieldcat-seltext_s = 'Meter Name'.
  endif.
  if ls_fieldcat-fieldname EQ 'ZZMETER_UPDATE'.
    ls_fieldcat-seltext_l = 'Meter Reading Date'.
    ls_fieldcat-seltext_m = 'Meter Reading Date'.
    ls_fieldcat-seltext_s = 'Meter Reading Date'.
  endif.
  if ls_fieldcat-fieldname EQ 'ZZMETER_NAME'.
    ls_fieldcat-seltext_l = 'Meter Name'.
    ls_fieldcat-seltext_m = 'Meter Name'.
    ls_fieldcat-seltext_s = 'Meter Name'.
  endif.
  if ls_fieldcat-fieldname EQ 'ZZFEGRP'.
    ls_fieldcat-seltext_l = 'Problem Code'.
    ls_fieldcat-seltext_m = 'Problem Code'.
    ls_fieldcat-seltext_s = 'Problem Code'.
  endif.
  if ls_fieldcat-fieldname EQ 'ZZREPORT_DATE'.
    ls_fieldcat-seltext_l = 'Report Date'.
    ls_fieldcat-seltext_m = 'Report Date'.
    ls_fieldcat-seltext_s = 'Report Date'.
  endif.
  if ls_fieldcat-fieldname EQ 'ZZSUPERVISOR'.
    ls_fieldcat-seltext_l = 'Supervisor'.
    ls_fieldcat-seltext_m = 'Supervisor'.
    ls_fieldcat-seltext_s = 'Supervisor'.
  endif.
  if ls_fieldcat-fieldname EQ 'ZZWORK_TYPE'.
    ls_fieldcat-seltext_l = 'Work Type'.
    ls_fieldcat-seltext_m = 'Work Type'.
    ls_fieldcat-seltext_s = 'Work Type'.
  endif.
  if ls_fieldcat-fieldname EQ 'ZZREVTX'.
    ls_fieldcat-seltext_l = 'Revision Description'.
    ls_fieldcat-seltext_m = 'Revision Description'.
    ls_fieldcat-seltext_s = 'Revision Description'.
  endif.
*  if ls_fieldcat-fieldname EQ 'ERNAM'.
*    ls_fieldcat-seltext_l = ''.
*    ls_fieldcat-seltext_m = ''.
*    ls_fieldcat-seltext_s = ''.
*  endif.

  MODIFY IT_FIELDCAT FROM LS_FIELDCAT.
ENDLOOP.
