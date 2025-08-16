CLASS zcl_sales_reg DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .

    INTERFACES if_oo_adt_classrun .

    INTERFACES if_rap_query_provider.
    class-METHODS runjob
      IMPORTING paraminvoiceno type c .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SALES_REG IMPLEMENTATION.


 METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
*    et_parameter_def = VALUE #(
*      ( selname = 'S_ID'    kind = if_apj_dt_exec_object=>select_option datatype = 'C' length = 10 param_text = 'My ID'                                      changeable_ind = abap_true )
*      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 80 param_text = 'My Description'   lowercase_ind = abap_true changeable_ind = abap_true )
*      ( selname = 'P_COUNT' kind = if_apj_dt_exec_object=>parameter     datatype = 'I' length = 10 param_text = 'My Count'                                   changeable_ind = abap_true )
*      ( selname = 'P_SIMUL' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length =  1 param_text = 'My Simulate Only' checkbox_ind = abap_true  changeable_ind = abap_true )
*    ).
*
*    " Return the default parameters values here
*    et_parameter_val = VALUE #(
*      ( selname = 'S_ID'    kind = if_apj_dt_exec_object=>select_option sign = 'I' option = 'EQ' low = '4711' )
*      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'My Default Description' )
*      ( selname = 'P_COUNT' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = '200' )
*      ( selname = 'P_SIMUL' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = abap_true )
*    ).
  ENDMETHOD.


 METHOD if_apj_rt_exec_object~execute.

    runjob( '' ).

  ENDMETHOD.


METHOD if_oo_adt_classrun~main.

runjob( '0000000000' ).


ENDMETHOD.


 METHOD if_rap_query_provider~select.
   IF io_request->is_data_requested( ).

     DATA: lt_response    TYPE TABLE OF zcds_sales,
           ls_response    TYPE zcds_sales,
           lt_responseout LIKE lt_response,
           ls_responseout LIKE LINE OF lt_responseout.

     DATA(lv_top)           = io_request->get_paging( )->get_page_size( ).
     DATA(lv_skip)          = io_request->get_paging( )->get_offset( ).
     DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0
                                 ELSE lv_top ).

*      DATA(lt_clause)        = io_request->get_filter( )->get_as_ranges( ).
     DATA(lt_parameter)     = io_request->get_parameters( ).
     DATA(lt_fields)        = io_request->get_requested_elements( ).
     DATA(lt_sort)          = io_request->get_sort_elements( ).


     DATA: lt_invoice_no    TYPE RANGE OF i_billingdocument-billingdocument,
           lt_ItemNo        TYPE RANGE OF zsales_reg_tb-itemno,
           lt_invoice_date  TYPE RANGE OF i_billingdocument-billingdocumentdate,
           lt_sales_org     TYPE RANGE OF i_billingdocument-salesorganization,
           lt_dist_channel  TYPE RANGE OF i_billingdocument-distributionchannel,
           lt_mat_type_code TYPE RANGE OF i_product-producttype,
           lt_mat_grp       TYPE RANGE OF i_billingdocumentitem-productgroup,
           lt_bill_party    TYPE RANGE OF i_billingdocumentpartner-customer,
           lt_sales_div     TYPE RANGE OF i_billingdocument-division,
           lt_accnt_no      TYPE RANGE OF i_billingdocument-AccountingDocument.
     DATA: lt_invoice_type             TYPE RANGE OF zsales_reg_tb-invoicetype,
           lt_invoice_doc_type_des     TYPE RANGE OF zsales_reg_tb-invoicedocumenttypedes,
           lt_ref_invoice_no           TYPE RANGE OF zsales_reg_tb-referenceinvoiceno,
           lt_ref_invoice_date         TYPE RANGE OF zsales_reg_tb-refinvoicedate,
           lt_accounting_doc_no        TYPE RANGE OF zsales_reg_tb-accountingdocno,
           lt_customer_po_no           TYPE RANGE OF zsales_reg_tb-customerpono,
           lt_sales_office             TYPE RANGE OF zsales_reg_tb-salesoffice,
           lt_sales_group              TYPE RANGE OF zsales_reg_tb-salesgroup,
           lt_sold_to_party            TYPE RANGE OF zsales_reg_tb-soldtocustomercode,
           lt_item_code                TYPE RANGE OF zsales_reg_tb-itemcode,
           lt_hsn_code                 TYPE RANGE OF zsales_reg_tb-hsncode,
           lt_cgst_percentage          TYPE RANGE OF zsales_reg_tb-cgstpercentage,
           lt_sgst_percentage          TYPE RANGE OF zsales_reg_tb-sgstpercentage,
           lt_igst_percentage          TYPE RANGE OF zsales_reg_tb-igstpercentage,
           lt_ugst_percentage          TYPE RANGE OF zsales_reg_tb-ugstpercentage,
           lt_tcs_percentage           TYPE RANGE OF zsales_reg_tb-tcspercentage,
           lt_document_currency        TYPE RANGE OF zsales_reg_tb-documentcurrency,
           lt_payment_term_code        TYPE RANGE OF zsales_reg_tb-paymenttermcode,
           lt_business_place           TYPE RANGE OF zsales_reg_tb-businessplace,
           lt_incoterms                TYPE RANGE OF zsales_reg_tb-incoterms,
           lt_ewaybill_number          TYPE RANGE OF zsales_reg_tb-ewaybillnumber,
           lt_irn_ack_number           TYPE RANGE OF zsales_reg_tb-irnacknumber,
           lt_outbound_delivery_number TYPE RANGE OF zsales_reg_tb-outbounddeliverynumber,
           lt_ship_to_party_code       TYPE RANGE OF zsales_reg_tb-shiptocustomercode,
           lt_transporter_code         TYPE RANGE OF zsales_reg_tb-transportercode,
           lt_mode_of_transport        TYPE RANGE OF zsales_reg_tb-modeoftransport,
           lt_shipping_point           TYPE RANGE OF zsales_reg_tb-shippingpoint,
           lt_batch                    TYPE RANGE OF zsales_reg_tb-batch,
           lt_bill_of_lading           TYPE RANGE OF zsales_reg_tb-billoflading,
           lt_vehicle_number           TYPE RANGE OF zsales_reg_tb-vehiclenumber,
           lt_vessel_name              TYPE RANGE OF zsales_reg_tb-vesselname,
           lt_lr_no                    TYPE RANGE OF zsales_reg_tb-lrno,
           lt_sales_order_no           TYPE RANGE OF zsales_reg_tb-salesorderno,
           lt_sales_order_type         TYPE RANGE OF zsales_reg_tb-salesorder_type,
           lt_sales_employee_code      TYPE RANGE OF zsales_reg_tb-salesemployeecode,
           lt_broker_code              TYPE RANGE OF zsales_reg_tb-brokercode,
           lt_commission_agent_code    TYPE RANGE OF zsales_reg_tb-commissionagentcode,
           lt_contact_person_code      TYPE RANGE OF zsales_reg_tb-contactpersoncode,
           lt_customer_group           TYPE RANGE OF zsales_reg_tb-customergroup,
           lt_sales_district           TYPE RANGE OF zsales_reg_tb-salesdistrict,
           lt_sales_contract_no        TYPE RANGE OF zsales_reg_tb-salescontractno,
           lt_created_by               TYPE RANGE OF zsales_reg_tb-created_by,
           lt_cancellation_invoice_no  TYPE RANGE OF zsales_reg_tb-cancellationinvoicenumber,
           lt_cancellation_ind         TYPE RANGE OF zsales_reg_tb-cancellationindicator,
           lt_po_number                TYPE RANGE OF zsales_reg_tb-ponumber,
           lt_po_date                  TYPE RANGE OF zsales_reg_tb-podate,
           lt_token_number             TYPE RANGE OF zsales_reg_tb-tokennumber,
           lt_token_datetime           TYPE RANGE OF zsales_reg_tb-tokendatetime,
           lt_gate_entry_number        TYPE RANGE OF zsales_reg_tb-gateentrynumber,
           lt_gate_entry_datetime      TYPE RANGE OF zsales_reg_tb-gateentrydatetime,
           lt_gate_out_number          TYPE RANGE OF zsales_reg_tb-gateoutnumber,
           lt_gate_out_datetime        TYPE RANGE OF zsales_reg_tb-gateoutdatetime,
           lt_weighbridge_gross        TYPE RANGE OF zsales_reg_tb-weighbridgegrossweight,
           lt_weighbridge_tare         TYPE RANGE OF zsales_reg_tb-weighbridgetareweight,
           lt_weighbridge_net          TYPE RANGE OF zsales_reg_tb-weighbridgenetweight,
           lt_uom_weighbridge          TYPE RANGE OF zsales_reg_tb-uomweighbridge.
*      lt_compnay_code   type range o

     TRY.
         DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
       CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
         " Minimal handling to satisfy SLIN
         RETURN.
     ENDTRY.


     LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
       CASE ls_filter_cond-name.
         WHEN 'INVOICENO'.
           lt_invoice_no = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'ITEMNO'.
           lt_ItemNo = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'INVOICEDATE'.
           lt_invoice_date = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'SALESORGANIZATION'.
           lt_sales_org = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'DISTRIBUTIONCHANNEL'.
           lt_dist_channel = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'MATERIALTYPECODE'.
           lt_mat_type_code = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'MATERIALGROUPCODE'.
           lt_mat_grp = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'BILLTOPARTYCODE'.
           lt_bill_party = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'SALESDIVISION'.
           lt_sales_div = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'ACCOUNTINGDOCNO'.
           lt_accnt_no = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'INVOICETYPE'.
           lt_invoice_type = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'INVOICEDOCUMENTTYPEDES'.
           lt_invoice_doc_type_des = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'REFERENCEINVOICENO'.
           lt_ref_invoice_no = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'REFINVOICEDATE'.
           lt_ref_invoice_date = CORRESPONDING #( ls_filter_cond-range ).
