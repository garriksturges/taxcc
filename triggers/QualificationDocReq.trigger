trigger QualificationDocReq on QualificationDocumentRequirement__c (after insert , after update) {
    
    System.debug('Entering into QualificationDocReq : '+userinfo.getUserName());
    List<ProgramCategoryQualification__c> pcqList = new List<ProgramCategoryQualification__c>();
    Set<id> pcqIds = new Set<id>();
    Set<id> pqIds = new Set<id>();
     Set<id> pqIdsToProcess = new Set<id>();
    if(trigger.isUpdate && !QualificationDocReqHelper.byPassInProgress){
        
        for(QualificationDocumentRequirement__c qdoc : trigger.new){
            System.debug('Document Status EID Formula:'+qdoc.DocumentStatusEIDFormula__c);
            if(qdoc.DocumentStatusEIDFormula__c <> trigger.oldMap.get(qdoc.id).DocumentStatusEIDFormula__c && qdoc.PCQReadinessEIDFormula__c != 6){ //QDR DOCUMENT STATUS
                
                    
                if(qdoc.ProgramCategoryQualification__c != null){
                    pcqIds.add(qdoc.ProgramCategoryQualification__c);
                    pqIds.add(qdoc.PQPCQIDFormula__c);  
                     }
                System.debug('pcqIds:'+ pcqIds);    
                System.debug('pqIds:'+ pqIds);       
             
                if(qdoc.ProgramQualification__c != null && qdoc.ProgramCategoryQualification__c == null &&!pqIds.contains(qdoc.ProgramQualification__c) )
                    pqIdsToProcess.add(qdoc.ProgramQualification__c);
                    System.debug('pqIdsToProcess:'+ pqIdsToProcess);
            }   
        }
        if(pcqIds != null && pcqIds.size()>0)
            QualificationDocReqHelper.ProcessQualificationsDocs(trigger.new);
        if(pqIdsToProcess != null && pqIdsToProcess.size()>0)   
            ProcessStageHelper.updateProcessStageOnPQ(pqIdsToProcess);
        
    } 
    else {
        if(QualificationDocReqHelper.qdrInsertFromPCQ)
            QualificationDocReqHelper.updateReadinessOnPCQ(trigger.new);
           } 
           
}