@isTest
private class SaveProgramCategoryQualification_TEST{

    static testMethod void SaveProgramCategorytest()  
    {
    	/*
        SaveProgramCategoryQualification saveProgramCatQual=new SaveProgramCategoryQualification();
    
 
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
        employeeAddressRecord.County__c=countyRecord.Id;
        employeeAddressRecord.Latitude__c=-34.1212121212;
        employeeAddressRecord.Longitude__c=100.1414141414;
        employeeAddressRecord.StreetAddressText__c='TEST STREET';
        employeeAddressRecord.State__c=stateRecord.Id;
        employeeAddressRecord.Employee__c=employeeRecord.Id;
        employeeAddressRecord.ZipCode__c='92115';
        
        insert employeeAddressRecord;
        
        Area__c areaRecord=new Area__c(Name='TEST AREA', AcreageAmount__c=100, AreaDescriptionText__c='test', AreaDefinitionMethod__c = 'State/Province');
        insert areaRecord;

        AreaState__c areaStateRecord=new AreaState__c(Area__c=areaRecord.Id, State__c=stateRecord.Id);
        insert areaStateRecord;
        
        
        
        Program__c programRecord = new Program__c(Name='TEST PROGRAM');
        insert programRecord;
        
        ProgramCategory__c programCategoryRecord=new ProgramCategory__c(Program__c=programRecord.Id, ProgramCategoryEID__c = 666666);
        insert programCategoryRecord;
 
        ProgramPeriod__c programPeriodRecord=new ProgramPeriod__c(Program__c=programRecord.Id, Area__c=areaRecord.Id, EndDate__c=Date.today().addYears(20), StartDate__c=Date.today().addYears(-20));
        insert programPeriodRecord;
        
        ProgramCategoryPeriod__c programCatPeriodRecord=new ProgramCategoryPeriod__c(ProgramCategory__c=programCategoryRecord.Id, Area__c=areaRecord.Id, StartDate__c=Date.today().addYears(-20), EndDate__c = Date.today().addYears(20));
        insert programCatPeriodRecord;
 
        Employment__c employmentRecord=new Employment__c(Employee__c = employeeRecord.Id, Entity__c = entityRecord.Id, Location__c = locationRecord.Id, StartDate__c = Date.today(), InitialHourlyRateAmount__c = 10.00);
        insert employmentRecord;
        
        Entity__c ent = new Entity__c(Account__c = a.Id, Name = 'TestEntity');
        insert ent;
        
         Location__c loc = new Location__c(Name= 'Test Location',StreetAddressText__c ='StrtAddress', CityName__c='XYZ', State__c = State.Id, ZipCode__c = '67542');
        insert loc;
        
        EntityLocation__c entLoc = new EntityLocation__c(Entity__c =ent.Id, Name='Ent Location', Location__c = loc.Id);
        insert entLoc;       
       
        
        EmployeeSurvey__c employeeSurveyRecord=new EmployeeSurvey__c(EmploymentPeriod__c=employmentRecord.Id, EntityLocation__c = entityLocationRecord.Id, SurveyDate__c = Datetime.now());
        insert employeeSurveyRecord;

        Map<String,Object> inputParams = new Map<String,Object>();
        
        InputParams.put('EmployeeSurveyRecord', employeeSurveyRecord.Id);
        InputParams.put('ProgramCategoryEID', 666666);
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);      
        try
        {
            //saveProgramCatQual.invoke(request);
            
            LocationArea__c locArea = new LocationArea__c(Location__c = locationRecord.Id, Area__c=areaRecord.Id);
            insert locArea;
            
            EmployeeAddressArea__c empAddArea = new EmployeeAddressArea__c(Area__c = areaRecord.Id, EmployeeAddress__c = employeeAddressRecord.Id);
            insert empAddArea;
            
            //saveProgramCatQual.invoke(request);
        }
        catch(Exception e)
        {
            e.getMessage();
        }
        
        saveProgramCatQual.describe();
        */
    }
    
 }