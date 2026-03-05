*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZPM_EMAIL.......................................*
DATA:  BEGIN OF STATUS_ZPM_EMAIL                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPM_EMAIL                     .
CONTROLS: TCTRL_ZPM_EMAIL
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZPM_EMAIL                     .
TABLES: ZPM_EMAIL                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
