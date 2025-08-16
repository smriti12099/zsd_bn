CLASS zsales_contract_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider. " use for rap report
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZSALES_CONTRACT_CLASS IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF zsales_contract_cds,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.


      DATA(lv_top)           = io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)          = io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0
                                  ELSE lv_top ).

      TRY.
          DATA(lt_clause)        = io_request->get_filter( )->get_as_ranges( ).
        CATCH  cx_rap_query_filter_no_range INTO DATA(lv_cx_rap_query_filter).
          DATA(lv_catch)  = '1'.
      ENDTRY.

      DATA(lt_parameter)     = io_request->get_parameters( ).
      DATA(lt_fields)        = io_request->get_requested_elements( ).
      DATA(lt_sort)          = io_request->get_sort_elements( ).

      TRY.
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
          lv_catch = '1'.
      ENDTRY.

      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).

        IF ls_filter_cond-name = 'PLANT'.
          DATA(lt_Plant) = ls_filter_cond-range[].
        ENDIF.

        IF ls_filter_cond-name = 'EQUIPMENT'.
          DATA(lt_Equipment) = ls_filter_cond-range[].
        ENDIF.

        IF ls_filter_cond-name = 'PURCHASEORDERBYCUSTOMER'.
          DATA(it_PURCHASEORDERBYCUSTOMER) = ls_filter_cond-range[].
        ENDIF.

        IF ls_filter_cond-name = 'SALESCONTRACT'.
          DATA(it_SALESCONTRACT) = ls_filter_cond-range[].
        ENDIF.

      ENDLOOP.

      SELECT
       FROM i_salescontract  WITH PRIVILEGED ACCESS AS a
       INNER JOIN i_salescontractitem WITH PRIVILEGED ACCESS AS c ON a~salescontract = c~salescontract
       LEFT JOIN I_SlsContrItemPricingElement WITH PRIVILEGED ACCESS AS pe ON a~SalesContract = pe~SalesContract
            AND c~SalesContractItem = pe~SalesContractItem AND pe~ConditionType = 'ZPR0' AND pe~ConditionInactiveReason IS INITIAL
       LEFT JOIN  i_plant WITH PRIVILEGED ACCESS AS d ON c~plant = d~plant
       LEFT JOIN  i_PRODUCT WITH PRIVILEGED ACCESS AS e ON c~Product  = e~Product
       LEFT JOIN zproduct_table as zproduct ON c~Product = zproduct~product
*        LEFT JOIN   i_salesdocumentitem WITH PRIVILEGED ACCESS AS j
*       ON c~SalesContract  = j~ReferenceSDDocument
*        LEFT JOIN   i_deliverydocumentitem WITH PRIVILEGED ACCESS AS i
*       ON j~ReferenceSDDocument  = i~ReferenceSDDocument
       FIELDS a~purchaseorderbycustomer,
             a~salescontract,
             c~SDProcessStatus,     " overallsdprocessstatus,
             a~creationdate,
             a~salescontractvalidityenddate,
             a~incotermsclassification,

             c~SalesContractItem,
             c~plant,
             c~Product,
             c~salescontractitemtext,
             c~targetquantity,
             c~targetquantityunit,
             c~itemnetweight,
             c~itemweightunit,
             c~NetPriceAmount,
             c~NetAmount,
             pe~ConditionQuantityUnit,
             d~plantname,
             e~producttype,
             e~productgroup,
             zproduct~product_description
*             h~actualdeliveryquantity
*             j~itemnetweight AS sale_order_net_wt
*             i~itemnetweight AS del_net_wt
              WHERE
       a~salescontract IN @it_SALESCONTRACT
   AND   c~plant IN @lt_Plant AND a~purchaseorderbycustomer IN @it_PURCHASEORDERBYCUSTOMER
     INTO TABLE @DATA(it).