*WHEN 'ACCOUNTINGDOCNO'.
*  lt_accounting_doc_no = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'CUSTOMERPONO'.
           lt_customer_po_no = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'SALESOFFICE'.
           lt_sales_office = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'SALESGROUP'.
           lt_sales_group = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'SOLDTOPARTYCODE'.
           lt_sold_to_party = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'ITEMCODE'.
           lt_item_code = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'HSNCODE'.
           lt_hsn_code = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'CGSTPERCENTAGE'.
           lt_cgst_percentage = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'SGSTPERCENTAGE'.
           lt_sgst_percentage = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'IGSTPERCENTAGE'.
           lt_igst_percentage = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'UGSTPERCENTAGE'.
           lt_ugst_percentage = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'TCSPERCENTAGE'.
           lt_tcs_percentage = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'DOCUMENTCURRENCY'.
           lt_document_currency = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'PAYMENTTERMCODE'.
           lt_payment_term_code = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'BUSINESSPLACE'.
           lt_business_place = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'INCOTERMS'.
           lt_incoterms = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'EWAYBILLNUMBER'.
           lt_ewaybill_number = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'IRNACKNUMBER'.
           lt_irn_ack_number = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'OUTBOUNDDELIVERYNUMBER'.
           lt_outbound_delivery_number = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'SHIPTOPARTYCODE'.
           lt_ship_to_party_code = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'TRANSPORTERCODE'.
           lt_transporter_code = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'MODE_OF_TRANSPORT'.
           lt_mode_of_transport = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'SHIPPINGPOINT'.
           lt_shipping_point = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'BATCH'.
           lt_batch = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'BILLOFLOADING'.
           lt_bill_of_lading = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'VEHICLENUMBER'.
           lt_vehicle_number = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'VESSELNAME'.
           lt_vessel_name = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'LRNO'.
           lt_lr_no = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'SALESORDERNO'.
           lt_sales_order_no = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'SALESORDER_TYPE'.
           lt_sales_order_type = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'SALESEMPLOYEECODE'.
           lt_sales_employee_code = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'BROKERCODE'.
           lt_broker_code = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'COMMISSIONAGENTCODE'.
           lt_commission_agent_code = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'CONTACTPERSONCODE'.
           lt_contact_person_code = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'CUSTOMERGROUP'.
           lt_customer_group = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'SALESDISTRICT'.
           lt_sales_district = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'SALESCONTRACTNO'.
           lt_sales_contract_no = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'CREATED_BY'.
           lt_created_by = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'CANCELLATIONINVOICENUMBER'.
           lt_cancellation_invoice_no = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'CANCELLATIONINDICATOR'.
           lt_cancellation_ind = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'PONUMBER'.
           lt_po_number = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'PODATE'.
           lt_po_date = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'TOKENDATETIME'.
           lt_token_datetime = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'TOKENNUMBER'.
           lt_token_number = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'GATEENTRYNUMBER'.
           lt_gate_entry_number = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'GATEENTRYDATETIME'.
           lt_gate_entry_datetime = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'GATEOUTNUMBER'.
           lt_gate_out_number = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'GATEOUTDATETIME'.
           lt_gate_out_datetime = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'WEIGHBRIDGEGROSSWEIGHT'.
           lt_weighbridge_gross = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'WEIGHBRIDGETAREWEIGHT'.
           lt_weighbridge_tare = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'WEIGHBRIDGENETWEIGHT'.
           lt_weighbridge_net = CORRESPONDING #( ls_filter_cond-range ).
         WHEN 'UOMWEIGHBRIDGE'.
           lt_uom_weighbridge = CORRESPONDING #( ls_filter_cond-range ).

       ENDCASE.
     ENDLOOP.


     DATA: lt_result TYPE STANDARD TABLE OF zsales_reg_tb.

     SELECT * FROM zsales_reg_tb AS a
            WHERE a~BillingDocument IN @lt_invoice_no
               AND a~itemno IN @lt_ItemNo
               AND a~InvoiceDate IN @lt_Invoice_Date
               AND a~SalesOrganization IN @lt_Sales_Org
               AND a~DistributionChannel IN @lt_Dist_Channel
               AND a~materialtypecode IN @lt_Mat_Type_Code
               AND a~materialgroupcode IN @lt_Mat_Grp
               AND a~Customer IN @lt_Bill_party
               AND a~SalesDivision IN @lt_Sales_Div
               AND a~accountingdocno IN @lt_accnt_no

               AND a~InvoiceType IN @lt_invoice_type
   AND a~InvoiceDocumentTypeDes IN @lt_invoice_doc_type_des
   AND a~ReferenceInvoiceNo IN @lt_ref_invoice_no
   AND a~RefInvoiceDate IN @lt_ref_invoice_date
*and a~AccountingDocNo in @lt_accounting_doc_no
   AND a~CustomerPONo IN @lt_customer_po_no
   AND a~SalesOffice IN @lt_sales_office
   AND a~SalesGroup IN @lt_sales_group
   AND a~SoldToCustomerCode IN @lt_sold_to_party
   AND a~ItemCode IN @lt_item_code
   AND a~HSNCode IN @lt_hsn_code
   AND a~CGSTPercentage IN @lt_cgst_percentage
   AND a~SGSTPercentage IN @lt_sgst_percentage
   AND a~IGSTPercentage IN @lt_igst_percentage
   AND a~UGSTPercentage IN @lt_ugst_percentage
   AND a~TCSPercentage IN @lt_tcs_percentage
   AND a~DocumentCurrency IN @lt_document_currency
   AND a~PaymentTermCode IN @lt_payment_term_code
   AND a~BusinessPlace IN @lt_business_place
   AND a~INCOTerms IN @lt_incoterms
   AND a~EwayBillNumber IN @lt_ewaybill_number
   AND a~IRNAckNumber IN @lt_irn_ack_number
   AND a~OutboundDeliveryNumber IN @lt_outbound_delivery_number
   AND a~ShipToCustomerCode IN @lt_ship_to_party_code
   AND a~TransporterCode IN @lt_transporter_code
   AND a~ModeOfTransport IN @lt_mode_of_transport
   AND a~ShippingPoint IN @lt_shipping_point
   AND a~Batch IN @lt_batch
   AND a~BillOfLading IN @lt_bill_of_lading
   AND a~VehicleNumber IN @lt_vehicle_number
   AND a~VesselName IN @lt_vessel_name
   AND a~LRNo IN @lt_lr_no
   AND a~SalesOrderNo IN @lt_sales_order_no
   AND a~SalesOrder_Type IN @lt_sales_order_type
   AND a~SalesEmployeeCode IN @lt_sales_employee_code
   AND a~BrokerCode IN @lt_broker_code
   AND a~CommissionAgentCode IN @lt_commission_agent_code
   AND a~ContactPersonCode IN @lt_contact_person_code
   AND a~CustomerGroup IN @lt_customer_group
   AND a~SalesDistrict IN @lt_sales_district
   AND a~SalesContractNo IN @lt_sales_contract_no
   AND a~Created_By IN @lt_created_by
   AND a~CancellationInvoiceNumber IN @lt_cancellation_invoice_no
   AND a~CancellationIndicator IN @lt_cancellation_ind
   AND a~PONumber IN @lt_po_number
   AND a~PODate IN @lt_po_date
   AND a~TokenNumber IN @lt_token_number
   AND a~TokenDateTime IN @lt_token_datetime
   AND a~GateEntryNumber IN @lt_gate_entry_number
   AND a~GateEntryDateTime IN @lt_gate_entry_datetime
   AND a~GateOutNumber IN @lt_gate_out_number
   AND a~GateOutDateTime IN @lt_gate_out_datetime
   AND a~WeighbridgeGrossWeight IN @lt_weighbridge_gross
   AND a~WeighbridgeTareWeight IN @lt_weighbridge_tare
   AND a~WeighbridgeNetWeight IN @lt_weighbridge_net
   AND a~UOMWeighbridge IN @lt_uom_weighbridge

         INTO TABLE @lt_result.


     LOOP AT lt_result INTO DATA(wa).

       ls_response-InvoiceDocumentTypeDes = wa-invoicedocumenttypedes.
       ls_response-SalesOrganizationName = wa-SalesOrganizationName.
       ls_response-DistributionChannelName = wa-DistributionChannelName.
       ls_response-SalesDivisionName = wa-salesdivisionname.
       ls_response-SalesOfficeName = wa-SalesOfficeName.
       ls_response-SalesGroupName = wa-SalesGroupName.

       ls_response-SoldToPartyAddress = wa-SoldToPartyAddress.
       ls_response-SoldToPartyState = wa-SoldToPartyState.
       ls_response-SoldToPartyCountry = wa-SoldToPartyCountry.
       ls_response-SoldToPartyPincode = wa-SoldToPartyPincode.
       ls_response-SoldToCustomerCode = wa-SoldToCustomerCode .
       ls_response-SoldToCustomerName = wa-SoldToCustomerName.
       ls_response-SoldToCustomerGSTINNo = wa-SoldToCustomerGSTINNo.
**             ls_response-SoldToCustomerCode = wa-Customer .
*          ENDIF.
*          IF WA-PartnerFunction = 'RE'.
**               READ TABLE IT_BILL_ADDRESS INTO DATA(WA_BILL_ADDRESS) WITH KEY AddressID = WA-AddressID.
**               DATA: bill_to_address TYPE string.
**               CONCATENATE WA_BILL_ADDRESS-HouseNumber WA_BILL_ADDRESS-StreetName WA_BILL_ADDRESS-StreetPrefixName1
**                        WA_BILL_ADDRESS-StreetPrefixName2 WA_BILL_ADDRESS-StreetSuffixName1
**                        WA_BILL_ADDRESS-StreetSuffixName2 WA_BILL_ADDRESS-CityName
**                        INTO bill_to_address.
       ls_response-BillToPartyAddress = wa-BillToPartyAddress.
       ls_response-BillToPartyState = wa-BillToPartyState.
       ls_response-BillToPartyCountry = wa-BillToPartyCountry.
       ls_response-BillToPartyPinCode = wa-BillToPartyPinCode.
       ls_response-BillToPartyCode = wa-BillToPartyCode.
       ls_response-BillToPartyName = wa-BillToPartyName.
**               ls_response-BillToPartyCode = wa-Customer.
*           ENDIF.
*            ls_response-BillToPartyCode = wa-BillToPartyCode.

*               ls_response-SoldToCustomerCode = wa-SoldToCustomerCode .

**               ls_response-SoldToPartyState = wa_sold_state-RegionName.
*                ls_response-SoldToPartyState = WA-soldtopartystate.
*                ls_response-SoldToPartyCountry = WA-SoldToPartyCountry.
*                ls_response-SoldToPartyPincode = WA-SoldToPartyPincode.

       ls_response-StandardCostPerUnit = wa-StandardCostPerUnit.
       ls_response-DeliveryOrderDate = wa-DeliveryOrderDate.
       ls_response-ActualGIDate = wa-ActualGIDate.
       ls_response-ShipToCustomerCode = wa-ShipToCustomerCode.
       ls_response-BillOfLading = wa-BillOfLading.

       ls_response-PONumber = wa-PONumber.
       ls_response-PODate = wa-PODate.
       ls_response-DispatchingPlant = wa-DispatchingPlant.
       ls_response-DispatchingPlantName = wa-DispatchingPlantName.
       ls_response-ReceivingPlant = wa-ReceivingPlant.
