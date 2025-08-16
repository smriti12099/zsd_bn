CLASS zclass_so_driver DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*    INTERFACES if_oo_adt_classrun.
    CLASS-DATA : access_token TYPE string .
    CLASS-DATA : xml_file TYPE string .
    CLASS-DATA : var1 TYPE vbeln.
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
        IMPORTING salesorderno1 TYPE string
        RETURNING VALUE(result12)  TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.
  PRIVATE SECTION.


    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://bn-dev-jpiuus30.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zsd_salesorder_print/zsd_salesorder_print'."'z/zpo_v2'."
*    CONSTANTS lc_template_name TYPE 'HDFC_CHECK/HDFC_MULTI_FINAL_CHECK'.
ENDCLASS.



CLASS ZCLASS_SO_DRIVER IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts.
    var1 = salesorderno1.
    var1 =   |{ |{ var1 ALPHA = OUT }| ALPHA = IN }| .
    data(salesorderno) = var1.

*    out->write( 'sk' ).
    SELECT SINGLE
     a~salesorder ,
     a~billingcompanycode ,
     a~creationdate,
     a~referencesddocument,
     a~salesorganization,
     a~INCOTERMSCLASSIFICATION,
     a~INCOTERMSLOCATION1,
     a~SALESDISTRICT,
     b~companycodename ,
     c~plant ,
     e~streetname,
     e~cityname,
     e~postalcode,
     e~region,
     e~country,
     f~emailaddress,
     d~plantcustomer,
     d~plantname,
     e~taxnumber3 ,
     e~telephonenumber1,
     h~confirmeddeliverydate,
     i~regionname,
     j~countryname,
     k~EMAIL
*     i~addressid
     FROM i_salesorder AS a
     LEFT JOIN i_companycode AS b ON a~billingcompanycode = b~companycode
     LEFT JOIN i_salesorderitem AS c ON a~salesorder = c~salesorder
     LEFT JOIN i_plant AS d ON c~plant = d~plant
*     LEFT JOIN i_address_2 AS e ON d~addressid = e~addressid
     LEFT JOIN i_customer AS e ON  d~plantcustomer = e~customer
     LEFT JOIN i_addressemailaddress_2 with PRIVILEGED ACCESS AS f ON d~addressid = f~addressid
     left join ztable_plant as k on c~Plant = k~plant_code
*     LEFT JOIN i_customer AS g ON d~plantcustomer = g~customer
     LEFT JOIN i_salesorderscheduleline AS h ON a~salesorder = h~salesorder
     LEFT JOIN i_regiontext AS i ON e~region = i~region AND e~country = i~country
     LEFT JOIN i_countrytext as j ON e~Country = j~country
     WHERE a~salesorder = @salesorderno AND h~confirmeddeliverydate IS NOT INITIAL
     INTO  @DATA(wa_head).

*    out->write( wa_head ).

    DATA : cin TYPE string.

    IF  wa_head-salesorganization EQ 'BNAL'.

      cin = 'U01403DL2011PLC301179'.
    ELSEIF wa_head-salesorganization EQ 'SBPL'.
      cin = 'U15490UP2020PTC128250'.
    ELSEIF wa_head-salesorganization EQ 'A1AG'.
      cin = 'U51909DL2020PTC366017'.
    ELSEIF wa_head-salesorganization EQ 'EPIL'.
      cin = 'U15549DL2022PLC402614'.

    ENDIF.



    DATA: comp_add1 TYPE string,
          comp_add2 TYPE string.
    DATA: pan        TYPE string,
          state_code TYPE string.

    comp_add1 = wa_head-streetname.

