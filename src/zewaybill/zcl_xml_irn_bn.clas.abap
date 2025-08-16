CLASS zcl_xml_irn_bn DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
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
                  bill_doc        TYPE string
                  printname       TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.

ENDCLASS.



CLASS ZCL_XML_IRN_BN IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD .


  METHOD read_posts.





    DATA : plant_add   TYPE string.
    DATA : p_add1  TYPE string.
    DATA : p_add2 TYPE string.
    DATA : p_city TYPE string.
    DATA : p_dist TYPE string.
    DATA : p_state TYPE string.
    DATA : p_country   TYPE string,
           plant_name  TYPE string,
           plant_gstin TYPE string,
           p_pin       TYPE string.



    SELECT SINGLE
     a~billingdocument ,
      a~billingdocumentdate ,
      a~creationdate,
      a~creationtime,
      a~documentreferenceid,
       b~referencesddocument ,
       b~plant,
        d~deliverydocumentbysupplier,
     e~gstin_no ,
     e~state_code2 ,
     e~plant_name1 ,
     e~address1 ,
     e~address2 ,
     e~city ,
     e~district ,
     e~state_name ,
     e~pin ,
     e~country ,
     g~supplierfullname,
     i~documentdate,
    j~irnno ,
    j~ackno ,
    j~ackdate ,
    j~billingdocno  ,    "invoice no
    j~billingdate ,
    j~signedqrcode ,
    j~vehiclenum ,
    j~grno ,
    j~grdate ,
    j~transportername ,
    j~transportmode ,
    b~salesorganization ,
    l~salesorganizationname ,
    j~ewaybillno ,
    j~ewaydate ,
    e~fssai_no ,
    a~incotermsclassification ,
    a~incotermslocation1 ,
    m~telephonenumber1 ,
    a~PurchaseOrderByCustomer ,
    e~company_name
    FROM i_billingdocument AS a
    LEFT JOIN i_billingdocumentitem AS b ON a~BillingDocument = b~BillingDocument
    LEFT JOIN i_purchaseorderhistoryapi01 AS c ON b~batch = c~batch AND c~goodsmovementtype = '101'
    LEFT JOIN i_inbounddelivery AS d ON c~deliverydocument = d~inbounddelivery
    LEFT JOIN ztable_plant AS e ON e~plant_code = b~plant
    LEFT JOIN i_billingdocumentpartner AS f ON a~BillingDocument = f~BillingDocument
    LEFT JOIN I_Supplier AS g ON f~Supplier = g~Supplier
    LEFT JOIN i_materialdocumentitem_2 AS h ON h~purchaseorder = c~purchaseorder AND h~goodsmovementtype = '101'
    LEFT JOIN I_MaterialDocumentHeader_2 AS i ON h~MaterialDocument = i~MaterialDocument
    LEFT JOIN ztable_irn AS j ON j~billingdocno = a~BillingDocument AND a~CompanyCode = j~bukrs
    LEFT JOIN i_salesdocument AS k ON k~salesdocument = b~salesdocument
    LEFT JOIN I_SalesOrganizationText AS l ON l~SalesOrganization = b~SalesOrganization
    LEFT JOIN I_Customer AS m ON m~Customer = a~payerparty

    WHERE a~BillingDocument = @bill_doc
    INTO @DATA(wa_header).


**********************************************************************CURRENT DATE

    DATA(lv_currdate) = cl_abap_context_info=>get_system_date( ).
    DATA: lv_datecurr      TYPE string.

    lv_datecurr = lv_currdate .
    CONDENSE lv_datecurr NO-GAPS.  " Remove any spaces
    lv_datecurr = lv_datecurr+6(2) && '/' && lv_datecurr+4(2) && '/' && lv_datecurr(4).


**********************************************************************CURRENT DATE END

**********************************************************************REFERENCE NUMBER NEW LOGIC

    SELECT SINGLE FROM I_BillingDocumentItem AS a
    LEFT JOIN I_SalesDocument AS b ON b~SalesDocument = a~ReferenceSDDocument
    FIELDS b~PurchaseOrderByCustomer , a~BillingDocument
    WHERE a~BillingDocument = @bill_doc
    INTO @DATA(wa_refdoc)
    PRIVILEGED ACCESS.


**********************************************************************REFERENCE NUMBER NEW LOGIC END

**********************************************************************REGISTERED OFFICE

    SELECT SINGLE FROM I_BillingDocumentItem AS a
    LEFT JOIN zcompanycode AS b ON b~company_code = a~CompanyCode
    FIELDS a~BillingDocument , b~address
    WHERE a~BillingDocument = @bill_doc
    INTO @DATA(wa_registered).


**********************************************************************REGISTERED OFFICE END


**********************************************************************STO NUMBER

    SELECT SINGLE FROM I_BillingDocumentItem AS a
    LEFT JOIN I_DeliveryDocumentItem AS b ON b~DeliveryDocument = a~ReferenceSDDocument AND b~DeliveryDocumentItem = a~ReferenceSDDocumentItem
    FIELDS b~ReferenceSDDocument , a~BillingDocument
    WHERE a~BillingDocument = @bill_doc
    INTO @DATA(wa_stonum)
    PRIVILEGED ACCESS.



**********************************************************************STO NUMBER END



**********************************************************************PLANT FSSAI

    SELECT SINGLE FROM I_BillingDocumentItem AS a
    LEFT JOIN ztable_plant AS b ON b~plant_code = a~Plant
    FIELDS a~BillingDocument ,b~fssai_no
    WHERE a~BillingDocument = @bill_doc
    INTO @DATA(wa_plntfssai).

**********************************************************************PLANT FSSAI END



**********************************************************************BILLTOPARTNER

    SELECT SINGLE
    a~billingdocument ,
    a~payerparty
    FROM i_billingdocument AS a
    WHERE a~BillingDocument = @bill_doc
    INTO @DATA(wa_bpart).

    SHIFT wa_bpart-PayerParty LEFT DELETING LEADING '0'.


***********************************************************************************

**********************************************************************SHIPTOPARTNER

    SELECT SINGLE
    a~billingdocument ,
    b~shiptoparty
    FROM I_BillingDocumentItem AS a
    LEFT JOIN I_DeliveryDocument AS b ON b~DeliveryDocument = a~ReferenceSDDocument
    WHERE a~BillingDocument = @bill_doc
    INTO @DATA(wa_spart) .


    SHIFT wa_spart-ShipToParty LEFT DELETING LEADING '0'.

***********************************************************************************

**********************************************************************BRANCH ADDRESS

SELECT SINGLE FROM I_BillingDocumentItem AS A
LEFT JOIN ztable_plant AS B ON B~plant_code = A~Plant
FIELDS A~BillingDocument , B~plant_name1 , B~plant_name2
WHERE A~BillingDocument = @bill_doc
INTO @DATA(WA_DELBRANCHADD).

    DATA : DELBRANCHADDRESS TYPE string.
    IF WA_DELBRANCHADD-plant_name1 IS NOT INITIAL.
      CONCATENATE DELBRANCHADDRESS WA_DELBRANCHADD-plant_name1 INTO DELBRANCHADDRESS.
    ENDIF.
    IF WA_DELBRANCHADD-plant_name2 IS NOT INITIAL.
      IF DELBRANCHADDRESS IS NOT INITIAL.
        CONCATENATE DELBRANCHADDRESS ',' INTO DELBRANCHADDRESS .
      ENDIF.
      CONCATENATE DELBRANCHADDRESS WA_DELBRANCHADD-plant_name2 INTO DELBRANCHADDRESS.
    ENDIF.


**********************************************************************BRANCH ADDRESS


**********************************************************************BANKDETAILS
    SELECT SINGLE FROM i_billingdocumentitem AS a
    LEFT JOIN ztable_irn AS b ON b~billingdocno = a~BillingDocument
    LEFT JOIN zbank_tab AS c ON c~salesorg = b~bukrs AND  c~distributionchannel = b~distributionchannel
    FIELDS c~acoount_number , c~bank_details , c~ifsc_code , c~distributionchannel ,c~salesorg
    WHERE a~billingdocument = @bill_doc  " AND c~distributionchannel IN ( 'BS','HS','TS','OS' )
    INTO @DATA(wa_bank).

    DATA : distch TYPE string.
    DATA : salesor TYPE string.
    distch = wa_bank-distributionchannel .
    salesor = wa_bank-salesorg .
**********************************************************************BANKDETAILS END


**********************************************************************SHIPTOPHONE

    SELECT SINGLE
    c~telephonenumber1,
    a~billingdocument
    FROM i_BillingDocumentitem AS a
    LEFT JOIN i_deliverydocument AS b ON b~deliverydocument = a~referencesddocument
    LEFT JOIN i_customer AS c ON c~Customer = b~shiptoparty
    WHERE a~billingdocument = @bill_doc
    INTO @DATA(wa_sp) PRIVILEGED ACCESS.


**********************************************************************Remarks

    SELECT SINGLE FROM i_billingdocument AS a
    FIELDS a~YY1_Remarks_bd_BDH , a~BillingDocument
    WHERE a~BillingDocument = @bill_doc
    INTO @DATA(wa_remarks).


**********************************************************************Remarks End



************************************************************************************
*    SELECT single from zgateentryheader as a
*        left join zgateentrylines as b on a~gateentryno = b~gateentryno
*      fields a~gateentryno, b~documentno
*        where a~gateentryno = b~gateentryno
*        into @data(wa_gateno).

**********************************************************************LR NO & VEHICLENO & TRANSPORTMODE & LR DATE

*    SELECT SINGLE
*    a~billingdocument ,
*    b~referencesddocument
*    FROM i_billingdocument AS a
*    LEFT JOIN i_billingdocumentitem AS b ON b~billingdocument = a~billingdocument
*    WHERE a~BillingDocument = @bill_doc
*    INTO @DATA(wa_lrvntm).
*
*    SHIFT wa_lrvntm-ReferenceSDDocument LEFT DELETING LEADING '0'.
*
*    SELECT SINGLE
*    d~vehicleno ,
*    d~LRNo ,
*    d~transportmode ,
*    d~transportername ,
*    d~lrdate
*    FROM i_billingdocument AS a
*    LEFT JOIN i_billingdocumentitem AS b ON b~billingdocument = a~billingdocument
*    LEFT JOIN zr_gateentrylines AS c ON c~Documentno = @wa_lrvntm-ReferenceSDDocument
*    LEFT JOIN ZR_GateEntryHeader AS d ON d~Gateentryno = c~Gateentryno
*    WHERE a~billingdocument = @bill_doc
*    INTO @DATA(wa_gatemain).

***********************************************************************LR NO & VEHICLENO & TRANSPORTMODE & LR DATE END


**********************************************************************FOR CREDIT NOTE PRINT SHIP TO CODE

    SELECT SINGLE FROM I_BillingDocumentItem AS a
    LEFT JOIN i_creditmemorequestitem AS b ON b~CreditMemoRequest = a~ReferenceSDDocument AND b~CreditMemoRequestItem = a~BillingDocumentItem
    LEFT JOIN i_CUSTOMERRETURNDELIVERYITEM AS c ON c~ReferenceSDDocument = b~ReferenceSDDocument
    LEFT JOIN i_customerreturndelivery AS d ON d~CustomerReturnDelivery = c~CustomerReturnDelivery
    LEFT JOIN i_businesspartner AS e ON e~BusinessPartner = d~ShipToParty
    FIELDS  d~ShipToParty , e~BusinessPartnerFullName
    WHERE a~BillingDocument = @bill_doc
    INTO @DATA(wa_creditship)
    PRIVILEGED ACCESS.

    SHIFT wa_creditship-ShipToParty LEFT DELETING LEADING '0'.
**********************************************************************FOR CREDIT NOTE PRINT SHIP TO CODE END


**********************************************************************FOR CREDIT NOTE SHIPTO ADDRESS END

    SELECT SINGLE FROM I_BillingDocumentItem AS a
    LEFT JOIN i_creditmemorequestitem AS b ON b~CreditMemoRequest = a~ReferenceSDDocument AND b~CreditMemoRequestItem = a~BillingDocumentItem
    LEFT JOIN i_CUSTOMERRETURNDELIVERYITEM AS c ON c~ReferenceSDDocument = b~ReferenceSDDocument
    LEFT JOIN i_customerreturndelivery AS d ON d~CustomerReturnDelivery = c~CustomerReturnDelivery
    LEFT JOIN i_customer AS e ON e~Customer = d~ShipToParty AND e~Language = 'E'
    LEFT JOIN i_address_2 AS f ON f~AddressID = e~AddressID
    LEFT JOIN i_regiontext AS g ON g~Region = f~Region AND g~Language = 'E' AND g~Country = 'IN'
    LEFT JOIN I_CountryText AS h ON h~Country = f~Country AND h~Language = 'E'
    FIELDS  f~HouseNumber , f~StreetName , f~StreetPrefixName1 , f~StreetPrefixName2 ,
           f~StreetSuffixName1 , f~StreetSuffixName2 , f~CityName , g~RegionName , h~CountryName , f~PostalCode , e~TaxNumber3 , e~TelephoneNumber1 , f~DistrictName , f~VillageName
    WHERE a~BillingDocument = @bill_doc
    INTO @DATA(wa_credshipadd)
    PRIVILEGED ACCESS.

    DATA : credaddship TYPE string.
    IF wa_credshipadd-HouseNumber IS NOT INITIAL.
      CONCATENATE credaddship wa_credshipadd-HouseNumber INTO credaddship.
    ENDIF.
    IF wa_credshipadd-StreetName IS NOT INITIAL.
      IF credaddship IS NOT INITIAL.
        CONCATENATE credaddship ',' INTO credaddship .
      ENDIF.
      CONCATENATE credaddship wa_credshipadd-StreetName INTO credaddship.
    ENDIF.
    IF wa_credshipadd-StreetPrefixName1 IS NOT INITIAL.
      IF credaddship IS NOT INITIAL.
        CONCATENATE credaddship ',' INTO credaddship .
      ENDIF.
      CONCATENATE credaddship wa_credshipadd-StreetPrefixName1 INTO credaddship.
    ENDIF.
    IF wa_credshipadd-StreetPrefixName2 IS NOT INITIAL.
      IF credaddship IS NOT INITIAL.
        CONCATENATE credaddship ',' INTO credaddship .
      ENDIF.
      CONCATENATE credaddship wa_credshipadd-StreetPrefixName2 INTO credaddship.
    ENDIF.
    IF wa_credshipadd-StreetSuffixName1 IS NOT INITIAL.
      IF credaddship IS NOT INITIAL.
        CONCATENATE credaddship ',' INTO credaddship .
      ENDIF.
      CONCATENATE credaddship wa_credshipadd-StreetSuffixName1 INTO credaddship.
    ENDIF.
    IF wa_credshipadd-StreetSuffixName2 IS NOT INITIAL.
      IF credaddship IS NOT INITIAL.
        CONCATENATE credaddship ',' INTO credaddship .
      ENDIF.
      CONCATENATE credaddship wa_credshipadd-StreetSuffixName2 INTO credaddship.
    ENDIF.
    IF wa_credshipadd-VillageName IS NOT INITIAL.
      IF credaddship IS NOT INITIAL.
        CONCATENATE credaddship ',' INTO credaddship .
      ENDIF.
      CONCATENATE credaddship wa_credshipadd-VillageName INTO credaddship.
    ENDIF.
    IF wa_credshipadd-DistrictName IS NOT INITIAL.
      IF credaddship IS NOT INITIAL.
        CONCATENATE credaddship ',' INTO credaddship .
      ENDIF.
      CONCATENATE credaddship wa_credshipadd-DistrictName INTO credaddship.
    ENDIF.
    IF wa_credshipadd-CityName IS NOT INITIAL.
      IF credaddship IS NOT INITIAL.
        CONCATENATE credaddship ',' INTO credaddship .
      ENDIF.
      CONCATENATE credaddship wa_credshipadd-CityName INTO credaddship.
    ENDIF.
    IF wa_credshipadd-RegionName IS NOT INITIAL.
      IF credaddship IS NOT INITIAL.
        CONCATENATE credaddship ',' INTO credaddship .
      ENDIF.
      CONCATENATE credaddship wa_credshipadd-RegionName INTO credaddship.
    ENDIF.
    IF wa_credshipadd-CountryName IS NOT INITIAL.
      IF credaddship IS NOT INITIAL.
        CONCATENATE credaddship ',' INTO credaddship .
      ENDIF.
      CONCATENATE credaddship wa_credshipadd-CountryName INTO credaddship.
    ENDIF.
    IF wa_credshipadd-PostalCode IS NOT INITIAL.
      IF credaddship IS NOT INITIAL.
        CONCATENATE credaddship '-' INTO credaddship .
      ENDIF.
      CONCATENATE credaddship wa_credshipadd-PostalCode INTO credaddship.
    ENDIF.





