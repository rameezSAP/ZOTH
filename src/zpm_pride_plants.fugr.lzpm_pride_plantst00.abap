*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZPM_PRIDE_PLANTS................................*
DATA:  BEGIN OF STATUS_ZPM_PRIDE_PLANTS              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPM_PRIDE_PLANTS              .
CONTROLS: TCTRL_ZPM_PRIDE_PLANTS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZPM_PRIDE_PLANTS              .
TABLES: ZPM_PRIDE_PLANTS               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
