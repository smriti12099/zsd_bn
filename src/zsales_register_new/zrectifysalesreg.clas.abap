CLASS zrectifysalesreg DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZRECTIFYSALESREG IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.









*  DATA billingdoc TYPE C LENGTH 10.
*
*  billingdoc = '0090000184'.
*
  delete from zsales_reg_tb WHERE billingdocument is not INITIAL.
*
*  Select from i_billingdocument as a
*            left join i_billingdocumentitem as b on a~BillingDocument = b~BillingDocument
*            LEFT JOIN I_BillingDocumentPartner AS bdp ON bdp~BillingDocument = a~BillingDocument AND bdp~PartnerFunction = 'RE'
*            left join I_BusinessPartner as bp on bp~BusinessPartner = bdp~Customer
*            left join I_Customer as cu on cu~Customer = bdp~Customer
*            left join I_Address_2 as ad on ad~AddressID = cu~AddressID
*            left join i_productplantbasic as ppb on b~Product = ppb~Product and ppb~Plant = b~Plant
*            LEFT JOIN i_product AS p on b~Product = p~Product
*            left join i_deliverydocument as dd on b~ReferenceSDDocument = dd~DeliveryDocument
*        fields a~BillingDocument, a~BillingDocumentType, a~BillingDocumentDate, a~DocumentReferenceID, a~AccountingDocument, a~PurchaseOrderByCustomer,
*               a~SalesOrganization, a~DistributionChannel, a~Division, a~IncotermsClassification, a~IncotermsLocation1, a~CancelledBillingDocument,
*               a~AssignmentReference, a~CustomerPaymentTerms, a~SoldToParty, a~PayerParty, a~CreatedByUser, a~BillingDocumentIsCancelled,
*               b~BillingDocumentItem, b~SalesGroup, b~SalesOffice, b~Product, b~BillingDocumentItemText, b~ProductGroup, b~BillingQuantityInBaseUnit,
*                b~BillingQuantityUnit, B~ItemGrossWeight, B~ItemNetWeight, B~ItemWeightUnit, B~NetAmount, B~TaxAmount, B~TransactionCurrency,
*                b~ReferenceSDDocument,
*               bdp~customer, BDP~PartnerFunction, bdp~BillingDocument as billDoc_bdp,
*               bp~BusinessPartnername,
*               cu~taxnumber3, CU~AddressID,
*               ppb~ConsumptionTaxCtrlCode,ppb~Product as PlantProduct, ppb~Plant,
*               p~ProductType,
*               dd~DeliveryDate, dd~ActualGoodsMovementDate, dd~ShipToParty, dd~ShippingPoint
*****          WHERE NOT EXISTS (
*****               SELECT BillingDocument FROM zsales_reg_tb
*****               WHERE a~BillingDocument = zsales_reg_tb~BillingDocument AND
*****                 a~CompanyCode = zsales_reg_tb~plant ) " AND
**                 a~FiscalYear = zsales_reg_tb~ )
*
**        where a~BillingDocument in @lt_invoice_no
**            AND a~BillingDocumentDate in @lt_Invoice_Date
**            and a~SalesOrganization in @lt_Sales_Org
**            and a~DistributionChannel in @lt_Dist_Channel
**            and p~ProductType in @lt_Mat_Type_Code
**            and b~ProductGroup in @lt_Mat_Grp
**            and bdp~Customer in @lt_Bill_party
**            and a~Division in @lt_Sales_Div
*        where a~BillingDocument = @billingdoc
*            into TABLE @DATA(it_header)
*            PRIVILEGED ACCESS.
*
*    Select from i_billingdocument as a
*            left join i_billingdocumentitem as b on a~BillingDocument = b~BillingDocument
**            LEFT JOIN I_BillingDocumentPartner AS bdp ON bdp~BillingDocument = a~BillingDocument AND bdp~PartnerFunction = 'RE'
**            left join I_BusinessPartner as bp on bp~BusinessPartner = bdp~Customer
**            left join I_Customer as cu on cu~Customer = bdp~Customer
**            left join I_Address_2 as ad on ad~AddressID = cu~AddressID
*            left join i_productplantbasic as ppb on b~Product = ppb~Product and ppb~Plant = b~Plant
*            LEFT JOIN i_product AS p on b~Product = p~Product
*            left join i_deliverydocument as dd on b~ReferenceSDDocument = dd~DeliveryDocument
*        fields a~BillingDocument, a~BillingDocumentType, a~BillingDocumentDate, a~DocumentReferenceID, a~AccountingDocument, a~PurchaseOrderByCustomer,
*               a~SalesOrganization, a~DistributionChannel, a~Division, a~IncotermsClassification, a~IncotermsLocation1, a~CancelledBillingDocument,
*               a~AssignmentReference, a~CustomerPaymentTerms, a~SoldToParty, a~PayerParty, a~CreatedByUser, a~BillingDocumentIsCancelled,
*               b~BillingDocumentItem, b~SalesGroup, b~SalesOffice, b~Product, b~BillingDocumentItemText, b~ProductGroup, b~BillingQuantityInBaseUnit,
*                b~BillingQuantityUnit, B~ItemGrossWeight, B~ItemNetWeight, B~ItemWeightUnit, B~NetAmount, B~TaxAmount, B~TransactionCurrency,
*                b~ReferenceSDDocument,
**               bdp~customer, BDP~PartnerFunction, bdp~BillingDocument as billDoc_bdp,
**               bp~BusinessPartnername,
**               cu~taxnumber3, CU~AddressID,
*               ppb~ConsumptionTaxCtrlCode,ppb~Product as PlantProduct, ppb~Plant,
*               p~ProductType,
*               dd~DeliveryDate, dd~ActualGoodsMovementDate, dd~ShipToParty, dd~ShippingPoint
*****          WHERE NOT EXISTS (
*****               SELECT BillingDocument FROM zsales_reg_tb
*****               WHERE a~BillingDocument = zsales_reg_tb~BillingDocument AND
*****                 a~CompanyCode = zsales_reg_tb~plant ) " AND
**                 a~FiscalYear = zsales_reg_tb~ )
*
**        where a~BillingDocument in @lt_invoice_no
**            AND a~BillingDocumentDate in @lt_Invoice_Date
**            and a~SalesOrganization in @lt_Sales_Org
**            and a~DistributionChannel in @lt_Dist_Channel
**            and p~ProductType in @lt_Mat_Type_Code
**            and b~ProductGroup in @lt_Mat_Grp
**            and bdp~Customer in @lt_Bill_party
**            and a~Division in @lt_Sales_Div
*        where a~BillingDocument = @billingdoc
*            into TABLE @DATA(it_header1)
*            PRIVILEGED ACCESS.
*
*    DATA abcd TYPE C LENGTH 1.
*    abcd = 'A'.

  ENDMETHOD.
ENDCLASS.
