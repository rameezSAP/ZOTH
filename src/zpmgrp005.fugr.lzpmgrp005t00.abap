*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTPM0008........................................*
DATA:  BEGIN OF STATUS_ZTPM0008                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTPM0008                      .
CONTROLS: TCTRL_ZTPM0008
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: ZTPM0009........................................*
DATA:  BEGIN OF STATUS_ZTPM0009                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTPM0009                      .
CONTROLS: TCTRL_ZTPM0009
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *ZTPM0008                      .
TABLES: *ZTPM0009                      .
TABLES: ZTPM0008                       .
TABLES: ZTPM0009                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
