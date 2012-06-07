trigger PreventProgramCategoryQualificationInDifferentProgram  on ProgramCategoryQualification__c (before insert,before update){
    
    Set<Id> programCategoryPeriodSet=new Set<Id>();
    Set<Id> programQualificationSet=new Set<Id>();
    
    for(ProgramCategoryQualification__c programCategoryQualification:trigger.new)
    {       
        programCategoryPeriodSet.add(programCategoryQualification.ProgramCategoryPeriod__c);
        programQualificationSet.add(programCategoryQualification.ProgramQualification__c);  
    }
    
    
    Map<Id,ProgramCategoryPeriod__c> programCategoryPeriodMap=new Map<Id,ProgramCategoryPeriod__c>([Select ProgramCategory__r.Program__c,ProgramCategory__c From ProgramCategoryPeriod__c where id in:programCategoryPeriodSet]);
    Map<Id,ProgramQualification__c> programQualificationMap=new Map<Id,ProgramQualification__c>([Select ProgramPeriod__r.Program__c,ProgramPeriod__c From ProgramQualification__c where id in:programQualificationSet]);
    
    for(ProgramCategoryQualification__c programCategoryQualification:trigger.new)
    {
        
        ProgramCategoryPeriod__c programCategoryPeriod = programCategoryPeriodMap.get(programCategoryQualification.ProgramCategoryPeriod__c);
        ProgramQualification__c programQualification = programQualificationMap.get(programCategoryQualification.ProgramQualification__c);
        
        if(programCategoryPeriod.ProgramCategory__r.Program__c != programQualification.ProgramPeriod__r.Program__c)
        {
            programCategoryQualification.addError('Uh, be careful. You are putting this record under a program qualification and also under a program category, as you should, but those two are under different programs. Go check, you\'ll see.');
        } 

    }   

}