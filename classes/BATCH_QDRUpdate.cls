global class BATCH_QDRUpdate implements Database.Batchable<sObject>{
  public string q{get; set;}
  /***********************************************/
	global void setDefaultQuery(){
		q = 'Select q.DocumentStatus__c, q.ProgramCategoryQualification__c From QualificationDocumentRequirement__c q where ProgramCategoryQualification__c != null';
		if(test.isRunningTest()) q = 'Select q.DocumentStatus__c, q.ProgramCategoryQualification__c From QualificationDocumentRequirement__c q limit 10'; 
	}
  /***********************************************/
  global database.querylocator start(Database.BatchableContext BC){
       return Database.getQueryLocator(q);
  }
  /***********************************************/
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		//make nonsenst Document status
			DocumentStatus__c ds = new DocumentStatus__c();
			ds.name = 'batch';
			ds.DocumentStatusEID__c =3.14444;
			ds.RankOrder__c = 1.0;
			insert ds;
			
			//make map of qdr ids to qdr.DocumentStatusEID__c value(for backup)
			//set doc status eid to nonsense value
			map<string, string> qdrEIDmap = new map<string, string>();
			list<QualificationDocumentRequirement__c> qdrList = new list<QualificationDocumentRequirement__c>();
			for(QualificationDocumentRequirement__c qdr : (list<QualificationDocumentRequirement__c>)scope){
				qdrEIDmap.put(qdr.id, qdr.DocumentStatus__c);
				qdr.DocumentStatusExternal__c = ds.id;	
				qdrList.add(qdr);	
			}
			update qdrList;
			
			//set QDRS to original values
			for(QualificationDocumentRequirement__c qdr : qdrList){
				qdr.DocumentStatusExternal__c = qdrEIDmap.get(qdr.id);		
			}
			update qdrList;
			
			//delete nonsense ds
			delete ds;	
	}
	/***********************************************/
	global void finish(Database.BatchableContext BC){
		
	}
	/***********************************************/
	global static void runBatch(){
		BATCH_QDRUpdate b = new BATCH_QDRUpdate();
		b.setDefaultQuery();
		Database.executeBatch(b, 100);
	}
	/***********************************************/
	static testMethod void Test_BATCH_RunUpdateOnCredit() {
    		test.startTest();
        BATCH_QDRUpdate.runBatch();
        test.stopTest();
    }	

}