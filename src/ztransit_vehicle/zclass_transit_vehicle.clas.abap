CLASS zclass_transit_vehicle DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCLASS_TRANSIT_VEHICLE IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    IF io_request->is_data_requested( ).

      DATA: lt_response    TYPE TABLE OF zdd_transit,
            ls_response    LIKE LINE OF lt_response,
            lt_responseout LIKE lt_response,
            ls_responseout LIKE LINE OF lt_responseout.


      DATA: it_final TYPE TABLE OF zdd_transit,
            wa_final TYPE zdd_transit.



      DATA : lv_index          TYPE sy-tabix.

      DATA(lv_top)           = io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)          = io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0
                                  ELSE lv_top ).

*      DATA(lt_clause)        = io_request->get_filter( )->get_as_ranges( ).
      DATA(lt_parameter)     = io_request->get_parameters( ).
      DATA(lt_fields)        = io_request->get_requested_elements( ).
      DATA(lt_sort)          = io_request->get_sort_elements( ).
    ENDIF.


    TRY.
         DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
       CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
         " Minimal handling to satisfy SLIN
         RETURN.
     ENDTRY.




    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
      IF ls_filter_cond-name = 'PLANT'.
        DATA(lt_plant)  = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'RECEIVINGPLANT'.
        DATA(lt_r_plant) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'CUSTOMER_CODE'.
        DATA(lt_s_party) = ls_filter_cond-range[].
      ELSEIF ls_filter_cond-name = 'INVOICE_NO'.
        DATA(lt_inv) = ls_filter_cond-range[].

      ENDIF.
    ENDLOOP.


    SELECT

    a~ReferenceSDDocument AS ref_sd_item,
    a~plant,
    c~receivingplant,
    d~plant_name1 AS  S_NAME_plant,
    k~plant_name1 AS  R_NAME_plant,
    c~shiptoparty AS customer_code,
    d~plant_name1 AS depot_loc,
    z~billingdocument AS invoice_no,
    z~creationdate AS invoice_date,
    b~material AS material_code,
    b~deliverydocumentitemtext AS material_desc,
    a~billingquantity AS invoice_qty,
    a~billingquantityunit AS uom,
    producttype AS material_category,
    b~itemnetweight AS invoice_net_weight,
    b~itemgrossweight AS invoice_gross_weight,
    f~conditionrateamount AS rate_per_casenag,
    f~conditionamount AS invoice_amount,
    g~vehiclenum AS vehicle_no,
    g~grno AS lr_no,
    g~transportername AS transporter_name,
    g~ewaybillno AS e_way_no,
*    h~shiptoparty,
*    i~addressid,
    j~cityname AS ship_to_city,
    a~billingdocumentitem AS bill_item,
    g~ewayvaliddate AS e_way_date






    FROM i_billingdocument AS z
    LEFT JOIN i_billingdocumentitem  AS a  ON z~BillingDocument = a~BillingDocument
    LEFT JOIN   i_outbounddeliveryitem AS b ON a~ReferenceSDDocument =  b~OutboundDelivery AND a~referencesddocumentitem = b~outbounddeliveryitem "AND a~Product = b~DeliveryDocumentItemText
    LEFT JOIN   i_outbounddelivery AS c ON c~OutboundDelivery = b~OutboundDelivery
    LEFT JOIN ztable_plant AS d ON d~plant_code = a~Plant
    LEFT JOIN ztable_plant AS k ON k~plant_code = c~ReceivingPlant
    LEFT JOIN I_Product AS e ON a~Product = e~Product
    LEFT JOIN I_BillingDocumentItemPrcgElmnt AS f ON a~BillingDocument = f~BillingDocument AND a~BillingDocumentItem = f~BillingDocumentItem
    AND f~ConditionClass = 'B' AND f~ConditionIsForStatistics <> 'X'
    LEFT JOIN ztable_irn AS g ON a~Plant = g~plant and a~BillingDocument = g~billingdocno
    LEFT JOIN I_DeliveryDocument AS h ON a~ReferenceSDDocument = h~DeliveryDocument
    LEFT JOIN i_customer AS i ON i~Customer = h~ShipToParty
    LEFT JOIN i_address_2  AS j ON i~AddressID = j~AddressID


    WHERE a~Plant IN @lt_plant AND
    c~ReceivingPlant IN @lt_r_plant AND
    c~ShipToParty IN @lt_s_party AND
    z~BillingDocument IN @lt_inv AND
    z~billingdocumenttype = 'JSTO'

    INTO CORRESPONDING FIELDS OF TABLE @it_final PRIVILEGED ACCESS.

    """""""""""""""""""""""""""""""""""""""

    SORT it_final BY invoice_no ASCENDING.
    DELETE ADJACENT DUPLICATES FROM it_final COMPARING invoice_no.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    DATA : newdocno TYPE string.
    DATA : lv_docitem1 TYPE numc5 .

    LOOP AT it_final INTO DATA(wa_it).

    """"""""""""""""""""""""""DocumentDate""""""""""""""""""""""""""""""""""""""""""""
      SELECT SINGLE  c~DocumentDate
      FROM I_BillingDocumentItem AS b
      left join I_MaterialDocumentItem_2 as c on b~ReferenceSDDocument = c~DeliveryDocument and c~GoodsMovementType = '101'
      WHERE B~ReferenceSDDocument = @wa_it-ref_sd_item

      INTO ( @wa_it-lv_documentdate  ).
      MODIFY it_final FROM wa_it.



        lv_docitem1 = wa_it-bill_item+1(5).
        wa_it-bill_item = lv_docitem1.

      newdocno = wa_it-ref_sd_item+2(8).
      wa_it-ref_sd_item = newdocno .
      MODIFY it_final FROM wa_it.
   """""""""""""""""""""Driver and mobile """""""""""""""""""""""""""""""""""""""""""""""""
      SELECT SINGLE b~drivername , b~driverno
      FROM zr_gateentrylines AS a
      LEFT JOIN zr_gateentryheader AS b
      ON a~gateentryno = b~Gateentryno
      WHERE a~Documentno = @wa_it-ref_sd_item
      INTO (@wa_it-driver_name, @wa_it-driver_mobile_no  ).
      MODIFY it_final FROM wa_it.
  """"""""""""""""""""""""""transit_day-Gateoutdate""""""""""""""""""""""""""""""""""""""""""""


      SELECT SINGLE c~Gateoutdate
      FROM I_BillingDocumentItem AS a
      LEFT JOIN zr_gateentrylines AS b ON @lv_docitem1 = b~Documentitem
                                         "           000010 = 00010
      left join ZR_GateEntryHeader as c on b~Gateentryno = c~Gateentryno
      WHERE b~Documentno = @wa_it-ref_sd_item
      INTO (@wa_it-lv_gateoutdate  ).
      MODIFY it_final FROM wa_it.




        if wa_it-lv_gateoutdate is not INITIAL and wa_it-lv_documentdate is not INITIAL.
        wa_it-no_transit_day =   wa_it-lv_gateoutdate - wa_it-lv_documentdate.
        ENDIF.


      MODIFY it_final FROM wa_it.


    ENDLOOP.


