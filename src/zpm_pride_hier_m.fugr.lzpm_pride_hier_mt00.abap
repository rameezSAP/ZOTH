*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZPM_PRIDE_HIER_M................................*
DATA:  BEGIN OF STATUS_ZPM_PRIDE_HIER_M              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPM_PRIDE_HIER_M              .
CONTROLS: TCTRL_ZPM_PRIDE_HIER_M
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZPM_PRIDE_HIER_M              .
TABLES: ZPM_PRIDE_HIER_M               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
