CLASS ZCL_AMDB_PM_PRIDE DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES IF_AMDP_MARKER_HDB .

    TYPES:
      BEGIN OF TY_STATUS,
        OBJNR          TYPE J_OBJNR,
        STATUS_PROFILE TYPE J_STSMA,
        SYSTEM_STATUS  TYPE CHAR40,
        USER_STATUS    TYPE CHAR40,
      END OF TY_STATUS .
    TYPES:
      TT_STATUS TYPE STANDARD TABLE OF TY_STATUS .

    DATA:
      GT_STATUS TYPE STANDARD TABLE OF TY_STATUS .

*  class-methods GET_STATUS_TEXT
*    for table function ZTF_GET_ORDER_STATUSE .
    CLASS-METHODS GET_MP_READING
        FOR TABLE FUNCTION ZTF_PM_PRIDE_ROUTE_MP_READ .
  PROTECTED SECTION.
  PRIVATE SECTION.

*    METHODS GET_ORDER_STATUS .
ENDCLASS.



CLASS ZCL_AMDB_PM_PRIDE IMPLEMENTATION.


  METHOD GET_MP_READING BY DATABASE FUNCTION
                               FOR HDB
                               LANGUAGE SQLSCRIPT
                               OPTIONS READ-ONLY
                               USING  IMRG  .

    internal_tab =   select MANDT   ,
                            MDOCM   ,
                            POINT   ,
                            IDATE   ,
                            ITIME   ,
                            ERDAT   ,
                            ERUHR   ,
*                            READG   ,
RECDV as READG,
                            RECDV   ,
                            RECDU   ,
                            CNTRR   ,
                            CDIFF   ,
                            IDIFF,
                            RANK ( ) OVER ( PARTITION BY mandt, POINT
                                 ORDER BY idate DESC ) AS rank
                      from IMRG
                      where mandt = :clnt;
*                      and POINT = :mp
*                      ORDER BY idate DESC ;



        RETURN SELECT
                            MANDT   ,
                            MDOCM   ,
                            POINT   ,
                            IDATE   ,
                            ITIME   ,
                            ERDAT   ,
                            ERUHR   ,
                            READG   ,
                            RECDV   ,
                            RECDU   ,
                            CNTRR   ,
                            CDIFF   ,
                            IDIFF
                   FROM :internal_tab
                   where rank < 6;
  ENDMETHOD.

ENDCLASS.