*      SELECT FROM i_salescontractpartner FIELDS
*                   SalesContract,
*                   partner,
*                   fullname AS Bill_to_Party_Name,
*                   fullname AS Sales_Employee_Name,
*                   fullname AS Broker_Name
*                   WHERE SalesContract IN @it_salescontract
*                   AND PartnerFunction IN ( 'RE' ,'ZE','ES' )
*                   INTO TABLE @DATA(it_salespartner) PRIVILEGED ACCESS.
      SELECT FROM i_salescontractpartner as sc
            INNER JOIN I_Customer AS cu ON cu~Customer = sc~partner
            INNER JOIN I_Address_2 as addr ON cu~AddressID = addr~AddressID
            FIELDS
                   sc~SalesContract,
                   sc~partner,
                   sc~fullname,
                   sc~PartnerFunction,
                   addr~cityname
                   WHERE sc~SalesContract IN @it_salescontract
                   AND sc~PartnerFunction = 'RE'
                   INTO TABLE @DATA(it_salespartnerBillTo) PRIVILEGED ACCESS.


      SELECT FROM i_salescontractpartner FIELDS
                   SalesContract,
                   partner,
                   fullname,
                   PartnerFunction
                   WHERE SalesContract IN @it_salescontract
                   AND PartnerFunction = 'ZE'
                   INTO TABLE @DATA(it_salespartnerEmp) PRIVILEGED ACCESS.
      SELECT FROM i_salescontractpartner FIELDS
                   SalesContract,
                   partner,
                   fullname,
                   PartnerFunction
                   WHERE SalesContract IN @it_salescontract
                   AND PartnerFunction = 'ES'
                   INTO TABLE @DATA(it_salespartnerBroker) PRIVILEGED ACCESS.

      SELECT FROM I_SalesDocumentitem
        FIELDS ReferenceSDDocument, ReferenceSDDocumentItem,
        SUM( OrderQuantity ) as SOQty, SUM( ItemNetWeight ) as SONetWeight
        WHERE ReferenceSDDocument IS NOT INITIAL
        GROUP BY ReferenceSDDocument, ReferenceSDDocumentItem
        INTO TABLE @DATA(lv_so) PRIVILEGED ACCESS.

      SELECT FROM I_SalesDocumentitem AS a
        LEFT JOIN I_DeliveryDocumentItem AS b
        ON b~ReferenceSDDocument = a~SalesDocument AND b~ReferenceSDDocumentItem = a~SalesDocumentItem
        FIELDS a~ReferenceSDDocument, a~ReferenceSDDocumentItem,
        SUM( b~ActualDeliveryQuantity ) as ActualDeliveryQuantity, SUM( b~ItemNetWeight ) as DeliveryNetWeight
        GROUP BY a~ReferenceSDDocument, a~ReferenceSDDocumentItem
        INTO TABLE @DATA(lv_dlvry) PRIVILEGED ACCESS.

      SELECT FROM I_SalesDocumentitem AS a
        LEFT JOIN I_BillingDocumentItem AS b
        ON b~SalesDocument = a~SalesDocument AND b~SalesDocumentItem = a~SalesDocumentItem
        FIELDS
        a~ReferenceSDDocument, a~ReferenceSDDocumentItem,
        SUM( CASE When b~BillingDocumentType = 'F2' OR b~BillingDocumentType = 'JSTO' Then b~BillingQuantity ELSE -1 * b~BillingQuantity End ) as BillingQuantity,
        SUM( CASE When b~BillingDocumentType = 'F2' OR b~BillingDocumentType = 'JSTO' Then b~ItemNetWeight   ELSE -1 * b~ItemNetWeight End ) as BillingNetWeight
        GROUP BY a~ReferenceSDDocument, a~ReferenceSDDocumentItem
        INTO TABLE @DATA(lv_billing) PRIVILEGED ACCESS.

      LOOP AT it INTO DATA(wa).
        ls_response-purchaseorderbycustomer = wa-purchaseorderbycustomer.
        ls_response-SalesContract = wa-SalesContract.
        ls_response-plant = wa-plant.
        ls_response-SalesContractItem = wa-SalesContractItem.

        READ TABLE it_salespartnerbillto INTO DATA(wa_partnerbillto) WITH KEY SalesContract = wa-SalesContract.
        IF wa_partnerbillto IS NOT INITIAL.
          ls_response-partner = wa_partnerbillto-Partner.
          ls_response-fullname = wa_partnerbillto-FullName.
          ls_response-partnercity = wa_partnerbillto-CityName.
          CLEAR wa_partnerbillto.
        ENDIF.

        READ TABLE it_salespartneremp INTO DATA(wa_partneremp) WITH KEY SalesContract = wa-SalesContract.
        IF wa_partneremp IS NOT INITIAL.
          ls_response-FULLNAME_sales = wa_partneremp-FullName.
          CLEAR wa_partneremp.
        ENDIF.

        READ TABLE it_salespartnerbroker INTO DATA(wa_partnerbroker) WITH KEY SalesContract = wa-SalesContract.
        IF wa_partnerbroker IS NOT INITIAL.
          ls_response-FULLNAME_Broker = wa_partnerbroker-FullName.
          CLEAR wa_partnerbroker.
        ENDIF.


        ls_response-overallsdprocessstatus = wa-SDProcessStatus.
        IF wa-SDProcessStatus = 'A'.
            ls_response-statusdesc = 'Open'.
        ELSEIF wa-SDProcessStatus = 'B'.
            ls_response-statusdesc = 'In Process'.
        ELSEIF wa-SDProcessStatus = 'C'.
            ls_response-statusdesc = 'Completed'.
        ENDIF.
        ls_response-creationdate = wa-creationdate.
        ls_response-salescontractvalidityenddate = wa-salescontractvalidityenddate.
        ls_response-incotermsclassification = wa-incotermsclassification.

        ls_response-material = wa-Product.
        IF wa-product_description IS INITIAL.
            ls_response-salescontractitemtext = wa-salescontractitemtext.
        ELSE.
            ls_response-salescontractitemtext = wa-product_description.
        ENDIF.
        ls_response-targetquantity = wa-targetquantity.
        ls_response-targetquantityunit = wa-targetquantityunit.
        ls_response-plantname = wa-plantname.
        ls_response-producttype = wa-producttype.
        ls_response-productgroup = wa-productgroup.
        ls_response-itemweightunit = wa-ItemWeightUnit.
        ls_response-netprice = wa-NetPriceAmount.
        ls_response-netpriceuom = wa-ConditionQuantityUnit.
        ls_response-contractamount = wa-NetAmount.

