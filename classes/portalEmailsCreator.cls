public with sharing class portalEmailsCreator {
	private integer MAXSIZE = 20;
	private boolean makeAttachment = false;
	public map  <string, list<PortalExecutiveDashboardController.locationProgramWrapper>> locationStats {get; set;}
	public map<String, list<PortalEmailDigestHelper.employeeDigestSubClass>> employeeStatsMap {get; set;}
	public PortalNotificationSchedule__c p {get; set;}
	public list <list<PortalEmailDigestHelper.employeeDigestSubClass>> eList;
	/***********************************/
	//public portalEmailsCreator(PortalNotificationSchedule__c po, map <string, list<PortalExecutiveDashboardController.locationProgramWrapper>> locationStats, map<String, list<PortalEmailDigestHelper.employeeDigestSubClass>> employeeStatsMap, list<PortalEmailDigestHelper.employeeDigestSubClass>eList){
	public portalEmailsCreator(PortalNotificationSchedule__c po, map <string, list<PortalExecutiveDashboardController.locationProgramWrapper>> locationStats, list<list<PortalEmailDigestHelper.employeeDigestSubClass>>eList){	
		this.locationStats = locationStats;
		//this.employeeStatsMap = employeeStatsMap;
		this.p = po;
		this.eList = eList;
	}
	/***********************************/
	public Messaging.SingleEmailMessage createEmail(){
		string frequency = frequencyLine();
		string topBody = topBody();
		string accountHeader = headerLarge(p.Contact__r.Account.Name);
		string locationHeader = header('LOCATION STATISTICS', 'center');
		string locationBody = locationBody();
		string employeeHeader1 = header('SCREENING NEEDED', 'center');
		employeeHeader1 += '<p style="font-style:italic">The following recent hires should call <phone style="font-weight:bold; font-style:italic;">800-779-3660</phone> and provide their store number and their Social Security Number.</p>';
		string employeeBody1 = employeeBody(elist[0], false);
		string screening;
		if(elist[0] != null && elist[0].size()>0) screening = employeeHeader1+employeeBody1;
		else screening = '';
		string employeeHeader2 = header('DOCUMENTS NEEDED', 'center');
		employeeHeader2 += '<p style="font-style:italic">The following employees have been screened, but TCC has not yet received the necessary paperwork. Please collect the paperwork from the employee as previously instructed and fax it to<phone style="font-weight:bold; font-style:italic;">855-927-0700.</phone></p>';
		string employeeBody2 = employeeBody(elist[1], true);
		string documents;
		if(elist[1] != null && elist[1].size()>0) documents = employeeHeader2+employeeBody2;
		else documents = '';
		
		String emailBody;
		//if(locationBody != 'none' && employeeBody1 != 'none' && employeeBody2 != 'none') emailBody= '<body style="width:500px;">'+emptyBody()+'</body>';
		//else  emailBody= '<body style="width:500px;">'+frequency+topBody+accountHeader+locationHeader+locationBody+employeeHeader1+employeeBody1+employeeHeader2+employeeBody2+'</body>';
		//emailBody= '<body style="width:500px;">'+topBody+accountHeader+screening+documents+locationHeader+frequency+locationBody+'</body>';
		if(screening == ''&& documents == '')emailBody= '<body style="width:500px; font-family: Verdana, sans-serif;">'+emptyBody()+'</body>';
		else emailBody= '<body style="width:500px; font-family: Verdana, sans-serif;">'+topBody+screening+documents+'</body>';
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {p.Contact__r.Email};
		mail.setToAddresses(toAddresses);
		mail.setReplyTo('noreply@taxcreditco.com');
		mail.setHtmlBody(emailBody);
		mail.setSubject('Action required – CA Enterprise Zone Tax Credits');
		if(makeAttachment|| test.isRunningTest()) mail.setFileAttachments(makeEmailAttachment());
		return mail;
	}
	/***********************************/
	private string frequencyLine(){
		String val = '<p style="font-style:italic">Your '+p.Frequency__c+' TAX CREDIT CO. Progress Report as of '+String.valueOf(Date.today())+'</p>';
		return val;
	}
	/***********************************/
	private string topBody(){
		string val = '<style>table{background-color:white;width:100%;} table tr th{background-color:white;} table tr td{text-align:center;} body{font-family: Verdana, sans-serif;}</style>';
		//val += '<p>Dear '+p.Contact__r.Name +',</p>';
		//val+='<p>Below is a '+ p.Frequency__c.toLowerCase()+' snapshot of your tax incentive screening activity at your ';
		String aName = (p.Contact__r.Account.ShortName__c != null) ? p.Contact__r.Account.ShortName__c : p.Contact__r.Account.Name;
		val += '<p>';
		val += aName;
		val += ' has engaged Tax Credit Co. to manage the process of determining eligibility and obtaining documentation related to available tax credits for hiring eligible employees. In order for '+aName+' to obtain the tax credits, employees must participate in the phone screening process and store managers must submit the appropriate paperwork. Our records indicate that the employees listed below still need to be screened for the tax credit or their paperwork is outstanding. ';
		val += '</p>';
		val += '<p>Qualifying credits can earn your store up to $10,000, so please follow up on the these actions if you have not already done so. For any questions on the process or to print the forms, please refer to the procedures on Storenet(Storenet>Payroll>Forms>California Enterprise Zone Credit—New Hire Procedures)';
		//val += '<a href="http://www.login.salesforce.com">[link]</a></p>';
		//val+='<br/><a href="https://c.na1.visual.force.com/apex/PortalHomePage" style="color:blue;">View full statistics for locations</a>';//ADD LINKS HERE!!!!!!!!
		return val;
	}
	/***********************************/
	public String emptyBodyTest(){
		if(test.isRunningTest()) return this.emptyBody();
		else return null;
	}
	private string emptyBody(){
		string val = '<style>table{background-color:white;width:100%;} table tr th{background-color:white;} table tr td{text-align:center;} body{font-family: Verdana, sans-serif;}</style>';
		val+= '<p>There has been no tax incentive screening activity as of '+Datetime.now().format('MM/dd/yy');
		val+=' at your '+p.Contact__r.Account.Name+' location(s) since your last report. However, there may still be action items from earlier that require your attention. Please log in to our Tax Credit Management System to view all available details.</p>';
		val+='<br/><p>Sincerely,</p><p>Tax Credit Co.</p>';
		return val;
	}
	/***********************************/
	private string header(String header, String tAlign){
		String val = '<p style="width:100%; background-color:lightGrey; font-weight:bold; font-size:90%; text-align:'+tAlign+';">';
		val+=header+'</p>';
		return val;
	}
	/***********************************/
	private string headerLarge(String header){
		String val = '<h2 style="width:100%; background-color:lightGrey; font-weight:bold; font-size:110%; text-align:center;">';
		val+=header+'</h2>';
		return val;
	}
	/***********************************/	
	private string locationBody(){
		list<String> progs = new list<String>();
		list<PortalExecutiveDashboardController.locationProgramWrapper> ll;
		String val = '';
		
		progs.addAll(locationStats.keySet());
		if(progs == null || progs.size() == 0) return 'none';
		progs.sort();
		
		Integer i = 0;
		for(string program:progs){
			ll = locationStats.get(program);
			if(ll != null && ll.size()>0){
				 val += generateLocationProgramTable(program, ll);
				 i=i+1;
			}
			if(i== this.MAXSIZE){					//make only list of size 20. If greater make csv attachment. 
				makeAttachment = true;
				break;
			}
		}
		
		if(val.length() < 5) return 'none';
		else return val;
	}
	/***********************************/
	private string generateLocationProgramTable(String program, list<PortalExecutiveDashboardController.locationProgramWrapper> llList){
		String val = header('Program: '+program, 'center');
		val+= '<table style="border-collapse:collapse; background-color:white;width:100%;"><tr><th style="text-align:left;">Location</th><th colspan="2">Screening Compliance</th><th colspan="2">Document Compliance</th><th colspan="2">Qualification Rate</th></tr>';
		for(PortalExecutiveDashboardController.locationProgramWrapper ll : llList){
			val += '<tr>';
			//val += '<td style="background-color:white; text-align:left;"><a href="https://c.na1.visual.force.com/apex/PortalLocationEmployeeStats?locId='+ll.lp.location__c+'&startD=&endD=&prog='+ll.lp.Program__r.ShortName__c+'">'+ll.lp.location__r.Name+'</a></td>';
			val += '<td style="background-color:white; text-align:left;">'+ll.lp.location__r.Name+'</td>';
			val += '<td style="background-color:white; text-align:right; border-right: 1px solid lightgrey; ">'+ll.PortalScreeningComplianceNum+'/'+ll.PortalScreeningComplianceDenom+'</td><td style="background-color:white; text-align:left; border-left: 1px solid lightgrey; ">'+string.valueOf(ll.getScreeningCompliancePCNT())+'%</td>';
			val += '<td style="background-color:white; text-align:right; border-right: 1px solid lightgrey; ">'+ll.documentNum+'/'+ll.documentDenom+'</td><td style="background-color:white; text-align:left; border-left: 1px solid lightgrey; ">'+string.valueOf(ll.getDocumentCompliancePCNT())+'%</td>';
			val += '<td style="background-color:white; text-align:right; border-right: 1px solid lightgrey; ">'+ll.PortalQualificationNum+'/'+ll.PortalScreeningComplianceDenom+'</td><td style="background-color:white; text-align:left; border-left: 1px solid lightgrey; ">'+string.valueOf(ll.getQualificationRatePCNT())+'%</td>';
			//val += '<td style="background-color:white;">0/'+ll.PortalQualificationNum+' - '+string.valueOf(ll.getDocumentCompliancePCNT())+'%</td>';
			val += '</tr>';
		}
		val+='</table>';
		return val;
	}
	/***********************************/
	private string employeeBody(list<PortalEmailDigestHelper.employeeDigestSubClass> eListl, boolean includeDocs){
		//list<String> progs = new list<String>();
		//list<PortalEmailDigestHelper.employeeDigestSubClass> es;
		String val = '';
		/*
		progs.addAll(locationStats.keySet());
		if(progs == null || progs.size() == 0) return '';
		progs.sort();
		
		for(string program:progs){
			es = employeeStatsMap.get(program);
			if(es != null && es.size()>0) val += generateEmployeeProgramTable(program, es);
		}
		*/
		integer i =0;
		if(eListl == null || eListl.size()==0) return 'none';
		integer endVal;
		if(eList.size()>this.MAXSIZE +5){
			endVal = this.MAXSIZE;
			this.makeAttachment = true;
		}
		else endVal = this.MAXSIZE + 5;
		if(includeDocs)
			val+= '<table style="background-color:white;width:100%;"><tr><th style="text-align:left;">Employee Name</th><th style="text-align:left;">SSN</th><th style="text-align:left;">Hired</th><th>Documents Needed</th><th>Documents to Replace</th></tr>';
		else
			val+= '<table style="background-color:white;width:100%;"><tr><th style="text-align:left;">Employee Name</th><th style="text-align:left;">SSN</th><th style="text-align:left;">Hired</th></tr>';
		for(PortalEmailDigestHelper.employeeDigestSubClass es :eListl){
			if(i == endVal){
				break;
			}
			val += '<tr>';
			val += '<td style="background-color:white; text-align:left;">'+es.name+'</td>';
			if(es.ssn!=null && es.ssn.length()>4)
				val += '<td style="background-color:white; text-align:left;">***-**-'+es.ssn.substring(es.ssn.length()-4,  es.ssn.length())+'</td>';
			else
				val += '<td style="background-color:white; text-align:left;">—</td>';
			val += '<td style="background-color:white; text-align:left;">'+es.hiredDate+'</td>';
			if(includeDocs){
				val+='<td style="background-color:white; text-align:left;">'+es.dNeeded+'</td>';
				val+='<td style="background-color:white; text-align:left;">'+es.dReplace+'</td>';
			}
				
			val += '</tr>';
			i = i+1;
		}
		val += '</table>';
		
		if(eListl.size() > endVal){
			val+='<p>Displaying '+String.valueOf(endVal) +' of '+ string.valueOf(eListl.size())+' employees. Please find the full list in the attached file.</p>';						
		}
		return val;
	}
	/************************************/
	private list <Messaging.Emailfileattachment> makeEmailAttachment(){
		list <Messaging.Emailfileattachment> rVal = new list<Messaging.Emailfileattachment>();
		String strBody = '';
		if(eList[0] != null && eList[0].size() > 0){
			strBody += 'Unscreened Employees \n';
			strBody += employeeAttachmentBody(eList[0], false);
			strBody += '\n';
		}
		if(eList[1] != null && eList[1].size() > 0){
			strBody += '\n Undocumented Employees \n';
			strBody += employeeAttachmentBody(eList[1], true);
			strBody += '\n';
		}
		//string lbody = locationAttachmentBody();
		//if(lbody != null && lbody.length()>30)
		//	strBody += lbody;
		blob b = blob.valueOf(strBody);
		Messaging.Emailfileattachment a = new Messaging.Emailfileattachment();
		a.setBody(b);
		//a.setContentType('csv');
		a.setFileName('digestStats.csv');
		rVal.add(a);
		return rVal;
	}
	/************************************/
	private string locationAttachmentBody(){
		String val = 'Location Statistics \n';
		list<String> progs = new list<String>();
		list<PortalExecutiveDashboardController.locationProgramWrapper> ll;
		
		progs.addAll(locationStats.keySet());
		if(progs == null || progs.size() == 0) return val;
		progs.sort();
		
		for(string program:progs){
			ll = locationStats.get(program);
			if(ll != null && ll.size()>0){
				 val += generateLocationProgramTableForAttachment(program, ll);
			}
		}
		
		if(val.length() < 5) return val+'\n';
		else return val;
	}
	/************************************/
	private string generateLocationProgramTableForAttachment(String program, list<PortalExecutiveDashboardController.locationProgramWrapper> llList){
		String val ='\n Program: '+program+'\n';
		val+= 'Location, Screening Compliance, , Document Compliance, , Qualification Rate, \n';
		for(PortalExecutiveDashboardController.locationProgramWrapper ll : llList){
			val += ll.lp.location__r.Name+', ';
			val += ll.PortalScreeningComplianceNum+' / '+ll.PortalScreeningComplianceDenom+', '+string.valueOf(ll.getScreeningCompliancePCNT())+'%, ';
			val += ll.documentNum+', '+ll.documentDenom+', '+string.valueOf(ll.getDocumentCompliancePCNT())+'%, ';
			val += ll.PortalQualificationNum+' / '+ll.PortalScreeningComplianceDenom+', '+string.valueOf(ll.getQualificationRatePCNT())+'%';
			val += '\n';
		}
		return val;
	}
	/************************************/
	 private string employeeAttachmentBody(list<PortalEmailDigestHelper.employeeDigestSubClass> eListl, boolean addDocs){
	 	string val ='';
		if(eListl == null || eListl.size()==0) return '';
		if(addDocs)
			val+= 'Last Name, First Name,  SSN, Hired, Documents Needed, Documents to Replace\n';
		else
			val+= 'Last Name, First Name,  SSN, Hired\n';
		for(PortalEmailDigestHelper.employeeDigestSubClass es :eListl){
			val += es.name+',';
			if(es.ssn!=null && es.ssn.length()>4)
				val += '***-**-'+es.ssn.substring(es.ssn.length()-4,  es.ssn.length())+',';
			else
				val += '— ,';
			val += es.hiredDate;
			if(addDocs){
				val+=',';
				val+=' '+es.dNeeded+',';
				val+=' '+es.dReplace;
			}
			val+='\n';
			//val += es.screened+', ';
			//val += es.documentStatus+', ';
			//val += es.qualified+'\n';
		}
		val += '\n';
	 	return val;
	 }
	/***********************************
	private string generateEmployeeProgramTable(string program, list<PortalEmailDigestHelper.employeeDigestSubClass> esList){
		String val = header('Program: '+program, 'left');
		val+= '<table><tr><th style="text-align:left;">Name</th><th>Hired</th><th>Status</th><th>Documents</th><th>Qualified</th></tr>';
		for(PortalEmailDigestHelper.employeeDigestSubClass es :esList){
			val += '<tr>';
			val += '<td style="background-color:white; text-align:left;">'+es.name+'</td>';
			val += '<td style="background-color:white; text-align:center;">'+es.hiredDate+'</td>';
			val += '<td style="background-color:white; text-align:center;">'+es.screened+'</td>';
			val += '<td style="background-color:white; text-align:center;">'+es.documentStatus+'</td>';
			val += '<td style="background-color:white; text-align:center;">'+es.qualified+'</td>';
			//val += '<td style="background-color:white; text-align:center;">'+es.documents+'</td>';
			val += '</tr>';
		}
		val += '</table>';
		return val;
	}
	***********************************/
}