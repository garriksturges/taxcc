global class BATCH_RunUpdateOnEntityStructure implements Database.Batchable<sObject>{

		global static void runBatch(){
			BATCH_RunUpdateOnEntityStructure b = new BATCH_RunUpdateOnEntityStructure();
			b.setDefaultQuery();
			Database.executeBatch(b);
		}


		public String query{get; set;}
	    
	    global void setDefaultQuery(){
	        this.query = 'Select StreetAddressText__c From EntityStructure__c';
	        if(test.isRunningTest()) this.query = 'Select StreetAddressText__c From EntityStructure__c limit 50';
	    }
	    
	    global database.querylocator start(Database.BatchableContext BC){
	            return Database.getQueryLocator(query);
	    }
	    
	    global void execute(Database.BatchableContext BC, List<sObject> scope){
        	List<EntityStructure__c> obs = new List<EntityStructure__c>();
            string sd;
        	
        	for(EntityStructure__c s :(list<EntityStructure__c>)scope){
          		sd = s.StreetAddressText__c;
          		s.StreetAddressText__c = sd;
          		obs.add(s);
        	}
 
        	update obs;
		}
	 
    	global void finish(Database.BatchableContext BC){
	         
    	}

    static testMethod void TEST_BATCH_RunUpdateOnEntityStructure() {
    		test.startTest();
        BATCH_RunUpdateOnEntityStructure.runBatch();
        test.stopTest();
    }    	

}