*    CONCATENATE  wa_credshipadd-StreetPrefixName1 wa_credshipadd-StreetPrefixName2 ',' wa_credshipadd-HouseNumber ',' wa_credshipadd-StreetName
*    wa_credshipadd-StreetSuffixName1  wa_credshipadd-StreetSuffixName2 ','
*    wa_credshipadd-CityName ',' wa_credshipadd-RegionName ',' wa_credshipadd-CountryName '-' wa_credshipadd-PostalCode
*    INTO credaddship SEPARATED BY space .

**********************************************************************FOR CREDIT NOTE SHIPTO ADDRESS END




**********************************************************************DELIVERY CHALLAN SHIP TO

    SELECT SINGLE FROM I_BillingDocItemPartner AS a
    LEFT JOIN i_customer AS b ON b~Customer = a~Customer AND b~Language = 'E' AND B~Country = 'IN'
    LEFT JOIN i_address_2 AS c ON c~AddressID = b~AddressID AND C~Country = 'IN'
    LEFT JOIN I_RegionText AS d ON d~Region = c~Region AND d~Language = 'E' AND D~Country = 'IN'
    LEFT JOIN I_CountryText AS e ON e~Country = d~Country AND d~Language = 'E' AND E~Country = 'IN'
    LEFT JOIN I_BuPaIdentification AS f ON f~BusinessPartner = b~Customer and f~BPIdentificationType = 'FSSAI'
    FIELDS a~BillingDocument , a~Customer ,
           b~CustomerName ,
           b~TelephoneNumber1 ,
           b~TaxNumber3 ,
           c~HouseNumber ,
           c~StreetName ,
           c~StreetPrefixName1 ,
           c~StreetPrefixName2 ,
           c~StreetSuffixName1 ,
           c~StreetSuffixName2 ,
           c~DistrictName ,
           c~VillageName ,
           c~CityName ,
           c~PostalCode ,
           d~RegionName ,
           e~CountryName ,
           f~BPIdentificationNumber
    WHERE a~BillingDocument = @bill_doc
    AND a~PartnerFunction = 'WE'
    INTO @DATA(wa_deli_ship)
    PRIVILEGED ACCESS.

     SHIFT wa_deli_ship-Customer LEFT DELETING LEADING '0'.


    DATA : deladdship TYPE string.
    IF wa_deli_ship-HouseNumber IS NOT INITIAL.
      CONCATENATE deladdship wa_deli_ship-HouseNumber INTO deladdship.
    ENDIF.
    IF wa_deli_ship-StreetName IS NOT INITIAL.
      IF deladdship IS NOT INITIAL.
        CONCATENATE deladdship ',' INTO deladdship .
      ENDIF.
      CONCATENATE deladdship wa_deli_ship-StreetName INTO deladdship.
    ENDIF.
    IF wa_deli_ship-StreetPrefixName1 IS NOT INITIAL.
      IF deladdship IS NOT INITIAL.
        CONCATENATE deladdship ',' INTO deladdship .
      ENDIF.
      CONCATENATE deladdship wa_deli_ship-StreetPrefixName1 INTO deladdship.
    ENDIF.
    IF wa_deli_ship-StreetPrefixName2 IS NOT INITIAL.
      IF deladdship IS NOT INITIAL.
        CONCATENATE deladdship ',' INTO deladdship .
      ENDIF.
      CONCATENATE deladdship wa_deli_ship-StreetPrefixName2 INTO deladdship.
    ENDIF.
    IF wa_deli_ship-StreetSuffixName1 IS NOT INITIAL.
      IF deladdship IS NOT INITIAL.
        CONCATENATE deladdship ',' INTO deladdship .
      ENDIF.
      CONCATENATE deladdship wa_deli_ship-StreetSuffixName1 INTO deladdship.
    ENDIF.
    IF wa_deli_ship-StreetSuffixName2 IS NOT INITIAL.
      IF deladdship IS NOT INITIAL.
        CONCATENATE deladdship ',' INTO deladdship .
      ENDIF.
      CONCATENATE deladdship wa_deli_ship-StreetSuffixName2 INTO deladdship.
    ENDIF.
    IF wa_deli_ship-VillageName IS NOT INITIAL.
      IF deladdship IS NOT INITIAL.
        CONCATENATE deladdship ',' INTO deladdship .
      ENDIF.
      CONCATENATE deladdship wa_deli_ship-VillageName INTO deladdship.
    ENDIF.
    IF wa_deli_ship-DistrictName IS NOT INITIAL.
      IF deladdship IS NOT INITIAL.
        CONCATENATE deladdship ',' INTO deladdship .
      ENDIF.
      CONCATENATE deladdship wa_deli_ship-DistrictName INTO deladdship.
    ENDIF.
    IF wa_deli_ship-CityName IS NOT INITIAL.
      IF deladdship IS NOT INITIAL.
        CONCATENATE deladdship ',' INTO deladdship .
      ENDIF.
      CONCATENATE deladdship wa_deli_ship-CityName INTO deladdship.
    ENDIF.
    IF wa_deli_ship-RegionName IS NOT INITIAL.
      IF deladdship IS NOT INITIAL.
        CONCATENATE deladdship ',' INTO deladdship .
      ENDIF.
      CONCATENATE deladdship wa_deli_ship-RegionName INTO deladdship.
    ENDIF.
    IF wa_deli_ship-CountryName IS NOT INITIAL.
      IF deladdship IS NOT INITIAL.
        CONCATENATE deladdship ',' INTO deladdship .
      ENDIF.
      CONCATENATE deladdship wa_deli_ship-CountryName INTO deladdship.
    ENDIF.
    IF wa_deli_ship-PostalCode IS NOT INITIAL.
      IF deladdship IS NOT INITIAL.
        CONCATENATE deladdship '-' INTO deladdship .
      ENDIF.
      CONCATENATE deladdship wa_deli_ship-PostalCode INTO deladdship.
    ENDIF.



**********************************************************************DELIVERY CHALLAN SHIP TO




**********************************************************************FOR CREDIT NOTE SHIPTO FSSAI

    SELECT SINGLE FROM I_BillingDocumentItem AS a
    LEFT JOIN i_creditmemorequestitem AS b ON b~CreditMemoRequest = a~ReferenceSDDocument AND b~CreditMemoRequestItem = a~BillingDocumentItem
    LEFT JOIN i_CUSTOMERRETURNDELIVERYITEM AS c ON c~ReferenceSDDocument = b~ReferenceSDDocument
    LEFT JOIN i_customerreturndelivery AS d ON d~CustomerReturnDelivery = c~CustomerReturnDelivery
    LEFT JOIN I_BuPaIdentification AS e ON e~BusinessPartner = d~ShipToParty
    FIELDS a~BillingDocument , e~BPIdentificationNumber
    WHERE a~BillingDocument = @bill_doc AND e~bpidentificationtype = ( 'FSSAI' )
    INTO @DATA(wa_credshipfssai)
    PRIVILEGED ACCESS.

**********************************************************************FOR CREDIT NOTE SHIPTO FSSAI END

**********************************************************************NEW LOGIC FOR  CN TAX INVOICE SHIPTO

    SELECT SINGLE FROM I_BillingDocument WITH PRIVILEGED ACCESS AS a
    LEFT JOIN I_BillingDocumentItem WITH PRIVILEGED ACCESS AS b ON b~BillingDocument = a~AssignmentReference
    LEFT JOIN I_DeliveryDocument WITH PRIVILEGED ACCESS AS c ON c~DeliveryDocument = b~ReferenceSDDocument
    LEFT JOIN I_BusinessPartner WITH PRIVILEGED ACCESS AS d ON d~BusinessPartner = c~ShipToParty
    LEFT JOIN I_Customer WITH PRIVILEGED ACCESS AS e ON e~Customer = c~ShipToParty AND e~Language = 'E'
    LEFT JOIN I_Address_2 WITH PRIVILEGED ACCESS  AS f   ON f~AddressID = e~AddressID
    LEFT JOIN I_CountryText WITH PRIVILEGED ACCESS AS g ON g~Country = f~Country AND g~Language = 'E'
    LEFT JOIN I_RegionText WITH PRIVILEGED ACCESS AS h ON h~Region = f~Region AND h~Language = 'E' AND h~Country = 'IN'
    LEFT JOIN I_BuPaIdentification AS i ON i~BusinessPartner = c~ShipToParty AND i~BPIdentificationType = 'FSSAI'
    FIELDS c~ShipToParty , d~BusinessPartnerFullName ,
           f~HouseNumber , f~StreetPrefixName1 , f~StreetPrefixName2 , f~StreetSuffixName1 , f~StreetSuffixName2 ,
           f~CityName , f~StreetName ,f~PostalCode ,f~DistrictName , f~VillageName , g~CountryName  , h~RegionName , e~TaxNumber3 , e~TelephoneNumber1   , i~BPIdentificationNumber
    WHERE a~BillingDocument = @bill_doc
    INTO @DATA(wa_cntaxadd).
*PRIVILEGED ACCESS.

    SHIFT wa_cntaxadd-ShipToParty LEFT DELETING LEADING '0'.

*    DATA : strname TYPE string.
*    DATA : strpre TYPE string.
*    DATA : strsuf TYPE string.
*    DATA : ctyname TYPE string.
*    DATA : regname TYPE string.
*    CONCATENATE  wa_cntaxadd-StreetName ','  INTO strname.
*    CONCATENATE wa_cntaxadd-StreetPrefixName1  wa_cntaxadd-StreetPrefixName2 INTO strpre.
*    CONCATENATE wa_cntaxadd-StreetSuffixName1  wa_cntaxadd-StreetSuffixName2 INTO strsuf.
*    CONCATENATE wa_cntaxadd-CityName  ','  INTO ctyname.
*    CONCATENATE wa_cntaxadd-RegionName  ',' INTO regname.



    DATA : cntaxinvadd TYPE string .
*    cntaxinvadd = wa_cntaxadd-HouseNumber.

    IF wa_cntaxadd-HouseNumber IS NOT INITIAL.
      CONCATENATE cntaxinvadd wa_cntaxadd-HouseNumber INTO cntaxinvadd.
    ENDIF.
    IF wa_cntaxadd-StreetName IS NOT INITIAL.
      IF cntaxinvadd IS NOT INITIAL.
        CONCATENATE cntaxinvadd ',' INTO cntaxinvadd .
      ENDIF.
      CONCATENATE cntaxinvadd wa_cntaxadd-StreetName INTO cntaxinvadd.
    ENDIF.
    IF wa_cntaxadd-StreetPrefixName1 IS NOT INITIAL.
      IF cntaxinvadd IS NOT INITIAL.
        CONCATENATE cntaxinvadd ',' INTO cntaxinvadd .
      ENDIF.
      CONCATENATE cntaxinvadd wa_cntaxadd-StreetPrefixName1 INTO cntaxinvadd.
    ENDIF.
    IF wa_cntaxadd-StreetPrefixName2 IS NOT INITIAL.
      IF cntaxinvadd IS NOT INITIAL.
        CONCATENATE cntaxinvadd ',' INTO cntaxinvadd .
      ENDIF.
      CONCATENATE cntaxinvadd wa_cntaxadd-StreetPrefixName2 INTO cntaxinvadd.
    ENDIF.
    IF wa_cntaxadd-StreetSuffixName2 IS NOT INITIAL.
      IF cntaxinvadd IS NOT INITIAL.
        CONCATENATE cntaxinvadd ',' INTO cntaxinvadd .
      ENDIF.
      CONCATENATE cntaxinvadd wa_cntaxadd-StreetSuffixName1 INTO cntaxinvadd.
    ENDIF.
    IF wa_cntaxadd-StreetSuffixName2 IS NOT INITIAL.
      IF cntaxinvadd IS NOT INITIAL.
        CONCATENATE cntaxinvadd ',' INTO cntaxinvadd .
      ENDIF.
      CONCATENATE cntaxinvadd wa_cntaxadd-StreetSuffixName2 INTO cntaxinvadd.
    ENDIF.
    IF wa_cntaxadd-VillageName IS NOT INITIAL.
      IF cntaxinvadd IS NOT INITIAL.
        CONCATENATE cntaxinvadd ',' INTO cntaxinvadd .
      ENDIF.
      CONCATENATE cntaxinvadd wa_cntaxadd-VillageName INTO cntaxinvadd.
    ENDIF.
    IF wa_cntaxadd-DistrictName IS NOT INITIAL.
      IF cntaxinvadd IS NOT INITIAL.
        CONCATENATE cntaxinvadd ',' INTO cntaxinvadd .
      ENDIF.
      CONCATENATE cntaxinvadd wa_cntaxadd-DistrictName INTO cntaxinvadd.
    ENDIF.
    IF wa_cntaxadd-CityName IS NOT INITIAL.
      IF cntaxinvadd IS NOT INITIAL.
        CONCATENATE cntaxinvadd ',' INTO cntaxinvadd .
      ENDIF.
      CONCATENATE cntaxinvadd wa_cntaxadd-CityName INTO cntaxinvadd.
    ENDIF.
    IF wa_cntaxadd-RegionName IS NOT INITIAL.
      IF cntaxinvadd IS NOT INITIAL.
        CONCATENATE cntaxinvadd ',' INTO cntaxinvadd .
      ENDIF.
      CONCATENATE cntaxinvadd wa_cntaxadd-RegionName INTO cntaxinvadd.
    ENDIF.
    IF wa_cntaxadd-CountryName IS NOT INITIAL.
      IF cntaxinvadd IS NOT INITIAL.
        CONCATENATE cntaxinvadd ',' INTO cntaxinvadd .
      ENDIF.
      CONCATENATE cntaxinvadd wa_cntaxadd-CountryName INTO cntaxinvadd.
    ENDIF.
    IF wa_cntaxadd-PostalCode IS NOT INITIAL.
      IF cntaxinvadd IS NOT INITIAL.
        CONCATENATE cntaxinvadd '-' INTO cntaxinvadd .
      ENDIF.
      CONCATENATE cntaxinvadd wa_cntaxadd-PostalCode INTO cntaxinvadd.
    ENDIF.




*    CONCATENATE  strname strpre strsuf
*                ctyname regname
*                wa_cntaxadd-CountryName '-' wa_cntaxadd-PostalCode INTO  cntaxinvadd SEPARATED BY space.

**********************************************************************NEW LOGIC FOR  CN TAX INVOICE SHIPTO END


