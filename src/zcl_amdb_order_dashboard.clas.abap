CLASS ZCL_AMDB_ORDER_DASHBOARD DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: IF_AMDP_MARKER_HDB.
    TYPES:
      BEGIN OF TY_STATUS,
        OBJNR          TYPE J_OBJNR,
        STATUS_PROFILE TYPE J_STSMA,
        SYSTEM_STATUS  TYPE CHAR40,
        USER_STATUS    TYPE CHAR40,
      END OF TY_STATUS.
    TYPES:
     TT_STATUS TYPE STANDARD TABLE OF TY_STATUS.
    DATA : GT_STATUS TYPE STANDARD TABLE OF TY_STATUS.
    CLASS-METHODS GET_STATUS_TEXT FOR TABLE FUNCTION ZTF_GET_ORDER_STATUSE.
    CLASS-METHODS GET_EQUI_ROOT FOR TABLE FUNCTION ZTF_GET_EUIP_ROOT .
    CLASS-METHODS GET_OPERATION_DATA FOR TABLE FUNCTION ZTF_GET_OPERATION_DATA .


  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS GET_ORDER_STATUS .
ENDCLASS.



CLASS ZCL_AMDB_ORDER_DASHBOARD IMPLEMENTATION.


  METHOD GET_ORDER_STATUS.

  ENDMETHOD.

  METHOD GET_STATUS_TEXT BY DATABASE FUNCTION
                               FOR HDB
                               LANGUAGE SQLSCRIPT
                               OPTIONS READ-ONLY
                               USING JEST JSTO TJ30T TJ02T.
*                               ZPM_DB_MAP_STAT.
    gt_status = select DISTINCT a.mandt as mandt,
    a.objnr,
    b.stsma as status_profile,
    d.txt04 as system_status,
    c.txt04 as user_status,
    'XXXX' as status,
    'XXXX' as new_status
    from jest as a
    inner join jsto as b on b.objnr = a.objnr and b.mandt = a.mandt
    left outer join tj30t as c on c.estat = a.stat and
    c.stsma = b.stsma and
    c.spras = 'E' and
    c.mandt = b.mandt
    left outer join tj02t as d ON d.istat = a.stat and
    d.spras = 'E'
*    left OUTER join ZPM_DB_MAP_STAT as e on d.txt04 = e.system_stat
    where  a.inact <> 'X' and a.mandt = :clnt and d.istat in ( 'I0045','I0001','I0002' );
*    where  a.inact <> 'X' and a.mandt = :clnt and d.txt04 in ( 'TECO','CRTD','REL' );
*     gt_complete = select  mandt,objnr,'C' as complete from  :gt_status
*     WHERE system_status = 'TECO';


    return select  mandt,
    objnr,
    status_profile,
    STRING_AGG( system_status, ',' ORDER BY system_status) as system_status,
    STRING_AGG( user_status, ',' ORDER BY user_status) as user_status,
    new_status
    FROM :gt_status
    GROUP BY mandt,objnr, status_profile,new_status;
  ENDMETHOD.


  METHOD GET_EQUI_ROOT BY DATABASE FUNCTION
                               FOR HDB
                               LANGUAGE SQLSCRIPT
                               OPTIONS READ-ONLY
                               USING  EQUZ  .

    internal_tab =   select  _root.mandt as client,
                            _Root.equnr as Equipment,
                            _First.equnr as Root,
                            '' as Text
                      from equz as _Root
                      inner join equz as _First on _Root.hequi  = _First.equnr where _Root.DATBI = '99991231' and _First.DATBI = '99991231';
*                      left outer join eqkt as _text on  _text.equnr  = _root.equnr;
*                  where _Root.mandt = clnt;

    Internal_tab1 = select client, Equipment as Equipment, Equipment as LookupEquiment, text as text,  1 as rank  from :internal_tab
                    union
                    SELECT _root.mandt,_first.Equipment as Equipment, _root.equnr as LookupEquiment, '' as text,  2 as rank  from equz as _root
                    INNER join :internal_tab as _first ON _root.equnr = _first.Root
                    where _Root.DATBI = '99991231'
                    union
                    select _root.mandt,_second.equnr as Equipment, _root.equnr as LookupEquiment, '' as text,  3 as rank  from equz as _root
                    INNER join equz as _first ON _root.equnr = _first.hequi
                    inner join equz as _second on _first.equnr = _second.hequi
                    where _Root.DATBI = '99991231' and _First.DATBI = '99991231' and _second.DATBI = '99991231'
                    union
                    select _root.mandt,_third.equnr as Equipment, _root.equnr as LookupEquiment, '' as text,   4 as rank  from equz as _root
                    INNER join equz as _first ON _root.equnr = _first.hequi
                    inner join equz as _second on _first.equnr = _second.hequi
                    inner join equz  as _third on _second.equnr = _third.hequi
                    where _Root.DATBI = '99991231' and _First.DATBI = '99991231' and _second.DATBI = '99991231'and _third.datbi = '99991231'
    ;


      rank_table  = select
                    client ,
                    Equipment,
                    LookupEquiment,
                    text,
                       RANK (  ) OVER ( PARTITION BY Equipment
                                     ORDER BY rank desc ) AS rank
                                     from :Internal_tab1
*                                 join eqkt as text on  text.equnr  =  equz.equnr
                                     ;


        RETURN SELECT
                       client,
                       Equipment,
                       LookupEquiment as root,
                       text,
                       rank as rank
                   FROM :rank_table
                  where rank = 1;
  ENDMETHOD.
  METHOD GET_OPERATION_DATA BY DATABASE FUNCTION
                               FOR HDB
                               LANGUAGE SQLSCRIPT
                               OPTIONS READ-ONLY
                               USING AFVC.

    rank_table  = select
                  mandt ,
                  aufpl,
                  VORNR,
                  pernr,
                  LTXA1,
                  RANK (  ) OVER ( PARTITION BY aufpl
                                   ORDER BY VORNR asc ) AS rank
                                   from afvc
*                                 join eqkt as text on  text.equnr  =  equz.equnr
                                   ;

        RETURN SELECT
                  mandt ,
                  aufpl,
                  VORNR,
                  pernr,
                  rank as rank,
                  LTXA1
                   FROM :rank_table
                  where rank = 1;

  ENDMETHOD.

ENDCLASS.
