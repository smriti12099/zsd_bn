CLASS zcl_veh_token_http DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS: get_html RETURNING VALUE(html) TYPE string.
    METHODS: post_html
      IMPORTING
                lv_gateentry TYPE string
*                lv_fiscalyear type string
*                lv_Companycode type string

      RETURNING VALUE(html)  TYPE string.

    CLASS-DATA url TYPE string.

ENDCLASS.



CLASS ZCL_VEH_TOKEN_HTTP IMPLEMENTATION.


  METHOD get_html.    "Response HTML for GET request



*    html = |<html> \n| &&
* |<body> \n| &&
* |<title>Sales Order   </title> \n| &&
* |<form action="{ url }" method="POST">\n| &&
* |<H2>SO Print</H2> \n| &&
* |<label for="fname">Sales Order Number:  </label> \n| &&
* |<input type="text" id="salesorderno" name="lv_gateentry" required ><br><br> \n| &&
* |<input type="submit" value="Submit"> \n| &&
* |</form> | &&
* |</body> \n| &&
* |</html> | .

    html = |<html> \n| &&
  |<body> \n| &&
  |<title>VEHICLE REPORTING TOKEN</title> \n| &&
*  |<form action="{ url }" method="POST">\n| &&
  |<form action="/sap/bc/http/sap/ZVEH_TOKEN_HTTP?sap-client=080" method="POST">\n| &&
  |<H2>BN Print</H2> \n| &&
  |<label for="fname">Gate Entry </label> \n| &&
  |<input type="text" id="lv_gateentry" name="lv_gateentry" required ><br><br> \n| &&
*  |<label for="fname">Fiscal Year</label> \n| &&
*  |<input type="text" id="lv_fiscalyear" name="lv_fiscalyear" required ><br><br> \n| &&
*   |<label for="fname">Company Code</label> \n| &&
*  |<input type="text" id="lv_Companycode" name="lv_Companycode" required ><br><br> \n| &&
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
    DATA json TYPE string .

    req_host = request->get_header_field( i_name = 'Host' ).
    req_proto = request->get_header_field( i_name = 'X-Forwarded-Proto' ).
    IF req_proto IS INITIAL.
      req_proto = 'https'.
    ENDIF.
*     req_uri = request->get_request_uri( ).
    DATA(symandt) = sy-mandt.
    req_uri = '/sap/bc/http/sap/ZVEH_TOKEN_HTTP?sap-client=080'.
    url = |{ req_proto }://{ req_host }{ req_uri }client={ symandt }|.


    CASE request->get_method( ).

      WHEN CONV string( if_web_http_client=>get ).

        response->set_text( get_html( ) ).

      WHEN CONV string( if_web_http_client=>post ).

        DATA(gee) = request->get_form_field( `lv_gateentry` ).
*        DATA(yr) = request->get_form_field( `lv_fiscalyear` ).
*        DATA(cc) = request->get_form_field( `lv_Companycode` ).

*        TRANSLATE cc to UPPER CASE.


        SELECT SINGLE FROM zgateentryheader WITH PRIVILEGED ACCESS
        FIELDS gateentryno WHERE gateentryno = @gee "and FiscalYear = @yr and CompanyCode = @cc
        INTO @DATA(lv_ge).

        IF lv_ge IS NOT INITIAL.

          TRY.
              DATA(pdf) = zcl_veh_token_xml=>read_posts( lv_gateentry = gee  ) .

*            response->set_text( pdf ).

*              DATA(html) = |{ pdf }|.
              DATA(html) = |<html> | &&
                                          |<body> | &&
                                            | <iframe src="data:application/pdf;base64,{ pdf }" width="100%" height="100%"></iframe>| &&
                                          | </body> | &&
                                        | </html>|.



              response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
              response->set_text( html ).
            CATCH cx_static_check INTO DATA(er).

              html = |Gate Entry Not Exits: { er->get_longtext( ) }|.

          ENDTRY.

        ELSE.

          html = |Gate Entry Not Found|.

        ENDIF.

    ENDCASE.

  ENDMETHOD.


  METHOD post_html.

    html = |<html> \n| &&
   |<body> \n| &&
   |<title>Token Print</title> \n| &&
   |<form action="{ url }" method="Get">\n| &&
   |<H2>BN print</H2> \n| &&
   |<input type="submit" value="Go Back"> \n| &&
   |</form> | &&
   |</body> \n| &&
   |</html> | .
  ENDMETHOD.
ENDCLASS.
