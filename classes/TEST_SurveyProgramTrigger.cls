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
public class TEST_SurveyProgramTrigger {
		public SurveyProgramScreened__c sps;
		public Entity__c ent;
		public EntityLocation__c el;
		public Program__c p;
		public Program__c p2;
		public EmployeeSurvey__c es;
		public EmployeeSurvey__c es2;
		public Account a;
		public Employee__c emp;
		public Location__c l;
		
		public TEST_SurveyProgramTrigger(){
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
    	//p.ProgramStartSummary__c = Date.today();
    	//p.ProgramEndSummary__c = Date.today();
    	insert p;
    	
    	p2 = new Program__c();
    	p2.ShortName__c='t2';
    	p2.Name = 'test2';
    	//p.ProgramStartSummary__c = Date.today();
    	//p.ProgramEndSummary__c = Date.today();
    	insert p2;
    	
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
    	
    	es2 = new EmployeeSurvey__c();
    	es2.Name = 'test2';
    	es2.EmploymentPeriod__c = em.id;
    	es2.EntityLocation__c = el.id;
    	insert es2;
		}

    static testMethod void myUnitTest() {
        TEST_SurveyProgramTrigger  tester = new TEST_SurveyProgramTrigger();
        Test.startTest();
        SurveyProgramScreened__c sps = new SurveyProgramScreened__c();
        sps.Survey__c = tester.es.id;
        sps.Program__c = tester.p.id;
        insert sps;
        list <wktLocationEmployeeProgram__c> w = [select SurveyProgramScreened__c, Program__c from wktLocationEmployeeProgram__c where SurveyProgramScreened__c = :sps.id];
        system.assert(w.size()==1);
        sps = new SurveyProgramScreened__c();
        sps.Survey__c = tester.es2.id;
        sps.Program__c = tester.p2.id;
        insert sps;
        w = [select SurveyProgramScreened__c, Program__c from wktLocationEmployeeProgram__c where SurveyProgramScreened__c = :sps.id];
        system.assert(w.size()==1);
        w = [select SurveyProgramScreened__c, Program__c, Employee__c from wktLocationEmployeeProgram__c where employee__c = :tester.emp.id];
        System.assert(w.size() == 2);
        for(wktLocationEmployeeProgram__c wkt :w){
        	System.assert(wkt.Program__c != null);
        }
        Test.stopTest();
    }
}