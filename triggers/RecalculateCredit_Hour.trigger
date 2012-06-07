/***************************************************************************************************************************************************************
Trigger Name : RecalculateCredit_Hour
Created By   : Srikanth Pothuraj
Created Date : 10/23/2011
Descriprtion : This Trigger fires when Hour records are Inserted, Updated or Deleted in order to calulate the Credits 
                          on its Wage records which has an Employment Period.   
Modification History :               
*****************************************************************************************************************************************************************/
trigger RecalculateCredit_Hour on Hour__c (after delete, after insert, after undelete, after update) {
    
 try{
     if(!processorcontrol.InFutureContext)
     {
      processorcontrol.InFutureContext = true;  
        
        Set<Id> hourId = new Set<Id>();
        Set<Id> WageIds = new Set<Id>(); 
        
        if(Trigger.isDelete)
        {       
            if(Trigger.isAfter)
            {       
                //System.debug('Wage Old Id::'+System.Trigger.OldMap.keyset());
                for(Hour__c hour : System.Trigger.Old)
                {
                    WageIds.Add(hour.Wage__c);
                }
                
                for(Hour__c h : [Select Wage__c, Name, Id, HourEID__c From Hour__c where Wage__c in : WageIds ])
                {
                    System.debug('Hour Id::'+h.Id);
                    hourId.add(h.Id);
                }
            }
            
        }
        else
        {   
            for(Hour__c hour : System.Trigger.New)
            {
                hourId.add(hour.Id);      
            }
            ProcessorControl.inFutureContext = true;
            
           /*  List<Hour__c> HrList=[select Id,Name,FullNameFormula__c from Hour__c where Id in:Trigger.New];
  
            for(Hour__c hour: HrList )
              {
              hour.Name=hour.FullNameFormula__c;
              
              }
              update HrList; */
                        
        }   
        
        MapProgramEmployment objProgEmpl = new MapProgramEmployment(); 
        
        objProgEmpl.calculateCredit(hourId, 'Hour');
        
        }
      }  
     catch(Exception ec){}

}