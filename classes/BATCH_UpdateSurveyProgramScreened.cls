global class BATCH_UpdateSurveyProgramScreened implements Database.Batchable<sObject>{
    
    public String query{get; set;}
    
    global void setDefaultQuery(){
        this.query = 'Select Program__c, Name, Survey__c,Id From SurveyProgramScreened__c where Program__c != null';
        if(test.isRunningTest()) this.query = 'Select Program__c, Name, Survey__c,Id From SurveyProgramScreened__c where Program__c != null limit 30';
    }
    
    global database.querylocator start(Database.BatchableContext BC){
            return Database.getQueryLocator(query);
    }
    
  global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<SurveyProgramScreened__c> obs = new List<SurveyProgramScreened__c>();
				String name;
        for(sObject s : scope){
          SurveyProgramScreened__c sps= (SurveyProgramScreened__c)s;
         	//name = sps.Survey__c;
         	//sps.Survey__c = name;   
          obs.add(sps);
        }

        update obs;
    }

    global void finish(Database.BatchableContext BC){
         
    }
    global static void runBatch(){
			BATCH_UpdateSurveyProgramScreened b = new BATCH_UpdateSurveyProgramScreened();
			b.setDefaultQuery();
			Database.executeBatch(b);
		}
		static testMethod void TEST_BATCH_UpdateSurveyProgramScreened() {
    		test.startTest();
        BATCH_UpdateSurveyProgramScreened.runBatch();
        test.stopTest();
    }
}