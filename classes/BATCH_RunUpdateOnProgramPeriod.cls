global class BATCH_RunUpdateOnProgramPeriod implements Database.Batchable<sObject>{

		global static void runBatch(){
			BATCH_RunUpdateOnProgramPeriod b = new BATCH_RunUpdateOnProgramPeriod();
			b.setDefaultQuery();
			Database.executeBatch(b);
		}


		public String query{get; set;}
	    
	    global void setDefaultQuery(){
	        this.query = 'Select StartDate__c From ProgramPeriod__c';
	        if(test.isRunningTest()) this.query = 'Select StartDate__c From ProgramPeriod__c limit 20';
	    }
	    
	    global database.querylocator start(Database.BatchableContext BC){
	            return Database.getQueryLocator(query);
	    }
	    
	    global void execute(Database.BatchableContext BC, List<sObject> scope){
        	List<ProgramPeriod__c> obs = new List<ProgramPeriod__c>();
            Date sd;
        	
        	for(ProgramPeriod__c s :(list<ProgramPeriod__c>)scope){
          		sd = s.StartDate__c;
          		s.StartDate__c = sd;
          		obs.add(s);
        	}
 
        	update obs;
		}
	 
    	global void finish(Database.BatchableContext BC){
	         
    	}
    	
    
    static testMethod void TEST_BATCH_RunUpdateOnProgramPeriod() {
    		test.startTest();
        BATCH_RunUpdateOnProgramPeriod.runBatch();
        test.stopTest();
    }

}