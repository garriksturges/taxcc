trigger EmployeeSurveyDelete_UpdateEmployment on EmployeeSurvey__c (before delete) {
	//get list of employments
	//and make set of old employeesurvey ids
	list<string> eIds = new list<string>();
	set<string> oldEsIds = new set<string>();
	for(EmployeeSurvey__c es: trigger.old){
		eids.add(es.EmploymentPeriod__c);
		oldEsIds.add(es.id);
	}
	
	//get employment periods and thier list of employee surveys
	list<Employment__c> employments = [Select e.SurveyCompletedDateGenerated__c, e.id,
																		 (Select Id From Surveys__r) 
																		 From Employment__c e
																		 where id in :eids];
	
	//make list of employments to update
	list<Employment__c> updateList = new list<Employment__c>();
	boolean addEmp;
	for(Employment__c emp :employments){
	 addEmp = true;
	 for(EmployeeSurvey__c es : emp.Surveys__r){
	 	if(OldEsIds.contains(es.id) == false) addEmp = false;
	 }
	 if(addEmp){
	 	 emp.SurveyCompletedDateGenerated__c = null;
	 	 updateList.add(emp);
	 }		
	}
	
	update updateList;
																			 

}