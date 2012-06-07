/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_PreventOverlappingWage_trigger {
		
		public SurveyProgramScreened__c sps;
		public Entity__c ent;
		public EntityLocation__c el;
		public Program__c p;
		public EmployeeSurvey__c es;
		public Account a;
		public Employee__c emp;
		public Location__c l;
		public Employment__c em;
		public QualificationProcessStage__c qps;
		public ProgramPeriod__c pp;
		public ProgramQualification__c pq;
		public ProgramCategory__c pc;
		public DocumentRequirement__c dr;
		public DocumentInstruction__c di;
		public DocumentStep__c ds;
		public DocumentOption__c doco;
		public DocumentSource__c dsource;
		public Documenttype__c dt;
		public ProgramCategoryPeriod__c pcp;
		public ProgramCategoryQualification__c pcq;
		public Area__c ar;

    public void setupData(){
    				a = new Account();
    	a.Name = 'testa';
    	insert a;
    	
    	Area__c ar = new Area__c();
      insert ar;
    	
    	emp = new Employee__c();
    	emp.Account__c = a.id;
    	emp.FirstName__c = 'test';
    	emp.LastName__c = 'testington';
    	emp.SSN__c = '000-00-1234';
    	
    	insert emp;
    	
      l = new Location__c();
    	l.Account__c = a.id;
    	l.Name = 'test';
    	insert l;
    	
    	ent = new Entity__c();
    	ent.Account__c = a.id;
    	ent.Name = 'test';
    	insert ent;
    	
    	el = new EntityLocation__c();
    	el.Entity__c = ent.id;
    	el.Location__c = l.id;
    	insert el;
    	
    	p = new Program__c();
    	p.ShortName__c='t';
    	p.Name = 'test';
    	p.ProgramEID__c = 5.123;
    	//p.ProgramStartSummary__c = Date.today();
    	//p.ProgramEndSummary__c = Date.today();
    	insert p;
    	
    	pp = new ProgramPeriod__c();
    	pp.Program__c = p.id;
    	pp.EndDate__c = Date.today().addDays(700);
    	pp.StartDate__c = date.today().addDays(-600);
    	insert pp;
    	 
    	em = new Employment__c();
    	em.Employee__c = emp.id;
    	em.Location__c = l.id;
    	em.StartDate__c = Date.today().addDays(-300);
    	em.EndDate__c = Date.today().addDays(50);
    	em.Entity__c = ent.id;
    	insert em;
    }
    
    static testMethod void myUnitTest() {
			Test_PreventOverlappingWage_trigger t = new Test_PreventOverlappingWage_trigger();
			t.setupData();
			test.startTest();
			Wage__c w = new Wage__c();
    	w.EmploymentPeriod__c = t.em.id;
    	w.StartDate__c = Date.today().addDays(-299);
    	w.EndDate__c = Date.today().addDays(-1);
    	w.WageAmount__c = 50;
    	insert w;    
    	
    	w = new Wage__c();
    	w.EmploymentPeriod__c = t.em.id;
    	w.StartDate__c = Date.today().addDays(-298);
    	w.EndDate__c = Date.today().addDays(-2);
    	w.WageAmount__c = 505;
    	insert w;
    	
    	w.StartDate__c = Date.today().addDays(-300);
    	w.EndDate__c = Date.today().addDays(-100);
    	update w;
    	
    	Wage__c w2 = new Wage__c();
    	w2.EmploymentPeriod__c = t.em.id;
    	w2.StartDate__c = Date.today().addDays(52);
    	w2.EndDate__c = Date.today().addDays(55);
    	w2.WageAmount__c = 505;
    	insert w2;
    	    
    	
			test.stopTest();
    }
}