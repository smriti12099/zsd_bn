@EndUserText.label: 'CDS for ZTRANSIT VEHICLE'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCLASS_TRANSIT_VEHICLE'
@UI.headerInfo: {
typeName: 'Count',
typeNamePlural: 'Count'
}

define custom entity zdd_transit
{
      @UI.selectionField   : [{ position :1 }]
      @UI.lineItem         : [{ position: 8, label: 'Invoice No.' }]
      @EndUserText.label   : 'Invoice No'
      key invoice_no           : abap.char(10);
  
     @UI.hidden: true
     key bill_item : abap.numc(6);


      @UI.selectionField   : [{ position: 2 }]
      @UI.lineItem         : [{ position: 1, label: 'Supply Plant Code' }]
      @EndUserText.label   : 'Supply Plant Code'
      plant                : abap.char(4);


      @UI.lineItem         : [{ position: 10, label: 'Material Code' }]
      @EndUserText.label   : 'Material Code'
      material_code        : abap.char(40);

      @UI.lineItem         : [{ position: 3, label: 'Supply Plant Name' }]
      @EndUserText.label   : 'Supply Plant Name'
      S_NAME_plant         : abap.char(60);

      @UI.lineItem         : [{ position: 26, label: 'E-Way No.' }]
      @EndUserText.label   : 'E-Way No..'
      e_way_no             : abap.char(20);


      @UI.selectionField   : [{ position: 3 }]
      @UI.lineItem         : [{ position: 2, label: 'Receving Plant Code' }]
      @EndUserText.label   : 'Receving Plant Code'
      RECEIVINGPLANT       : abap.char(4);

      @UI.lineItem         : [{ position: 4, label: 'Receving Plant Name' }]
      @EndUserText.label   : 'Receving Plant Name'
      R_NAME_plant         : abap.char(60);


      @UI.selectionField   : [{ position: 4 }]
      @UI.lineItem         : [{ position: 5, label: 'Customer Code' }]
      @EndUserText.label   : 'Customer Code'
      customer_code        : abap.char(10);

      @UI.lineItem         : [{ position: 6, label: 'Ship to City' }]
      @EndUserText.label   : 'Ship to City'
      ship_to_city         : abap.char(40);

      @UI.lineItem         : [{ position: 7, label: 'Depot Location' }]
      @EndUserText.label   : 'Depot Location'
      depot_loc            : abap.char(60);



      @UI.lineItem         : [{ position: 9, label: 'Invoice Date.' }]
      @EndUserText.label   : 'Invoice Date'
      invoice_date         : abap.dats(8);



      @UI.lineItem         : [{ position: 11, label: 'Material Description' }]
      @EndUserText.label   : 'Material Description'
      material_desc        : abap.char(40);


      @UI.lineItem         : [{ position: 12, label: 'Invoice Qty' }]
      @EndUserText.label   : 'Invoice Qty'
      invoice_qty          : abap.dec(16, 3);

      @UI.lineItem         : [{ position: 13, label: 'UOM' }]
      @EndUserText.label   : 'UOM'
      uom                  : abap.unit( 3 );

      @UI.lineItem         : [{ position: 14, label: 'Material Category' }]
      @EndUserText.label   : 'Material Category'
      material_category    : abap.char(4);

      @UI.lineItem         : [{ position: 15, label: 'Invoice Net Weight (Kg)' }]
      @EndUserText.label   : 'Invoice Net Weight (Kg)'
      invoice_net_weight   : abap.dec(15,3);

      @UI.lineItem         : [{ position: 16, label: 'Invoice Gross Weight Kg' }]
      @EndUserText.label   : 'Invoice Gross Weight Kg'
      invoice_gross_weight : abap.dec(15,3);

      @UI.lineItem         : [{ position: 17, label: 'Rate Per Case/Nag' }]
      @EndUserText.label   : 'Rate Per Case/Nag'
      rate_per_casenag     : abap.dec(21,3);

      @UI.lineItem         : [{ position: 18, label: 'Invoice Amount ' }]
      @EndUserText.label   : 'Invoice Amount '
      invoice_amount       : abap.dec( 18, 3 );


      @UI.lineItem         : [{ position: 19, label: 'GST amount' }]
      @EndUserText.label   : 'GST amount '
      gst_amount           : abap.dec( 18, 3 );


      @UI.lineItem         : [{ position: 20, label: 'Invoice Amt With GST' }]
      @EndUserText.label   : 'Invoice Amt With GST'
      invo_gst_amount      : abap.dec( 18, 3 );


      @UI.lineItem         : [{ position: 21, label: 'No. of Transit Days (As on Current)' }]
      @EndUserText.label   : 'No. of Transit Days (As on Current)'
      no_transit_day       : abap.dec( 18, 3 );




      @UI.lineItem         : [{ position: 21, label: 'Vehicle Number' }]
      @EndUserText.label   : 'Vehicle Number'
      vehicle_no           : abap.char(15);

      @UI.lineItem         : [{ position: 22, label: 'LR Number' }]
      @EndUserText.label   : 'LR Number'
      lr_no                : abap.char(30);


      @UI.lineItem         : [{ position: 23, label: 'Transporter Name' }]
      @EndUserText.label   : 'Transporter Name'
      transporter_name     : abap.char(60);


      @UI.lineItem         : [{ position: 24, label: 'Driver Name' }]
      @EndUserText.label   : 'Driver Name'
      driver_name          : abap.char(60);

      @UI.lineItem         : [{ position: 25, label: 'Driver Mob. No.' }]
      @EndUserText.label   : 'Driver Mob. No.'
      driver_mobile_no     : abap.char(10);




      @UI.lineItem         : [{ position: 27, label: 'E-way Expired Date' }]
      @EndUserText.label   : 'E-Way Date..'
      e_way_date           : abap.dats(8);
      
      ref_sd_item   :abap.char(10);
      
      lv_gateoutdate : abap.dats(8);
      lv_documentdate : abap.dats(8);
      lv_docitem : abap.numc(6);
      
      
      






}