*                ls_response-ReceivingPlantName = wa-ReceivingPlantName.
       ls_response-StorageLocation = wa-StorageLocation.
       ls_response-StorageLocationDescription = wa-StorageLocationDescription.
       ls_response-DeliveryQuantity = wa-DeliveryQuantity.
       ls_response-UOMDeliveryQty = wa-UOMDeliveryQty.
       ls_response-Batch  = wa-Batch.
       ls_response-DlvryGrossWeightWithPackaging  = wa-DlvryGrossWeightWithPackaging.
       ls_response-DeliveryNetOilWeight = wa-DeliveryNetOilWeight.
       ls_response-DeliveryWeightUOM = wa-DeliveryWeightUOM.
       ls_response-SalesOrderNo = wa-SalesOrderNo.
       ls_response-SalesOrderDate = wa-SalesOrderDate.
       ls_response-SalesOrder_Type = wa-salesorder_type.
       ls_response-CustomerPONo = wa-CustomerPONo.
       ls_response-CustomerPODate = wa-CustomerPODate.
       ls_response-ContactPersonCode  = wa-ContactPersonCode.
       ls_response-ContactPersonName  = wa-ContactPersonName.
"       ls_response-OrderQuantity  = wa-OrderQuantity.
"       ls_response-ConfirmedQuantity  = wa-ConfirmedQuantity.
"       ls_response-SalesUnit  = wa-SalesUnit.
       ls_response-OrderReason  = wa-OrderReason.
       ls_response-CustomerGroup  = wa-CustomerGroup.
       ls_response-SalesContractNo  = wa-SalesContractNo.
       ls_response-SalesContractDate  = wa-SalesContractDate.
       ls_response-SalesContractValidFromDate  = wa-SalesContractValidFromDate.
       ls_response-SalesContractValidToDate  = wa-SalesContractValidToDate.
       ls_response-SalesContract_Type  = wa-SalesContractType.
       ls_response-businessplace = wa-BusinessPlace.



*                read table order_type_text into data(wa_order_type_text) with key OrderType = wa_dlvry_item-SalesOrderType.
       ls_response-SalesOrderTypeDesc = wa-SalesOrderTypeDesc.

*                read table ord_reason_desc into data(wa_ord_reason_desc) with key SDDocumentReason = wa_dlvry_item-SDDocumentReason.
       ls_response-OrderReasonDescription  = wa-OrderReasonDescription.

*                read table sales_contract_qty into data(wa_sales_contract_qty) with key SalesContract = wa_dlvry_item-refersddoc_so.
*       ls_response-SalesContractQuantity  = wa-SalesContractQuantity.
*       ls_response-SalesContractQuantityUOM  = wa-SalesContractQuantityUOM.

*                read table ship_to_cust_name into data(wa_ship_to_cust_name) with key BusinessPartner = wa-ShipToParty.
       ls_response-ShipToCustomerName = wa-ShipToCustomerName.

*                READ TABLE ship_to_prty_addrs INTO DATA(WA_ship_to_prty_addrs) with key Customer = wa-ShipToParty.
       DATA : Ship_TO_part_address TYPE string.
*                CONCATENATE WA_ship_to_prty_addrs-HouseNumber WA_ship_to_prty_addrs-StreetName WA_ship_to_prty_addrs-StreetPrefixName1
*                            WA_ship_to_prty_addrs-StreetPrefixName2 WA_ship_to_prty_addrs-StreetSuffixName1 WA_ship_to_prty_addrs-StreetSuffixName2
*                            into Ship_TO_part_address.
       ls_response-ShipToPartyAddress = wa-shiptopartyaddress.
       ls_response-ShipToPartyCity = wa-shiptopartyaddress.
       ls_response-ShipToPartyState = wa-shiptopartystate.
       ls_response-ShipToPartyCountry = wa-shiptopartycountry.
       ls_response-ShipToPartyPincode = wa-shiptopartypincode.

*               READ TABLE mat_type_desc into data(wa_mat_type_desc) with key ProductType = wa-ProductType.
       ls_response-MaterialTypeDescription = wa-MaterialTypeDescription.

*            READ TABLE IRN into data(wa_irn) with key billingdocno = wa-BillingDocument plant = wa-Plant.
       ls_response-EwayBillNumber = wa-ewaybillnumber.
       ls_response-IRNAckNumber = wa-irnacknumber.
       ls_response-EwayBillDateTime = wa-ewaybilldatetime.
       ls_response-transportername = wa-transportername.
       ls_response-modeoftransport = wa-modeoftransport.
       ls_response-vehiclenumber = wa-vehiclenumber.

*            read table sales_Dist into data(wa_sales_Dist) with KEY SalesDistrict = wa_dlvry_item-SalesDistrict.
       ls_response-salesdistrict = wa-SalesDistrict.

*             read table gate_entry into data(wa_gate_entry) with key documentno = wa-ReferenceSDDocument.
       ls_response-tokennumber = wa-tokennumber.
       ls_response-tokendatetime = wa-tokendatetime.
       ls_response-gateentrynumber = wa-gateentrynumber.
       ls_response-gateentrydatetime = wa-gateentrydatetime.
       ls_response-lrno = wa-lrno.
       ls_response-lrdate = wa-lrdate.
       ls_response-weighbridgegrossweight = wa-weighbridgegrossweight.
       ls_response-weighbridgetareweight = wa-weighbridgetareweight.
       ls_response-weighbridgenetweight = wa-weighbridgenetweight.
*               ls_response-uomweighbridge = wa_gate_entry-.
       ls_response-gateoutnumber = wa-gateoutnumber.
       ls_response-gateoutdatetime = wa-gateoutdatetime.

*            read table payt_desc into data(wa_payt_desc) with key PaymentTerms = wa-CustomerPaymentTerms.
       ls_response-description = wa-description.

       ls_response-InvoiceNo = wa-BillingDocument.
       ls_response-ItemNo = wa-itemno.
       ls_response-InvoiceType = wa-InvoiceType.
       ls_response-InvoiceDate = wa-InvoiceDate.
       ls_response-ReferenceInvoiceNo = wa-ReferenceInvoiceNo.
       ls_response-RefInvoiceDate = wa-RefInvoiceDate.
       ls_response-AccountingDocNo = wa-AccountingDocNo.
       ls_response-CustomerPONo = wa-CustomerPONo.
       ls_response-SalesOrganization = wa-SalesOrganization.
       ls_response-DistributionChannel = wa-DistributionChannel.
       ls_response-SalesDivision = wa-SalesDivision.
       ls_response-SalesOffice = wa-SalesOffice.
       ls_response-SalesGroup = wa-SalesGroup.
       ls_response-paymenttermcode = wa-paymenttermcode.
       ls_response-againstinvoicedate = wa-againstinvoicedate.
       ls_response-created_by = wa-created_by.
*            ls_response-SoldToCustomerCode = wa-Customer .
*            ls_response-SoldToCustomerName = wa-SoldToCustomerName.
*            ls_response-SoldToCustomerGSTINNo = wa-SoldToCustomerGSTINNo.
*            ls_response-BillToPartyName = wa-BillToPartyName.
*            ls_response-BillToPartyAddress = wa-billtopartyaddress.
       ls_response-ItemCode = wa-Product.
       ls_response-ItemDescription = wa-ItemDescription.
       ls_response-MaterialGroupCode = wa-MaterialGroupCode.
       ls_response-HSNCode = wa-HSNCode.
       ls_response-MaterialTypeCode = wa-MaterialTypeCode.
       ls_response-SalesInvoiceQuantity = wa-SalesInvoiceQuantity.
       ls_response-SalesInvoiceQtyUOM = wa-SalesInvoiceQtyUOM.
       ls_response-SalesInvoiceGrossWeight = wa-SalesInvoiceGrossWeight.
       ls_response-SalesInvoiceNetWeight = wa-SalesInvoiceNetWeight.
       ls_response-SalesInvoiceWeightUOM = wa-SalesInvoiceWeightUOM.
       ls_response-SalesInvoiceTaxableAmount = wa-salesinvoicetaxableamount.
       ls_response-TaxAmount = wa-TaxAmount.
       ls_response-DocumentCurrency = wa-DocumentCurrency.
       ls_response-INCOTerms = wa-INCOTerms.
       ls_response-INCOTermsLocation = wa-INCOTermsLocation.
       ls_response-CancellationInvoiceNumber = wa-CancellationInvoiceNumber.
       ls_response-cancellationindicator = wa-cancellationindicator.
*                IF wa-CancellationInvoiceNumber IS NOT INITIAL.
*                     ls_response-CancellationIndicator = 'X'.
*                ELSE.
*                     CLEAR ls_response-CancellationIndicator.
*                ENDIF.
       ls_response-OutboundDeliveryNumber = wa-OutboundDeliveryNumber.
       ls_response-DeliveryOrderDate = wa-DeliveryOrderDate.
       ls_response-ActualGIDate = wa-ActualGIDate.
       ls_response-ShipToCustomerCode = wa-ShipToCustomerCode.
       ls_response-ShippingPoint = wa-ShippingPoint.
       ls_response-AgainstInvoiceNumber = wa-AgainstInvoiceNumber.


       IF sy-subrc = 0.
         ls_response-SalesEmployeeCode = wa-SalesEmployeeCode.
         ls_response-SalesEmployeeName = wa-SalesEmployeeName.
       ENDIF.

       IF sy-subrc = 0.
         ls_response-BrokerCode = wa-BrokerCode.
         ls_response-BrokerName = wa-BrokerName.
       ENDIF.


*    LOOP AT it_price INTO DATA(wa_condition) WHERE BillingDocument = wa-BillingDocument
*                                                    AND BillingDocumentItem = wa-BillingDocumentItem.
*      CASE wa_condition-ConditionType.
*        wHEN 'ZPR0'.
       ls_response-SalesInvoiceUnitPrice = wa-SalesInvoiceUnitPrice.

*        WHEN 'D100' OR 'ZRAB'.
       ls_response-FreeGoodsDiscount = wa-FreeGoodsDiscount.

*        WHEN 'ZHF1' OR 'ZIF1'.
       ls_response-FreightAmount = wa-FreightAmount.

*        WHEN 'ZHP1'.
       ls_response-PackingAmount = wa-PackingAmount.

*        WHEN 'ZHI1'.
       ls_response-InsuranceAmount = wa-InsuranceAmount.

*        WHEN 'ZBK1'.
       ls_response-BrokerAmount = wa-BrokerAmount.

*        WHEN 'ZCA1'.
       ls_response-CommissionAgentAmount = wa-CommissionAgentAmount.

