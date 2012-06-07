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
private class CalculateWOTC_Test{
//[Select Id, (Select Id From Credits__r), Entity__r.Id,Name,StartDate__c, (Select Id, Name, EndDate__c, StartDate__c,HoursSummary__c, WageAmount__c From Wages__r order by EndDate__c), 
//(Select Id, Name, Employment__c , ProgramPeriod__c, ProgramPeriod__r.Program__r.ProgramEID__c From ProgramQualifications__r) From Employment__c where Id IN: EmploymentIds];
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
		
		public void makeData(){
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
    	em.Entity__c = ent.id;
    	insert em;
    	
    	Wage__c w = new Wage__c();
    	w.EmploymentPeriod__c = em.id;
    	w.StartDate__c = Date.today().addDays(-299);
    	w.EndDate__c = Date.today().addDays(-1);
    	w.WageAmount__c = 50;
    	insert w;
    	
    	Hour__c h = new Hour__c();
    	h.HourAmount__c = 10000;
    	h.Wage__c = w.id;
    	h.Location__c = l.id;
    	h.RateAmount__c = 25;
    	insert h;
    	
    	w = new Wage__c();
    	w.EmploymentPeriod__c = em.id;
    	w.StartDate__c = Date.today().addDays(-299);
    	w.EndDate__c = Date.today().addYears(5);
    	w.WageAmount__c = 500;
    	insert w;
    	
    	h = new Hour__c();
    	h.HourAmount__c = 10000;
    	h.Wage__c = w.id;
    	h.Location__c = l.id;
    	h.RateAmount__c = 25;
    	insert h; 
    	
    	es = new EmployeeSurvey__c();
    	es.Name = 'test';
    	es.EmploymentPeriod__c = em.id;
    	es.EntityLocation__c = el.id;
    	insert es; 
    	
    	sps = new SurveyProgramScreened__c();
      sps.Survey__c = es.id;
      sps.Program__c = p.id;
      insert sps;
    	
    	qps = new QualificationProcessStage__c();
    	qps.InCertificationProcessBit__c = true;
    	qps.Name = 'TEST';
			qps.ExternalName__c = 'TEST';
			qps.RankOrder__c = 2;
			insert qps;
		
			pq = new ProgramQualification__c();
			pq.Employment__c = em.id;
			pq.ProcessStage__c = qps.id;
			pq.ProcessStageDate__c = Datetime.now().addDays(-100);
			pq.ProgramPeriod__c = pp.id;
			pq.ProgramQualificationEID__c = 123123.23;
			pq.Survey__c =  es.id;
			insert pq;
			
			pc = new ProgramCategory__c();
			pc.Name = 'testpc';
			pc.ProgramCategoryDescriptionText__c='testing stuff';
			pc.ProgramCategoryCode__c = 'yellow';
			pc.RankOrder__c = 2.0;
			pc.Program__c = p.id;
			insert pc;
		
			dr = new DocumentRequirement__c();
			dr.Name = 'test';
			dr.SortOrder__c = 1;
			dr.Program__c = p.id;
			dr.ProgramCategory__c = pc.id;
			insert dr;		
			
			di = new DocumentInstruction__c();
			di.Audience__c = 'Employee';
			di.Language__c = 'English';
			di.InstructionSummaryText__c = 'some text';
			di.DocumentRequirement__c = dr.id;
			insert di;	
			
			ds = new DocumentStep__c();
			ds.InternalStatus__c = 'test';
			ds.Name = 'test';
			ds.QualificationProcessStage__c = qps.id;
			ds.StepOrder__c = 1.0;
			ds.DocumentRequirement__c = dr.id;
			insert ds;

			dSource = new DocumentSource__c();
			dsource.DocumentSourceEID__c = 1.0;
			dSource.Name = 'test';
			insert dSource;
			
			dt = new Documenttype__c();
			dt.DescriptionText__c ='test';
			dt.DocumentationStage__c = 'test';
			dt.DocumentSource__c = dsource.id;
			dt.DocumentTypeAbbr__c ='t';
			dt.Name = 'test';
			dt.SortOrder__c = 1;
			dt.Usage__c = 'test';
			insert dt;
			
			doco = new DocumentOption__c();
			doco.DocumentStep__c = ds.id;
			doco.DocumentType__c = dt.id;
			insert doco;
			
			list<ProgramCategory__c> pcList = [select ProgramCategoryEID__c, id from ProgramCategory__c where ProgramCategoryEID__c != null];
	    map<double, ProgramCategory__c> pcMap = new map<double, ProgramCategory__c>();
	    for(ProgramCategory__c pc: pcList){
	    	pcMap.put(pc.ProgramCategoryEID__c, pc);
	    }
	    
	    list<ProgramCategoryPeriod__c> pcpL = new List<ProgramCategoryPeriod__c>();
	    pcp = new ProgramCategoryPeriod__c();
	    pcp.ProgramCategory__c = pcMap.get(73).id;
	    pcp.StartDate__c = date.today().addDays(-40);
	    pcp.EndDate__c = date.today();
	    pcp.Area__c = ar.id;
	    pcpL.add(pcp);//insert pcp;	
	    
	    pcp = new ProgramCategoryPeriod__c();
	    pcp.ProgramCategory__c = pcMap.get(70).id;
	    pcp.StartDate__c = date.today().addDays(-40);
	    pcp.EndDate__c = date.today();
	    pcp.Area__c = ar.id;
	    pcpL.add(pcp);//insert pcp;
	    insert pcpL;
			
			list<ProgramCategoryQualification__c> pcql = new list<ProgramCategoryQualification__c>();
			pcq = new ProgramCategoryQualification__c();
			pcq.Name = 'test';
			pcq.Survey__c = es.id;
			pcq.ProcessStage__c = qps.id;
			pcq.ProgramQualification__c = pq.id;
			pcq.ProgramCategoryPeriod__c = pcpL[0].id;
			pcqL.add(pcq);//insert pcq;	
			
	    
			pcq = new ProgramCategoryQualification__c();
			pcq.Name = 'test';
			pcq.Survey__c = es.id;
			pcq.ProcessStage__c = qps.id;
			pcq.ProgramQualification__c = pq.id;
			pcq.ProgramCategoryPeriod__c = pcpL[1].id;
			pcqL.add(pcq);//insert pcq;	
			
			insert pcqL;
		}	

