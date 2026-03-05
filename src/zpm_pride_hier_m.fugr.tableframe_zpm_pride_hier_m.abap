*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZPM_PRIDE_HIER_M
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZPM_PRIDE_HIER_M   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
