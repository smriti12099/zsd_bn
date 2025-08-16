class ZCL_DSC_TAXINVPRINT definition
  public
  create public .

public section.
  DATA :result12 TYPE string.

  interfaces IF_HTTP_SERVICE_EXTENSION .
  METHODS pattern_catch IMPORTING row TYPE i RETURNING VALUE(result) type i.
protected section.
private section.
  CLASS-DATA url TYPE string.
ENDCLASS.



CLASS ZCL_DSC_TAXINVPRINT IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    DATA(req) = request->get_form_fields(  ).
    DATA(printname) = VALUE #( req[ name = 'print' ]-value OPTIONAL ).
    DATA(cc) = request->get_form_field( `companycode` ).
    DATA(doc) = request->get_form_field( `document` ).
    DATA(getdocument) = VALUE #( req[ name = 'doc' ]-value OPTIONAL ).
    DATA(getcompanycode) = VALUE #( req[ name = 'cc' ]-value OPTIONAL ).




    DATA token_url TYPE string .
    DATA lv_token TYPE string.
    DATA lv_client TYPE REF TO if_web_http_client.
    DATA req1 TYPE REF TO if_web_http_client.
    DATA irn_url TYPE string .
    DATA lv_client2 TYPE REF TO if_web_http_client.
    DATA req3 TYPE REF TO if_web_http_client.



    SELECT  SINGLE FROM ztable_plant AS b
    FIELDS b~gstin_no
    WHERE b~comp_code =  @cc INTO @DATA(selectedGST).
    DATA yaxis TYPE i.

*    SELECT COUNT( b~billingdocumentitem ) AS lines FROM I_billingdocument AS a
*    INNER JOIN i_billingdocumentitem AS b ON
*    a~billingdocument = b~billingdocument
*    WHERE ( a~BillingDocument = @doc )
*    GROUP BY a~billingdocument INTO @yaxis.
*    ENDSELECT.
*    DATA(y) =  pattern_catch( row = yaxis ).
*
*
*
*    SELECT SINGLE FROM zr_integration_tab
*    FIELDS Intgpath
*    WHERE Intgmodule = 'TAX-PRINT-URL'
*    INTO @irn_url.
*
*
*    TRY.
*        DATA(dest2) = cl_http_destination_provider=>create_by_url( |{ irn_url }?x=415&y={ y }| ).
*        lv_client2 = cl_web_http_client_manager=>create_by_http_destination( dest2 ).
*
*      CATCH cx_static_check INTO DATA(lv_cx_static_check2).
*        response->set_status( i_code = 500 i_reason = 'Internal Server Error' ).
*        response->set_text( |Destination creation failed: { lv_cx_static_check2->get_longtext( ) }| ).
*        RETURN.
*    ENDTRY.

*
*    DATA(req4) = lv_client2->get_http_request( ).
*
*    SELECT SINGLE FROM zr_integration_tab
*     FIELDS Intgpath
*     WHERE Intgmodule = 'IRN-HEAD'
*     INTO @DATA(subscription).
*
*    SPLIT subscription  AT ':' INTO DATA(head1name) DATA(head1val).
*
*    req4->set_header_field(
*       i_name  = head1name
*       i_value = head1val
*     ).
*    req4->set_header_field(
*       i_name  = 'gstin'
*       i_value = CONV string( '07AAFCD5862R007' )
*     ).
*
*
*
*    TYPES: BEGIN OF ty_item_list,
*             base64String TYPE string,
*           END OF ty_item_list.
*
*    DATA : wa_json TYPE ty_item_list.

  response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
        response->set_text( zhttp_printform=>printdistributor( doc = doc cc = cc printname = printname ) ).

*    res  .

*    DATA:json TYPE REF TO if_xco_cp_json_data.
*
*    xco_cp_json=>data->from_abap(
*      EXPORTING
*        ia_abap      = wa_json
*      RECEIVING
*        ro_json_data = json   ).
*    json->to_string(
*      RECEIVING
*        rv_string =   DATA(lv_string) ).
*
*    REPLACE ALL OCCURRENCES OF '"BASE64STRING"' IN lv_string WITH '"base64String"'.
*
*    req4->set_text( lv_string ).
*    req4->set_content_type( 'application/json' ).
*    DATA url_response2 TYPE string.
*
*    TRY.
*        url_response2 = lv_client2->execute( if_web_http_client=>post )->get_binary( ).
*        response->set_content_type( 'application/pdf' ).
*        response->set_text( url_response2 ).
*        RETURN.
*      CATCH cx_web_http_client_error INTO DATA(lv_error_response2).
*        response->set_status( i_code = 500 i_reason = 'Internal Server Error' ).
*        response->set_text( |API request failed: { lv_error_response2->get_longtext( ) }| ).
*    ENDTRY.
*


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
