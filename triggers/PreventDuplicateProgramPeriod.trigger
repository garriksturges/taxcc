/******************************************************************************************************************************************
Trigger Name : PreventDuplicateProgramPeriod
Created By   : Nagaraju Naidu
Description  : This Trigger prevents adding a same Program, Agency, Area, and Start Date under ProgramPeriod.   
Modification History: 
   
*******************************************************************************************************************************************/

trigger PreventDuplicateProgramPeriod on ProgramPeriod__c (before insert, before update) 
{
    //Set<String> agency  = new Set<String>();
    //Set<String> area = new Set<String>();
    Set<String> program = new Set<String>();
    //Set<Date> StartDate=new Set<Date>();
    Map<string,Id> mapprogramperiod=new Map<string,Id>();
    for(ProgramPeriod__c programperiod : Trigger.new){
        //agency.add(programperiod.Agency__c);
        //area.add(programperiod.Area__c);
        program.add(programperiod.Program__c);
        //StartDate.add(programperiod.StartDate__c);
    }
    //List<ProgramPeriod__c> lstprogramperiod = [Select ID,Agency__c, Area__c, Program__c, StartDate__c from ProgramPeriod__c where Agency__c in: agency and Area__c in:area and Program__c in:program and StartDate__c in:startdate];
    List<ProgramPeriod__c> lstprogramperiod = [Select ID,Agency__c, Area__c, Program__c, StartDate__c from ProgramPeriod__c where Program__c in:program];
    
    for(ProgramPeriod__c programperiod:lstprogramperiod)
    {
        string combinekey=string.valueof(programperiod.Agency__c)+string.valueof(programperiod.Area__c)+string.valueof(programperiod.Program__c)+string.valueof(programperiod.StartDate__c);
        mapprogramperiod.put(combinekey,programperiod.Id);
    }
    for(ProgramPeriod__c programperiod:trigger.new)
    {
        string combinekey=string.valueof(programperiod.Agency__c)+string.valueof(programperiod.Area__c)+string.valueof(programperiod.Program__c)+string.valueof(programperiod.StartDate__c);
        if(mapprogramperiod.containsKey(combinekey))
        {
           //system.debug('testng'+mapprogramperiod.get(combinekey)+'test'+programperiod);
           if (Trigger.isInsert || (Trigger.isUpdate && mapprogramperiod.get(combinekey)!=programperiod.Id))
            {
                programperiod.addError('You\'ll never believe it, but this program period already exists. In other words, there is already a program period for this program, in this area, reporting to this agency, effective on this date.');
            }
        }
    }
}