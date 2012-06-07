global class BATCH_UpdateEmployeeSurvey_NoPQFill implements Database.Batchable<sObject>{
public String query{get; set;}
    
    global void setDefaultQuery(){
        this.query = 'Select SurveyResultGenerated__c, DeclinedSurveyBit__c, (Select Id From ProgramQualifications__r) From EmployeeSurvey__c ';
        if(test.isRunningTest()) this.query = 'Select SurveyResultGenerated__c, DeclinedSurveyBit__c, (Select Id From ProgramQualifications__r) From EmployeeSurvey__c limit 100';
    }
    
    global database.querylocator start(Database.BatchableContext BC){
            return Database.getQueryLocator(query);
    }
    
  global void execute(Database.BatchableContext BC, List<sObject> scope){
        list<EmployeeSurvey__c> esList = new list <EmployeeSurvey__c>();
        for(EmployeeSurvey__c es : (list<EmployeeSurvey__c>)scope){
        	if(es.ProgramQualifications__r == null || es.ProgramQualifications__r.size() == 0){
						es.SurveyResultGenerated__c = 'Did Not Qualify';
						esList.add(es);
        	}
        }
    	update esList;
    }
    

    global void finish(Database.BatchableContext BC){
         
    }
	global static void runBatch(){
		BATCH_UpdateEmployeeSurvey_NoPQFill b = new BATCH_UpdateEmployeeSurvey_NoPQFill();
		b.setDefaultQuery();
		Database.executeBatch(b);
	}
	
    static testMethod void BATCH_UpdateEmployeeSurvey_NoPQFillTEST() {
    		test.startTest();
        BATCH_UpdateEmployeeSurvey_NoPQFill.runBatch();
        test.stopTest();
    }	
}

/*
list<EmployeeSurvey__c> l = [Select e.SurveyResultGenerated__c, e.DeclinedSurveyBit__c, (Select Id From ProgramQualifications__r) From EmployeeSurvey__c e limit 999];
for(EmployeeSurvey__c es:l){
	if(es.ProgramQualifications__r.size() == 0) system.assert(false, 'ITS ZERO!!!');
}
*/