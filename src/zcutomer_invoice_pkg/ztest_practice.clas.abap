CLASS ztest_practice DEFINITION
  PUBLIC


  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS ZTEST_PRACTICE IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

*    var1 = accountingDocNo.
*    var1 =   |{ |{ var1 ALPHA = OUT }| ALPHA = IN }| .
*    DATA(lv_accountingDocNo) = var1.
    "*************************************************************top header details
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
 WHERE a~AccountingDocument = '1800000017'   AND a~CompanyCode = 'BNAL' AND a~FiscalYear = '2025'
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
    WHERE a~AccountingDocument = '1800000017'
      AND a~CompanyCode = 'BNAL'
      AND a~FiscalYear = '2025'
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
    WHERE a~CompanyCode = 'BNAL'
      AND a~AccountingDocument = '1800000017'
      AND a~FiscalYear = '2025'
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
        WHERE a~AccountingDocument = '1800000017'   AND a~CompanyCode = 'BNAL' AND a~FiscalYear = '2025'
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
         a~amountincompanycodecurrency,
         b~productdescription,
       c~glaccount,
         c~glaccountname

    FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
    LEFT JOIN i_glaccounttextrawdata WITH PRIVILEGED ACCESS AS c ON a~GLAccount = c~GLAccount
     LEFT JOIN i_productdescription  WITH PRIVILEGED ACCESS AS b ON a~product = b~Product
    WHERE a~CompanyCode = 'BNAL'
      AND a~AccountingDocument = '1800000017'
      AND a~FiscalYear = '2025'
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

       WHERE a~AccountingDocument = '1800000017'    AND a~CompanyCode = 'BNAL' AND a~FiscalYear = '2025'
       AND a~debitcreditcode = 'S' AND a~financialaccounttype = 'D'
      INTO @DATA(wa_FOOTER).


    " out->write( it_item ).
    """"""""""""""""""""""""""""""CGST """""""""""""""""""""""""""""""""""

    """'ROUNDOFF,HSNCODE""""""""""""'''''''

    SELECT
      a~AmountInCompanyCodeCurrency AS AmountInCompanyCodeCurrency

    FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS AS a
    WHERE a~CompanyCode = 'BNAL'
      AND a~AccountingDocument = '1800000017'
      AND a~FiscalYear = '2025'
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





    LOOP AT it_item INTO DATA(wa_line).

      DATA(lv_xml2) =
          |<item>| &&
          |<No_Need_Node></No_Need_Node>| &&
          |<gl_des>{ wa_line-GLAccountName }</gl_des>| &&
          |<gl_des>{ wa_line-GLAccountName }</gl_des>| &&
          |<Material>{ wa_line-product }</Material>| &&
          |<AmountInCompanyCodeCurrency>{ wa_line-amountincompanycodecurrency }</AmountInCompanyCodeCurrency>| &&
         |<ProductDescription>{ wa_line-ProductDescription }</ProductDescription>| &&
          |<IN_HSNOrSACCode>{ wa_line-IN_HSNOrSACCode }</IN_HSNOrSACCode>| &&
          |<QTY>{ wa_line-Quantity }</QTY>| &&
          |<BaseUnit>{ wa_line-BaseUnit }</BaseUnit>| .
CONCATENATE lv_xml lv_xml2   '|</item>|' INTO lv_xml.

 ENDLOOP.



   SELECT
  a~ACCOUNTINGDOCUMENT,
  a~COMPANYCODE,
  a~FISCALYEAR,
  a~AMOUNTINCOMPANYCODECURRENCY,
  a~TRANSACTIONTYPEDETERMINATION
  FROM i_operationalacctgdocitem  WITH PRIVILEGED ACCESS as a
 WHERE a~AccountingDocument = '1800000017' AND  a~FiscalYear = '2025'
  AND a~AmountInCompanyCodeCurrency < -1 AND a~CompanyCode = 'BNAL'
 AND a~TransactionTypeDetermination IN ( 'JOI','JOC','JOS' )
  INTO TABLE @DATA(gst).
*  out->write( gst ).
DATA igst_Amount TYPE STRING.
DATA Sgst_Amount TYPE STRING.
DATA Sgst_Rate TYPE STRING.
DATA Sgst_Rategst TYPE STRING.
DATA Cgst_Amount TYPE STRING.



 LOOP AT gst INTO DATA(wa_gst).
  if  wa_gst-TransactionTypeDetermination = 'JOI' .
       igst_amount = wa_gst-AmountInCompanyCodeCurrency.

       ELSEIF wa_gst-TransactionTypeDetermination = 'JOC'.
        cgst_amount = wa_gst-AmountInCompanyCodeCurrency.
        ELSEIF wa_gst-TransactionTypeDetermination = 'JOS'.
         sgst_amount = wa_gst-AmountInCompanyCodeCurrency.

  ENDIF.


   DATA(lv_wa_gst) =
   |<Gst>| &&
  |<igst_Amount>{ igst_amount }</igst_Amount>| &&
  |<Sgst_Amount>{ cgst_amount }</Sgst_Amount>| &&
  |<Cgst_Amount>{ cgst_amount }</Cgst_Amount>| &&
  |<Cgst_Rate>{ sgst_rate }</Cgst_Rate>| &&
  |<igst_Rate>{ Sgst_Rategst }</igst_Rate>| &&
   |</Gst>|.

  CONCATENATE lv_xml lv_wa_gst INTO lv_xml.

 ENDLOOP.

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
out->write( lv_xml ).



*
*     CALL METHOD zcl_ads_print=>getpdf(
*       EXPORTING
*         xmldata  = lv_xml
*         template = lc_template_name
*       RECEIVING
*         result   = result12 ).




  ENDMETHOD.
ENDCLASS.
