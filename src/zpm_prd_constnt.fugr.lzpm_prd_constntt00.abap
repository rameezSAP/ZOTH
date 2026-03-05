*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZPM_PRD_CONSTANT................................*
DATA:  BEGIN OF STATUS_ZPM_PRD_CONSTANT              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPM_PRD_CONSTANT              .
CONTROLS: TCTRL_ZPM_PRD_CONSTANT
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZPM_PRD_CONSTANT              .
TABLES: ZPM_PRD_CONSTANT               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
