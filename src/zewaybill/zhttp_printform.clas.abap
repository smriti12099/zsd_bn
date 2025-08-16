CLASS zhttp_printform DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.


    CLASS-METHODS printDistributor
     IMPORTING
        cc type string
        printname type string
        doc type string
     RETURNING VALUE(pdf) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA url TYPE string.

ENDCLASS.



CLASS ZHTTP_PRINTFORM IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

    DATA(req) = request->get_form_fields(  ).
    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).
    DATA(cookies)  = request->get_cookies(  ) .

    DATA req_host TYPE string.
    DATA req_proto TYPE string.
*12.03    DATA req_uri TYPE string.
    DATA json TYPE string .

    req_host = request->get_header_field( i_name = 'Host' ).
    req_proto = request->get_header_field( i_name = 'X-Forwarded-Proto' ).
    IF req_proto IS INITIAL.
      req_proto = 'https'.
    ENDIF.
*     req_uri = request->get_request_uri( ).
    DATA(symandt) = sy-mandt.
*12.03    req_uri = '/sap/bc/http/sap/ZHTTP_SERVICE?sap-client=080'.
*12.03    url = |{ req_proto }://{ req_host }{ req_uri }client={ symandt }|.
    DATA(printname) = VALUE #( req[ name = 'print' ]-value OPTIONAL ).
    DATA(cc) = request->get_form_field( `companycode` ).
    DATA(doc) = request->get_form_field( `document` ).
    DATA(getdocument) = VALUE #( req[ name = 'doc' ]-value OPTIONAL ).
    DATA(getcompanycode) = VALUE #( req[ name = 'cc' ]-value OPTIONAL ).


    CASE request->get_method( ).

      WHEN CONV string( if_web_http_client=>get ).
        IF printname = 'dom1' OR printname = 'dom2' OR printname = 'dom3'
        OR printname = 'sto1' OR printname = 'sto2' OR printname = 'sto3'
        OR printname = 'expo1' OR printname = 'expo2' OR printname = 'expo3'
        OR printname = 'dnwith1' OR printname = 'dnwith2' OR printname = 'dnwith3'
        OR printname = 'foc' OR printname = 'foc2' OR printname = 'foc3'
        OR printname = 'cndn1' OR printname = 'cndn2' OR printname = 'cndn3'
        OR printname = 'cnwith1' OR printname = 'cnwith2' OR printname = 'cnwith3'
        OR printname = 'os1' OR printname = 'os2' OR printname = 'os3'
        OR printname = 'gt1' OR printname = 'gt2' OR printname = 'gt3'
        OR printname = 'ot1' OR printname = 'ot2' OR printname = 'ot3'
        OR printname = 'bsto1' OR printname = 'bsto2' OR printname = 'bsto3'
        OR printname = 'ts1' OR printname = 'ts2' OR printname = 'ts3'
        OR printname = 'bfoc1' OR printname = 'bfoc2' OR printname = 'bfoc3'  " OR printname = 'bcn' .
        OR printname = 'nut1' OR printname = 'nut2' OR printname = 'nut3'
        OR printname = 'dc1' OR printname = 'dc2' OR printname = 'dc3'.
          SELECT SINGLE FROM I_BillingDocument AS a
                    FIELDS a~DistributionChannel,a~BillingDocumentType
                    WHERE a~BillingDocument = @getdocument AND a~CompanyCode = @getcompanycode
                    INTO @DATA(wa_check).
          DATA: getresult TYPE string.
          getresult = wa_check-DistributionChannel.
        ENDIF.
*        IF printname = 'cndn'.
*        SELECT SINGLE FROM I_BillingDocument AS a
*                    FIELDS a~DistributionChannel,a~BillingDocumentType
*                    WHERE a~BillingDocument = @getdocument and a~CompanyCode = @getcompanycode
*                    INTO @wa_check.
*          getresult = wa_check-BillingDocumentType.
*        ENDIF.

        response->set_text( getresult ).

      WHEN CONV string( if_web_http_client=>post ).


              response->set_header_field( i_name = 'Content-Type' i_value = 'text/html' ).
              response->set_text( printdistributor( doc = doc cc = cc printname = printname ) ).


*               IF printname = 'bcn'.
*                pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
*              ENDIF.

*                SELECT SINGLE FROM i_billingdocument AS a
*                FIELDS a~FiscalYear,a~AccountingDocument
*                WHERE a~BillingDocument = @doc AND a~CompanyCode = @cc
*                INTO @DATA(wa_doc).
*
*
*
*
*
*                SELECT SINGLE FROM i_accountingdocumentjournal WITH PRIVILEGED ACCESS AS a
*                 FIELDS accountingdocument WHERE a~accountingdocument = @wa_doc-AccountingDocument AND a~FiscalYear = @wa_doc-FiscalYear AND a~CompanyCode = @cc
*                 INTO @DATA(lv_ac).
*
*                DATA: ac TYPE string.
*                DATA: fs TYPE string.
*                ac = wa_doc-AccountingDocument.
*                fs = wa_doc-FiscalYear.
*                pdf = zcl_ficndn_inv=>read_posts( accounting_no = ac  Company_code = cc fiscal_year = fs ) .
*              ENDIF.



    ENDCASE.


  ENDMETHOD.


  METHOD printDistributor.

    SELECT SINGLE * FROM I_BillingDocument AS a
    WHERE a~BillingDocument = @doc AND a~CompanyCode = @cc
    INTO @DATA(lv_invoice).

    IF lv_invoice IS NOT INITIAL.
      TRY.
          IF printname = 'dom1'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'dom2'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'dom3'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'sto1'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'sto2'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'sto3'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.

          IF printname = 'expo1'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'expo2'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'expo3'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.

          IF printname = 'dnwith1'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'dnwith2'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'dnwith3'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.

          IF printname = 'foc'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'foc2'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'foc3'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.

          IF printname = 'cndn1'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'cndn2'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'cndn3'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.

          IF printname = 'cnwith1'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'cnwith2'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'cnwith3'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.

          IF printname = 'os1'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'os2'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'os3'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.

          IF printname = 'gt1'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'gt2'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'gt3'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.

          IF printname = 'ot1'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'ot2'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'ot3'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.

          IF printname = 'bsto1'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'bsto2'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'bsto3'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.


          IF printname = 'ts1'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'ts2'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'ts3'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.

          IF printname = 'bfoc1'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'bfoc2'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'bfoc3'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.

          IF printname = 'nut1'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'nut2'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'nut3'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.

          IF printname = 'dc1'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'dc2'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF printname = 'dc3'.
            pdf = zcl_xml_irn_bn=>read_posts( bill_doc = doc printname = printname ) .
          ENDIF.
          IF  pdf = 'ERROR'.
            pdf = 'Error to show PDF something Problem'.

          ENDIF.
        CATCH cx_static_check INTO DATA(er).
          pdf =  er->get_longtext(  ) .
      ENDTRY.
    ELSE.
      pdf = 'Invoice No does not exist.' .
    ENDIF.

  ENDMETHOD.
ENDCLASS.
