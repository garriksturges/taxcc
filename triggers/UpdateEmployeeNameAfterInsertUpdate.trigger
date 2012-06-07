trigger UpdateEmployeeNameAfterInsertUpdate on Employee__c (after insert, after update)
{

List< Employee__c > updateEmpList = new list< Employee__c >();


  try
  {
    if(!ProcessorControl.inFutureContext)
    {  
      ProcessorControl.inFutureContext = true;
      
      List<Employee__c> empList = [select Id, Name, FullNameFormula__c from Employee__c where Id in: Trigger.new];
      
        for (Employee__c e : empList)
        {
          e.Name = e.FullNameFormula__c;   

           updateEmpList.add(e);  
        }  
      
        update updateEmpList;
    }
  }
  catch(Exception ex){}  
}