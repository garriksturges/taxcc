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
public class TEST_QualificationDocumentRequirementTri {
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
		
		
		public TEST_QualificationDocumentRequirementTri(){}
		public void makeData(){
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
    	
    	pp = new ProgramPeriod__c();
    	pp.Program__c = p.id;
    	pp.EndDate__c = Date.today().addDays(700);
    	pp.StartDate__c = date.today().addDays(-600);
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
			
			
			pcq = new ProgramCategoryQualification__c();
			pcq.Name = 'test';
			pcq.Survey__c = es.id;
			pcq.ProcessStage__c = qps.id;
			pcq.ProgramQualification__c = pq.id;
			insert pcq;			

			

		}
		
    static testMethod void myUnitTest() {
      TEST_QualificationDocumentRequirementTri tester = new TEST_QualificationDocumentRequirementTri();
      tester.makeData();
      test.startTest();
      QualificationDocumentRequirement__c qdr = new QualificationDocumentRequirement__c();
      qdr.DocumentRequirement__c = tester.dr.id;
      qdr.ProgramCategoryQualification__c = tester.pcq.id;
      insert qdr;
      system.assert(qdr.id != null);
      test.stopTest();
        
    }
}