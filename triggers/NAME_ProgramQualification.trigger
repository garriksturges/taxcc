trigger NAME_ProgramQualification on ProgramQualification__c (before insert, before update) {
list<String> eIds = new list<String>();
list<String> pIds = new list<String>();
map<String, String> eMap = new Map<String, String>();
map<String, String> pMap = new Map<String, String>();
QualificationProcessStage__c qps = [Select Id, QualificationProcessStageEID__c from QualificationProcessStage__c where QualificationProcessStageEID__c = 8];
for(ProgramQualification__c pq : trigger.new){
    eIds.add(pq.Employment__c);
    pIds.add(pq.ProgramPeriod__c);
}

List<Employment__c> employmentList = [select Employee__r.FullNameFormula__c from Employment__c where Id in :eIds];

for(Employment__c e : employmentList){
    eMap.put(e.Id, e.Employee__r.FullNameFormula__c );
}

List<ProgramPeriod__c> programPeriodList = [select Program__r.ShortName__c from ProgramPeriod__c where id in :pIds];
for(ProgramPeriod__c pp : programPeriodList){
    pMap.put(pp.id, pp.Program__r.ShortName__c);
}

map<String, Integer> fieldMax;
list<String> orderList;
for(ProgramQualification__c pq : trigger.new){
    fieldMax = new map<String, Integer>();
    orderList = new list<String>();
    
    //fields
    if(pq.Employment__c != null && eMap.get(pq.Employment__c)!= null){
        fieldMax.put(eMap.get(pq.Employment__c), 37);
        orderList.add(eMap.get(pq.Employment__c));
    }
    if(pq.ProgramPeriod__c != null && pMap.get(pq.ProgramPeriod__c)!=null){
        fieldMax.put(pMap.get(pq.ProgramPeriod__c), 36);
        orderList.add(pMap.get(pq.ProgramPeriod__c));
    }
    if(pq.EffectiveDate__c != null){
        Datetime sd = Datetime.newInstance(pq.EffectiveDate__c, Time.newInstance(0,0,0,0)); 
        fieldMax.put(sd.format('M/yy'),5);
        orderList.add(sd.format('M/yy'));
    }
    
    NAME_Trigger_helper nh = new NAME_Trigger_helper(fieldMax, orderList, 80);
      pq.Name = nh.generateName();
      if(trigger.isInsert){
     	 pq.ProcessStage__c = qps.Id;
      pq.ProcessStageDate__c = System.now();
      }
      else if(trigger.isUpdate && pq.ProcessStage__c <> trigger.OldMap.get(pq.Id).ProcessStage__c)
		pq.ProcessStageDate__c = System.now();
 		
     

}
	 for(ProgramQualification__c pq : trigger.new){
 		if(trigger.isUpdate){ // && pq.ProcessStage__c <> trigger.OldMap.get(pq.Id).ProcessStage__c){
		if(pq.ProcessStage__c <> trigger.OldMap.get(pq.Id).ProcessStage__c)
		pq.ProcessStageDate__c = System.now();
 		}
	 }
}