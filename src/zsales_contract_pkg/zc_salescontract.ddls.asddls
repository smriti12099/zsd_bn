@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS for Sales Contract'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_SALESCONTRACT as select from I_SalesContract
{
     //Key
  key SalesContract,

      //Category
      SalesContractType,

      //Admin
      CreatedByUser,
      LastChangedByUser,
      
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangeDateTime,

      //Org
      SalesOrganization,
      DistributionChannel,
      OrganizationDivision,
      SalesGroup,
      SalesOffice,

      //Sales
      @Consumption.valueHelpDefinition: [
       { entity:  { name:    'I_Customer_VH',
                    element: 'Customer' }
       }]
      SoldToParty,
      CustomerGroup,
      AdditionalCustomerGroup1,
      AdditionalCustomerGroup2,
      AdditionalCustomerGroup3,
      AdditionalCustomerGroup4,
      AdditionalCustomerGroup5,

      @Consumption.valueHelpDefinition: [
       { entity:  { name:    'I_CreditControlAreaStdVH',
                    element: 'CreditControlArea' }
       }]
      CreditControlArea,
      CustomerRebateAgreement,
      ServicesRenderedDate,
      SDDocumentReason,
      PurchaseOrderByCustomer,
      PurchaseOrderByShipToParty,
      CustomerPurchaseOrderType,
      CustomerPurchaseOrderDate,
      CustomerPurchaseOrderSuplmnt,
      SalesDistrict,
      ProductCatalog,

      //Contract
      SalesContractSignedDate,
      ContractPartnerCanclnDocDate,
      NmbrOfSalesContractValdtyPerd,
      SalesContractValidityPerdUnit,
      SalesContractValidityPerdCat,
      SlsContractCanclnReqRcptDate,
      RequestedCancellationDate,
      SalesContractCanclnParty,
      SalesContractCanclnReason,
      SalesContractCanclnProcedure,
      EquipmentInstallationDate,
      EquipmentDeliveryAccptcDate,
      EquipmentDismantlingDate,
      SalesContractFollowUpAction,
      SlsContractFollowUpActionDate,
      CanclnDocByContrPartner,
      @Analytics.internalName: #LOCAL
      MasterSalesContract,

      //Pricing
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      TotalNetAmount,
      TransactionCurrency,
      PricingDate,
      @Analytics.internalName: #LOCAL
      SDPricingProcedure,
      @Analytics.internalName: #LOCAL
      CustomerPriceGroup,
      RetailPromotion,
      PriceDetnExchangeRate,
      @Analytics.internalName: #LOCAL
      PriceListType,
      
      @Analytics.internalName: #LOCAL
      TaxDepartureCountry,
      @Analytics.internalName: #LOCAL
      VATRegistrationCountry,

      //Shipping
      ShippingCondition,
      IncotermsClassification,
      IncotermsTransferLocation,
      IncotermsLocation1,
      IncotermsLocation2,
      IncotermsVersion,
      CompleteDeliveryIsDefined,
      ShippingType,

      //Billing
      BillingDocumentDate,
      @Consumption.valueHelpDefinition: [
      { entity:  { name:    'I_CompanyCodeStdVH',
                   element: 'CompanyCode' }
      }]
      BillingCompanyCode,

      //Payment
      CustomerPaymentTerms,
      PaymentMethod,
      FixedValueDate,
      AdditionalValueDays,

      //Accounting
      FiscalYear,
      FiscalPeriod,
      ExchangeRateDate,
      ExchangeRateType,
      @Consumption.valueHelpDefinition: [
       { entity:  { name:    'I_BusinessAreaStdVH',
                    element: 'BusinessArea' }
       }]
      BusinessArea,
      CustomerAccountAssignmentGroup,
      @Consumption.valueHelpDefinition: [
       { entity:  { name:    'I_BusinessAreaStdVH',
                    element: 'BusinessArea' }
       }]
      CostCenterBusinessArea,
      CostCenter,
      @Consumption.valueHelpDefinition: [
       { entity:  { name:    'I_ControllingAreaStdVH',
                    element: 'ControllingArea' }
       }]
      ControllingArea,
      OrderID,
      AssignmentReference,

      //Reference
      ReferenceSDDocument,
      ReferenceSDDocumentCategory,
      @Analytics.internalName: #LOCAL
      AccountingDocExternalReference,

      //Status
      OverallSDProcessStatus,
      OverallSDDocumentRejectionSts,
      TotalBlockStatus,
      OverallTotalSDDocRefStatus,
      OverallSDDocReferenceStatus,
      TotalCreditCheckStatus,
      MaxDocValueCreditCheckStatus,
      PaymentTermCreditCheckStatus,
      FinDocCreditCheckStatus,
      ExprtInsurCreditCheckStatus,
      PaytAuthsnCreditCheckSts,
      CentralCreditCheckStatus,
      CentralCreditChkTechErrSts,
      HdrGeneralIncompletionStatus,
      OverallPricingIncompletionSts,
      HeaderBillgIncompletionStatus,
      OvrlItmGeneralIncompletionSts,
      OvrlItmBillingIncompletionSts,
      ContractDownPaymentStatus,
      @Analytics.internalName: #LOCAL
      SalesDocApprovalStatus,
      ContractManualCompletion,

      OverallBillingBlockStatus,
      HeaderBillingBlockReason,

      // Product Compliance Status
      @Analytics.internalName: #LOCAL
      OverallChmlCmplncStatus,
      @Analytics.internalName: #LOCAL
      OverallDangerousGoodsStatus,
      @Analytics.internalName: #LOCAL
      OverallSafetyDataSheetStatus,

      //Trade Compliance Status
      @Analytics.internalName: #LOCAL
      OverallTrdCmplncEmbargoSts,
      @Analytics.internalName: #LOCAL
      OvrlTrdCmplncSnctndListChkSts,
      @Analytics.internalName: #LOCAL
      OvrlTrdCmplncLegalCtrlChkSts
}
