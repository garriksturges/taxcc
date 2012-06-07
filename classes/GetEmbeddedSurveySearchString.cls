global class GetEmbeddedSurveySearchString implements Process.Plugin{

    global Process.PluginResult invoke(Process.PluginRequest request){
    
        Decimal accountEID = (Decimal)request.inputParameters.get('AccountEID');
        String five9SessionID = (String)request.inputParameters.get('Five9SessionID');
        
        String resultString = '/apex/CallCenterScreenEmployeeEmbedded?VarAccountEID=' + String.valueOf(accountEID) + '&Five9SessionID=' + five9SessionID;
        
       
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('Result', resultString);
        
        return new Process.PluginResult(result);    
    }
    
    global Process.PluginDescribeResult describe(){
        
        Process.PluginDescribeResult  result = new Process.PluginDescribeResult();
        
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter('AccountEID', Process.PluginDescribeResult.ParameterType.DECIMAL, true),
            new Process.PluginDescribeResult.InputParameter('Five9SessionID', Process.PluginDescribeResult.ParameterType.STRING, false)
          };
        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>{
            new Process.PluginDescribeResult.OutputParameter('Result', Process.PluginDescribeResult.ParameterType.STRING)
        };
        
        return result;
            
    }    

    public static testMethod void GetAge_TEST(){
        GetEmbeddedSurveySearchString controller = new GetEmbeddedSurveySearchString(); 
        Map<String,Object> inputParams = new Map<String,Object>();
        
        Decimal accountEID = 2874;
        String five9sessionId = '456321789';
        
        InputParams.put('AccountEID', accountEID);
        InputParams.put('Five9SessionID', five9sessionId);
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);      
        try
        {   
         	Process.PluginResult result = controller.invoke(request);
         	Map<String, Object> returnMap = result.outputParameters;
         	String resultString = String.valueOf(returnMap.get('Result'));
         	
         	System.debug('Hello' + resultString);
         	system.assert(resultString != '');
         	
         	controller.describe();
        }
        catch(Exception e)
        {
            e.getMessage();
        }
    }    
}