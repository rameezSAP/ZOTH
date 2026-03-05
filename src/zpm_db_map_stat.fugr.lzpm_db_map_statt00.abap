*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZPM_DB_MAP_STAT.................................*
DATA:  BEGIN OF STATUS_ZPM_DB_MAP_STAT               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPM_DB_MAP_STAT               .
CONTROLS: TCTRL_ZPM_DB_MAP_STAT
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZPM_DB_MAP_STAT               .
TABLES: ZPM_DB_MAP_STAT                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
