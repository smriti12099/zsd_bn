@EndUserText.label: 'BP Partner Function Database Table Singl'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'BpPartnerFunctioAll'
  }
}
define root view entity ZI_BpPartnerFunctionDa_S
  as select from I_Language
    left outer join ZDT_BP_PARTNER on 0 = 0
  composition [0..*] of ZI_BpPartnerFunctionDa as _BpPartnerFunctionDa
{
  @UI.facet: [ {
    id: 'ZI_BpPartnerFunctionDa', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: 'BP Partner Function Database Table', 
    position: 1 , 
    targetElement: '_BpPartnerFunctionDa'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _BpPartnerFunctionDa,
  @UI.hidden: true
  max( ZDT_BP_PARTNER.LAST_CHANGED_AT ) as LastChangedAtMax
  
}
where I_Language.Language = $session.system_language
