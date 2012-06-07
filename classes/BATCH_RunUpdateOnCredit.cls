global class BATCH_RunUpdateOnCredit implements Database.Batchable<sObject>{
public String query{get; set;}
    
    global void setDefaultQuery(){
        this.query = 'Select StartDate__c From Credit__c';
        if(test.isRunningTest()) this.query = 'Select StartDate__c From Credit__c limit 50';
    }
    
    global database.querylocator start(Database.BatchableContext BC){
            return Database.getQueryLocator(query);
    }
    
  global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Credit__c> obs = new List<Credit__c>();
				Date sd;
        for(Credit__c s :(list<Credit__c>)scope){
          sd = s.StartDate__c;
          s.StartDate__c = sd;
         	//name = sps.Survey__c;
         	//sps.Survey__c = name;   
          obs.add(s);
        }

        update obs;
    }

    global void finish(Database.BatchableContext BC){
         
    }
	global static void runBatch(){
		BATCH_RunUpdateOnCredit b = new BATCH_RunUpdateOnCredit();
		b.setDefaultQuery();
		Database.executeBatch(b);
	}
	
    static testMethod void Test_BATCH_RunUpdateOnCredit() {
    		ProgramQualification__c pq = [select id from ProgramQualification__c limit 1];
    		Credit__c c = new Credit__c();
    		c.CreditEID__c = 123.1231;
    		c.ProgramQualification__c = pq.id;
    		insert c;
    		test.startTest();
    		
        BATCH_RunUpdateOnCredit.runBatch();
        test.stopTest();
    }	
}