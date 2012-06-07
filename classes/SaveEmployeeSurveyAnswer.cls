global class SaveEmployeeSurveyAnswer implements Process.Plugin{
     
    global Process.PluginResult invoke(Process.PluginRequest request){
        String employeeSurveyId = (String)request.inputParameters.get('EmployeeSurveyId');  
        Decimal surveyQuestionEid = Decimal.valueOf((String)request.inputParameters.get('SurveyQuestionEID'));  
        String textAnswer = (String)request.inputParameters.get('TextAnswer');
        Datetime datetimeAnswer = (Datetime)request.inputParameters.get('DateAnswer');                   
        Decimal numericAnswer = (Decimal)request.inputParameters.get('NumericAnswer');
        Boolean isBlankAnswer = false;          
        Date dateAnswer;
        
        
       
        
        if(datetimeAnswer != null)
        {
            dateAnswer = Date.valueOf(datetimeAnswer);
        }
        
        Map<String, Object> result = new Map<String, Object>();
                  
        if(textAnswer == null && dateAnswer == null && numericAnswer == null)
        {
            isBlankAnswer = true;
        } 
        else if(textAnswer != null && textAnswer.trim() == '' && dateAnswer == null && numericAnswer == null)
        {
            isBlankAnswer = true;
        }  

                      
        SurveyQuestion__c surveyQuestion = [select Id from SurveyQuestion__c where QuestionEID__c =:surveyQuestionEid];
                               
        if(!isBlankAnswer)      
        {
            List<EmployeeSurveyAnswer__c> existingAnswer = [select Id, EmployeeSurveyAnswerDate__c, EmployeeSurveyAnswerAmount__c, EmployeeSurveyAnswerText__c from EmployeeSurveyAnswer__c where EmployeeSurvey__c=:employeeSurveyId and SurveyQuestion__c =:surveyQuestion.Id];
            
            if(existingAnswer == null || existingAnswer.size() == 0)
            {
            
                EmployeeSurveyAnswer__c empSurvey = new EmployeeSurveyAnswer__c(EmployeeSurvey__c = employeeSurveyId, SurveyQuestion__c = surveyQuestion.Id, EmployeeSurveyAnswerDate__c = dateAnswer, EmployeeSurveyAnswerAmount__c = numericAnswer, EmployeeSurveyAnswerText__c = textAnswer);       
            
                insert empSurvey;
            }
            else
            {
                for(EmployeeSurveyAnswer__c esa: existingAnswer)
                {
                    esa.EmployeeSurveyAnswerDate__c = dateAnswer;
                    esa.EmployeeSurveyAnswerAmount__c = numericAnswer;
                    esa.EmployeeSurveyAnswerText__c = textAnswer;
                }                    
                
                update existingAnswer;
            }
            
            result.put('Result','Success');
        }                      
        else
        {
            result.put('Result', 'Success');
        }
        
        return new Process.PluginResult(result);  
    }
    
    global Process.PluginDescribeResult describe(){
        
        Process.PluginDescribeResult  result = new Process.PluginDescribeResult();
        
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter('EmployeeSurveyId', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('SurveyQuestionEID', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('TextAnswer', Process.PluginDescribeResult.ParameterType.STRING, false),
            new Process.PluginDescribeResult.InputParameter('DateAnswer ', Process.PluginDescribeResult.ParameterType.DATETIME, false),
            new Process.PluginDescribeResult.InputParameter('BooleanAnswer ', Process.PluginDescribeResult.ParameterType.BOOLEAN, false),
            new Process.PluginDescribeResult.InputParameter('NumericAnswer', Process.PluginDescribeResult.ParameterType.DECIMAL, false)
        };
        
        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>{
            new Process.PluginDescribeResult.OutputParameter('Result', Process.PluginDescribeResult.ParameterType.STRING)
        };
        
        return result;
            
    }
}