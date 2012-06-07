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
private class PortalScreeningComplianceHelper_test {
		
		public Entity__c ent;
		public EntityLocation__c el;
		public Program__c p;
		public Program__c p2;
		public EmployeeSurvey__c es;
		public EmployeeSurvey__c es2;
		public Account a;
		public Employee__c emp;
		public Location__c l;
    public SurveyProgramScreened__c sps;
    
		public void insertData(){
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
    	es.SurveyDate__c = Datetime.now().addDays(-14);
    	insert es; 
    	
    	es2 = new EmployeeSurvey__c();
    	es2.Name = 'test2';
    	es2.EmploymentPeriod__c = em.id;
    	es2.EntityLocation__c = el.id;
    	insert es2;
    	
    	sps = new SurveyProgramScreened__c();
    	sps.Program__c = p.id;
    	sps.Survey__c =es.id;
    	insert sps;
	    			
		}
		
		
    static testMethod void myUnitTest() {
        PortalScreeningComplianceHelper_test t = new PortalScreeningComplianceHelper_test();
       	t.insertData();
				if(t.l.id == null) insert t.l;
        LocationProgram__c lp = new LocationProgram__c();
        lp.Program__c = t.p.id;
        lp.StartDate__c = Date.today().addDays(-300);
        lp.EndDate__c = Date.today().addDays(300);
        lp.Location__c = t.l.id;
        insert lp;
        lp =[Select Program__r.ShortName__c, Program__c,  Location__c, 
            Location__r.LongitudeCode__c,
            Location__r.LatitudeCode__c,
            Location__r.State__r.Name, Location__r.StreetAddressText__c, location__r.State__r.StateAbbr__c,
            Location__r.State__c, Location__r.Name, Location__r.LocationEID__c,
            Location__r.CityName__c, Location__r.AccountHierarchyMember__c
            From LocationProgram__c 
            where id = :lp.id];
        list<PortalExecutiveDashboardController.locationProgramWrapper> ll = new list<PortalExecutiveDashboardController.locationProgramWrapper>();
        Date sd = Date.today().addYears(-10);
        Date ed = Date.today().addYears(10);
        PortalExecutiveDashboardController.locationProgramWrapper lpw = new PortalExecutiveDashboardController.locationProgramWrapper(lp, 'red');
        ll.add(lpw);
        list <wktLocationEmployeeProgram__c> wktListF=[Select SurveyLocation__c, Program__c, Program__r.shortName__c, Employment__c, Employment__r.Location__c,
 							ProgramStartDate__c, ProgramName__c, ProgramEndDate__c, SurveyDate__c, Employment__r.Status__c,
							HireLocation__c, HireDate__c, Employee__c,  
							QualificationProcessStage__r.ExternalName__c, QualificationProcessStage__r.RankOrder__c, QualificationProcessStage__r.QualificationProcessStageEID__c, QualificationProcessStage__r.Name, QualificationProcessStage__c 
 							From wktLocationEmployeeProgram__c 
 							where HireLocation__c = :t.l.id];
       list <wktLocationEmployeeProgram__c> wktList =[Select SurveyLocation__c, Program__c, Program__r.shortName__c, Employment__c, Employment__r.Location__c,
 							ProgramStartDate__c, ProgramName__c, ProgramEndDate__c, SurveyDate__c, Employment__r.Status__c,
							HireLocation__c, HireDate__c, Employee__c,  
							QualificationProcessStage__r.ExternalName__c, QualificationProcessStage__r.RankOrder__c, QualificationProcessStage__r.QualificationProcessStageEID__c, QualificationProcessStage__r.Name, QualificationProcessStage__c 
 							From wktLocationEmployeeProgram__c 
 							where HireLocation__c = :t.l.id];
 							
        test.startTest();
        PortalScreeningComplianceHelper.setupPSC(ll, null, null);
        PortalScreeningComplianceHelper.setupDocDenom(wktList);
        PortalScreeningComplianceHelper.setupDocNum(wktList);
        PortalScreeningComplianceHelper.setupQualificationAndDocumentMaps(wktList, wktListF);
        PortalScreeningComplianceHelper.filterWktList(wktList);
        test.stopTest();
        
        
    }
}