/******************************************************************************************************************************************
Trigger Name : PreventDuplicateProgramCategoryPeriod
Created By   : Nagaraju Naidu
Description  : This Trigger prevents adding a same Area, Program Category and Start Date  under ProgramCategoryPeriod.   
Modification History: 
   
*******************************************************************************************************************************************/

trigger PreventDuplicateProgramCategoryPeriod on ProgramCategoryPeriod__c (before insert, before update) {
  Set<String> programcategory = new Set<String>();
  Map<string,Id> mapprogramcatperiod=new Map<string,Id>();
  for(ProgramCategoryPeriod__c programcatperiod : Trigger.new)
  {
    programcategory.add(programcatperiod.ProgramCategory__c);
    
  }
  List<ProgramCategoryPeriod__c> lstprogramcatperiod = [Select ID, Area__c, ProgramCategory__c, StartDate__c from ProgramCategoryPeriod__c where ProgramCategory__c in:programcategory];
  for(ProgramCategoryPeriod__c programcatperiod:lstprogramcatperiod)
  {
    string combinekey=string.valueof(programcatperiod.Area__c)+string.valueof(programcatperiod.ProgramCategory__c)+string.valueof(programcatperiod.StartDate__c);
    mapprogramcatperiod.put(combinekey,programcatperiod.Id);
  }
  for(ProgramCategoryPeriod__c programcatperiod:trigger.new)
  {
    string combinekey=string.valueof(programcatperiod.Area__c)+string.valueof(programcatperiod.ProgramCategory__c)+string.valueof(programcatperiod.StartDate__c);
    if(mapprogramcatperiod.containsKey(combinekey))
    {
      if ((Trigger.isInsert) || ((Trigger.isUpdate) && (mapprogramcatperiod.get(combinekey) !=programcatperiod.Id)))
      {
          programcatperiod.addError('I\'m guessing you\'ve forgotten that you already entered a program category periods for this category under this area and effective on this date. Or perhaps someone else already entered it. Regardless, it\'s not going in again.');
      }
    }
  }
}