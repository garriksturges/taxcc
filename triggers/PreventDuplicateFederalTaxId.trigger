/******************************************************************************************************************************************
Trigger Name : PreventDuplicateFederalTaxId
Created By   : Nagaraju Naidu
Description  : This Trigger prevents adding a same Federal Tax ID under Entity Structure.   
Modification History: 
   
*******************************************************************************************************************************************/

trigger PreventDuplicateFederalTaxId on EntityStructure__c (before insert, before update){
    
    List<String> uniqueValueList = new List<String>();
    for(EntityStructure__c a : Trigger.new){
        System.Debug(a.FederalTaxId__c );
        uniqueValueList.add(a.FederalTaxId__c);
    }
    
    List<EntityStructure__c> acctList = [select id, FederalTaxId__c from EntityStructure__c where FederalTaxId__c IN :uniqueValueList];
    
    Map<String,EntityStructure__c> uniqueValueMap = new Map<String,EntityStructure__c>();
    for(EntityStructure__c a : acctList){
        uniqueValueMap.put(a.FederalTaxId__c,a);        
    }
    for(EntityStructure__c a : Trigger.new){
        if(uniqueValueMap.containsKey(a.FederalTaxId__c )){
            if(trigger.isInsert || (trigger.isUpdate && a.FederalTaxId__c<>null &&a.id<>uniqueValueMap.get(a.FederalTaxId__c).id)){
                a.addError('Another business entity already has this federal tax ID. Now begins the mystery as to which one is correct.');
            }           
        }
    }
}