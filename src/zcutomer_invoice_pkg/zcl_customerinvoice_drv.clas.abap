CLASS zcl_customerinvoice_drv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*   INTERFACES if_oo_adt_classrun.
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
      END OF struct.
    CLASS-METHODS :
      create_client
        IMPORTING url           TYPE string
        RETURNING VALUE(result) TYPE REF TO if_web_http_client
        RAISING   cx_static_check ,

      read_posts
        IMPORTING accounting_no   TYPE string
                  Company_code    TYPE string
                  fiscal_year     TYPE string
        RETURNING VALUE(result12) TYPE string
        RAISING   cx_static_check .

  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS lc_ads_render TYPE string VALUE '/ads.restapi/v1/adsRender/pdf'.
    CONSTANTS  lv1_url    TYPE string VALUE 'https://adsrestapi-formsprocessing.cfapps.jp10.hana.ondemand.com/v1/adsRender/pdf?templateSource=storageName&TraceLevel=2'  .
    CONSTANTS  lv2_url    TYPE string VALUE 'https://dev-tcul4uw9.authentication.jp10.hana.ondemand.com/oauth/token'  .
    CONSTANTS lc_storage_name TYPE string VALUE 'templateSource=storageName'.
    CONSTANTS lc_template_name TYPE string VALUE 'zficust_inv/zficust_inv'.
**    CONSTANTS lc_template_name TYPE 'HDFC_CHECK/HDFC_MULTI_FINAL_CHECK'.
ENDCLASS.



