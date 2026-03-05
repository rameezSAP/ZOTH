*&---------------------------------------------------------------------*
*& Report ZPM_EQUIP_UPLOAD_LTXT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZPM_EQUIP_UPLOAD_LTXT."ZPM_EQUIP_UPLOAD_LTXT
TYPES: BEGIN OF TY_ITAB ,
         EQUI(18)     TYPE C,
         LMAKTX(2000) TYPE C,
         ROW          TYPE I,
         TSIZE        TYPE I,
       END OF TY_ITAB.


" Data Declarations - Internal Tables
DATA: I_TAB          TYPE STANDARD TABLE OF TY_ITAB  INITIAL SIZE 0,
      IT_EXLOAD      LIKE ZST_LONGTEXT  OCCURS 0 WITH HEADER LINE,
      IT_LINES       LIKE STANDARD TABLE OF TLINE WITH HEADER LINE,
      IT_TEXT_HEADER LIKE STANDARD TABLE OF THEAD WITH HEADER LINE,
      WA             TYPE TY_ITAB,
      P_ERROR        TYPE  SY-LISEL,
      LEN            TYPE I.

"Selection Screen
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-002.

  PARAMETERS:PFILE   TYPE RLGRAP-FILENAME OBLIGATORY, "Excel File Name with Path
             W_BEGIN TYPE I OBLIGATORY,                                      "Excel Row beginning
             W_END   TYPE I OBLIGATORY.                                          "Excel End Row
SELECTION-SCREEN END OF BLOCK B1.

AT SELECTION-SCREEN.

  IF PFILE IS INITIAL.

    MESSAGE S368(00) WITH 'Please input filename'. STOP.

  ENDIF.

START-OF-SELECTION.

  REFRESH:I_TAB.
  PERFORM EXCEL_DATA_INT_TABLE.
  PERFORM EXCEL_TO_INT.
  PERFORM CONTOL_PARAMETER.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR PFILE.

  PERFORM F4_FILENAME.

  " F4 Help getting Excel File Name with Comlete Path
FORM F4_FILENAME .

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      PROGRAM_NAME  = SYST-CPROG
      DYNPRO_NUMBER = SYST-DYNNR
    IMPORTING
      FILE_NAME     = PFILE.

ENDFORM.

"Read Legacy Data Transfer from Excel using Custom Function Module

FORM EXCEL_DATA_INT_TABLE .

  CALL FUNCTION 'ZFM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      FILENAME    = PFILE
      I_BEGIN_COL = '0001'               "Excel Beginning Column
      I_BEGIN_ROW = W_BEGIN
      I_END_COL   = '002'                  "Excel End Column
      I_END_ROW   = W_END
    TABLES
      INTERN      = IT_EXLOAD.

ENDFORM.                    " EXCEL_DATA_INT_TABLE

"Transfer Excel data into internal table

FORM EXCEL_TO_INT .

  LOOP AT IT_EXLOAD .
    CASE  IT_EXLOAD-COL.
      WHEN '0001'.
        WA-EQUI   = IT_EXLOAD-VALUE.        "Equipment Number Leading with Zero
      WHEN '0002'.
        WA-LMAKTX   = IT_EXLOAD-VALUE.      " Equipment Long Text
    ENDCASE.

    AT END OF ROW.
      WA-TSIZE = STRLEN( WA-LMAKTX ).         "Finding String Length using STRLEN
      WA-ROW = IT_EXLOAD-ROW .                  "Adding Current Row Num into Internal table
      APPEND WA TO I_TAB.
      CLEAR WA .
    ENDAT.

  ENDLOOP.

ENDFORM.                    " EXCEL_TO_INT

"Maintain Header, Item data and pass into "SAVE_TEXT” to save to Long Text

FORM CONTOL_PARAMETER.

  DATA OFF TYPE I VALUE '0'.
  DATA HEADER           TYPE THEAD.
  DATA LT_LINES            TYPE STANDARD TABLE OF TLINE.
  TYPES:BEGIN OF TY_TEXT,
          TEXT TYPE SOTR_TXT,
        END OF TY_TEXT.
  DATA:LT_TEXT TYPE STANDARD TABLE OF TY_TEXT.
  DATA LS_LINE            TYPE TLINE.
  DATA IT_EQKT_DEL TYPE STANDARD TABLE OF EQKT.
  DATA IT_EQKT_INS TYPE STANDARD TABLE OF EQKT.
  DATA TEXT TYPE STRING.
  LOOP AT I_TAB INTO WA.

*    * Create Header

    IT_TEXT_HEADER-TDID     = 'LTXT'.                 " Text ID for Equipment Master
    IT_TEXT_HEADER-TDSPRAS  = SY-LANGU .    " Login Language Key
    IT_TEXT_HEADER-TDNAME   = WA-EQUI.     "Equipment Number leading with Zero
    IT_TEXT_HEADER-TDOBJECT = 'EQUI'.     " Text Object
    MOVE WA-TSIZE TO LEN .

    LEN =  LEN / 70  + 1.                                           "Finding Number of Row’s taken by Long Text

    " Note :  Number of Row Required for Long Text Display
