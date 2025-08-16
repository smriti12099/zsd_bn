@EndUserText.label: 'Copy BP Partner Function Database Table'
define abstract entity ZD_CopyBpPartnerFunctionDaP
{
  @EndUserText.label: 'New Customer Code'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: Customer' )
  Customer : ZDE_CUSTOMER;
  @EndUserText.label: 'New Sales Organisation'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: SalesOrg' )
  SalesOrg : ZDE_SALESORG;
  @EndUserText.label: 'New Distribution Channel'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: DistChannel' )
  DistChannel : ZDE_DIST_CHANNEL;
  @EndUserText.label: 'New Division'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: Division' )
  Division : ZDE_DIVISION;
  
}