*        WHEN 'JOCG'.
       ls_response-CGSTAmount = wa-CGSTAmount.
       ls_response-CGSTPercentage = wa-CGSTPercentage.

*        WHEN 'JOSG'.
       ls_response-SGSTAmount = wa-SGSTAmount.
       ls_response-SGSTPercentage = wa-SGSTPercentage.

*        WHEN 'JOIG'.
       ls_response-IGSTAmount = wa-IGSTAmount.
       ls_response-IGSTPercentage = wa-IGSTPercentage.

*        WHEN 'JOUG'.
       ls_response-UGSTAmount = wa-UGSTAmount.
       ls_response-UGSTPercentage = wa-UGSTPercentage.

*        WHEN 'JTC1'.
       ls_response-TCSAmount = wa-TCSAmount.
       ls_response-TCSPercentage = wa-TCSPercentage.
*        WHEN 'DRD1'.
       ls_response-RoundOff = wa-RoundOff.
*      ENDCASE.
*    ENDLOOP.

*            ls_response-InvoiceAmount = wa-salesinvoicetaxableamount + ( ls_response-FreeGoodsDiscount - ls_response-TCSAmount ) - ls_response-RoundOff .
       ls_response-InvoiceAmount = wa-invoiceamount. " + ls_response-RoundOff .


*    ***************************************************************** HIDDEN FIELDS ...
       ls_response-PricingProcedureStep = wa-PricingProcedureStep.
       ls_response-PricingProcedureCounter = wa-PricingProcedureCounter.
       ls_response-Plant = wa-Plant.
       ls_response-Product = wa-product.
       ls_response-SalesOrder = wa-SalesOrder.
       ls_response-SalesOrderType = wa-SalesOrderType.
       ls_response-PartnerFunction = wa-PartnerFunction.
       ls_response-SalesContract = wa-SalesContract.
       ls_response-SalesContractType = wa-SalesContractType.
       ls_response-BillingDocument = wa-billingdocument.
       ls_response-Customer = wa-Customer.


       APPEND ls_response TO lt_response.
       CLEAR: ls_response , wa.
     ENDLOOP.


     SORT lt_response BY InvoiceNo.
     lv_max_rows = lv_skip + lv_top.
     IF lv_skip > 0.
       lv_skip = lv_skip + 1.
     ENDIF.

     CLEAR lt_responseout.
     LOOP AT lt_response ASSIGNING FIELD-SYMBOL(<lfs_out_line_item>) FROM lv_skip TO lv_max_rows.
       ls_responseout = <lfs_out_line_item>.
       APPEND ls_responseout TO lt_responseout.
     ENDLOOP.

     io_response->set_total_number_of_records( lines( lt_response ) ).
     io_response->set_data( lt_responseout ).

   ENDIF.

 ENDMETHOD.


METHOD runjob.

  DATA: amountsign TYPE int2.

  DATA: localinvoiceno TYPE c LENGTH 10.

  DATA: lt_response TYPE TABLE OF zsales_reg_tb,
        ls_response TYPE zsales_reg_tb.


  localinvoiceno = paraminvoiceno.


  IF localinvoiceno = ''.
    DELETE FROM zsales_reg_tb WHERE invoiceno IS NOT INITIAL.

*************************************************
    SELECT FROM i_billingdocument AS a
        LEFT JOIN i_billingdocumentitem AS b ON a~BillingDocument = b~BillingDocument
        LEFT JOIN I_BillingDocumentPartner AS bdp ON bdp~BillingDocument = a~BillingDocument AND bdp~PartnerFunction = 'RE'
        LEFT JOIN I_BusinessPartner AS bp ON bp~BusinessPartner = bdp~Customer
        LEFT JOIN I_Customer AS cu ON cu~Customer = bdp~Customer
        LEFT JOIN I_Address_2 AS ad ON ad~AddressID = cu~AddressID
        LEFT JOIN i_productplantbasic AS ppb ON b~Product = ppb~Product AND ppb~Plant = b~Plant
        LEFT JOIN i_product AS p ON b~Product = p~Product
        LEFT JOIN i_deliverydocument AS dd ON b~ReferenceSDDocument = dd~DeliveryDocument
    FIELDS a~BillingDocument, a~BillingDocumentType, a~BillingDocumentDate, a~DocumentReferenceID, a~AccountingDocument, a~PurchaseOrderByCustomer,
           a~SalesOrganization, a~DistributionChannel, a~Division, a~IncotermsClassification, a~IncotermsLocation1, a~CancelledBillingDocument,
           a~AssignmentReference, a~CustomerPaymentTerms, a~SoldToParty, a~PayerParty, a~CreatedByUser, a~BillingDocumentIsCancelled,
           a~FiscalYear, a~CompanyCode,
           b~BillingDocumentItem, b~SalesGroup, b~SalesOffice, b~Product, b~BillingDocumentItemText, b~ProductGroup, b~BillingQuantityInBaseUnit,
           b~BillingQuantity, b~BillingQuantityUnit, b~ItemGrossWeight, b~ItemNetWeight, b~ItemWeightUnit, b~NetAmount, b~TaxAmount, b~TransactionCurrency,
           b~ReferenceSDDocument, b~Plant AS bill_doc_plant,
           bdp~customer, bdp~PartnerFunction, bdp~BillingDocument AS billDoc_bdp,
           bp~BusinessPartnername,
           cu~taxnumber3, cu~AddressID,
           ppb~ConsumptionTaxCtrlCode,ppb~Product AS PlantProduct, ppb~Plant,
           p~ProductType,
           dd~DeliveryDate, dd~ActualGoodsMovementDate, dd~ShipToParty, dd~ShippingPoint
****          WHERE NOT EXISTS (
****               SELECT BillingDocument FROM zsales_reg_tb
****               WHERE a~BillingDocument = zsales_reg_tb~BillingDocument AND
****                 a~CompanyCode = zsales_reg_tb~plant ) " AND
*                 a~FiscalYear = zsales_reg_tb~ )

*        where a~BillingDocument in @lt_invoice_no
*            AND a~BillingDocumentDate in @lt_Invoice_Date
*            and a~SalesOrganization in @lt_Sales_Org
*            and a~DistributionChannel in @lt_Dist_Channel
*            and p~ProductType in @lt_Mat_Type_Code
*            and b~ProductGroup in @lt_Mat_Grp
*            and bdp~Customer in @lt_Bill_party
*            and a~Division in @lt_Sales_Div
*        where a~BillingDocument = '0090000692'
        INTO TABLE @DATA(it_header)
        PRIVILEGED ACCESS.


    SELECT DISTINCT a~BillingDocument, b~ReferenceSDDocument FROM i_billingdocument AS a
    LEFT JOIN i_billingdocumentitem AS b ON a~BillingDocument = b~BillingDocument
    INTO TABLE @DATA(it_billingheader)
    PRIVILEGED ACCESS.
  ELSE.


    DELETE FROM zsales_reg_tb WHERE invoiceno = @localinvoiceno.

*************************************************
    SELECT FROM i_billingdocument AS a
        LEFT JOIN i_billingdocumentitem AS b ON a~BillingDocument = b~BillingDocument
        LEFT JOIN I_BillingDocumentPartner AS bdp ON bdp~BillingDocument = a~BillingDocument AND bdp~PartnerFunction = 'RE'
        LEFT JOIN I_BusinessPartner AS bp ON bp~BusinessPartner = bdp~Customer
        LEFT JOIN I_Customer AS cu ON cu~Customer = bdp~Customer
        LEFT JOIN I_Address_2 AS ad ON ad~AddressID = cu~AddressID
        LEFT JOIN i_productplantbasic AS ppb ON b~Product = ppb~Product AND ppb~Plant = b~Plant
        LEFT JOIN i_product AS p ON b~Product = p~Product
        LEFT JOIN i_deliverydocument AS dd ON b~ReferenceSDDocument = dd~DeliveryDocument
    FIELDS a~BillingDocument, a~BillingDocumentType, a~BillingDocumentDate, a~DocumentReferenceID, a~AccountingDocument, a~PurchaseOrderByCustomer,
           a~SalesOrganization, a~DistributionChannel, a~Division, a~IncotermsClassification, a~IncotermsLocation1, a~CancelledBillingDocument,
           a~AssignmentReference, a~CustomerPaymentTerms, a~SoldToParty, a~PayerParty, a~CreatedByUser, a~BillingDocumentIsCancelled,
           a~FiscalYear, a~CompanyCode,
           b~BillingDocumentItem, b~SalesGroup, b~SalesOffice, b~Product, b~BillingDocumentItemText, b~ProductGroup, b~BillingQuantityInBaseUnit,
           b~BillingQuantity, b~BillingQuantityUnit, b~ItemGrossWeight, b~ItemNetWeight, b~ItemWeightUnit, b~NetAmount, b~TaxAmount, b~TransactionCurrency,
           b~ReferenceSDDocument, b~Plant AS bill_doc_plant,
           bdp~customer, bdp~PartnerFunction, bdp~BillingDocument AS billDoc_bdp,
           bp~BusinessPartnername,
           cu~taxnumber3, cu~AddressID,
           ppb~ConsumptionTaxCtrlCode,ppb~Product AS PlantProduct, ppb~Plant,
           p~ProductType,
           dd~DeliveryDate, dd~ActualGoodsMovementDate, dd~ShipToParty, dd~ShippingPoint
****          WHERE NOT EXISTS (
****               SELECT BillingDocument FROM zsales_reg_tb
****               WHERE a~BillingDocument = zsales_reg_tb~BillingDocument AND
****                 a~CompanyCode = zsales_reg_tb~plant ) " AND
*                 a~FiscalYear = zsales_reg_tb~ )

          WHERE a~BillingDocument = @localinvoiceno
*            AND a~BillingDocumentDate in @lt_Invoice_Date
*            and a~SalesOrganization in @lt_Sales_Org
*            and a~DistributionChannel in @lt_Dist_Channel
*            and p~ProductType in @lt_Mat_Type_Code
*            and b~ProductGroup in @lt_Mat_Grp
*            and bdp~Customer in @lt_Bill_party
*            and a~Division in @lt_Sales_Div
*        where a~BillingDocument = '0090000692'
        INTO TABLE @it_header
        PRIVILEGED ACCESS.

    SELECT DISTINCT a~BillingDocument, b~ReferenceSDDocument FROM i_billingdocument AS a
    LEFT JOIN i_billingdocumentitem AS b ON a~BillingDocument = b~BillingDocument
    WHERE a~BillingDocument = @localinvoiceno
    INTO TABLE @it_billingheader
    PRIVILEGED ACCESS.

  ENDIF.
***********************************************

*********************************************** DESCRIPTION QUERY'S
  IF it_header IS NOT INITIAL.
