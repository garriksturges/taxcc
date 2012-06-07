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
private class PreventDuplicateProgramPeriod_TEST{

private static Program__c Prgm;
private static Area__c Area;
private static Agency__c Agcy;
private static ProgramPeriod__c prgp;

  static{
  Prgm=new Program__c(Name='TestProgram', ShortName__c='TP');
  insert Prgm;
  
  Area=new Area__c(Name='Fremont',AreaDefinitionMethod__c='Country');
  insert Area;
    
  Agcy=new Agency__c(Name='Test Agency Name',SignatoryName__c='Test George',AgencyEmail__c='Test.vonhoff@myflorida.com');
  insert Agcy;
    
  prgp=new ProgramPeriod__c(Name='Test1991',Program__c=Prgm.Id,Area__c=Area.Id,Agency__c=Agcy.Id,StartDate__c=Date.today());
  insert prgp;
  }

  static testmethod void preventProgramPeriodDup(){
  ProgramPeriod__c ProgramPeriod=new ProgramPeriod__c();
  date startdate= date.parse('1/25/2010');
  ProgramPeriod.Program__c=Prgm.Id;
  ProgramPeriod.Area__c=Area.Id;
  ProgramPeriod.Agency__c=Agcy.Id;
  ProgramPeriod.StartDate__c=startdate;
  
  insert ProgramPeriod;
  //update ProgramPeriod;
  
  }
}