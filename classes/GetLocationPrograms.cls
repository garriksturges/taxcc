global class GetLocationPrograms implements Process.Plugin{

    global Process.PluginResult invoke(Process.PluginRequest request){
        
        String entityLocationId = (String)request.inputParameters.get('EntityLocationId');          
        String employeeSurveyId = (String)request.inputParameters.get('EmployeeSurveyId');           
                
        Map<String, Object> result = new Map<String, Object>();
        
        EmployeeSurvey__c es = [select Id, ReportedHireDate__c from EmployeeSurvey__c where Id =:employeeSurveyId];
        Date hireDate = es.ReportedHireDate__c ;
        
        List<Program__c> progList = [SELECT Id, ProgramEID__c, (select Program__c from LocationProgramLaunches__r where Location__c in(select Location__c from EntityLocation__c where Id =:entityLocationId) and (StartDate__c <=:hireDate or StartDate__c >=:hireDate or StartDate__c = null) and (EndDate__c >=:hireDate or EndDate__c <=:hireDate or EndDate__c = null)) FROM Program__c];
                
        for(Program__c prog : progList)
        {
            String varName = 'ProgramId' + prog.ProgramEID__c;
            
            
            if(prog.LocationProgramLaunches__r.size() > 0)
            {
                List<SurveyProgramScreened__c> existingScreened = [select Id from SurveyProgramScreened__c where Survey__c =:employeeSurveyId and Program__c =:prog.Id];
                
                if(existingScreened.size() == 0)
                {
                    SurveyProgramScreened__c programScreened = new SurveyProgramScreened__c(Survey__c = employeeSurveyId, Program__c = prog.Id);
                    insert programScreened;
                }
                
                result.put(varName,'Yes');                       
                    
            }
            else
            {
                result.put(varName,'No');
            }
        }
        
        return new Process.PluginResult(result);    
    }
    
    global Process.PluginDescribeResult describe(){
        
        Process.PluginDescribeResult  result = new Process.PluginDescribeResult();
        
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter('EntityLocationId', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('EmployeeSurveyId', Process.PluginDescribeResult.ParameterType.STRING, true)
        };
        
        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>{
            new Process.PluginDescribeResult.OutputParameter('ProgramId1', Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('ProgramId2', Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('ProgramId3', Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('ProgramId4', Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('ProgramId5', Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('ProgramId6', Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('ProgramId7', Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('ProgramId8', Process.PluginDescribeResult.ParameterType.STRING),                                    
            new Process.PluginDescribeResult.OutputParameter('ProgramId9', Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('ProgramId10', Process.PluginDescribeResult.ParameterType.STRING),            
            new Process.PluginDescribeResult.OutputParameter('ProgramId11', Process.PluginDescribeResult.ParameterType.STRING),   
            new Process.PluginDescribeResult.OutputParameter('ProgramId12', Process.PluginDescribeResult.ParameterType.STRING),  
            new Process.PluginDescribeResult.OutputParameter('ProgramId13', Process.PluginDescribeResult.ParameterType.STRING),    
            new Process.PluginDescribeResult.OutputParameter('ProgramId14', Process.PluginDescribeResult.ParameterType.STRING),    
            new Process.PluginDescribeResult.OutputParameter('ProgramId15', Process.PluginDescribeResult.ParameterType.STRING),    
            new Process.PluginDescribeResult.OutputParameter('ProgramId16', Process.PluginDescribeResult.ParameterType.STRING),    
            new Process.PluginDescribeResult.OutputParameter('ProgramId17', Process.PluginDescribeResult.ParameterType.STRING),    
            new Process.PluginDescribeResult.OutputParameter('ProgramId18', Process.PluginDescribeResult.ParameterType.STRING),    
            new Process.PluginDescribeResult.OutputParameter('ProgramId19', Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('ProgramId21', Process.PluginDescribeResult.ParameterType.STRING)    
        };
        
        return result;
            
    }
}