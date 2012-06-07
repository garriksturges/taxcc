global class BATCH_RunUpdateOnEmployeeSurvey implements Database.Batchable<sObject>{

		global static void runBatch(){
			BATCH_RunUpdateOnEmployeeSurvey b = new BATCH_RunUpdateOnEmployeeSurvey();
			b.setDefaultQuery();
			Database.executeBatch(b);
		}


		public String query{get; set;}
	    
	    global void setDefaultQuery(){
	        this.query = 'Select SurveyDate__c From EmployeeSurvey__c';
	        if(test.isRunningTest()) this.query = 'Select SurveyDate__c From EmployeeSurvey__c limit 100';
	    }
	    
	    global database.querylocator start(Database.BatchableContext BC){
	            return Database.getQueryLocator(query);
	    }
	    
	    global void execute(Database.BatchableContext BC, List<sObject> scope){
        	List<EmployeeSurvey__c> obs = new List<EmployeeSurvey__c>();
            Datetime sd;
        		
        	for(EmployeeSurvey__c s :(list<EmployeeSurvey__c>)scope){
          		sd = s.SurveyDate__c;
          		s.SurveyDate__c = sd;
          		obs.add(s);
        	}
 
        	update obs;
		}
	 
    	global void finish(Database.BatchableContext BC){
	         
    	}
    	
  	static testMethod void TEST_BATCH_RunUpdateOnEmployeeSurvey() {
	     SurveyProgramScreened__c sps;
			 Entity__c ent;
			 EntityLocation__c el;
			 Program__c p;
			 EmployeeSurvey__c es;
			 Account a;
			 Employee__c emp;
			 Location__c l;
    	a = new Account();
    	a.Name = 'testa';
    	insert a;
    	
    	emp = new Employee__c();
    	emp.Account__c = a.id;
    	emp.FirstName__c = 'test';
    	emp.LastName__c = 'testington';
    	emp.SSN__c = '000-00-1234';
    	insert emp;
    	
      l = new Location__c();
    	l.Account__c = a.id;
    	l.Name = 'test';
    	
    	ent = new Entity__c();
    	ent.Account__c = a.id;
    	ent.Name = 'test';
    	insert ent;
    	    	
    	el = new EntityLocation__c();
    	el.Entity__c = ent.id;
    	el.Location__c = l.id;
    	
    	p = new Program__c();
    	p.ShortName__c='t';
    	p.Name = 'test';
    	p.MaximumLifetimeBenefitAmount__c = 100;
    	//p.ProgramStartSummary__c = Date.today();
    	//p.ProgramEndSummary__c = Date.today();
    	insert p;
    	
    	 
    	Employment__c em = new Employment__c();
    	em.Employee__c = emp.id;
    	em.Location__c = l.id;
    	em.StartDate__c = Date.today();
    	em.Entity__c = ent.id;
    	insert em;
    	
    	es = new EmployeeSurvey__c();
    	es.Name = 'test';
    	es.EmploymentPeriod__c = em.id;
    	es.EntityLocation__c = el.id;
    	insert es; 
    		test.startTest();
        BATCH_RunUpdateOnEmployeeSurvey.runBatch();
        test.stopTest();
    }

}