********************************************************************************************************************

    " 1. For BillingDocumentType
    SELECT FROM i_billingdocumenttypetext AS t
           INNER JOIN @it_header AS h ON t~BillingDocumentType = h~BillingDocumentType
        FIELDS t~BillingDocumentTypeName, t~BillingDocumentType
        INTO TABLE @DATA(it_billtext)
        PRIVILEGED ACCESS.

    " 2. For SalesOrganization
    SELECT FROM i_salesorganizationtext AS t
           INNER JOIN @it_header AS h ON t~SalesOrganization = h~SalesOrganization
        FIELDS t~SalesOrganizationName, t~SalesOrganization
        INTO TABLE @DATA(it_salestext)
        PRIVILEGED ACCESS.

    " 3. For DistributionChannel
    SELECT FROM i_distributionchanneltext AS t
           INNER JOIN @it_header AS h ON t~DistributionChannel = h~DistributionChannel
        FIELDS t~DistributionChannel, t~DistributionChannelName
        INTO TABLE @DATA(it_distributiontext)
        PRIVILEGED ACCESS.

    " 4. For Division
    SELECT FROM i_divisiontext AS t
           INNER JOIN @it_header AS h ON t~Division = h~Division
        FIELDS t~Division, t~DivisionName
        INTO TABLE @DATA(it_divisiontext)
        PRIVILEGED ACCESS.

    " 5. For SalesOffice
    SELECT FROM i_salesofficetext AS t
           INNER JOIN @it_header AS h ON t~salesoffice = h~SalesOffice
        FIELDS t~SalesOfficeName, t~salesoffice
        INTO TABLE @DATA(it_salesOFCTEXT)
        PRIVILEGED ACCESS.

    " 6. For SalesGroup
    SELECT FROM i_salesgrouptext AS t
           INNER JOIN @it_header AS h ON t~SalesGroup = h~SalesGroup
        FIELDS t~SalesGroup, t~SalesGroupName
        INTO TABLE @DATA(it_salesgrptext)
        PRIVILEGED ACCESS.

    " 7. For Ship-to Customer Name
    SELECT FROM i_businesspartner AS bp
           INNER JOIN @it_header AS h ON bp~BusinessPartner = h~ShipToParty
        FIELDS bp~BusinessPartner, bp~BusinessPartnerFullName
        INTO TABLE @DATA(ship_to_cust_name)
        PRIVILEGED ACCESS.

    " 8. For Ship-to Party Address
    SELECT FROM i_customer AS cust
           INNER JOIN @it_header AS h ON cust~Customer = h~ShipToParty
           LEFT JOIN i_address_2 AS addrs ON cust~AddressID = addrs~AddressID
           LEFT JOIN i_regiontext AS rt ON addrs~Region = rt~Region
           LEFT JOIN i_countrytext AS ct ON addrs~Country = ct~Country
        FIELDS cust~Customer, addrs~AddressID, addrs~HouseNumber, addrs~StreetName,
               addrs~StreetPrefixName1, addrs~StreetPrefixName2,
               addrs~StreetSuffixName1, addrs~StreetSuffixName2, addrs~CityName,
               addrs~PostalCode, rt~RegionName, ct~CountryName
           WHERE addrs~CorrespondenceLanguage = 'E' AND rt~Language = 'E'  AND rt~Country = 'IN'
        INTO TABLE @DATA(ship_to_prty_addrs)
        PRIVILEGED ACCESS.

    " 9. For Standard Cost
    SELECT FROM i_billingdocumentitemprcgelmnt AS cond
           INNER JOIN @it_header AS h ON cond~BillingDocument = h~BillingDocument
           AND cond~BillingDocumentItem = h~BillingDocumentItem
        FIELDS cond~ConditionRateValue, cond~BillingDocument,
               cond~BillingDocumentItem, cond~PricingProcedureStep,
               cond~PricingProcedureCounter
        WHERE cond~ConditionType = 'ZCIP'
        INTO TABLE @DATA(Stnd_Cost_Unit)
        PRIVILEGED ACCESS.

    " 10. For Material Type Description
    SELECT FROM i_producttypetext AS t
           INNER JOIN @it_header AS h ON t~ProductType = h~ProductType
        FIELDS t~ProductType, t~MaterialTypeName
        INTO TABLE @DATA(mat_type_desc)
        PRIVILEGED ACCESS.

    " 11. For Delivery Document
    SELECT FROM i_deliverydocument AS d
           INNER JOIN @it_header AS h ON d~DeliveryDocument = h~ReferenceSDDocument
        FIELDS d~DeliveryDocument, d~DeliveryDate,
               d~ActualGoodsMovementDate, d~ShipToParty, d~BillOfLading
        INTO TABLE @DATA(ship_to_cust)
        PRIVILEGED ACCESS.


    " 12. For Pricing Conditions
    SELECT FROM i_billingdocumentitemprcgelmnt AS cond
           INNER JOIN @it_header AS h ON cond~BillingDocument = h~BillingDocument
           AND cond~BillingDocumentItem = h~BillingDocumentItem
        FIELDS cond~BillingDocument, cond~BillingDocumentItem,
               cond~ConditionType, cond~ConditionAmount,
               cond~ConditionRateValue, cond~TransactionCurrency
        WHERE cond~ConditionType IN ('ZPR0', 'D100', 'ZHF1', 'ZHP1', 'ZHI1',
                                   'ZBK1', 'ZCA1', 'JOCG', 'JOSG', 'JOIG',
                                   'JOUG', 'JTC1', 'ZRAB', 'ZIF1', 'DRD1')
        INTO TABLE @DATA(it_price)
        PRIVILEGED ACCESS.


    SELECT FROM i_billingdocument AS a
            INNER JOIN @it_header AS h ON a~BillingDocument = h~BillingDocument
               LEFT JOIN i_billingdocumentitem AS b ON a~BillingDocument = b~BillingDocument
               LEFT JOIN I_BillingDocumentPartner AS bdp ON bdp~BillingDocument = a~BillingDocument AND bdp~PartnerFunction = 'AG'
               LEFT JOIN I_Customer AS cu ON cu~Customer = bdp~Customer
*            left join I_Address_2 as ad on ad~AddressID = cu~AddressID
        FIELDS  b~BillingDocumentItem, b~SalesGroup, b~SalesOffice, cu~AddressID, bdp~PartnerFunction
           INTO TABLE @DATA(it_address_new)
           PRIVILEGED ACCESS.


    " For SOLD TO ADDRESS
    SELECT FROM I_Address_2 AS addr
       INNER JOIN @it_address_new AS h ON addr~AddressID = h~AddressID
       LEFT JOIN i_regiontext AS rt ON addr~Region = rt~Region
       LEFT JOIN i_countrytext AS ct ON addr~Country = ct~Country
    FIELDS addr~AddressID,
           addr~HouseNumber,
           addr~StreetName,
           addr~StreetPrefixName1,
           addr~StreetPrefixName2,
           addr~StreetSuffixName1,
           addr~StreetSuffixName2,
           addr~cityname,
           addr~Country,
           addr~PostalCode,
           rt~Region,
           rt~RegionName,
           ct~CountryName
    WHERE addr~CorrespondenceLanguage = 'E' AND rt~Language = 'E' AND rt~Country = 'IN'
    INTO TABLE @DATA(it_sold_address_details)
    PRIVILEGED ACCESS.


    SELECT FROM i_billingdocument AS a
            INNER JOIN @it_header AS h ON a~BillingDocument = h~BillingDocument
               LEFT JOIN i_billingdocumentitem AS b ON a~BillingDocument = b~BillingDocument
               LEFT JOIN I_BillingDocumentPartner AS bdp ON bdp~BillingDocument = a~BillingDocument AND bdp~PartnerFunction = 'RE'
               LEFT JOIN I_Customer AS cu ON cu~Customer = bdp~Customer
*            left join I_Address_2 as ad on ad~AddressID = cu~AddressID
        FIELDS  b~BillingDocumentItem, b~SalesGroup, b~SalesOffice, cu~AddressID, bdp~PartnerFunction
           INTO TABLE @it_address_new
           PRIVILEGED ACCESS.

    " BILL TO ADDRESS
    SELECT FROM I_Address_2 AS addr
       INNER JOIN @it_address_new AS h ON addr~AddressID = h~AddressID
       LEFT JOIN i_regiontext AS rt ON addr~Region = rt~Region
       LEFT JOIN i_countrytext AS ct ON addr~Country = ct~Country
    FIELDS addr~AddressID,
           addr~HouseNumber,
           addr~StreetName,
           addr~StreetPrefixName1,
           addr~StreetPrefixName2,
           addr~StreetSuffixName1,
           addr~StreetSuffixName2,
           addr~cityname,
           addr~Country,
           addr~PostalCode,
           rt~Region,
           rt~RegionName,
           ct~CountryName
    WHERE addr~CorrespondenceLanguage = 'E' AND rt~Language = 'E' AND rt~Country = 'IN'
    INTO TABLE @DATA(it_bill_address_details)
    PRIVILEGED ACCESS.


    IF it_sold_address_details IS INITIAL.
      SELECT FROM I_Address_2 AS addr
        INNER JOIN @it_address_new AS h ON addr~AddressID = h~AddressID
        LEFT JOIN i_regiontext AS rt ON addr~Region = rt~Region
        LEFT JOIN i_countrytext AS ct ON addr~Country = ct~Country
        FIELDS addr~AddressID,
             addr~HouseNumber,
             addr~StreetName,
             addr~StreetPrefixName1,
             addr~StreetPrefixName2,
             addr~StreetSuffixName1,
             addr~StreetSuffixName2,
             addr~cityname,
             addr~Country,
             addr~PostalCode,
             rt~Region,
             rt~RegionName,
             ct~CountryName
        WHERE addr~CorrespondenceLanguage = 'E' AND rt~Language = 'E' AND rt~Country = 'IN'
        INTO TABLE @it_sold_address_details
        PRIVILEGED ACCESS.
    ENDIF.

    " Split the results if you need separate tables
    DATA(it_sold_address) = it_sold_address_details.
    DATA(it_bill_address) = it_bill_address_details.


    " For Delivery Item details
    SELECT FROM i_deliverydocumentitem AS ddi
       INNER JOIN @it_billingheader AS h ON ddi~DeliveryDocument = h~ReferenceSDDocument
       LEFT JOIN i_purchaseorderchangedocument AS pocd ON ddi~ReferenceSDDocument = pocd~PurchaseOrder
       LEFT JOIN i_plant AS pl ON ddi~Plant = pl~Plant
       LEFT JOIN i_storagelocation AS sl ON ddi~StorageLocation = sl~StorageLocation AND ddi~Plant = sl~Plant
       LEFT JOIN i_salesorder AS so ON ddi~ReferenceSDDocument = so~SalesOrder
       LEFT JOIN I_SalesDocument AS sd ON ddi~ReferenceSDDocument = sd~SalesDocument
       LEFT JOIN i_salesorderpartner AS sopAP ON ddi~ReferenceSDDocument = sopAP~SalesOrder
                                          AND sopAP~PartnerFunction = 'AP'
       LEFT JOIN i_salesorderpartner AS sopZE ON ddi~ReferenceSDDocument = sopZE~SalesOrder
                                          AND sopZE~PartnerFunction = 'ZE'
       LEFT JOIN i_salesorderpartner AS sopES ON ddi~ReferenceSDDocument = sopES~SalesOrder
                                          AND sopES~PartnerFunction = 'ES'
       LEFT JOIN i_customer AS custZE ON sopZE~Customer = custZE~Customer
