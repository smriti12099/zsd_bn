class ZDSC_COMMONPRINT definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .
protected section.
private section.

CLASS-DATA url TYPE string.

ENDCLASS.



CLASS ZDSC_COMMONPRINT IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    CASE request->get_method( ).
      WHEN CONV string( if_web_http_client=>post ).

        DATA(req) = request->get_form_fields(  ).
        DATA(printname) = VALUE #( req[ name = 'print' ]-value OPTIONAL ).
        DATA(cc) = request->get_form_field( `companycode` ).
        DATA(doc) = request->get_form_field( `document` ).

        response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
        response->set_text( zhttp_printform=>printdistributor( doc = doc cc = cc printname = printname ) ).

    ENDCASE.


  ENDMETHOD.
ENDCLASS.
