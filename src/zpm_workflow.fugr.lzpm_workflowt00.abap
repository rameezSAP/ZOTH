*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZPM_ROT.........................................*
DATA:  BEGIN OF STATUS_ZPM_ROT                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPM_ROT                       .
CONTROLS: TCTRL_ZPM_ROT
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: ZPM_SET_V1......................................*
DATA:  BEGIN OF STATUS_ZPM_SET_V1                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPM_SET_V1                    .
CONTROLS: TCTRL_ZPM_SET_V1
            TYPE TABLEVIEW USING SCREEN '0003'.
*...processing: ZPM_WF..........................................*
DATA:  BEGIN OF STATUS_ZPM_WF                        .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPM_WF                        .
CONTROLS: TCTRL_ZPM_WF
            TYPE TABLEVIEW USING SCREEN '9999'.
*.........table declarations:.................................*
TABLES: *ZPM_ROT                       .
TABLES: *ZPM_SET_V1                    .
TABLES: *ZPM_WF                        .
TABLES: ZPM_ROT                        .
TABLES: ZPM_SET_V1                     .
TABLES: ZPM_WF                         .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
