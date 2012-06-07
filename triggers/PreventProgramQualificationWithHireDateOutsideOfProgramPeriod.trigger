/******************************************************************************************************************************************
Trigger Name : PreventProgramQualificationWithHireDateOutsideOfProgramPeriod  
Created By   : Nagaraju Naidu
Description  : This Trigger prevents invalid Employment startDate with Program Period under Program Qualification. 
Modification History: 
   
*******************************************************************************************************************************************/

trigger PreventProgramQualificationWithHireDateOutsideOfProgramPeriod  on ProgramQualification__c (before insert,before update) 
{
  Set<Id> setempperiod=new Set<Id>();
  Set<Id> setprgperiod=new Set<Id>();

for(ProgramQualification__c prgQual:trigger.new)
{
 setempperiod.add(prgQual.Employment__c);
 setprgperiod.add(prgQual.ProgramPeriod__c);
}

Map<Id,Employment__c> MapEmployment=new Map<Id,Employment__c>([select id,StartDate__c,EndDate__c from Employment__c where id in:setempperiod]);
Map<Id,ProgramPeriod__c> MapPrgPeriod=new Map<Id,ProgramPeriod__c>([select id,StartDate__c,EndDate__c from ProgramPeriod__c where id in:setprgperiod]);
for(ProgramQualification__c prgQual:trigger.new)
{
  Employment__c Employment=MapEmployment.get(prgQual.Employment__c);
  ProgramPeriod__c PrgPeriod=MapPrgPeriod.get(prgQual.ProgramPeriod__c);
  if(PrgPeriod.EndDate__c!=null)
  {
    if(Employment.StartDate__c>=PrgPeriod.StartDate__c && Employment.StartDate__c<=PrgPeriod.EndDate__c)
    {}
    else
      prgQual.addError('That program was not active at the time this person was hired. If you think it was, there\'s probably another program period record for this program.');
  }
  else
  if(Employment.StartDate__c>=PrgPeriod.StartDate__c)
  {}
  else
    prgQual.addError('That program was not active at the time this person was hired. If you think it was, there\'s probably another program period record for this program.');
}

}