**********************************************************************NEW LOGIC FOR DN TAX INVOICE SHIP TO PARTY

    SELECT SINGLE FROM I_BillingDocument WITH PRIVILEGED ACCESS AS a
    LEFT JOIN I_BillingDocumentItem WITH PRIVILEGED ACCESS AS b ON b~BillingDocument = a~AssignmentReference
    LEFT JOIN I_DeliveryDocument WITH PRIVILEGED ACCESS AS c ON c~DeliveryDocument = b~ReferenceSDDocument
    LEFT JOIN I_BusinessPartner WITH PRIVILEGED ACCESS AS d ON d~BusinessPartner = c~ShipToParty
    LEFT JOIN I_Customer WITH PRIVILEGED ACCESS AS e ON e~Customer = c~ShipToParty AND e~Language = 'E'
    LEFT JOIN I_Address_2 WITH PRIVILEGED ACCESS  AS f   ON f~AddressID = e~AddressID
    LEFT JOIN I_CountryText WITH PRIVILEGED ACCESS AS g ON g~Country = f~Country AND g~Language = 'E'
    LEFT JOIN I_RegionText WITH PRIVILEGED ACCESS AS h ON h~Region = f~Region AND h~Language = 'E' AND h~Country = 'IN'
    LEFT JOIN I_BuPaIdentification AS i ON i~BusinessPartner = c~ShipToParty AND i~BPIdentificationType = 'FSSAI'
    FIELDS c~ShipToParty , d~BusinessPartnerFullName ,
           f~HouseNumber , f~StreetPrefixName1 , f~StreetPrefixName2 , f~StreetSuffixName1 , f~StreetSuffixName2 ,
           f~CityName , f~StreetName ,f~PostalCode , f~DistrictName , f~VillageName , g~CountryName  , h~RegionName , e~TaxNumber3 , e~TelephoneNumber1   , i~BPIdentificationNumber
    WHERE a~BillingDocument = @bill_doc
    INTO @DATA(wa_dntaxadd).



    SHIFT wa_dntaxadd-ShipToParty LEFT DELETING LEADING '0'.

*    DATA : strnamedn TYPE string.
*    DATA : strpredn TYPE string.
*    DATA : strsufdn TYPE string.
*    DATA : ctynamedn TYPE string.
*    DATA : regnamedn TYPE string.
*    CONCATENATE  wa_dntaxadd-StreetName ','  INTO strnamedn.
*    CONCATENATE wa_dntaxadd-StreetPrefixName1  wa_dntaxadd-StreetPrefixName2 INTO strpredn.
*    CONCATENATE wa_dntaxadd-StreetSuffixName1  wa_dntaxadd-StreetSuffixName2 INTO strsufdn.
*    CONCATENATE wa_dntaxadd-CityName  ','  INTO ctynamedn.
*    CONCATENATE wa_dntaxadd-RegionName  ',' INTO regnamedn.



    DATA : dntaxinvadd TYPE string .
*    dntaxinvadd = wa_dntaxadd-HouseNumber.

    IF wa_dntaxadd-HouseNumber IS NOT INITIAL.
      CONCATENATE dntaxinvadd wa_dntaxadd-HouseNumber INTO dntaxinvadd.
    ENDIF.
    IF wa_dntaxadd-StreetName IS NOT INITIAL.
      IF dntaxinvadd IS NOT INITIAL.
        CONCATENATE dntaxinvadd ',' INTO dntaxinvadd .
      ENDIF.
      CONCATENATE dntaxinvadd wa_dntaxadd-StreetName INTO dntaxinvadd.
    ENDIF.
    IF wa_dntaxadd-StreetPrefixName1 IS NOT INITIAL.
      IF dntaxinvadd IS NOT INITIAL.
        CONCATENATE dntaxinvadd ',' INTO dntaxinvadd .
      ENDIF.
      CONCATENATE dntaxinvadd wa_dntaxadd-StreetPrefixName1 INTO dntaxinvadd.
    ENDIF.
    IF wa_dntaxadd-StreetPrefixName2 IS NOT INITIAL.
      IF dntaxinvadd IS NOT INITIAL.
        CONCATENATE dntaxinvadd ',' INTO dntaxinvadd .
      ENDIF.
      CONCATENATE dntaxinvadd wa_dntaxadd-StreetPrefixName2 INTO dntaxinvadd.
    ENDIF.
    IF wa_dntaxadd-StreetSuffixName1 IS NOT INITIAL.
      IF dntaxinvadd IS NOT INITIAL.
        CONCATENATE dntaxinvadd ',' INTO dntaxinvadd .
      ENDIF.
      CONCATENATE dntaxinvadd wa_dntaxadd-StreetSuffixName1 INTO dntaxinvadd.
    ENDIF.
    IF wa_dntaxadd-StreetSuffixName2 IS NOT INITIAL.
      IF dntaxinvadd IS NOT INITIAL.
        CONCATENATE dntaxinvadd ',' INTO dntaxinvadd .
      ENDIF.
      CONCATENATE dntaxinvadd wa_dntaxadd-StreetSuffixName2 INTO dntaxinvadd.
    ENDIF.
    IF wa_dntaxadd-VillageName IS NOT INITIAL.
      IF dntaxinvadd IS NOT INITIAL.
        CONCATENATE dntaxinvadd ',' INTO dntaxinvadd .
      ENDIF.
      CONCATENATE dntaxinvadd wa_dntaxadd-VillageName INTO dntaxinvadd.
    ENDIF.
    IF wa_dntaxadd-DistrictName IS NOT INITIAL.
      IF dntaxinvadd IS NOT INITIAL.
        CONCATENATE dntaxinvadd ',' INTO dntaxinvadd .
      ENDIF.
      CONCATENATE dntaxinvadd wa_dntaxadd-DistrictName INTO dntaxinvadd.
    ENDIF.
    IF wa_dntaxadd-CityName IS NOT INITIAL.
      IF dntaxinvadd IS NOT INITIAL.
        CONCATENATE dntaxinvadd ',' INTO dntaxinvadd .
      ENDIF.
      CONCATENATE dntaxinvadd wa_dntaxadd-CityName INTO dntaxinvadd.
    ENDIF.
    IF wa_dntaxadd-RegionName IS NOT INITIAL.
      IF dntaxinvadd IS NOT INITIAL.
        CONCATENATE dntaxinvadd ',' INTO dntaxinvadd .
      ENDIF.
      CONCATENATE dntaxinvadd wa_dntaxadd-RegionName INTO dntaxinvadd.
    ENDIF.
    IF wa_dntaxadd-CountryName IS NOT INITIAL.
      IF dntaxinvadd IS NOT INITIAL.
        CONCATENATE dntaxinvadd ',' INTO dntaxinvadd .
      ENDIF.
      CONCATENATE dntaxinvadd wa_dntaxadd-CountryName INTO dntaxinvadd.
    ENDIF.
    IF wa_dntaxadd-PostalCode IS NOT INITIAL.
      IF dntaxinvadd IS NOT INITIAL.
        CONCATENATE dntaxinvadd '-' INTO dntaxinvadd .
      ENDIF.
      CONCATENATE dntaxinvadd wa_dntaxadd-PostalCode INTO dntaxinvadd.
    ENDIF.


*    CONCATENATE  strnamedn strpredn strsufdn
*                ctynamedn regnamedn
*                wa_dntaxadd-CountryName '-' wa_dntaxadd-PostalCode INTO  dntaxinvadd SEPARATED BY space.




**********************************************************************NEW LOGIC FOR DN TAX INVOICE SHIP TO PARTY END


**********************************************************************ZIRN LOGIC FOR LR NO & VEHICLENO & TRANSPORTMODE & LR DATE END

*SELECT SINGLE FROM I_BillingDocument AS A
*LEFT JOIN ztable_irn AS B ON B~billingdocno = A~BillingDocument
*FIELDS A~BillingDocument , B~vehiclenum , B~transportername , B~grno , B~grdate
*WHERE A~BillingDocument = @bill_doc
*INTO @DATA(WA_IRN).


**********************************************************************ZIRN LOGIC FOR LR NO & VEHICLENO & TRANSPORTMODE & LR DATE END

    p_add1 = wa_header-address1 .
    p_add2 = wa_header-address2 .
    p_dist = wa_header-district .
    p_city = wa_header-city .
    p_state = wa_header-state_name .
    p_pin =  wa_header-pin .
    p_country =   wa_header-Country  .

    CONCATENATE  '-' p_pin INTO p_pin SEPARATED BY space.
*      CONCATENATE p_add1  p_add2  p_dist p_city   p_state '-' p_pin  p_country INTO plant_add SEPARATED BY space.

    plant_name = wa_header-plant_name1.
    plant_gstin = wa_header-gstin_no.



**********************************************************************TransporterName

    SELECT SINGLE
    a~billingdocument,
    c~suppliername
    FROM i_billingdocument AS a
    LEFT JOIN i_billingdocumentpartner AS b ON b~BillingDocument = a~billingdocument
    LEFT JOIN I_Supplier AS c ON c~Supplier = b~Supplier
    WHERE a~billingdocument = @bill_doc
    AND b~PartnerFunction = 'SP'
    INTO @DATA(wa_tn)
    PRIVILEGED ACCESS.


*************************************************************************************

*********************************************************************************EMAIL


    SELECT SINGLE FROM i_BillingDocumentItem AS a
    LEFT JOIN i_plant  AS b ON a~plant = b~plant
    LEFT JOIN i_customer AS c ON b~PlantCustomer = c~customer
    LEFT JOIN i_addressemailaddress_2 AS d ON d~addressid = c~addressid
    LEFT JOIN ztable_plant AS e ON e~plant_code = a~Plant
    FIELDS a~billingdocument ,
    d~emailaddress ,
    e~email
    WHERE a~billingdocument = @bill_doc
    INTO @DATA(wa_email)
    PRIVILEGED ACCESS.


**************************************************************************************


**********************************************************************BROKERName

    SELECT SINGLE
    a~billingdocument,
    c~suppliername
    FROM i_billingdocument AS a
    LEFT JOIN i_billingdocumentpartner AS b ON b~BillingDocument = a~billingdocument
    LEFT JOIN I_Supplier AS c ON c~Supplier = b~Supplier
    WHERE a~billingdocument = @bill_doc
    AND b~PartnerFunction = 'ES'
    INTO @DATA(wa_br)
    PRIVILEGED ACCESS.




*************************************************************************BROKERName END



    """""""""""""""""""""""""""""""""   BILL TO """""""""""""""""""""""""""""""""
    SELECT SINGLE
  d~streetname ,         " bill to add
  d~streetprefixname1 ,   " bill to add
  d~streetprefixname2 ,   " bill to add
  d~cityname ,   " bill to add
  d~region ,  "bill to add
  d~postalcode ,   " bill to add
  d~districtname ,   " bill to add
  d~country  ,
  d~housenumber ,
  c~customername,
  e~regionname,
  f~countryname,
  c~taxnumber3,
  d~streetsuffixname1,
  d~streetsuffixname2
 FROM I_BillingDocument AS a
 LEFT JOIN i_billingdocumentpartner AS b ON b~billingdocument = a~billingdocument
 LEFT JOIN i_customer AS c ON c~customer = b~Customer
 LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
 LEFT JOIN i_regiontext AS e ON e~Region = c~Region AND e~Language = 'E' AND c~Country = e~Country
 LEFT JOIN i_countrytext AS f ON d~Country = f~Country
 WHERE b~partnerFunction = 'RE' AND  a~BillingDocument = @bill_doc
 INTO @DATA(wa_bill)
 PRIVILEGED ACCESS.

    DATA : Post_Ctry TYPE string.
    Post_Ctry =   wa_bill-PostalCode .
    CONCATENATE '-' Post_Ctry INTO Post_Ctry SEPARATED BY space.
*Concatenate   wa_bill-STREETSUFFIXNAME1 post_ctry into wa_bill-STREETSUFFIXNAME1 .

    DATA : Streetprefixxname TYPE string.
    Streetprefixxname = wa_bill-StreetPrefixName1 && '' && wa_bill-StreetPrefixName2 && ''.

    DATA : StreetSuffixname TYPE string.
    StreetSuffixname = wa_bill-StreetSuffixName1 && ' ' && wa_bill-StreetSuffixName2 && ''.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""SHIP TO  Address
*     SELECT SINGLE
*     d~streetname ,
*     d~streetprefixname1 ,
*     d~streetprefixname2 ,
*     d~cityname ,
*     d~region ,
*     d~postalcode ,
*     d~districtname ,
*     d~country  ,
*     d~housenumber ,
*     c~customername ,
*     a~soldtoparty ,
*     e~regionname ,
*     c~taxnumber3 ,
*     d~STREETSUFFIXNAME1,
*     d~STREETSUFFIXNAME2 ,
*     f~countryname
*    FROM I_BillingDocumentitem AS a
*    LEFT JOIN i_billingdocumentpartner AS b ON b~billingdocument = a~billingdocument
*    LEFT JOIN i_customer AS c ON c~customer = b~Customer
*    LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
*    LEFT JOIN I_RegionText AS e on e~Region = d~Region and e~Country = d~Country
*    LEFT JOIN i_countrytext AS f ON d~Country = f~Country
*    WHERE b~partnerFunction = 'WE'
*    and c~Language = 'E'
*    and a~BillingDocument = @bill_doc
*    INTO @DATA(wa_ship)
*    PRIVILEGED ACCESS.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""SHIP TO  Address LATEST

    SELECT SINGLE
    a~billingdocument ,
    c~businesspartnerfullname ,
    e~housenumber ,
    e~streetname ,
    e~streetprefixname1 ,
    e~streetprefixname2 ,
    e~streetsuffixname1 ,
    e~streetsuffixname2 ,
    e~cityname ,
    f~regionname ,
    g~countryname ,
    e~postalcode ,
    e~districtname ,
    d~taxnumber3
    FROM i_billingdocumentitem AS a
    LEFT JOIN i_deliverydocument AS b ON b~DeliveryDocument = a~ReferenceSDDocument
    LEFT JOIN i_businesspartner AS c ON c~BusinessPartner = b~ShipToParty
    LEFT JOIN i_customer AS d ON d~Customer = b~ShipToParty
    LEFT JOIN i_address_2 AS e ON e~AddressID = d~AddressID
    LEFT JOIN I_RegionText AS f ON f~Region = e~Region AND f~Language = 'E' AND d~Country = f~Country
    LEFT JOIN I_CountryText AS g ON g~Country = e~Country
    WHERE a~BillingDocument = @bill_doc
    INTO @DATA(wa_ship2)
    PRIVILEGED ACCESS.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""SHIP TO  Address LATEST

    DATA : shipPost_Ctry TYPE string.
    shipPost_Ctry =  wa_ship2-PostalCode .
    CONCATENATE  '-'  shipPost_Ctry INTO shipPost_Ctry SEPARATED BY space.
*Concatenate   wa_ship-STREETSUFFIXNAME1 shipPost_Ctry into wa_ship-STREETSUFFIXNAME1 .

    DATA : ShipStreetprefixxname TYPE string.
    ShipStreetprefixxname = wa_ship2-StreetPrefixName1 && '' && wa_ship2-StreetPrefixName2 && ''.

    DATA : ShipStreetSuffixname TYPE string.
    ShipStreetSuffixname = wa_ship2-StreetSuffixName1 && ' ' && wa_ship2-StreetSuffixName2 && ''.

    DATA : wa_ad5 TYPE string.
    wa_ad5 = wa_bill-PostalCode.
    CONCATENATE wa_ad5 wa_bill-CityName  wa_bill-DistrictName INTO wa_ad5 SEPARATED BY space.

    DATA : wa_ad5_ship TYPE string.
    wa_ad5_ship = wa_ship2-PostalCode.
    CONCATENATE wa_ad5_ship wa_ship2-CityName  wa_ship2-DistrictName INTO wa_ad5_ship SEPARATED BY space.







