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
private class TEST_EmploymentTrigger {
		public Account a;
		public Employee__c emp;
		public Location__c l;
		public Entity__c ent;
    static testMethod void myUnitTest() {
        TEST_EmploymentTrigger t = new TEST_EmploymentTrigger();
        test.startTest();
        String emId = t.insertTriggerData();
        list <wktLocationEmployeeProgram__c> w = [select Employment__c from wktLocationEmployeeProgram__c where Employment__c = :emId];
        system.assert(w.size()==1);
        
        Test.stopTest();
    }
    
    public TEST_EmploymentTrigger(){
    	a = new Account();
    	a.Name = 'testa';
    	insert a;
    	
    	ent = new Entity__c();
    	ent.Account__c = a.id;
    	ent.Name = 'test';
    	insert ent;
    	
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
    	
    }
    public String insertTriggerData(){
    	Employment__c em = new Employment__c();
    	em.Employee__c = emp.id;
    	em.Location__c = l.id;
    	em.StartDate__c = Date.today();
    	em.Entity__c = ent.id;
    	insert em;
    	
    	em.EndDate__c = Date.today();
    	update em;
    	return em.id;
    }
}