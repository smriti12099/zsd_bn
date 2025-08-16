class ZDSC_SIGNEDPRINT definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .
  METHODS pattern_catch IMPORTING row TYPE i RETURNING VALUE(result) type i.
protected section.
private section.
ENDCLASS.



CLASS ZDSC_SIGNEDPRINT IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA lv_client2 TYPE REF TO if_web_http_client.


    CASE request->get_method( ).
      WHEN CONV string( if_web_http_client=>post ).

        TYPES: BEGIN OF ty_request,
                 corx   TYPE i,
                 cory   TYPE i,
                 base64 TYPE string,
                 billingDocument TYPE vbeln,
               END OF ty_request.
        DATA : requestData TYPE ty_request.
        xco_cp_json=>data->from_string( request->get_text(  ) )->write_to( REF #( requestData ) ).

        SELECT SINGLE FROM zr_integration_tab
        FIELDS Intgpath
        WHERE Intgmodule = 'TAX-PRINT-URL'
        INTO @DATA(irn_url).

        TRY.
            DATA(dest2) = cl_http_destination_provider=>create_by_url( |{ irn_url }?x={ requestData-corx }&y={ requestData-cory }| ).
            lv_client2 = cl_web_http_client_manager=>create_by_http_destination( dest2 ).

          CATCH cx_static_check INTO DATA(lv_cx_static_check2).
            response->set_status( i_code = 500 i_reason = 'Internal Server Error' ).
            response->set_text( |Destination creation failed: { lv_cx_static_check2->get_longtext( ) }| ).
            RETURN.
        ENDTRY.

        requestData-billingdocument = |{ requestData-billingdocument ALPHA = IN }|.

        SELECT SINGLE FROM I_BillingDocumentItem as a
          INNER JOIN ztable_plant as b on a~Plant = b~plant_code and a~CompanyCode = b~comp_code
          FIELDS b~gstin_no
          WHERE a~BillingDocument = @requestData-billingdocument
          INTO @DATA(lv_gstin).


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
           i_value = CONV string( lv_gstin )
         ).



        TYPES: BEGIN OF ty_item_list,
                 base64String TYPE string,
               END OF ty_item_list.

        DATA : wa_json TYPE ty_item_list.

        wa_json-base64string =  requestData-base64.

        DATA:json TYPE REF TO if_xco_cp_json_data.

        xco_cp_json=>data->from_abap(
          EXPORTING
            ia_abap      = wa_json
          RECEIVING
            ro_json_data = json   ).
        json->to_string(
          RECEIVING
            rv_string =   DATA(lv_string) ).

        REPLACE ALL OCCURRENCES OF '"BASE64STRING"' IN lv_string WITH '"base64String"'.

        req4->set_text( lv_string ).
        req4->set_content_type( 'application/json' ).
        DATA url_response2 TYPE string.

        TRY.
            DATA(resp) = lv_client2->execute( if_web_http_client=>post ).


            TYPES: BEGIN OF ty_response,
                     error_code    TYPE string,
                     error_message TYPE string,
                     error_source  TYPE string,
                   END OF ty_response.
            DATA: responseDataError TYPE ty_response,
                  binaryresponse    TYPE string.



*            TRY.
*                xco_cp_json=>data->from_string( resp->get_text( ) )->write_to( REF #( responseDataError ) ).
*
*                IF responseDataError-error_code IS NOT INITIAL.
*                  response->set_status( i_code = 400 i_reason = 'Bad Request' ).
*                  response->set_text( |Error: { responseDataError-error_message }| ).
*                  RETURN.
*                ENDIF.
*
*
*                binaryresponse = resp->get_binary( ).
*                response->set_content_type( 'application/pdf' ).
*                response->set_text( binaryresponse ).
*
*              CATCH cx_root INTO DATA(lx_root).
*                response->set_status( i_code = 500 i_reason = 'Internal Server Error' ).
*                response->set_text(  |General Error: { lx_root->get_text( ) }| ).
*                RETURN.
*            ENDTRY.

            binaryresponse = resp->get_binary( ).
            response->set_content_type( 'application/pdf' ).
            response->set_text( binaryresponse ).
            RETURN.
          CATCH cx_web_http_client_error INTO DATA(lv_error_response2).
            response->set_status( i_code = 500 i_reason = 'Internal Server Error' ).
            response->set_text( |API request failed: { lv_error_response2->get_longtext( ) }| ).
        ENDTRY.

    ENDCASE.

  ENDMETHOD.


   METHOD pattern_catch.
  DATA: lv_row     TYPE i,
        lt_pattern TYPE STANDARD TABLE OF i WITH EMPTY KEY,
        lv_result  TYPE i.

  lt_pattern = VALUE #( ( 410 ) ( 410 ) ( 500 ) ( 500 ) ( 500 ) ( 620 ) ( 620 ) ( 620 ) ( 620 ) ).

  " You need to make sure 'row' is a parameter of the method
  lv_row = row.

  " Using modulus to get pattern index
  DATA(idx) = ( ( lv_row - 1 ) MOD lines( lt_pattern ) ).
  lv_result = lt_pattern[ idx + 1 ].

  " Set return value
  result = lv_result.
  RETURN result.
  ENDMETHOD.
ENDCLASS.
