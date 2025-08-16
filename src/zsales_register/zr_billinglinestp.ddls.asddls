@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Billing Lines CDS View'
define view entity ZR_BillingLinesTP
  as select from zbillinglines as BillingLines
  association to parent ZR_BillingDocTP as _BillingDoc on  $projection.bukrs               = _BillingDoc.Bukrs
                                                       and $projection.Fiscalyearvalue     = _BillingDoc.Fiscalyearvalue
                                                       and $projection.billingdocumentitem = _BillingDoc.Billingdocument
{
      @EndUserText.label: 'Company Code'
  key companycode                as bukrs,
      @EndUserText.label: 'Fiscal Year Value'
  key fiscalyearvalue            as Fiscalyearvalue,
      // V
      @EndUserText.label: 'Invoice No'
  key invoice                    as billingdocument,
      // AB
      @EndUserText.label: 'Line Item No.'
  key lineitemno                 as billingdocumentitem,
      // A
      @EndUserText.label: 'Sales Quotation'
      salesquotation             as referencesddocument,
      // B
      @EndUserText.label: 'Creation Date'
      creationdate               as creationdate,
      // C
      @EndUserText.label: 'Sales Person'
      salesperson                as fullname,
      // D
      @EndUserText.label: 'Sale Order Number'
      saleordernumber            as salesdocument,
      // E
      @EndUserText.label: 'Sales Creation Date'
      salescreationdate          as sales_creationdate,
      // F
      @EndUserText.label: 'Customer PO Number'
      customerponumber           as purchaseorderbycustomer,
      // G
      @EndUserText.label: 'Sold to party GSTIN'
      soldtopartygstin           as taxnumber3,
      //companycode             as companycode,
      // I
      @EndUserText.label: 'Sold-to Party Name'
      soldtopartyname            as customername,
      // J
      @EndUserText.label: 'Sold-to Party Number'
      soldtopartynumber          as soldtoparty,
      // K
      @EndUserText.label: 'Ship to Party Number'
      shiptopartynumber          as shiptoparty,
      // L
      @EndUserText.label: 'Ship to Party Name'
      shiptopartyname            as ship_customername,
      // M
      @EndUserText.label: 'Ship to Party GST No.'
      shiptopartygstno           as ship_taxnumber3,
      // N
      @EndUserText.label: 'Delivery Place State Code'
      deliveryplacestatecode     as del_place_state_code,
      // P
      @EndUserText.label: 'Sold to Region Code'
      soldtoregioncode           as sold_region_code,
      // Q
      @EndUserText.label: 'Delivery Number'
      deliverynumber             as D_ReferenceSDDocument,
      // R
      @EndUserText.label: 'Delivery Date'
      deliverydate               as delivery_CreationDate,
      // S
      @EndUserText.label: 'Billing Type'
      billingtype                as BillingDocumentType,
      // T
      @EndUserText.label: 'Billing Doc. Desc.'
      billingdocdesc             as billing_doc_desc,
      // U
      @EndUserText.label: 'Bill No.'
      billno                     as documentreferenceid,
      // X
      @EndUserText.label: 'E - way Bill Number'
      ewaybillnumber             as E_way_Bill_Number,
      // Y
      @EndUserText.label: 'E way Bill Date & Time'
      ewaybilldatetime           as E_way_Bill_Date_Time,
      // Z
      @EndUserText.label: 'IRN Ack Number'
      irnacknumber               as IRN_Ack_Number,
      // AA
      @EndUserText.label: 'Delivery Plant'
      deliveryplant              as del_plant,
      // W
      @EndUserText.label: 'Invoice Date'
      invoicedate                as Billingdocumentdate,
      // AC
      @EndUserText.label: 'Material No'
      materialno                 as Product,
      // AD
      @EndUserText.label: 'Material Description'
      materialdescription        as Materialdescription,
      // AE
      @EndUserText.label: 'Customer Item Code'
      customeritemcode           as MaterialByCustomer,
      // AF
      @EndUserText.label: 'HSN Code'
      hsncode                    as ConsumptionTaxCtrlCode,
      // AG
      @EndUserText.label: 'HS Code'
      hscode                     as YY1_SOHSCODE_SDI,
      // AH
      @EndUserText.label: 'QTY'
      qty                        as billingQuantity,
      // AI
      @EndUserText.label: 'UOM'
      uom                        as baseunit,
      // AK
      @EndUserText.label: 'Document currency'
      documentcurrency           as transactioncurrency,
      // AL
      @EndUserText.label: 'Exchange rate'
      exchangerate               as accountingexchangerate,
      // AJ
      @EndUserText.label: 'Rate'
      rate                       as Itemrate,
      // AM
      @EndUserText.label: 'Rate in INR'
      rateininr                  as rate_in_inr,
      // AN
      @EndUserText.label: 'Taxable Value before Discount'
      taxablevaluebeforediscount as taxable_value,
      // AV
      @EndUserText.label: 'IGST Amt'
      igstamt                    as Igst,
      // AZ
      @EndUserText.label: 'SGST Amt'
      sgstamt                    as Sgst,
      // AX
      @EndUserText.label: 'CGST Amt'
      cgstamt                    as Cgst,
      // AQ
      @EndUserText.label: 'Taxable Value After Discount'
      taxablevalueafterdiscount  as taxable_value_dis,
      // AR
      @EndUserText.label: 'Freight Charge INR'
      freightchargeinr           as freight_charge_inr,
      // AS
      @EndUserText.label: 'Insurance Rate INR'
      insurancerateinr           as insurance_rate,
      // AT
      @EndUserText.label: 'Insurance Amount INR'
      insuranceamountinr         as insurance_amt,
      // BA
      @EndUserText.label: 'UGST Rate'
      ugstrate                   as rateugst,
      // BB
      @EndUserText.label: 'UGST Amt'
      ugstamt                    as ugst,
      // BE
      @EndUserText.label: 'Roundoff Value'
      roundoffvalue              as Roundoff,
      // AP
      @EndUserText.label: 'Discount Amount'
      discountamount             as Discount,
      // AO
      @EndUserText.label: 'Discount Rate'
      discountrate               as ratediscount,
      // BF
      @EndUserText.label: 'Invoice Amount'
      invoiceamount              as Totalamount,
      // AU
      @EndUserText.label: 'IGST Rate'
      igstrate                   as Rateigst,
      // AW
      @EndUserText.label: 'CGST Rate'
      cgstrate                   as Ratecgst,
      // AY
      @EndUserText.label: 'SGST Rate'
      sgstrate                   as Ratesgst,
      // BC
      @EndUserText.label: 'TCS Rate'
      tcsrate                    as Ratetcs,
      // BD
      @EndUserText.label: 'TCS Amount'
      tcsamount                  as Tcs,
      @EndUserText.label: 'Cancelled Invoice'
      cancelledinvoice           as cancelledinvoice,
      case when cancelledinvoice = 'X' then
      1 else 0 end  as Cancelled,

      _BillingDoc

}
