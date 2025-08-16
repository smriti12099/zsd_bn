@EndUserText.label: 'BP Partner Function Database Table'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_BpPartnerFunctionDa
  as select from zdt_bp_partner
  association to parent ZI_BpPartnerFunctionDa_S as _BpPartnerFunctioAll on $projection.SingletonID = _BpPartnerFunctioAll.SingletonID
{
  key customer              as Customer,
  key sales_org             as SalesOrg,
  key dist_channel          as DistChannel,
  key division              as Division,
      partner_function      as PartnerFunction,
      bpcustomernumber      as Bpcustomernumber,
      processed             as Processed,
      log                   as Log,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      @Consumption.hidden: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      @Consumption.hidden: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Consumption.hidden: true
      1                     as SingletonID,
      _BpPartnerFunctioAll

}
