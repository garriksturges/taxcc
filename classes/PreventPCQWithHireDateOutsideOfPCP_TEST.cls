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
 private class PreventPCQWithHireDateOutsideOfPCP_TEST{
 private static Account Acc;
 private static Entity__c Ent;
 private static Employee__c Emp;
 private static Employment__c Empperiod;
 private static Program__c Prgm;
 private static Area__c Area;
 private static Agency__c Agcy;
 private static ProgramPeriod__c prgp;
 private static ProgramQualification__c prgqual;
 private static Name Name;
 private static Location__c Loc;
 private static EntityLocation__c  EntityLoc;
 private static EmployeeSurvey__c Empsurvy;
 private static ProgramCategory__c Prgcat;
 private static ProgramCategoryPeriod__c prgcatpriod; 
 private static ProgramCategoryQualification__c prgcatqual;
 private static EmployeeSurvey__c Empsury;
 //private static Survey__c survy;

  static{
  Acc=new Account(Name ='TestAccForEmpPeriod',Type='Press',Phone='510-222-9999',Website='www.taxcreditco.com',BillingState ='CA',BillingPostalCode='23451',BillingStreet='South BurnSide Avenue',BillingCity='Park Labrea',BillingCountry='USA');
  insert Acc;
  
  Ent=new Entity__c(Name='Target',Account__c=Acc.Id);
  insert Ent;
  
  Loc=new Location__c(Account__c=Acc.Id,Name='TestLocation',StreetAddressText__c='Test street Address',CityName__c='Richmond',ZipCode__c='89912');
  insert Loc;
  
  EntityLoc=new EntityLocation__c(Name='TestEnityLocation',Entity__c=Ent.Id,Location__c=Loc.Id);
  insert EntityLoc;
  
  Emp=new Employee__c(FirstName__c='Steve',LastName__c='Johnson',MiddleName__c='Rojer',ClientEmployeeID__c='2312111',SSN__c='239121228',Account__c=Acc.Id);
  insert Emp;
  
  Empperiod=new Employment__c(Entity__c=Ent.Id,Employee__c=Emp.Id,Location__c=Loc.Id,StartDate__c=system.today().addDays(-20),EndDate__c=system.today().addDays(-2));
  insert Empperiod;
  
   Empsury=new EmployeeSurvey__c(Name='TestEmploysurvy',EmploymentPeriod__c=Empperiod.Id,EntityLocation__c=EntityLoc.Id,SurveySource__c='Email',ReportedHireDate__c=system.today().addDays(-5));
   insert Empsury;
   
  Prgm=new Program__c(Name='TestProgram', ShortName__c='TP');
  insert Prgm;
  
  Area=new Area__c(Name='Fremont',AreaDefinitionMethod__c='Country');
  insert Area;
    
  Agcy=new Agency__c(Name='Test Agency Name',SignatoryName__c='Test George',AgencyEmail__c='Test.vonhoff@myflorida.com',VoucherChargeEffectiveDate__c=System.today().addDays(-4));
  insert Agcy;
  
  //survy=new Survey__c(Name='TestSurveyName');
  //insert survy;   
  
  prgp=new ProgramPeriod__c(Name='Test1991',Program__c=Prgm.Id,Area__c=Area.Id,Agency__c=Agcy.Id,StartDate__c=System.today().addDays(-40),EndDate__c=System.today().addDays(-15));
  insert prgp;
  
  QualificationProcessStage__c qps = [select Id from QualificationProcessStage__c where QualificationProcessStageEID__c = 8];
  prgqual=new  ProgramQualification__c(Name='TestProgramQualification96051', ProcessStage__c = qps.Id, Employment__c=Empperiod.Id,ProgramPeriod__c=prgp.Id,EffectiveDate__c=System.today().addDays(-11),Survey__c=Empsury.Id);
  insert prgqual;
  
  Prgcat=new ProgramCategory__c(Name='Test Program Category',Program__c=Prgm.Id,ProgramCategoryCode__c='2345123');
  insert Prgcat;
  
  prgcatpriod=new ProgramCategoryPeriod__c(Name='TestPQ9999',ProgramCategory__c=Prgcat.Id,Area__c=Area.Id,StartDate__c=System.today().addDays(-30),EndDate__c=System.today().addDays(-10));
  insert prgcatpriod;

    
  }
  
  static testmethod void PreventPCQWithHireDateOutsideOfPCP(){
  
  ProgramCategoryQualification__c Prgcatqualification=new ProgramCategoryQualification__c();
  Prgcatqualification.ProgramCategoryPeriod__c=prgcatpriod.Id;
  Prgcatqualification.ProgramQualification__c=prgqual.Id;
  Prgcatqualification.ReadinessDate__c=System.today().addDays(-10);
 
   Insert Prgcatqualification;
   update Loc;
   update Empperiod;
   update prgp;
   update prgqual;
   update Prgcat;
   update prgcatpriod;
   update Prgcatqualification;
   delete Prgcatqualification;
      
  } 
 }