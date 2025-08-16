@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forZScheme'
define root view entity ZI_ZScheme02TP
  provider contract transactional_interface
  as projection on ZR_ZScheme02TP as ZScheme
{
  key Bukrs,
  key Schemecode,
  Validfrom,
  Validto,
  plantcode,
  division,
  distributionchannel,
  customerpricegroup,  
  Schemeqty,
  Freeqty,
  Minimumqty,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt,
  _ZSchemeLines : redirected to composition child ZI_ZSchemeLines01TP
  
}
