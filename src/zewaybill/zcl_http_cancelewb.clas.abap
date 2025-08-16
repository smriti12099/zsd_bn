CLASS zcl_http_cancelewb DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension .

    CLASS-METHODS :getPayload IMPORTING
                                        invoice       TYPE ztable_irn-billingdocno
                                        companycode   TYPE ztable_irn-bukrs
                              RETURNING VALUE(result) TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_HTTP_CANCELEWB IMPLEMENTATION.


  METHOD getPayload.


    TYPES: BEGIN OF ty_item_list,
             ewbNo         TYPE string,
             cancelRsnCode TYPE string,
             cancelRmrk    TYPE string,
           END OF ty_item_list.

    DATA : wa_json TYPE ty_item_list.

    SELECT SINGLE FROM ztable_irn AS a
    FIELDS a~ewaybillno
     WHERE a~billingdocno = @invoice AND
     a~bukrs = @companycode
     INTO @DATA(lv_table_data).

    IF lv_table_data = ''.
      result = '1'.
      RETURN.
    ENDIF.

    wa_json-ewbno = lv_table_data.
    wa_json-cancelrmrk =  'Data Entry Mistake'.
    wa_json-cancelrsncode = 'DATA_ENTRY_MISTAKE'.


    DATA:json TYPE REF TO if_xco_cp_json_data.

    xco_cp_json=>data->from_abap(
      EXPORTING
        ia_abap      = wa_json
      RECEIVING
        ro_json_data = json   ).
    json->to_string(
      RECEIVING
        rv_string =   DATA(lv_string) ).

    REPLACE ALL OCCURRENCES OF '"EWBNO"' IN lv_string WITH '"ewbNo"'.
    REPLACE ALL OCCURRENCES OF '"CANCELRSNCODE"' IN lv_string WITH '"cancelRsnCode"'.
    REPLACE ALL OCCURRENCES OF '"CANCELRMRK"' IN lv_string WITH '"cancelRmrk"'.

    result = lv_string.

  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.
    CASE request->get_method(  ).
      WHEN CONV string( if_web_http_client=>post ).
        DATA irn_url TYPE string.
        DATA lv_client2 TYPE REF TO if_web_http_client.

        SELECT SINGLE FROM zr_integration_tab
        FIELDS Intgpath
        WHERE Intgmodule = 'EWB-CANCEL-URL'
        INTO @irn_url.

        """"""""""""""" changes by apratim on 30/06/2024 """"""""""""""""""""""""
*        select single
*        from zdt_usersetup as a
*        FIELDS
*        a~userid
*        where a~userid = @sy-uname
*        into @data(lv_user).
*
*        IF lv_user is INITIAL.
*          response->set_text( 'Not Authorised to Cancel' ).
*          RETURN.
*        ENDIF.

        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

        TRY.
            DATA(dest2) = cl_http_destination_provider=>create_by_url( irn_url ).
            lv_client2 = cl_web_http_client_manager=>create_by_http_destination( dest2 ).

          CATCH cx_static_check INTO DATA(lv_cx_static_check2).
            response->set_status( i_code = 500 i_reason = 'Internal Server Error' ).
            response->set_text( |Destination creation failed: { lv_cx_static_check2->get_longtext( ) }| ).
            RETURN.
        ENDTRY.

        DATA: lv_bukrs TYPE ztable_irn-bukrs.
        DATA: lv_invoice TYPE ztable_irn-billingdocno.
        DATA: lv_gstno TYPE string.

        TRY.
            lv_bukrs = request->get_form_field( `companycode` ).
            lv_invoice = request->get_form_field( `document` ).

            SELECT SINGLE FROM ztable_irn AS a
          FIELDS a~ewaybillno
             WHERE a~billingdocno = @lv_invoice AND
             a~bukrs = @lv_bukrs
             INTO @DATA(lv_table_data1).


            IF lv_bukrs IS INITIAL OR lv_invoice IS INITIAL.
              response->set_text( 'Company code and document number are required' ).
              RETURN.
            ELSEIF lv_table_data1 IS INITIAL.
              response->set_text( 'EWB Not Generated' ).
              RETURN.
            ENDIF.


            DATA(get_payload) = getpayload( companycode = lv_bukrs invoice = lv_invoice ).

            SELECT SINGLE FROM I_BillingDocumentItem AS b
                  FIELDS b~Plant, b~BillingDocumentType
                  WHERE b~BillingDocument = @lv_invoice
                  INTO @DATA(lv_document_details) PRIVILEGED ACCESS.

            IF sy-subrc <> 0.
              response->set_text( |Document { lv_invoice } not found| ).
              RETURN.
            ENDIF.

            SELECT SINGLE FROM ztable_plant
                FIELDS gstin_no
                WHERE comp_code = @lv_bukrs AND plant_code = @lv_document_details-Plant
                INTO @DATA(userPass).

            IF userPass IS INITIAL.
              response->set_status( i_code = 404 i_reason = 'Not Found' ).
              response->set_text( |GSTIN not found for company { lv_bukrs } and plant { lv_document_details-Plant }| ).
              RETURN.
            ENDIF.

            DATA(req4) = lv_client2->get_http_request( ).

            SELECT SINGLE FROM zr_integration_tab
             FIELDS Intgpath
             WHERE Intgmodule = 'IRN-HEAD'
             INTO @DATA(subscription).

            SPLIT subscription  AT ':' INTO DATA(head1name) DATA(head1val).

            req4->set_header_field(
               i_name  = head1name
               i_value = head1val
             ).
            req4->set_header_field(
               i_name  = 'gstin'
               i_value = CONV string( userPass )
             ).

            req4->append_text( EXPORTING data = get_payload ).
            req4->set_content_type( 'application/json' ).
            DATA url_response2 TYPE string.


            TRY.
                url_response2 = lv_client2->execute( if_web_http_client=>post )->get_text( ).

                TYPES: BEGIN OF errorDetails,
                         error_code    TYPE string,
                         error_message TYPE string,
                         error_source  TYPE string,
                       END OF errorDetails.

                TYPES: BEGIN OF govt_res1,
                         errorDetails TYPE  errorDetails,
                       END OF govt_res1.

                TYPES: BEGIN OF mainres,
                         irn       TYPE  string,
                         ewbStatus TYPE string,
                       END OF mainres.


                DATA lv_message TYPE mainres.
                DATA lv_message2 TYPE govt_res1.

                xco_cp_json=>data->from_string( url_response2 )->write_to( REF #( lv_message ) ).

                IF lv_message-ewbstatus = 'CANCELLED'.

                  DATA: wa_zirn TYPE ztable_irn.
                  SELECT SINGLE * FROM ztable_irn AS a
                     WHERE a~billingdocno = @lv_invoice AND
                     a~bukrs = @lv_bukrs
                     INTO @DATA(lv_table_data).

                  wa_zirn = lv_table_data.
                  wa_zirn-ewaybillno = ''.
                  wa_zirn-ewaydate = '00010101'.
                  wa_zirn-ewaycanceldate = cl_abap_context_info=>get_system_date( ).
                  wa_zirn-ewayvaliddate = '00010101'.
                  wa_zirn-ewaycreatedby  = ''.
                  wa_zirn-ewaystatus = 'CNL'.
                  MODIFY ztable_irn FROM @wa_zirn.

                  response->set_text( |EWB Cancelled| ).
                  RETURN.
                ENDIF.

                xco_cp_json=>data->from_string( url_response2 )->write_to( REF #( lv_message2 ) ).
                response->set_text( lv_message2-errordetails-error_message ).

              CATCH cx_web_http_client_error INTO DATA(lv_error_response2).
                response->set_status( i_code = 500 i_reason = 'Internal Server Error' ).
                response->set_text( |API request failed: { lv_error_response2->get_longtext( ) }| ).
            ENDTRY.
          CATCH cx_root INTO DATA(lv_general_error).
            response->set_status( i_code = 500 i_reason = 'Internal Server Error' ).
            response->set_text( |Processing failed: { lv_general_error->get_longtext( ) }| ).
        ENDTRY.
      WHEN OTHERS.
        response->set_status( i_code = 405 i_reason = 'Method Not Allowed' ).
        response->set_text( 'Only POST method is supported' ).
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
