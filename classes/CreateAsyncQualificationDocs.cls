/*This Batch is for ADDING New QDR's for the PCQ's when NEW DOCUMENT REQUIREMENTS are Inserted*/


global class CreateAsyncQualificationDocs implements DataBase.Batchable<Sobject>,Database.stateful {

          
         global List<ProgramCategoryQualification__c> pcqList  ;

global Database.QueryLocator start(Database.BatchableContext BC){

  return (Database.getQueryLocator([ select Id, Name,ProgramQualification__c,PQAgencyEidFormula__c,    
                    PQDocumentSourceEidGeneratedFormula__c,RankOrderofProgramcategory__c,
                    ProgramCategoryPeriod__r.ProgramCategory__c, ProgramCategoryPeriod__c from ProgramCategoryQualification__c where   
                    PCQUpdateThroughBATCH__c = true order by ProgramQualification__c])
                    );

}

global void execute(Database.BatchableContext info, List<sObject> pcqList1){
    
        List<string> programCategoryIdList = new List<string>();
        Map<Id,List<ProgramCategoryQualification__c>> pcqMap = new Map<Id,List<ProgramCategoryQualification__c>>();
        List<QualificationDocumentStep__c> qualRoleStep = new List<QualificationDocumentStep__c>();
        QualificationDocumentRequirement__c qr;
        QualificationDocumentStep__c qrs;
        List<QualificationDocumentRequirement__c> qualificationDocReqList = new List<QualificationDocumentRequirement__c>();
        List<QualificationDocumentStep__c> qualificationDocStepList = new List<QualificationDocumentStep__c>();
        Map<String,Integer> docReqAgencyMap = new Map<String,Integer>();
        Set<Id> docAgency = new Set<Id>();
        //List<string> programCategoryIdList = new List<string>();
        Set<Decimal> pcqAgencyIds = new Set<Decimal>();
        Map<string, List<DocumentRequirement__c>> documentRequirementMap = new Map<string, List<DocumentRequirement__c>>();
        List<DocumentRequirement__c> docReqsList;
        
        List<ProgramCategoryQualification__c> pcqsList ;
        pcqList = (List<ProgramCategoryQualification__c>) pcqList1;
       /**
       		Thr folllowing for deleting the existiing QDRs
       */
       List<QualificationDocumentRequirement__c> qdrToDelete =  [select id from QualificationDocumentRequirement__c where ProgramCategoryQualification__c in :pcqList ];
       if(qdrToDelete != null && qdrToDelete.size() > 0)
       		delete qdrToDelete;
       		//End Qdr Delete
       		  		
       		
       		
       		
       		 //The following loop populating PCQ's by PQ
        for(ProgramCategoryQualification__c pcq : pcqList){
            if(pcqMap.containsKey(pcq.ProgramQualification__c))
                pcqMap.get(pcq.ProgramQualification__c).add(pcq);
            else {
                pcqsList = new   List<ProgramCategoryQualification__c>();
                pcqsList.add(pcq);
                pcqMap.put(pcq.ProgramQualification__c,pcqsList);
            }
            programCategoryIdList.add(pcq.ProgramCategoryPeriod__r.ProgramCategory__c);
            pcqAgencyIds.add(pcq.PQAgencyEidFormula__c);
        }
        System.debug('pcqAgencyIds:'+pcqAgencyIds);
        
        //The following loop populating Document Req's by PC
        for(DocumentRequirement__c docReq : [select Id, Name,DocumentRequirementAgencyCountSummary__c, ProgramCategory__c, (Select Id, Name, DocumentRequirement__c From DocumentSteps__r) From DocumentRequirement__c
                                            where ProgramCategory__c =:programCategoryIdList]){
            if(documentRequirementMap.containsKey(docReq.ProgramCategory__c)&& documentRequirementMap.get(docReq.ProgramCategory__c) != null){
                documentRequirementMap.get(docReq.ProgramCategory__c).add(docReq);
                } else{
                    docReqsList = new List<DocumentRequirement__c>();
                    docReqsList.add(docReq);
                    documentRequirementMap.put(docReq.ProgramCategory__c, docReqsList);
                }
         // Logic of Inserting QDR's through AGENCY!
                if(docReq.DocumentRequirementAgencyCountSummary__c > 0)
                    docAgency.add(docReq.id);
            }
            System.debug('docAgency:'+docAgency);
           for(AggregateResult aggr : [select count(id) agencyCount,DocumentRequirement__c docReqId from  
                                        DocumentRequirementAgency__c where DocumentRequirement__c in :docAgency and 
                                        AgencyEidFormula__c in : pcqAgencyIds group by DocumentRequirement__c]) {
                docReqAgencyMap.put(String.valueOf(aggr.get('docReqId')),Integer.valueOf(aggr.get('agencyCount')));                                                 
                                                
          }
          System.debug('docReqAgencyMap:'+docReqAgencyMap);
          Map<Id,Set<Decimal>> agencyFormulas = new Map<Id,Set<Decimal>>();
          Set<Decimal> docAgencySet;
          for(DocumentRequirementAgency__c agency : [select AgencyEidFormula__c,DocumentRequirement__c from   
                                                    DocumentRequirementAgency__c where DocumentRequirement__c in 
                                                    :docReqAgencyMap.keySet()]){
                          if(agencyFormulas.containsKey(agency.DocumentRequirement__c)&&  agencyFormulas.get(agency.DocumentRequirement__c) != null){
                              agencyFormulas.get(agency.DocumentRequirement__c).add(agency.AgencyEidFormula__c);
                          }else {
                               docAgencySet = new Set<Decimal>();
                               docAgencySet.add(agency.AgencyEidFormula__c);
                               agencyFormulas.put(agency.DocumentRequirement__c,docAgencySet);
                          }                            
                      }
        
        for(ProgramCategoryQualification__c pcq : pcqList)
        {
            System.debug('pcq:'+pcq.id);
          List<DocumentRequirement__c> documentReqList = documentRequirementMap.get(pcq.ProgramCategoryPeriod__r.ProgramCategory__c);                    
               
               System.debug('documentReqList:'+documentReqList);         
            if(documentReqList != null && documentReqList.size() > 0) {
                pcqMap.remove(pcq.ProgramQualification__c);
                
            for(DocumentRequirement__c  dr : documentReqList){
                System.debug('dr id :'+dr.id);
                System.debug('agencyFormulas.get(dr.id):'+agencyFormulas.get(dr.id));
                if(dr.DocumentRequirementAgencyCountSummary__c == 0 || (agencyFormulas.containsKey(dr.id) && dr.DocumentRequirementAgencyCountSummary__c > 0 && agencyFormulas.get(dr.id).contains(pcq.PQAgencyEidFormula__c)) ){
                    QualificationDocumentRequirement__c qdr = new QualificationDocumentRequirement__c();
                    qdr.ProgramCategoryQualification__c = pcq.Id;
                    qdr.DocumentRequirement__c = dr.Id;
                    
                    qualificationDocReqList.add(qdr);     
                }
             }
       
            }                                
        }
    if(qualificationDocReqList != null && qualificationDocReqList.size()>0){
        QualificationDocReqHelper.qdrInsertFromPCQ = true ;     
        QualificationDocReqHelper.PQDocumentSourceEid = false ;      
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
        System.debug('documentReqList:'+qdrList);              
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
      
    QualificationDocReqHelper.updateReadinessOnNoQDRs(pcqMap);
         
}

/************************************************/
    global void finish(Database.BatchableContext BC){
            
                for(ProgramCategoryQualification__c pcq : pcqList)  {
                          pcq.PCQUpdateThroughBATCH__c = false ;
            
        }
        Database.update(pcqList,false);
        
}   
  
}