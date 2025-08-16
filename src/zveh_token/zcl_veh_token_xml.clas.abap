CLASS zcl_veh_token_xml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

*    INTERFACES if_oo_adt_classrun .
    CLASS-DATA : access_token TYPE string .
    CLASS-DATA : xml_file TYPE string .
    TYPES :
      BEGIN OF struct,
        xdp_template TYPE string,
        xml_data     TYPE string,
        form_type    TYPE string,
        form_locale  TYPE string,
        tagged_pdf   TYPE string,
        embed_font   TYPE string,
      END OF struct."


    CLASS-METHODS :
      create_client
        IMPORTING url           TYPE string
        RETURNING VALUE(result) TYPE REF TO if_web_http_client
        RAISING   cx_static_check ,

      read_posts
        IMPORTING
                  lv_gateentry    TYPE string
*                  lv_fiscalyear         TYPE string
*                  lv_Companycode        TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .

  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zvehicle_token/zvehicle_token'."'zpo/zpo_v2'."
*    CONSTANTS lc_template_name TYPE 'HDFC_CHECK/HDFC_MULTI_FINAL_CHECK'.

ENDCLASS.



CLASS ZCL_VEH_TOKEN_XML IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts .

*    TYPES : BEGIN OF ty_st,
*              bill_no      TYPE i_accountingdocumentjournal-Clearingaccountingdocument,
*              gross_amt    TYPE i_accountingdocumentjournal-Debitamountintranscrcy,
*              pay_prev     TYPE i_accountingdocumentjournal-Debitamountintranscrcy,
*              tds          TYPE i_accountingdocumentjournal-Creditamountintranscrcy,
*              net_amt      TYPE i_accountingdocumentjournal-Creditamountintranscrcy,
*              invoice_date TYPE i_accountingdocumentjournal-PostingDate,
*              invoice_no   TYPE i_accountingdocumentjournal-Accountingdocument,
**      total_gross_amt type i_accountingdocumentjournal-Debitamountintranscrcy,
*
*            END OF ty_st.

    SELECT  SINGLE FROM zgateentryheader
    FIELDS gateentryno, driverlicenseno, drivername, transportmode, gateindate, vehiclergnno,
    transportername, driverno
    WHERE gateentryno = @lv_gateentry
    INTO @DATA(lv_final).

    DATA(lv_xml) = |<Form>| &&
                   |<TokenNo>{ lv_final-gateentryno }</TokenNo>| &&
                   |<TransType>{ ' ' }</TransType>| &&
                   |<VendorCity>{ ' ' }</VendorCity>| &&
                   |<DriverLic>{ lv_final-driverlicenseno }</DriverLic>| &&
                   |<DriverName>{ lv_final-drivername }</DriverName>| &&
                   |<DocumentsCollected>{ ' ' }</DocumentsCollected>| &&
                   |<DocumentsCollected1>{ ' ' }</DocumentsCollected1>| &&
                   |<ModeOfTransport>{ lv_final-transportmode }</ModeOfTransport>| &&
                   |<GateDateTime>{ lv_final-gateindate }</GateDateTime>| &&
                   |<DailySeqNo>{ ' ' }</DailySeqNo>| &&
                   |<VehicleRegnNo>{ lv_final-vehiclergnno }</VehicleRegnNo>| &&
                   |<Transporter>{ lv_final-transportername }</Transporter>| &&
                   |<DriverMob>{ lv_final-driverno }</DriverMob>| &&
                   |<SecurityOff>{ ' ' }</SecurityOff>| &&
                   |<Temp1>{ ' ' }</Temp1>| &&
                   |<Temp2>{ ' ' }</Temp2>| &&
                   |<Temp3>{ ' ' }</Temp3>| &&
                   |</Form>|.




    CALL METHOD zcl_ads_print=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).

  ENDMETHOD.
ENDCLASS.