**********************************************************************NEW BILL AND SHIP ADD 12/05/2025


    SELECT SINGLE FROM I_BillingDocument AS a
    LEFT JOIN i_billingdocumentpartner AS b ON b~billingdocument = a~billingdocument
    LEFT JOIN i_customer AS c ON c~customer = b~Customer
    LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
    LEFT JOIN i_regiontext AS e ON e~Region = c~Region AND e~Language = 'E' AND c~Country = e~Country AND e~Country = 'IN'
    LEFT JOIN i_countrytext AS f ON d~Country = f~Country
    FIELDS   d~streetname ,         " bill to add
      d~streetprefixname1 ,   " bill to add
      d~streetprefixname2 ,   " bill to add
      d~cityname ,   " bill to add
      d~region ,  "bill to add
      d~postalcode ,   " bill to add
      d~districtname ,   " bill to add
      d~country  ,
      d~housenumber ,
      c~customername,
      e~regionname,
      f~countryname,
      c~taxnumber3,
      d~streetsuffixname1,
      d~streetsuffixname2,
      d~VillageName
    WHERE b~partnerFunction = 'RE' AND  a~BillingDocument = @bill_doc
    INTO @DATA(wa_billnew)
    PRIVILEGED ACCESS.


    DATA : bill_addressnew TYPE string.

    IF wa_billnew-HouseNumber IS NOT INITIAL.
      CONCATENATE bill_addressnew wa_billnew-HouseNumber INTO bill_addressnew.
    ENDIF.
    IF wa_billnew-StreetName IS NOT INITIAL.
      IF bill_addressnew IS NOT INITIAL.
        CONCATENATE bill_addressnew ',' INTO bill_addressnew .
      ENDIF.
      CONCATENATE bill_addressnew wa_billnew-StreetName INTO bill_addressnew.
    ENDIF.
    IF wa_billnew-StreetPrefixName1 IS NOT INITIAL.
      IF bill_addressnew IS NOT INITIAL.
        CONCATENATE bill_addressnew ',' INTO bill_addressnew .
      ENDIF.
      CONCATENATE bill_addressnew wa_billnew-StreetPrefixName1 INTO bill_addressnew.
    ENDIF.
    IF wa_billnew-StreetPrefixName2 IS NOT INITIAL.
      IF bill_addressnew IS NOT INITIAL.
        CONCATENATE bill_addressnew ',' INTO bill_addressnew .
      ENDIF.
      CONCATENATE bill_addressnew wa_billnew-StreetPrefixName2 INTO bill_addressnew.
    ENDIF.
    IF wa_billnew-StreetSuffixName1 IS NOT INITIAL.
      IF bill_addressnew IS NOT INITIAL.
        CONCATENATE bill_addressnew ',' INTO bill_addressnew .
      ENDIF.
      CONCATENATE bill_addressnew wa_billnew-StreetSuffixName1 INTO bill_addressnew.
    ENDIF.
    IF wa_billnew-StreetSuffixName2 IS NOT INITIAL.
      IF bill_addressnew IS NOT INITIAL.
        CONCATENATE bill_addressnew ',' INTO bill_addressnew .
      ENDIF.
      CONCATENATE bill_addressnew wa_billnew-StreetSuffixName2 INTO bill_addressnew.
    ENDIF.
    IF wa_billnew-VillageName IS NOT INITIAL.
      IF bill_addressnew IS NOT INITIAL.
        CONCATENATE bill_addressnew ',' INTO bill_addressnew .
      ENDIF.
      CONCATENATE bill_addressnew wa_billnew-VillageName INTO bill_addressnew.
    ENDIF.
    IF wa_billnew-DistrictName IS NOT INITIAL.
      IF bill_addressnew IS NOT INITIAL.
        CONCATENATE bill_addressnew ',' INTO bill_addressnew .
      ENDIF.
      CONCATENATE bill_addressnew wa_billnew-DistrictName INTO bill_addressnew.
    ENDIF.
    IF wa_billnew-CityName IS NOT INITIAL.
      IF bill_addressnew IS NOT INITIAL.
        CONCATENATE bill_addressnew ',' INTO bill_addressnew .
      ENDIF.
      CONCATENATE bill_addressnew wa_billnew-CityName INTO bill_addressnew.
    ENDIF.
    IF wa_billnew-RegionName IS NOT INITIAL.
      IF bill_addressnew IS NOT INITIAL.
        CONCATENATE bill_addressnew ',' INTO bill_addressnew .
      ENDIF.
      CONCATENATE bill_addressnew wa_billnew-RegionName INTO bill_addressnew.
    ENDIF.
    IF wa_billnew-CountryName IS NOT INITIAL.
      IF bill_addressnew IS NOT INITIAL.
        CONCATENATE bill_addressnew ',' INTO bill_addressnew .
      ENDIF.
      CONCATENATE bill_addressnew wa_billnew-CountryName INTO bill_addressnew.
    ENDIF.
    IF wa_billnew-PostalCode IS NOT INITIAL.
      IF bill_addressnew IS NOT INITIAL.
        CONCATENATE bill_addressnew '-' INTO bill_addressnew .
      ENDIF.
      CONCATENATE bill_addressnew wa_billnew-PostalCode INTO bill_addressnew.
    ENDIF.


*CONCATENATE wa_billnew-StreetName STRPREBILL STRSUFBILL
*             wa_billnew-DistrictName ',' wa_billnew-VillageName ','
*             wa_billnew-CityName ',' wa_billnew-RegionName ','
*             wa_billnew-CountryName '-' wa_billnew-PostalCode INTO BILL_ADDRESSNEW SEPARATED BY SPACE.



    SELECT SINGLE  FROM i_billingdocumentitem AS a
        LEFT JOIN i_deliverydocument AS b ON b~DeliveryDocument = a~ReferenceSDDocument
        LEFT JOIN i_businesspartner AS c ON c~BusinessPartner = b~ShipToParty
        LEFT JOIN i_customer AS d ON d~Customer = b~ShipToParty
        LEFT JOIN i_address_2 AS e ON e~AddressID = d~AddressID
        LEFT JOIN I_RegionText AS f ON f~Region = e~Region AND f~Language = 'E' AND d~Country = f~Country
        LEFT JOIN I_CountryText AS g ON g~Country = e~Country
        FIELDS a~billingdocument ,
        c~businesspartnerfullname ,
        e~housenumber ,
        e~streetname ,
        e~streetprefixname1 ,
        e~streetprefixname2 ,
        e~streetsuffixname1 ,
        e~streetsuffixname2 ,
        e~cityname ,
        f~regionname ,
        g~countryname ,
        e~postalcode ,
        e~districtname ,
        d~taxnumber3 ,
        e~VillageName
        WHERE a~BillingDocument = @bill_doc
        INTO @DATA(wa_ship2new)
        PRIVILEGED ACCESS.

    DATA : ship_addressnew TYPE string.
*DATA : STRPRESHIP TYPE STRING.
*DATA : STRSUFSHIP TYPE STRING.
*STRPRESHIP = wa_ship2new-StreetPrefixName1 && wa_ship2new-StreetPrefixName2.
*STRSUFSHIP = wa_ship2new-StreetSuffixName1 && wa_ship2new-StreetSuffixName2.
*SHIP_ADDRESSNEW = wa_ship2new-HouseNumber.


    IF wa_ship2new-HouseNumber IS NOT INITIAL.
      CONCATENATE ship_addressnew wa_ship2new-HouseNumber INTO ship_addressnew.
    ENDIF.
    IF wa_ship2new-StreetName IS NOT INITIAL.
      IF ship_addressnew IS NOT INITIAL.
        CONCATENATE ship_addressnew ',' INTO ship_addressnew .
      ENDIF.
      CONCATENATE ship_addressnew wa_ship2new-StreetName INTO ship_addressnew.
    ENDIF.
    IF wa_ship2new-StreetPrefixName1 IS NOT INITIAL.
      IF ship_addressnew IS NOT INITIAL.
        CONCATENATE ship_addressnew ',' INTO ship_addressnew .
      ENDIF.
      CONCATENATE ship_addressnew wa_ship2new-StreetPrefixName1 INTO ship_addressnew.
    ENDIF.
    IF wa_ship2new-StreetPrefixName2 IS NOT INITIAL.
      IF ship_addressnew IS NOT INITIAL.
        CONCATENATE ship_addressnew ',' INTO ship_addressnew .
      ENDIF.
      CONCATENATE ship_addressnew wa_ship2new-StreetPrefixName2 INTO ship_addressnew.
    ENDIF.
    IF wa_ship2new-StreetSuffixName2 IS NOT INITIAL.
      IF ship_addressnew IS NOT INITIAL.
        CONCATENATE ship_addressnew ',' INTO ship_addressnew .
      ENDIF.
      CONCATENATE ship_addressnew wa_ship2new-StreetSuffixName1 INTO ship_addressnew.
    ENDIF.
    IF wa_ship2new-StreetSuffixName2 IS NOT INITIAL.
      IF ship_addressnew IS NOT INITIAL.
        CONCATENATE ship_addressnew ',' INTO ship_addressnew .
      ENDIF.
      CONCATENATE ship_addressnew wa_ship2new-StreetSuffixName2 INTO ship_addressnew.
    ENDIF.
    IF wa_ship2new-VillageName IS NOT INITIAL.
      IF ship_addressnew IS NOT INITIAL.
        CONCATENATE ship_addressnew ',' INTO ship_addressnew .
      ENDIF.
      CONCATENATE ship_addressnew wa_ship2new-VillageName INTO ship_addressnew.
    ENDIF.
    IF wa_ship2new-DistrictName IS NOT INITIAL.
      IF ship_addressnew IS NOT INITIAL.
        CONCATENATE ship_addressnew ',' INTO ship_addressnew .
      ENDIF.
      CONCATENATE ship_addressnew wa_ship2new-DistrictName INTO ship_addressnew.
    ENDIF.
    IF wa_ship2new-CityName IS NOT INITIAL.
      IF ship_addressnew IS NOT INITIAL.
        CONCATENATE ship_addressnew ',' INTO ship_addressnew .
      ENDIF.
      CONCATENATE ship_addressnew wa_ship2new-CityName INTO ship_addressnew.
    ENDIF.
    IF wa_ship2new-RegionName IS NOT INITIAL.
      IF ship_addressnew IS NOT INITIAL.
        CONCATENATE ship_addressnew ',' INTO ship_addressnew .
      ENDIF.
      CONCATENATE ship_addressnew wa_ship2new-RegionName INTO ship_addressnew.
    ENDIF.
    IF wa_ship2new-CountryName IS NOT INITIAL.
      IF ship_addressnew IS NOT INITIAL.
        CONCATENATE ship_addressnew ',' INTO ship_addressnew .
      ENDIF.
      CONCATENATE ship_addressnew wa_ship2new-CountryName INTO ship_addressnew.
    ENDIF.
    IF wa_ship2new-PostalCode IS NOT INITIAL.
      IF ship_addressnew IS NOT INITIAL.
        CONCATENATE ship_addressnew '-' INTO ship_addressnew .
      ENDIF.
      CONCATENATE ship_addressnew wa_ship2new-PostalCode INTO ship_addressnew.
    ENDIF.


*    CONCATENATE wa_ship2new-StreetName STRPRESHIP STRSUFSHIP
*             wa_ship2new-DistrictName ',' wa_ship2new-VillageName ','
*             wa_ship2new-CityName ',' wa_ship2new-RegionName ','
*             wa_ship2new-CountryName '-' wa_ship2new-PostalCode INTO SHIP_ADDRESSNEW SEPARATED BY SPACE.
*



    SELECT SINGLE FROM I_BillingDocumentItem AS a
    LEFT JOIN ztable_plant AS b ON b~plant_code = a~Plant
    FIELDS b~address1 , b~address2 , b~city , b~state_name , b~country , b~pin
    WHERE a~BillingDocument = @bill_doc
    INTO @DATA(wa_branchadd).

    DATA : branchaddnew TYPE string.
    CONCATENATE wa_branchadd-address1 ',' wa_branchadd-address2  wa_branchadd-city ','
                wa_branchadd-state_name ',' wa_branchadd-country '-' wa_branchadd-pin
                INTO branchaddnew SEPARATED BY space.


**********************************************************************NEW BILL AND SHIP ADD 12/05/2025 END


**********************************************************************BILLTOPARTY FSSAINO
    SELECT SINGLE
    a~billingdocument ,
    b~bpidentificationnumber
    FROM i_billingdocument AS a
    LEFT JOIN I_BuPaIdentification AS b ON b~BusinessPartner = a~PayerParty
    WHERE a~BillingDocument = @bill_doc
    AND b~BPIdentificationType = 'FSSAI'
    INTO @DATA(wa_billfssai) .

**********************************************************************BILLTOPARTY FSSAINO END


**********************************************************************BILLTOPARTY FSSAINO

    SELECT SINGLE
    a~billingdocument ,
    d~bpidentificationnumber
    FROM i_billingdocument AS a
    LEFT JOIN  i_billingdocumentitem AS b ON b~billingdocument = a~billingdocument
    LEFT JOIN I_DeliveryDocument AS c ON c~DeliveryDocument = b~ReferenceSDDocument
    LEFT JOIN i_bupaidentification AS d ON d~BusinessPartner = c~ShipToParty
    WHERE a~BillingDocument = @bill_doc
    AND d~BPIdentificationType = 'FSSAI'
    INTO @DATA(wa_shipfssai).

**********************************************************************BILLTOPARTY FSSAINO END

