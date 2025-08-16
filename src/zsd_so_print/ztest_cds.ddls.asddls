@AbapCatalog.sqlViewName: 'YTEST_CDS'
@AbapCatalog.compiler.compareFilter: true
//@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'test cds'
define view ztest_cds
  as select from I_Product as A
{
  key A.Product     as MaterialCode,
      A.ProductType as Ptyp
}
