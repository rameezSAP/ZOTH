*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZPM_WF_ORD......................................*
DATA:  BEGIN OF STATUS_ZPM_WF_ORD                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPM_WF_ORD                    .
CONTROLS: TCTRL_ZPM_WF_ORD
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZPM_WF_ORD                    .
TABLES: ZPM_WF_ORD                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
