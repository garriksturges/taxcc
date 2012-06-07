/***************************************************************************************************************************************************************
Trigger Name : RecalculateCredit_PQ
Created By   : Srikanth Pothuraj
Created Date : 11/1/2011
Descriprtion : This Trigger fires when Program Qualification records are Inserted, Updated or Deleted in order to calulate the Credits for WOTC
                        based on its Employment records.   
Modification History :               
****************************************************************************************************************************************************************/
trigger RecalculateCredit_PQ on ProgramQualification__c (before update, after update) {
    

    
    if(Trigger.isBefore)
    {
        for (ProgramQualification__c p : Trigger.New) 
        {   
            if(p.Employment__c != Trigger.oldMap.get(p.Id).Employment__c)
            {
                Employment__c emp = [Select Id, (Select Id From Credits__r) From Employment__c where Id =: Trigger.oldMap.get(p.Id).Employment__c];
                
                if(emp.Credits__r.size() > 0)
                    delete emp.Credits__r;
            }
        }
    }
    
    if(Trigger.isAfter)
    {
        Map<Decimal, Set<String>> progEmp = new Map<Decimal, Set<String>>();
        CalculateWOTC calWOTC = new CalculateWOTC();
        
        List<ProgramQualification__c>  lstPrgQlf = [Select Id, Employment__r.Id, Employment__r.StartDate__c,ProgramPeriod__r.StartDate__c,ProgramPeriod__r.EndDate__c, 
                                                ProgramPeriod__r.Program__r.Id, ProgramPeriod__r.Program__r.ProgramEID__c, (Select Id from Credits__r) From ProgramQualification__c p where Id in:Trigger.oldMap.keyset()];
        
        if (lstPrgQlf.size()>0)
        {
            for (ProgramQualification__c pq : lstPrgQlf)
            {
                if ((pq.ProgramPeriod__r.StartDate__c <= pq.Employment__r.StartDate__c) && (pq.Employment__r.StartDate__c <= pq.ProgramPeriod__r.EndDate__c || pq.ProgramPeriod__r.EndDate__c == null))
                {
                
                    if(progEmp.containsKey(pq.ProgramPeriod__r.Program__r.ProgramEID__c))
                    {
                        Set<String> empIds = progEmp.get(pq.ProgramPeriod__r.Program__r.ProgramEID__c);
                        empIds.add(pq.Employment__r.Id);
                        progEmp.put(pq.ProgramPeriod__r.Program__r.ProgramEID__c, empIds);
                    }
                    else
                    {
                        Set<String> tSet = new Set<String>();
                        tSet.add(pq.Employment__r.Id);
                        progEmp.put(pq.ProgramPeriod__r.Program__r.ProgramEID__c, tSet);
                    }                               
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