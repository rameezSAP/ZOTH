*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZPM_DIST_LIST...................................*
DATA:  BEGIN OF STATUS_ZPM_DIST_LIST                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPM_DIST_LIST                 .
CONTROLS: TCTRL_ZPM_DIST_LIST
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZPM_DIST_LIST                 .
TABLES: ZPM_DIST_LIST                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
