trigger EmployeeSurveyTriggerUpdateWkt on EmployeeSurvey__c (before insert, before update) {
	/*//get all employee Ids
	list<String> eList = new list<String>();
	for(EmployeeSurvey__c es: Trigger.new){
		eList.add(es.EmploymentPeriod__r.Employee__c);
	}
	//get all wtk
	list<wktLocationEmployeeProgram__c> wktList = [Select SurveyProgramScreened__c, SurveyLocation__c, SurveyDate__c, Program__c,
																								ProgramStartDate__c, ProgramPeriod__c, ProgramEndDate__c, HireLocation__c, HireDate__c,
																								Employment__c, Employee__c, EmployeeSurvey__c 
																								From wktLocationEmployeeProgram__c
																								where Employee__c in :eList and Program__c = null];

	for()																								
	*/
}

/*Select e.SurveySource__c, e.SurveyDate__c, e.SF1EmployeeSurveyID__c, e.ReportedHireDate__c, e.Name, e.EntityLocation__r.Location__c, 
e.EntityLocation__c, e.EmploymentPeriod__r.Employee__c, e.EmploymentPeriod__c(Select Program__c From SurveyProgramsScreened__r) From EmployeeSurvey__c e*/