	static testMethod void myUnitTestWOTC() {
		CalculateWOTC_Test t = new CalculateWOTC_Test();
		t.makeData();
		test.startTest();
		set <string> idSet = new set<string>();
		idSet.add(t.em.id);
		CalculateWOTC cw = new CalculateWOTC();
		cw.CalculateWOTCCredit(5.123, idSet);
		test.stopTest();
	}
/*public static List<ProgramCategoryPeriod__c> ProgramCategoryPeriodList;
public static ProgramCategoryPeriod__c pcperiod, pcperiod1;
public static Employee__c EmployeeList;
public static List<Wage__c> WageList;
*/
    static testMethod void myUnitTest() {
 /*
   test.startTest();   
    Program__c prog = [Select Name, Id,(Select Id, Name, ProgramCategoryCode__c, ProgramCategoryEId__c From ProgramCategories__r where ProgramCategoryEId__c = 73.0),(Select Id, Name, EndDate__c, StartDate__c, Program__c From ProgramPeriods__r) From Program__c where Name = 'Work Opportunity Tax Credit'];
         
    Area__c area = new Area__c(Name='United States (50 states and DC)', AreaDescriptionText__c ='Test Area');
    insert area;
        
    Agency__c Agcy = new Agency__c(Name='Test Agency');
    insert Agcy;
        
    ProgramPeriod__c prgperiod = new ProgramPeriod__c(Name='Test Program period',Program__c=prog.Id, Area__c=area.Id,Agency__c=Agcy.Id,StartDate__c=System.today().addDays(-40));
    insert prgperiod;   
       
    ProgramCategory__c prgcat = new ProgramCategory__c(Name='Test ProgramCategory',program__c=prog.Id);
    insert prgcat;
       
    DocumentRequirement__c dr = new DocumentRequirement__c(Name='Documents Required', ProgramCategory__c=prgcat.Id);
    insert dr;
        
    DocumentStep__c drStep = new DocumentStep__c(Name='Doc Role Step', DocumentRequirement__c = dr.Id);
    insert drStep; 
        
    State__c state = new State__c(Name='California', StateAbbr__c = 'CA');
    insert state;
        
    Location__c loc = new Location__c(Name= 'Test Location',StreetAddressText__c ='StrtAddress', CityName__c='XYZ', State__c = state.Id, ZipCode__c = '67542');
    insert loc; 
    
    // Program Category Period List.   
    pcperiod = new ProgramCategoryPeriod__c(Name='Testprgcatperiod',Area__c = area.Id, ProgramCategory__c = prgcat.Id, StartDate__c = System.today().addDays(-40));
    pcperiod1 = new ProgramCategoryPeriod__c(Name='Testprgcatperiod',Area__c = area.Id, ProgramCategory__c = prog.ProgramCategories__r[0].Id, StartDate__c = System.today().addDays(-35));
    ProgramCategoryPeriodList = new List<ProgramCategoryPeriod__c>{pcperiod,pcperiod1};
    insert ProgramCategoryPeriodList;
                
    Account a = new Account(Name='Test Account');
    insert a;
        
    Entity__c ent = new Entity__c(Account__c = a.Id, Name = 'TestEntity');
    insert ent;
        
    EntityFiscalyear__c entFiscalyear = new EntityFiscalyear__c(Entity__c = ent.Id, FiscalYearEndDate__c = System.today().adddays(100));
    insert entFiscalyear;
    
    //Employee List    
    employee = new Employee__c(FirstName__c ='Emp1',Account__c = a.Id, LastName__c ='Lname',MiddleName__c = 'MName', SSN__c = '343532523');
    employee2 = new Employee__c(FirstName__c ='Emp2',Account__c = a.Id, LastName__c ='Lname2', SSN__c = '343532523');
    EmployeeList = new List<Employee__c>{employee,employee2};  
    insert EmployeeList;
        
    Employment__c emplnt = new Employment__c(Employee__c = EmployeeList[0].Id, Entity__c = ent.Id, Status__c = 'Hired',StartDate__c = System.today().addDays(-30));
    insert emplnt;
        
     wage1 = new Wage__c(WageAmount__c = 8000, StartDate__c = System.today(), EndDate__c=System.today().addDays(100) , EmploymentPeriod__c = emplnt.Id);
     wage2 = new Wage__c(WageAmount__c = 3000, StartDate__c = System.today().addDays(101), EndDate__c=System.today().addDays(375) , EmploymentPeriod__c = emplnt.Id);      
     WageList = new List<Wage__c>{wage1,wage2};
     insert WageList;
       
    
   //     Hour__c hr = new Hour__c(Wage__c = w.Id, HourAmount__c=250.00, RateAmount__c = 20.00,Location__c = loc.Id);        
     //   insert hr;
        
    //    Hour__c hr2 = new Hour__c(Wage__c = w2.Id, HourAmount__c=200.00, RateAmount__c = 30.00,Location__c = loc.Id);
    //    ProcessorControl.inFutureContext = false;
     //   insert hr2;
        
        ProgramQualification__c progQual = new ProgramQualification__c(Name='TestProgramQualification',Employment__c = emplnt.Id, ProgramPeriod__c = prgperiod.Id);
        insert progQual;
                
        
        ProgramCategoryQualification__c pcq = new ProgramCategoryQualification__c(ProgramCategoryPeriod__c = pcperiod.Id, ProgramQualification__c = progQual.Id); 
        insert pcq;
        
        
                     
        ProgramCategoryQualification__c pcq2 = new ProgramCategoryQualification__c(ProgramCategoryPeriod__c = pcperiod.Id, ProgramQualification__c = progQual.Id); 
        insert pcq2;
                 
       
         
        ProcessorControl.inFutureContext = false; 
        emplnt.StartDate__c = System.today().addDays(-39);
        update emplnt;  
        
        emplnt.StartDate__c = System.today().addDays(1);
        
        try{
            ProcessorControl.inFutureContext = false;
            update emplnt;
        }
        catch(Exception e)
        {
            System.assertEquals(e.getMessage().Contains('This employee must have actually been hired earlier than that date. The employee already has wages starting earlier'), true);
        } 
        
        Test.startTest();
        ProcessorControl.inFutureContext = false;
        progQual.EffectiveDate__c = System.today().addDays(-39);
        update progQual;
        
        
        ProcessorControl.inFutureContext = false;     
        delete hr;
        ProcessorControl.inFutureContext = false;
        delete w2;
        ProcessorControl.inFutureContext = false;
        delete pcq;
        
        Test.stopTest();     
        */
    } 
}