*        SELECT SINGLE FROM I_SalesDocumentitem AS a
*        LEFT JOIN I_DeliveryDocumentItem AS b
*        ON b~ReferenceSDDocument = a~SalesDocument AND b~ReferenceSDDocumentItem = a~SalesDocumentItem
*        FIELDS a~salesdocument, a~salesdocumentitem,
*        b~ActualDeliveryQuantity, b~ItemNetWeight AS itemnetwt_dlvry
*
*        WHERE a~ReferenceSDDocument = @wa-SalesContract AND a~ReferenceSDDocumentItem = @wa-SalesContractItem
*        INTO @DATA(WA_qty) PRIVILEGED ACCESS.

        "so qty sum
*        SELECT SINGLE FROM I_SalesDocumentitem
*        FIELDS SUM( OrderQuantity ) as SOQty, SUM( ItemNetWeight ) as SONetWeight
*        WHERE ReferenceSDDocument = @wa-SalesContract AND ReferenceSDDocumentItem = @wa-SalesContractItem
*        INTO @DATA(lv_so_qty_sum) PRIVILEGED ACCESS.

        READ TABLE lv_so INTO DATA(lv_so_qty_sum) WITH KEY ReferenceSDDocument = wa-SalesContract ReferenceSDDocumentItem = wa-SalesContractItem.

        "delivery net qty sum
*        SELECT SINGLE FROM I_SalesDocumentitem AS a
*        LEFT JOIN I_DeliveryDocumentItem AS b
*        ON b~ReferenceSDDocument = a~SalesDocument AND b~ReferenceSDDocumentItem = a~SalesDocumentItem
*        FIELDS SUM( b~ActualDeliveryQuantity ) as ActualDeliveryQuantity, SUM( b~ItemNetWeight ) as DeliveryNetWeight
*        WHERE a~ReferenceSDDocument = @wa-SalesContract AND a~ReferenceSDDocumentItem = @wa-SalesContractItem
*        INTO @DATA(lv_dlvry_qty_sum) PRIVILEGED ACCESS.

        READ TABLE lv_dlvry INTO DATA(lv_dlvry_qty_sum) WITH KEY ReferenceSDDocument = wa-SalesContract ReferenceSDDocumentItem = wa-SalesContractItem.

        "Billing net qty sum
*        SELECT SINGLE FROM I_SalesDocumentitem AS a
*        LEFT JOIN I_BillingDocumentItem AS b
*        ON b~SalesDocument = a~SalesDocument AND b~SalesDocumentItem = a~SalesDocumentItem
*        FIELDS
*        SUM( CASE When b~BillingDocumentType = 'F2' OR b~BillingDocumentType = 'JSTO' Then b~BillingQuantity ELSE -1 * b~BillingQuantity End ) as BillingQuantity,
*        SUM( CASE When b~BillingDocumentType = 'F2' OR b~BillingDocumentType = 'JSTO' Then b~ItemNetWeight   ELSE -1 * b~ItemNetWeight End ) as BillingNetWeight
*        WHERE a~ReferenceSDDocument = @wa-SalesContract AND a~ReferenceSDDocumentItem = @wa-SalesContractItem
*        INTO @DATA(lv_billing_qty_sum) PRIVILEGED ACCESS.

        READ TABLE lv_billing INTO DATA(lv_billing_qty_sum) WITH KEY ReferenceSDDocument = wa-SalesContract ReferenceSDDocumentItem = wa-SalesContractItem.

        ls_response-orderquantity = lv_so_qty_sum-soqty.  "sales order qty
        ls_response-actualdeliveryquantity = lv_dlvry_qty_sum-actualdeliveryquantity.  " wa_QTY-actualdeliveryquantity.
        ls_response-actualinvoicequantity = lv_billing_qty_sum-billingquantity.  " wa_QTY-actualdeliveryquantity.
        ls_response-Contract_Balance_Quantity = wa-targetquantity - lv_so_qty_sum-soqty.
        ls_response-itemnetweight = wa-ItemNetWeight.
        ls_response-ITEMNETWEIGHT_so = lv_so_qty_sum-sonetweight. "wa_qty-ItemNetWeight.
        ls_response-ITEMNETWEIGHT_delivery = lv_dlvry_qty_sum-deliverynetweight.
        ls_response-ITEMNETWEIGHT_Invoice = lv_billing_qty_sum-billingnetweight.

        ls_response-Contract_deliver_Balance_Qty = wa-targetquantity - lv_dlvry_qty_sum-actualdeliveryquantity.
        ls_response-Contract_Pending_Net_Weight =  wa-ItemNetWeight  - lv_so_qty_sum-sonetweight.

        APPEND ls_response TO lt_response.
        CLEAR: wa, ls_response, lv_so_qty_sum, lv_dlvry_qty_sum, lv_billing_qty_sum.
      ENDLOOP.


*      SORT lt_response BY plant.
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
ENDCLASS.
