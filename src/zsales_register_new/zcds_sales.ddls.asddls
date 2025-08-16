@EndUserText.label: 'Sales Register'
@Search.searchable: false
@ObjectModel.query.implementedBy: 'ABAP:ZCL_SALES_REG'
@UI.headerInfo: {typeName: 'Sales Register'}
@Metadata.allowExtensions: true
//@Analytics.query:true
define view entity ZCDS_SALES
        as select from zsales_reg_tb
{
      @Search.defaultSearchElement: true
//      @UI.selectionField: [{ position: 10 }] // Select-Options
      @UI.lineItem: [{ position: 10, label: 'Sales Invoice No' }]
      @EndUserText.label: 'Sales Invoice No' 
   //   @Consumption.valueHelpDefinition: [{ entity : {  name: 'i_billingdocument', element: 'BILLINGDOCUMENT' } }]
      key invoiceno  as InvoiceNo,
      
       @UI.lineItem: [{ position: 20, label:'Line Item No' }]     
      key itemno as ItemNo,

      @UI.hidden: true
      key pricingprocedurestep as PricingProcedureStep,

      @UI.hidden: true
      key pricingprocedurecounter as PricingProcedureCounter,

      @UI.hidden: true
      key plant as Plant,

      @UI.hidden: true
      key product as Product,

      @UI.hidden: true 
      key salesorder as SalesOrder,

      @UI.hidden: true
      key salesordertype as SalesOrderType, 

      @UI.hidden: true
      key partnerfunction as PartnerFunction,

      @UI.hidden: true
      key salesorderitem as SalesOrderItem,

      @UI.hidden: true
      key salescontract as SalesContract,
      
      @UI.hidden: true
      key salescontracttype as SalesContractType,

      @UI.hidden: true
      key customer as Customer,

      @UI.hidden: true
      key billingdocument as BillingDocument,

      @UI.lineItem: [{ position:30, label:'Sales Invoice Type' }]   
      invoicetype as InvoiceType,

      @UI.lineItem: [{ position:40, label:'Sales Invoice Document Type Des.' }]     
      invoicedocumenttypedes as InvoiceDocumentTypeDes,

      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position:50 }]             
      @UI.lineItem: [{ position:50, label:'Sales Invoice Date' }]     
      invoicedate as InvoiceDate,

      @UI.lineItem: [{ position:60, label:'Reference Invoice No' }]     
      referenceinvoiceno as ReferenceInvoiceNo,

      @UI.lineItem: [{ position:70, label:'Ref Invoice Date' }]     
      refinvoicedate as RefInvoiceDate,

      @UI.lineItem: [{ position: 80, label: 'Accounting Doc. No.' }]
      accountingdocno as AccountingDocNo,

      @UI.lineItem: [{ position: 90, label: 'Customer PO No' }]
      customerpono as CustomerPONo,

      @Search.defaultSearchElement: true
      @UI.lineItem: [{ position: 100, label: 'Sales Organization' }]
      salesorganization as SalesOrganization,

      @UI.lineItem: [{ position: 110, label: 'Sales Organization Name' }]
      salesorganizationname as SalesOrganizationName,

      @Search.defaultSearchElement: true
      @UI.lineItem: [{ position: 120, label: 'Distribution Channel' }]
      distributionchannel as DistributionChannel,

      @UI.lineItem: [{ position: 130, label: 'Distribution Channel Name' }]
      distributionchannelname as DistributionChannelName,

      @Search.defaultSearchElement: true
      @UI.lineItem: [{ position: 140, label: 'Sales Division' }]
      salesdivision as SalesDivision,

      @UI.lineItem: [{ position: 150, label: 'Sales Division Name' }]
      salesdivisionname as SalesDivisionName,

      @UI.lineItem: [{ position: 160, label: 'Sales Office' }]
      salesoffice as SalesOffice,

      @UI.lineItem: [{ position: 170, label: 'Sales Office Name' }]
      salesofficename as SalesOfficeName,

      @UI.lineItem: [{ position: 180, label: 'Sales Group' }]
      salesgroup as SalesGroup,

      @UI.lineItem: [{ position: 190, label: 'Sales Group Name' }]
      salesgroupname as SalesGroupName,

      @UI.lineItem: [{ position: 200, label: 'Sold To Customer Code' }]
      soldtocustomercode as SoldToCustomerCode,

      @UI.lineItem: [{ position: 210, label: 'Sold To Customer Name' }]
      soldtocustomername as SoldToCustomerName,

      @UI.lineItem: [{ position: 220, label: 'Sold To Customer GSTIN No' }]
      soldtocustomergstinno as SoldToCustomerGSTINNo,

      @UI.lineItem: [{ position: 230, label: 'Sold-to-party Address' }]
      soldtopartyaddress as SoldToPartyAddress,

      @UI.lineItem: [{ position: 240, label: 'Sold-to-party State' }]
      soldtopartystate as SoldToPartyState,

      @UI.lineItem: [{ position: 250, label: 'Sold-To Party Country' }]
      soldtopartycountry as SoldToPartyCountry,

      @UI.lineItem: [{ position: 260, label: 'Sold to party Pincode' }]
      soldtopartypincode as SoldToPartyPincode,
      
      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 270 }]
      @UI.lineItem: [{ position: 270, label: 'Bill-To Party Code' }]
      billtopartycode as BillToPartyCode,

      @UI.lineItem: [{ position: 280, label: 'Bill To Party Name' }]
      billtopartyname as BillToPartyName,

      @UI.lineItem: [{ position: 290, label: 'Bill to party Address' }]
      billtopartyaddress as BillToPartyAddress,

      @UI.lineItem: [{ position: 300, label: 'Bill to party State' }]
      billtopartystate as BillToPartyState,

      @UI.lineItem: [{ position: 310, label: 'Bill-To Party Country' }]
      billtopartycountry as BillToPartyCountry,

      @UI.lineItem: [{ position: 320, label: 'Bill to party Pin Code' }]
      billtopartypincode as BillToPartyPinCode,

      @UI.lineItem: [{ position: 330, label: 'Item Code' }]
      itemcode as ItemCode,

      @UI.lineItem: [{ position: 340, label: 'Item Description' }]
      itemdescription as ItemDescription,

      @Search.defaultSearchElement: true
      @UI.lineItem: [{ position: 350, label: 'Material Group Code' }]
      materialgroupcode as MaterialGroupCode,

      @UI.lineItem: [{ position: 360, label: 'Mat Group Code Description' }]
      matgroupcodedescription as MatGroupCodeDescription,

      @UI.lineItem: [{ position: 370, label: 'HSN Code' }]
      hsncode as HSNCode,

      @UI.lineItem: [{ position: 380, label: 'Standard Cost per Unit' }]
      standardcostperunit as StandardCostPerUnit,

      @Search.defaultSearchElement: true
      @UI.lineItem: [{ position: 390, label: 'Material Type Code' }]
      materialtypecode as MaterialTypeCode,

      materialtypedescription as MaterialTypeDescription, 

      @UI.lineItem: [{ position: 410, label: 'Sales Invoice Quantity' }]
      salesinvoicequantity as SalesInvoiceQuantity,
 
      @UI.lineItem: [{ position: 420, label: 'Sales Invoice Qty UOM' }]
      salesinvoiceqtyuom as SalesInvoiceQtyUOM,

      @UI.lineItem: [{ position: 430, label: 'Sales Invoice Gross Weight' }]
      salesinvoicegrossweight as SalesInvoiceGrossWeight,

      @UI.lineItem: [{ position: 440, label: 'Sales Invoice Net Weight' }]
      salesinvoicenetweight as SalesInvoiceNetWeight,

      @UI.lineItem: [{ position: 450, label: 'Sales Invoice Weight UOM' }]
      salesinvoiceweightuom as SalesInvoiceWeightUOM,

      @UI.lineItem: [{ position: 460, label: 'Sales Invoice Unit Price' }]
      salesinvoiceunitprice as SalesInvoiceUnitPrice,

      @UI.lineItem: [{ position: 470, label: 'Sales Invoice Taxable Amount' }]
      salesinvoicetaxableamount as SalesInvoiceTaxableAmount,

      @UI.lineItem: [{ position: 480, label: 'Free Goods Discount' }]
      freegoodsdiscount as FreeGoodsDiscount,

      @UI.lineItem: [{ position: 490, label: 'Freight Amount' }]
      freightamount as FreightAmount,

      @UI.lineItem: [{ position: 500, label: 'Packing Amount' }]
      packingamount as PackingAmount,

      @UI.lineItem: [{ position: 510, label: 'Insurance Amount' }]
      insuranceamount as InsuranceAmount,

      @UI.lineItem: [{ position: 520, label: 'Broker Amount' }]
      brokeramount as BrokerAmount,

      @UI.lineItem: [{ position: 530, label: 'Commission Agent Amount' }]
      commissionagentamount as CommissionAgentAmount,

      @UI.lineItem: [{ position: 540, label: 'CGST%' }]
      cgstpercentage as CGSTPercentage,

      @UI.lineItem: [{ position: 550, label: 'CGST Amount' }]
      cgstamount as CGSTAmount,

      @UI.lineItem: [{ position: 560, label: 'SGST%' }]
      sgstpercentage as SGSTPercentage,

      @UI.lineItem: [{ position: 570, label: 'SGST Amount' }]
      sgstamount as SGSTAmount,

      @UI.lineItem: [{ position: 580, label: 'IGST%' }]
      igstpercentage as IGSTPercentage,

      @UI.lineItem: [{ position: 590, label: 'IGST Amount' }]
      igstamount as IGSTAmount,

      @UI.lineItem: [{ position: 600, label: 'UGST%' }]
      ugstpercentage as UGSTPercentage,

      @UI.lineItem: [{ position: 610, label: 'UGST Amount' }]
      ugstamount as UGSTAmount,

      @UI.lineItem: [{ position: 620, label: 'TCS%' }]
      tcspercentage as TCSPercentage,

      @UI.lineItem: [{ position: 630, label: 'TCS Amount' }]
      tcsamount as TCSAmount,

      @UI.lineItem: [{ position: 640, label: 'Tax Amount' }]
      taxamount as TaxAmount,

      @UI.lineItem: [{ position: 650, label: 'Round Off' }]
      roundoff as RoundOff,

      @UI.lineItem: [{ position: 660, label: 'Invoice Amount' }]
      invoiceamount as InvoiceAmount,

      @UI.lineItem: [{ position: 670, label: 'Document Currency' }]
      documentcurrency as DocumentCurrency,

      @UI.lineItem: [{ position: 680, label: 'Payment Term Code' }]
      paymenttermcode as PaymentTermCode,

      @UI.lineItem: [{ position: 690, label: 'Description' }]
      description as Description,

      @UI.lineItem: [{ position: 700, label: 'Business Place' }]
      businessplace as BusinessPlace,

      @UI.lineItem: [{ position: 710, label: 'INCO Terms' }]
      incoterms as INCOTerms,

      @UI.lineItem: [{ position: 720, label: 'INCO Terms Location' }]
      incotermslocation as INCOTermsLocation,
      
      @UI.lineItem: [{ position: 730, label: 'E-way Bill Number' }]
      ewaybillnumber as EwayBillNumber,

      @UI.lineItem: [{ position: 740, label: 'IRN Ack Number' }]
      irnacknumber as IRNAckNumber,

      @UI.lineItem: [{ position: 750, label: 'E-way Bill Date & Time' }]
      ewaybilldatetime as EwayBillDateTime,

      @UI.lineItem: [{ position: 760, label: 'Cancellation Invoice Number' }]
      cancellationinvoicenumber as CancellationInvoiceNumber,

      @UI.lineItem: [{ position: 770, label: 'Cancellation Indicator' }]
      cancellationindicator as CancellationIndicator,

      @UI.lineItem: [{ position: 780, label: 'PO Number' }]
      ponumber as PONumber,

      @UI.lineItem: [{ position: 790, label: 'PO Date' }]
      podate as PODate,

      @UI.lineItem: [{ position: 800, label: 'Outbound Delivery Number' }]
      outbounddeliverynumber as OutboundDeliveryNumber,

      @UI.lineItem: [{ position: 810, label: 'Delivery Order Date' }]
      deliveryorderdate as DeliveryOrderDate,

      @UI.lineItem: [{ position: 820, label: 'Actual GI Date' }]
      actualgidate as ActualGIDate,

      @UI.lineItem: [{ position: 830, label: 'Ship To Customer Code' }]
      shiptocustomercode as ShipToCustomerCode,

      @UI.lineItem: [{ position: 840, label: 'Ship To Customer Name' }]
      shiptocustomername as ShipToCustomerName,

      @UI.lineItem: [{ position: 850, label: 'Ship-to-party Address' }]
      shiptopartyaddress as ShipToPartyAddress,

      @UI.lineItem: [{ position: 860, label: 'Ship-to-party City' }]
      shiptopartycity as ShipToPartyCity,

      @UI.lineItem: [{ position: 870, label: 'Ship To party State' }]
      shiptopartystate as ShipToPartyState,

      @UI.lineItem: [{ position: 880, label: 'Ship-To Party Country' }]
      shiptopartycountry as ShipToPartyCountry,

      @UI.lineItem: [{ position: 890, label: 'Ship-to-party Pincode' }]
      shiptopartypincode as ShipToPartyPincode,

      @UI.lineItem: [{ position: 900, label: 'Transporter Code' }]
      transportercode as TransporterCode,

      @UI.lineItem: [{ position: 910, label: 'Transporter Name' }]
      transportername as TransporterName,

      @UI.lineItem: [{ position: 920, label: 'Mode of Transport' }]
      modeoftransport as ModeOfTransport,

      @UI.lineItem: [{ position: 930, label: 'Shipping Point' }]
      shippingpoint as ShippingPoint,

      @UI.lineItem: [{ position: 940, label: 'Dispatching Plant' }]
      dispatchingplant as DispatchingPlant,

      @UI.lineItem: [{ position: 950, label: 'Dispatching Plant Name' }]
      dispatchingplantname as DispatchingPlantName,

      @UI.lineItem: [{ position: 960, label: 'Receiving Plant' }]
      receivingplant as ReceivingPlant,

      @UI.lineItem: [{ position: 970, label: 'Receiving Plant Name' }]
      receivingplantname as ReceivingPlantName,

      @UI.lineItem: [{ position: 980, label: 'Storage location' }]
      storagelocation as StorageLocation,

      @UI.lineItem: [{ position: 990, label: 'Descr. of Storage Loc.' }]
      storagelocationdescription as StorageLocationDescription,

      @UI.lineItem: [{ position: 1000, label: 'Delivery Quantity' }]
      deliveryquantity as DeliveryQuantity,

      @UI.lineItem: [{ position: 1010, label: 'UOM Delivery Qty' }]
      uomdeliveryqty as UOMDeliveryQty,

      @UI.lineItem: [{ position: 1020, label: 'Batch' }]
      batch as Batch,

      @UI.lineItem: [{ position: 1030, label: 'Delivery Gross Weight with Packaging' }]
      dlvrygrossweightwithpackaging as DlvryGrossWeightWithPackaging,

      @UI.lineItem: [{ position: 1040, label: 'Delivery Net Oil Weight' }]
      deliverynetoilweight as DeliveryNetOilWeight,

      @UI.lineItem: [{ position: 1050, label: 'Delivery Weight UOM' }]
      deliveryweightuom as DeliveryWeightUOM,

      @UI.lineItem: [{ position: 1060, label: 'Bill of Lading' }]
      billoflading as BillOfLading,

      @UI.lineItem: [{ position: 1070, label: 'Port of Loading' }]
      portofloading as PortOfLoading,