CLASS ZCL_CUSTOMERINVOICE_DRV IMPLEMENTATION.


  METHOD create_client .
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).

  ENDMETHOD.


  METHOD read_posts .

    DATA : cin TYPE string.
    SELECT SINGLE
   a~companycode,
   f~companycodename ,
    g~address1,
    g~address2,
    g~city,
    g~state_name,
    g~country,
    g~pin,
     g~pan_no,
    g~gstin_no,
    g~fssai_no,
    h~ackno,
    h~ackdate,
    h~irnno,
    h~ewaybillno,
    h~ewaydate
     FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
    LEFT JOIN i_companycode WITH PRIVILEGED ACCESS  AS f ON a~companycode   = f~CompanyCode
    LEFT JOIN ztable_plant WITH PRIVILEGED ACCESS  AS g ON a~BusinessPlace   = g~plant_code
    LEFT JOIN ztable_irn WITH PRIVILEGED ACCESS  AS h ON g~plant_code  = h~plant
 WHERE a~AccountingDocument = @accounting_no   AND a~CompanyCode = @Company_code AND a~FiscalYear = @fiscal_year
   INTO @DATA(wa_head).



    IF wa_head-CompanyCode = 'BNAL'.
      cin = 'U01403DL2011PLC301179'.
    ELSEIF wa_head-CompanyCode = 'SBPL'.
      cin = 'U15490UP2020PTC128250'.
    ELSEIF wa_head-CompanyCode = 'A1AG'.
      cin = 'U51909DL2020PTC366017'.
    ELSEIF wa_head-CompanyCode = 'EPIL'.
      cin = 'U15549DL2022PLC402614'.
    ENDIF.

    DATA: PLANT_add1 TYPE string.


    PLANT_add1  = wa_head-address1.
    CONCATENATE PLANT_add1  wa_head-address2 wa_head-city   wa_head-state_name   wa_head-country  wa_head-pin INTO
    PLANT_add1 SEPARATED BY space.

    """""""""""""""""""""""""""""BILL TO """""""""""""""""""""""""""""""""""""
    SELECT SINGLE
      a~Customer,
      b~CustomerName,
      b~TelephoneNumber1,
      b~TelephoneNumber2,
      b~TaxNumber3,
      c~StreetName,
      c~StreetPrefixName1,
      c~StreetPrefixName2,
      c~CityName,
      c~DistrictName,
      c~Region,
      c~PostalCode,
      c~Country,
      c~HouseNumber,
      d~RegionName,
      e~BPIdentificationNumber

    FROM i_operationalacctgdocitem  WITH PRIVILEGED ACCESS AS a

      LEFT JOIN i_customer WITH PRIVILEGED ACCESS AS b
        ON a~Customer = b~Customer
      LEFT JOIN i_address_2   WITH PRIVILEGED ACCESS AS c
        ON b~AddressID = c~AddressID
      LEFT JOIN i_regiontext   WITH PRIVILEGED ACCESS AS d
        ON b~Region = d~Region
      LEFT JOIN i_bupaidentification  WITH PRIVILEGED ACCESS AS e
        ON a~Customer = e~BusinessPartner
    WHERE  a~AccountingDocument = @accounting_no   AND a~CompanyCode = @Company_code AND a~FiscalYear = @fiscal_year
      AND a~FinancialAccountType = 'D'
      AND e~BPIdentificationType = 'FSSAI'
      INTO @DATA(wa_head_bill).

    DATA: bill_to TYPE string.


    bill_to = wa_head_bill-streetname.
    CONCATENATE bill_to  wa_head_bill-StreetPrefixName1  wa_head_bill-StreetPrefixName2  wa_head_bill-CityName  wa_head_bill-DistrictName  wa_head_bill-RegionName
    wa_head_bill-country  wa_head_bill-PostalCode INTO
   bill_to SEPARATED BY space.
*out->write( bill_to ).
    """""""""""""""""""""""""""""Shipped To """""""""""""""""""""""""""""""""""""

    SELECT SINGLE
      a~Customer,
      b~CustomerName,
      b~TelephoneNumber1,
      b~TelephoneNumber2,
      b~TaxNumber3,
      c~StreetName,
      c~StreetPrefixName1,
      c~StreetPrefixName2,
      c~CityName,
      c~DistrictName,
      c~Region,
      c~PostalCode,
      c~Country,
      c~HouseNumber,
      d~RegionName,
      e~BPIdentificationNumber

    FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
      LEFT JOIN i_customer  WITH PRIVILEGED ACCESS AS b
        ON a~Customer = b~Customer
      LEFT JOIN i_address_2  WITH PRIVILEGED ACCESS AS c
        ON b~AddressID = c~AddressID
      LEFT JOIN i_regiontext  WITH PRIVILEGED ACCESS AS d
        ON b~Region = d~Region
      LEFT JOIN i_bupaidentification WITH PRIVILEGED ACCESS AS e
        ON a~Customer = e~BusinessPartner
    WHERE a~AccountingDocument = @accounting_no   AND a~CompanyCode = @Company_code AND a~FiscalYear = @fiscal_year
      AND a~FinancialAccountType = 'D'
      AND e~BPIdentificationType = 'FSSAI'
      INTO @DATA(wa_head_ship).


    DATA: ship_to TYPE string.


    ship_to = wa_head_ship-streetname.
    CONCATENATE  ship_to  wa_head_ship-StreetPrefixName1  wa_head_ship-StreetPrefixName2   wa_head_ship-CityName  wa_head_ship-DistrictName  wa_head_ship-RegionName
    wa_head_ship-country  wa_head_ship-PostalCode INTO
   ship_to SEPARATED BY space.
*out->write( ship_to ).
    """""""""""""""""""""""""""""" 3rd block invoice details **********************************



    SELECT SINGLE
       a~documentdate,
*    a~DOCUMENTREFERENCEID,
       a~originalreferencedocument,
       b~incotermsclassification,
        b~incotermslocation1
       FROM i_operationalacctgdocitem  WITH PRIVILEGED ACCESS AS a
      LEFT JOIN i_billingdocument WITH PRIVILEGED ACCESS AS b ON a~customer = b~payerparty
        WHERE a~AccountingDocument = @accounting_no   AND a~CompanyCode = @Company_code AND a~FiscalYear = @fiscal_year
      INTO @DATA(wa_head_invoice).



    """""""""""""""""""""""""""""ITEM DETAILS"""""""""""""""""""""""""""""""""""""""""

    SELECT
      a~AccountingDocument,
         a~in_hsnorsaccode,
         a~companycode,
         a~fiscalyear,
         a~product,
         a~quantity,
         a~baseunit,
         a~TaxItemGroup,
         a~amountincompanycodecurrency,
         b~productdescription,
       c~glaccount,
         c~glaccountname

    FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
    LEFT JOIN i_glaccounttextrawdata WITH PRIVILEGED ACCESS AS c ON a~GLAccount = c~GLAccount
     LEFT JOIN i_productdescription  WITH PRIVILEGED ACCESS AS b ON a~product = b~Product
    WHERE a~AccountingDocument = @accounting_no   AND a~CompanyCode = @Company_code AND a~FiscalYear = @fiscal_year
      AND a~AccountingDocumentItemType <> 'T'
      AND a~CostElement IS NOT INITIAL
      AND a~AmountInCompanyCodeCurrency < -1

    INTO TABLE @DATA(it_item).
