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
private class SaveEmployeeInformationPlugin_test {
		Account a;
		Location__c l;
		Entity__c ent;
		FlowSession__c fl;
    public void makeData(){
    	a = new Account();
    	a.Name = 'testa';
    	insert a;
    	
    	ent = new Entity__c();
    	ent.Account__c = a.id;
    	ent.Name = 'test';
    	insert ent;
    	
      l = new Location__c();
    	l.Account__c = a.id;
    	l.Name = 'test';
    	insert l;
    	
    	fl = new FlowSession__c();
    	fl.DescriptionText__c = 'sdlfkjsdlfkjsdlkfjsdf';
    	insert fl;
    }
    static testMethod void myUnitTest() {
    		SaveEmployeeInformationPlugin_test t = new SaveEmployeeInformationPlugin_test();
    		t.makeData();
    		
        SaveEmployeeInformationPlugin plugin = new SaveEmployeeInformationPlugin();
        Map<String,Object> inputParams = new Map<String,Object>();
				
				//String AccountId = (String)request.inputParameters.get('AccountId');
        inputParams.put('AccountId', t.a.id);
        
        //String EntityId = (String)request.inputParameters.get('EntityId');
        inputParams.put('EntityId', t.ent.id);
        
        //String LocationId = (String)request.inputParameters.get('LocationId');
        inputParams.put('LocationId', t.l.id);
        
        //String FirstName = (String)request.inputParameters.get('FirstName');
        inputParams.put('FirstName', 'ARF');
        
        //String MiddleName = (String)request.inputParameters.get('MiddleName');
        inputParams.put('MiddleName', 'ARF');
        
        //String LastName = (String)request.inputParameters.get('LastName');
        inputParams.put('LastName', 'ARF');
        
        //Date Birthday = Date.valueOf((Datetime)request.inputParameters.get('Birthday'));
        inputParams.put('Birthday', Datetime.now().addYears(-32));
        
        //String SSN = (String)request.inputParameters.get('SSN');
        inputParams.put('SSN', '123-34-1234');
        
        //String SessionId  = (String)request.inputParameters.get('SessionId');
        inputParams.put('SessionId', t.fl.id);
        
        //String Street = (String)request.inputParameters.get('Street');
        inputParams.put('Street', '123 happy dr.');
        
        //String City = (String)request.inputParameters.get('City');
        inputParams.put('City', 'New York');
        
        //String State = (String)request.inputParameters.get('State');
       	inputParams.put('State', null);
       	
        //String ZipCode = (String)request.inputParameters.get('ZipCode');
        inputParams.put('ZipCode', '94123');
        
        //String County = (String)request.inputParameters.get('County');
        inputParams.put('County', null);
        
        //Decimal Latitude = (Decimal)request.inputParameters.get('Latitude');
        inputParams.put('Latitude', 79.79);
        
        //Decimal Longitude = (Decimal)request.inputParameters.get('Longitude');
        inputParams.put('Longitude', 79.79);
        
        //Date HireDate = Date.valueOf((Datetime)request.inputParameters.get('HireDate'));
        inputParams.put('HireDate', Datetime.now().addYears(-2));
        
        //Decimal HourlyWage = (Decimal)request.inputParameters.get('HourlyWage');
        inputParams.put('HourlyWage', 42);
        
        //String JobTitle = (String)request.inputParameters.get('JobTitle');
        inputParams.put('JobTitle', 'arfer');
        
        //String Department = (String)request.inputParameters.get('Department');
        inputParams.put('Department', 'arfer');

        Process.PluginRequest request = new Process.PluginRequest(inputParams);           
        
        plugin.invoke(request);
        plugin.describe();
    }
}