global class GetAge implements Process.Plugin{

    global Process.PluginResult invoke(Process.PluginRequest request){
    
        Datetime parsedDate = (Datetime)request.inputParameters.get('Birthday');
        Datetime hireDate = (Datetime)request.inputParameters.get('HireDate');
        
        Date hireDateOnly;
        
        if(hireDate != null)
        {
			hireDateOnly = Date.valueOf(hireDate);        		
        }  
        
        Date dateOnly = Date.valueOf(parsedDate);            
        Integer daysBetween;
        
        if(hireDateOnly != null)
        {
        	daysBetween = dateOnly.daysBetween(hireDateOnly);
        }
        else
        {
        	daysBetween = dateOnly.daysBetween(date.today());
        }        
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('DaysBetween', daysBetween);
        
        return new Process.PluginResult(result);    
    }
    
    global Process.PluginDescribeResult describe(){
        
        Process.PluginDescribeResult  result = new Process.PluginDescribeResult();
        
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter('Birthday', Process.PluginDescribeResult.ParameterType.DATETIME, true),
            new Process.PluginDescribeResult.InputParameter('HireDate', Process.PluginDescribeResult.ParameterType.DATETIME, false)
          };
        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>{
            new Process.PluginDescribeResult.OutputParameter('DaysBetween', Process.PluginDescribeResult.ParameterType.INTEGER)
        };
        
        return result;
            
    }    

    public static testMethod void GetAge_TEST(){
        GetAge controller = new GetAge(); 
        Map<String,Object> inputParams = new Map<String,Object>();
        
        Date birthday = date.newInstance(1975, 9, 24);
        Date hiredate = date.newInstance(1995, 12, 1);
        
        InputParams.put('Birthday', birthday);
        InputParams.put('HireDate', hiredate);
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);      
        try
        {   
         	Process.PluginResult result = controller.invoke(request);
         	Map<String, Object> returnMap = result.outputParameters;
         	integer daysbetween = integer.valueOf(returnMap.get('DaysBetween'));
         	
         	System.debug('Hello' + string.valueOf(daysbetween));
         	system.assert(daysbetween == 7373);
         	
         	controller.describe();
        }
        catch(Exception e)
        {
            e.getMessage();
        }
    }    
}