*out->write( it_item ).

    ""RATEE

    """"""""""''''''''''''''FOOTER DETAILS ************************************************************



    SELECT SINGLE
        a~documentitemtext,
       g~plant_name1,
       g~address1,
       g~address2,
       g~city,
       g~state_name,
       g~country,
       g~pin,
       h~distributionchannel,
       i~bank_details,
       i~acoount_number,
       i~ifsc_code

        FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
       LEFT JOIN ztable_plant WITH PRIVILEGED ACCESS  AS g ON a~BusinessPlace   = g~plant_code
       LEFT JOIN i_billingdocument WITH PRIVILEGED ACCESS  AS h ON a~customer   = h~payerparty
       LEFT JOIN zbank_tab  WITH PRIVILEGED ACCESS  AS i ON a~Companycode   = i~salesorg

       WHERE a~AccountingDocument = @accounting_no   AND a~CompanyCode = @Company_code AND a~FiscalYear = @fiscal_year
       AND a~debitcreditcode = 'S' AND a~financialaccounttype = 'D'
      INTO @DATA(wa_FOOTER).


    " out->write( it_item ).
    """"""""""""""""""""""""""""""CGST """""""""""""""""""""""""""""""""""

    SELECT FROM i_operationalacctgdocitem  AS a
    FIELDS a~amountincompanycodecurrency,
     a~AccountingDocument,
     a~CompanyCode,
     a~TaxItemGroup,
     a~FiscalYear,
    a~transactiontypedetermination
    WHERE a~AccountingDocument = @accounting_no   AND a~CompanyCode = @Company_code AND a~FiscalYear = @fiscal_year
    AND a~AmountInCompanyCodeCurrency < -1 AND
     a~transactiontypedetermination  = 'JOC'
    INTO TABLE @DATA(it_cgst_amt).

*out->write( it_cgst_amt ).


*   out->write( it_cgst_amt ).
    """"""""""""""""""""""""""""""SGST """""""""""""""""""""""""""""""""""

    SELECT FROM i_operationalacctgdocitem  AS a
    FIELDS a~amountincompanycodecurrency,
     a~AccountingDocument,
     a~CompanyCode,
     a~FiscalYear,
     a~TaxItemGroup,
    a~transactiontypedetermination
    WHERE a~AccountingDocument = @accounting_no   AND a~CompanyCode = @Company_code AND a~FiscalYear = @fiscal_year
    AND a~AmountInCompanyCodeCurrency < -1 AND
     a~transactiontypedetermination  = 'JOS'
    INTO TABLE @DATA(it_sgst_amt).

*out->write( it_sgst_amt ).


    """"""""""""""""""""""""""""""IGST """""""""""""""""""""""""""""""""""
    SELECT FROM i_operationalacctgdocitem  AS a
        FIELDS a~amountincompanycodecurrency,
         a~AccountingDocument,
         a~CompanyCode,
         a~TaxItemGroup,
         a~FiscalYear,
        a~transactiontypedetermination
        WHERE a~AccountingDocument = @accounting_no   AND a~CompanyCode = @Company_code AND a~FiscalYear = @fiscal_year
        AND a~transactiontypedetermination  = 'JOI'  AND a~AmountInCompanyCodeCurrency < -1
        INTO TABLE @DATA(it_igst_amt).


