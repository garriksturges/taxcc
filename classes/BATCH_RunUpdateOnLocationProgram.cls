global class BATCH_RunUpdateOnLocationProgram implements Database.Batchable<sObject>{

		global static void runBatch(){
			BATCH_RunUpdateOnLocationProgram b = new BATCH_RunUpdateOnLocationProgram();
			b.setDefaultQuery();
			Database.executeBatch(b);
		}


		public String query{get; set;}
	    
	    global void setDefaultQuery(){
	        this.query = 'Select StartDate__c From LocationProgram__c';
	        if(test.isRunningTest()) this.query = 'Select StartDate__c From LocationProgram__c limit 50';
	    }
	    
	    global database.querylocator start(Database.BatchableContext BC){
	            return Database.getQueryLocator(query);
	    }
	    
	    global void execute(Database.BatchableContext BC, List<sObject> scope){
        	List<LocationProgram__c> obs = new List<LocationProgram__c>();
            Date sd;
        	
        	for(LocationProgram__c s :(list<LocationProgram__c>)scope){
          		sd = s.StartDate__c;
          		s.StartDate__c = sd;
          		obs.add(s);
        	}
 
        	update obs;
		}
	 
    	global void finish(Database.BatchableContext BC){
	         
    	}
    	
    static testMethod void TEST_BATCH_RunUpdateOnLocationProgram() {
    		test.startTest();
        BATCH_RunUpdateOnLocationProgram.runBatch();
        test.stopTest();
    }    	

}