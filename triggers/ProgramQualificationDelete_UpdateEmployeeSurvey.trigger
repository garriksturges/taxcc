trigger ProgramQualificationDelete_UpdateEmployeeSurvey on ProgramQualification__c (after delete) {
//get list of Employee Survey ids
	list<string> esIds = new list<string>();
	set<string> oldPQset = new set<string>();
	for(ProgramQualification__c pq: trigger.old){
		esIds.add(pq.Survey__c);
		oldPqSet.add(pq.id);
	}
	
	list<EmployeeSurvey__c> updateList;
	boolean addES;
	for(list<EmployeeSurvey__c> esList:[Select e.SurveyResultGenerated__c, (Select Id From ProgramQualifications__r) From EmployeeSurvey__c e where id in :esIds]){
		updateList = new list<EmployeeSurvey__c>();
		for(EmployeeSurvey__c es: esList){
			addES=true;
			for(ProgramQualification__c pq : es.ProgramQualifications__r){
				if(oldPqSet.contains(pq.id) == false) addES = false;
			}
			if(addES || es.SurveyResultGenerated__c == null){
				es.SurveyResultGenerated__c = 'Did Not Qualify';
				updateList.add(es);
			}
		}
		update updateList;
	}

}