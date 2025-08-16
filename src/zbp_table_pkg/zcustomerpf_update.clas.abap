CLASS zcustomerpf_update DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_result,
             Customer            TYPE string,
             SalesOrganization   TYPE string,
             DistributionChannel TYPE string,
             Division            TYPE string,
             PartnerCounter      TYPE string,
             PartnerFunction     TYPE string,
             BPCustomerNumber    TYPE string,
           END OF ty_result.

    TYPES:  BEGIN OF ty_results,
              results TYPE STANDARD TABLE OF ty_result WITH EMPTY KEY,
            END OF ty_results.
    TYPES: BEGIN OF ty_d,
             d TYPE ty_results,
           END OF ty_d.

    TYPES: BEGIN OF ty_d_patch,
             d TYPE ty_result,
           END OF ty_d_patch.




    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun .

    METHODS runJob
      IMPORTING
        VALUE(Customer) TYPE c.

     METHODS extract_message_from_xml
      IMPORTING
        !iv_xml       TYPE string
      RETURNING
        VALUE(rv_msg) TYPE string.
PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCUSTOMERPF_UPDATE IMPLEMENTATION.


  METHOD extract_message_from_xml.

    DATA: lv_start_pos TYPE i,
          lv_close_pos TYPE i,
          lv_len       TYPE i,
          lv_temp      TYPE string.

    " Find opening <message> tag
    FIND FIRST OCCURRENCE OF '<message' IN iv_xml MATCH OFFSET lv_start_pos.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " Find the end of the opening tag '>'
    lv_temp = iv_xml+lv_start_pos.
    FIND FIRST OCCURRENCE OF '>' IN lv_temp MATCH OFFSET lv_close_pos.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    lv_start_pos = lv_start_pos + lv_close_pos + 1.

    " Find closing </message> tag
    lv_temp = iv_xml+lv_start_pos.
    FIND FIRST OCCURRENCE OF '</message>' IN lv_temp MATCH OFFSET lv_close_pos.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    lv_len = lv_close_pos.
    rv_msg = iv_xml+lv_start_pos(lv_len).
  ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 80 param_text = 'Customer Partner Function'   lowercase_ind = abap_true changeable_ind = abap_true )
    ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'Customer Partner Function' )
    ).

  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    DATA p_descr TYPE c LENGTH 80.

    " Getting the actual parameter values
*    LOOP AT it_parameters INTO DATA(ls_parameter).
*      CASE ls_parameter-selname.
*        WHEN 'P_DESCR'. p_descr = ls_parameter-low.
*      ENDCASE.
*    ENDLOOP.

    runjob( '' ).
