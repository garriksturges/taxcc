trigger ProgramQualificationRequirement on ProgramQualification__c (after insert, after update, before delete) {
	
	boolean execute = false;
	list<ProgramQualification__c> pqsToUpdate;
/************************************************/
	if(trigger.isUpdate){
		pqsToUpdate = new list<ProgramQualification__c>();
		for(ProgramQualification__c pqNew : trigger.new){
			//Uncomment line 9 after updating PCQs in Prod
		if(pqNew.Employment__c != trigger.oldMap.get(pqNew.id).Employment__c)
			pqsToUpdate.add(pqNew);
		}
		if(pqsToUpdate.size() >0){
			execute = true;
			list<QualificationDocumentStep__c> oldQDSlist = [Select QualificationDocumentRequirement__r.ProgramQualification__c, 
															QualificationDocumentRequirement__r.Id, QualificationDocumentRequirement__c 
															From QualificationDocumentStep__c where QualificationDocumentRequirement__r.ProgramQualification__c in :pqsToUpdate];
			if(oldQDSlist != null && oldQDSlist.size() > 0)
				delete oldQDSlist;
			list<QualificationDocumentRequirement__c> oldQRDlist = [Select ProgramQualification__c From QualificationDocumentRequirement__c 
																		where ProgramQualification__c in :pqsToUpdate];
			if(oldQRDlist != null && oldQRDlist.size() > 0)
				delete oldQRDlist; 
		} 
	
}
/************************************************/
	if(trigger.isInsert || execute){
	Set<Id> pcqIds =  new Set<Id>();
	Map<id, List<ProgramQualification__c>> pqMap = new Map<Id, List<ProgramQualification__c>>(); 
	List<ProgramQualification__c> pqsList;
	List<QualificationDocumentStep__c> qualRoleStep = new List<QualificationDocumentStep__c>();
	
	QualificationDocumentRequirement__c qr;
	QualificationDocumentStep__c qrs;
	
	List<QualificationDocumentRequirement__c> qualificationDocReqList = new List<QualificationDocumentRequirement__c>();
	List<QualificationDocumentStep__c> qualificationDocStepList = new List<QualificationDocumentStep__c>();
	List<ProgramQualification__c> pqlist; //= [Select Id, Name, ProgramPeriod__r.Program__c, Employment__c, ProgramPeriod__c From ProgramQualification__c where Id IN: Trigger.newMap.keyset()];
	
	if(trigger.isInsert){
			pqList = [select Id, Name,Employment__c,ProgramPeriod__r.Program__c, ProgramPeriod__c 
						from ProgramQualification__c where Id IN: Trigger.newMap.keyset()];
		}
	else{
			pqList = [select Id, Name,Employment__c,ProgramPeriod__r.Program__c  
						from ProgramQualification__c where Id IN: pqsToUpdate];
		}
	
	List<string> ProgramIdList = new List<string>();
	for (ProgramQualification__c pq : pqList){
		if(pqMap.containskey(pq.Employment__c))
		pqMap.get(pq.Employment__c).add(pq);
		else{
			pqsList = new List<ProgramQualification__c>();
			pqsList.add(pq);
			pqMap.put(pq.Employment__c, pqsList );
		}
		ProgramIdList.add(pq.ProgramPeriod__r.Program__c);
	}
	
	Map<string, List<DocumentRequirement__c>> documentRequirementMap = new Map<string, List<DocumentRequirement__c>>();
	List<DocumentRequirement__c> docReqsList ;
	// Populating the Document Requirements by Program.
	for( DocumentRequirement__c docReq :  [Select Id, Name, Program__c,(Select Id, Name, DocumentRequirement__c From DocumentSteps__r) From DocumentRequirement__c 
											where Program__c =:ProgramIdList] ){
		if(documentRequirementMap.containsKey(docReq.Program__c) && documentRequirementMap.get(docReq.Program__c) != null )  {
			documentRequirementMap.get(docReq.Program__c).add(docReq);
		} else {
			docReqsList = new List<DocumentRequirement__c>();
			docReqsList.add(docReq);
			documentRequirementMap.put(docReq.Program__c,docReqsList);
		}                               
									
	}
	
	for (ProgramQualification__c pq :pqList){
		List<DocumentRequirement__c> documentReqList = documentRequirementMap.get(pq.ProgramPeriod__r.Program__c);
		
		if(documentReqList != null && documentReqList.size() > 0) {
			pqMap.remove(pq.Employment__c);
	
			for (DocumentRequirement__c dr : documentReqList){
				QualificationDocumentRequirement__c qdr = new QualificationDocumentRequirement__c();
				qdr.ProgramQualification__c = pq.Id;
				qdr.DocumentRequirement__c = dr.Id;
				
				qualificationDocReqList.add(qdr);
			}
		}
	}
	
		if(qualificationDocReqList != null && qualificationDocReqList.size()>0){
		
		insert qualificationDocReqList;
	}
	
/************************************************/	
	Map<string, List<QualificationDocumentRequirement__c>> qdrMap = new Map<string, List<QualificationDocumentRequirement__c>>();
	List<QualificationDocumentRequirement__c> qdrs;
	List<id> qdrIdList = new List<id>();
	for (QualificationDocumentRequirement__c qdr :qualificationDocReqList){
		if(qdrMap.get(qdr.ProgramQualification__c)!= null)
			qdrMap.get(qdr.ProgramQualification__c).add(qdr);
		else{
			qdrs = new  List<QualificationDocumentRequirement__c>();
			qdrs.add(qdr);
			qdrMap.put(qdr.ProgramQualification__c,  qdrs);	
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
	
	for (ProgramQualification__c pq : pqlist){
		List<QualificationDocumentRequirement__c> qdrList = qdrMap.get(pq.id);   
		System.debug('documentReqList:'+qdrList);
		
		if(qdrList!= null && qdrList.size()>0){
	
			for (QualificationDocumentRequirement__c qdr:qdrList ){
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
	}
/************************************************/
	if(trigger.isDelete){
		
		List <id> qdrIdList = new List<id>();       
		system.debug('trigger.old' + trigger.old);
		List<QualificationDocumentRequirement__c> qdrList = [select id,Name from QualificationDocumentRequirement__c where ProgramQualification__c in :trigger.oldMap.keyset() ];
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