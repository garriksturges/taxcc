/***************************************************************************************************************************************************************
Trigger Name : PreventOverlappingEmployment
Created By   : Srikanth Pothuraj
Created Date :  11/8/2011
Descriprtion : When a Employment record Hire date and the Termination date is modified, The Hire date of the Employment Period should
                    not be greater than any of its Wage records Start Dates & The Termination date of the Employment should not be less 
                    than any of its Wages Start Dates.
Modification History :               
*****************************************************************************************************************************************************************/

trigger PreventOverlappingEmployment on Employment__c (before update)
{
    for (Employment__c emp : Trigger.new)
     {
        
         Employment__c Empt = [Select StartDate__c, Id, EndDate__c, (Select Id, EmploymentPeriod__c, EndDate__c, StartDate__c From Wages__r order by StartDate__c)
                                             From Employment__c where Id =: emp.Id];
                 
         if(Empt.Wages__r.size() > 0)
         {          
            if(emp.StartDate__c > Empt.Wages__r[0].StartDate__c) 
            {
                emp.addError('This employee must have actually been hired earlier than that date. The employee already has wages starting earlier.');
            }
            if(emp.EndDate__c <= Empt.Wages__r[Empt.Wages__r.size()-1].StartDate__c)
            {
                emp.addError('This employee can\'t be terminated that early. The employee was paid for a period that began after that date.');            
            }
         }
        
      }

}