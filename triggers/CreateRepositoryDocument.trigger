trigger CreateRepositoryDocument on RepositoryDocument__c (after insert,after update, before delete) {

	Map<String,String> drstoQrsMap =  new Map<String, String>();
	set<id> repositoryIdSet = new set<id>();
	set<id> UpdateRepositoryIdSet = new set<id>();
	map<String,Integer> qdoCount = new map<String,Integer>();
	Set<Id> EmplntIds = new Set<Id>();
	List<QualificationDocumentOption__c> qualDocOptList = new List<QualificationDocumentOption__c>();
/************************************************/  

	if(trigger.isDelete){
		system.debug('trigger.old' + trigger.old);
		List<QualificationDocumentOption__c> qdo = [Select Id, RepositoryDocument__c from QualificationDocumentOption__c where RepositoryDocument__c in : trigger.old];
		System.debug('qdo:'+ qdo);
			if(qdo != null && qdo.size() > 0)
				delete qdo;
}
/************************************************/   

	if(trigger.isInsert)  {
		
		List <id> rdList ;// = new List <id>();
		List <QualificationDocumentRequirement__c> qrList = new List <QualificationDocumentRequirement__c>();
		map <String,String> drstoQrsMaps; // =  new map <String,String>();
		
			for(RepositoryDocument__c rd : [Select Employment__c,DocumentStatus__r.DocumentStatusEID__c, DocumentStatus__r.Name, DocumentStatus__c, 
											DocumentType__c From RepositoryDocument__c where Id IN :Trigger.NewMap.KeySet()]){
					System.debug('Rd Id :'+rd.id);	
					System.debug('Rd Employ:'+rd.Employment__c);						
			rdList = new List <id>();
			drstoQrsMaps =  new Map<String, String>();
			for(QualificationDocumentRequirement__c qr : [Select Id,ProgramQualification__r.Employment__c, ProgramQualification__c, ProgramQualification__r.Id 
														//(Select Id, Name, QualificationDocumentRequirement__c,DocumentStep__c From QualificationFunctions__r) 
															From QualificationDocumentRequirement__c where ProgramQualification__r.Employment__c =: rd.Employment__c 
																OR ProgramCategoryQualification__r.ProgramQualification__r.Employment__c =: rd.Employment__c])
		{
			rdList.add(qr.id);
		}
		System.debug('rdList:'+rdList);
		
			for (QualificationDocumentStep__c qds : [Select Id, Name, QualificationDocumentRequirement__c,DocumentStep__c From QualificationDocumentStep__c where 
									QualificationDocumentRequirement__c in :rdList ]){
										drstoQrsMaps.put(qds.DocumentStep__c, qds.Id);
							}
		System.debug('drstoQrsMaps:'+drstoQrsMaps);
		
				for(DocumentOption__c docOption : [Select Id, Name,DocumentStep__c, DocumentType__c From DocumentOption__c where DocumentStep__c IN : drstoQrsMaps.keyset()]){
					if (rd.DocumentType__c == docOption.DocumentType__c){
						QualificationDocumentOption__c qdo = new QualificationDocumentOption__c();
						//DocumentStatus__c doc = new  DocumentStatus__c ();
				
						qdo.DocumentOption__c = docOption.Id;
						qdo.RepositoryDocument__c = rd.Id;
						qdo.QualificationDocumentStep__c = drstoQrsMaps.get(docOption.DocumentStep__c);
						qdo.DocumentStatusGenerated__c = rd.DocumentStatus__c;
						qualDocOptList.add(qdo);
						
				}
			}
		}
		//Optimizing the code
		/*	Map<Id,RepositoryDocument__c> rdsMap = new Map<Id,RepositoryDocument__c>();
			Set<Id> rdEmpIds = new Set<Id>();
			for(RepositoryDocument__c rd : [Select Employment__c,DocumentStatus__r.DocumentStatusEID__c, DocumentStatus__r.Name, DocumentStatus__c, 
											DocumentType__c From RepositoryDocument__c where Id IN :Trigger.NewMap.KeySet()]){
												rdEmpIdMap.put(rd.id,rd);
												rdEmpIds.add(rd.Employment__c);
											}
		 System.debug('rdEmpIds:'+rdEmpIds);
		 for(QualificationDocumentRequirement__c qr : [Select Id,ProgramQualification__r.Employment__c, ProgramQualification__c, ProgramQualification__r.Id 
														from QualificationDocumentRequirement__c where ProgramQualification__r.Employment__c in: rdEmpIds
																OR ProgramCategoryQualification__r.ProgramQualification__r.Employment__c in :rdEmpIds])
		{
			rdList.add(qr.id);
		}
	  for (QualificationDocumentStep__c qds : [Select Id, Name, QualificationDocumentRequirement__c,DocumentStep__c From QualificationDocumentStep__c where 
									QualificationDocumentRequirement__c in :rdList ]){
										drstoQrsMaps.put(qds.DocumentStep__c, qds.Id);
		}
		for(DocumentOption__c docOption : [Select Id, Name,DocumentStep__c, DocumentType__c From DocumentOption__c where DocumentStep__c IN : drstoQrsMaps.keyset()]){
					if (rd.DocumentType__c == docOption.DocumentType__c){
						QualificationDocumentOption__c qdo = new QualificationDocumentOption__c();
						//DocumentStatus__c doc = new  DocumentStatus__c ();
				
						qdo.DocumentOption__c = docOption.Id;
						qdo.RepositoryDocument__c = rd.Id;
						qdo.QualificationDocumentStep__c = drstoQrsMaps.get(docOption.DocumentStep__c);
						qdo.DocumentStatusGenerated__c = rd.DocumentStatus__c;
						qualDocOptList.add(qdo);
						
				}
			}*/
		
	insert qualDocOptList;
	}	
	
/************************************************/
	if(trigger.isUpdate) {
	
		for(RepositoryDocument__c rd :trigger.new){
			if(rd.DocumentType__c != trigger.oldMap.get(rd.Id).DocumentType__c){
			repositoryIdSet.add(rd.Id); 
			}
			else if( rd.DocumentStatus__r.Name != trigger.oldMap.get(rd.Id).DocumentStatus__r.Name
					||rd.DocumentStatus__c != trigger.oldMap.get(rd.Id).DocumentStatus__c){
			UpdateRepositoryIdSet.add(rd.Id);       
			}
		
		}
		if(repositoryIdSet != null &&repositoryIdSet.size() > 0){
		list <AggregateResult> aggr = [select RepositoryDocument__c, count(id) from QualificationDocumentOption__c where RepositoryDocument__c in: repositoryIdSet group by RepositoryDocument__c];
		for(AggregateResult agg: aggr){
				if(integer.valueof(agg.get('expr0'))>0){
				qdoCount.put(string.valueof(agg.get('RepositoryDocument__c')),integer.valueof(agg.get('expr0')));   
			}
		}  
		list<QualificationDocumentOption__c> qdclist = [select id,name from QualificationDocumentOption__c where RepositoryDocument__c in :qdoCount.keyset() ];
		if(qdclist != null && qdclist.size() > 0){
			delete qdclist;
		}
		
		for(RepositoryDocument__c rd : [Select Employment__c,DocumentStatus__r.DocumentStatusEID__c, DocumentStatus__r.Name, DocumentStatus__c, DocumentType__c 
											From RepositoryDocument__c where Id IN :Trigger.NewMap.KeySet()]){
												
		for(QualificationDocumentRequirement__c qr : [Select Id,ProgramQualification__r.Employment__c, ProgramQualification__c, ProgramQualification__r.Id, 
														(Select Id, Name, QualificationDocumentRequirement__c,DocumentStep__c From QualificationFunctions__r) 
														From QualificationDocumentRequirement__c where ProgramQualification__r.Employment__c =: rd.Employment__c 
														OR ProgramCategoryQualification__r.ProgramQualification__r.Employment__c =: rd.Employment__c]){
			drstoQrsMap =  new Map<String, String>();
			for(QualificationDocumentStep__c qrsid : qr.QualificationFunctions__r)
			{
				drstoQrsMap.put(qrsid.DocumentStep__c, qrsid.Id);
			}
			
					
			
	for(DocumentOption__c docOption : [Select Id, Name,DocumentStep__c, DocumentType__c From DocumentOption__c where DocumentStep__c IN : drstoQrsMap.keyset()]){
		
				if (rd.DocumentType__c == docOption.DocumentType__c){
					
					QualificationDocumentOption__c qdo = new QualificationDocumentOption__c();
					DocumentStatus__c doc = new  DocumentStatus__c ();
			
					qdo.DocumentOption__c = docOption.Id;
					qdo.RepositoryDocument__c = rd.Id;
					qdo.QualificationDocumentStep__c = drstoQrsMap.get(docOption.DocumentStep__c);
					qdo.DocumentStatusGenerated__c = rd.DocumentStatus__c;
					qualDocOptList.add(qdo);
					
			}
			}
		}
		}
	
	insert qualDocOptList;
	}
			
/************************************************/
	if(UpdateRepositoryIdSet != null && UpdateRepositoryIdSet.size() > 0){
	map<string,RepositoryDocument__c> rdmap = new map<string,RepositoryDocument__c>();
	list<QualificationDocumentOption__c> qdcUpdateList = new list<QualificationDocumentOption__c>();
	for(RepositoryDocument__c rdlist : [Select id,Employment__c,DocumentStatus__r.DocumentStatusEID__c, DocumentStatus__r.Name, DocumentStatus__c,
									DocumentType__c From RepositoryDocument__c where Id IN :UpdateRepositoryIdSet] ){
							rdmap.put(String.valueof(rdlist.get('Id')),rdlist);         
	}
		
	for(QualificationDocumentOption__c qdc : [select id,name,DocumentOption__c,QualificationDocumentStep__c,DocumentStatusGenerated__c,
												RepositoryDocument__c from QualificationDocumentOption__c where RepositoryDocument__c in : UpdateRepositoryIdSet]){
													
											  qdc.DocumentStatusGenerated__c = rdmap.get(qdc.RepositoryDocument__c).DocumentStatus__c;
											  qdcUpdateList.add(qdc);             
														}
													
if(qdcUpdateList != null && qdcUpdateList.size() >0){
	update qdcUpdateList;
}
                                                          
	} 
/************************************************/  		
	
		}    
		
		
}