**********************************************************************SHIP TO FOR CN WITHOUT REFERENEC

    SELECT SINGLE FROM i_billingdocumentitem AS a
    LEFT JOIN i_salesdocumentitem AS b ON b~SalesDocument = a~ReferenceSDDocument AND b~SalesDocumentItem = a~BillingDocumentItem
    LEFT JOIN i_customer AS c ON c~Customer = b~ShipToParty AND c~Language = 'E'
    LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
    LEFT JOIN I_RegionText AS e ON e~Region = d~Region AND e~Language = 'E' AND e~Country = 'IN'
    LEFT JOIN I_CountryText AS f ON f~Country = d~Country AND f~Language = 'E'
    LEFT JOIN I_BuPaIdentification AS g ON g~BusinessPartner = b~ShipToParty AND g~BPIdentificationType = 'FSSAI'
    FIELDS b~ShipToParty , c~CustomerName , d~HouseNumber , d~StreetName , d~StreetPrefixName1 ,
           d~StreetPrefixName2 , d~StreetSuffixName2 , d~DistrictName , d~VillageName , d~CityName ,
           e~RegionName , f~CountryName , d~PostalCode , c~TelephoneNumber1 , c~TaxNumber3 , g~BPIdentificationNumber
    WHERE a~BillingDocument = @bill_doc
    INTO @DATA(wa_cnwithoutadd)
    PRIVILEGED ACCESS.

    SHIFT wa_cnwithoutadd-ShipToParty LEFT DELETING LEADING '0'.

    DATA : cnwithoutadd TYPE string.

    IF wa_cnwithoutadd-HouseNumber IS NOT INITIAL.
      CONCATENATE cnwithoutadd wa_cnwithoutadd-HouseNumber INTO cnwithoutadd.
    ENDIF.
    IF wa_cnwithoutadd-StreetName IS NOT INITIAL.
      IF cnwithoutadd IS NOT INITIAL.
        CONCATENATE cnwithoutadd ',' INTO cnwithoutadd .
      ENDIF.
      CONCATENATE cnwithoutadd wa_cnwithoutadd-StreetName INTO cnwithoutadd.
    ENDIF.
    IF wa_cnwithoutadd-StreetPrefixName1 IS NOT INITIAL.
      IF cnwithoutadd IS NOT INITIAL.
        CONCATENATE cnwithoutadd ',' INTO cnwithoutadd .
      ENDIF.
      CONCATENATE cnwithoutadd wa_cnwithoutadd-StreetPrefixName1 INTO cnwithoutadd.
    ENDIF.
    IF wa_cnwithoutadd-StreetPrefixName2 IS NOT INITIAL.
      IF cnwithoutadd IS NOT INITIAL.
        CONCATENATE cnwithoutadd ',' INTO cnwithoutadd .
      ENDIF.
      CONCATENATE cnwithoutadd wa_cnwithoutadd-StreetPrefixName2 INTO cnwithoutadd.
    ENDIF.
    IF wa_cnwithoutadd-StreetSuffixName2 IS NOT INITIAL.
      IF cnwithoutadd IS NOT INITIAL.
        CONCATENATE cnwithoutadd ',' INTO cnwithoutadd .
      ENDIF.
      CONCATENATE cnwithoutadd wa_cnwithoutadd-StreetSuffixName2 INTO cnwithoutadd.
    ENDIF.
    IF wa_cnwithoutadd-DistrictName IS NOT INITIAL.
      IF cnwithoutadd IS NOT INITIAL.
        CONCATENATE cnwithoutadd ',' INTO cnwithoutadd .
      ENDIF.
      CONCATENATE cnwithoutadd wa_cnwithoutadd-DistrictName INTO cnwithoutadd.
    ENDIF.
    IF wa_cnwithoutadd-VillageName IS NOT INITIAL.
      IF cnwithoutadd IS NOT INITIAL.
        CONCATENATE cnwithoutadd ',' INTO cnwithoutadd .
      ENDIF.
      CONCATENATE cnwithoutadd wa_cnwithoutadd-VillageName INTO cnwithoutadd.
    ENDIF.
    IF wa_cnwithoutadd-CityName IS NOT INITIAL.
      IF cnwithoutadd IS NOT INITIAL.
        CONCATENATE cnwithoutadd ',' INTO cnwithoutadd .
      ENDIF.
      CONCATENATE cnwithoutadd wa_cnwithoutadd-CityName INTO cnwithoutadd.
    ENDIF.
    IF wa_cnwithoutadd-RegionName IS NOT INITIAL.
      IF cnwithoutadd IS NOT INITIAL.
        CONCATENATE cnwithoutadd ',' INTO cnwithoutadd .
      ENDIF.
      CONCATENATE cnwithoutadd wa_cnwithoutadd-RegionName INTO cnwithoutadd.
    ENDIF.
    IF wa_cnwithoutadd-CountryName IS NOT INITIAL.
      IF cnwithoutadd IS NOT INITIAL.
        CONCATENATE cnwithoutadd ',' INTO cnwithoutadd .
      ENDIF.
      CONCATENATE cnwithoutadd wa_cnwithoutadd-CountryName INTO cnwithoutadd.
    ENDIF.
    IF wa_cnwithoutadd-PostalCode IS NOT INITIAL.
      IF cnwithoutadd IS NOT INITIAL.
        CONCATENATE cnwithoutadd '-' INTO cnwithoutadd .
      ENDIF.
      CONCATENATE cnwithoutadd wa_cnwithoutadd-PostalCode INTO cnwithoutadd.
    ENDIF.




**********************************************************************SHIP TO FOR CN WITHOUT REFERENEC END

**********************************************************************NUTRICA DISPATCH FROM DETAILS


    SELECT SINGLE FROM i_billingdocumentitem AS a
    LEFT JOIN ztable_plant AS b ON b~plant_code = a~Plant
    FIELDS b~address1 , b~address2 , b~city , b~state_name , b~state_code1 , b~gstin_no
    WHERE a~BillingDocument = @bill_doc
    INTO @DATA(wa_nutadd).

    DATA : nutadd TYPE string.
    CONCATENATE wa_nutadd-address1 wa_nutadd-address2 wa_nutadd-city INTO nutadd SEPARATED BY space.

**********************************************************************NUTRICA DISPATCH FROM DETAILS END



    SELECT SINGLE
    a~billingdocument ,
    c~plantname ,
    d~streetname ,
    d~streetprefixname1 ,
    d~streetprefixname2 ,
    d~streetsuffixname1 ,
    d~streetsuffixname2 ,
    d~cityname ,
    d~region ,
    d~postalcode ,
    d~districtname ,
    d~country  ,
    d~housenumber ,
    e~regionname ,
    f~countryname
    FROM i_billingdocument AS a
    LEFT JOIN i_billingdocumentitem AS b ON b~BillingDocument = a~BillingDocument
    LEFT JOIN i_plant AS c ON c~Plant = b~Plant
    LEFT JOIN i_address_2 AS d ON d~AddressID = c~AddressID
    LEFT JOIN I_RegionText AS e ON e~Region = d~Region AND e~Country = d~Country
    LEFT JOIN i_countrytext AS f ON d~Country = f~Country
    WHERE a~billingdocument = @bill_doc
    INTO @DATA(wa_company)
    PRIVILEGED ACCESS.



    DATA : ship_post TYPE string.
    ship_post = wa_company-PostalCode.
    CONCATENATE '-' ship_post INTO ship_post SEPARATED BY space.
    DATA : CompStreetprefixxname TYPE string.
    CompStreetprefixxname = wa_company-StreetPrefixName1 && '' && wa_company-StreetPrefixName2 && ''.

    DATA : CompStreetSuffixname TYPE string.
    CompStreetSuffixname = wa_company-StreetSuffixName1 && ' ' && wa_company-StreetSuffixName2 && ''.

**********************************************************************COMPANYDETAILS END


    """""""""""""""""""""""""""""""""""ITEM DETAILS"""""""""""""""""""""""""""""""""""

    SELECT
      a~billingdocument,
      a~billingdocumentitem,
      a~product,
      a~netamount,
      b~handlingunitreferencedocument,
      b~material,
      b~handlingunitexternalid,
      c~packagingmaterial,
      d~productdescription,
      e~materialbycustomer ,
      f~consumptiontaxctrlcode  ,   "HSN CODE
      a~billingdocumentitemtext ,   "mat
*12.03        e~yy1_packsize_sd_sdi  ,  "i_avgpkg
      a~billingquantity  ,  "Quantity
      a~billingquantityunit  ,  "UOM
      a~baseunit ,
*12.03        e~yy1_packsize_sd_sdiu  ,   " package_qtyunit
*12.03        e~yy1_noofpack_sd_sdi  ,   " avg_content
*      g~conditionratevalue   ,  " i_per
*      g~conditionamount ,
*      g~conditionbasevalue,
*      g~conditiontype ,
      a~billingtobasequantitynmrtr ,
      a~billingtobasequantitydnmntr ,
      a~itemNETweight ,
      a~referencesddocument AS rsd ,
      j~referencesddocument ,
      a~Batch ,
      a~ItemWeightUnit ,
      j~netpricequantityunit ,
      j~orderquantityunit ,
      a~salesdocument ,
      a~salesdocumentitem ,
      a~billingquantityinbaseunit ,
      a~referencesddocument AS obdnum ,
      l~netpriceamount
      FROM I_BillingDocumentItem AS a
      LEFT JOIN i_handlingunititem AS b ON a~referencesddocument = b~handlingunitreferencedocument
      LEFT JOIN i_handlingunitheader AS c ON b~handlingunitexternalid = c~handlingunitexternalid
      LEFT JOIN i_productdescription AS d ON d~product = a~product
      LEFT JOIN I_SalesDocumentItem AS e ON e~SalesDocument = a~SalesDocument AND e~salesdocumentitem = a~salesdocumentitem
      LEFT JOIN i_productplantbasic AS f ON a~Product = f~Product AND a~Plant = f~Plant
*      LEFT JOIN i_billingdocumentitemprcgelmnt AS g ON g~BillingDocument = a~BillingDocument  AND g~BillingDocumentItem = a~BillingDocumentItem
      LEFT JOIN i_deliverydocumentitem AS h ON h~DeliveryDocument =  a~ReferenceSDDocument AND h~DeliveryDocumentItem = a~ReferenceSDDocumentItem
      LEFT JOIN I_SalesOrderItem AS j ON j~SalesOrder = h~ReferenceSDDocument AND  j~SalesOrderItem = h~ReferenceSDDocumentItem
      LEFT JOIN i_materialdocumentitem_2 AS k ON k~MaterialDocument = a~ReferenceSDDocument AND k~MaterialDocumentItem = a~ReferenceSDDocumentItem
      LEFT JOIN I_PurchaseOrderItemAPI01 AS l ON l~PurchaseOrder = k~PurchaseOrder AND l~PurchaseOrderItem = k~PurchaseOrderItem
      WHERE a~billingdocument = @bill_doc
      INTO TABLE  @DATA(it_item)
      PRIVILEGED ACCESS.

**********************************************************************CONDITION TYPE ZPR0



    SELECT billingdocument,
       billingdocumentitem,
       conditiontype,
       conditionratevalue,
       conditionbasevalue,
       conditionamount
FROM i_billingdocumentitemprcgelmnt
WHERE billingdocument = @bill_doc
INTO TABLE @DATA(it_conditions_ZPR0).




**********************************************************************CONDITION TYPE ZPR0 END

**********************************************************************CONDITION TYPE ZCIP

    SELECT billingdocument,
        billingdocumentitem,
        conditiontype,
        conditionratevalue,
        conditionbasevalue,
        conditionamount
 FROM i_billingdocumentitemprcgelmnt
 WHERE billingdocument = @bill_doc
 INTO TABLE @DATA(it_conditions_ZCIP).



**********************************************************************CONDITION TYPE ZCIP END

********************************************************************** Nutrica MRP

    SELECT FROM i_billingdocumentitemprcgelmnt
      FIELDS billingdocument,
             billingdocumentitem,
             conditiontype,
             ConditionRateAmount
     WHERE billingdocument = @bill_doc
     INTO TABLE @DATA(it_conditions_ZMRP).


    SELECT FROM i_billingdocumentitemprcgelmnt
      FIELDS billingdocument,
             billingdocumentitem,
             conditiontype,
             ConditionAmount
     WHERE billingdocument = @bill_doc
     INTO TABLE @DATA(it_conditions_ZBP0).


********************************************************************** Nutrica MRP END


*      out->write( it_item ).
    SELECT SUM( conditionamount )
FROM i_billingdocitemprcgelmntbasic
WHERE billingdocument = @bill_doc
  AND conditiontype = 'ZFRT'
  INTO @DATA(freight).



    SORT it_item BY BillingDocumentItem.
    DELETE ADJACENT DUPLICATES FROM it_item COMPARING BillingDocument BillingDocumentItem.

    DATA : discount TYPE p DECIMALS 3.

