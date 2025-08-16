@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_BANK_TAB
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_BANK_TAB
{
  key Salesorg,
  key Distributionchannel,
  BankDetails,
  AcoountNumber,
  IfscCode,
  CreatedBy,
  CreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
  LastChangedAt
  
}
