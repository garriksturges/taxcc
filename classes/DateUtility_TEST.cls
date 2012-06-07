@isTest
private class DateUtility_TEST{

    static testMethod void dateutilityTest() 
    {
    DateUtility dtutil=new DateUtility();
    Map<String,Object> inputParams = new Map<String,Object>();

        string feedSubject = 'Flow is alive';
        InputParams.put('DateToParse', Date.Today());
        InputParams.put('DaysOrMonthsToAdd','2');
        InputParams.put('DaysOrMonths','Days');

        Process.PluginRequest request = new Process.PluginRequest(inputParams); 
    //Process.PluginRequest request=new Process.PluginRequest();
    dtutil.invoke(request);
    dtutil.describe();
    }
    
 }