"       LEFT JOIN i_salesorderitem AS soi ON ddi~ReferenceSDDocument = soi~SalesOrder AND ddi~DeliveryDocumentItem = soi~SalesOrderItem
       LEFT JOIN i_salescontract AS sc ON sd~ReferenceSDDocument = sc~SalesContract
    FIELDS ddi~DeliveryDocument,
           ddi~DeliveryDocumentItem,
           ddi~ReferenceSDDocument,
           pocd~CreationDate,
           ddi~Plant,
           ddi~IssuingOrReceivingPlant,
           ddi~StorageLocation,
           sl~StorageLocationName,
           ddi~ActualDeliveryQuantity,
           ddi~DeliveryQuantityUnit,
           ddi~Batch,
           ddi~ItemGrossWeight,
           ddi~ItemNetWeight,
           ddi~ItemWeightUnit,
           pl~PlantName,
           pl~BusinessPlace,
           so~SalesOrderDate,
           so~SalesOrderType,
           so~PurchaseOrderByCustomer,
           so~CustomerPurchaseOrderDate,
*           so~SDDocumentReason,
           so~CustomerGroup,
           so~SalesOrder,
           so~ReferenceSDDocument AS ReferSDDoc_SO,
           so~SalesOffice,
           so~SalesGroup,
           sopAP~ContactPerson AS contactpersoncode,
           sopAP~FullName AS contactpersonname,
           sopES~Supplier AS brokercode,
           sopES~FullName AS brokername,
           sopZE~customer AS salesemployeecode,
           custZE~CustomerName AS salesemployeename,
"           soi~OrderQuantity,
"           soi~ConfdDelivQtyInOrderQtyUnit,
"           soi~OrderQuantityUnit,
"           soi~SalesOrderItem,
           sc~SalesContractDate,
           sc~SalesContractValidityStartDate,
           sc~SalesContractValidityEndDate,
           sc~SalesContractType,
           sc~SalesContract,
           sd~SDDocumentReason,
           sd~SalesDistrict,
           sd~SalesDocumentType
    WHERE ddi~Material <> '' AND ddi~ActualDeliveryQuantity <> 0
    INTO TABLE @DATA(dlvry_item)
    PRIVILEGED ACCESS.

    " FOR SALES DISTRICT
    SELECT FROM I_SalesDistrictText AS a
        INNER JOIN @dlvry_item AS b ON a~SalesDistrict = b~SalesDistrict
            FIELDS a~SalesDistrictName, a~SalesDistrict
                INTO TABLE @DATA(sales_Dist) PRIVILEGED ACCESS.

    " For Order Type Text
    SELECT FROM i_ordertypetext AS t
           INNER JOIN @dlvry_item AS d ON t~OrderType = d~SalesOrderType
        FIELDS t~OrderType,
               t~OrderTypeName
        INTO TABLE @DATA(order_type_text)
        PRIVILEGED ACCESS.

    " For Document Reason Text
    SELECT FROM i_sddocumentreasontext AS t
           INNER JOIN @dlvry_item AS d ON t~SDDocumentReason = d~SDDocumentReason
        FIELDS t~SDDocumentReason,
               t~SDDocumentReasonText
        INTO TABLE @DATA(ord_reason_desc)
        PRIVILEGED ACCESS.

    " For Sales Contract Item
*    SELECT FROM i_SALESCONTRACTITEM AS t
*           INNER JOIN @dlvry_item AS d ON t~SalesContract = d~refersddoc_so
*        FIELDS t~SalesContract,
*               t~SalesContractItem,
*               t~TargetQuantity,
*               t~TargetQuantityUnit
*        INTO TABLE @DATA(sales_contract_qty)
*        PRIVILEGED ACCESS.

    " FOR IRN FIELDS
    SELECT FROM ztable_irn AS ti
            INNER JOIN @it_header AS hdr ON ti~billingdocno = hdr~BillingDocument
          FIELDS ti~ewaybillno, ti~ackno, ti~ewaydate, ti~billingdocno, ti~transportername, ti~transportmode, ti~vehiclenum
            INTO TABLE @DATA(irn)
                PRIVILEGED ACCESS.

    " Payment Terms Description
    SELECT FROM i_paymenttermstext AS a
            INNER JOIN @it_header AS hdr ON a~PaymentTerms = hdr~CustomerPaymentTerms
           FIELDS a~PaymentTermsDescription, a~PaymentTerms
            INTO TABLE @DATA(payt_desc) PRIVILEGED ACCESS.

    " GATE ENTRY
    SELECT FROM zgateentrylines AS a
            INNER JOIN @it_header AS hdr ON a~documentno = hdr~ReferenceSDDocument
            LEFT JOIN zgateentryheader AS ge ON ge~gateentryno = a~gateentryno
         FIELDS ge~gateentryno, ge~vehrepdate, ge~vehreptime, ge~gateindate, ge~gateintime, ge~lrno, ge~lrdate, ge~grosswt, ge~tarewt, ge~netwt,
                ge~gateoutdate, ge~gateouttime,
                a~documentno
             INTO TABLE @DATA(gate_entry).

    " BUSINESS PLACE LOGIC
    SELECT FROM i_operationalacctgdociteM AS a
           INNER JOIN @it_header AS hdr ON a~BillingDocument = hdr~BillingDocument AND a~CompanyCode = hdr~CompanyCode AND a~FiscalYear = hdr~FiscalYear
        FIELDS a~BusinessPlace, a~BillingDocument, a~CompanyCode, a~FiscalYear
           INTO TABLE @DATA(it_bp).

  ENDIF.


********************************************************** LOOP's
  LOOP AT it_header INTO DATA(wa).

* Delete already processed sales line
*      DELETE FROM zsales_reg_tb
*        WHERE zsales_reg_tb~plant = @wa-Plant AND
**        zsales_reg_tb~fiscalyearvalue = @wa-FiscalYear AND
*        zsales_reg_tb~invoiceno = @wa-BillingDocument.

    IF wa-BillingDocumentType = 'F2' OR wa-BillingDocumentType = 'JSTO' OR wa-BillingDocumentType = 'L2' or wa-BillingDocumentType = 'S2'.
      amountsign = 1.
    ELSE.
      amountsign = -1.
    ENDIF.


    READ TABLE it_billtext INTO DATA(wa_billtext) WITH KEY BillingDocumentType = wa-BillingDocumentType.
    ls_response-InvoiceDocumentTypeDes = wa_billtext-BillingDocumentTypeName.

    READ TABLE it_salestext INTO DATA(wa_salestext) WITH KEY SalesOrganization = wa-SalesOrganization.
    ls_response-SalesOrganizationName = wa_salestext-SalesOrganizationName.

    READ TABLE it_distributiontext INTO DATA(wa_distributiontext) WITH KEY DistributionChannel = wa-DistributionChannel.
    ls_response-DistributionChannelName = wa_distributiontext-DistributionChannelName.

    READ TABLE it_divisiontext INTO DATA(wa_divisiontext) WITH KEY Division = wa-Division.
    ls_response-SalesDivisionName = wa_divisiontext-DivisionName.

    IF wa-SalesOffice IS NOT INITIAL.
      READ TABLE it_salesOFCTEXT INTO DATA(WA_salesOFCTEXT) WITH KEY salesoffice = wa-SalesOffice.
      ls_response-SalesOfficeName = WA_salesOFCTEXT-SalesOfficeName.
    ENDIF.

    IF wa-SalesGroup IS NOT INITIAL.
      READ TABLE it_salesgrptext INTO DATA(wa_salesgrptext) WITH KEY SalesGroup = wa-SalesGroup.
      ls_response-SalesGroupName = wa_salesgrptext-SalesGroupName.
    ENDIF.

*   IF WA-PartnerFunction = 'AG'.
    READ TABLE it_sold_address INTO DATA(wa_sold_address) WITH KEY AddressID = wa-AddressID.
    DATA : SOLD_TO_address TYPE string.
    CONCATENATE wa_sold_address-HouseNumber wa_sold_address-StreetName wa_sold_address-StreetPrefixName1 wa_sold_address-StreetPrefixName2
                wa_sold_address-StreetSuffixName1 wa_sold_address-StreetSuffixName2 wa_sold_address-CityName
                    INTO sold_to_address.
    ls_response-SoldToPartyAddress = sold_to_address.
    ls_response-SoldToPartyState = wa_sold_address-RegionName.
    ls_response-SoldToPartyCountry = wa_sold_address-CountryName.
    ls_response-SoldToPartyPincode = wa_sold_address-PostalCode.
    ls_response-SoldToCustomerCode = wa-SoldToParty .
    ls_response-SoldToCustomerName = wa-BusinessPartnerName.
    ls_response-SoldToCustomerGSTINNo = wa-taxnumber3.
