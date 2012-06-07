/***************************************************************************************************************************************************************
Trigger Name : RecalculateCredit_Employment
Created By   : Srikanth Pothuraj
Created Date : 10/25/2011
Descriprtion : This Trigger fires when Employment records are Inserted, Updated or Deleted in order to calulate the Credits for WOTC
                        based on its Employment records.   
Modification History :               
****************************************************************************************************************************************************************/
trigger RecalculateCredit_Employment on Employment__c (after update, after insert) {
    

    
    if (Trigger.isUpdate)
    { 
        Map<Decimal, Set<String>> progEmp = new Map<Decimal, Set<String>>();
        Set<String> empIds = new Set<String>();
        CalculateWOTC calWOTC = new CalculateWOTC();
        
        List<ProgramQualification__c>  lstPrgQlf = [Select Employment__r.StartDate__c, Employment__r.EndDate__c, Employment__r.Employee__c, Employment__r.Name,ProgramPeriod__r.Program__c, 
                                                    Employment__r.Id, Employment__c,ProgramPeriod__r.StartDate__c,ProgramPeriod__r.EndDate__c, ProgramPeriod__r.Program__r.Id,ProgramPeriod__r.Program__r.Name, ProgramPeriod__r.Program__r.ProgramEID__c
                                                    From ProgramQualification__c p where Employment__c in:Trigger.oldMap.keyset() order by ProgramPeriod__r.Program__r.Id];
                                                        
        if (lstPrgQlf.size()>0)
        {
            for (ProgramQualification__c pq : lstPrgQlf)
            {
                if ((pq.ProgramPeriod__r.StartDate__c <= pq.Employment__r.StartDate__c) && (pq.Employment__r.StartDate__c <= pq.ProgramPeriod__r.EndDate__c || pq.ProgramPeriod__r.EndDate__c == null))
                {
                    empIds.add(pq.Employment__c);
                        
                    if(pq.ProgramPeriod__r.Program__r.ProgramEID__c != null)
                        progEmp.put(pq.ProgramPeriod__r.Program__r.ProgramEID__c, empIds);
                }
                                                    
            }
            
            if(progEmp.size()> 0)
            {
                for(Decimal p : progEmp.keyset())
                {
                    if(p == 1)
                    {
                        calWOTC.CalculateWOTCCredit(p, progEmp.get(p));
                    }
                }
            }
            
        }
        
    }     
        
                                                
}