"""""""""""""""""""""""GST""""""""""""""""""""""""""""""""""""""""""

    SELECT billingdocument, billingdocumentitem,
         SUM( conditionamount ) AS gst_amount
    FROM i_billingdocumentitemprcgelmnt
   WHERE conditiontype IN ('JOCG', 'JOIG', 'JOSG')
     "AND conditionisforstatistics <> 'X'
   GROUP BY billingdocument, billingdocumentitem
   INTO TABLE @DATA(lt_gst).

    SORT it_final BY invoice_no ASCENDING.
    DELETE ADJACENT DUPLICATES FROM it_final COMPARING invoice_no.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    LOOP AT it_final INTO DATA(wa).
      SHIFT wa-material_code LEFT DELETING LEADING '0'.

      READ TABLE lt_gst INTO DATA(lv_gst) WITH KEY billingdocument = wa-invoice_no billingdocumentitem = wa-bill_item.

      SELECT  SINGLE b~gateentryno
      FROM i_billingdocumentitem AS a
      LEFT JOIN ZR_GateEntryLines  AS b ON b~Documentno = a~ReferenceSDDocument
*      LEFT JOIN ZR_GateEntryHeader as c on c~Gateentryno = b~Gateentryno
      INTO @DATA(lv_gate_no)  .


      ls_response-invoice_no = wa-invoice_no.
      ls_response-plant = wa-plant.
      ls_response-receivingplant = wa-receivingplant.
      ls_response-s_name_plant = wa-s_name_plant.
      ls_response-r_name_plant = wa-r_name_plant.
      ls_response-customer_code = wa-customer_code.
      ls_response-depot_loc = wa-depot_loc.
      ls_response-invoice_date = wa-invoice_date.
      ls_response-material_code = wa-material_code.
      ls_response-material_desc = wa-material_desc.
      ls_response-invoice_qty = wa-invoice_qty.
      ls_response-uom = wa-uom.
      ls_response-material_category = wa-material_category.
      ls_response-invoice_net_weight = wa-invoice_net_weight.
      ls_response-invoice_gross_weight = wa-invoice_gross_weight.
      ls_response-rate_per_casenag = wa-rate_per_casenag.
      ls_response-invoice_amount = wa-invoice_amount.
      ls_response-vehicle_no = wa-vehicle_no.
      ls_response-lr_no = wa-lr_no.
      ls_response-transporter_name = wa-transporter_name.
      ls_response-e_way_no = wa-e_way_no.
      ls_response-ship_to_city = wa-ship_to_city.
      ls_response-e_way_date = wa-e_way_date.
      ls_response-driver_name = wa-driver_name.
      ls_response-driver_mobile_no = wa-driver_mobile_no.
      ls_response-no_transit_day = wa-no_transit_day.

      IF sy-subrc = 0.
        ls_response-gst_amount = lv_gst-gst_amount.
        ls_response-invo_gst_amount = wa-invoice_amount + lv_gst-gst_amount.
      ELSE.
        CLEAR: ls_response-gst_amount, ls_response-invo_gst_amount.
      ENDIF.

      APPEND ls_response TO lt_response.
      CLEAR ls_response.
    ENDLOOP.
*
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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

  ENDMETHOD.
ENDCLASS.
