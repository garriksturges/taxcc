/******************************************************************************************************************************************
Trigger Name : PreventDuplicateEntity
Created Date :  9/29/2011
Created By   : Srikanth Pothuraj
Description : This Trigger prevents adding an Entity with the same Name on an single Account.
Modification History: 
   10/7/2011 - Christopher Thaxter - Removed AccountName__c in favor of UniqueAccountEntityFormula__c; revised error message
*******************************************************************************************************************************************/

trigger PreventDuplicateEntity on Entity__c (before insert, before update) { // Events

    Map<String, Entity__c> entMap = new Map<String, Entity__c>();
    String uniqueKey;
    //String accountName;
    String entityName;



    for (Entity__c ent : System.Trigger.new) {
        //accountName = ent.AccountName__c;
        entityName = ent.Name;
        uniqueKey = ent.UniqueAccountEntityFormula__c;//accountName + entityName;
       
        if (ent.Name != null) {
    
            if (entMap.containsKey(uniqueKey)) {
                ent.Name.addError('That entity already exists in this account. I\'m just saying.');
            } else {
                entMap.put(uniqueKey, ent);
           }
       
    }  
  }
     
     if(!entMap.isEmpty()) 
     {   
       for (List<Entity__c> entCheck : [SELECT Id,UniqueAccountEntityFormula__c FROM Entity__c WHERE UniqueAccountEntityFormula__c IN :entMap.KeySet()]) {
            
            for(Entity__c ent :entCheck)
              {  
                String currentEntityId = ent.Id;
                
                if(entMap.containsKey(ent.UniqueAccountEntityFormula__c) && (currentEntityId != entMap.get(ent.UniqueAccountEntityFormula__c).Id))
                  {
                      Entity__c newEnt = entMap.get(ent.UniqueAccountEntityFormula__c);
                     newEnt.Name.addError('That entity already exists in this account. I\'m just saying.');
                  } 
              }  
        }
     }    
    }