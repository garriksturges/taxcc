/******************************************************************************************************************************************
Trigger Name : PreventDuplicatePCQ
Created By   : Nagaraju Naidu
Description  : This Trigger prevents adding Program Category Qualification record that is being entered cannot map to the same Program category Period.program category and Program Qualification.   
Modification History: 
   
*******************************************************************************************************************************************/
trigger PreventDuplicateProgramCategoryQualification on ProgramCategoryQualification__c (before insert, before update) {

    Map<string,ProgramCategoryQualification__c> PCPMapPCQ = new Map<string,ProgramCategoryQualification__c>();
    string PrgQual;
    string Prgcatperiod;
    string uniquekey;

    for(ProgramCategoryQualification__c PCQ:System.Trigger.new)
    {
        Prgcatperiod=[select ProgramCategory__c from ProgramCategoryPeriod__c where id=:PCQ.ProgramCategoryPeriod__c].ProgramCategory__c;
        Prgcatperiod=Prgcatperiod.substring(0,15);
        PrgQual=PCQ.ProgramQualification__c;
        PrgQual=PrgQual.substring(0,15);
        uniquekey=PrgQual+Prgcatperiod;
  
        if (Prgcatperiod != null) {
            if(PCPMapPCQ.containskey(uniquekey))
            {
                PCQ.ProgramCategoryPeriod__c.addError('That\'s cheating. Or maybe over-compensation. Greed? An honest mistake, you say? Be that as it may, I can\'t allow double qualifications for the same category, as that could create double credits.');
            } 
            else
            {
                PCPMapPCQ.put(uniquekey, PCQ);
            }
        }
      
    } 
  
    if(!PCPMapPCQ.isEmpty())
    {
        for (List<ProgramCategoryQualification__c> PCQlist : [select Id,PCQualification_Unique_Key__c from ProgramCategoryQualification__c where PCQualification_Unique_Key__c IN :PCPMapPCQ.keySet()])
        { 
            for(ProgramCategoryQualification__c Prgcatqualification :PCQlist)
            {
                String CurrPCQId = Prgcatqualification.Id;
                
                if(PCPMapPCQ.containskey(Prgcatqualification.PCQualification_Unique_Key__c) && (CurrPCQId !=PCPMapPCQ.get(Prgcatqualification.PCQualification_Unique_Key__c).Id))
                {
                    ProgramCategoryQualification__c newPrgCatQual = PCPMapPCQ.get(Prgcatqualification.PCQualification_Unique_Key__c);
                    newPrgCatQual.ProgramCategoryPeriod__c.addError('That\'s cheating. Or maybe over-compensation. Greed? An honest mistake, you say? Be that as it may, I can\'t allow double qualifications for the same category, as that could create double credits.');
                }
            }
        }
    }
}