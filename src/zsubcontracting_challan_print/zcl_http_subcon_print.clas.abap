CLASS zcl_http_subcon_print DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS: get_html RETURNING VALUE(html) TYPE string.
    METHODS: post_html IMPORTING
                                 lv_billingno   TYPE string
                                 lv_billingtype TYPE string
                                 lv_org         TYPE string
                       RETURNING VALUE(html)    TYPE string.

    CLASS-DATA url TYPE string.

ENDCLASS.



CLASS ZCL_HTTP_SUBCON_PRINT IMPLEMENTATION.


  METHOD get_html.    "Response HTML for GET request

    html = |<html> \n| &&
  |<body> \n| &&
  |<title>Inspection Lot </title> \n| &&
  |<form action="{ url }" method="POST">\n| &&
  |<H2> BN Subcontracting Challan Print</H2> \n| &&
  |<label for="fname">SubContract :  </label> \n| &&
  |<input type="text" id="lv_billingno" name="lv_billingno" required ><br><br> \n| &&
  |<input type="submit" value="Submit"> \n| &&
  |</form> | &&
  |</body> \n| &&
  |</html> | .

  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.

    DATA(req) = request->get_form_fields(  ).
    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).
    DATA(cookies)  = request->get_cookies(  ) .

    DATA req_host TYPE string.
    DATA req_proto TYPE string.
    DATA req_uri TYPE string.

    req_host = request->get_header_field( i_name = 'Host' ).
    req_proto = request->get_header_field( i_name = 'X-Forwarded-Proto' ).
    IF req_proto IS INITIAL.
      req_proto = 'https'.
    ENDIF.
*     req_uri = request->get_request_uri( ).
    DATA(symandt) = sy-mandt.
    req_uri = '/sap/bc/http/sap/ZHTTP_SUBCON_PRINT?sap-client=080'.
    url = |{ req_proto }://{ req_host }{ req_uri }client={ symandt }|.


    CASE request->get_method( ).

      WHEN CONV string( if_web_http_client=>get ).

        response->set_text( get_html( ) ).

      WHEN CONV string( if_web_http_client=>post ).

*        DATA(billno) = request->get_form_field( `lv_billingno` ).
        DATA(billtype) = request->get_form_field( `lv_billingtype` ).
*        DATA(org) = request->get_form_field( `lv_org` ).

        DATA(printname) = VALUE #( req[ name = 'print' ]-value OPTIONAL ).
        DATA(cc) = request->get_form_field( `companycode` ).
        DATA(doc) = request->get_form_field( `document` ).
        DATA(getdocument) = VALUE #( req[ name = 'doc' ]-value OPTIONAL ).
        DATA(getcompanycode) = VALUE #( req[ name = 'cc' ]-value OPTIONAL ).

        DATA : var1 TYPE I_salescontract-SalesContract.
        DATA: v_lot2 TYPE string.

        var1 = doc.
        var1 =   |{ |{ var1 ALPHA = OUT }| ALPHA = IN }| .
        v_lot2 = doc.
        v_lot2 = var1.


        SELECT SINGLE FROM I_BillingDocument
        FIELDS BillingDocument WHERE BillingDocument = @v_lot2
        INTO @DATA(lv_billno).

        IF lv_billno IS NOT INITIAL.

          TRY.
              DATA(pdf) = zcl_subcon_challan_print=>read_posts( lv_billingno = doc lv_billingtype = billtype lv_org = cc ).
              IF  pdf = 'ERROR'.
                response->set_text( 'Error to show PDF something Problem' ).

*            response->set_text( pdf ).
              ELSE.
                DATA(html) = |<html> | &&
                               |<body> | &&
                                 | <iframe src="data:application/pdf;base64,{ pdf }" width="100%" height="100%"></iframe>| &&
                               | </body> | &&
                             | </html>|.

                response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
                response->set_text( pdf )."line
              ENDIF.
            CATCH cx_static_check INTO DATA(er).
              response->set_text( er->get_longtext(  ) ).
          ENDTRY.
        ELSE.
          response->set_text( ' Billing Number does not exist.' ).
        ENDIF.

    ENDCASE.



  ENDMETHOD.


  METHOD post_html.

    html = |<html> \n| &&
   |<body> \n| &&
   |<title> SUbcontract Challan Print </title> \n| &&
   |<form action="{ url }" method="Get">\n| &&
   |<H2>Subcontract Print Success </H2> \n| &&
   |<input type="submit" value="Go Back"> \n| &&
   |</form> | &&
   |</body> \n| &&
   |</html> | .
  ENDMETHOD.
ENDCLASS.
