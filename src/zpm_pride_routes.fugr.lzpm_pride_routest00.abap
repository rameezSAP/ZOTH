*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZPM_PRIDE_ROUTES................................*
DATA:  BEGIN OF STATUS_ZPM_PRIDE_ROUTES              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPM_PRIDE_ROUTES              .
CONTROLS: TCTRL_ZPM_PRIDE_ROUTES
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZPM_PRIDE_ROUTES              .
TABLES: ZPM_PRIDE_ROUTES               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
