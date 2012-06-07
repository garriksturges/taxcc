trigger ProgramQualificationInsert_UpdateEmployeeSurvey on ProgramQualification__c (after insert) {

	//get list of Employee Survey ids
	list<string> esIds = new list<string>();
	for(ProgramQualification__c pq: trigger.new){
		esIds.add(pq.Survey__c);
	}

	//get employee surveys and update them
	for(list<EmployeeSurvey__c> esList : [Select e.SurveyResultGenerated__c From EmployeeSurvey__c e where id in :esIds]){
		for(EmployeeSurvey__c es: esList){
			es.SurveyResultGenerated__c = 'Qualified';
		}																		
		update esList;
	}
}