*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZPM_PRIDE_RDET_T................................*
DATA:  BEGIN OF STATUS_ZPM_PRIDE_RDET_T              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPM_PRIDE_RDET_T              .
CONTROLS: TCTRL_ZPM_PRIDE_RDET_T
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZPM_PRIDE_RDET_T              .
TABLES: ZPM_PRIDE_RDET_T               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
