trigger UpdateWageNameAfterInsertUpdate on Wage__c (after insert, after update) {

try
    {
       
   if(!ProcessorControl.inFutureContext)
    {  
     // ProcessorControl.inFutureContext = true;
      
      List<Wage__c> WageList=[select Id, Name, FullNameFormula__c from Wage__c where Id in: Trigger.new];
      
        for (Wage__c wge: WageList) 
        {
          wge.Name = wge.FullNameFormula__c;   
             
        }  
      
        update WageList;
     }
       }
    catch(Exception ex){}  

}