*    runjob( p_descr ).
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    runJob( '100002' ).
  ENDMETHOD.


  METHOD runJob.

    DATA url_response2 TYPE string.
    DATA BPCustomer TYPE c LENGTH 10.
    DATA lv_client TYPE REF TO if_web_http_client.
    DATA user_pass TYPE string.
    BPCustomer = Customer.

    SELECT SINGLE FROM zintegration_tab
      FIELDS intgpath
      WHERE intgmodule = 'MY-URL'
      INTO @DATA(my_url).

    SELECT SINGLE FROM zr_integration_tab
        FIELDS Intgpath
        WHERE Intgmodule = 'MY-USER'
        INTO @user_pass.
    SPLIT user_pass AT ':' INTO DATA(i_username) DATA(i_password).


    IF BPCustomer IS NOT INITIAL.
      SELECT * FROM zdt_bp_partner
       WHERE customer = @BPCustomer
       INTO TABLE @DATA(lt_pf).
    ELSE.
      SELECT * FROM zdt_bp_partner
       WHERE processed NE 1
       INTO TABLE @lt_pf.
    ENDIF.


    LOOP AT lt_pf INTO DATA(wa_pf).

      TRY.
          DATA(dest2) = cl_http_destination_provider=>create_by_url( CONV string( my_url ) ).
          lv_client = cl_web_http_client_manager=>create_by_http_destination( dest2 ).
        CATCH cx_static_check INTO DATA(lv_cx_static_check2).
          RETURN.
      ENDTRY.

      DATA(forward_url) = |/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_CustSalesPartnerFunc|.
      DATA(key) = |{ forward_url }(Customer='{ wa_pf-customer }',|
                     &&  |SalesOrganization='{ wa_pf-sales_org }',|
                     &&  |DistributionChannel='{ wa_pf-dist_channel }',|
                     &&  |Division='{ wa_pf-division }',|
                     &&  |PartnerCounter='0',|
                     &&  |PartnerFunction='{ wa_pf-partner_function }')|.

      DATA(req4) = lv_client->get_http_request( ).
      req4->set_authorization_basic(
          i_username = i_username
          i_password = i_password
      ).
      req4->set_uri_path( key ).
      req4->set_header_field( i_name =  'x-csrf-token' i_value = 'fetch' ).
      req4->set_content_type( 'application/json' ).

      TRY.
          DATA(get_response) = lv_client->execute( if_web_http_client=>get ).
          DATA(text_response) = get_response->get_text( ).
          DATA(status_code) = get_response->get_status( )-code.

          req4->set_header_field( i_name =  'x-csrf-token' i_value = get_response->get_header_field( i_name = 'x-csrf-token' ) ).

          IF status_code EQ 404.

            DATA postdata TYPE ty_result.
            postdata-customer = wa_pf-customer.
            postdata-salesorganization = wa_pf-sales_org.
            postdata-distributionchannel = wa_pf-dist_channel.
            postdata-division = wa_pf-division.
            postdata-partnercounter = '0'.
            postdata-partnerfunction = wa_pf-partner_function.
            postdata-bpcustomernumber = wa_pf-bpcustomernumber.

            DATA:json TYPE REF TO if_xco_cp_json_data.
            xco_cp_json=>data->from_abap(
              EXPORTING ia_abap      = postdata
              RECEIVING ro_json_data = json
              ).
            json->to_string( RECEIVING rv_string = DATA(lv_string) ).

            REPLACE ALL OCCURRENCES OF 'CUSTOMER' IN lv_string WITH 'Customer'.
            REPLACE ALL OCCURRENCES OF 'SALESORGANIZATION' IN lv_string WITH 'SalesOrganization'.
            REPLACE ALL OCCURRENCES OF 'DISTRIBUTIONCHANNEL' IN lv_string WITH 'DistributionChannel'.
            REPLACE ALL OCCURRENCES OF 'DIVISION' IN lv_string WITH 'Division'.
            REPLACE ALL OCCURRENCES OF 'PARTNERCOUNTER' IN lv_string WITH 'PartnerCounter'.
            REPLACE ALL OCCURRENCES OF 'PARTNERFUNCTION' IN lv_string WITH 'PartnerFunction'.
            REPLACE ALL OCCURRENCES OF 'BPCUSTOMERNUMBER' IN lv_string WITH 'BPCustomerNumber'.
            REPLACE ALL OCCURRENCES OF 'NUMBER' IN lv_string WITH 'Number'.

            req4->set_uri_path( forward_url ).
            req4->set_text( lv_string ).
            DATA(lv_response2) = lv_client->execute( if_web_http_client=>post ).
            IF lv_response2->get_status( )-code EQ 201.
              UPDATE zdt_bp_partner
                SET processed = 1
                WHERE customer = @wa_pf-customer
                  AND sales_org = @wa_pf-sales_org
                  AND dist_channel = @wa_pf-dist_channel
                  AND division = @wa_pf-division
                  AND partner_function = @wa_pf-partner_function.
            ELSE.
              DATA(message) = extract_message_from_xml( lv_response2->get_text(  ) ).
              UPDATE zdt_bp_partner
               SET log = @message, processed = 2
               WHERE customer = @wa_pf-customer
                 AND sales_org = @wa_pf-sales_org
                 AND dist_channel = @wa_pf-dist_channel
                 AND division = @wa_pf-division
                 AND partner_function = @wa_pf-partner_function.
            ENDIF.

          ELSE.
            DATA patchdata TYPE ty_d_patch.
            patchdata-d-bpcustomernumber = wa_pf-bpcustomernumber.

            DATA:json2 TYPE REF TO if_xco_cp_json_data.

            xco_cp_json=>data->from_abap(
              EXPORTING
                ia_abap      = patchdata
              RECEIVING
                ro_json_data = json2   ).
            json2->to_string(
              RECEIVING
                rv_string =   DATA(lv_string2) ).

            REPLACE ALL OCCURRENCES OF '"CUSTOMER":"",' IN lv_string2 WITH ''.
            REPLACE ALL OCCURRENCES OF '"SALESORGANIZATION":"",' IN lv_string2 WITH ''.
            REPLACE ALL OCCURRENCES OF '"DISTRIBUTIONCHANNEL":"",' IN lv_string2 WITH ''.
            REPLACE ALL OCCURRENCES OF '"DIVISION":"",' IN lv_string2 WITH ''.
            REPLACE ALL OCCURRENCES OF '"PARTNERCOUNTER":"",' IN lv_string2 WITH ''.
            REPLACE ALL OCCURRENCES OF '"PARTNERFUNCTION":"",' IN lv_string2 WITH ''.
            REPLACE ALL OCCURRENCES OF 'BPCUSTOMERNUMBER' IN lv_string2 WITH 'BPCustomerNumber'.
            REPLACE ALL OCCURRENCES OF 'D' IN lv_string2 WITH 'd'.
            REPLACE ALL OCCURRENCES OF 'NUMBER' IN lv_string2 WITH 'Number'.

            req4->set_text( lv_string2 ).
            req4->set_header_field( i_name =  'If-Match' i_value = '*' ).
            req4->set_uri_path( key ).
            DATA(lv_response3) = lv_client->execute( if_web_http_client=>patch ).
            DATA(text_response3) = lv_response3->get_text( ).
            DATA(status_code2) = lv_response3->get_status( )-code.

            IF status_code2 EQ 204.
              UPDATE zdt_bp_partner
                SET processed = 1
                WHERE customer = @wa_pf-customer
                  AND sales_org = @wa_pf-sales_org
                  AND dist_channel = @wa_pf-dist_channel
                  AND division = @wa_pf-division
                  AND partner_function = @wa_pf-partner_function.
            ELSE.
              message = extract_message_from_xml( text_response3 ).
              UPDATE zdt_bp_partner
                SET log = @message, processed = 2
                WHERE customer = @wa_pf-customer
                  AND sales_org = @wa_pf-sales_org
                  AND dist_channel = @wa_pf-dist_channel
                  AND division = @wa_pf-division
                  AND partner_function = @wa_pf-partner_function.
            ENDIF.
          ENDIF.
          CLEAR: patchdata,postdata,message.

        CATCH cx_web_http_client_error INTO DATA(lv_error_response2).
          RETURN.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
