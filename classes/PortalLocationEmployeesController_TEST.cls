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
private class PortalLocationEmployeesController_TEST {
        Account a;
        public Location__c l;
        public EntityLocation__c el;
        public Employment__c emnt;
        public Employment__c emnt2;
        public Employee__c eyee1;
        public Employee__c eyee2;
        public EmployeeSurvey__c es;
        public Entity__c ent;
        public Wage__c w;
        public Hour__c h;       
        public AccountHierarchyLevel__c l1;
        public AccountHierarchyMember__c ahm1;
        
        public void createData(){
            a=new Account();
            a.name = 'test';
            insert a;
            
            ent = new Entity__c();
            ent.Name = 'test';
            ent.Account__c = a.id;
            insert ent;
            
            l1 = new AccountHierarchyLevel__c();
            l1.Account__c = a.id;
            l1.AccountHierarchyLevelLabelName__c = 'test level 1';
            l1.LevelNumber__c = 1;
            insert l1;
            
            ahm1 = new AccountHierarchyMember__c();
            ahm1.AccountHierarchyMemberName__c = 'test';
            ahm1.AccountHierarchyLevel__c = l1.id;
            ahm1.AccountHierarchyMemberLabelName__c = 'test';
            ahm1.Account__c = a.id;
            insert ahm1;
            
            l = new Location__c();
            l.Name = 'test';
            l.Account__c = a.id;
            l.AccountHierarchyMember__c = ahm1.id;
            insert l;
            
            el = new EntityLocation__c();
            el.Location__c = l.id;
            el.Entity__c = ent.id;
            insert el;
            
            eyee1 = new Employee__c();
            eyee1.FirstName__c = 'test1';
            eyee1.LastName__c = 'test1';
            eyee1.SSN__c = '000-00-0000';
            eyee1.Account__c = a.id;
            insert eyee1;
            
            eyee2 = new Employee__c();
            eyee2.FirstName__c = 'test2';
            eyee2.LastName__c = 'test2';
            eyee2.SSN__c = '000-00-1234';
            eyee2.Account__c = a.id;
            insert eyee2;
            
            emnt = new Employment__c();
            emnt.Employee__c = eyee1.id;
            emnt.Entity__c = ent.id;
            emnt.StartDate__c = date.today().addDays(-100);
            insert emnt;
            
            w = new Wage__c();
            w.EmploymentPeriod__c = emnt.id;
            w.WageAmount__c = 12;
            w.StartDate__c = date.today().addDays(-100);
            w.EndDate__c = date.today();
            insert w;
            
            h = new Hour__c();
            h.Location__c = l.id;
            h.Wage__c = w.id;
            h.HourAmount__c = 12.12;
            insert h;
        
            el= new EntityLocation__c();
            el.Location__c = l.id;
            el.Entity__c = ent.id;
            insert el;
            
            emnt2 = new Employment__c();
            emnt2.Employee__c = eyee2.id;
            emnt2.Entity__c = ent.id;
            emnt2.StartDate__c = date.today().addDays(-100);
            insert emnt2;
            
            es = new EmployeeSurvey__c();
            es.EntityLocation__c = el.id;
            es.EmploymentPeriod__c = emnt2.id;
            insert es;
            
        }       
    static testMethod void myUnitTest() {
       PortalLocationEmployeesController_TEST t = new PortalLocationEmployeesController_TEST();
       t.createData();
       Apexpages.currentPage().getParameters().put('locId', t.l.id);
       
       test.startTest();
       PortalLocationEmployeesController pl = new PortalLocationEmployeesController();
       System.assert(pl.ewList.size()>0);
       pl.nextPage();
       pl.previousPage();
       System.assert(pl.getemployeeIdSet() != null);
       test.stopTest();
    }
}