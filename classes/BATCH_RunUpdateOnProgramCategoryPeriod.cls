global class BATCH_RunUpdateOnProgramCategoryPeriod implements Database.Batchable<sObject>{

		global static void runBatch(){
			BATCH_RunUpdateOnProgramCategoryPeriod b = new BATCH_RunUpdateOnProgramCategoryPeriod();
			b.setDefaultQuery();
			Database.executeBatch(b);
		}


		public String query{get; set;}
	    
	    global void setDefaultQuery(){
	        this.query = 'Select StartDate__c From ProgramCategoryPeriod__c';
	        if(test.isRunningTest()) this.query = 'Select StartDate__c From ProgramCategoryPeriod__c limit 20';
	    }
	    
	    global database.querylocator start(Database.BatchableContext BC){
	            return Database.getQueryLocator(query);
	    }
	    
	    global void execute(Database.BatchableContext BC, List<sObject> scope){
        	List<ProgramCategoryPeriod__c> obs = new List<ProgramCategoryPeriod__c>();
            Date sd;
        	
        	for(ProgramCategoryPeriod__c s :(list<ProgramCategoryPeriod__c>)scope){
          		sd = s.StartDate__c;
          		s.StartDate__c = sd;
          		obs.add(s);
        	}
 
        	update obs;
		}
	 
    	global void finish(Database.BatchableContext BC){
	         
    	}

    static testMethod void TEST_BATCH_RunUpdateOnProgramCategoryPeriod() {
    		test.startTest();
        BATCH_RunUpdateOnProgramCategoryPeriod.runBatch();
        test.stopTest();
    }
}