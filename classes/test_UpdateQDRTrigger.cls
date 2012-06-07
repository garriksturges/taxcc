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
private class test_UpdateQDRTrigger {

       static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
         Account a = new Account(Name='Test Account');
        insert a;
        
        Entity__c ent = new Entity__c(Account__c = a.Id, Name = 'TestEntity');
        insert ent;
        
        Employee__c employee = new Employee__c(FirstName__c ='Emp1',Account__c = a.Id, LastName__c ='Lname',MiddleName__c = 'MName', SSN__c = '343532523');
        insert employee;
        
        
        Employment__c emplnt = new Employment__c(Employee__c = employee.Id, Entity__c = ent.Id, Status__c = 'Hired',StartDate__c = System.today().addDays(-30));
        insert emplnt;
        
        /*Employment__c emplnt2 = [Select Employment__r.StartDate__c, Employment__r.EndDate__c, Employment__r.Employee__c, Employment__r.Name,ProgramPeriod__r.Program__c,Employment__r.Id, Employment__c,ProgramPeriod__r.StartDate__c,ProgramPeriod__r.EndDate__c, ProgramPeriod__r.Program__r.Id,ProgramPeriod__r.Program__r.Name From ProgramQualification__c p where Employment__c =:emplnt.Id order by ProgramPeriod__r.Program__r.Id];
        emplnt2.Employment__r.EndDate__c = date.today().addYears(30);*/
        /*update emplnt;*/
        
         Area__c area = new Area__c(Name='United States (50 states and DC)', AreaDescriptionText__c ='Test Area');
        insert area;
        
        Agency__c Agcy = new Agency__c(Name='Test Agency');
        insert Agcy;
         Program__c prog = new Program__c(Name='Test Program');
        insert prog;
        
        ProgramPeriod__c prgperiod = new ProgramPeriod__c(Name='Test Program period',Program__c=prog.Id, Area__c=area.Id,Agency__c=Agcy.Id,StartDate__c=System.today().addDays(-40));
        insert prgperiod;
        
         ProgramQualification__c progQual = new ProgramQualification__c(Name='TestProgramQualification',Employment__c = emplnt.Id, ProgramPeriod__c = prgperiod.Id);
        insert progQual;
        
        DocumentStatus__c  dst  = new DocumentStatus__c  (Name = 'Good' , RankOrder__c = 1);
        Insert dst;
        
        
        DocumentStatus__c  dst1  = new DocumentStatus__c  (Name = 'Test' , RankOrder__c = 1);
        Insert dst1;
        
        
        Program__c pr = new Program__c(Name='TestProgram');
        insert pr;
        
        DocumentRequirement__c docReq = new DocumentRequirement__c(Name = 'Address Verification', Program__c = pr.Id );
        insert docReq ;
        
        QualificationDocumentRequirement__c qualReq = new QualificationDocumentRequirement__c(ProgramQualification__c = progQual.Id, DocumentRequirement__c = docReq.Id);
        insert qualReq;            

        
        DocumentStep__c docrolestep = new DocumentStep__c(Name ='docRoleStep' , DocumentRequirement__c  = docReq.Id);       
        insert docrolestep;
        
        QualificationDocumentStep__c quarolestep =new QualificationDocumentStep__c(DocumentStep__c = docrolestep.Id, QualificationDocumentRequirement__c = qualReq.Id);
        insert quarolestep;
        
        Documenttype__c doctype = new Documenttype__c(Name ='Form 8850',DocumentTypeAbbr__c ='F8850',Usage__c = 'Active',/*Source__c = 'Client',*/DocumentationStage__c = 'Prerequisite');
        insert doctype;
        System.assertEquals('Form 8850', [select name from Documenttype__c where id =:doctype.id ].Name);
        
        DocumentOption__c docOpt = new DocumentOption__c(DocumentStep__c= docrolestep.Id,DocumentType__c = doctype.Id);
        insert docOpt ;
         
         RepositoryDocument__c repDoc = new RepositoryDocument__c (Name ='Test 2',DocumentType__c =doctype.Id, LaserficheDocumentId__c = 6546575, Employment__c = emplnt.Id, DocumentStatus__c = dst.Id);
        // insert repDoc;
         
         QualificationDocumentOption__c Qdo = new QualificationDocumentOption__c( DocumentOption__c = docOpt.Id, QualificationDocumentStep__c = quarolestep.Id );
         insert Qdo;
         
         Documenttype__c doctype2 = new Documenttype__c(Name ='Form 8850',DocumentTypeAbbr__c ='F850',Usage__c = 'Active',/*Source__c = 'Client',*/DocumentationStage__c = 'Prerequisite');
         insert doctype2;
         
         RepositoryDocument__c repDoc2 = new RepositoryDocument__c(Name ='Test 1',DocumentType__c =doctype2.Id, LaserficheDocumentId__c = 654575, Employment__c = emplnt.Id, DocumentStatus__c = dst.Id);
         insert repDoc2;
         RepositoryDocument__c repDoc3 = new RepositoryDocument__c(Name ='Test 2',DocumentType__c =doctype2.Id, LaserficheDocumentId__c = 654575, Employment__c = emplnt.Id, DocumentStatus__c = dst.Id);
         insert repDoc3;
         
         test.starttest();
         repDoc2.DocumentType__c = doctype.Id;      
         update repDoc2;
         
         repDoc2.DocumentStatus__c = dst1.Id;
         update repDoc2;
         repDoc2.DocumentType__c = doctype2.Id;      
         update repDoc2;
          
         repDoc.LaserficheDocumentId__c = 654575;      
         update repDoc2;
              
         DocumentStatus__c  dst2  = [select Id from DocumentStatus__c where RankOrder__c = 3];           
         Qdo.DocumentStatusGenerated__c = dst2.Id;
         update Qdo;
         dst1.DocumentStatusEID__c = 1;
         
         //DocumentStatus__c dsG = [select DocumentStatusEID__c from DocumentStatus__c where DocumentStatusEID__c =1 limit 1];
         //quarolestep.DocumentStatus__c = dsG.id;
         //update quarolestep;
         
				delete quarolestep;
         test.stoptest();
         
    } 
}