class ZCL_ITAB_TO_EXCEL definition
  public
  final
  create public .

public section.

  methods ITAB_TO_XSTRING
    importing
      value(IR_DATA_REF) type ref to DATA optional
      value(LT_FCAT) type LVC_T_FCAT optional
    returning
      value(RV_XSTRING) type XSTRING .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ITAB_TO_EXCEL IMPLEMENTATION.


  METHOD ITAB_TO_XSTRING.
 BREAK ac_Adnan.
    FIELD-SYMBOLS: <FS_DATA> TYPE ANY TABLE.

    CLEAR RV_XSTRING.
    ASSIGN IR_DATA_REF->* TO <FS_DATA>.

    TRY.
        CL_SALV_TABLE=>FACTORY(
          IMPORTING
            R_SALV_TABLE = DATA(LO_TABLE)
          CHANGING
            T_TABLE      = <FS_DATA> ).

*        DATA(LT_FCAT) =
*          CL_SALV_CONTROLLER_METADATA=>GET_LVC_FIELDCATALOG(
*          R_COLUMNS      = LO_TABLE->GET_COLUMNS( )
*          R_AGGREGATIONS = LO_TABLE->GET_AGGREGATIONS( ) ).

        DATA(LO_RESULT) =
          CL_SALV_EX_UTIL=>FACTORY_RESULT_DATA_TABLE(
          R_DATA         = IR_DATA_REF
          T_FIELDCATALOG = LT_FCAT ).

        CL_SALV_BS_TT_UTIL=>IF_SALV_BS_TT_UTIL~TRANSFORM(
          EXPORTING
            XML_TYPE      = IF_SALV_BS_XML=>C_TYPE_XLSX
            XML_VERSION   = CL_SALV_BS_A_XML_BASE=>GET_VERSION( )
            R_RESULT_DATA = LO_RESULT
            XML_FLAVOUR   = IF_SALV_BS_C_TT=>C_TT_XML_FLAVOUR_EXPORT
            GUI_TYPE      = IF_SALV_BS_XML=>C_GUI_TYPE_GUI
          IMPORTING
            XML           = RV_XSTRING ).
      CATCH CX_ROOT.
        CLEAR RV_XSTRING.
    ENDTRY.


  ENDMETHOD.
ENDCLASS.
