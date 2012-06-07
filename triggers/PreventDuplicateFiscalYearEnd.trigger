/******************************************************************************************************************************************
Trigger Name : PreventDuplicateFiscalYearEnd
Created By   : Nagaraju Naidu
Description  : This Trigger prevents adding same Fiscal Year End date under Entity.   
Modification History: 
   
*******************************************************************************************************************************************/

trigger PreventDuplicateFiscalYearEnd on EntityFiscalyear__c (before insert, before update) {

   set<Id> newefy = new set<Id>();
   for(EntityFiscalyear__c b : Trigger.new){
     newefy.add(b.Entity__c);
   } 
   
   Map<Date, Id> existefy =  new Map<Date, Id>();
   
   for (EntityFiscalyear__c efy : [select Id, FiscalYearEndDate__c from EntityFiscalyear__c where Entity__c in: newefy]){  
       existefy.put(efy.FiscalYearEndDate__c,efy.Id );
   }
   
   for (EntityFiscalyear__c b2 : Trigger.new) {
       if (existefy.containsKey(b2.FiscalYearEndDate__c)){
           if ((Trigger.isInsert) || ((Trigger.isUpdate) && (existefy.get(b2.FiscalYearEndDate__c) != b2.Id))) {
             b2.addError('There is already a ' +b2.FiscalYearEndDate__c + ' for this entity.');
             }
         }
     }     
}