*     if comp_add1  is not INITIAL.
*     CONCATENATE comp_add1  ','  into comp_add1 SEPARATED BY space.
*     endif.
*
      if wa_head-cityname  is not INITIAL.
    CONCATENATE comp_add1  wa_head-cityname INTO comp_add1 SEPARATED BY space.
    endif.

    if wa_head-RegionName is not initial.
    CONCATENATE  comp_add2  wa_head-RegionName  INTO comp_add2 SEPARATED BY space.
    endif.

    if wa_head-CountryName is not initial.
    CONCATENATE comp_add2 ',' wa_head-CountryName INTO comp_add2 SEPARATED BY space.
    endif.


    if wa_head-PostalCode is not initial.
    CONCATENATE comp_add2 ',' wa_head-postalcode INTO comp_add2 SEPARATED BY space.
    endif.

    pan = wa_head-taxnumber3+2(10).
    state_code = wa_head-taxnumber3+0(2).

    SELECT SINGLE
    a~salesorder,
     b~fullname,
     b~referencebusinesspartner,
     c~telephonenumber1,
     c~addressid,
     d~emailaddress
    FROM
    i_salesorder AS a
    LEFT JOIN i_salesorderpartner AS b ON b~salesorder = a~salesorder
    AND b~partnerfunction = 'AP'
    LEFT JOIN i_customer AS c ON b~referencebusinesspartner = c~customer
    LEFT JOIN i_addressemailaddress_2 AS d ON c~addressid = d~addressid
     WHERE a~salesorder = @salesorderno
    INTO  @DATA(wa_head1).

    SELECT SINGLE
    a~salesorder ,
    b~fullname
    FROM i_salesorder AS a
    LEFT JOIN i_salesorderpartner AS b ON a~salesorder = b~salesorder AND b~partnerfunction = 'ZE'
     WHERE a~salesorder = @salesorderno
     INTO @DATA(wa_head2).





*
*    """""""""""""""""""""""""""""bill to-- address*************

    SELECT SINGLE
          b~customer,
          b~fullname,
         d~streetname,
         d~cityname,
         d~postalcode,
         d~region,
         d~country,
         d~taxnumber3,
         i~regionname,
         e~countryname

    FROM i_salesorder AS a
    LEFT JOIN i_salesorderpartner AS b ON a~salesorder = b~salesorder  AND b~partnerfunction = 'RE'
    LEFT JOIN i_customer AS d ON b~customer = d~customer
     LEFT JOIN i_regiontext AS i ON d~region = i~region AND d~country = i~country
     LEFT JOIN i_countrytext AS e ON d~Country = e~Country
    WHERE a~salesorder = @salesorderno
    INTO @DATA(wa_ad_bill).




*   out->write( wa_ad_bill ).
*****


    DATA : bill_ad1        TYPE string,
           bill_ad2        TYPE string,
           bill_ad3        TYPE string,
           state_code_bill TYPE string.

*    bill_ad1 =   wa_ad_bill-StreetName .
**
*
*    bill_ad2 = wa_ad_bill-CityName.
*    CONCATENATE  wa_ad_bill-PostalCode ' ' INTO bill_ad2 .
*
*    bill_ad3 = wa_ad_bill-Region.
*    CONCATENATE wa_ad_bill-Country  ' ' INTO bill_ad1.


    bill_ad1 =   wa_ad_bill-streetname .
*

    bill_ad2 = wa_ad_bill-cityname.
    CONCATENATE bill_ad2  ','  wa_ad_bill-CountryName INTO bill_ad2 SEPARATED BY space .

    bill_ad3 =  wa_ad_bill-postalcode.
*    CONCATENATE bill_ad3  ','  wa_ad_bill-CountryName INTO bill_ad3 SEPARATED BY space.



    state_code_bill = wa_ad_bill-taxnumber3+0(2).


    """""""""""""""""""""""""""""""""""""ship "to ********


    SELECT SINGLE
          b~customer,
          b~fullname,
         d~streetname,
         d~cityname,
         d~postalcode,
         d~region,
         d~country,
         d~taxnumber3,
         i~regionname,
         e~countryname

    FROM i_salesorder AS a
    LEFT JOIN i_salesorderpartner AS b ON a~salesorder = b~salesorder AND b~partnerfunction = 'WE'
    LEFT JOIN i_customer AS d ON b~customer = d~customer
     LEFT JOIN i_regiontext AS i ON d~region = i~region AND d~country = i~country
     left JOIN i_countrytext as e ON d~Country = e~Country
    WHERE a~salesorder = @salesorderno
    INTO @DATA(wa_ad_ship).



    DATA : ship_ad1        TYPE string,
           ship_ad2        TYPE string,
           ship_ad3        TYPE string,
           state_code_ship TYPE string.



    ship_ad1 =   wa_ad_ship-streetname.
*
    ship_ad2 = wa_ad_ship-cityname.
    CONCATENATE ship_ad2  ','  wa_ad_ship-CountryName INTO ship_ad2 SEPARATED BY space .

    ship_ad3 = wa_ad_ship-postalcode.
*    CONCATENATE ship_ad3  ','  wa_ad_ship-CountryName  ' ' INTO ship_ad3 SEPARATED BY space.


    state_code_ship = wa_ad_ship-taxnumber3+0(2).

    """""""""""""""""""""""""""""Item details """"""""""""""""""""""""""""""

    SELECT a~salesorder ,
    a~totalnetamount,
    b~netamount,
    b~product,
    b~salesorder AS so_item,
    b~salesorderitem,
    b~orderquantity,
    b~orderquantityunit,
    c~productdescription,
    d~consumptiontaxctrlcode