*      out->write( it_item ).
*    out->write( wa_header ).

    DATA: temp_add TYPE string.
    temp_add = wa_bill-postalcode.
    CONCATENATE temp_add wa_bill-CityName wa_bill-DistrictName INTO temp_add.

    DATA: temp_add_ship  TYPE string.
    temp_add_ship = wa_ship2-PostalCode.
    CONCATENATE temp_add wa_ship2-CityName wa_ship2-DistrictName INTO temp_add_ship.

    DATA: lv_counter TYPE i.
    lv_counter = 0 .

    DATA(lv_xml) =
    |<Form>| &&
    |<BillingDocumentNode>| &&
    |<BillingDocument>{ wa_header-BillingDocument }</BillingDocument>| &&
    |<CurrentDate>{ lv_datecurr }</CurrentDate>| &&
    |<EWAYBILLNO>{ wa_header-ewaybillno }</EWAYBILLNO>| &&
    |<PLANTFSSAI>{ wa_plntfssai-fssai_no }</PLANTFSSAI>| &&
    |<VehicleNo>{ wa_header-vehiclenum }</VehicleNo>| &&
    |<LrNo>{ wa_header-grno }</LrNo>| &&
    |<YY1_Transporter_Name_BDH>{ wa_header-transportername }</YY1_Transporter_Name_BDH>| &&
    |<TransporterMode>{ wa_header-transportmode }</TransporterMode>| &&
    |<SIGNEDQR>{ wa_header-signedqrcode }</SIGNEDQR>| &&
    |<AckNumber>{ wa_header-ackno }</AckNumber>| &&
    |<NUTDISPATCHADD>{ nutadd }</NUTDISPATCHADD>| &&
    |<NUTDISPATCHSTATE>{ wa_nutadd-state_name }</NUTDISPATCHSTATE>| &&
    |<NUTDISPATCHSTATECODE>{ wa_nutadd-state_code1 }</NUTDISPATCHSTATECODE>| &&
    |<NUTDISPATCHGSTIN>{ wa_nutadd-gstin_no }</NUTDISPATCHGSTIN>| &&
    |<REMARKS>{ wa_remarks-YY1_Remarks_bd_BDH }</REMARKS>| &&
    |<NEWBILLTOADD>{ bill_addressnew }</NEWBILLTOADD>| &&
    |<NEWSHIPTOADD>{ ship_addressnew }</NEWSHIPTOADD>| &&
    |<BRANCHADD>{ branchaddnew }</BRANCHADD>| &&
    |<DEBITSHIPTOCODE>{ wa_dntaxadd-ShipToParty }</DEBITSHIPTOCODE>| &&
    |<DEBITSHIPTONAME>{ wa_dntaxadd-BusinessPartnerFullName }</DEBITSHIPTONAME>| &&
    |<DEBITSHIPTOADD>{ dntaxinvadd }</DEBITSHIPTOADD>| &&
    |<DEBITSHIPTOSTATE>{ wa_dntaxadd-RegionName }</DEBITSHIPTOSTATE>| &&
    |<DEBITSHIPTOGST>{ wa_dntaxadd-TaxNumber3 }</DEBITSHIPTOGST>| &&
    |<DEBITSHIPTOPHONE>{ wa_dntaxadd-TelephoneNumber1 }</DEBITSHIPTOPHONE>| &&
    |<DEBITSHIPTOFSSAI>{ wa_dntaxadd-BPIdentificationNumber }</DEBITSHIPTOFSSAI>| &&
    |<CNWITHOUTREFADD>{ cnwithoutadd }</CNWITHOUTREFADD>| &&
    |<CNWITHOUTREFCODE>{ wa_cnwithoutadd-ShipToParty }</CNWITHOUTREFCODE>| &&
    |<CNWITHOUTREFNAME>{ wa_cnwithoutadd-CustomerName }</CNWITHOUTREFNAME>| &&
    |<CNWITHOUTREFSTATE>{ wa_cnwithoutadd-RegionName }</CNWITHOUTREFSTATE>| &&
    |<CNWITHOUTREFPHONE>{ wa_cnwithoutadd-TelephoneNumber1 }</CNWITHOUTREFPHONE>| &&
    |<CNWITHOUTREFGST>{ wa_cnwithoutadd-TaxNumber3 }</CNWITHOUTREFGST>| &&
    |<CNWITHOUTREFFSSAI>{ wa_cnwithoutadd-BPIdentificationNumber }</CNWITHOUTREFFSSAI>| &&
    |<REGISTEREDOFFICE>{ wa_registered-address }</REGISTEREDOFFICE>| &&
    |<STONUM>{ wa_stonum-ReferenceSDDocument }</STONUM>| &&
    |<DELSHIPCODE>{ wa_deli_ship-Customer }</DELSHIPCODE>| &&
    |<DELSHIPNAME>{ wa_deli_ship-CustomerName }</DELSHIPNAME>| &&
    |<DELSHIPADD>{ deladdship }</DELSHIPADD>| &&
    |<DELSHIPPHONE>{ wa_deli_ship-TelephoneNumber1 }</DELSHIPPHONE>| &&
    |<DELSHIPSTATE>{ wa_deli_ship-RegionName }</DELSHIPSTATE>| &&
    |<DELSHIPGSTIN>{ wa_deli_ship-TaxNumber3 }</DELSHIPGSTIN>| &&
    |<DELSHIPFSSAI>{ wa_deli_ship-BPIdentificationNumber }</DELSHIPFSSAI>| &&
    |<DELBRANCHADD>{ delbranchaddress }</DELBRANCHADD>|.




    DATA : original_buyer TYPE string.
    DATA : duplicate_transporter TYPE string.
    DATA : office_copy TYPE string.

    DATA : del_original TYPE string.
    DATA : del_duplicate TYPE string.
    DATA : del_triplicate TYPE string.


    del_original = 'ORIGINAL'.
    del_duplicate = 'DUPLICATE'.
    del_triplicate = 'TRIPLICATE'.

    original_buyer = 'ORIGINAL FOR BUYER' .
    duplicate_transporter = 'DUPLICATE FOR TRANSPORTER' .
    office_copy = 'OFFICE COPY' .

    IF printname = 'sto1' OR  printname = 'cndn1' OR  printname = 'expo1' OR  printname = 'dom1' OR  printname = 'gt1'
    OR  printname = 'foc1' OR  printname = 'os1' OR  printname = 'ot1' OR  printname = 'bsto1' OR  printname = 'ts1'
    OR  printname = 'bfoc1' OR printname = 'nut1' OR printname = 'cnwith1' OR printname = 'dnwith1'.
      DATA(lv_typeofprint1) =
      |<TYPEOFPRINT>{ original_buyer }</TYPEOFPRINT>|.

      CONCATENATE lv_xml lv_typeofprint1 INTO lv_xml.

    ELSEIF printname = 'sto2' OR  printname = 'cndn2' OR  printname = 'expo2' OR  printname = 'dom2' OR  printname = 'gt2'
    OR  printname = 'foc2' OR  printname = 'os2' OR  printname = 'ot2' OR  printname = 'bsto2' OR  printname = 'ts2'
    OR  printname = 'bfoc2' OR printname = 'nut2' OR printname = 'cnwith2' OR printname = 'dnwith2'.
      DATA(lv_typeofprint2) =
      |<TYPEOFPRINT>{ duplicate_transporter }</TYPEOFPRINT>|.

      CONCATENATE lv_xml lv_typeofprint2 INTO lv_xml.

    ELSEIF printname = 'sto3' OR  printname = 'cndn3' OR  printname = 'expo3' OR  printname = 'dom3' OR  printname = 'gt3'
    OR  printname = 'foc3' OR  printname = 'os3' OR  printname = 'ot3' OR  printname = 'bsto3' OR  printname = 'ts3'
    OR  printname = 'bfoc3' OR printname = 'nut3' OR printname = 'cnwith3' OR printname = 'dnwith3'.
      DATA(lv_typeofprint3) =
      |<TYPEOFPRINT>{ office_copy }</TYPEOFPRINT>|.

      CONCATENATE lv_xml lv_typeofprint3 INTO lv_xml.

    ELSEIF printname = 'dc1'.
      DATA(del_orig) =
      |<TYPEOFPRINT>{ del_original }</TYPEOFPRINT>|.

      CONCATENATE lv_xml del_orig INTO lv_xml.

    ELSEIF printname = 'dc2'.
      DATA(del_dupl) =
      |<TYPEOFPRINT>{ del_duplicate }</TYPEOFPRINT>|.

      CONCATENATE lv_xml del_dupl INTO lv_xml.

    ELSEIF printname = 'dc3'.
      DATA(del_trip) =
      |<TYPEOFPRINT>{ del_triplicate }</TYPEOFPRINT>|.

      CONCATENATE lv_xml del_trip INTO lv_xml.

    ENDIF.


    IF wa_creditship  IS NOT INITIAL.

      DATA(lv_xmlcnadd) =
     |<CREDITSHIPTOCODE>{ wa_creditship-ShipToParty }</CREDITSHIPTOCODE>| &&
     |<CREDITSHIPTONAME>{ wa_creditship-BusinessPartnerFullName }</CREDITSHIPTONAME>| &&
     |<CREDITSHIPTOADD>{ credaddship }</CREDITSHIPTOADD>| &&
     |<CREDITSHIPTOSTATE>{ wa_credshipadd-RegionName }</CREDITSHIPTOSTATE>| &&
     |<CREDITSHIPTOGST>{ wa_credshipadd-TaxNumber3 }</CREDITSHIPTOGST>| &&
     |<CREDITSHIPTOPHONE>{ wa_credshipadd-TelephoneNumber1 }</CREDITSHIPTOPHONE>| &&
     |<CREDITSHIPTOFSSAI>{ wa_credshipfssai-BPIdentificationNumber }</CREDITSHIPTOFSSAI>|.

      CONCATENATE lv_xml lv_xmlcnadd INTO lv_xml.

    ELSE .

      DATA(lv_xmlcnadd2) =
      |<CREDITSHIPTOCODE>{ wa_cntaxadd-ShipToParty }</CREDITSHIPTOCODE>| &&
      |<CREDITSHIPTONAME>{ wa_cntaxadd-BusinessPartnerFullName }</CREDITSHIPTONAME>| &&
      |<CREDITSHIPTOADD>{ cntaxinvadd }</CREDITSHIPTOADD>| &&
      |<CREDITSHIPTOSTATE>{ wa_cntaxadd-RegionName }</CREDITSHIPTOSTATE>| &&
      |<CREDITSHIPTOGST>{ wa_cntaxadd-TaxNumber3 }</CREDITSHIPTOGST>| &&
      |<CREDITSHIPTOPHONE>{ wa_cntaxadd-TelephoneNumber1 }</CREDITSHIPTOPHONE>| &&
      |<CREDITSHIPTOFSSAI>{ wa_cntaxadd-BPIdentificationNumber }</CREDITSHIPTOFSSAI>|.

      CONCATENATE lv_xml lv_xmlcnadd2 INTO lv_xml.

    ENDIF.


*    IF wa_gatemain IS NOT INITIAL.
*    DATA(LV_VEH) =
*    |<VehicleNo>{ wa_gatemain-Vehicleno }</VehicleNo>|.
*    CONCATENATE lv_xml lv_veh INTO lv_xml.
*    ELSE .
*    DATA(LV_VEH2) =
*    |<VehicleNo>{ WA_IRN-vehiclenum }</VehicleNo>|.
*    CONCATENATE lv_xml LV_VEH2 INTO lv_xml.
*    ENDIF.
*
*    IF wa_gatemain IS NOT INITIAL.
*    DATA(LV_LRNO) =
*    |<LrNo>{ wa_gatemain-Lrno }</LrNo>| .
*    CONCATENATE lv_xml lv_lrno INTO lv_xml.
*    ELSE .
*    DATA(LV_LRNO2) =
*    |<LrNo>{ wa_irn-grno }</LrNo>| .
*    CONCATENATE lv_xml lv_lrno2 INTO lv_xml.
*    ENDIF.
*
*    IF wa_gatemain IS NOT INITIAL.
*    DATA(LV_TRNAME) =
*    |<YY1_Transporter_Name_BDH>{ wa_gatemain-Transportername }</YY1_Transporter_Name_BDH>|.
*    CONCATENATE lv_xml LV_TRNAME INTO lv_xml.
*    ELSE .
*    DATA(LV_TRNAME2) =
*    |<YY1_Transporter_Name_BDH>{ wa_irn-transportername }</YY1_Transporter_Name_BDH>|.
*    CONCATENATE lv_xml LV_TRNAME2 INTO lv_xml.
*    ENDIF.

**********************************************************************LRDATE CONDENSE

*    DATA:  lv_date_raw   TYPE string.
*    DATA:  lv_formatted  TYPE string.
*
*    lv_date_raw = CONV string( wa_header-grdate ).
*    CONDENSE lv_date_raw NO-GAPS.
*
*    IF strlen( lv_date_raw ) = 8.
*      lv_formatted = lv_date_raw+4(2) && '/' && lv_date_raw+6(2) && '/' && lv_date_raw+0(4).
**  lv_formatted = lv_date_raw+6(2) && '/' && lv_date_raw+4(2) && '/' && lv_date_raw+0(4).
*
*    ENDIF.
*
*    DATA(lv_gatemain2) =
*    |<LrDate>{ lv_formatted }</LrDate>|.
*    CONCATENATE lv_xml lv_gatemain2 INTO lv_xml.

DATA  lv_date_raw  TYPE string.
DATA  lv_formatted TYPE string.

lv_date_raw = CONV string( wa_header-grdate ).
CONDENSE lv_date_raw NO-GAPS.          "now e.g. '20250712'

IF strlen( lv_date_raw ) = 8.
  " dd/mm/yyyy  ->  positions 6‑7 | 4‑5 | 0‑3
  lv_formatted = lv_date_raw+6(2) && '/' &&
                 lv_date_raw+4(2) && '/' &&
                 lv_date_raw+0(4).         "12/07/2025
ENDIF.

DATA(lv_gatemain2) = |<LrDate>{ lv_formatted }</LrDate>|.
CONCATENATE lv_xml lv_gatemain2 INTO lv_xml.



*ENDIF.

**********************************************************************LRDATE CONDENSE END

*DATA: lv_date      TYPE string,
*      lv_gatemain1 TYPE string,
*      lv_gatemain2 TYPE string.
*
*" Check if lrdate is valid (not initial and not a default date)
*IF wa_gatemain-lrdate IS NOT INITIAL AND wa_gatemain-lrdate <> '00000000' AND wa_gatemain-lrdate <> '00010101'.
*
*    " Determine the format based on length (YYYYMMDD = 8, YYYY-MM-DD hh:mm:ss > 8)
*    IF strlen( wa_gatemain-lrdate ) = 8.
*        " Convert YYYYMMDD to DD/MM/YYYY format
*        lv_date = wa_gatemain-lrdate+6(2) && '/' && wa_gatemain-lrdate+4(2) && '/' && wa_gatemain-lrdate(4).
*    ELSE.
*        " Convert YYYY-MM-DD hh:mm:ss to DD/MM/YYYY format
*        lv_date = wa_gatemain-lrdate+8(2) && '/' && wa_gatemain-lrdate+5(2) && '/' && wa_gatemain-lrdate(4).
*    ENDIF.
*
*    " Generate XML tag with formatted date
*    lv_gatemain1 = |<LrDate>{ lv_date }</LrDate>|.
*    CONCATENATE lv_xml lv_gatemain1 INTO lv_xml RESPECTING BLANKS.
*ELSE.
*    " Generate XML tag with an empty LrDate
*    lv_gatemain2 = |<LrDate></LrDate>|.
*    CONCATENATE lv_xml lv_gatemain2 INTO lv_xml RESPECTING BLANKS.
*ENDIF.


**********************************************************************LRDATE CONDENSE END

**********************************************************************EWAYBILLDATE CONDENSE

    DATA: lv2_date     TYPE string,
          lv_gatemain3 TYPE string,
          lv_gatemain4 TYPE string.

    " Check if ewaydate is valid (not initial and not a default date)
    IF wa_header-ewaydate IS NOT INITIAL AND wa_header-ewaydate <> '00000000' AND wa_header-ewaydate <> '00010101'.

      " Determine the format based on length (YYYYMMDD = 8, YYYY-MM-DD hh:mm:ss > 8)
      IF strlen( wa_header-ewaydate ) = 8.
        " Convert YYYYMMDD to DD/MM/YYYY format
        lv2_date = wa_header-ewaydate+6(2) && '/' && wa_header-ewaydate+4(2) && '/' && wa_header-ewaydate(4).
      ELSE.
        " Convert YYYY-MM-DD hh:mm:ss to DD/MM/YYYY format
        lv2_date = wa_header-ewaydate+8(2) && '/' && wa_header-ewaydate+5(2) && '/' && wa_header-ewaydate(4).
      ENDIF.

      " Generate XML tag with formatted date
      lv_gatemain3 = |<EWAYBILLDATE>{ lv2_date }</EWAYBILLDATE>|.
      CONCATENATE lv_xml lv_gatemain3 INTO lv_xml RESPECTING BLANKS.
    ELSE.
      " Generate XML tag with an empty EWAYBILLDATE
      lv_gatemain4 = |<EWAYBILLDATE></EWAYBILLDATE>|.
      CONCATENATE lv_xml lv_gatemain4 INTO lv_xml RESPECTING BLANKS.
    ENDIF.




**********************************************************************EWAYBILLDATE CONDENSE END

**********************************************************************ACKDATE CONDENSE
*DATA: lv3_date      TYPE string,
*      lv_gatemain5  TYPE string,
*      lv_gatemain6  TYPE string.
*
*" Check if ackdate is valid (not initial and not a default date)
*IF wa_header-ackdate IS NOT INITIAL AND wa_header-ackdate <> '00000000' AND wa_header-ackdate <> '00010101'.
*    " Extract YYYY, MM, and DD from the format 'YYYY-MM-DD hh:mm:ss'
*    lv3_date = wa_header-ackdate+8(2) && '/' && wa_header-ackdate+5(2) && '/' && wa_header-ackdate(4).
*
*    " Generate XML tag with formatted date
*    lv_gatemain5 = |<AckDate>{ lv3_date }</AckDate>|.
*    CONCATENATE lv_xml lv_gatemain5 INTO lv_xml RESPECTING BLANKS.
*ELSE.
*    " Generate XML tag with an empty AckDate
*    lv_gatemain6 = |<AckDate></AckDate>|.
*    CONCATENATE lv_xml lv_gatemain6 INTO lv_xml RESPECTING BLANKS.
*ENDIF.

    DATA: lv3_date     TYPE string,
          lv_gatemain5 TYPE string,
          lv_gatemain6 TYPE string.

    " Check if ackdate is valid (not initial and not a default date)
    IF wa_header-ackdate IS NOT INITIAL AND wa_header-ackdate <> '00000000' AND wa_header-ackdate <> '00010101'.

      " Determine the format based on length (YYYYMMDD = 8, YYYY-MM-DD hh:mm:ss > 8)
      IF strlen( wa_header-ackdate ) = 8.
        " Convert YYYYMMDD to DD/MM/YYYY format
        lv3_date = wa_header-ackdate+6(2) && '/' && wa_header-ackdate+4(2) && '/' && wa_header-ackdate(4).
      ELSE.
        " Convert YYYY-MM-DD hh:mm:ss to DD/MM/YYYY format
        lv3_date = wa_header-ackdate+8(2) && '/' && wa_header-ackdate+5(2) && '/' && wa_header-ackdate(4).
      ENDIF.

      " Generate XML tag with formatted date
      lv_gatemain5 = |<AckDate>{ lv3_date }</AckDate>|.
      CONCATENATE lv_xml lv_gatemain5 INTO lv_xml RESPECTING BLANKS.
    ELSE.
      " Generate XML tag with an empty AckDate
      lv_gatemain6 = |<AckDate></AckDate>|.
      CONCATENATE lv_xml lv_gatemain6 INTO lv_xml RESPECTING BLANKS.
    ENDIF.



