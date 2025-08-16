@EndUserText.label: 'Daily Dispatch Report'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_DAILY_DISPATCH'
@UI.headerInfo: {
typeName: 'Count',
typeNamePlural: 'Count'
}
define custom entity zdd_daily_dispatch
{
  @UI.selectionField : [{ position: 1 }] 
  @UI.lineItem       : [{ position:8 , label: 'Billing Document' }]
  @EndUserText.label: 'Billing Document'
 key bill : abap.char(10);
 
  @UI.lineItem       : [{ position:9 , label: 'Billing Document Item' }]
  @EndUserText.label: 'Billing DocumentItem'
//  @Consumption.filter.hidden: true
 key bill_item : abap.numc(6);
 
//  @UI.lineItem       : [{ position:1.5 , label: 'count' }]
//  @EndUserText.label: 'Count'
//  cnt : abap.int4;
  
   @UI.selectionField : [{ position: 2 }] 
  @UI.lineItem       : [{ position:1 , label: 'Supply Plant Code' }]
  @EndUserText.label: 'Supply Plant Code'
  s_plant : abap.char(4);
  
    @UI.selectionField : [{ position: 3 }] 
  @UI.lineItem       : [{ position:2 , label: 'Receiving Plant Code' }]
  @EndUserText.label: 'Receiving Plant Code'
  r_plant : abap.char(4);
  
  @UI.lineItem       : [{ position:3 , label: 'Supply Plant Name' }]
  @EndUserText.label: 'Supply Plant Name'
  s_plant_name : abap.char(60);
  
  @UI.lineItem       : [{ position:4 , label: 'Receiving Plant Name' }]
  @EndUserText.label: 'Receiving Plant Name'
  r_plant_name : abap.char(60);
  
    @UI.selectionField : [{ position: 4 }] 
   @UI.lineItem       : [{ position:5}]
  @EndUserText.label: 'Customer Code'
  cust : abap.char(10);
  
  
   @UI.lineItem       : [{ position:6}]
  @EndUserText.label: 'Ship To City'
  city : abap.char(40);
  
    @UI.lineItem       : [{ position:7 }]
  @EndUserText.label: 'Depot Location'
  depot : abap.char(60);
  
    @UI.selectionField : [{ position: 5 }] 
  @UI.lineItem       : [{ position:10 }]
  @EndUserText.label: 'Creation Date'
  creation_date : abap.dats(8);
  
  @UI.lineItem       : [{ position:11 }]
  @EndUserText.label: 'Material Code'
  mat_code : abap.char(40);
  
  @UI.lineItem       : [{ position:12 }]
  @EndUserText.label: 'Material Description'
  mat_desc : abap.char(40);
 
  @UI.lineItem       : [{ position:13 }]
  @EndUserText.label: 'Invoice Qty'
  inv_qty : abap.dec(13,3);
  
  @UI.lineItem       : [{ position:14 }]
  @EndUserText.label: 'Invoice Unit'
  inv_unit : abap.unit(3);
  
    @UI.selectionField : [{ position: 6 }] 
   @UI.lineItem       : [{ position:15 }]
  @EndUserText.label: 'Material Category'
  mat_cat : abap.char(4);
  
  @UI.lineItem       : [{ position:16 }]
  @EndUserText.label: 'Net Weight'
  @Semantics.quantity.unitOfMeasure: 'net_unit'
  net_weight : abap.dec(15,3);
  
  @UI.hidden: true
  net_unit : abap.unit(3);
  
  @UI.lineItem       : [{ position:17 }]
  @EndUserText.label: 'Gross Weight'
  @Semantics.quantity.unitOfMeasure: 'gross_unit'
  gross_weight : abap.dec(15,3);
  
  @UI.hidden: true
  gross_unit : abap.unit(3);
  
    @UI.lineItem       : [{ position:18 }]
  @EndUserText.label: 'Rate Per Case/Nag'
  ratepercase : abap.dec(15,3);
  
   @UI.lineItem       : [{ position:19 }]
  @EndUserText.label: 'Invoice Amount'
  inv_amt : abap.dec(15,3);
    
   @UI.lineItem       : [{ position:22 }]
  @EndUserText.label: 'Vehicle Number'
  veh : abap.char(15);
  
  @UI.lineItem       : [{ position:23 }]
  @EndUserText.label: 'LR Number'
  lr_no : abap.char(20);
  
  @UI.lineItem       : [{ position:24 }]
  @EndUserText.label: 'Transporter Name'
  Trans_name : abap.char(60);
  
  @UI.lineItem       : [{ position:27 }]
  @EndUserText.label: 'E-Way No'
  eway : abap.char(20);
  
  @UI.lineItem: [{ position: 30 }]
  @EndUserText.label: 'Ship to party'
  ship_to_party : abap.char(10);

  @UI.lineItem: [{ position: 40 }]
  @EndUserText.label: 'Ship to party name'
  ship_to_party_name : abap.char(60);

  @UI.lineItem: [{ position: 50 }]
  @EndUserText.label: 'Sold to party'
  sold_to_party : abap.char(10);

  @UI.lineItem: [{ position: 60 }]
  @EndUserText.label: 'Sold to party name'
  sold_to_party_name : abap.char(60);

  @UI.lineItem: [{ position: 70 }]
  @EndUserText.label: 'Sale order / PO'
  sale_order_po : abap.char(20);
  
    @UI.lineItem: [{ position: 80 }]
  @EndUserText.label: 'Driver Name'
  driver_name : abap.char(50);

  
}
