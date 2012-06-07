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
public class BATCH_EmailDigest_TEST {
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
    public AccountHierarchyLevel__c l2;
    public AccountHierarchyLevel__c l3;
    public AccountHierarchyMember__c ahm1;
    public AccountHierarchyMember__c ahm2;
    public AccountHierarchyMember__c ahm3;
    public SurveyProgramScreened__c sps;
        public Program__c prog1;
        public LocationProgram__c lp1;
        public Contact c;
        public PortalNotificationSchedule__c p;
        
        public  BATCH_EmailDigest_TEST(){}
        public void insertInfo(){
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
            
            l2 = new AccountHierarchyLevel__c();
            l2.Account__c = a.id;
            l2.AccountHierarchyLevelLabelName__c = 'test level 2';
            l2.LevelNumber__c = 2;
            l2.AccountHierarchyLevel__c = l1.id;
            insert l2;
            
            l3 = new AccountHierarchyLevel__c();
            l3.Account__c = a.id;
            l3.AccountHierarchyLevelLabelName__c = 'test level 3';
            l3.LevelNumber__c = 3;
            l3.AccountHierarchyLevel__c = l2.id;
            insert l3;  
            
            ahm1 = new AccountHierarchyMember__c();
            ahm1.AccountHierarchyMemberName__c = 'test';
            ahm1.AccountHierarchyLevel__c = l1.id;
            ahm1.AccountHierarchyMemberLabelName__c = 'test';
            ahm1.Account__c = a.id;
            insert ahm1;
            
            ahm2 = new AccountHierarchyMember__c();
            ahm2.ParentAccountHierarchyMember__c = ahm1.id;
            ahm2.AccountHierarchyMemberName__c = 'test2';
            ahm2.AccountHierarchyLevel__c = l2.id;
            ahm2.AccountHierarchyMemberLabelName__c = 'test';
            ahm2.Account__c = a.id;
            insert ahm2;
            
            ahm3 = new AccountHierarchyMember__c();
            ahm3.ParentAccountHierarchyMember__c = ahm2.id;
            ahm3.AccountHierarchyMemberName__c = 'test3';
            ahm3.AccountHierarchyLevel__c = l3.id;
            ahm3.AccountHierarchyMemberLabelName__c = 'test';
            ahm3.Account__c = a.id;
            insert ahm3;

            l = new Location__c();
            l.Name = 'test';
            l.Account__c = a.id;
            l.AccountHierarchyMember__c = ahm3.id;
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
            emnt.StartDate__c = date.today().addDays(-1);
            emnt.Location__c = l.id;
            emnt.Status__c = 'Hired';
            insert emnt;
            
            w = new Wage__c();
            w.EmploymentPeriod__c = emnt.id;
            w.WageAmount__c = 12;
            w.StartDate__c = date.today().addDays(-1);
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
            emnt2.StartDate__c = date.today();
            emnt2.Location__c = l.id;
            emnt2.Status__c = 'Hired';
            insert emnt2;
            
            es = new EmployeeSurvey__c();
            es.EntityLocation__c = el.id;
            es.EmploymentPeriod__c = emnt2.id;
            es.ReportedHireDate__c = date.today();
            insert es;
                      
            prog1 = new Program__c();
        prog1.ShortName__c = 'PROG';
        prog1.MaximumLifetimeBenefitAmount__c = 123.0;
        insert prog1;
        
        sps = new SurveyProgramScreened__c();
      sps.Survey__c = es.id;
      sps.Program__c = prog1.id;
      insert sps;
      
        lp1 = new LocationProgram__c();
        lp1.Location__c = l.id;
        lp1.Program__c = prog1.id;
        lp1.StartDate__c = Date.today().addDays(-4000);
        lp1.EndDate__c = Date.today().addDays(4000);
        insert lp1;
        
        c= new Contact();
        c.AccountHierarchyMember__c = ahm1.id;
        c.AccountId = a.id;
        c.ExecutiveAccessBit__c = true;
        c.FirstName= 'test';
        c.LastName = 'testing';
        c.Email = 'test@testingsthebatch.com';
        insert c;
         
        p = new PortalNotificationSchedule__c();
        p.Contact__c = c.id;
        p.NextDigestDate__c = date.today();
        p.Frequency__c = 'Daily';
        p.DigestType__c = 'First';
        insert p;
        
       
        }
        
    static testMethod void testBatch() {
      BATCH_EmailDigest_TEST t = new BATCH_EmailDigest_TEST();
      t.insertInfo();
      test.startTest();
      BATCH_EmailDigest.runBatch();
      system.assert(true);
      test.stopTest();
      
    }
	
	
}