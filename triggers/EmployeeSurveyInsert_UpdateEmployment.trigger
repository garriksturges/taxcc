trigger EmployeeSurveyInsert_UpdateEmployment on EmployeeSurvey__c (after insert) {

	//get list of Employments to test/update
	list<string> eIds = new list<string>();
	for(EmployeeSurvey__c es: trigger.new){
		eids.add(es.EmploymentPeriod__c);
	}
	
	//get employments
	list<Employment__c> employments = [Select e.SurveyCompletedDateGenerated__c, e.id
																		 From Employment__c e
																		 where id in :eids];
	
	//make map of employments
	map<string, Employment__c> empMap =  new map<string, Employment__c>();
	for(Employment__c emp : employments){
		empMap.put(emp.id, emp);		
	}
	
	//make list to update
	list<Employment__c> updateList = new list<Employment__c>();
	Employment__c emp;
	for(EmployeeSurvey__c es: trigger.new){
		emp = empMap.get(es.EmploymentPeriod__c);
		if(emp!=null && (emp.SurveyCompletedDateGenerated__c == null || emp.SurveyCompletedDateGenerated__c < es.CreatedDate)){
			emp.SurveyCompletedDateGenerated__c = es.CreatedDate;
			updateList.add(emp);
		}
	}
	
	update updateList;
}