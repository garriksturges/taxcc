@isTest
private class TEST_PQUpdateWKTLocationEmployeeProgram {
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
		
		public TEST_PQUpdateWKTLocationEmployeeProgram(){
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
    	
    	p2 = new Program__c();
    	p2.ShortName__c='t2';
    	p2.Name = 'test2';
    	//p.ProgramStartSummary__c = Date.today();
    	//p.ProgramEndSummary__c = Date.today();
    	insert p2;
    	
    	pp2 = new ProgramPeriod__c();
    	pp2.Program__c = p2.id;
    	pp2.StartDate__c = Date.today().addDays(-1000);
    	pp2.EndDate__c = Date.today().addDays(1000);
    	insert pp2;
    	
    	p3 = new Program__c();
    	p3.ShortName__c='t3';
    	p3.Name = 'test3';
    	//p.ProgramStartSummary__c = Date.today();
    	//p.ProgramEndSummary__c = Date.today();
    	insert p3;
    	
    	pp3 = new ProgramPeriod__c();
    	pp3.Program__c = p3.id;
    	pp3.StartDate__c = Date.today().addDays(-1000);
    	pp3.EndDate__c = Date.today().addDays(1000);
    	insert pp3;
    	
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
    	
    	es2 = new EmployeeSurvey__c();
    	es2.Name = 'test2';
    	es2.EmploymentPeriod__c = em.id;
    	es2.EntityLocation__c = el.id;
    	insert es2;
    	
    	es3 = new EmployeeSurvey__c();
    	es3.Name = 'test2';
    	es3.EmploymentPeriod__c = em.id;
    	es3.EntityLocation__c = el.id;
    	insert es3;
		}
		static testMethod void myUnitTest() {
			TEST_PQUpdateWKTLocationEmployeeProgram  t = new TEST_PQUpdateWKTLocationEmployeeProgram();
			test.startTest();
			list<ProgramQualification__c> pql = new list<ProgramQualification__c>();
			ProgramQualification__c pq = new ProgramQualification__c();
			pq.ProgramPeriod__c = t.pp.id;
			pq.Employment__c = t.em.id;
			pql.add(pq);
			//insert pq; 
			ProgramQualification__c pq2 = new ProgramQualification__c();
			pq2.ProgramPeriod__c = t.pp2.id;
			pq2.Employment__c = t.em.id;
			//insert pq;
			pql.add(pq2);
			ProgramQualification__c pq3 = new ProgramQualification__c();
			pq3.ProgramPeriod__c = t.pp3.id;
			pq3.Employment__c = t.em.id;
			//insert pq3;
			pql.add(pq3);
			insert pql;
			
			Employee__c emp = new Employee__c();
    	emp.Account__c = t.a.id;
    	emp.FirstName__c = 'test2';
    	emp.LastName__c = 'testington2';
    	emp.SSN__c = '000-00-3434';
    	insert emp;
    	Employment__c em = new Employment__c();
    	em.Employee__c = emp.id;
    	em.Location__c = t.l.id;
    	em.StartDate__c = Date.today().addDays(-400);
    	em.Entity__c = t.ent.id;
    	insert em;
    	
    	pql = new list<ProgramQualification__c>();
    	
    	ProgramQualification__c pqA = new ProgramQualification__c();
			pqA.ProgramPeriod__c = t.pp.id;
			pqA.Employment__c = em.id;
			//insert pqA;
			pql.add(pqA);
			ProgramQualification__c pqB = new ProgramQualification__c();
			pqB.ProgramPeriod__c = t.pp3.id;
			pqB.Employment__c = em.id;
			//insert pqA;
			pql.add(pqB);
 			
 			insert pql;
 			
			
			test.stopTest();
		}

}