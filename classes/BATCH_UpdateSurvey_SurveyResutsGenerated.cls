global class BATCH_UpdateSurvey_SurveyResutsGenerated implements Database.Batchable<sObject>{
public String query{get; set;}
    
    global void setDefaultQuery(){
        this.query = 'Select survey__c from ProgramQualification__c';
        if(test.isRunningTest()) this.query = 'Select survey__c from ProgramQualification__c limit 100';
    }
    
    global database.querylocator start(Database.BatchableContext BC){
            return Database.getQueryLocator(query);
    }
    
  global void execute(Database.BatchableContext BC, List<sObject> scope){
        list<string>sids = new list<String>();
        for(ProgramQualification__c pq : (list<ProgramQualification__c>)scope){
        	sids.add(pq.Survey__c);
        }
    		for(list<EmployeeSurvey__c>esList : [Select e.SurveyResultGenerated__c From EmployeeSurvey__c e where id in :sIds]){
    			for(EmployeeSurvey__c es: esList){
						es.SurveyResultGenerated__c = 'Qualified';
					}																		
					update esList;	
    		}
    }

    global void finish(Database.BatchableContext BC){
         
    }
	global static void runBatch(){
		BATCH_UpdateSurvey_SurveyResutsGenerated b = new BATCH_UpdateSurvey_SurveyResutsGenerated();
		b.setDefaultQuery();
		Database.executeBatch(b);
	}
	
    static testMethod void BATCH_UpdateSurvey_SurveyResutsGenerated() {
    		test.startTest();
        BATCH_UpdateSurvey_SurveyResutsGenerated.runBatch();
        test.stopTest();
    }	
}
/*
list<EmployeeSurvey__c> l = [Select e.SurveySource__c, e.SurveyResultGenerated__c, e.EmploymentPeriod__c, e.DeclinedSurveyBit__c, (Select Id From ProgramQualifications__r) From EmployeeSurvey__c e  where SurveyResultGenerated__c =''];
for(EmployeeSurvey__c es:l){
	system.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'+es.ProgramQualifications__r.size());
}
*/