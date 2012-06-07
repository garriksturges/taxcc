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
public class CreateAsyncQualificationDocs_Test {
	
public static Account a;
 public static Entity__c Entity;
 public static Employee__c employee;
 public static Employment__c employment;
 public static Area__c area, area1;
 public static List<Area__c> areaList;
 public static Agency__c Agency;
 public static Program__c program;
 public static ProgramCategory__c pc, pc1, pc2, pc3; 
 public static List<ProgramCategory__c> programCategoryList;
 public static ProgramCategoryPeriod__c pcp, pcp1, pcp2, pcp3;
 public static List<ProgramCategoryPeriod__c> programCategoryPeriodList;
 public static ProgramQualification__c programQualification;
 public static ProgramPeriod__c programPeriod;
 public static QualificationProcessStage__c qualificationProcessStage;
 public static List<ProgramQualification__c> programQualificationList;
 public static QualificationReadiness__c qr, qr1;
 /*****************************************************************/   
 
 static {
    
    	/*loginUser = [select id from user where id='00530000004rW4R'];*/
        a = new Account(Name='Test Account');
        insert a;
        
        Entity  = new Entity__c(Account__c = a.Id, Name = 'TestEntity');
        insert Entity;
        
        employee = new Employee__c(FirstName__c ='Emp1',Account__c = a.Id, LastName__c ='Lname',MiddleName__c = 'MName', SSN__c = '343532523');
        insert employee;
        
        employment = new Employment__c(Employee__c = employee.Id, Entity__c = Entity.Id, Status__c = 'Hired',StartDate__c = System.today().addDays(-60));
        insert employment;
        
        // Area List
        area = new Area__c(Name='United States (50 states and DC)', AreaDescriptionText__c ='Test Area');
        area1 = new Area__c(Name='United States (50 states and DC)', AreaDescriptionText__c ='Test Area');
        areaList = new Area__c[] {area1,area};
        insert areaList ;  
        
        Agency = new Agency__c(Name='Test Agency');
        insert Agency;
        
        //Program
        program = new Program__c(Name='Test Program');
        insert program;
        
        // Program Category List      
        pc = new ProgramCategory__c(Program__c = program.Id, Name = 'Test program Category', RankOrder__c = 60);
        pc1 = new ProgramCategory__c(Program__c = program.Id, Name = 'Test  Category', RankOrder__c = 80);
        pc2 = new ProgramCategory__c(Program__c = program.Id, Name = 'Test  Category', RankOrder__c = 100); // Has 2 Document Requirements.
        pc3 = new ProgramCategory__c(Program__c = program.Id, Name = 'Testing program Category', RankOrder__c = 70);
        programCategoryList = new ProgramCategory__c []{pc , pc1, pc2, pc3}; 
        insert programCategoryList ; 
        
        // Program Category Period List   
        pcp = new ProgramCategoryPeriod__c(Name = 'TestProgramCategoryPeriod', ProgramCategory__c = programCategoryList[0].Id, Area__c = areaList[0].Id, StartDate__c = System.today().addDays(-90));
  		pcp1 = new ProgramCategoryPeriod__c(Name = 'TestProgramCategoryPeriod', ProgramCategory__c = programCategoryList[1].Id, Area__c = areaList[1].Id, StartDate__c = System.today().addDays(-70));
        pcp2 = new ProgramCategoryPeriod__c(Name = 'TestProgramCategoryPeriod', ProgramCategory__c = programCategoryList[2].Id, Area__c = areaList[1].Id, StartDate__c = System.today().addDays(-50)); // Can be used in PCQ!
        pcp3 = new ProgramCategoryPeriod__c(Name = 'TestProgramCategoryPeriod', ProgramCategory__c = programCategoryList[3].Id, Area__c = areaList[1].Id, StartDate__c = System.today().addDays(-80));
        programCategoryPeriodList = new ProgramCategoryPeriod__c[]{pcp, pcp1, pcp2, pcp3};
        insert programCategoryPeriodList; // Program Category Period List
        
        // Document Requirements
        
        DocumentRequirement__c drq = new DocumentRequirement__c(Name = 'Address Verification', Program__c = program.Id );
		DocumentRequirement__c drq1 = new DocumentRequirement__c(Name = 'Address Verification', ProgramCategory__c = programCategoryList[1].Id );
		DocumentRequirement__c drq2 = new DocumentRequirement__c(Name = 'Address Verification', ProgramCategory__c = programCategoryList[2].Id );
		DocumentRequirement__c drq3 = new DocumentRequirement__c(Name = 'Address Verification', ProgramCategory__c = programCategoryList[2].Id );
	   	List<DocumentRequirement__c> docsList = new List<DocumentRequirement__c>{drq,drq1,drq2,drq3};
	    insert docsList;
	    
        // Program Period 
        programPeriod = new ProgramPeriod__c(Name='Test Program period',Program__c=program.Id,  Area__c=areaList[0].Id, Agency__c = Agency.Id,StartDate__c=System.today().addDays(-200));
        insert programPeriod;
        
        // Qualification Process Stage
        
        qualificationProcessStage = new QualificationProcessStage__c (Name = 'Ready to Prepare Application' , RankOrder__c = 90 );
        insert qualificationProcessStage;  
        
        // Program Qualification List
        programQualification = new ProgramQualification__c(Name = 'Test Program Qualification', ProgramPeriod__c = programPeriod.Id, Employment__c = employment.Id, ProcessStage__c = qualificationProcessStage.Id );
        programQualificationList = new List<ProgramQualification__c>{programQualification};
        insert programQualificationList;
        
        // Qualification Readiness 
        qr = new QualificationReadiness__c(Name = 'Available', RankOrder__c = 1, QualificationReadinessEID__c = 9);
        insert qr;
        qr1 = new QualificationReadiness__c(Name = 'Disqualified Automatically', RankOrder__c = 2,QualificationReadinessEID__c = 8);
        insert qr1;
 } 
 
 /**********************************************/         
       static testMethod void myUnitTest1() {
       	test.starttest(); 
       	ProgramCategoryQualification__c pcq1 = new ProgramCategoryQualification__c(ProgramCategoryPeriod__c = programCategoryPeriodList[2].Id, 
        										ProgramQualification__c = programQualification.Id, PCQUpdateThroughBATCH__c = true);
        
        List<ProgramCategoryQualification__c> pcqList = new List<ProgramCategoryQualification__c>{pcq1};
        insert pcqList ; 
      	BATCH_QDRHelper.invokeBatch();
        test.stopTest();
          
        pcqList = [select ProcessStageEIDformula__c, ReadinessEid__c from ProgramCategoryQualification__c where id in :pcqList ];
        system.assertEquals(2.0,pcqList[0].ReadinessEid__c);
        system.assertEquals(26,pcqList[0].ProcessStageEIDformula__c);
        System.assertEquals(false ,[select PCQUpdateThroughBATCH__c from ProgramCategoryQualification__c where id in :pcqList  ].PCQUpdateThroughBATCH__c);
   	}
 
}