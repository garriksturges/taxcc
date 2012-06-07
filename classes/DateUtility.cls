global class DateUtility implements Process.Plugin{

    global Process.PluginResult invoke(Process.PluginRequest request){
    
        Datetime parsedDate = (Datetime)request.inputParameters.get('DateToParse');
        Integer daysOrMonthsToAdd = integer.valueOf((String)request.inputParameters.get('DaysOrMonthsToAdd'));
        String daysOrMonths = (String)request.inputParameters.get('DaysOrMonths');
        DateTime currentDateTime = DateTime.now();
        String stringCurrentDateTime = currentDateTime.format();
        
        Datetime newDate = null;        
        
        if(daysOrMonths == 'Days')
        {
            newDate = parsedDate.addDays(daysOrMonthsToAdd );        
        }
        else
        {
            newDate = parsedDate.addMonths(daysOrMonthsToAdd );
        }
        
        String newDateString = newDate.format('MMMMM, yyyy');
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('ModifiedDate', newDateString);
        result.put('CurrentDateTime', stringCurrentDateTime);
        
        return new Process.PluginResult(result);    
    }
    
    global Process.PluginDescribeResult describe(){
        
        Process.PluginDescribeResult  result = new Process.PluginDescribeResult();
        
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter('DateToParse', Process.PluginDescribeResult.ParameterType.DATETIME, true),
            new Process.PluginDescribeResult.InputParameter('DaysOrMonthsToAdd', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('DaysOrMonths', Process.PluginDescribeResult.ParameterType.STRING, true)
        };
        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>{
            new Process.PluginDescribeResult.OutputParameter('ModifiedDate', Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('CurrentDateTime', Process.PluginDescribeResult.ParameterType.STRING)
        };
        
        return result;
            
    }
}