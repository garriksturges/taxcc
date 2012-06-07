public with sharing class PortalEmployeeInfoController {
	private string empId;
	
	list<wktLocationEmployeeProgram__c> wktL	{get; set;}
	public string employeeLocationID 		{get; set;}
	public string employeeLocationName	{get; set;}
	public string employeeLastName			{get; set;}
	public string employeeFirstName			{get; set;}
	public string employeeFullName			{get; set;}
	//EMPLOYEE TABLE INFO
	public string EMP_name				{get; set;}
	public string EMP_accountName	{get; set;}
	public string EMP_id					{get; set;}
	public string EMP_ssn					{get; set;}
	public string EMP_refId				{get; set;}
	//EMPLOYMENT INFO
	public list<EMPLOYMENT_INFO> employmentList	{get; set;}
	//SURVEY INFO
	public list<SURVEY_INFO> surveyList	{get; set;}
	//QUALIFICATIONS
	public list<QUALIFICATIONS> qualificationList	{get; set;}
	
	/************************************/
	public PortalEmployeeInfoController(){
		empId = ApexPages.currentPage().getParameters().get('empId');
		employeeLocationID =ApexPages.currentPage().getParameters().get('locId');
		if(empId!=null) makeWktList();
		if(wktL!=null && wktL.size()>0){
			setupCrumbs();
			fillOutEMPLOYEEtableInfo();
			fillOutEMPLOYMENTholders();
			fillOutSURVEYStaken();
			fillOutQualifications();
		}	
	}
	/************************************/
	private void makeWktList(){
		wktL = [Select w.Program__r.ShortName__c, w.Program__r.Name, w.Program__c,
						w.Employee__r.LastName__c, w.Employee__r.FirstName__c,
						w.ExternalProcessStageName__c, w.Employment__r.ReferenceID__c, 
						w.Employment__r.Location__c, w.Employment__r.StartDate__c, 
						w.Employment__r.Id, w.Employment__c, w.Employment__r.Location__r.Name, 
						w.Employment__r.JobTitleName__c, w.Employment__r.EndDate__c, 
						w.Employee__r.MaskedSSNFormula__c, 
						w.Employee__r.Account__c, w.Employee__r.Id, w.Employee__c, w.Employee__r.Name,
						w.Employee__r.Account__r.ShortName__c, w.Employee__r.Account__r.Name, 
						w.Employee__r.ClientEmployeeID__c,
						w.EmployeeSurvey__r.EntityLocation__c, w.EmployeeSurvey__r.SurveyResultGenerated__c, 
						w.EmployeeSurvey__r.ReportedHireDate__c, w.EmployeeSurvey__r.CreatedDate, 
						w.EmployeeSurvey__c, w.EmployeeName__c, w.EmployeeSurvey__r.EntityLocation__r.Location__r.Name,
						w.EmployeeSurvey__r.SurveyDate__c,
						w.DocumentReplacementNeededText__c, w.DocumentReceivedText__c, w.DocumentNeededText__c,
						w.QualifiedCategoryText__c, w.Employee__r.FirstLastNameFormula__c, w.Employment__r.Status__c,
						w.ActionItemFormula__c, w.ProgramQualification__r.ProcessStage__r.ExternalName__c
						From wktLocationEmployeeProgram__c w
						where Employee__r.Id = :empId
						order by Employment__r.StartDate__c];
	}
	/************************************/
	private void setupCrumbs(){
		wktLocationEmployeeProgram__c wkt = wktL[0];
		employeeLastName = wkt.Employee__r.LastName__c;
		employeeFirstName = wkt.Employee__r.FirstName__c;
		employeeFullName = wkt.Employee__r.FirstLastNameFormula__c;
		if(employeeLocationID!=null){
			try{
				Location__c l = [select Name from Location__c where id =:employeeLocationID];
				employeeLocationName = l.Name;
			}
			catch(Exception e){}
		}
	}
	/************************************/
	private void fillOutEMPLOYEEtableInfo(){
		wktLocationEmployeeProgram__c wkt = wktL[0];
		EMP_name = wkt.Employee__r.Name;
		if(wkt.Employee__r.Account__r.ShortName__c!=null) EMP_accountName = wkt.Employee__r.Account__r.ShortName__c;
		else EMP_accountName = wkt.Employee__r.Account__r.Name;
		EMP_id = wkt.Employee__r.ClientEmployeeID__c;
		EMP_ssn = wkt.Employee__r.MaskedSSNFormula__c;
		EMP_refId = wkt.Employment__r.ReferenceID__c;
	}
	/************************************/
	private void fillOutEMPLOYMENTholders(){
		employmentList = new list<EMPLOYMENT_INFO>();
		for(wktLocationEmployeeProgram__c wkt : wktL){
			if(wkt.Employment__c != null) employmentList.add(new EMPLOYMENT_INFO(wkt));
		}
	}
	/************************************/
	private void fillOutSURVEYStaken(){
		surveyList = new list<SURVEY_INFO>();
		for(wktLocationEmployeeProgram__c wkt: wktL){
			if(wkt.EmployeeSurvey__c !=null) surveyList.add(new SURVEY_INFO(wkt));
		}
	}
	/************************************/
	private void fillOutQualifications(){
		qualificationList = new list<QUALIFICATIONS>();
		for(wktLocationEmployeeProgram__c wkt: wktL){
			if(wkt.Program__c !=null) qualificationList.add(new QUALIFICATIONS(wkt));
		}
	}
	/************************************/
	/***/
	public class EMPLOYMENT_INFO{
		public string startDate			{get; set;}
		public string location			{get; set;}
		public string jobTitle			{get; set;}
		public string endDate				{get; set;}
		
		public EMPLOYMENT_INFO(wktLocationEmployeeProgram__c wkt){
			//startDate = String.valueOf(wkt.Employment__r.StartDate__c.month())+'/'+String.valueOf(wkt.Employment__r.StartDate__c.day())+'/'+String.valueOf(wkt.Employment__r.StartDate__c.year());
			//location = wkt.Employment__r.Location__r.Name;
			//jobTitle = wkt.Employment__r.JobTitleName__c;
			//endDate = string.valueOf(wkt.Employment__r.EndDate__c);
			
			//ADDED BY BOB 4/25/12
            if(String.valueOf(wkt.Employment__r.StartDate__c.month())+'/'+String.valueOf(wkt.Employment__r.StartDate__c.day())+'/'+String.valueOf(wkt.Employment__r.StartDate__c.year()) == null || String.valueOf(wkt.Employment__r.StartDate__c.month())+'/'+String.valueOf(wkt.Employment__r.StartDate__c.day())+'/'+String.valueOf(wkt.Employment__r.StartDate__c.year()) == '') startDate = '—';
            else startDate = String.valueOf(wkt.Employment__r.StartDate__c.month())+'/'+String.valueOf(wkt.Employment__r.StartDate__c.day())+'/'+String.valueOf(wkt.Employment__r.StartDate__c.year());
            if(string.valueOf(wkt.Employment__r.EndDate__c) == null || string.valueOf(wkt.Employment__r.EndDate__c) == '') endDate = '—';
            else endDate = string.valueOf(wkt.Employment__r.EndDate__c.month())+'/'+string.valueOf(wkt.Employment__r.EndDate__c.day())+'/'+string.valueOf(wkt.Employment__r.EndDate__c.year());
            if(wkt.Employment__r.Location__r.Name == null || wkt.Employment__r.Location__r.Name == '') location = '—';
            else location = wkt.Employment__r.Location__r.Name;
            if(wkt.Employment__r.JobTitleName__c == null || wkt.Employment__r.JobTitleName__c == '') jobTitle = '—';
            else jobTitle = wkt.Employment__r.JobTitleName__c;
            if(string.valueOf(wkt.Employment__r.EndDate__c) == null || string.valueOf(wkt.Employment__r.EndDate__c) == '') endDate = '—';
            else endDate = string.valueOf(wkt.Employment__r.EndDate__c);
            
		}
	}
	/***/
	public class SURVEY_INFO{
		public string createdDate		{get; set;}
		public string location			{get; set;}
		public string results				{get; set;}
		public string hireDate			{get; set;}		
		
		public SURVEY_INFO(wktLocationEmployeeProgram__c wkt){
			//createdDate = String.valueOf(wkt.EmployeeSurvey__r.SurveyDate__c.month())+'/'+String.valueOf(wkt.EmployeeSurvey__r.SurveyDate__c.day())+'/'+String.valueOf(wkt.EmployeeSurvey__r.SurveyDate__c.year());
			//location = wkt.EmployeeSurvey__r.EntityLocation__r.Location__r.Name;
			//results = wkt.EmployeeSurvey__r.SurveyResultGenerated__c;
			//hireDate = string.valueOf(wkt.EmployeeSurvey__r.ReportedHireDate__c.month())+'/'+string.valueOf(wkt.EmployeeSurvey__r.ReportedHireDate__c.day())+'/'+string.valueOf(wkt.EmployeeSurvey__r.ReportedHireDate__c.year());
			
			
			if(String.valueOf(wkt.EmployeeSurvey__r.SurveyDate__c.month())+'/'+String.valueOf(wkt.EmployeeSurvey__r.SurveyDate__c.day())+'/'+String.valueOf(wkt.EmployeeSurvey__r.SurveyDate__c.year()) == null || String.valueOf(wkt.EmployeeSurvey__r.SurveyDate__c.month())+'/'+String.valueOf(wkt.EmployeeSurvey__r.SurveyDate__c.day())+'/'+String.valueOf(wkt.EmployeeSurvey__r.SurveyDate__c.year()) == '') createdDate = '—';
            else createdDate = String.valueOf(wkt.EmployeeSurvey__r.SurveyDate__c.month())+'/'+String.valueOf(wkt.EmployeeSurvey__r.SurveyDate__c.day())+'/'+String.valueOf(wkt.EmployeeSurvey__r.SurveyDate__c.year());
            if(wkt.EmployeeSurvey__r.EntityLocation__r.Location__r.Name == null || wkt.EmployeeSurvey__r.EntityLocation__r.Location__r.Name == '') location = '—';
            else location = wkt.EmployeeSurvey__r.EntityLocation__r.Location__r.Name;
            if(wkt.EmployeeSurvey__r.SurveyResultGenerated__c == null || wkt.EmployeeSurvey__r.SurveyResultGenerated__c == '') results = '—';
            else results = wkt.EmployeeSurvey__r.SurveyResultGenerated__c;
            if(string.valueOf(wkt.EmployeeSurvey__r.ReportedHireDate__c.month())+'/'+string.valueOf(wkt.EmployeeSurvey__r.ReportedHireDate__c.day())+'/'+string.valueOf(wkt.EmployeeSurvey__r.ReportedHireDate__c.year()) == null || string.valueOf(wkt.EmployeeSurvey__r.ReportedHireDate__c.month())+'/'+string.valueOf(wkt.EmployeeSurvey__r.ReportedHireDate__c.day())+'/'+string.valueOf(wkt.EmployeeSurvey__r.ReportedHireDate__c.year()) == '') hireDate = '—';
            else hireDate = string.valueOf(wkt.EmployeeSurvey__r.ReportedHireDate__c.month())+'/'+string.valueOf(wkt.EmployeeSurvey__r.ReportedHireDate__c.day())+'/'+string.valueOf(wkt.EmployeeSurvey__r.ReportedHireDate__c.year());
		}
	}
	/***/
	public class QUALIFICATIONS{
		public string programName		{get; set;}
		public string stageName			{get; set;}
		public string categoryText	{get; set;}
		public string docNeeded			{get; set;}
		public string docRec				{get; set;}
		public string empStatus		{get; set;}
		public string certStatus		{get; set;}
		public string qualTasks		{get; set;}
		
		public QUALIFICATIONS(wktLocationEmployeeProgram__c wkt){
			programName = wkt.Program__r.Name;
			//stageName = wkt.ExternalProcessStageName__c;
			//categoryText = 
			//docNeeded = makeDocNeeded(wkt);
			//docRec = makeDocRec(wkt);
			//if(wkt.QualifiedCategoryText__c==null) categoryText = '—';
			//else categoryText=wkt.QualifiedCategoryText__c;
			//if(wkt.ExternalProcessStageName__c == null || wkt.ExternalProcessStageName__c == '') stageName = '—';
            //else stageName = wkt.ExternalProcessStageName__c;
			//if(makeDocNeeded(wkt) == null || makeDocNeeded(wkt) == '') docNeeded = '—';
            //else docNeeded = makeDocNeeded(wkt);
            //if(makeDocNeeded(wkt) == null || makeDocNeeded(wkt) == '') docNeeded = '—';
            //else docNeeded = makeDocNeeded(wkt);
            //if(makeDocRec(wkt) == null || makeDocRec(wkt) == '') docRec = '—';
            //else docRec = makeDocRec(wkt);
            if(wkt.Employment__r.Status__c == null || wkt.Employment__r.Status__c == '') empStatus = '—';
            else empStatus = wkt.Employment__r.Status__c;
            if(wkt.ProgramQualification__r.ProcessStage__r.ExternalName__c == null || wkt.ProgramQualification__r.ProcessStage__r.ExternalName__c == '') certStatus = '—';
            else certStatus = wkt.ProgramQualification__r.ProcessStage__r.ExternalName__c;
            if(wkt.ActionItemFormula__c == null || wkt.ActionItemFormula__c == '') qualTasks = '—';
            else qualTasks = wkt.ActionItemFormula__c;
			
		}
		/************************/
		public string makeDocNeeded(wktLocationEmployeeProgram__c wkt){
			string rVal = '';
			string rep = '';
			if(wkt.DocumentNeededText__c !=null){
				rVal =  wkt.DocumentNeededText__c.replaceAll(';', ',');
				if(rVal.endsWith(',')) rVal = rVal.substring(0, rVal.length()-1);
				rVal = rVal+' ';
			}
			if(wkt.DocumentReplacementNeededText__c != null){
				rep = wkt.DocumentReplacementNeededText__c.replaceAll(';', ',');
				if(rep.endsWith(',')) rep = rep.substring(0, rep.length()-1);
				rep = 'Please replace: '+rep;
			} 
			return rVal+rep;
		}
		/************************/
		public string makeDocRec(wktLocationEmployeeProgram__c wkt){
			string rVal ='';
			if(wkt.DocumentReceivedText__c !=null){
					rVal =  wkt.DocumentReceivedText__c.replaceAll(';', ',');
					if(rVal.endsWith(',')) rVal = rVal.substring(0, rVal.length()-1);
			}
			return rVal;
		}
	}	
	/***/
}