//      @UI.lineItem: [{ position: 1080, label: 'Goods Receipt/Issue Slip' }]
//      goodsreceiptissueslip as GoodsReceiptIssueSlip,

      @UI.lineItem: [{ position: 1090, label: 'Token Number' }]
      tokennumber as TokenNumber,

      @UI.lineItem: [{ position: 1100, label: 'Token Date & Time' }]
      tokendatetime as TokenDateTime,

      @UI.lineItem: [{ position: 1110, label: 'Gate Entry Number' }]
      gateentrynumber as GateEntryNumber,

      @UI.lineItem: [{ position: 1120, label: 'Gate Entry Date & Time' }]
      gateentrydatetime as GateEntryDateTime,

      @UI.lineItem: [{ position: 1130, label: 'Vehicle Number' }]
      vehiclenumber as VehicleNumber,

      @UI.lineItem: [{ position: 1140, label: 'Vessel Name' }]
      vesselname as VesselName,

      @UI.lineItem: [{ position: 1150, label: 'LR No' }]
      lrno as LRNo,

      @UI.lineItem: [{ position: 1160, label: 'LR Date' }]
      lrdate as LRDate,

      @UI.lineItem: [{ position: 1170, label: 'Weighbridge Gross Weight' }]
      weighbridgegrossweight as WeighbridgeGrossWeight,

      @UI.lineItem: [{ position: 1180, label: 'Weighbridge Tare Weight' }]
      weighbridgetareweight as WeighbridgeTareWeight,

      @UI.lineItem: [{ position: 1190, label: 'Weighbridge Net Weight' }]
      weighbridgenetweight as WeighbridgeNetWeight,

      @UI.lineItem: [{ position: 1200, label: 'UOM Weighbridge' }]
      uomweighbridge as UOMWeighbridge,

      @UI.lineItem: [{ position: 1210, label: 'Gate Out Number' }]
      gateoutnumber as GateOutNumber,

      @UI.lineItem: [{ position: 1220, label: 'Gate Out Date & Time' }]
      gateoutdatetime as GateOutDateTime,

      @UI.lineItem: [{ position: 1230, label: 'Sales Order No' }]
      salesorderno as SalesOrderNo,

      @UI.lineItem: [{ position: 1240, label: 'Sales Order Date' }]
      salesorderdate as SalesOrderDate,

      @UI.lineItem: [{ position: 1250, label: 'Sales Order Type' }]
      salesorder_type as SalesOrder_Type,

      @UI.lineItem: [{ position: 1260, label: 'Sales Order Type Desc' }]
      salesordertypedesc as SalesOrderTypeDesc,

      @UI.lineItem: [{ position: 1270, label: 'Customer PO No' }]
      customerpono2 as CustomerPONo2,

      @UI.lineItem: [{ position: 1280, label: 'Customer PO Date' }]
      customerpodate as CustomerPODate,

      @UI.lineItem: [{ position: 1290, label: 'Sales Employee Code' }]
      salesemployeecode as SalesEmployeeCode,

      @UI.lineItem: [{ position: 1300, label: 'Sales Employee Name' }]
      salesemployeename as SalesEmployeeName,

      @UI.lineItem: [{ position: 1310, label: 'Broker Code' }]
      brokercode as BrokerCode,

      @UI.lineItem: [{ position: 1320, label: 'Broker Name' }]
      brokername as BrokerName,

      @UI.lineItem: [{ position: 1330, label: 'Commission Agent Code' }]
      commissionagentcode as CommissionAgentCode,

      @UI.lineItem: [{ position: 1340, label: 'Commission Agent Name' }]
      commissionagentname as CommissionAgentName,
    
      @UI.lineItem: [{ position: 1350, label: 'Contact Person Code' }]
      contactpersoncode as ContactPersonCode,

      @UI.lineItem: [{ position: 1360, label: 'Contact Person Name' }]
      contactpersonname as ContactPersonName,

