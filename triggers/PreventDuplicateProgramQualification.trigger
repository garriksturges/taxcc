/******************************************************************************************************************************************
Trigger Name : PreventDuplicate_PQ
Created By   : Nagaraju Naidu
Description  : This Trigger prevents adding Program Qualification record that is being entered cannot map to the same Program Period.program and Employment.   
Modification History: 
   
*******************************************************************************************************************************************/

trigger PreventDuplicateProgramQualification on ProgramQualification__c (before insert) {

 // Events
	
    Map<String, ProgramQualification__c> empProgMap = new Map<String, ProgramQualification__c>();
    String uniqueKey;
    String employmentId;
    String programId;
   
   // Bypassing the code while New PQ's are Inserted ONLY through Survey!
 if((trigger.isInsert || trigger.isUpdate) && !QualifyProgramCategory.byPassPreventDuplicatePQ ) { 
    for (ProgramQualification__c pq : System.Trigger.new ) {
        programId = [Select Program__c From ProgramPeriod__c where Id=: pq.ProgramPeriod__c].Program__c;
        programId = programId.substring(0,15);        
        employmentId = pq.Employment__c;
        if(employmentId != null) employmentId = employmentId.substring(0,15);
        uniqueKey = employmentId + programId;       
       
        if (programId != null) {    
            if (empProgMap.containsKey(uniqueKey)) {
                pq.ProgramPeriod__c.addError('You know, this employee can only qualify once for this program, unless the person is hired a separate time, and even then it may or may not be right.');
            } else {
                empProgMap.put(uniqueKey, pq);
           }
       
        }  
  }
     
     if(!empProgMap.isEmpty()) 
     { 
         
       for (List<ProgramQualification__c> prgCheck : [SELECT Id,Unique_Key_Qualification__c FROM ProgramQualification__c WHERE Unique_Key_Qualification__c IN :empProgMap.KeySet()]) {
            
            for(ProgramQualification__c prgQual :prgCheck)
              {  
                String currentPQId = prgQual.Id;
                
                if(empProgMap.containsKey(prgQual.Unique_Key_Qualification__c) && (currentPQId != empProgMap.get(prgQual.Unique_Key_Qualification__c).Id))
                  {
                     ProgramQualification__c newProgQual = empProgMap.get(prgQual.Unique_Key_Qualification__c);
                     newProgQual.ProgramPeriod__c.addError('You know, this employee can only qualify once for this program, unless the person is hired a separate time, and even then it may or may not be right.');
                  } 
              }  
        }
     }
}

}