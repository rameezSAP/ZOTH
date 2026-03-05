*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZPM_NOT_WBS.....................................*
DATA:  BEGIN OF STATUS_ZPM_NOT_WBS                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPM_NOT_WBS                   .
CONTROLS: TCTRL_ZPM_NOT_WBS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZPM_NOT_WBS                   .
TABLES: ZPM_NOT_WBS                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
