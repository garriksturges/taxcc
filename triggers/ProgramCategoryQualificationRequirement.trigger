trigger ProgramCategoryQualificationRequirement on ProgramCategoryQualification__c (after insert, after update, before delete) {
    //ADDED BY GARRIK
    boolean execute = false;
    list<ProgramCategoryQualification__c> pcqsToUpdate;
/************************************************/
    if(trigger.isUpdate && !QualificationDocReqHelper.byPassTriggers && QualificationDocReqHelper.isManualUpdate){
        pcqsToUpdate = new list<ProgramCategoryQualification__c>();
        for(ProgramCategoryQualification__c pcqNew : trigger.new){
            //Uncomment line 10 after updating PCQs in Prod
           if(pcqNew.ProgramCategoryPeriod__c != trigger.oldMap.get(pcqNew.id).ProgramCategoryPeriod__c)
               pcqsToUpdate.add(pcqNew);
        }
        
        if(pcqsToUpdate.size() >0){
            execute = true;
            list<QualificationDocumentStep__c> oldQDSlist = [Select QualificationDocumentRequirement__r.ProgramCategoryQualification__c, 
                                                              QualificationDocumentRequirement__r.Id, QualificationDocumentRequirement__c 
                                                              From QualificationDocumentStep__c where QualificationDocumentRequirement__r.ProgramCategoryQualification__c 
                                                              in :pcqsToUpdate];
            if(oldQDSlist != null && oldQDSlist.size() > 0)
                delete oldQDSlist;
            list<QualificationDocumentRequirement__c> oldQRDlist = [Select ProgramCategoryQualification__c From QualificationDocumentRequirement__c 
                                                                    where ProgramCategoryQualification__c in :pcqsToUpdate];
            if(oldQRDlist != null && oldQRDlist.size() > 0)
                delete oldQRDlist; 
        } 
    }
    
/************************************************/    
    if(trigger.isInsert || execute){//IF ADDED BY GARRIK
        Set<Id> pcIds =  new Set<Id>();
        Map<Id,List<ProgramCategoryQualification__c>> pcqMap = new Map<Id,List<ProgramCategoryQualification__c>>();
        List<ProgramCategoryQualification__c> pcqsList ;
        List<QualificationDocumentStep__c> qualRoleStep = new List<QualificationDocumentStep__c>();
    
        QualificationDocumentRequirement__c qr;
        QualificationDocumentStep__c qrs;
        
        List<QualificationDocumentRequirement__c> qualificationDocReqList = new List<QualificationDocumentRequirement__c>();
        List<QualificationDocumentStep__c> qualificationDocStepList = new List<QualificationDocumentStep__c>();
        List<ProgramCategoryQualification__c> pcqList;
        //change/added logic by garrik
        if(trigger.isInsert){
            pcqList = [select Id, Name,ProgramQualification__c,RankOrderofProgramcategory__c, ProgramCategoryPeriod__r.ProgramCategory__c, ProgramCategoryPeriod__c
                         from ProgramCategoryQualification__c where Id IN: Trigger.newMap.keyset()];
        }
        else{
            pcqList = [select Id, Name,ProgramQualification__c,RankOrderofProgramcategory__c, ProgramCategoryPeriod__r.ProgramCategory__c, 
                        ProgramCategoryPeriod__c from ProgramCategoryQualification__c where Id IN: pcqsToUpdate];
        }
        //end g change
        List<string> programCategoryIdList = new List<string>();
        //The following loop populating PCQ's by PQ
        for(ProgramCategoryQualification__c pcq : pcqList)
        {
            if(pcqMap.containsKey(pcq.ProgramQualification__c))
                pcqMap.get(pcq.ProgramQualification__c).add(pcq);
            else {
                pcqsList = new   List<ProgramCategoryQualification__c>();
                pcqsList.add(pcq);
                pcqMap.put(pcq.ProgramQualification__c,pcqsList);
            }
            programCategoryIdList.add(pcq.ProgramCategoryPeriod__r.ProgramCategory__c);
        }
            
        Map<string, List<DocumentRequirement__c>> documentRequirementMap = new Map<string, List<DocumentRequirement__c>>();
        List<DocumentRequirement__c> docReqsList;
        //The following loop populating Document Req's by PC
        for(DocumentRequirement__c docReq : [select Id, Name, ProgramCategory__c, (Select Id, Name, DocumentRequirement__c From DocumentSteps__r) From DocumentRequirement__c
                                            where ProgramCategory__c =:programCategoryIdList]){
            if(documentRequirementMap.containsKey(docReq.ProgramCategory__c)&& documentRequirementMap.get(docReq.ProgramCategory__c) != null){
                documentRequirementMap.get(docReq.ProgramCategory__c).add(docReq);
                } else{
                    docReqsList = new List<DocumentRequirement__c>();
                    docReqsList.add(docReq);
                    documentRequirementMap.put(docReq.ProgramCategory__c, docReqsList);
                }
            
            }
        
        for(ProgramCategoryQualification__c pcq : pcqList)
        {
          List<DocumentRequirement__c> documentReqList = documentRequirementMap.get(pcq.ProgramCategoryPeriod__r.ProgramCategory__c);                    
                        
            if(documentReqList != null && documentReqList.size() > 0) {
                pcqMap.remove(pcq.ProgramQualification__c);
                
            for(DocumentRequirement__c  dr : documentReqList){
                    QualificationDocumentRequirement__c qdr = new QualificationDocumentRequirement__c();
                    qdr.ProgramCategoryQualification__c = pcq.Id;
                    qdr.DocumentRequirement__c = dr.Id;
                    
                    qualificationDocReqList.add(qdr);     
                }
       
            }                                
        }
    if(qualificationDocReqList != null && qualificationDocReqList.size()>0){
        QualificationDocReqHelper.qdrInsertFromPCQ = true ;           
        insert qualificationDocReqList;
    }
/************************************************/        
        Map<string, List<QualificationDocumentRequirement__c>> qdrMap = new Map<string, List<QualificationDocumentRequirement__c>>();
        List<QualificationDocumentRequirement__c> qdrs ;
        List<id> qdrIdList = new List<id>();
        for(QualificationDocumentRequirement__c qdr : qualificationDocReqList){
        
            if( qdrMap.get(qdr.ProgramCategoryQualification__c) != null)
                qdrMap.get(qdr.ProgramCategoryQualification__c).add(qdr);
                
            else {
                    qdrs = new  List<QualificationDocumentRequirement__c>();
                    qdrs.add(qdr);
                    qdrMap.put(qdr.ProgramCategoryQualification__c,  qdrs);
                }
            qdrIdList.add(qdr.DocumentRequirement__c);
            
        }
        System.debug('qdrMap:'+qdrMap);
        
        Map<string, List<DocumentStep__c>> documentStepMap = new Map<string, List<DocumentStep__c>>();
        List<DocumentStep__c> docStepList;
        
        for(DocumentStep__c docStep : [Select Id, Name, DocumentRequirement__c From DocumentStep__c where DocumentRequirement__c in :qdrIdList]){
            if(documentStepMap.containsKey(docStep.DocumentRequirement__c)&& documentStepMap.get(docStep.DocumentRequirement__c) != null){
                documentStepMap.get(docStep.DocumentRequirement__c).add(docStep);
            } else{
                docStepList = new List<DocumentStep__c>();
                docStepList.add(docStep);
                documentStepMap.put(docStep.DocumentRequirement__c, docStepList);
            }
            
        }  
        
        for(ProgramCategoryQualification__c pcq : pcqList){
                        
        List<QualificationDocumentRequirement__c> qdrList = qdrMap.get(pcq.id);   
        System.debug('documentReqList:'+qdrList)   ;              
        
        if(qdrList != null && qdrList.size() > 0) {            
            
            for(QualificationDocumentRequirement__c  qdr : qdrList){
                    
                    List<DocumentStep__c> qdsList = documentStepMap.get(qdr.DocumentRequirement__c);
                        if(qdsList != null && qdsList.size() > 0){
                            System.debug('DocumentStep List :'+qdsList);
                            for(DocumentStep__c  drStep : qdsList){
                                QualificationDocumentStep__c qds = new QualificationDocumentStep__c();
                                qds.QualificationDocumentRequirement__c = qdr.Id;                   
                                qds.DocumentStep__c = drStep.Id;
                                //qdrMap.remove(dr.Id);   
                                qualificationDocStepList.add(qds);
                            }
                            System.debug('qualificationDocStepList:'+qualificationDocStepList);
                        } 
                    }  
                }                                
            }
        
    insert qualificationDocStepList;
/************************************************/        
        //The following code is for updating readiness on PCQ when there are no QDRs
        //Uncomment line 167 and comment line 168 after updating PCQs in Prod
       if((trigger.isInsert) && pcqMap != null && pcqMap.size() > 0){
       //if(!QualificationDocReqHelper.byPassTriggers && pcqMap != null && pcqMap.size() > 0){    
            System.debug('pcqMap:'+pcqMap);
            QualificationDocReqHelper.updateReadinessOnNoQDRs(pcqMap);
        } 
    }
/************************************************/    
    if(trigger.isDelete){
        
        List <id> qdrIdList = new List<id>();       
        system.debug('trigger.old' + trigger.old);
        List<QualificationDocumentRequirement__c> qdrList = [select id,Name from QualificationDocumentRequirement__c where ProgramCategoryQualification__c in :trigger.oldMap.keyset() ];
        system.debug('Deleted qdrList' + qdrList);
        for(QualificationDocumentRequirement__c qdr : qdrList){
            qdrIdList.add(qdr.id);  
        }
        if(qdrList.size() > 0 && qdrList != null){
            delete qdrList;
        }
    }
/************************************************/    
}