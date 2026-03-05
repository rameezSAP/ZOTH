@AbapCatalog.sqlViewName: 'ZPM_ORD_TO_PO'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PM:Order to Purchase Order Cost'
define view ZPM_ORDER_TO_PO_COST_CDS
  as select from    ebkn          as _ORD
    left outer join eban          as _pr   on  _ORD.banfn = _pr.banfn
                                           and _pr.loekz  <> 'X'

    left outer join ekpo          as _ekpo   on  _ekpo.ebeln = _pr.ebeln
                                           and _pr.pstyp  = '9'                                           

    left outer join ekko          as _po   on  _pr.ebeln = _po.ebeln
                                           and _po.loekz  <> 'X'

    left outer join prcd_elements as _cost on  _po.knumv     =  _cost.knumv 
                                           and (
                                              _cost.kschl    =  'PB00'
                                              or _cost.kschl =  'PBXX'
                                            )

{
_ORD.aufnr,
_po.ebeln as ebeln,
  sum(kwert) as KWERT


}
where
   _ORD.aufnr <> ''
 and _ORD.loekz  <> 'X'
  and _cost.kposn  <> '000000'
group by
  _ORD.aufnr,_po.ebeln;
