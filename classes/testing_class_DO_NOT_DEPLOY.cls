public with sharing class testing_class_DO_NOT_DEPLOY {

		public SurveyProgramScreened__c sps;
		public Entity__c ent;
		public EntityLocation__c el;
		public Program__c p;
		public ProgramPeriod__c pp;
		public Program__c p2;
		public ProgramPeriod__c pp2;
		public Program__c p3;
		public ProgramPeriod__c pp3;
		public EmployeeSurvey__c es;
		public EmployeeSurvey__c es2;
		public EmployeeSurvey__c es3;
		public Account a;
		public Employee__c emp;
		public Location__c l;
		public Employment__c em;
		public ProgramQualification__c pq;
		public ProgramCategoryPeriod__c pcp;
		
		public testing_class_DO_NOT_DEPLOY(){
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
    	//p.ProgramStartSummary__c = Date.today();
    	//p.ProgramEndSummary__c = Date.today();
    	insert p;
    	
    	pp = new ProgramPeriod__c();
    	pp.Program__c = p.id;
    	pp.StartDate__c = Date.today().addDays(-1000);
    	pp.EndDate__c = Date.today().addDays(1000);
    	insert pp;
    	
    	em = new Employment__c();
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
    	
    	SurveyProgramScreened__c sps = new SurveyProgramScreened__c();
      sps.Survey__c = es.id;
      sps.Program__c = p.id;
      insert sps;
    	
    	pq = new ProgramQualification__c();
			pq.ProgramPeriod__c = pp.id;
			pq.Employment__c = em.id;
			insert pq; 
			
			ProgramCategory__c pcat = new ProgramCategory__c();
			pcat.Name = 'TEST';
			pcat.Program__c = p.id;
			insert pcat;
			
			Area__c ar = new Area__c();
			ar.Name = 'aragas';
			insert ar;
			
			pcp= new ProgramCategoryPeriod__c();
			pcp.ProgramCategory__c = pcat.id;
			pcp.Area__c = ar.id;
			insert pcp;
		}
		
		static testMethod void myUnitTest() {
			testing_class_DO_NOT_DEPLOY t = new testing_class_DO_NOT_DEPLOY();
			test.startTest();
			ProgramCategoryQualification__c pcq = new ProgramCategoryQualification__c();
			pcq.ProgramQualification__c = t.pq.id;
			pcq.ProgramCategoryPeriod__c = t.pcp.id;
			insert pcq;
			
			test.stopTest();
		}
		

}