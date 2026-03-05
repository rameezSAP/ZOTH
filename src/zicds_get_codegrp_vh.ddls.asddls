@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Pride : MP Code Group Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Search.searchable: true
define view entity ZICDS_GET_CODEGRP_VH
  as select from qpct
{
      //    key katalogart as Katalogart,
      @Search.defaultSearchElement: true
  key codegruppe as Codegruppe,
@ObjectModel.text.element: ['Kurztext']  
  key code       as Code,
      gueltigab  as Gueltigab,
      @Semantics.text: true
      
      kurztext   as Kurztext,
      ltextv     as Ltextv,
      inaktiv    as Inaktiv,
      geloescht  as Geloescht
}
where
      sprache    = 'E'
  and katalogart = 'D'
  and inaktiv    = ''
