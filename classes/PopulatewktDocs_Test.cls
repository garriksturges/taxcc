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
private class PopulatewktDocs_Test {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        /*
        User u = [Select Id from User where IsActive = true AND Profile.Name = 'System Administrator' limit 1];
        
        System.runAs(u){
            
        
        Test.startTest();
         Program__c programRecord = [Select Name, Id,(Select Id, Name, ProgramCategoryCode__c, ProgramCategoryEId__c From ProgramCategories__r where ProgramCategoryEId__c = 73.0),(Select Id, Name, EndDate__c, StartDate__c, Program__c From ProgramPeriods__r) From Program__c where Name = 'Work Opportunity Tax Credit'];
        
        
        Account  accountRecord = new Account();
        accountRecord.Name = 'TEST ACCOUNT';
        insert accountRecord;

        Country__c countryRecord=new Country__c(Name = 'TEST COUNTRY');
        insert  countryRecord;

        State__c stateRecord=new State__c(Country__c=countryRecord.Id, StateAbbr__c='TT');
        insert stateRecord;

        County__c countyRecord=new County__c(State__c=stateRecord.Id, Name='TEST COUNTY');
        insert countyRecord;
        
        Entity__c entityRecord = new Entity__c(Name='TEST ENTITY', Account__c = accountRecord.Id);
        insert entityRecord;
        
        Location__c locationRecord = new Location__c(Account__c = accountRecord.Id, Name='TEST LOCATION', StreetAddressText__c='1212 Main St.', CityName__c='SAN DIEGO', State__c=stateRecord.Id, ZipCode__c='92115');
        insert locationRecord;
        
        EntityLocation__c entityLocationRecord = new EntityLocation__c(Entity__c=entityRecord.id, Location__c=locationRecord.id);
        insert entityLocationRecord;
        
        Employee__c employeeRecord=new Employee__c(Account__c=accountRecord.id, BirthDate__c= date.today().addYears(-30), Email__c='test@test.com', LastName__c='test', FirstName__c='test', SSN__c='555125555');
        insert employeeRecord;

        EmployeeAddress__c employeeAddressRecord=new EmployeeAddress__c();
        employeeAddressRecord.CityName__c='TEST CITY';
        employeeAddressRecord.CountyName__c=countyRecord.Id;
        employeeAddressRecord.Latitude__c=-34.1212121212;
        employeeAddressRecord.Longitude__c=100.1414141414;
        employeeAddressRecord.StreetAddressText__c='TEST STREET';
        employeeAddressRecord.StateName__c=stateRecord.Id;
        employeeAddressRecord.EmployeeId__c=employeeRecord.Id;
        employeeAddressRecord.ZipCode__c='92115';
        
        insert employeeAddressRecord;
        
        Area__c areaRecord=new Area__c(Name='TEST AREA', AcreageAmount__c=100, AreaDescriptionText__c='test', AreaDefinitionMethod__c = 'State/Province');
        insert areaRecord;

        AreaState__c areaStateRecord=new AreaState__c(Area__c=areaRecord.Id, State__c=stateRecord.Id);
        insert areaStateRecord;
        
                
        ProgramCategory__c programCategoryRecord=new ProgramCategory__c(Program__c=programRecord.Id, ProgramCategoryEID__c = 666666);
        insert programCategoryRecord;
 
        ProgramPeriod__c programPeriodRecord=new ProgramPeriod__c(Program__c=programRecord.Id, Area__c=areaRecord.Id, EndDate__c=Date.today().addYears(20), StartDate__c=Date.today().addYears(-20));
        insert programPeriodRecord;
        
        ProgramCategoryPeriod__c programCatPeriodRecord=new ProgramCategoryPeriod__c(ProgramCategory__c=programCategoryRecord.Id, Area__c=areaRecord.Id, StartDate__c=Date.today().addYears(-20), EndDate__c = Date.today().addYears(20));
        insert programCatPeriodRecord;
 
        Employment__c employmentRecord=new Employment__c(Employee__c = employeeRecord.Id, Entity__c = entityRecord.Id, Location__c = locationRecord.Id, StartDate__c = Date.today(), InitialHourlyRateAmount__c = 10.00);
        insert employmentRecord;        
                
        EmployeeSurvey__c employeeSurveyRecord=new EmployeeSurvey__c(EmploymentPeriod__c=employmentRecord.Id, EntityLocation__c = entityLocationRecord.Id, SurveyDate__c = Datetime.now());
        insert employeeSurveyRecord;
        
         ProgramQualification__c progQual = new ProgramQualification__c(Name='TestProgramQualification',Employment__c = employmentRecord.Id, ProgramPeriod__c = programPeriodRecord.Id);
        insert progQual;
                
        
        ProgramCategoryQualification__c pcq = new ProgramCategoryQualification__c(ProgramCategoryPeriod__c = programCatPeriodRecord.Id, ProgramQualification__c = progQual.Id); 
        insert pcq;
        
        System.debug('progQual.Employment__r.Employee__c:::'+progQual.Employment__r.Employee__c);
        
        Populate8850 pop = new Populate8850();
        pop.CreatewktDoc8850(progQual);
        
        
        Test.stopTest();
        
        }
        */
    }
}