//      @UI.lineItem: [{ position: 1370, label: 'Order Quantity' }]
//      orderquantity as OrderQuantity,

//      @UI.lineItem: [{ position: 1380, label: 'Confirmed Quantity' }]
//      confirmedquantity as ConfirmedQuantity,

//      @UI.lineItem: [{ position: 1390, label: 'Sales Unit' }]
//      salesunit as SalesUnit,

      @UI.lineItem: [{ position: 1400, label: 'Order Reason' }]
      orderreason as OrderReason,

      @UI.lineItem: [{ position: 1410, label: 'Order Reason Description' }]
      orderreasondescription as OrderReasonDescription,

      @UI.lineItem: [{ position: 1420, label: 'Against Invoice Number' }]
      againstinvoicenumber as AgainstInvoiceNumber,

      @UI.lineItem: [{ position: 1430, label: 'Against Invoice Date' }]
      againstinvoicedate as AgainstInvoiceDate,

      @UI.lineItem: [{ position: 1440, label: 'Customer Group' }]
      customergroup as CustomerGroup,

      @UI.lineItem: [{ position: 1450, label: 'Sales District' }]
      salesdistrict as SalesDistrict,

      @UI.lineItem: [{ position: 1460, label: 'Sales Contract No' }]
      @UI.selectionField: [{exclude: true}]
      salescontractno as SalesContractNo,

      @UI.lineItem: [{ position: 1470, label: 'Sales Contract Date' }]
      salescontractdate as SalesContractDate,

      @UI.lineItem: [{ position: 1480, label: 'Sales Contract Valid From Date' }]
      salescontractvalidfromdate as SalesContractValidFromDate,

      @UI.lineItem: [{ position: 1490, label: 'Sales Contract Valid To Date' }]
      salescontractvalidtodate as SalesContractValidToDate,

