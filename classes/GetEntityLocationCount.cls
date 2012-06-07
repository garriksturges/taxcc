global class GetEntityLocationCount implements Process.Plugin{

    global Process.PluginResult invoke(Process.PluginRequest request){
    
        String locationRecord = (String)request.inputParameters.get('LocationRecord');
        Decimal entityLocationEID = 0;
        Integer entityLocationCount = 0;
        String entityLocationSFID = '';
        
       	entityLocationCount = [select count() from EntityLocation__c where Location__c =:locationRecord]; 
       	
       	if(entityLocationCount == 1)
       	{
       		EntityLocation__c entityLocation = [select Id, EntityLocationEID__c from EntityLocation__c where Location__c =:locationRecord limit 1];       		
       		
       		entityLocationEID = entityLocation.EntityLocationEID__c;
       		entityLocationSFID = entityLocation.Id;
       	}     
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('EntityLocationCount', entityLocationCount);
        result.put('EntityLocationEID', entityLocationEID);
        result.put('EntityLocationSFID', entityLocationSFID);
        
        return new Process.PluginResult(result);    
    }
    
    global Process.PluginDescribeResult describe(){
        
        Process.PluginDescribeResult  result = new Process.PluginDescribeResult();
        
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter('LocationRecord', Process.PluginDescribeResult.ParameterType.STRING, true)
        };
        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>{
            new Process.PluginDescribeResult.OutputParameter('EntityLocationCount', Process.PluginDescribeResult.ParameterType.INTEGER),
            new Process.PluginDescribeResult.OutputParameter('EntityLocationEID', Process.PluginDescribeResult.ParameterType.DECIMAL),
            new Process.PluginDescribeResult.OutputParameter('EntityLocationSFID', Process.PluginDescribeResult.ParameterType.STRING)
        };
        
        return result;
            
    }
    
   public static testMethod void GetEntityLocationCount_TEST()
   {
   		Account a;
   		Location__c l;
   		Entity__c ent;
   		EntityLocation__c el;
   		 
  		a = new Account();
	   	a.Name = 'testa';
	   	insert a;
	    	
    	
		l = new Location__c();
	    l.Account__c = a.id;
	    l.Name = 'test';
	    	
	    ent = new Entity__c();
	    ent.Account__c = a.id;
	    ent.Name = 'test';
	    insert ent;
	    	
	    el = new EntityLocation__c();
	    el.Entity__c = ent.id;
	    el.Location__c = l.id;
        
        test.startTest();
        
	        GetEntityLocationCount plugin = new GetEntityLocationCount();
	        Map<String,Object> inputParams = new Map<String,Object>();
	
	        InputParams.put('LocationRecord', l.id);        
	
	        Process.PluginRequest request = new Process.PluginRequest(inputParams);           
	        
	        plugin.invoke(request);
	        
	        plugin.describe();
        
        test.stopTest();
    }
}