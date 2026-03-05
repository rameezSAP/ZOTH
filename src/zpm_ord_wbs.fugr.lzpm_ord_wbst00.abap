*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZPM_ORD_WBS.....................................*
DATA:  BEGIN OF STATUS_ZPM_ORD_WBS                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPM_ORD_WBS                   .
CONTROLS: TCTRL_ZPM_ORD_WBS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZPM_ORD_WBS                   .
TABLES: ZPM_ORD_WBS                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
