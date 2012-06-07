/***************************************************************************************************************************************************************
Trigger Name : RecalcalculateCredit_PCQ
Created By   : Srikanth Pothuraj
Created Date : 10/24/2011
Descriprtion : This Trigger fires when  Program Category Qualification records are inserted, Updated or Deleted in order to calulate the Credits
                          on its Program Qualification which has a Employment Period.
Modification History :
*****************************************************************************************************************************************************************/

trigger RecalculateCredit_PCQ on ProgramCategoryQualification__c (after delete, after insert, after undelete, after update) {
    try
    {
        if(!ProcessorControl.inFutureContext)
        {
            Set<Id> pcqId = new Set<Id>();
            Set<Id> prgQualIds = new Set<Id>();
        
            if(Trigger.isDelete)
            {
                if(Trigger.isAfter)
                {
                    //System.debug('Wage Old Id::'+System.Trigger.OldMap.keyset());
                    for(ProgramCategoryQualification__c p : System.Trigger.Old)
                    {
                        prgQualIds.Add(p.ProgramQualification__c);
                    }
        
                    for(ProgramCategoryQualification__c pc : [Select ProgramQualification__c, ProgramCategoryQualificationEID__c, ProgramCategoryPeriod__c, Id From ProgramCategoryQualification__c where ProgramQualification__c in : prgQualIds])
                    {
                        pcqId.add(pc.Id);
                    }
        
                    for(ProgramQualification__c pq : [Select Id, Employment__c, (Select Id, Name From ProgramCategoryQualifications__r), (Select Id, ProgramQualification__c From Credits__r)
                                                         From ProgramQualification__c where Id IN: prgQualIds])
                    {
                        if(pq.ProgramCategoryQualifications__r.size() == 0)
                        {
                            delete pq.Credits__r ;
                        }
                    }
                }
            }
            else
            {
                for(ProgramCategoryQualification__c p : System.Trigger.New)
                {
                    pcqId.add(p.Id);
                }
        
                processorcontrol.InFutureContext = true;        
            }
        
            MapProgramEmployment objProgEmpl = new MapProgramEmployment();      
            objProgEmpl.calculateCredit(pcqId, 'ProgramCategoryQualification');     
        }
    }
    catch(Exception ec){}
}