*          ENDIF.
*          IF WA-PartnerFunction = 'RE'.
    READ TABLE it_bill_address INTO DATA(wa_bill_address) WITH KEY AddressID = wa-AddressID.
    DATA: bill_to_address TYPE string.
    CONCATENATE wa_bill_address-HouseNumber wa_bill_address-StreetName wa_bill_address-StreetPrefixName1
             wa_bill_address-StreetPrefixName2 wa_bill_address-StreetSuffixName1
             wa_bill_address-StreetSuffixName2 wa_bill_address-CityName
             INTO bill_to_address.
    ls_response-BillToPartyAddress = bill_to_address.
    ls_response-BillToPartyState = wa_bill_address-RegionName.
    ls_response-BillToPartyCountry = wa_bill_address-CountryName.
    ls_response-BillToPartyPinCode = wa_bill_address-PostalCode.
    ls_response-BillToPartyCode = wa-PayerParty.
    ls_response-BillToPartyName = wa-BusinessPartnerName.

    READ TABLE Stnd_Cost_Unit INTO DATA(wa_Stnd_Cost_Unit) WITH KEY BillingDocument = wa-BillingDocument BillingDocumentItem = wa-BillingDocumentItem.
    ls_response-StandardCostPerUnit = wa_stnd_cost_unit-ConditionRateValue.

    READ TABLE ship_to_cust INTO DATA(wa_ship_to_cust) WITH KEY DeliveryDocument = wa-ReferenceSDDocument.
    ls_response-DeliveryOrderDate = wa_ship_to_cust-DeliveryDate.
    ls_response-ActualGIDate = wa_ship_to_cust-ActualGoodsMovementDate.
    ls_response-ShipToCustomerCode = wa_ship_to_cust-ShipToParty.
    ls_response-BillOfLading = wa_ship_to_cust-BillOfLading.

    READ TABLE dlvry_item INTO DATA(wa_dlvry_item) WITH KEY DeliveryDocument = wa-ReferenceSDDocument.
    ls_response-PONumber = wa_dlvry_item-ReferenceSDDocument.
    ls_response-PODate = wa_dlvry_item-CreationDate.
    ls_response-DispatchingPlant = wa_dlvry_item-Plant.
    ls_response-DispatchingPlantName = wa_dlvry_item-PlantName.
    ls_response-ReceivingPlant = wa_dlvry_item-IssuingOrReceivingPlant.
*                ls_response-ReceivingPlantName = wa_dlvry_item-PlantName.
    ls_response-StorageLocation = wa_dlvry_item-StorageLocation.
    ls_response-StorageLocationDescription = wa_dlvry_item-StorageLocationName.
    ls_response-DeliveryQuantity = wa_dlvry_item-ActualDeliveryQuantity.
    ls_response-UOMDeliveryQty = wa_dlvry_item-DeliveryQuantityUnit.
    ls_response-Batch  = wa_dlvry_item-Batch.
    ls_response-DlvryGrossWeightWithPackaging  = wa_dlvry_item-ItemGrossWeight.
    ls_response-DeliveryNetOilWeight = wa_dlvry_item-ItemNetWeight.
    ls_response-DeliveryWeightUOM = wa_dlvry_item-ItemWeightUnit.
    ls_response-SalesOrderNo = wa_dlvry_item-ReferenceSDDocument.
    ls_response-SalesOrderDate = wa_dlvry_item-SalesOrderDate.
    ls_response-SalesOrder_Type =  wa_dlvry_item-SalesDocumentType.   "  wa_dlvry_item-SalesOrderType.


    " If SalesOrderType is INITIAL, fetch from BillingDocumentItem
    IF ls_response-SalesOrder_Type IS INITIAL.
      SELECT SINGLE SalesDocumentType
        FROM I_SalesDocument
        WHERE SalesDocument = @wa-ReferenceSDDocument
        INTO @ls_response-SalesOrder_Type.
    ENDIF.



    ls_response-CustomerPONo = wa_dlvry_item-PurchaseOrderByCustomer.
    ls_response-CustomerPODate = wa_dlvry_item-CustomerPurchaseOrderDate.
    ls_response-ContactPersonCode  = wa_dlvry_item-contactpersoncode.
    ls_response-ContactPersonName  = wa_dlvry_item-contactpersonname.
    ls_response-SalesEmployeeCode = wa_dlvry_item-salesemployeecode.
    ls_response-SalesEmployeeName = wa_dlvry_item-salesemployeename.
    ls_response-BrokerCode = wa_dlvry_item-brokercode.
    ls_response-BrokerName = wa_dlvry_item-brokername.

    "    ls_response-OrderQuantity  = wa_dlvry_item-OrderQuantity.
    "    ls_response-ConfirmedQuantity  = wa_dlvry_item-ConfdDelivQtyInOrderQtyUnit.
    "    ls_response-SalesUnit  = wa_dlvry_item-OrderQuantityUnit.
    ls_response-OrderReason  = wa_dlvry_item-SDDocumentReason.
    ls_response-CustomerGroup  = wa_dlvry_item-CustomerGroup.
    ls_response-SalesContractNo  = wa_dlvry_item-ReferSDDoc_SO.
    ls_response-SalesContractDate  = wa_dlvry_item-SalesContractDate.
    ls_response-SalesContractValidFromDate  = wa_dlvry_item-SalesContractValidityStartDate.
    ls_response-SalesContractValidToDate  = wa_dlvry_item-SalesContractValidityEndDate.
    ls_response-SalesContract_Type  = wa_dlvry_item-SalesContractType.
*    ls_response-businessplace = wa_dlvry_item-BusinessPlace.



    READ TABLE order_type_text INTO DATA(wa_order_type_text) WITH KEY OrderType = wa_dlvry_item-SalesOrderType.
    ls_response-SalesOrderTypeDesc = wa_order_type_text-OrderTypeName.

    READ TABLE ord_reason_desc INTO DATA(wa_ord_reason_desc) WITH KEY SDDocumentReason = wa_dlvry_item-SDDocumentReason.
    ls_response-OrderReasonDescription  = wa_ord_reason_desc-SDDocumentReasonText.

*    READ TABLE sales_contract_qty INTO DATA(wa_sales_contract_qty) WITH KEY SalesContract = wa_dlvry_item-refersddoc_so.
**    ls_response-SalesContractQuantity  = wa_sales_contract_qty-TargetQuantity.
*    ls_response-SalesContractQuantityUOM  = wa_sales_contract_qty-TargetQuantityUnit.

    READ TABLE ship_to_cust_name INTO DATA(wa_ship_to_cust_name) WITH KEY BusinessPartner = wa-ShipToParty.
    ls_response-ShipToCustomerName = wa_ship_to_cust_name-BusinessPartnerFullName.

    READ TABLE ship_to_prty_addrs INTO DATA(WA_ship_to_prty_addrs) WITH KEY Customer = wa-ShipToParty.
    DATA : Ship_TO_part_address TYPE string.
    CONCATENATE WA_ship_to_prty_addrs-HouseNumber WA_ship_to_prty_addrs-StreetName WA_ship_to_prty_addrs-StreetPrefixName1
                WA_ship_to_prty_addrs-StreetPrefixName2 WA_ship_to_prty_addrs-StreetSuffixName1 WA_ship_to_prty_addrs-StreetSuffixName2
                INTO Ship_TO_part_address.
    ls_response-ShipToPartyAddress = Ship_TO_part_address.
    ls_response-ShipToPartyCity = WA_ship_to_prty_addrs-CityName.
    ls_response-ShipToPartyState = WA_ship_to_prty_addrs-RegionName.
    ls_response-ShipToPartyCountry = WA_ship_to_prty_addrs-CountryName.
    ls_response-ShipToPartyPincode = WA_ship_to_prty_addrs-PostalCode.

    READ TABLE mat_type_desc INTO DATA(wa_mat_type_desc) WITH KEY ProductType = wa-ProductType.
    ls_response-MaterialTypeDescription = wa_mat_type_desc-MaterialTypeName.

    READ TABLE irn INTO DATA(wa_irn) WITH KEY billingdocno = wa-BillingDocument.
    ls_response-EwayBillNumber = wa_irn-ewaybillno.
    ls_response-IRNAckNumber = wa_irn-ackno.
    ls_response-EwayBillDateTime = wa_irn-ewaydate.
    ls_response-transportername = wa_irn-transportername.
    ls_response-modeoftransport = wa_irn-transportmode.
    ls_response-vehiclenumber = wa_irn-vehiclenum.

    READ TABLE gate_entry INTO DATA(wa_gate_entry) WITH KEY documentno = wa-ReferenceSDDocument.
    ls_response-tokennumber = wa_gate_entry-gateentryno.
    ls_response-tokendatetime = |{ wa_gate_entry-gateindate DATE = ISO } { wa_gate_entry-gateintime TIME = ISO }|.
    ls_response-gateentrynumber = wa_gate_entry-gateentryno.
    ls_response-gateentrydatetime = |{ wa_gate_entry-gateindate DATE = ISO } { wa_gate_entry-gateintime TIME = ISO }|.
    ls_response-lrno = wa_gate_entry-lrno.
    ls_response-lrdate = wa_gate_entry-lrdate.
    ls_response-weighbridgegrossweight = wa_gate_entry-grosswt.
    ls_response-weighbridgetareweight = wa_gate_entry-tarewt.
    ls_response-weighbridgenetweight = wa_gate_entry-netwt.
*               ls_response-uomweighbridge = wa_gate_entry-.
    ls_response-gateoutnumber = wa_gate_entry-gateentryno.
    ls_response-gateoutdatetime = |{ wa_gate_entry-gateoutdate DATE = ISO } { wa_gate_entry-gateouttime TIME = ISO }|.


    READ TABLE sales_Dist INTO DATA(wa_sales_Dist) WITH KEY SalesDistrict = wa_dlvry_item-SalesDistrict.
    ls_response-salesdistrict = wa_sales_dist-SalesDistrictName.

    READ TABLE payt_desc INTO DATA(wa_payt_desc) WITH KEY PaymentTerms = wa-CustomerPaymentTerms.
    ls_response-description = wa_payt_desc-PaymentTermsDescription.

*               DATA: lv_timestamp TYPE string.  " or same type as wa_irn-ewaydate
*   DATA:   lv_datetime  TYPE string.
*   DATA:   lv_date      TYPE string.
*   DATA:   lv_time      TYPE string.
*
*lv_timestamp = wa_irn-ewaydate.
*
*" Extract date and time parts
*lv_date = lv_timestamp(8).       " YYYYMMDD
*lv_time = lv_timestamp+8(6).     " hhmmss
*
*" Format to DD-MM-YYYY hh:mm:ss
*lv_datetime = |{ lv_date+6(2) }-{ lv_date+4(2) }-{ lv_date+0(4) } { lv_time+0(2) }:{ lv_time+2(2) }:{ lv_time+4(2) }|.
*
*ls_response-EwayBillDateTime = lv_datetime.