**********************************************************************ACKDATE CONDENSE END



    DATA(lv_xml2) =
    |<YY1_EmailAddress_BDH>{ wa_email-email }</YY1_EmailAddress_BDH>| &&
    |<BillingDate>{ wa_header-billingdate }</BillingDate>| &&
    |<BankName>{ wa_bank-bank_details }</BankName>| &&
    |<AccNo>{ wa_bank-acoount_number }</AccNo>| &&
    |<IFSCNo>{ wa_bank-ifsc_code }</IFSCNo>| &&
    |<DocumentReferenceID>{ wa_header-DocumentReferenceID }</DocumentReferenceID>|.

    CONCATENATE lv_xml lv_xml2 INTO lv_xml.

    IF wa_header-PurchaseOrderByCustomer IS NOT INITIAL.
      DATA(lv_xml_12) =
      |<PurchaseOrderByCustomer>{ wa_header-PurchaseOrderByCustomer }</PurchaseOrderByCustomer>|.

      CONCATENATE lv_xml lv_xml_12 INTO lv_xml.
    ELSE.
      DATA(lv_xml_13) =
      |<PurchaseOrderByCustomer>{ wa_refdoc-PurchaseOrderByCustomer }</PurchaseOrderByCustomer>|.
      CONCATENATE lv_xml lv_xml_13 INTO lv_xml.
    ENDIF.

    DATA(lv_xml_14) =
    |<YY1_Broker_BDH>{ wa_br-SupplierName }</YY1_Broker_BDH>| &&
    |<YY1_Phone_Number_BDH>{ wa_header-TelephoneNumber1 }</YY1_Phone_Number_BDH>| &&
    |<YY1_SHIPTO_PHONENUMBER_BDH>{ wa_sp-TelephoneNumber1 }</YY1_SHIPTO_PHONENUMBER_BDH>| &&
    |<Irn>{ wa_header-irnno }</Irn>| &&
*    |<YY1_PLANT_COM_ADD_BDH>{ plant_add }</YY1_PLANT_COM_ADD_BDH>| &&
    |<YY1_PLANT_COM_NAME_BDH>{ plant_name }</YY1_PLANT_COM_NAME_BDH>| &&
    |<YY1_PLANT_COM_GSTIN_NO_BDH>{ plant_gstin }</YY1_PLANT_COM_GSTIN_NO_BDH>| &&
    |<Supplier>| &&
    |<CompanyCode>{ wa_header-SalesOrganization }</CompanyCode>| &&
    |<AddressLine1Text>{ wa_company-PlantName }</AddressLine1Text>| &&
    |<AddressLine2Text>{ CompStreetprefixxname }</AddressLine2Text>| &&
    |<AddressLine3Text>{ wa_company-StreetName }</AddressLine3Text>| &&
    |<AddressLine4Text>{ CompStreetSuffixname }</AddressLine4Text>| &&
    |<AddressLine5Text>{ wa_company-CityName }</AddressLine5Text>| &&
    |<AddressLine6Text>{ wa_company-RegionName }</AddressLine6Text>| &&
    |<AddressLine7Text>{ wa_company-CountryName }</AddressLine7Text>| &&
    |<AddressLine8Text>{ ship_post }</AddressLine8Text>| &&
    |</Supplier>| &&
    |<PlantAdd>| &&
    |<AddressLine1Text>{ p_add1 }</AddressLine1Text>| &&
    |<AddressLine2Text>{ p_add2 }</AddressLine2Text>| &&
    |<AddressLine3Text>{ p_dist }</AddressLine3Text>| &&
    |<AddressLine4Text>{ p_city }</AddressLine4Text>| &&
    |<AddressLine5Text>{ p_state }</AddressLine5Text>| &&
    |<AddressLine6Text>{ p_country }</AddressLine6Text>| &&
    |<AddressLine7Text>{ p_pin }</AddressLine7Text>| &&
    |<AddressLine8Text></AddressLine8Text>| &&
    |</PlantAdd>| &&
    |<Incoterms>| &&
    |<Incoterms>{ wa_header-IncotermsClassification }</Incoterms>| &&
    |<IncotermsLocation1>{ wa_header-IncotermsLocation1 }</IncotermsLocation1>| &&
    |</Incoterms>| &&
    |<TaxationTerms>| &&
    |<IN_ShipToPtyGSTIdnNmbr>{ wa_ship2-TaxNumber3 }</IN_ShipToPtyGSTIdnNmbr>| &&
    |</TaxationTerms>| &&
    |<ShipToParty>| &&
    |<RegionName>{ wa_ship2-RegionName }</RegionName>| &&
    |<Partner>{ wa_spart-ShipToParty }</Partner>| &&
    |<AddressLine1Text>{ wa_ship2-BusinessPartnerFullName }</AddressLine1Text>| &&
    |<ShipToFssaiNo>{ wa_shipfssai-BPIdentificationNumber }</ShipToFssaiNo>| &&
    |</ShipToParty>| .
    CONCATENATE lv_xml lv_xml_14 INTO lv_xml.


    IF wa_header-company_name IS NOT INITIAL.
      DATA(lv_xml3) =
      |<Company>| &&
      |<CompanyName>{ wa_header-company_name }</CompanyName>| &&
      |</Company>|.
      CONCATENATE lv_xml lv_xml3 INTO lv_xml.
    ELSE.
      DATA(lv_xml4) =
      |<Company>| &&
      |<CompanyName>{ wa_header-SalesOrganizationName }</CompanyName>| &&
      |</Company>|.
      CONCATENATE lv_xml lv_xml4 INTO lv_xml.
    ENDIF.

    IF wa_header-SalesOrganization = 'BNAL'.
      DATA : lv_bnal TYPE string.
      lv_bnal = '1. All disputes are subject to MUMBAI Jurisdiction.'.
      DATA(lv_footerjurisdiction) =
      |<FOOTERJURISDICTION>{ lv_bnal }</FOOTERJURISDICTION>| .
      CONCATENATE lv_xml lv_footerjurisdiction INTO lv_xml.

    ELSEIF wa_header-SalesOrganization = 'A1AG'.
      DATA : lv_a1ag TYPE string.
      lv_a1ag = '1. All disputes are subject to NOIDA Jurisdiction.'.
      DATA(lv_footerjurisdiction2) =
      |<FOOTERJURISDICTION>{ lv_a1ag }</FOOTERJURISDICTION>| .
      CONCATENATE lv_xml lv_footerjurisdiction2 INTO lv_xml.

    ELSEIF wa_header-SalesOrganization = 'SBPL'.
      DATA : lv_sbpl TYPE string.
      lv_sbpl = '1. All disputes are subject to MUMBAI Jurisdiction.'.
      DATA(lv_footerjurisdiction3) =
      |<FOOTERJURISDICTION>{ lv_sbpl }</FOOTERJURISDICTION>| .
      CONCATENATE lv_xml lv_footerjurisdiction3 INTO lv_xml.
    ENDIF.

    DATA(lv_xml5) =
    |<BillToParty>| &&
    |<AddressLine1Text>{ wa_bill-CustomerName }</AddressLine1Text>| &&
    |<AddressLine2Text>{ Streetprefixxname }</AddressLine2Text>| &&
    |<AddressLine3Text>{ wa_bill-StreetName }</AddressLine3Text>| &&
    |<AddressLine4Text>{ StreetSuffixname }</AddressLine4Text>| &&
    |<AddressLine5Text>{ wa_bill-CityName }</AddressLine5Text>| &&
    |<AddressLine6Text>{ wa_bill-RegionName }</AddressLine6Text>| &&
    |<AddressLine7Text>{ wa_bill-CountryName }</AddressLine7Text>| &&
    |<AddressLine8Text>{ Post_Ctry }</AddressLine8Text>| &&
    |<BillToFssaiNo>{ wa_billfssai-bpidentificationnumber }</BillToFssaiNo>| &&
*    |<Region>{ wa_bill-Region }</Region>| &&
    |<FullName>{ wa_bill-CustomerName }</FullName>| &&   " done
*12.03    |<Partner>{ wa_header-YY1_DONo_SDH }</Partner>| &&
    |<RegionName>{ wa_bill-RegionName }</RegionName>| &&
    |<Partner>{ wa_bpart-PayerParty }</Partner>| &&
    |</BillToParty>| &&
    |<Items>|.

    CONCATENATE lv_xml lv_xml5 INTO lv_xml.


    SELECT FROM i_billingdocumentitem AS a
    FIELDS a~BillingDocument , a~BillingDocumentItem , a~SalesDocument , a~SalesDocumentItem , a~ReferenceSDDocument , a~Batch
    WHERE a~BillingDocument = @bill_doc
    INTO TABLE @DATA(lt_batch)
    PRIVILEGED ACCESS.

    LOOP AT it_item INTO DATA(wa_item) .

*      SELECT SINGLE
*     a~trade_name
*     FROM zmaterial_table AS a
*     WHERE a~mat = @wa_item-Product
*     INTO @DATA(wa_item3).
*
*      IF wa_item3 IS NOT INITIAL.
*        DATA(lv_item) =
*        |<BillingDocumentItemNode>| &&
*        |<YY1_fg_material_name_BDI>{ wa_item3 }</YY1_fg_material_name_BDI>|.
*        CONCATENATE lv_xml  lv_item INTO lv_xml.
*      ELSE.
*        " Fetch Product Name from `i_producttext`
*        SELECT SINGLE
*        a~productname
*        FROM i_producttext AS a
*        WHERE a~product = @wa_item-Product
*        INTO @DATA(wa_item4).
*
*        DATA(lv_item4) =
*        |<BillingDocumentItemNode>| &&
*        |<YY1_fg_material_name_BDI>{ wa_item4 }</YY1_fg_material_name_BDI>|.
*        CONCATENATE lv_xml lv_item4 INTO lv_xml.
*      ENDIF.
      SHIFT wa_item-Product LEFT DELETING LEADING '0'.
      DATA(lv_item) =
      |<BillingDocumentItemNode>|.
      CONCATENATE lv_xml lv_item INTO lv_xml.



      DATA(lv_item_xml11) =


      |<BillingDocumentItemText>{ wa_item-Product }</BillingDocumentItemText>| &&
      |<Batch>{ wa_item-Batch }</Batch>| &&
      |<SalesContract>{ wa_item-ReferenceSDDocument }</SalesContract>| &&
      |<IN_HSNOrSACCode>{ wa_item-consumptiontaxctrlcode }</IN_HSNOrSACCode>| &&
      |<NetPriceAmount></NetPriceAmount>| &&                       " pending
      |<Plant></Plant>| &&                                         " pending
      |<Quantity>{ wa_item-BillingQuantity }</Quantity>| &&
      |<QtyPCS>{ wa_item-BillingQuantityInBaseUnit }</QtyPCS>| &&
      |<QuantityUnit>{ wa_item-BillingQuantityUnit }</QuantityUnit>| &&
      |<YY1_bd_zdif_BDI></YY1_bd_zdif_BDI>| &&                      " pending
      |<YY1_fg_material_name_BDI></YY1_fg_material_name_BDI>| &&    " Pending
      |<ITEMCODE>{ wa_item-Product }</ITEMCODE>| &&
      |<OBD>{ wa_item-obdnum }</OBD>| .
      CONCATENATE lv_xml lv_item_xml11 INTO lv_xml.


      SHIFT wa_item-Product LEFT DELETING LEADING '0'.
      DATA : prd TYPE string.
      prd = wa_item-Product.

      SELECT FROM zproduct_table AS a
      FIELDS a~product_description , a~product
      WHERE a~product = @prd
      INTO TABLE @DATA(it_description).

      READ TABLE it_description INTO DATA(wa_description) WITH KEY product = wa_item-Product.
      IF wa_description-product IS NOT INITIAL .
        DATA(lv_item_xml12) =
        |<ITEMDESC>{ wa_description-product_description }</ITEMDESC>|.
        CONCATENATE lv_xml lv_item_xml12 INTO lv_xml.
      ELSEIF wa_description-product IS INITIAL.
        DATA(lv_item_xml13) =
        |<ITEMDESC>{ wa_item-ProductDescription }</ITEMDESC>|.
        CONCATENATE lv_xml lv_item_xml13 INTO lv_xml.
      ENDIF.
      CLEAR : prd, wa_description.


      DATA(lv_item_xml14) =
     |<NetAmount>{ wa_item-NetAmount }</NetAmount>| &&
     |<ItemPricingConditions>|.
      CONCATENATE lv_xml lv_item_xml14 INTO lv_xml.



      SELECT
        a~conditionType  ,  "hidden conditiontype
        a~conditionamount ,  "hidden conditionamount
        a~conditionratevalue  ,  "condition ratevalue
        a~conditionbasevalue   " condition base value
        FROM I_BillingDocItemPrcgElmntBasic AS a
         WHERE a~BillingDocument = @bill_doc AND a~BillingDocumentItem = @wa_item-BillingDocumentItem
        INTO TABLE @DATA(lt_item2)
        PRIVILEGED ACCESS.

      LOOP AT lt_item2 INTO DATA(wa_item2).
        DATA(lv_item2_xml) =
        |<ItemPricingConditionNode>| &&
        |<lineitem>{ lv_counter }</lineitem>| &&
        |<ConditionAmount>{ wa_item2-ConditionAmount }</ConditionAmount>| &&
        |<ConditionBaseValue>{ wa_item2-ConditionBaseValue }</ConditionBaseValue>| &&
        |<ConditionRateValue>{ wa_item2-ConditionRateValue }</ConditionRateValue>| &&
        |<ConditionType>{ wa_item2-ConditionType }</ConditionType>| &&
        |</ItemPricingConditionNode>|.
        CONCATENATE lv_xml lv_item2_xml INTO lv_xml.
        CLEAR wa_item2.
      ENDLOOP.

      lv_counter = lv_counter + 1 .

      DATA(lv_item3_xml) =
      |</ItemPricingConditions>|.
      CONCATENATE lv_xml lv_item3_xml INTO lv_xml.

**********************************************************************WEIGHT(KG)
*      SELECT FROM I_BILLINGDOCUMENTITEM AS A
*      FIELDS A~BillingDocument , A~BillingQuantity , A~ItemNETWeight , A~ItemWeightUnit
*      WHERE A~BillingDocument = @bill_doc
*      INTO TABLE @DATA(IT_WEIGHT).
*
*      LOOP AT IT_WEIGHT INTO DATA(WA_WEIGHT).


*      DATA : BILLQT TYPE P DECIMALS 3.
      DATA : itmgrw TYPE p DECIMALS 3.
      DATA : billgrw TYPE p DECIMALS 3.
      DATA : billgrw2 TYPE p DECIMALS 3.
*      BILLQT = WA_ITEM-BillingQuantity .
      itmgrw = wa_item-itemNETweight .
      billgrw =  itmgrw .
      billgrw2 = itmgrw * 1000 .

      IF WA_item-ItemWeightUnit = 'KG' .
        DATA(lv_weight) =
            |<NetWeight>{ billgrw }</NetWeight>| .
        CONCATENATE lv_xml  lv_weight INTO lv_xml.

      ELSE.
        DATA(lv_weight2) =
            |<NetWeight>{ billgrw2 }</NetWeight>| .
        CONCATENATE lv_xml  lv_weight2 INTO lv_xml.
        CLEAR :  billgrw , itmgrw  , billgrw2 . "BILLQT .
      ENDIF.
*      ENDLOOP.

**********************************************************************WEIGHT(KG) END

