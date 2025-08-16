@EndUserText.label: 'I_SALESDOCUMENT CDS'
@Search.searchable: false
@UI.headerInfo: {typeName: 'Sales Order Print'}
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity zr_sales_order_print
  as select from I_SalesDocument
{
      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:1 }]
      @UI.lineItem   : [{ position:1, label:'Sales Document' }]
  key SalesDocument,


      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:2 }]
      @UI.lineItem   : [{ position:2, label:'Sales Order Type' }]
      SDDocumentCategory,
      
      
      @Search.defaultSearchElement: true
      @UI.selectionField   : [{ position:3 }]
      @UI.lineItem   : [{ position:3, label:'Sales Order Creation Date' }]
//      @Consumption.filter:{ mandatory: true }
      CreationDate

}
