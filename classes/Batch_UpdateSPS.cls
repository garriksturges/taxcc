global class Batch_UpdateSPS implements Database.Batchable<sObject>{
  public string q{get; set;}
  /***********************************************/
	global void setDefaultQuery(){
		q = 'Select s.SurveyProgramScreenedEID__c, s.Survey__c, s.Program__c, s.Survey__r.EmploymentPeriod__r.Employee__c From SurveyProgramScreened__c s where Survey__r.EmploymentPeriod__r.Employee__c != null';
		if(test.isRunningTest()) q = 'Select s.SurveyProgramScreenedEID__c, s.Survey__c, s.Program__c From SurveyProgramScreened__c s limit 100'; 
	}
  /***********************************************/
  global database.querylocator start(Database.BatchableContext BC){
       return Database.getQueryLocator(q);
  }
  /***********************************************/
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		list<SurveyProgramScreened__c> spsList = new list<SurveyProgramScreened__c>();
		double val;
		for(SurveyProgramScreened__c sps : (list<SurveyProgramScreened__c>)scope){
			val = sps.SurveyProgramScreenedEID__c;
			sps.SurveyProgramScreenedEID__c = val;
			spsList.add(sps);
		}
		update spsList;
	}
	/***********************************************/
	global void finish(Database.BatchableContext BC){
		
	}
	/***********************************************/
	global static void runBatch(){
		Batch_UpdateSPS b = new Batch_UpdateSPS();
		b.setDefaultQuery();
		Database.executeBatch(b, 100);
	}
	/***********************************************/
	static testMethod void Test_Batch_UpdateSPS() {
    		test.startTest();
        Batch_UpdateSPS.runBatch();
        test.stopTest();
    }	

}