**********************************************************************RATE PER UOM ZPR0
* SHIFT wa_item-ReferenceSDDocument LEFT DELETING LEADING '0'.
* SHIFT wa_item-rsd LEFT DELETING LEADING '0'.


      READ TABLE it_conditions_zpr0 INTO DATA(wa_cond)
          WITH KEY billingdocument     = wa_item-billingdocument
                   billingdocumentitem = wa_item-billingdocumentitem
                   conditiontype       = 'ZPR0'.

      IF sy-subrc = 0 AND wa_cond-conditionratevalue IS NOT INITIAL.

        DATA : lv_rateperuom TYPE string.
        DATA : lv_zpr0  TYPE p DECIMALS 2.

        IF wa_item-netpricequantityunit = wa_item-orderquantityunit.
          lv_rateperuom = |<RATEPERUOM>{ wa_cond-conditionratevalue }</RATEPERUOM>|.
        ELSE.
          lv_zpr0 = wa_item-billingtobasequantitynmrtr * wa_cond-conditionratevalue.
          lv_rateperuom = |<RATEPERUOM>{ lv_zpr0 }</RATEPERUOM>|.
        ENDIF.

        CONCATENATE lv_xml lv_rateperuom INTO lv_xml.

      ENDIF.

**********************************************************************RATE PER UOM ZPR0 END

**********************************************************************RATE PER UOM ZCIP END

      READ TABLE it_conditions_zcip INTO DATA(wa_cond_zcip)
          WITH KEY billingdocument     = wa_item-billingdocument
                   billingdocumentitem = wa_item-billingdocumentitem
                   conditiontype       = 'ZCIP'.

      IF sy-subrc = 0 AND wa_cond_zcip-conditionratevalue IS NOT INITIAL.

        DATA : lv_zcip TYPE p DECIMALS 2.
        DATA : lv_zcip_rate_xml TYPE string.

        IF wa_item-netpricequantityunit = wa_item-orderquantityunit.
          lv_zcip_rate_xml =
          |<ZCIPRATEPERUOM>{ wa_cond_zcip-conditionratevalue }</ZCIPRATEPERUOM>| .
*          |<DELIVERYRATEPERUOM>{ wa_cond_zcip-conditionratevalue }</DELIVERYRATEPERUOM>|.
        ELSE.
          lv_zcip = wa_item-billingtobasequantitynmrtr * wa_cond_zcip-conditionratevalue.
          lv_zcip_rate_xml =
          |<ZCIPRATEPERUOM>{ lv_zcip }</ZCIPRATEPERUOM>| .
*          |<DELIVERYRATEPERUOM>{ lv_zcip }</DELIVERYRATEPERUOM>|.
        ENDIF.

        CONCATENATE lv_xml lv_zcip_rate_xml INTO lv_xml.

      ENDIF.



**********************************************************************RATE PER UOM ZCIP END

**********************************************************************MRP
      READ TABLE it_conditions_ZMRP INTO DATA(wa_conditions_ZMRP)
                WITH KEY billingdocument     = wa_item-billingdocument
                         billingdocumentitem = wa_item-billingdocumentitem
                         conditiontype       = 'ZMRP'.

      DATA(lv_mrp) =
         |<MRPITEM>{ wa_conditions_zmrp-ConditionRateAmount }</MRPITEM>|.
      CONCATENATE lv_xml lv_mrp INTO lv_xml.
      CLEAR : wa_conditions_zmrp.
**********************************************************************MRP END

**********************************************************************nUTRICA RATE PER UOM

      DATA: bilqtycs TYPE p LENGTH 13 DECIMALS 3.
      DATA: bilqtyea TYPE p LENGTH 13 DECIMALS 3.
      DATA : baseval TYPE p LENGTH 13 DECIMALS 3.
      DATA : billunit TYPE string.
      DATA : nutrateuom TYPE p LENGTH 13 DECIMALS 3.
      READ TABLE it_conditions_zbp0 INTO DATA(wa_conditions_zbp0)
                WITH KEY billingdocument     = wa_item-billingdocument
                         billingdocumentitem = wa_item-billingdocumentitem
                         conditiontype       = 'ZBP0'.
      bilqtycs =  wa_item-BillingQuantity .
      bilqtyea = wa_item-billingquantityinbaseunit.
      baseval = wa_conditions_zbp0-conditionamount.
      billunit = wa_item-BillingQuantityUnit.

      IF billunit = 'CS' .
        IF bilqtycs IS NOT INITIAL.
          nutrateuom = baseval / bilqtycs.
        ELSE.
          nutrateuom = 0.
          " Or handle the divide-by-zero case differently
        ENDIF.

      ELSEIF billunit = 'EA' .
        IF bilqtyea IS NOT INITIAL.
          nutrateuom = baseval / bilqtyea.
        ELSE.
          nutrateuom = 0.
          " Or handle the divide-by-zero case differently
        ENDIF.

      ELSE .
        IF bilqtycs IS NOT INITIAL.
          nutrateuom = baseval / bilqtycs.
        ELSE.
          nutrateuom = 0.
          " Or handle the divide-by-zero case differently
        ENDIF.

      ENDIF.

      DATA(lv_bp0) =
         |<NUTRATEPERUOM>{ nutrateuom }</NUTRATEPERUOM>|.
      CONCATENATE lv_xml lv_bp0 INTO lv_xml.
      CLEAR : wa_conditions_zbp0 , bilqtycs , bilqtyea  , baseval , nutrateuom.

**********************************************************************MRP END



*DATA : CONTYPE TYPE STRING .
*DATA : CONBASEVAL2 TYPE P DECIMALS 2.
*DATA : CONDRATEVAL2 TYPE P DECIMALS 2.
*DATA : CONDMULVAL2 TYPE P DECIMALS 2.
*CONBASEVAL2 = wa_item-BILLINGTOBASEQUANTITYNMRTR .
*CONDRATEVAL2 = wa_cond-ConditionRateValue .
*CONDMULVAL2 = conbaseval2 * condrateval2 .
*CONTYPE = wa_cond-ConditionType.
*
*IF contype = 'ZPR0' .
*  DATA(LV_ITEM_RATE) =
*   |<RATEPERUOM>{ CONDMULVAL2 }</RATEPERUOM>|.
*CONCATENATE   lv_xml lv_item_rate INTO lv_xml.
*
*ELSE .
*    DATA(LV_ITEM_RATE2) =
*   |<RATEPERUOM></RATEPERUOM>|.
*CONCATENATE   lv_xml lv_item_rate2 INTO lv_xml.
*CLEAR : contype , CONBASEVAL2 , CONDRATEVAL2 , CONDMULVAL2   .
*ENDIF.
*DATA : CONBASEVAL3 TYPE P DECIMALS 2.
*DATA : CONDRATEVAL3 TYPE P DECIMALS 2.
*DATA : CONDMULVAL3 TYPE P DECIMALS 2.
*CONBASEVAL3 = wa_item-BILLINGTOBASEQUANTITYNMRTR .
*CONDRATEVAL3 = wa_item-ConditionRateValue .
*CONDMULVAL3 = conbaseval3 * condrateval3 .
*
*ELSEIF  WA_item-ConditionType = 'ZCIP' .
*  DATA(LV_ITEM_RATE2) =
*   |<STORATEPERUOM>{ CONDMULVAL3 }</STORATEPERUOM>|.
*CONCATENATE   lv_xml LV_ITEM_RATE2 INTO lv_xml.
*CLEAR :  CONBASEVAL3 , CONDRATEVAL3 , CONDMULVAL3   .

*ENDIF.

**********************************************************************RATE PER UOM END


**********************************************************************ZCIP RATE PER UOM

*DATA : CONBASEVAL3 TYPE P DECIMALS 2.
*DATA : CONDRATEVAL3 TYPE P DECIMALS 2.
*DATA : CONDMULVAL3 TYPE P DECIMALS 2.
*CONBASEVAL3 = wa_item-BILLINGTOBASEQUANTITYNMRTR .
*CONDRATEVAL3 = wa_item-ConditionRateValue .
*CONDMULVAL3 = conbaseval3 * condrateval3 .
*
*ELSEIF  WA_item-ConditionType = 'ZCIP' .
*  DATA(LV_ITEM_RATE2) =
*   |<STORATEPERUOM>{ CONDMULVAL3 }</STORATEPERUOM>|.
*CONCATENATE   lv_xml LV_ITEM_RATE2 INTO lv_xml.
*CLEAR :  CONBASEVAL3 , CONDRATEVAL3 , CONDMULVAL3   .
*ENDIF.


**********************************************************************ZCIP RATE PER UOM END



      DATA(lv_item8_xml) =
      |</BillingDocumentItemNode>|.
      CONCATENATE lv_xml lv_item8_xml INTO lv_xml.


      CLEAR lv_item.
      CLEAR lv_item_xml11.
      CLEAR lv_item_xml12.
      CLEAR lv_item_xml13.
      CLEAR lv_item_xml14.
      CLEAR lt_item2.
      CLEAR wa_item.
    ENDLOOP.

    DATA(lv_payment_term) =
      |<PaymentTerms>| &&
      |<PaymentTermsName></PaymentTermsName>| &&    " pending
      |</PaymentTerms>|.

    CONCATENATE lv_xml lv_payment_term INTO lv_xml.

    DATA(lv_shiptoparty) =
    |<ShipToParty>| &&
    |<AddressLine2Text>{ ShipStreetprefixxname }</AddressLine2Text>| &&
    |<AddressLine3Text>{ wa_ship2-StreetName }</AddressLine3Text>| &&
    |<AddressLine4Text>{ ShipStreetSuffixname }</AddressLine4Text>| &&
    |<AddressLine5Text>{ wa_ship2-CityName }</AddressLine5Text>| &&
    |<AddressLine6Text>{ wa_ship2-RegionName }</AddressLine6Text>| &&
    |<AddressLine7Text>{ wa_ship2-CountryName }</AddressLine7Text>| &&
    |<AddressLine8Text>{ shipPost_Ctry }</AddressLine8Text>| &&
    |<FullName>{ wa_bill-Region }</FullName>| &&
    |<RegionName>{ wa_ship2-RegionName }</RegionName>| &&
    |</ShipToParty>|.

    CONCATENATE lv_xml lv_shiptoparty INTO lv_xml.

*    DATA(lv_supplier) =
*    |<Supplier>| &&
*    |<RegionName></RegionName>| &&                 " pending
*    |</Supplier>|.
*    CONCATENATE lv_xml lv_supplier INTO lv_xml.

    DATA(lv_taxation) =
    |<TaxationTerms>| &&
    |<IN_BillToPtyGSTIdnNmbr>{ wa_bill-taxnumber3 }</IN_BillToPtyGSTIdnNmbr>| &&       " pending   IN_BillToPtyGSTIdnNmbr
    |</TaxationTerms>|.
    CONCATENATE lv_xml lv_taxation INTO lv_xml.

    DATA(lv_footer) =
    |</Items>| &&
    |</BillingDocumentNode>| &&
    |</Form>|.

    CONCATENATE lv_xml lv_footer INTO lv_xml.

    CLEAR wa_ad5.
    CLEAR wa_ad5_ship.
    CLEAR wa_bill.
    CLEAR wa_ship2.
    CLEAR wa_header.



    REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'and' .




    DATA: lc_template_name2 TYPE string.

    IF printname = 'sto1' OR printname = 'sto2' OR printname = 'sto3'.

      SELECT SINGLE FROM zintegration_tab FIELDS intgpath
      WHERE intgmodule = 'bs_print'
      INTO @lc_template_name2 PRIVILEGED ACCESS.

    ELSEIF printname = 'dom1' OR printname = 'dom2' OR printname = 'dom3'.

      SELECT SINGLE FROM zintegration_tab FIELDS intgpath
      WHERE intgmodule = 'ec_print'
      INTO @lc_template_name2 PRIVILEGED ACCESS.

    ELSEIF printname = 'expo1' OR printname = 'expo2' OR printname = 'expo3'.

      SELECT SINGLE FROM zintegration_tab FIELDS intgpath
      WHERE intgmodule = 'dn_print'
      INTO @lc_template_name2 PRIVILEGED ACCESS.

    ELSEIF printname = 'foc' OR printname = 'foc2' OR printname = 'foc3'.

      SELECT SINGLE FROM zintegration_tab FIELDS intgpath
      WHERE intgmodule = 'hs_print'
      INTO @lc_template_name2 PRIVILEGED ACCESS.

    ELSEIF printname = 'cndn1' OR printname = 'cndn2' OR printname = 'cndn3'.

      SELECT SINGLE FROM zintegration_tab FIELDS intgpath
      WHERE intgmodule = 'cn_print'
      INTO @lc_template_name2 PRIVILEGED ACCESS.

    ELSEIF printname = 'os1' OR printname = 'os2' OR printname = 'os3'.

      SELECT SINGLE FROM zintegration_tab FIELDS intgpath
      WHERE intgmodule = 'os_print'
      INTO @lc_template_name2 PRIVILEGED ACCESS.

    ELSEIF printname = 'gt1' OR printname = 'gt2' OR printname = 'gt3'.

      SELECT SINGLE FROM zintegration_tab FIELDS intgpath
      WHERE intgmodule = 'gt_print'
      INTO @lc_template_name2 PRIVILEGED ACCESS.

    ELSEIF printname = 'ot1' OR printname = 'ot2' OR printname = 'ot3'.

      SELECT SINGLE FROM zintegration_tab FIELDS intgpath
      WHERE intgmodule = 'ot_print'
      INTO @lc_template_name2 PRIVILEGED ACCESS.

    ELSEIF printname = 'bsto1' OR printname = 'bsto2' OR printname = 'bsto3'.

      SELECT SINGLE FROM zintegration_tab FIELDS intgpath
      WHERE intgmodule = 'sto_print'
      INTO @lc_template_name2 PRIVILEGED ACCESS.


    ELSEIF printname = 'ts1' OR printname = 'ts2' OR printname = 'ts3'.

      SELECT SINGLE FROM zintegration_tab FIELDS intgpath
      WHERE intgmodule = 'ts_print'
      INTO @lc_template_name2 PRIVILEGED ACCESS.

    ELSEIF printname = 'bfoc1' OR printname = 'bfoc2' OR printname = 'bfoc3'.

      SELECT SINGLE FROM zintegration_tab FIELDS intgpath
      WHERE intgmodule = 'foc_print'
      INTO @lc_template_name2 PRIVILEGED ACCESS.

    ELSEIF printname = 'nut1' OR printname = 'nut2' OR printname = 'nut3'.

      SELECT SINGLE FROM zintegration_tab FIELDS intgpath
      WHERE intgmodule = 'nut_print'
      INTO @lc_template_name2 PRIVILEGED ACCESS.

    ELSEIF printname = 'cnwith1' OR printname = 'cnwith2' OR printname = 'cnwith3'.

      SELECT SINGLE FROM zintegration_tab FIELDS intgpath
      WHERE intgmodule = 'cnwithout_print'
      INTO @lc_template_name2 PRIVILEGED ACCESS.

    ELSEIF printname = 'dnwith1' OR printname = 'dnwith2' OR printname = 'dnwith3'.

      SELECT SINGLE FROM zintegration_tab FIELDS intgpath
      WHERE intgmodule = 'dnwithout_print'
      INTO @lc_template_name2 PRIVILEGED ACCESS.

    ELSEIF printname = 'dc1' OR printname = 'dc2' OR printname = 'dc3'.

      SELECT SINGLE FROM zintegration_tab FIELDS intgpath
      WHERE intgmodule = 'JOB_WORK'
      INTO @lc_template_name2 PRIVILEGED ACCESS.


    ENDIF.

    CALL METHOD zcl_ads_print=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name2
      RECEIVING
        result   = result12 ).




  ENDMETHOD.
ENDCLASS.