*              = Total length of long text / Number Character’s in one Row + 1
*               Here I am taken 70 number of character in each row ,
*               because in Equipment Master Long Text Area Display 53 Character without using Horizontal Bar . "

    DO LEN TIMES .
      MOVE '*' TO IT_LINES-TDFORMAT.
      MOVE  WA-LMAKTX+OFF(70) TO IT_LINES-TDLINE.
      SHIFT IT_LINES-TDLINE LEFT DELETING LEADING ' '.
      OFF = OFF + 70 .
      APPEND IT_LINES.
      CLEAR IT_LINES .
    ENDDO.

*/** Read already maintained Long Text
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
*       CLIENT                  = SY-MANDT
        ID                      = IT_TEXT_HEADER-TDID
        LANGUAGE                = IT_TEXT_HEADER-TDSPRAS
        NAME                    = IT_TEXT_HEADER-TDNAME
        OBJECT                  = IT_TEXT_HEADER-TDOBJECT
*       ARCHIVE_HANDLE          = 0
*       LOCAL_CAT               = ' '
      IMPORTING
        HEADER                  = HEADER
*       OLD_LINE_COUNTER        = OLD_LINE_COUNTER
      TABLES
        LINES                   = LT_LINES
      EXCEPTIONS
        ID                      = 1
        LANGUAGE                = 2
        NAME                    = 3
        NOT_FOUND               = 4
        OBJECT                  = 5
        REFERENCE_CHECK         = 6
        WRONG_ACCESS_TO_ARCHIVE = 7.


    MOVE WA-LMAKTX TO TEXT.
    CLEAR LT_TEXT[].

*/** Split Long Text into 70 Character lines
    CALL FUNCTION 'SOTR_SERV_STRING_TO_TABLE'
      EXPORTING
        TEXT                = TEXT
        FLAG_NO_LINE_BREAKS = ' '
        LINE_LENGTH         = 70
*       LANGU               = SY-LANGU
      TABLES
        TEXT_TAB            = LT_TEXT.

    LOOP AT LT_TEXT ASSIGNING FIELD-SYMBOL(<FS_TEXT>).
      LS_LINE-TDLINE = <FS_TEXT>.
      LS_LINE-TDFORMAT = '*'.
      APPEND LS_LINE TO LT_LINES.
    ENDLOOP.

*Using SAVE_TEXT Functional Module Save Long Text to SAP
    AT END OF ROW.

      CALL FUNCTION 'SAVE_TEXT'
        EXPORTING
          CLIENT          = SY-MANDT
          HEADER          = IT_TEXT_HEADER
          INSERT          = ' '
          SAVEMODE_DIRECT = 'X'
        TABLES
          LINES           = LT_LINES
        EXCEPTIONS
          ID              = 1
          LANGUAGE        = 2
          NAME            = 3
          OBJECT          = 4
          OTHERS          = 5.

      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY
            NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO P_ERROR.
        WRITE: WA-EQUI && ' text not upated due to ' && P_ERROR.
        NEW-LINE.
        CONTINUE.
      ELSE.
        WRITE: WA-EQUI && ' text has been updated '.
        NEW-LINE.
      ENDIF.

      SELECT * FROM EQKT INTO TABLE @DATA(LT_EQKT) WHERE EQUNR = @WA-EQUI AND SPRAS = 'E'.
      IF SY-SUBRC = 0.
        LOOP AT LT_EQKT ASSIGNING FIELD-SYMBOL(<FS_EQKT>).
          <FS_EQKT>-KZLTX = 'X'.

        ENDLOOP.

*/**** We need to maintained the Long Text Flag on the EQKT-KZLTX
*/**** so that the Long Text Icon display on the Display Notificatin Screen
        IF LT_EQKT[] IS NOT INITIAL.
          CALL FUNCTION 'EQKT_SAVE_UPD_TASK'
            TABLES
              IT_EQKT_UPD    = LT_EQKT
              IT_EQKT_DEL    = IT_EQKT_DEL
              IT_EQKT_INS    = IT_EQKT_INS
            EXCEPTIONS
              ERROR_EQKT_UPD = 1
              ERROR_EQKT_INS = 2
              ERROR_EQKT_DEL = 3
              OTHERS         = 4.
          COMMIT WORK.
        ENDIF.
      ENDIF.
      CLEAR: WA ,LEN , OFF.
      CLEAR: LT_EQKT[],IT_LINES[],LT_TEXT[],LT_LINES[].
      REFRESH IT_LINES .
    ENDAT.
    CLEAR: LT_EQKT[],IT_LINES[],LT_TEXT[],LT_LINES[].
    REFRESH IT_LINES .
  ENDLOOP.
ENDFORM.                    " CONTOL_PARAMETER
