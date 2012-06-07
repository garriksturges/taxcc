/******************************************************************************************************************************************
Trigger Name : PreventDuplicateEmploymentPeriod
Created By   : Nagaraju Naidu
Description  : This Trigger prevents adding a EmploymentPeriod with same Entity, Employee & Start Date.   
Modification History: 
   
*******************************************************************************************************************************************/

trigger PreventDuplicateEmploymentPeriod on Employment__c (before insert, before update) 
{
Set<string> setEntity=new Set<string>();
Set<string> setEmployee=new Set<string>();
Set<Date> setStartDate=new Set<Date>();
Map<string,Id> mapEmployment=new Map<string,Id>();
for(Employment__c Employment:trigger.new)
{
setEntity.add(Employment.Entity__c);
setEmployee.add(Employment.Employee__c);
setStartDate.add(Employment.StartDate__c);
}
List<Employment__c> lstEmployment=[select id,Entity__c,Employee__c,StartDate__c from Employment__c where Entity__c in :setEntity and Employee__c in :setEmployee and StartDate__c in :setStartDate];
for(Employment__c Employment:lstEmployment)
{
string combinekey=string.valueof(Employment.Entity__c)+string.valueof(Employment.Employee__c)+string.valueof(Employment.StartDate__c);
mapEmployment.put(combinekey,Employment.Id);
}

for(Employment__c Employment:trigger.new)
{
string combinekey=string.valueof(Employment.Entity__c)+string.valueof(Employment.Employee__c)+string.valueof(Employment.StartDate__c);
if(mapEmployment.containsKey(combinekey))
{
if ((Trigger.isInsert) || ((Trigger.isUpdate) && (mapEmployment.get(combinekey) !=Employment.Id)))
{
    Employment.addError('This employee is already working for this entity on this hire date, according to data previously entered by someone around here.');
}
}
}
}