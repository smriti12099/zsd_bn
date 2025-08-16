CLASS zcl_test_sales_contract DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
    CLASS-DATA: access_token TYPE string.
    CLASS-DATA: xml_file TYPE string.
    CLASS-DATA: var1 TYPE vbeln.

    TYPES:
      BEGIN OF struct,
        xdp_template TYPE string,
        xml_data     TYPE string,
        form_type    TYPE string,
        form_locale  TYPE string,
        tagged_pdf   TYPE string,
        embed_font   TYPE string,
      END OF struct.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS lv1_url TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'.
    CONSTANTS lv2_url TYPE string VALUE 'https://bn-dev-jpiuus30.authentication.jp10.hana.ondemand.com/oauth/token'.
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zsd_salescontract/zsd_salescontract'.
ENDCLASS.



CLASS ZCL_TEST_SALES_CONTRACT IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.




    TYPES : BEGIN OF ty_head,
              broker TYPE string,
            END OF ty_head.

    DATA: wa_head1 TYPE ty_head.


    " Fetch header data
    SELECT  SINGLE  FROM i_salescontract WITH PRIVILEGED ACCESS  AS a
      LEFT JOIN i_salescontractitem WITH PRIVILEGED ACCESS  AS b ON a~SalesContract = b~SalesContract
       LEFT JOIN i_plant  WITH PRIVILEGED ACCESS  AS c  ON c~Plant = b~plant
       LEFT JOIN i_address_2 WITH PRIVILEGED ACCESS   AS d  ON d~AddressID = c~AddressID
       LEFT JOIN i_regiontext WITH PRIVILEGED ACCESS   AS j  ON j~Region = d~Region
       LEFT JOIN i_salescontractpartner WITH PRIVILEGED ACCESS   AS e  ON e~Customer = a~SoldToParty
       LEFT JOIN i_address_2 WITH PRIVILEGED ACCESS   AS g  ON g~AddressID = e~AddressID
        LEFT JOIN i_regiontext WITH PRIVILEGED ACCESS   AS k ON k~Region = g~Region
       LEFT JOIN i_productdescription WITH PRIVILEGED ACCESS   AS f  ON b~product = f~Product
       LEFT JOIN i_companycode WITH PRIVILEGED ACCESS    AS h ON a~BillingCompanyCode = h~CompanyCode
       LEFT JOIN i_paymenttermstext WITH PRIVILEGED ACCESS   AS i ON a~CustomerPaymentTerms = i~PaymentTermsName
       FIELDS
        a~SalesContract , a~CreationDate ,
         c~PlantName, d~HouseNumber, d~StreetName,
        d~StreetPrefixName1, d~StreetPrefixName2, d~StreetSuffixName1, d~StreetSuffixName2,
        d~CityName, d~PostalCode, d~Region , d~Country ,
       e~FullName AS sellername , b~TransactionCurrency ,
         d~Street ,
         j~RegionName,
        g~HouseNumber AS customerHouseNumber, g~Street AS customerstreetname , g~StreetPrefixName1 AS customerStreetPrefixName1 , g~StreetPrefixName2  AS customerStreetPrefixName2 ,
        g~StreetSuffixName1  AS customerStreetSuffixName1, g~StreetSuffixName2  AS customerStreetSuffixName2 , g~CityName AS customerCityName , g~PostalCode  AS customerPostalCode , k~RegionName AS customerregion , g~country AS customercountry ,
         f~ProductDescription , b~NetAmount , a~BillingCompanyCode
        , b~TargetQuantity , b~TargetQuantityUnit , a~SalesContractValidityStartDate , a~SalesContractValidityEndDate , h~CompanyCodeName, i~PaymentTermsName ,
        a~IncotermsClassification , a~IncotermsLocation1 , b~NetPriceQuantityUnit
        WHERE a~SalesContract = '0040000261' AND e~PartnerFunction = 'AG'
  INTO @DATA(wa_head).



    SELECT SINGLE b~fullname AS broker
   FROM i_salescontract AS a
    LEFT JOIN i_salescontractpartner AS b
      ON a~SalesContract = b~SalesContract
    WHERE a~SalesContract = '0040000261'
      AND b~partnerfunction = 'ES'  INTO @wa_head1.

    out->write( Wa_head1-broker ).
    out->write( Wa_head-RegionName ).

    " cutsomer adreess
    DATA: comp_add1 TYPE string,
          comp_add2 TYPE string.

    comp_add1 = wa_head-customerhousenumber.
    CONCATENATE comp_add1 ' ' wa_head-customerstreetname ' ' wa_head-customerstreetprefixname1 ' '  wa_head-customerstreetprefixname2 ' '  wa_head-customerstreetsuffixname1 ' '   wa_head-customerstreetsuffixname2 ' '  wa_head-customercityname  INTO
    comp_add1.
    comp_add2 = wa_head-customerregion.
    CONCATENATE  comp_add2 ' ' wa_head-customercountry  ' ' wa_head-customerpostalcode INTO
    comp_add2 SEPARATED BY space.

    " vendor adresss
    DATA: ven_add1 TYPE string,
          ven_add2 TYPE string.

    ven_add1 = wa_head-housenumber.
    CONCATENATE ven_add1 ' ' wa_head-streetname ' ' wa_head-streetprefixname1 ' '  wa_head-streetprefixname2 ' '  wa_head-streetsuffixname1 ' '   wa_head-streetsuffixname2 ' '  wa_head-cityname  INTO
    ven_add1.
    ven_add2 = wa_head-RegionName.
    CONCATENATE  ven_add2 ' ' wa_head-country ' ' wa_head-PostalCode INTO
    ven_add2 SEPARATED BY space.





    DATA(lv_xml) = |<Form>| &&

                       |<DATE>{ wa_head-CreationDate }</DATE>| &&
                       |<SALESCONTRACTNUMBER>{ wa_head-SalesContract }</SALESCONTRACTNUMBER>| &&
                       |<PLANTNAME>{ wa_head-PlantName }</PLANTNAME>| &&
                       "vendor adress
                       |<vendorAdress>{ ven_add1 }</vendorAdress>| &&
                       |<vendorAdress1>{ ven_add2  }</vendorAdress1>| &&
                       |<SELLERFullName>{ wa_head-sellername }</SELLERFullName>| &&
                     "CUSTOMER ADRESS DATA

                       |<CUSTOMERAddress1>{ comp_add1 }</CUSTOMERAddress1>| &&
                       |<CUSTOMERAddress2>{ comp_add2 }</CUSTOMERAddress2>| &&

                       |<brokerfullname>{ wa_head1-broker }</brokerfullname>| &&
                       |<ProductDesc>{ wa_head-ProductDescription }</ProductDesc>| &&
                       |<Tragetqty>{ wa_head-TargetQuantity }</Tragetqty>| &&
                        |<TragetqtyUnit>{ wa_head-TargetQuantityUnit }</TragetqtyUnit>| &&
                        |<salesStartdate>{ wa_head-SalesContractValidityStartDate }</salesStartdate>| &&
                        |<salesEnddate>{ wa_head-SalesContractValidityEndDate }</salesEnddate>| &&
                        |<IncoTermsclass>{ wa_head-IncotermsClassification }</IncoTermsclass>| &&
                        |<IncotermsLocation1>{ wa_head-IncotermsLocation1 }</IncotermsLocation1>| &&
                         |<Companyname>{ wa_head-CompanyCodeName }</Companyname>| &&
                         |<PRICE>{ wa_head-NetAmount }</PRICE>| &&
                         |<companycode>{ wa_head-BillingCompanyCode }</companycode>| &&
                         |<paymentterms>{ wa_head-PaymentTermsName }</paymentterms>| &&
                         |<TransactionCurrency>{ wa_head-TransactionCurrency }</TransactionCurrency>| &&
                          |<NetPriceQuantityUnit>{ wa_head-NetPriceQuantityUnit }</NetPriceQuantityUnit>| &&
                       |</Form>|.


    out->write( lv_xml ).

  ENDMETHOD.
ENDCLASS.
