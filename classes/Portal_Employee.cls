public with sharing class Portal_Employee {
	private string empId;
	public string employeeFirstName {get; set;}
	public string employeeLastName {get; set;}
	public string employeeLocationName {get; set;}
	public string employeeLocationID {get; set;}
	public list <ProgramListing> programList {get; set;} 
	/*********************************/
	public Portal_Employee(){
		empId = Apexpages.currentPage().getParameters().get('eId');
		list<wktLocationEmployeeProgram__c> wktList = [Select w.Program__r.ShortName__c, w.Program__r.Name, w.Program__c, 
																									w.HireLocation__r.StreetAddressText__c, w.HireLocation__r.State__c, 
																									w.HireLocation__r.CityName__c, w.HireLocation__r.Name, w.HireLocation__c, 
																									w.HireDate__c, w.Employee__c, w.EmployeeName__c, w.DocumentReplacementNeededText__c, 
																									w.DocumentReceivedText__c, w.DocumentNeededText__c, w.SurveyLocation__r.Name, 
																									w.SurveyLocation__c, w.SurveyDate__c, Employee__r.FirstName__c, Employee__r.LastName__c,
																									Employment__r.Location__r.Name, Employment__r.Location__r.Id
																									From wktLocationEmployeeProgram__c w
																									where Employee__c = :empId];
		programList = new list<ProgramListing>();
		if(wktList != null && wktList.size() > 0){
			employeeFirstName = wktList[0].Employee__r.FirstName__c;
			employeeLastName = wktList[0].Employee__r.LastName__c;
			employeeLocationName = wktList[0].Employment__r.Location__r.Name;
			employeeLocationID = wktList[0].Employment__r.Location__r.Id;
			for(wktLocationEmployeeProgram__c wkt : wktList){
				programList.add(new ProgramListing(wkt));
			}
		}
	}
	/******************************/
	/*****/
	public class ProgramListing{
		public String programName{get; set;}
		public list<string> receivedDocs {get;set;}
		public list<string> neededDocs {get; set;}
		public list<string> replaceDocs {get; set;}
		public string hireLoc		{get; set;}
		public string surveyLoc	{get; set;}
		public wktLocationEmployeeProgram__c wkt {get; set;}
		
		public ProgramListing(wktLocationEmployeeProgram__c wkt){
			this.wkt = wkt;
			this.programName = wkt.Program__r.Name + ' -- '+wkt.Program__r.shortName__c;
			
			if(wkt.SurveyLocation__c != null) surveyLoc = wkt.SurveyLocation__r.Name;
			else surveyLoc = 'NONE';
			if(wkt.Hirelocation__c != null) hireLoc = wkt.HireLocation__r.Name;
			else hireLoc = 'NONE';
			
			if(wkt.DocumentReceivedText__c != null) receivedDocs = wkt.DocumentReceivedText__c.split(';');
			if(wkt.DocumentNeededText__c != null) neededDocs = wkt.DocumentNeededText__c.split(';');
			if(wkt.DocumentReplacementNeededText__c != null) replaceDocs = wkt.DocumentReplacementNeededText__c.split(';');
		}	
	}
	/*****/ 
	/******************************/
}