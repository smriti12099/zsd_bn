CLASS zcl_daily_dispatch DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_DAILY_DISPATCH IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF zdd_daily_dispatch,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.


      DATA(lv_top)   =   io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)  =   io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0 ELSE lv_top ).

      DATA(lt_parameters)  = io_request->get_parameters( ).
      DATA(lt_fileds)  = io_request->get_requested_elements( ).
      DATA(lt_sort)          = io_request->get_sort_elements( ).

      TRY.
          DATA(lt_Filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
          CLEAR lt_Filter_cond.
      ENDTRY.


      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = to_upper( 'bill' ).
          DATA(lt_bill) = ls_filter_cond-range[].
        ELSEIF ls_filter_cond-name = to_upper( 'bill_item' ).
          DATA(lt_bill_item) = ls_FILTER_cond-range[].
        ELSEIF ls_filter_cond-name = to_upper( 's_plant' ).
          DATA(lt_splant) = ls_FILTER_cond-range[].
        ELSEIF ls_filter_cond-name = to_upper( 'r_plant' ).
          DATA(lt_rplant) = ls_FILTER_cond-range[].
        ELSEIF ls_filter_cond-name = to_upper( 's_plant_name' ).
          DATA(lt_splantname) = ls_FILTER_cond-range[].
        ELSEIF ls_filter_cond-name = to_upper( 'r_plant_name' ).
          DATA(lt_rplantname) = ls_FILTER_cond-range[].
        ELSEIF ls_filter_cond-name = to_upper( 'cust' ).
          DATA(lt_cust) = ls_FILTER_cond-range[].
        ELSEIF ls_filter_cond-name = to_upper( 'city' ).
          DATA(lt_city) = ls_FILTER_cond-range[].
        ELSEIF ls_filter_cond-name = to_upper( 'depot' ).
          DATA(lt_depot) = ls_FILTER_cond-range[].
        ELSEIF ls_filter_cond-name = to_upper( 'creation_date' ).
          DATA(lt_creationdate) = ls_FILTER_cond-range[].
        ELSEIF ls_filter_cond-name = to_upper( 'mat_code' ).
          DATA(lt_matcode) = ls_FILTER_cond-range[].
        ELSEIF ls_filter_cond-name = to_upper( 'mat_desc' ).
          DATA(lt_mat_desc) = ls_FILTER_cond-range[].
        ELSEIF ls_filter_cond-name = to_upper( 'inv_qty' ).
          DATA(lt_inv_qty) = ls_FILTER_cond-range[].
        ELSEIF ls_filter_cond-name = to_upper( 'inv_unit' ).
          DATA(lt_inv_unit) = ls_FILTER_cond-range[].
        ELSEIF ls_filter_cond-name = to_upper( 'mat_cat' ).
          DATA(lt_mat_cat) = ls_FILTER_cond-range[].
        ELSEIF ls_filter_cond-name = to_upper( 'net_weight' ).
          DATA(lt_net_weight) = ls_FILTER_cond-range[].
        ELSEIF ls_filter_cond-name = to_upper( 'gross_weight' ).
          DATA(lt_gross_weight) = ls_FILTER_cond-range[].
        ELSEIF ls_filter_cond-name = to_upper( 'ratepercase' ).
          DATA(lt_ratepercase) = ls_FILTER_cond-range[].
        ELSEIF ls_filter_cond-name = to_upper( 'inv_amt' ).
          DATA(lt_inv_amt) = ls_FILTER_cond-range[].
        ELSEIF ls_filter_cond-name = to_upper( 'veh' ).
          DATA(lt_veh) = ls_FILTER_cond-range[].
        ELSEIF ls_filter_cond-name = to_upper( 'lr_no' ).
          DATA(lt_lr_no) = ls_FILTER_cond-range[].
        ELSEIF ls_filter_cond-name = to_upper( 'Trans_name' ).
          DATA(lt_trans_name) = ls_FILTER_cond-range[].
        ELSEIF ls_filter_cond-name = to_upper( 'eway' ).
          DATA(lt_eway) = ls_FILTER_cond-range[].
        ENDIF.
      ENDLOOP.

      IF lt_bill IS NOT INITIAL.
        LOOP AT lt_bill INTO DATA(wa_bill).

          DATA : var1 TYPE I_BillingDocument-BillingDocument.

          IF wa_bill-low IS NOT INITIAL.
            var1 = wa_bill-low.
            wa_bill-low = |{ var1 ALPHA = IN }|.
          ENDIF.

          IF wa_bill-high IS NOT INITIAL.
            CLEAR var1.
            var1 = wa_bill-high .
            wa_bill-high  = |{ var1 ALPHA = IN }|.
          ENDIF.
          MODIFY lt_bill FROM wa_bill.
        ENDLOOP.
      ENDIF.

      IF lt_matcode IS NOT INITIAL.
        LOOP AT lt_matcode INTO DATA(wa_matcode).

          DATA : var2 TYPE c LENGTH 18.

          IF wa_matcode-low IS NOT INITIAL.
            var2 = wa_matcode-low.
            wa_matcode-low = |{ var2 ALPHA = IN }|.
          ENDIF.

          IF wa_matcode-high IS NOT INITIAL.
            CLEAR var2.
            var2 = wa_matcode-high .
            wa_matcode-high  = |{ var2 ALPHA = IN }|.
          ENDIF.
          MODIFY lt_matcode FROM wa_matcode.
        ENDLOOP.
      ENDIF.

      IF lt_cust IS NOT INITIAL.
        LOOP AT lt_cust INTO DATA(wa_cust).

          DATA : var3 TYPE c LENGTH 10.

          IF wa_cust-low IS NOT INITIAL.
            var3 = wa_cust-low.
            wa_cust-low = |{ var3 ALPHA = IN }|.
          ENDIF.

          IF wa_cust-high IS NOT INITIAL.
            CLEAR var3.
            var3 = wa_cust-high .
            wa_cust-high  = |{ var3 ALPHA = IN }|.
          ENDIF.
          MODIFY lt_cust FROM wa_cust.
        ENDLOOP.
      ENDIF.



      SELECT FROM I_BillingDocumentItem AS a
      LEFT JOIN I_OutboundDeliveryItem AS b ON a~ReferenceSDDocument = b~OutboundDelivery AND a~ReferenceSDDocumentItem = b~OutboundDeliveryItem
      LEFT JOIN I_OutboundDelivery AS c ON b~OutboundDelivery = c~OutboundDelivery
      LEFT JOIN ztable_plant AS d ON a~Plant = d~plant_code
      LEFT JOIN ztable_plant AS e ON c~ReceivingPlant = e~plant_code
      LEFT JOIN I_BillingDocument AS f ON a~BillingDocument = f~BillingDocument
      LEFT JOIN I_DeliveryDocument AS g ON  a~ReferenceSDDocument = g~DeliveryDocument
      LEFT JOIN I_customer AS h ON g~ShipToParty = h~Customer
      LEFT JOIN I_Address_2 AS i ON h~AddressID = i~AddressID
      LEFT JOIN I_Product AS j ON a~Product = j~Product
      LEFT JOIN ztable_irn AS k ON a~Plant = k~plant AND a~BillingDocument = k~billingdocno
      LEFT JOIN  i_billingdocumentitemprcgelmnt AS l ON a~BillingDocument = l~BillingDocument AND a~BillingDocumentItem = l~BillingDocumentItem AND l~ConditionClass = 'B' AND l~ConditionIsForStatistics IS INITIAL
      AND l~ConditionInactiveReason IS INITIAL
      LEFT JOIN i_deliverydocumentitem AS ddi ON a~ReferenceSDDocument = ddi~DeliveryDocument AND a~ReferenceSDDocumentItem = ddi~DeliveryDocumentItem
      FIELDS a~Plant,a~BillingDocument,a~BillingDocumentItem,a~ReferenceSDDocument as bill_referenceSDDocument , c~ReceivingPlant,d~plant_name1,e~plant_name1 AS receiving_name,f~PayerParty,
      i~CityName,a~CreationDate,a~Product,a~BillingDocumentItemText,a~BillingQuantity,a~BillingQuantityUnit,j~ProductType,a~ItemNetWeight,a~ItemGrossWeight,
      a~ItemWeightUnit,k~vehiclenum,k~grno,k~transportername,k~ewaybillno
      ,l~ConditionAmount,l~ConditionRateAmount,
      g~ShipToParty,
      f~SoldToParty,
      h~CustomerName,
      ddi~ReferenceSDDocument

      WHERE a~BillingDocument IN @lt_bill AND a~BillingDocumentItem IN @lt_bill_item AND a~Plant IN @lt_splant AND c~ReceivingPlant IN @lt_rplant AND
      d~plant_name1 IN @lt_splantname AND e~plant_name1 IN @lt_rplantname AND f~PayerParty IN @lt_cust AND i~CityName IN @lt_city AND e~plant_name1 IN @lt_depot AND
       a~CreationDate IN @lt_creationdate AND a~Product IN @lt_matcode AND a~BillingDocumentItemText IN @lt_mat_desc AND a~BillingQuantity IN @lt_inv_qty
       AND a~BillingQuantityUnit IN @lt_inv_unit AND j~ProductType IN @lt_mat_cat AND a~ItemNetWeight IN @lt_net_weight AND a~ItemGrossWeight IN @lt_gross_weight
       AND l~ConditionAmount IN @lt_inv_amt AND l~ConditionRateAmount IN @lt_ratepercase AND k~vehiclenum IN @lt_veh AND k~grno IN @lt_lr_no
       AND k~transportername IN @lt_trans_name AND k~ewaybillno IN @lt_eway
      INTO TABLE @DATA(it).


      IF it IS NOT INITIAL.

*       SELECT cus~Customer, cus~CustomerName
*    INTO TABLE @DATA(sold_to_party_name)
*    FROM I_Customer AS cus
*    FOR ALL ENTRIES IN @it
*    WHERE cus~Customer = @it-SoldToParty.
**
        SELECT cus~Customer, cus~CustomerName
        FROM I_Customer AS cus
        INNER JOIN @it AS itab
        ON cus~Customer = itab~SoldToParty
        INTO TABLE @DATA(sold_to_party_name).

        select from zgateentrylines as a
            inner join zgateentryheader as c on a~gateentryno = c~gateentryno
             INNER JOIN @it AS b ON LPAD( a~documentno, 10, '0' ) = b~bill_referenceSDDocument
*            inner join @it as b on a~documentno = b~ReferenceSDDocument
          FIELDS a~gateentryno, c~drivername, a~documentno
            into table @data(it_drivername).

      ENDIF.


      LOOP AT it ASSIGNING FIELD-SYMBOL(<fs_item>).
        SHIFT <fs_item>-BillingDocument LEFT DELETING LEADING '0'.
        SHIFT <fs_item>-Product LEFT DELETING LEADING '0'.
        SHIFT <fs_item>-PayerParty LEFT DELETING LEADING '0'.
        shift <fs_item>-bill_referencesddocument LEFT DELETING LEADING '0'.
      ENDLOOP.

      SORT it BY BillingDocument BillingDocumentItem.
      DATA : count TYPE i VALUE 1.

      LOOP AT it INTO DATA(wa).
*       ls_response-cnt = count.
        ls_response-s_plant = wa-Plant.
        ls_response-r_plant = wa-ReceivingPlant.
        ls_response-s_plant_name = wa-plant_name1.
        ls_response-r_plant_name = wa-receiving_name.
        ls_response-bill = wa-BillingDocument.
        ls_response-bill_item = wa-BillingDocumentItem.
        ls_response-cust = wa-PayerParty.
        ls_response-city = wa-cityname.
        ls_response-depot = wa-receiving_name.
        ls_response-creation_date = wa-CreationDate.
        ls_response-mat_code = wa-Product.
        ls_response-mat_desc = wa-BillingDocumentItemText.
        ls_response-inv_qty = wa-BillingQuantity.
        ls_response-inv_unit = wa-BillingQuantityUnit.
        ls_response-mat_cat = wa-ProductType.
        ls_response-net_weight = wa-ItemNetWeight.
        ls_response-net_unit = wa-ItemWeightUnit.
        ls_response-gross_weight = wa-ItemGrossWeight.
        ls_response-gross_unit = wa-ItemWeightUnit.
        ls_response-ratepercase = wa-ConditionRateAmount.
        ls_response-inv_amt = wa-ConditionAmount.
        ls_response-veh = wa-vehiclenum.
        ls_response-lr_no = wa-grno.
        ls_response-Trans_name = wa-transportername.
        ls_response-eway = wa-ewaybillno.
        ls_response-ship_to_party = wa-ShipToParty.
        ls_response-ship_to_party_name = wa-CustomerName.
        ls_response-sold_to_party = wa-SoldToParty.
        ls_response-sale_order_po = wa-ReferenceSDDocument.

        READ TABLE sold_to_party_name INTO DATA(wa_sold_to_party_name) WITH KEY Customer = wa-SoldToParty.
        ls_response-sold_to_party_name = wa_sold_to_party_name-CustomerName.


        read table it_drivername into data(wa_drivername) with key documentno = wa-bill_referenceSDDocument.
        ls_response-driver_name = wa_drivername-drivername.

        APPEND ls_response TO lt_response.
        CLEAR : ls_response.
*       count = count + 1.
      ENDLOOP.


      SORT lt_response BY bill bill_item .

      LOOP AT lt_sort INTO DATA(ls_sort).
        CASE ls_sort-element_name.
          WHEN 'BILL'.
            SORT lt_response BY  bill ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY bill DESCENDING.
            ENDIF.
          WHEN 'BILL_ITEM'.
            SORT lt_response BY bill_item ASCENDING.
            IF ls_sort-descending = abap_true.
              SORT lt_response BY bill_item DESCENDING.
            ENDIF.
        ENDCASE.
      ENDLOOP.

      lv_max_rows = lv_skip + lv_top.
      IF lv_skip > 0.
        lv_skip = lv_skip + 1.
      ENDIF.
*    DELETE ADJACENT DUPLICATES FROM lt_response COMPARING bill bill_item.
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