*          e~CONDITIONRATEVALUE
    FROM i_salesorder AS a
    LEFT JOIN i_salesorderitem AS b ON a~salesorder = b~salesorder
    LEFT JOIN i_productdescription AS c ON b~product = c~product AND c~language = 'E'
    LEFT JOIN i_productplantbasic AS d ON b~product = d~product AND b~plant = d~plant
*          left JOIN i_salesorderitempricingelement as e on b~SalesOrder = e~SalesOrder AND b~SalesOrderItem = e~SalesOrderItem
*                      AND e~ConditionType = 'ZPR0'
WHERE a~salesorder = @salesorderno
    INTO TABLE @DATA(it_item).



    """"""""""""""""""""""""""""""""""""""""""""Rate """""

    SELECT a~salesorder ,
   b~salesorder AS so_item,
   b~salesorderitem,
   e~conditionratevalue
   FROM i_salesorder AS a
   LEFT JOIN i_salesorderitem AS b ON a~salesorder = b~salesorder
   LEFT JOIN i_salesorderitempricingelement AS e ON b~salesorder = e~salesorder AND b~salesorderitem = e~salesorderitem
               AND e~conditiontype = 'ZPR0'
               WHERE a~salesorder = @salesorderno
   INTO TABLE @DATA(rate).






    """""""""""""""""" discount """"""""""""""""""""""""""
    SELECT a~salesorder ,
   b~salesorder AS so_item,
   b~salesorderitem,
   e~conditionratevalue
   FROM i_salesorder AS a
   LEFT JOIN i_salesorderitem AS b ON a~salesorder = b~salesorder
   LEFT JOIN i_salesorderitempricingelement AS e ON b~salesorder = e~salesorder AND b~salesorderitem = e~salesorderitem
               AND e~conditiontype = 'ZD02'
               WHERE a~salesorder = @salesorderno
   INTO TABLE @DATA(disc).

    """"""""""""""""""""""""""""""""""""CGST RATE & AMOUNT"

    SELECT a~salesorder ,
    b~salesorder AS so_item,
    b~salesorderitem,
    e~conditionratevalue,
    e~conditionamount
    FROM i_salesorder AS a
    LEFT JOIN i_salesorderitem AS b ON a~salesorder = b~salesorder
    LEFT JOIN i_salesorderitempricingelement AS e ON b~salesorder = e~salesorder AND b~salesorderitem = e~salesorderitem
                AND e~conditiontype = 'JOCG'
                WHERE a~salesorder = @salesorderno
    INTO TABLE @DATA(cgst).

    """"""""""""""""""""""""""""""""""SGST RATE & AMOUNT""""""""""""""



    SELECT a~salesorder ,
   b~salesorder AS so_item,
   b~salesorderitem,
   e~conditionratevalue,
   e~conditionamount
   FROM i_salesorder AS a
   LEFT JOIN i_salesorderitem AS b ON a~salesorder = b~salesorder
   LEFT JOIN i_salesorderitempricingelement AS e ON b~salesorder = e~salesorder AND b~salesorderitem = e~salesorderitem
               AND e~conditiontype = 'JOSG' OR e~conditiontype = 'JOUG'
               WHERE a~salesorder = @salesorderno
   INTO TABLE @DATA(sgst).

    """"""""""""""""""""""""""""""""""IGST rate & amount""""""""""""

    SELECT a~salesorder ,
  b~salesorder AS so_item,
  b~salesorderitem,
  e~conditionratevalue,
  e~conditionamount
  FROM i_salesorder AS a
  LEFT JOIN i_salesorderitem AS b ON a~salesorder = b~salesorder
  LEFT JOIN i_salesorderitempricingelement AS e ON b~salesorder = e~salesorder AND b~salesorderitem = e~salesorderitem
              AND e~conditiontype = 'JOIG'
              WHERE a~salesorder = @salesorderno
  INTO TABLE @DATA(igst).

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""ROUNDING
    SELECT a~salesorder ,
 b~salesorder AS so_item,
 b~salesorderitem,
 e~conditionratevalue,
 e~conditionamount
 FROM i_salesorder AS a
 LEFT JOIN i_salesorderitem AS b ON a~salesorder = b~salesorder
 LEFT JOIN i_salesorderitempricingelement AS e ON b~salesorder = e~salesorder AND b~salesorderitem = e~salesorderitem
             AND e~conditiontype = 'DRD1'
             WHERE a~salesorder = @salesorderno
 INTO TABLE @DATA(rounding).

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""payment terms
*    out->write( rounding ).

    SELECT SINGLE
     a~salesorder,
    a~customerpaymentterms,
    b~customerpaymenttermsname
    FROM i_salesorder AS a
    LEFT JOIN i_customerpaymenttermstext AS b ON a~customerpaymentterms = b~customerpaymentterms
    WHERE a~salesorder = @salesorderno
    INTO  @DATA(pay_terms).



*          out->write( it_item ).
*           out->write( disc ).
    DATA rounding_off_val TYPE i_salesorderitempricingelement-conditionamount.

    DATA(lv_xml) =
    |<form>| &&
    |<header>| &&
    |<salesOrg>{ wa_head-salesorganization }</salesOrg>| &&
    |<companyName>{ wa_head-companycodename }</companyName>| &&
    |<companyAd1>{ comp_add1 }</companyAd1>| &&
    |<companyAd2>{ comp_add2 }</companyAd2>| &&
    |<email>{ wa_head-email }</email>| &&
    |<phone>{ wa_head-telephonenumber1 }</phone>| &&
    |<pan>{ pan }</pan>| &&
    |<gst>{ wa_head-taxnumber3 }</gst>| &&
    |<cin>{ cin }</cin>| &&
    |<Incoterms>{ wa_head-IncotermsClassification }</Incoterms>| &&
    |<IncotermsLocation>{ wa_head-IncotermsLocation1 }</IncotermsLocation>| &&
    |<SalesDistrict>{ wa_head-SalesDistrict }</SalesDistrict>| &&
    |<so_no>{ wa_head-salesorder }</so_no>| &&
    |<so_dt>{ wa_head-creationdate }</so_dt>| &&
    |<state>{ wa_head-RegionName }</state>| &&
    |<stateCode>{ state_code }</stateCode>| &&
    |<placeOfSupply></placeOfSupply>| &&
    |<documentDate>{ wa_head-creationdate }</documentDate>| &&
    |<delivDate>{ wa_head-confirmeddeliverydate }</delivDate>| &&
    |<contactPerson>{ wa_head1-fullname }</contactPerson>| &&
    |<phoneNo>{ wa_head1-telephonenumber1 }</phoneNo>| &&
    |<email>{ wa_head1-emailaddress }</email>| &&
    |<salesEmp>{ wa_head2-fullname }</salesEmp>| &&
    |<DispatchPlant>{ wa_head-PlantName }</DispatchPlant>| &&
    |<saudaBookingNo>{ wa_head-referencesddocument }</saudaBookingNo>| &&
    |<billTo>| &&
    |<customercodebill>{ wa_ad_bill-Customer }</customercodebill>| &&
    |<name>{ wa_ad_bill-fullname }</name>| &&
    |<address1>{ bill_ad1 }</address1>| &&
    |<address2>{ bill_ad2 }</address2>| &&
    |<address3>{ bill_ad3 }</address3>| &&
    |<state>{ wa_ad_bill-RegionName }</state>| &&
    |<stateCode>{ state_code_bill }</stateCode>| &&
    |<gstNo>{ wa_ad_bill-taxnumber3 }</gstNo>| &&
    |</billTo>| &&
    |<shipTo>| &&
    |<customercodeship>{ wa_ad_ship-Customer }</customercodeship>| &&
    |<name>{ wa_ad_ship-fullname }</name>| &&
    |<address1>{ ship_ad1 }</address1>| &&
    |<address2>{ ship_ad2 }</address2>| &&
    |<address3>{ ship_ad3 }</address3>| &&
    |<state>{ wa_ad_ship-RegionName }</state>| &&
    |<stateCode>{ state_code_ship }</stateCode>| &&
    |<gstNo>{ wa_ad_ship-taxnumber3 }</gstNo>| &&
    |</shipTo>| &&
    |</header>| &&
    |<item>|.

    LOOP AT it_item INTO DATA(wa_item).
      DATA(lv_xml2) =
       |<lineItem>| &&
       |<itemCode>{ wa_item-product }</itemCode>| &&
       |<itemDesc>{ wa_item-productdescription }</itemDesc>| &&
       |<hsn>{ wa_item-consumptiontaxctrlcode }</hsn>| &&
       |<qty>{ wa_item-orderquantity }</qty>| &&
       |<uom>{ wa_item-orderquantityunit }</uom>| &&
       |<taxable_value>{ wa_item-netamount }</taxable_value>|.



      READ TABLE rate INTO DATA(wa_rate) WITH KEY salesorder = wa_item-salesorder salesorderitem = wa_item-salesorderitem.
      DATA(lv_rate) =
        |<rate>{ wa_rate-conditionratevalue }</rate>|.

      READ TABLE disc INTO DATA(wa_disc) WITH KEY salesorder = wa_item-salesorder salesorderitem = wa_item-salesorderitem.
      DATA(lv_disc) =
      |<disc>{ wa_disc-conditionratevalue }</disc>|.

      READ TABLE cgst INTO DATA(wa_cgst) WITH KEY salesorder = wa_item-salesorder salesorderitem = wa_item-salesorderitem.
      DATA(lv_jocg) =
      |<cgstRate>{ wa_cgst-conditionratevalue }</cgstRate>| &&
      |<cgst_amount>{ wa_cgst-conditionamount }</cgst_amount>|.

      READ TABLE sgst INTO DATA(wa_sgst) WITH KEY salesorder = wa_item-salesorder salesorderitem = wa_item-salesorderitem.
      DATA(lv_josg) =
      |<sgstRate>{ wa_sgst-conditionratevalue }</sgstRate>| &&
      |<sgst_amount>{ wa_sgst-conditionamount }</sgst_amount>|.

      READ TABLE igst INTO DATA(wa_igst) WITH KEY salesorder = wa_item-salesorder salesorderitem = wa_item-salesorderitem.
      DATA(lv_joig) =
      |<igstRate>{ wa_igst-conditionratevalue }</igstRate>| &&
      |<igst_amount>{ wa_igst-conditionamount }</igst_amount>|.






      CONCATENATE lv_xml lv_xml2 lv_rate lv_disc lv_jocg lv_josg lv_joig '</lineItem>' INTO lv_xml.
      READ TABLE rounding INTO DATA(wa_rounding) WITH KEY salesorder = wa_item-salesorder salesorderitem = wa_item-salesorderitem.
      rounding_off_val = rounding_off_val + wa_rounding-conditionamount.

    ENDLOOP.

    DATA(lv_footer) =
    |</item>| &&
    |<footer>| &&
    |<totalAmtBefTax>{ wa_item-TotalNetAmount }</totalAmtBefTax>| &&
    |<rounding_off>{ rounding_off_val }</rounding_off>| &&
    |<payment_terms>{ pay_terms-customerpaymenttermsname  }</payment_terms>| &&
    |</footer>| &&
    |</form>|.

    CONCATENATE lv_xml lv_footer INTO lv_xml.

      REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'and'.

*    out->write( lv_xml ).
    CALL METHOD zcl_ads_print=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).
  ENDMETHOD.
ENDCLASS.
