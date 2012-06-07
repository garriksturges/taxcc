/******************************************************************************************************************************************
Trigger Name :  PreventDuplicateWage
Created By   :  Nagaraju Naidu
Description  :  This Trigger prevents Wage start dates should be greater than or equal to 
                the Hire date of its Employment Period record. Wage start date and end date 
                should not Fall/Overlap in-between the previous Wage start date or the End date 
                under single Employment Period.
                
Modification History: 
   
*******************************************************************************************************************************************/

trigger PreventOverlappingWage on Wage__c (before insert, before update)  
{
  try{
     if(!processorcontrol.InFutureContext)
     {      
        for(Wage__c wage : Trigger.new)
        {
            List<Wage__c> wageFromEmp = [Select id, StartDate__c, EndDate__c,EmploymentPeriod__r.EndDate__c from Wage__c where EmploymentPeriod__c =: wage.EmploymentPeriod__c order by EndDate__c desc];
            
            if(wageFromEmp.size() > 0)
            {
                if(wage.StartDate__c >= wageFromEmp[0].EmploymentPeriod__r.EndDate__c)
                        {
                            wage.addError('That would be a payment with a start date that begins after this person was terminated. That doesn\'t make what I call sense. Either there\'s something wrong with the data, or this payment should go with another employment period.');
                        }
            }
            
            if(Trigger.isInsert)
            {                                   
                if(wageFromEmp.size() > 0)
                {
                    for(Wage__c wge : wageFromEmp)
                    {
                        System.debug('wge.StartDate__c:::' +wge.StartDate__c);
                        System.debug('wge.EndDate__c:::' +wge.EndDate__c);
                        System.debug('wage.StartDate__c:::' +wage.StartDate__c);
                        System.debug('wage.EndDate__c:::' +wage.EndDate__c);
                        if((wge.StartDate__c <= wage.StartDate__c && wage.StartDate__c <= wge.EndDate__c ) ||
                            (wge.StartDate__c <= wage.EndDate__c && wage.EndDate__c <= wge.EndDate__c)  ||
                             (wage.StartDate__c <= wge.StartDate__c  &&  wge.EndDate__c <=wage.EndDate__c))
                            {
                                wage.addError('There is already another wage record that would overlap this one. Meaning, an existing record\'s end date is after the payment start date that you entered AND the existing record\'s start date is before the current record\'s end date. Clear as mud?');
                            }
                    }   
                }           
                            
            }   
            
            if(Trigger.isUpdate)
            {
                List<Wage__c> wageFrmEmp = [Select id, StartDate__c, EndDate__c,EmploymentPeriod__r.EndDate__c from Wage__c where EmploymentPeriod__c =: wage.EmploymentPeriod__c AND Id !=: wage.Id order by EndDate__c];
                
                if(wageFrmEmp.size()>0)
                {
                    for(Wage__c wge : wageFrmEmp)
                    {
                        if((wge.StartDate__c <= wage.StartDate__c && wage.StartDate__c <= wge.EndDate__c ) ||
                            (wge.StartDate__c <= wage.EndDate__c && wage.EndDate__c <= wge.EndDate__c)  ||
                            (wage.StartDate__c <= wge.StartDate__c  &&  wge.EndDate__c <=wage.EndDate__c))
                        {
                            wage.addError('There is already another wage record that would overlap this one. Meaning, an existing record\'s end date is after the payment start date that you entered AND the existing record\'s start date is before the current record\'s end date. Clear as mud?');
                        }   
                              
                    }
                } 
                                
            }                                             
    
        }
        
        }
      }  
     catch(Exception ec){}   
}