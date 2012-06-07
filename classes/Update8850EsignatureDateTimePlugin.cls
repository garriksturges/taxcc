global class Update8850EsignatureDateTimePlugin implements Process.Plugin{

    global Process.PluginResult invoke(Process.PluginRequest request){
    
        String employeeSurveyId = (String)request.inputParameters.get('EmployeeSurveyId');
        String stringDateTime = (String)request.inputParameters.get('StringDateTime');
        
        DateTime currentDateTime = DateTime.parse(stringDateTime);
        
        wktDocument8850__c es = [select Id, ElectronicSignatureDateTime__c from wktDocument8850__c where EmployeeSurvey__c=:employeeSurveyId];
        es.ElectronicSignatureDateTime__c = currentDateTime;
        update es;        
        
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('Result', 'Success');
        
        return new Process.PluginResult(result);    
    }
    
    global Process.PluginDescribeResult describe(){
        
        Process.PluginDescribeResult  result = new Process.PluginDescribeResult();
        
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter('StringDateTime', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('EmployeeSurveyId', Process.PluginDescribeResult.ParameterType.STRING, true)
        };
        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>{
            new Process.PluginDescribeResult.OutputParameter('Result', Process.PluginDescribeResult.ParameterType.STRING)
        };
        
        return result;
            
    }
}