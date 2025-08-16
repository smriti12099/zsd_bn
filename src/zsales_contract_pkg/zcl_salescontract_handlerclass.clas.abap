CLASS zcl_salescontract_handlerclass DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS: get_html RETURNING VALUE(html) TYPE string.
    METHODS: post_html
      IMPORTING
                SALES_CONTRACT     TYPE string
      RETURNING VALUE(html) TYPE string.

    CLASS-DATA url TYPE string.
ENDCLASS.



CLASS ZCL_SALESCONTRACT_HANDLERCLASS IMPLEMENTATION.


  METHOD get_html.    "Response HTML for GET request

    html = |<html> \n| &&
  |<body> \n| &&
  |<title>Inspection Lot </title> \n| &&
  |<form action="{ url }" method="POST">\n| &&
  |<H2> BN Sales Contract Print</H2> \n| &&
  |<label for="fname">Sales Contract :  </label> \n| &&
  |<input type="text" id="SALES_CONTRACT" name="SALES_CONTRACT" required ><br><br> \n| &&
  |<input type="submit" value="Submit"> \n| &&
  |</form> | &&
  |</body> \n| &&
  |</html> | .

  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.

    "0500000010  0002000004  4500000001 0500000002/3/4 4500000004 0600000004/5
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
    req_uri = '/sap/bc/http/sap/ZHTTP_SD_SALESCONTRACT_SRV?sap-client=080'.
    url = |{ req_proto }://{ req_host }{ req_uri }client={ symandt }|.


    CASE request->get_method( ).

      WHEN CONV string( if_web_http_client=>get ).

        response->set_text( get_html( ) ).

      WHEN CONV string( if_web_http_client=>post ).

        DATA(v_lot) = request->get_form_field( `SALES_CONTRACT` ).

         DATA : var1 TYPE I_salescontract-SalesContract.
        DATA: v_lot2 TYPE string.

         var1 = v_lot.
         var1 =   |{ |{ var1 ALPHA = OUT }| ALPHA = IN }| .
         v_lot2 = v_lot.
         v_lot2 = var1.


        SELECT SINGLE FROM i_salescontract
        FIELDS SalesContract WHERE SalesContract = @v_lot2
        INTO @DATA(lv_lot).

        IF lv_lot IS NOT INITIAL.

          TRY.
              DATA(pdf) = zcl_salescontract_drv=>read_posts( SALES_CONTRACT = v_lot2 ).
    if  pdf = 'ERROR'.
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
          response->set_text( ' Sales Contract no. does not exist.' ).
        ENDIF.

    ENDCASE.



  ENDMETHOD.


  METHOD post_html.

    html = |<html> \n| &&
   |<body> \n| &&
   |<title> Sales Contract Number </title> \n| &&
   |<form action="{ url }" method="Get">\n| &&
   |<H2>Sales Contract Print Success </H2> \n| &&
   |<input type="submit" value="Go Back"> \n| &&
   |</form> | &&
   |</body> \n| &&
   |</html> | .
  ENDMETHOD.
ENDCLASS.
