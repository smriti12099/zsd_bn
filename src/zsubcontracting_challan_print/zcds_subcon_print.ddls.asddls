@EndUserText.label: 'CDS FOR SUBCONTRACTING CHALLAN PRINT'
@Search.searchable: false
//@ObjectModel.query.implementedBy: 'ABAP:'
@UI.headerInfo: {typeName: 'SUBCONTRACTING CHALLAN PRINT'}
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZCDS_SUBCON_PRINT as select from I_BillingDocument as a
// with parameters parameter_name : parameter_type
{
      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:10 }]
      @UI.lineItem   : [{ position:10 , label:'Billing Document' }]
      @EndUserText.label: 'Billing Document'
      key a.BillingDocument,
      
      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:20 }]
      @UI.lineItem   : [{ position:20 , label:'Billing Document Type' }]
      @EndUserText.label: 'Billing Document Type'
      a.BillingDocumentType, 
      
      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:30 }]
      @UI.lineItem   : [{ position:30 , label:'Sales Organization' }]
      @EndUserText.label: 'Sales Organization'
      a.SalesOrganization
  
}
