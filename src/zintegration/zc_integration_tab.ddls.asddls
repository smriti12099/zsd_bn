@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_INTEGRATION_TAB
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_INTEGRATION_TAB
{
  key Intgmodule,
  Intgpath,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
  
}
