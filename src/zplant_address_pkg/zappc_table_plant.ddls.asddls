@Metadata.allowExtensions: true
@EndUserText.label: 'Plant Table App'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZAPPC_TABLE_PLANT
  provider contract transactional_query
  as projection on ZAPPR_TABLE_PLANT
{
  key CompCode,
  key PlantCode,
  CompanyName,
  PlantName1,
  PlantName2,
  Address1,
  Address2,
  Address3,
  City,
  District,
  StateCode1,
  StateCode2,
  StateName,
  Pin,
  Country,
  CinNo,
  GstinNo,
  PanNo,
  TanNo,
  Email,
  FssaiNo,
  MobNo,
  Remark1,
  Remark2,
  Remark3,
  Weightpath,
  CreatedBy,
  CreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
  LastChangedAt
  
}