***********************************************************  SALES GROUP & ORDER
    SELECT single FROM i_billingdocument AS a
        LEFT JOIN i_billingdocumentitem  AS b ON a~BillingDocument = b~BillingDocument
        LEFT JOIN i_deliverydocumentitem  AS c on b~ReferenceSDDocument = c~DeliveryDocument and b~ReferenceSDDocumentItem = c~DeliveryDocumentItem
        LEFT JOIN i_salesorderitem       AS d ON c~ReferenceSDDocument = d~SalesOrder and c~ReferenceSDDocumentItem = d~SalesOrderItem
        left join i_salescontract        as e on d~ReferenceSDDocument = e~SalesContract
     fields e~SalesOffice, e~SalesGroup
        where a~BillingDocument = @wa-BillingDocument
        into @data(sales_data).

  if sales_data is not INITIAL.
    ls_response-SalesOffice = sales_data-SalesOffice.
    ls_response-SalesGroup = sales_data-SalesGroup.
  else.
    ls_response-SalesOffice = wa_dlvry_item-SalesOffice.      " wa-SalesOffice.
    ls_response-SalesGroup = wa_dlvry_item-SalesGroup.       " wa-SalesGroup.
  ENDIF.


    ls_response-InvoiceNo = wa-BillingDocument.
    ls_response-ItemNo = wa-BillingDocumentItem.
    ls_response-InvoiceType = wa-BillingDocumentType.
    ls_response-InvoiceDate = wa-BillingDocumentDate.
    ls_response-ReferenceInvoiceNo = wa-DocumentReferenceID.
    ls_response-RefInvoiceDate = wa-BillingDocumentDate.
    ls_response-AccountingDocNo = wa-AccountingDocument.
    ls_response-CustomerPONo = wa-PurchaseOrderByCustomer.
    ls_response-SalesOrganization = wa-SalesOrganization.
    ls_response-DistributionChannel = wa-DistributionChannel.
    ls_response-SalesDivision = wa-Division.
    ls_response-paymenttermcode = wa-CustomerPaymentTerms.
    ls_response-againstinvoicedate = wa-BillingDocumentDate.
    ls_response-created_by = wa-CreatedByUser.
*            ls_response-SoldToCustomerCode = wa-Customer .
*            ls_response-SoldToCustomerName = wa-BusinessPartnerName.
*            ls_response-SoldToCustomerGSTINNo = wa-taxnumber3.
*            ls_response-BillToPartyName = wa-BusinessPartnerName.
*            ls_response-BillToPartyAddress = sold_to_address.
    ls_response-ItemCode = wa-Product.
    ls_response-ItemDescription = wa-BillingDocumentItemText.
    ls_response-MaterialGroupCode = wa-ProductGroup.
    ls_response-HSNCode = wa-ConsumptionTaxCtrlCode.
    ls_response-MaterialTypeCode = wa-ProductType.
    ls_response-SalesInvoiceQuantity = wa-BillingQuantity.
    ls_response-SalesInvoiceQtyUOM = wa-BillingQuantityUnit.
    ls_response-SalesInvoiceGrossWeight = wa-ItemGrossWeight.
    ls_response-SalesInvoiceNetWeight = wa-ItemNetWeight.
    ls_response-SalesInvoiceWeightUOM = wa-ItemWeightUnit.
    ls_response-SalesInvoiceTaxableAmount = wa-NetAmount.
    ls_response-TaxAmount = wa-TaxAmount.
    ls_response-DocumentCurrency = wa-TransactionCurrency.
    ls_response-INCOTerms = wa-IncotermsClassification.
    ls_response-INCOTermsLocation = wa-IncotermsLocation1.
    ls_response-CancellationInvoiceNumber = wa-CancelledBillingDocument.
    ls_response-cancellationindicator = wa-BillingDocumentIsCancelled.
*                IF wa-CancelledBillingDocument IS NOT INITIAL.
*                     ls_response-CancellationIndicator = 'X'.
*                ELSE.
*                     CLEAR ls_response-CancellationIndicator.
*                ENDIF.
    ls_response-OutboundDeliveryNumber = wa-ReferenceSDDocument.
    ls_response-DeliveryOrderDate = wa-DeliveryDate.
    ls_response-ActualGIDate = wa-ActualGoodsMovementDate.
    ls_response-ShipToCustomerCode = wa-ShipToParty.
    ls_response-ShippingPoint = wa-ShippingPoint.
    ls_response-AgainstInvoiceNumber = wa-AssignmentReference.


    READ TABLE it_bp INTO DATA(wa_bp) WITH KEY BillingDocument = wa-BillingDocument CompanyCode = wa-CompanyCode FiscalYear = wa-FiscalYear.
    ls_response-businessplace = wa_dlvry_item-Plant.       " WA_BP-BusinessPlace.


    LOOP AT it_price INTO DATA(wa_condition) WHERE BillingDocument = wa-BillingDocument
                                                    AND BillingDocumentItem = wa-BillingDocumentItem.
      CASE wa_condition-ConditionType.
        WHEN 'ZPR0'.
          ls_response-SalesInvoiceUnitPrice = wa_condition-ConditionRateValue.

        WHEN 'D100' OR 'ZRAB'.
          ls_response-FreeGoodsDiscount = wa_condition-ConditionAmount.

        WHEN 'ZHF1' OR 'ZIF1'.
          ls_response-FreightAmount = wa_condition-ConditionAmount.

        WHEN 'ZHP1'.
          ls_response-PackingAmount = wa_condition-ConditionAmount.

        WHEN 'ZHI1'.
          ls_response-InsuranceAmount = wa_condition-ConditionAmount.

        WHEN 'ZBK1'.
          ls_response-BrokerAmount = wa_condition-ConditionAmount.

        WHEN 'ZCA1'.
          ls_response-CommissionAgentAmount = wa_condition-ConditionAmount.

        WHEN 'JOCG'.
          ls_response-CGSTAmount = wa_condition-ConditionAmount.
          ls_response-CGSTPercentage = wa_condition-ConditionRateValue.

        WHEN 'JOSG'.
          ls_response-SGSTAmount = wa_condition-ConditionAmount.
          ls_response-SGSTPercentage = wa_condition-ConditionRateValue.

        WHEN 'JOIG'.
          ls_response-IGSTAmount = wa_condition-ConditionAmount.
          ls_response-IGSTPercentage = wa_condition-ConditionRateValue.

        WHEN 'JOUG'.
          ls_response-UGSTAmount = wa_condition-ConditionAmount.
          ls_response-UGSTPercentage = wa_condition-ConditionRateValue.

        WHEN 'JTC1'.
          ls_response-TCSAmount = wa_condition-ConditionAmount.
          ls_response-TCSPercentage = wa_condition-ConditionRateValue.
        WHEN 'DRD1'.
          ls_response-RoundOff = wa_condition-ConditionAmount.
      ENDCASE.
    ENDLOOP.



*            ls_response-InvoiceAmount = wa-NetAmount + ( ls_response-FreeGoodsDiscount - ls_response-TCSAmount ) - ls_response-RoundOff .
    ls_response-InvoiceAmount = wa-NetAmount + ls_response-TaxAmount.   " + ls_response-RoundOff .


************************************************************************* HIDDEN FIELDS ...
    ls_response-PricingProcedureStep = wa_stnd_cost_unit-PricingProcedureStep.
    ls_response-PricingProcedureCounter = wa_stnd_cost_unit-PricingProcedureCounter.
    ls_response-Plant = wa-Plant.
    ls_response-Product = wa-plantproduct.
    ls_response-SalesOrder = wa_dlvry_item-SalesOrder.
    ls_response-SalesOrderType = wa_dlvry_item-SalesOrderType.
*            ls_response-PartnerFunction = wa-PartnerFunction.
    ls_response-SalesContract = wa_dlvry_item-SalesContract.
    ls_response-SalesContractType = wa_dlvry_item-SalesContractType.
    ls_response-BillingDocument = wa-billdoc_bdp.
    ls_response-Customer = WA_ship_to_prty_addrs-Customer.


******************************************* Negative Fields
    ls_response-FreeGoodsDiscount = amountsign * ls_response-FreeGoodsDiscount.
    ls_response-FreightAmount = amountsign * ls_response-FreightAmount.
    ls_response-PackingAmount = amountsign * ls_response-PackingAmount.
    ls_response-InsuranceAmount = amountsign * ls_response-insuranceamount .
    ls_response-BrokerAmount = amountsign * ls_response-brokeramount.
    ls_response-CommissionAgentAmount = amountsign * ls_response-commissionagentamount.
    ls_response-CGSTAmount = amountsign * ls_response-cgstamount.
    ls_response-SGSTAmount = amountsign * ls_response-sgstamount.
    ls_response-IGSTAmount = amountsign * ls_response-igstamount.
    ls_response-UGSTAmount = amountsign * ls_response-ugstamount.
    ls_response-TCSAmount = amountsign * ls_response-tcsamount.
    ls_response-RoundOff = amountsign * ls_response-roundoff.
    ls_response-SalesInvoiceTaxableAmount = amountsign * ls_response-salesinvoicetaxableamount.
    ls_response-TaxAmount = amountsign * ls_response-taxamount.
    ls_response-SalesInvoiceGrossWeight = amountsign * ls_response-salesinvoicegrossweight.
    ls_response-SalesInvoiceNetWeight = amountsign * ls_response-salesinvoicenetweight.
    ls_response-SalesInvoiceQuantity = amountsign * ls_response-salesinvoicequantity.
    ls_response-InvoiceAmount = amountsign * ls_response-InvoiceAmount.
    ls_response-deliverynetoilweight = amountsign * ls_response-deliverynetoilweight.
    ls_response-DlvryGrossWeightWithPackaging = amountsign * ls_response-DlvryGrossWeightWithPackaging.
    ls_response-weighbridgegrossweight = amountsign * ls_response-weighbridgegrossweight.
    ls_response-weighbridgetareweight = amountsign * ls_response-weighbridgetareweight.
    ls_response-weighbridgenetweight = amountsign * ls_response-weighbridgenetweight.
    ls_response-deliveryquantity = amountsign * ls_response-deliveryquantity.


******************************************** CONDITION
    if wa-BillingDocumentType = 'JSTO'.
          ls_response-CGSTAmount = 0.
          ls_response-CGSTPercentage = 0.
          ls_response-SGSTAmount = 0.
          ls_response-SGSTPercentage = 0.
    endif.



    APPEND ls_response TO lt_response.
    MODIFY zsales_reg_tb FROM @ls_response.
    CLEAR ls_response.
    CLEAR: wa_billtext, wa_salestext, wa_distributiontext, wa_divisiontext, WA_salesOFCTEXT, wa_salesgrptext,
        wa_sold_address, wa_bill_address, wa_Stnd_Cost_Unit, wa_ship_to_cust, wa_dlvry_item, wa_order_type_text, wa_ord_reason_desc,
        wa_ship_to_cust_name, WA_ship_to_prty_addrs, wa_mat_type_desc, sales_data,      "   wa_sales_contract_qty,
        wa_irn, wa_gate_entry, wa_sales_Dist, wa_payt_desc.


  ENDLOOP.

*   INSERT zsales_reg_tb FROM TABLE @lt_response.
  CLEAR: lt_response.

ENDMETHOD.
ENDCLASS.
