trigger EmployeeSurvey_DeclinedSurveyBit_SurveyResultsGenerated on EmployeeSurvey__c (before insert, before update) {
	for(EmployeeSurvey__c es : trigger.new){
		if(es.DeclinedSurveyBit__c == true && es.SurveyResultGenerated__c != 'Qualified') es.SurveyResultGenerated__c = 'Declined';
		if(es.SurveyResultGenerated__c ==null) es.SurveyResultGenerated__c = 'Did Not Qualify';
	}

}