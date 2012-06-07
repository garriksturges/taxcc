@istest
private class PortalEmployeeStatsTesting {
		public SurveyProgramScreened__c sps;
		public Entity__c ent;
		public EntityLocation__c el;
		public Program__c p;
		public EmployeeSurvey__c es;
		public Account a;
		public Employee__c emp;
		public Location__c l;

	static testMethod void testEmployeeStats(){
			PortalEmployeeStatsTesting tc= new PortalEmployeeStatsTesting();
			tc.setupTestData();
			Apexpages.currentPage().getParameters().put('locId',tc.l.id);
			PortalLocationEmployeeStatsController c = new PortalLocationEmployeeStatsController();
			c.updateEmployeeList();
			c.nextPage();
			c.previousPage();
			c.startDateFilter = date.today().addDays(-1000).format();
			c.endDateFilter = date.today().format();
			c.DateScreen();
			c.updateEmployeeList();
			system.assert(c.employeeList.size()>0); 
	}

	private void setupTestData(){
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
	}
}