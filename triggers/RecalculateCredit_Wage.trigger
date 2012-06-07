/***************************************************************************************************************************************************************
Trigger Name : RecalculateCredit_Wage
Created By   : Srikanth Pothuraj
Created Date : 10/23/2011
Descriprtion : This Trigger fires when Wage records are Inserted, Updated or Deleted in order to calulate the Credits 
                          on its Employment records.   
Modification History :               
*****************************************************************************************************************************************************************/


trigger RecalculateCredit_Wage on Wage__c (after undelete, after insert, after update, after delete) {
  
 try
  {
   
   System.debug('ProcessorControl.inFutureContext:::' + ProcessorControl.inFutureContext);    
 if(!ProcessorControl.inFutureContext)
  {    
    Set<Id> wageId = new Set<Id>();
    Set<Id> EmpIds = new Set<Id>(); 
    
    if(Trigger.isDelete)
    {       
        if(Trigger.isAfter)
        {       
            System.debug('Wage Old Id::'+System.Trigger.OldMap.keyset());
            for(Wage__c wge : System.Trigger.Old)
            {
                EmpIds.Add(wge.EmploymentPeriod__c);
            }
            
            for(Wage__c wag : [Select Id, EmploymentPeriod__r.StartDate__c,EmploymentPeriod__r.Entity__c, EmploymentPeriod__r.EndDate__c,
                                         EmploymentPeriod__r.Employee__c, EmploymentPeriod__c From Wage__c where EmploymentPeriod__c in : EmpIds ])
            {
                System.debug('Wage Id::'+wag.Id);
                wageId.add(wag.Id);
            }
            
            for(Employment__c  emp : [Select StartDate__c, Id, EndDate__c, (Select Id, ProgramQualification__c, ProgramCategory__c From Credits__r),
                                        (Select Id, Name From Wages__r)From Employment__c where Id in : EmpIds])
            {
                if (emp.Wages__r.size() == 0)
                {
                    delete emp.Credits__r ; 
                }
            }                           
        }
        
    }
    else
    {   
        for(Wage__c wge : System.Trigger.New)
        {
            wageId.add(wge.Id);     
        }
        
        ProcessorControl.inFutureContext = true;
      
       /* List<Wage__c> WageList=[select Id, Name, FullNameFormula__c from Wage__c where Id in: Trigger.new];
      
        for (Wage__c wge: WageList) 
        {
          wge.Name = wge.FullNameFormula__c;   
             
        }  
      
        update WageList; */
    }   
    
    MapProgramEmployment objProgEmpl = new MapProgramEmployment(); 
    
    objProgEmpl.calculateCredit(wageId, 'Wage');
   
     }
    
  }
  catch(Exception ec){} 
}