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
private class PreventPQWithHireDateOutsideOfPP_TEST{
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
//private static Survey__c survy;

  static{
  Acc=new Account(Name ='TestAccForEmpPeriod',Type='Press',Phone='510-222-9999',Website='www.taxcreditco.com',BillingState ='CA',BillingPostalCode='23451',BillingStreet='South BurnSide Avenue',BillingCity='Park Labrea',BillingCountry='USA');
  insert Acc;
  
  Ent=new Entity__c(Name='Target',Account__c=Acc.Id);
  insert Ent;
  
  Emp=new Employee__c(FirstName__c='Steve',LastName__c='Johnson',MiddleName__c='Rojer',ClientEmployeeID__c='2312111',SSN__c='239121228',Account__c=Acc.Id);
  insert Emp;
  
  Empperiod=new Employment__c(Entity__c=Ent.Id,StartDate__c=System.today().addDays(-25),Employee__c=Emp.Id);
  insert Empperiod;
  
  Prgm=new Program__c(Name='TestProgram', ShortName__c='TP');
  insert Prgm;
  
  Area=new Area__c(Name='Fremont',AreaDefinitionMethod__c='Country');
  insert Area;
    
  Agcy=new Agency__c(Name='Test Agency Name',SignatoryName__c='Test George',AgencyEmail__c='Test.vonhoff@myflorida.com');
  insert Agcy;
    
  prgp=new ProgramPeriod__c(Name='Test1991',Program__c=Prgm.Id,Area__c=Area.Id,Agency__c=Agcy.Id,StartDate__c=System.today().addDays(-45));
  insert prgp;
  
  //survy=new Survey__c(Name='TestSurveyName');
  //insert survy;   
  }
  
  static testmethod void PreventPQWithHireDateOutsideOfPP(){
  ProgramQualification__c PrgQualification=new ProgramQualification__c();
  //date Qualificationdate=date.parse('10/30/2011');
  PrgQualification.Name='TestProgramQualification';
  PrgQualification.Employment__c=Empperiod.Id;
  PrgQualification.ProgramPeriod__c=prgp.Id;
  //PrgQualification.Survey__c=survy.Id;
  PrgQualification.EffectiveDate__c=System.today().addDays(-15);
    
  
  insert PrgQualification;
  update PrgQualification;
  
  }
  }