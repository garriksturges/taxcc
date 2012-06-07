global class BATCH_QualificationDocumentTrigger implements Database.Batchable<sObject>{
	public string q{get; set;}
	
	/***********************************************/
	global void setDefaultQuery(){
		q = 'Select Employment__c, QualificationProcessStage__c From wktLocationEmployeeProgram__c where QualificationProcessStage__c != null';
		if(test.isRunningTest()) q = 'Select Employment__c From wktLocationEmployeeProgram__c limit 10'; 
	}
	/***********************************************/
	global static void runBatch(){
      BATCH_QualificationDocumentTrigger b = new BATCH_QualificationDocumentTrigger();
      b.setDefaultQuery();
      Database.executeBatch(b, 50);
    }
	/***********************************************/
  global database.querylocator start(Database.BatchableContext BC){
  	return Database.getQueryLocator(q);
  }
 /***********************************************/
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		//get list of employee ids
		list<String> empIds = new list<string>();
		for(wktLocationEmployeeProgram__c wkt : (list<wktLocationEmployeeProgram__c>)scope){
			empIds.add(wkt.Employment__c);
		}
		
		//get QDRs that have pq referencing employments
		for(list<QualificationDocumentRequirement__c> qdrList : [Select q.ProgramQualification__r.Employment__c, q.ProgramQualification__c, 
																												q.ProgramCategoryQualification__r.ProgramQualification__r.Employment__c,
																												q.ProgramCategoryQualification__r.ProgramQualification__c, 
																												q.ProgramCategoryQualification__r.ProgramQualification__r.ProgramPeriod__c,
																												q.ProgramCategoryQualification__c, q.DocumentStatusEIDFormula__c, // QDR DOCUMENT STATUS
																												q.ProgramQualification__r.ProgramPeriod__c,
																												q.DocumentStatus__c   
																												From QualificationDocumentRequirement__c q
																												where ProgramQualification__r.Employment__c in :empIds 
																												or ProgramCategoryQualification__r.ProgramQualification__r.Employment__c in :empids]){
			//make map of employment + program period to one qdr for each employment
			/*map<String, QualificationDocumentRequirement__c> qdrMap = new map<String, QualificationDocumentRequirement__c>();
			QualificationDocumentRequirement__c qdrTest;
			string empS;
			string ppS;
			for(QualificationDocumentRequirement__c qdr : qdrList){
				//employeeId
				if(qdr.ProgramQualification__c != null && qdr.ProgramQualification__r.Employment__c!=null) empS = qdr.ProgramQualification__r.Employment__c;
				else if(qdr.ProgramCategoryQualification__c !=null && qdr.ProgramCategoryQualification__r.ProgramQualification__c!=null &&qdr.ProgramCategoryQualification__r.ProgramQualification__r.Employment__c != null) emps = qdr.ProgramCategoryQualification__r.ProgramQualification__r.Employment__c;
				else emps = null;
				//program period id
				if(qdr.ProgramQualification__c != null && qdr.ProgramQualification__r.ProgramPeriod__c!=null) ppS = qdr.ProgramQualification__r.ProgramPeriod__c;
				else if(qdr.ProgramCategoryQualification__c !=null && qdr.ProgramCategoryQualification__r.ProgramQualification__c!=null &&qdr.ProgramCategoryQualification__r.ProgramQualification__r.ProgramPeriod__c != null) pps = qdr.ProgramCategoryQualification__r.ProgramQualification__r.ProgramPeriod__c;
				else ppS = null;
				
				if(emps!=null && ppS != null){
					qdrTest = qdrMap.get(empS+ppS);
					if(qdrTest == null) qdrMap.put(empS+ppS, qdr);
				}
			}																												
			//get list of QDR to update
			set<String> qdrKeys = qdrMap.keySet();
			qdrList = new list<QualificationDocumentRequirement__c>();
			for(string key:qdrKeys){
				qdrList.add(qdrMap.get(key));
			}
			*/
			//make nonsenst Document status
			DocumentStatus__c ds = new DocumentStatus__c();
			ds.name = 'batch';
			ds.DocumentStatusEID__c =3.14444;
			ds.RankOrder__c = 1.0;
			insert ds;
			
			//make map of qdr ids to qdr.DocumentStatusEID__c value(for backup)
			//set doc status eid to nonsense value
			map<string, string> qdrEIDmap = new map<string, string>();
			for(QualificationDocumentRequirement__c qdr : qdrList){
				qdrEIDmap.put(qdr.id, qdr.DocumentStatus__c);
				qdr.DocumentStatus__c = ds.id;		
			}
			update qdrList;
			
			//set QDRS to original values
			for(QualificationDocumentRequirement__c qdr : qdrList){
				qdr.DocumentStatus__c = qdrEIDmap.get(qdr.id);		
			}
			update qdrList;
			
			//delete nonsense ds
			delete ds;
			if(test.isRunningTest()) break;
		}
	} 
	/***********************************************/
	global void finish(Database.BatchableContext BC){
		
	}
	/***********************************************/

}