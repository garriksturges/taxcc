trigger PreventProgramCategoryQualificationWithHireDateOutsideOfProgramCategoryPeriod on ProgramCategoryQualification__c (before insert, before update) 
{
  Set<Id> setempperiod=new Set<Id>();
  Set<Id> setprgcatperiod=new Set<Id>();
  for(ProgramCategoryQualification__c PrgCatQual:trigger.new)
  {
    setempperiod.add(PrgCatQual.ProgramQualification__c);
    setprgcatperiod.add(PrgCatQual.ProgramCategoryPeriod__c);
  }
  
  Map<Id,ProgramQualification__c> mapPrgQual=new Map<Id,ProgramQualification__c>([Select Employment__r.StartDate__c,Employment__r.EndDate__c,Employment__c From ProgramQualification__c]);
  //Map<Id,Employment__c> MapEmployment=new Map<Id,Employment__c>([select id,StartDate__c,EndDate__c from Employment__c where id in:setempperiod]);
  Map<Id,ProgramCategoryPeriod__c> MapPrgCatPeriod=new Map<Id,ProgramCategoryPeriod__c>([select id,StartDate__c,EndDate__c from ProgramCategoryPeriod__c where id in:setprgcatperiod]);
  for(ProgramCategoryQualification__c prgCatQual:trigger.new)
    {
        ProgramQualification__c ProgramQualification=mapPrgQual.get(prgCatQual.ProgramQualification__c);
        ProgramCategoryPeriod__c PrgcatPeriod=MapPrgCatPeriod.get(prgCatQual.ProgramCategoryPeriod__c);
  if(PrgcatPeriod.EndDate__c!=null)
  {
    if(ProgramQualification.Employment__r.StartDate__c>=PrgcatPeriod.StartDate__c && ProgramQualification.Employment__r.StartDate__c<=PrgcatPeriod.EndDate__c)
    {}
    else
      prgCatQual.addError('That category was not active at the time this person was hired. Hopefully this person qualifies for something else, otherwise it\'s a lost cause.');
  }
  else
  if(ProgramQualification.Employment__r.StartDate__c>=PrgcatPeriod.StartDate__c)
  {}
  else
    prgCatQual.addError('That category was not active at the time this person was hired. Hopefully this person qualifies for something else, otherwise it\'s a lost cause.');
    }
}