//      @UI.lineItem: [{ position: 1500, label: 'Sales Contract Quantity' }]
      @UI.hidden: true
      salescontractquantity as SalesContractQuantity,

//      @UI.lineItem: [{ position: 1510, label: 'Sales Contract Quantity UOM' }]
      @UI.hidden: true  
      salescontractquantityuom as SalesContractQuantityUOM,

      @UI.lineItem: [{ position: 1520, label: 'Sales Contract Type' }]
      salescontract_type as SalesContract_Type,
      
      @UI.lineItem: [{ position: 1530, label: 'Created By' }]
      created_by as Created_By

}

































//@EndUserText.label: 'Sales Register'
//@Search.searchable: false
//@ObjectModel.query.implementedBy: 'ABAP:ZCL_SALES_REG'
//@UI.headerInfo: {typeName: 'Sales Register'}
//@Metadata.allowExtensions: true
//define custom entity ZCDS_SALES
//{
//      @Search.defaultSearchElement: true
//      @UI.selectionField: [{ position: 10 }] // Select-Options
//      @UI.lineItem: [{ position: 10, label: 'Sales Invoice No' }]
//      @EndUserText.label: 'Sales Invoice No' 
//   //   @Consumption.valueHelpDefinition: [{ entity : {  name: 'i_billingdocument', element: 'BILLINGDOCUMENT' } }]
//      key InvoiceNo   : abap.char(10);
//      
////      @Search.defaultSearchElement: true
////      @UI.selectionField   : [{ position:20 }]             
//      @UI.lineItem   : [{ position:20, label:'Line Item No' }]     
//      key ItemNo      : abap.numc(6);   
//      @UI.hidden: true
//      key PricingProcedureStep : abap.numc(3);
//      @UI.hidden: true
//      key PricingProcedureCounter : abap.numc(3);
//      @UI.hidden: true
//      key Plant : abap.char(4);
//      @UI.hidden: true
//      key Product : abap.char(40);
//      @UI.hidden: true 
//      key SalesOrder : abap.char(10);
//      @UI.hidden: true
//      key SalesOrderType : abap.char(4); 
//      @UI.hidden: true
//      key PartnerFunction : abap.char(2);
//      @UI.hidden: true
//      key SalesOrderItem : abap.numc(6);
//      @UI.hidden: true
//      key SalesContract : abap.char(10);
//      @UI.hidden: true
//      key SalesContractType : abap.char(4);
//      @UI.hidden: true
//      key Customer : abap.char(10);
//      @UI.hidden: true
//      key BillingDocument : abap.char(10);
//
//                 
//      @UI.lineItem   : [{ position:30, label:'Sales Invoice Type' }]   
//      InvoiceType      : abap.char(4);   
//          
//      @UI.lineItem   : [{ position:40, label:'Sales Invoice Document Type Des.' }]     
//      InvoiceDocumentTypeDes      : abap.char(60);   
//      
//       @Search.defaultSearchElement: true
//      @UI.selectionField   : [{ position:50 }]             
//      @UI.lineItem   : [{ position:50, label:'Sales Invoice Date' }]     
//      InvoiceDate      : abap.dats(8);   
//                   
//      @UI.lineItem   : [{ position:60, label:'Reference Invoice No' }]     
//      ReferenceInvoiceNo  : abap.char(16); 
//            
//      @UI.lineItem   : [{ position:70, label:'Ref Invoice Date' }]     
//      RefInvoiceDate  : abap.dats(8);   
//
//      @UI.lineItem: [{ position: 80, label: 'Accounting Doc. No.' }]
//      AccountingDocNo: abap.char(10);
//
//      @UI.lineItem: [{ position: 90, label: 'Customer PO No' }]
//      CustomerPONo: abap.char(20);
//      
//      @Search.defaultSearchElement: true
//      @UI.selectionField: [{ position: 100 }]
//      @UI.lineItem: [{ position: 100, label: 'Sales Organization' }]
//      SalesOrganization: abap.char(4);
//
//      @UI.lineItem: [{ position: 110, label: 'Sales Organization Name' }]
//      SalesOrganizationName: abap.char(40);
//      
//      @Search.defaultSearchElement: true
//      @UI.selectionField: [{ position: 120 }]
//      @UI.lineItem: [{ position: 120, label: 'Distribution Channel' }]
//      DistributionChannel: abap.char(2);
//
//      @UI.lineItem: [{ position: 130, label: 'Distribution Channel Name' }]
//      DistributionChannelName: abap.char(20);
//      
//      @Search.defaultSearchElement: true
//      @UI.selectionField: [{ position: 140 }]
//      @UI.lineItem: [{ position: 140, label: 'Sales Division' }]
//      SalesDivision: abap.char(2);
//      
//      @UI.lineItem: [{ position: 150, label: 'Sales Division Name' }]
//      SalesDivisionName: abap.char(20);
//
//      @UI.lineItem: [{ position: 160, label: 'Sales Office' }]
//      SalesOffice: abap.char(4);
//
//      @UI.lineItem: [{ position: 170, label: 'Sales Office Name' }]
//      SalesOfficeName: abap.char(40);
//
//      @UI.lineItem: [{ position: 180, label: 'Sales Group' }]
//      SalesGroup: abap.char(3);
//
//      @UI.lineItem: [{ position: 190, label: 'Sales Group Name' }]
//      SalesGroupName: abap.char(20);
//
//      @UI.lineItem: [{ position: 200, label: 'Sold To Customer Code' }]
//      SoldToCustomerCode: abap.char(10);
//
//      @UI.lineItem: [{ position: 210, label: 'Sold To Customer Name' }]
//      SoldToCustomerName: abap.char(40);
//      
//      @UI.lineItem: [{ position: 220, label: 'Sold To Customer GSTIN No' }]
//      SoldToCustomerGSTINNo: abap.char(15);
//      
//      @UI.lineItem: [{ position: 230, label: 'Sold-to-party Address' }]
//      SoldToPartyAddress: abap.char(150);
//      
//      @UI.lineItem: [{ position: 240, label: 'Sold-to-party State' }]
//      SoldToPartyState: abap.char(40);
//      
//      @UI.lineItem: [{ position: 250, label: 'Sold-To Party Country' }]
//      SoldToPartyCountry: abap.char(3);
//      
//      @UI.lineItem: [{ position: 260, label: 'Sold to party Pincode' }]
//      SoldToPartyPincode: abap.char(10);
//      
//      @Search.defaultSearchElement: true
//      @UI.selectionField: [{ position: 270 }]
//      @UI.lineItem: [{ position: 270, label: 'Bill-To Party Code' }]
//      BillToPartyCode: abap.char(10);
//      
//      @UI.lineItem: [{ position: 280, label: 'Bill To Party Name' }]
//      BillToPartyName: abap.char(35);
//
//      @UI.lineItem: [{ position: 290, label: 'Bill to party Address' }]
//      BillToPartyAddress: abap.char(150);
//
//      @UI.lineItem: [{ position: 300, label: 'Bill to party State' }]
//      BillToPartyState: abap.char(40);
//
//      @UI.lineItem: [{ position: 310, label: 'Bill-To Party Country' }]
//      BillToPartyCountry: abap.char(3);
//
//      @UI.lineItem: [{ position: 320, label: 'Bill to party Pin Code' }]
//      BillToPartyPinCode: abap.char(10);
//
//      @UI.lineItem: [{ position: 330, label: 'Item Code' }]
//      ItemCode: abap.char(40);
//
//      @UI.lineItem: [{ position: 340, label: 'Item Description' }]
//      ItemDescription: abap.char(40);
//      
//      @Search.defaultSearchElement: true
//      @UI.selectionField: [{ position: 350 }]
//      @UI.lineItem: [{ position: 350, label: 'Material Group Code' }]
//      MaterialGroupCode: abap.char(9);
//
//      @UI.lineItem: [{ position: 360, label: 'Mat Group Code Description' }]
//      MatGroupCodeDescription: abap.char(20);
//
//      @UI.lineItem: [{ position: 370, label: 'HSN Code' }]
//      HSNCode: abap.char(8);
//      
//      @UI.lineItem: [{ position: 380, label: 'Standard Cost per Unit' }]
//      StandardCostPerUnit: abap.char(23);
//      
//      @Search.defaultSearchElement: true
//      @UI.selectionField: [{ position: 390 }]
//      @UI.lineItem: [{ position: 390, label: 'Material Type Code' }]
//      MaterialTypeCode: abap.char(4);
//
//      MaterialTypeDescription: abap.char(40);
//      
//      @UI.lineItem: [{ position: 410, label: 'Sales Invoice Quantity' }]
//      SalesInvoiceQuantity: abap.numc(13);
//
//      @UI.lineItem: [{ position: 420, label: 'Sales Invoice Qty UOM' }]
//      SalesInvoiceQtyUOM: abap.unit(3);
//      
//       @UI.lineItem: [{ position: 430, label: 'Sales Invoice Gross Weight' }]
//      SalesInvoiceGrossWeight: abap.dec(15,3);
//      
//      @UI.lineItem: [{ position: 440, label: 'Sales Invoice Net Weight' }]
//      SalesInvoiceNetWeight: abap.dec(15,3);
//      
//      @UI.lineItem: [{ position: 450, label: 'Sales Invoice Weight UOM' }]
//      SalesInvoiceWeightUOM: abap.unit(3);
//      
//      @UI.lineItem: [{ position: 460, label: 'Sales Invoice Unit Price' }]
//      SalesInvoiceUnitPrice: abap.dec(15,2);
//      
//      @UI.lineItem: [{ position: 470, label: 'Sales Invoice Taxable Amount' }]
//      SalesInvoiceTaxableAmount: abap.dec(15,2);
//      
//      @UI.lineItem: [{ position: 480, label: 'Free Goods Discount' }]
//      FreeGoodsDiscount: abap.dec(15,2);
//      
//      @UI.lineItem: [{ position: 490, label: 'Freight Amount' }]
//      FreightAmount: abap.dec(15,2);
//      
//      @UI.lineItem: [{ position: 500, label: 'Packing Amount' }]
//      PackingAmount: abap.dec(15,2);
//      
//      @UI.lineItem: [{ position: 510, label: 'Insurance Amount' }]
//      InsuranceAmount: abap.dec(15,2);
//      
//      @UI.lineItem: [{ position: 520, label: 'Broker Amount' }]
//      BrokerAmount: abap.dec(15,2);
//      
//      @UI.lineItem: [{ position: 530, label: 'Commission Agent Amount' }]
//      CommissionAgentAmount: abap.dec(15,2);
//      
//      @UI.lineItem: [{ position: 540, label: 'CGST%' }]
//      CGSTPercentage: abap.dec(5,2);
//      
//      @UI.lineItem: [{ position: 550, label: 'CGST Amount' }]
//      CGSTAmount: abap.dec(15,2);
//      
//      @UI.lineItem: [{ position: 560, label: 'SGST%' }]
//      SGSTPercentage: abap.dec(5,2);
//      
//      @UI.lineItem: [{ position: 570, label: 'SGST Amount' }]
//      SGSTAmount: abap.dec(15,2);
//      
//      @UI.lineItem: [{ position: 580, label: 'IGST%' }]
//      IGSTPercentage: abap.dec(5,2);
//      
//      @UI.lineItem: [{ position: 590, label: 'IGST Amount' }]
//      IGSTAmount: abap.dec(15,2);
//      
//      @UI.lineItem: [{ position: 600, label: 'UGST%' }]
//      UGSTPercentage: abap.dec(5,2);
//      
//      @UI.lineItem: [{ position: 610, label: 'UGST Amount' }]
//      UGSTAmount: abap.dec(15,2);
//      
//      @UI.lineItem: [{ position: 620, label: 'TCS%' }]
//      TCSPercentage: abap.dec(5,2);
//      
//      @UI.lineItem: [{ position: 630, label: 'TCS Amount' }]
//      TCSAmount: abap.dec(15,2);
//      
//      @UI.lineItem: [{ position: 640, label: 'Tax Amount' }]
//      TaxAmount: abap.dec(15,2);
//      
//      @UI.lineItem: [{ position: 650, label: 'Round Off' }]
//      RoundOff: abap.dec(15,2);
//      
//      @UI.lineItem: [{ position: 660, label: 'Invoice Amount' }]
//      InvoiceAmount: abap.dec(15,2);
//      
//      @UI.lineItem: [{ position: 670, label: 'Document Currency' }]
//      DocumentCurrency: abap.cuky(5);
//      
//      @UI.lineItem: [{ position: 680, label: 'Payment Term Code' }]
//      PaymentTermCode: abap.char(4);
//      
//      @UI.lineItem: [{ position: 690, label: 'Description' }]
//      Description: abap.char(255);
//      
//      @UI.lineItem: [{ position: 700, label: 'Business Place' }]
//      BusinessPlace: abap.char(4);
//      
//      @UI.lineItem: [{ position: 710, label: 'INCO Terms' }]
//      INCOTerms: abap.char(3);
//      
//      @UI.lineItem: [{ position: 720, label: 'INCO Terms Location' }]
//      INCOTermsLocation: abap.char(70);
//      
//      @UI.lineItem: [{ position: 730, label: 'E-way Bill Number' }]
//      EwayBillNumber: abap.char(12);
//      
//      @UI.lineItem: [{ position: 740, label: 'IRN Ack Number' }]
//      IRNAckNumber: abap.char(64);
//      
//      @UI.lineItem: [{ position: 750, label: 'E-way Bill Date & Time' }]
//      EwayBillDateTime: abap.tims;
//      
//      @UI.lineItem: [{ position: 760, label: 'Cancellation Invoice Number' }]
//      CancellationInvoiceNumber: abap.char(10);
//      
//      @UI.lineItem: [{ position: 770, label: 'Cancellation Indicator' }]
//      CancellationIndicator: abap.char(1);
//      
//      @UI.lineItem: [{ position: 780, label: 'PO Number' }]
//      PONumber: abap.char(35);
//      
//      @UI.lineItem: [{ position: 790, label: 'PO Date' }]
//      PODate: abap.dats(8);
//      
//      @UI.lineItem: [{ position: 800, label: 'Outbound Delivery Number' }]
//      OutboundDeliveryNumber: abap.char(10);
//      
//      @UI.lineItem: [{ position: 810, label: 'Delivery Order Date' }]
//      DeliveryOrderDate: abap.dats(8);
//      
//      @UI.lineItem: [{ position: 820, label: 'Actual GI Date' }]
//      ActualGIDate: abap.dats(8);
//      
//      @UI.lineItem: [{ position: 830, label: 'Ship To Customer Code' }]
//      ShipToCustomerCode: abap.char(10);
//      
//      @UI.lineItem: [{ position: 840, label: 'Ship To Customer Name' }]
//      ShipToCustomerName: abap.char(40);
//      
//      @UI.lineItem: [{ position: 850, label: 'Ship-to-party Address' }]
//      ShipToPartyAddress: abap.char(150);
//      
//      @UI.lineItem: [{ position: 860, label: 'Ship-to-party City' }]
//      ShipToPartyCity: abap.char(40);
//      
//      @UI.lineItem: [{ position: 870, label: 'Ship To party State' }]
//      ShipToPartyState: abap.char(40);
//      
//      @UI.lineItem: [{ position: 880, label: 'Ship-To Party Country' }]
//      ShipToPartyCountry: abap.char(3);
//      
//      @UI.lineItem: [{ position: 890, label: 'Ship-to-party Pincode' }]
//      ShipToPartyPincode: abap.char(10);
//      
//      @UI.lineItem: [{ position: 900, label: 'Transporter Code' }]
//      TransporterCode: abap.char(10);
//      
//      @UI.lineItem: [{ position: 910, label: 'Transporter Name' }]
//      TransporterName: abap.char(35);
//      
//      @UI.lineItem: [{ position: 920, label: 'Mode of Transport' }]
//      ModeOfTransport: abap.char(4);
//      
//      @UI.lineItem: [{ position: 930, label: 'Shipping Point' }]
//      ShippingPoint: abap.char(4);
//      
//      @UI.lineItem: [{ position: 940, label: 'Dispatching Plant' }]
//      DispatchingPlant: abap.char(4);
//      
//      @UI.lineItem: [{ position: 950, label: 'Dispatching Plant Name' }]
//      DispatchingPlantName: abap.char(30);
//      
//      @UI.lineItem: [{ position: 960, label: 'Receiving Plant' }]
//      ReceivingPlant: abap.char(4);
//      
//      @UI.lineItem: [{ position: 970, label: 'Receiving Plant Name' }]
//      ReceivingPlantName: abap.char(30);
//      
//      @UI.lineItem: [{ position: 980, label: 'Storage location' }]
//      StorageLocation: abap.char(4);
//      
//      @UI.lineItem: [{ position: 990, label: 'Descr. of Storage Loc.' }]
//      StorageLocationDescription: abap.char(30);
//      
//      @UI.lineItem: [{ position: 1000, label: 'Delivery Quantity' }]
//      DeliveryQuantity: abap.dec(15,3);
//      
//      @UI.lineItem: [{ position: 1010, label: 'UOM Delivery Qty' }]
//      UOMDeliveryQty: abap.unit(3);
//      
//      @UI.lineItem: [{ position: 1020, label: 'Batch' }]
//      Batch: abap.char(10);
//      
//      @UI.lineItem: [{ position: 1030, label: 'Delivery Gross Weight with Packaging' }]
//      DlvryGrossWeightWithPackaging: abap.dec(15,3);
//      
//      @UI.lineItem: [{ position: 1040, label: 'Delivery Net Oil Weight' }]
//      DeliveryNetOilWeight: abap.dec(15,3);
//      
//      @UI.lineItem: [{ position: 1050, label: 'Delivery Weight UOM' }]
//      DeliveryWeightUOM: abap.unit(3);
//      
//      @UI.lineItem: [{ position: 1060, label: 'Bill of Lading' }]
//      BillOfLading: abap.char(35);
//      
//      @UI.lineItem: [{ position: 1070, label: 'Port of Loading' }]
//      PortOfLoading: abap.char(35);
//      
//      @UI.lineItem: [{ position: 1080, label: 'Goods Receipt/Issue Slip' }]
//      GoodsReceiptIssueSlip: abap.char(20);
//      
//      @UI.lineItem: [{ position: 1090, label: 'Token Number' }]
//      TokenNumber: abap.char(20);
//      
//      @UI.lineItem: [{ position: 1100, label: 'Token Date & Time' }]
//      TokenDateTime: abap.tims;
//      
//      @UI.lineItem: [{ position: 1110, label: 'Gate Entry Number' }]
//      GateEntryNumber: abap.char(20);
//      
//      @UI.lineItem: [{ position: 1120, label: 'Gate Entry Date & Time' }]
//      GateEntryDateTime: abap.tims;
//      
//      @UI.lineItem: [{ position: 1130, label: 'Vehicle Number' }]
//      VehicleNumber: abap.char(20);
//      
//      @UI.lineItem: [{ position: 1140, label: 'Vessel Name' }]
//      VesselName: abap.char(35);
//      
//      @UI.lineItem: [{ position: 1150, label: 'LR No' }]
//      LRNo: abap.char(20);
//      
//      @UI.lineItem: [{ position: 1160, label: 'LR Date' }]
//      LRDate: abap.dats(8);
//      
//      @UI.lineItem: [{ position: 1170, label: 'Weighbridge Gross Weight' }]
//      WeighbridgeGrossWeight: abap.dec(15,3);
//      
//      @UI.lineItem: [{ position: 1180, label: 'Weighbridge Tare Weight' }]
//      WeighbridgeTareWeight: abap.dec(15,3);
//      
//      @UI.lineItem: [{ position: 1190, label: 'Weighbridge Net Weight' }]
//      WeighbridgeNetWeight: abap.dec(15,3);
//      
//      @UI.lineItem: [{ position: 1200, label: 'UOM Weighbridge' }]
//      UOMWeighbridge: abap.unit(3);
//      
//      @UI.lineItem: [{ position: 1210, label: 'Gate Out Number' }]
//      GateOutNumber: abap.char(20);
//      
//      @UI.lineItem: [{ position: 1220, label: 'Gate Out Date & Time' }]
//      GateOutDateTime: abap.tims;
//      
//      @UI.lineItem: [{ position: 1230, label: 'Sales Order No' }]
//      SalesOrderNo: abap.char(10);
//      
//      @UI.lineItem: [{ position: 1240, label: 'Sales Order Date' }]
//      SalesOrderDate: abap.dats(8);
//      
//      @UI.lineItem: [{ position: 1250, label: 'Sales Order Type' }]
//      SalesOrder_Type: abap.char(4);
//      
//      @UI.lineItem: [{ position: 1260, label: 'Sales Order Type Desc' }]
//      SalesOrderTypeDesc: abap.char(60);
//      
//      @UI.lineItem: [{ position: 1270, label: 'Customer PO No' }]
//      CustomerPONo2: abap.char(35);
//      
//      @UI.lineItem: [{ position: 1280, label: 'Customer PO Date' }]
//      CustomerPODate: abap.dats(8);
//      
//      @UI.lineItem: [{ position: 1290, label: 'Sales Employee Code' }]
//      SalesEmployeeCode: abap.char(8);
//      
//      @UI.lineItem: [{ position: 1300, label: 'Sales Employee Name' }]
//      SalesEmployeeName: abap.char(40);
//      
//      @UI.lineItem: [{ position: 1310, label: 'Broker Code' }]
//      BrokerCode: abap.char(10);
//      
//      @UI.lineItem: [{ position: 1320, label: 'Broker Name' }]
//      BrokerName: abap.char(35);
//      
//      @UI.lineItem: [{ position: 1330, label: 'Commission Agent Code' }]
//      CommissionAgentCode: abap.char(10);
//      
//      @UI.lineItem: [{ position: 1340, label: 'Commission Agent Name' }]
//      CommissionAgentName: abap.char(35);
//      
//      @UI.lineItem: [{ position: 1350, label: 'Contact Person Code' }]
//      ContactPersonCode: abap.char(10);
//      
//      @UI.lineItem: [{ position: 1360, label: 'Contact Person Name' }]
//      ContactPersonName: abap.char(35);
//      
//      @UI.lineItem: [{ position: 1370, label: 'Order Quantity' }]
//      OrderQuantity: abap.dec(15,3);
//      
//      @UI.lineItem: [{ position: 1380, label: 'Confirmed Quantity' }]
//      ConfirmedQuantity: abap.dec(15,3);
//      
//      @UI.lineItem: [{ position: 1390, label: 'Sales Unit' }]
//      SalesUnit: abap.unit(3);
//      
//      @UI.lineItem: [{ position: 1400, label: 'Order Reason' }]
//      OrderReason: abap.char(4);
//      
//      @UI.lineItem: [{ position: 1410, label: 'Order Reason Description' }]
//      OrderReasonDescription: abap.char(60);
//      
//      @UI.lineItem: [{ position: 1420, label: 'Against Invoice Number' }]
//      AgainstInvoiceNumber: abap.char(10);
//      
//      @UI.lineItem: [{ position: 1430, label: 'Against Invoice Date' }]
//      AgainstInvoiceDate: abap.dats(8);
//      
//      @UI.lineItem: [{ position: 1440, label: 'Customer Group' }]
//      CustomerGroup: abap.char(2);
//      
//      @UI.lineItem: [{ position: 1450, label: 'Sales District' }]
//      SalesDistrict: abap.char(6);
//      
//      @UI.lineItem: [{ position: 1460, label: 'Sales Contract No' }]
//      SalesContractNo: abap.char(10);
//      
//      @UI.lineItem: [{ position: 1470, label: 'Sales Contract Date' }]
//      SalesContractDate: abap.dats(8);
//      
//      @UI.lineItem: [{ position: 1480, label: 'Sales Contract Valid From Date' }]
//      SalesContractValidFromDate: abap.dats(8);
//      
//      @UI.lineItem: [{ position: 1490, label: 'Sales Contract Valid To Date' }]
//      SalesContractValidToDate: abap.dats(8);
//      
//      @UI.lineItem: [{ position: 1500, label: 'Sales Contract Quantity' }]
//      SalesContractQuantity: abap.dec(15,3);
//      
//      @UI.lineItem: [{ position: 1510, label: 'Sales Contract Quantity UOM' }]
//      SalesContractQuantityUOM: abap.unit(3);
//      
//      @UI.lineItem: [{ position: 1520, label: 'Sales Contract Type' }]
//      SalesContract_Type: abap.char(4);
//
//}
