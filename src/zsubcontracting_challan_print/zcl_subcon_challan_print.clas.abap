CLASS zcl_subcon_challan_print DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-DATA : access_token TYPE string .
    CLASS-DATA : xml_file TYPE string .
    CLASS-METHODS :
      create_client
        IMPORTING url           TYPE string
        RETURNING VALUE(result) TYPE REF TO if_web_http_client
        RAISING   cx_static_check ,

      read_posts
        IMPORTING
                  lv_billingno          TYPE string
                  lv_billingtype         TYPE string
                  lv_org        TYPE string
        RETURNING VALUE(result12)       TYPE string
        RAISING   cx_static_check .

    INTERFACES if_oo_adt_classrun .

  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS lv1_url TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'.
    CONSTANTS lv2_url TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'.
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'ZSD_JOB_WORK/ZSD_JOB_WORK'.

ENDCLASS.



CLASS ZCL_SUBCON_CHALLAN_PRINT IMPLEMENTATION.


  METHOD create_client.
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
  ENDMETHOD.


  METHOD read_posts.





    "Build XML
    DATA(lv_xml) = |<Form>| &&
                    |<Header>| &&
*                    |<CompanyCode>{ lv_header-CompanyCode }</CompanyCode>| &&
*                    |<CompanyCodeName>{ lv_header-CompanyCodeName }</CompanyCodeName>| &&
*                    |<CompanyAdress>{ PLANT_adress }</CompanyAdress>| &&
*                    |<Email>{ lv_header-email }</Email>| &&
*                    |<Phone>{ lv_header-mob_no }</Phone>| &&
*                    |<Pan_no>{ lv_header-pan_no }</Pan_no>| &&
*                    |<gstin>{ lv_header-gstin_no }</gstin>| &&
*                    |<Cin>{ lv_header-cin_no }</Cin>| &&
*                    |<fssai_no>{ lv_header-fssai_no }</fssai_no>| &&
                    |</Header>| &&
                    |<Item>|.

    "Add Line Items to XML
*    LOOP AT it_FINAL INTO wa_FINAL.
*      DATA(lv_xml2) = |<Line_Item>| &&
**       |<SRNO>{ wa_FINAL-srno }</SRNO>| &&
**       |<Description>{ wa_FINAL-desc }</Description>| &&
**       |<SAC_CODE>{ wa_FINAL-sac_code }</SAC_CODE>| &&
**       |<taxable_value>{ wa_FINAL-taxable_value }</taxable_value>| &&
*       |</Line_Item>|.
*
*      CONCATENATE lv_xml lv_xml2  INTO lv_xml.
*    ENDLOOP.

    CONCATENATE lv_xml '</Item>' '</Form>' INTO lv_xml.

    "Clean XML
    REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'and'.
    REPLACE ALL OCCURRENCES OF '<=' IN lv_xml WITH 'let'.
    REPLACE ALL OCCURRENCES OF '>=' IN lv_xml WITH 'get'.
    REPLACE ALL OCCURRENCES OF ',,' IN lv_xml WITH ','.
    REPLACE ALL OCCURRENCES OF ',,,' IN lv_xml WITH space.

    "Generate PDF
    CALL METHOD zcl_ads_print=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).

  ENDMETHOD.
ENDCLASS.