*out->write( it_igst_amt ).

    """'ROUNDOFF,HSNCODE""""""""""""'''''''

    SELECT
      a~AmountInCompanyCodeCurrency AS AmountInCompanyCodeCurrency

    FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
    WHERE a~AccountingDocument = @accounting_no   AND a~CompanyCode = @Company_code AND a~FiscalYear = @fiscal_year
      AND a~AccountingDocumentItemType <> 'T'
      AND a~CostElement IS NOT INITIAL
      AND a~AmountInCompanyCodeCurrency > -1
      INTO @DATA(roundoff).

    ENDSELECT.



    DATA(lv_xml) =
       |<form>| &&
       |<header>| &&
       |<companycode>{ wa_head-CompanyCode }</companycode>| &&
       |<companyName>{ wa_head-CompanyCodeName }</companyName>| &&
       |<PlantAdd> { PLANT_add1 }</PlantAdd>| &&
       |<pan_no>{ wa_head-pan_no  }</pan_no>| &&
       |<gstin_no>{ wa_head-gstin_no }</gstin_no>| &&
       |<FSSAI_NO>{ wa_head-fssai_no }</FSSAI_NO>| &&
       |<cin_NO>{ cin }</cin_NO>| &&
       |<ackno>{ wa_head-ackno }</ackno>| &&
       |<ackdate>{ wa_head-ackdate }</ackdate>| &&
       |<ewaybillno>{ wa_head-ewaybillno }</ewaybillno>| &&
        |<ewaydate>{ wa_head-ewaydate }</ewaydate>| &&
        |<irnno>{ wa_head-irnno }</irnno>| &&
       |<BillTo>| &&
         |<customerno>{ wa_head_bill-Customer }</customerno>| &&
         |<customerName>{ wa_head_bill-CustomerName }</customerName>| &&
        |<customeradd>{ bill_to }</customeradd>| &&
       |<PhoneNumber1>{ wa_head_bill-TelephoneNumber1 }</PhoneNumber1>| &&
       |<PhoneNumber2>{ wa_head_bill-TelephoneNumber2 }</PhoneNumber2>| &&
        |<gstin>{ wa_head_bill-TaxNumber3 }</gstin>| &&
        |<stateName>{ wa_head_bill-RegionName }</stateName>| &&
         |<placeOfSupply>{ wa_head_bill-RegionName }</placeOfSupply>| &&
         |<BPIdentificationNumber>{ wa_head_bill-BPIdentificationNumber }</BPIdentificationNumber>| &&
         |</BillTo>| &&
         |<supplierDetails>| &&
       |<supplier>{ wa_head_ship-Customer }</supplier>| &&
       |<supName>{ wa_head_ship-CustomerName }</supName>| &&
       |<address1>{ ship_to }</address1>| &&
       |<supp_PhoneNumber1>{ wa_head_ship-TelephoneNumber1 }</supp_PhoneNumber1>>| &&
       |<supp_PhoneNumber2>{ wa_head_ship-TelephoneNumber2 }</supp_PhoneNumber2>>| &&
        |<supp_gstin>{ wa_head_ship-TaxNumber3 }</supp_gstin>| &&
        |<supp_stateName>{ wa_head_ship-RegionName }</supp_stateName>| &&
         |<supp_placeOfSupply>{ wa_head_ship-RegionName }</supp_placeOfSupply>| &&
         |<BPIdentificationNumber>{ wa_head_ship-BPIdentificationNumber }</BPIdentificationNumber>| &&
         |</supplierDetails>| &&
*         |<invoiceNo>{ wa_head_invoice- }</invoiceNo>| &&
         |<REF_NO>{ wa_head_invoice-OriginalReferenceDocument }</REF_NO>| &&
         |<invDate>{ wa_head_invoice-DocumentDate }</invDate>| &&
          |<IncotermsLocation1>{ wa_head_invoice-IncotermsLocation1 }</IncotermsLocation1>| &&
          |<IncotermsClassification>{ wa_head_invoice-IncotermsClassification }</IncotermsClassification>| &&
         |</header>| &&
          |<itemNode>|.

    DATA: lv_igst_amt TYPE string,
          lv_cgst_amt TYPE string,
          lv_sgst_amt TYPE string,
          lv_xml13    TYPE string.

    DATA : srno TYPE string.
    LOOP AT it_item INTO DATA(wa_line).
      srno  = srno + 1.
      DATA(lv_xml2) =
          |<item>| &&
          |<No_Need_Node></No_Need_Node>| &&
         |<s_no>{ srno   }</s_no>| &&
          |<gl_des>{ wa_line-GLAccountName }</gl_des>| &&
          |<gl_des>{ wa_line-GLAccountName }</gl_des>| &&
          |<Material>{ wa_line-product }</Material>| &&
          |<AmountInCompanyCodeCurrency>{ wa_line-amountincompanycodecurrency }</AmountInCompanyCodeCurrency>| &&
         |<ProductDescription>{ wa_line-ProductDescription }</ProductDescription>| &&
          |<IN_HSNOrSACCode>{ wa_line-IN_HSNOrSACCode }</IN_HSNOrSACCode>| &&
          |<QTY>{ wa_line-Quantity }</QTY>| &&
          |<BaseUnit>{ wa_line-BaseUnit }</BaseUnit>| .


      READ TABLE it_cgst_amt INTO DATA(wa_camt) WITH KEY
      AccountingDocument = wa_line-AccountingDocument  CompanyCode = wa_line-CompanyCode  FiscalYear = wa_line-FiscalYear TaxItemGroup = WA_LINE-TaxItemGroup.
      "   transactiontypedetermination  = 'JOC' .
      DATA(lv_cgstAmt) =
|<cgstAmt>{ wa_camt-AmountInCompanyCodeCurrency }</cgstAmt>|.

      READ TABLE it_sgst_amt INTO DATA(wa_samt) WITH KEY AccountingDocument = wa_line-AccountingDocument  CompanyCode = wa_line-CompanyCode  FiscalYear = wa_line-FiscalYear TaxItemGroup = WA_LINE-TaxItemGroup.
*      AccountingDocument = '1800000015' CompanyCode = 'BNAL'  FiscalYear = '2025'
      "transactiontypedetermination  = 'JOS' .
      DATA(lv_sgstAmt) =
              |<sgstAmt>{ wa_samt-AmountInCompanyCodeCurrency }</sgstAmt>|.


      READ TABLE it_igst_amt INTO DATA(wa_iamt) WITH KEY AccountingDocument = wa_line-AccountingDocument  CompanyCode = wa_line-CompanyCode  FiscalYear = wa_line-FiscalYear TaxItemGroup = WA_LINE-TaxItemGroup.
*      AccountingDocument = '1800000015' CompanyCode = 'BNAL'  FiscalYear = '2025'
      "transactiontypedetermination  = 'JOI' .
      DATA(lv_igstAmt) =
              |<igstAmt>{ wa_iamt-AmountInCompanyCodeCurrency }</igstAmt>|.
*     CLEAR : wa_camt, wa_iamt, wa_samt.

      CONCATENATE lv_xml lv_xml2 lv_cgstamt lv_sgstamt  lv_igstamt  '|</item>|' INTO lv_xml.
      CLEAR wa_camt.
      CLEAR wa_samt.
      CLEAR wa_iamt.
*        CLEAR wa_uamt.
      CLEAR wa_line.
    ENDLOOP.

    .
*CONCATENATE lv_xml lv_xml2  INTO lv_xml.

    DATA(lv_footer) =
         |</itemNode>| &&
        |<footer>| &&
        |<Branch>{ wa_footer-plant_name1 }</Branch>| &&
        "branch adress
        |<remarks>{ wa_footer-DocumentItemText }</remarks>| &&
        |<bank_details>{ wa_footer-bank_details  }</bank_details>| &&
        |<acoount_number>{ wa_footer-acoount_number }</acoount_number>| &&
        |<ifsc_code>{ wa_footer-ifsc_code }</ifsc_code>| &&

         |<ROUNDOFF>{ roundoff }</ROUNDOFF>| &&
        |</footer>| .




    " Close XML structure
    CONCATENATE lv_xml lv_footer '</form>' INTO lv_xml.

    " Replace special characters
    REPLACE ALL OCCURRENCES OF '&' IN lv_xml WITH 'and'.
    REPLACE ALL OCCURRENCES OF '<=' IN lv_xml WITH 'let'.
    REPLACE ALL OCCURRENCES OF '>=' IN lv_xml WITH 'get'.

*    out->write( lv_cgstamt ).
*out->write( lv_sgstamt ).
*out->write( lv_xml ).



*
    CALL METHOD zcl_ads_print=>getpdf(
      EXPORTING
        xmldata  = lv_xml
        template = lc_template_name
      RECEIVING
        result   = result12 ).



  ENDMETHOD.
ENDCLASS.
