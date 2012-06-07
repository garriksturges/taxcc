public class PortalModuleEmailHelper {
	private integer NUMBEROFROWS = 20;
	public PortalModuleEmailHelper(){}
	set <string> ahmSet;
	private map  <string, list<PortalExecutiveDashboardController.locationProgramWrapper>> locationStats;
	private list<PortalNotificationContent__c> pncList;
	/******************************/
	public map<string, list<PortalNotificationModule__c>> makeContactToPNMMap(list<PortalNotificationModule__c> pnmList){
		map<String, list<PortalNotificationModule__c>> cMap = new map<String, list<PortalNotificationModule__c>>();
		list<PortalNotificationModule__c> subList;
		for(PortalNotificationModule__c pnm:pnmList){
			sublist = cMap.get(pnm.PortalNotificationSchedule__r.Contact__c);
			if(sublist==null) subList = new list<PortalNotificationModule__c>();
			sublist.add(pnm);
			cMap.put(pnm.PortalNotificationSchedule__r.Contact__c, sublist);
		}
		return cMap;
	}
	/******************************/
	public map<string, list<PortalNotificationContent__c>> makeContactToPNCMap(list<string> pnsIds){
		map<String, list<PortalNotificationContent__c>> cMap = new map<String, list<PortalNotificationContent__c>>();
		pncList = makePNCList(pnsIds);
		list<PortalNotificationContent__c> subList;
		for(PortalNotificationContent__c pnc:pncList){
			sublist = cMap.get(pnc.PortalNotificationModule__r.PortalNotificationSchedule__r.Contact__c);
			if(sublist==null) subList = new list<PortalNotificationContent__c>();
			sublist.add(pnc);
			cMap.put(pnc.PortalNotificationModule__r.PortalNotificationSchedule__r.Contact__c, sublist);
		}
		return cMap;
	}
	/******************************/
	//create list of emails, one for each contact in map
	public void generateAndSendEmailForEachContact(map<string, list<PortalNotificationContent__c>> cToPncMap, map<string, list<PortalNotificationModule__c>> cToPnmMap){
		//for eachContact generate email
		//set <string> ahmSet;
		//map  <string, list<PortalExecutiveDashboardController.locationProgramWrapper>> locationStats;
		//set <string> keys = cToPncMap.keySet();
		set <string> keys = cToPnmMap.keySet();
		//list<PortalNotificationContent__c> pncList;
		list<PortalNotificationModule__c> pnmList;
		
		list<list<PortalEmailDigestHelper.employeeDigestSubClass>> eList;
		String bodyText;
		String screeningText;
		String documentText;
		String complianceSummary;
		Messaging.SingleEmailMessage[] emailList = new List<Messaging.SingleEmailMessage>();
		
		list<String> pnsUpdateList = new list<String>();
		list<PortalNotification__c> pnList = new list <PortalNotification__c>();
		list<Attachment> aList = new list <Attachment>();
		
		Messaging.SingleEmailMessage mail;
		String emailBody;
		String emailText;
		String[] toAddresses;
		for(String cId: keys){
			ahmSet = null;
			locationStats = null;
			pncList = null;
			pncList = cToPncMap.get(cId);
			pnmList = cToPnmMap.get(cId);

			bodyText = makeBodyText();
			screeningText = makeScreeningText(pnmList, eList);
			documentText = makeDocumentText(pnmList, eList);
			complianceSummary = makeComplianceSummary(pnmList);	
			
			emailText=bodyText+screeningText+documentText+complianceSummary;
			if(emailText!=null && emailText.length()>0){
				mail = new Messaging.SingleEmailMessage();
				emailBody= '<body style="width:500px; font-family: Verdana, sans-serif;">'+emailText+'</body>';
				toAddresses = new String[] {pncList[0].PortalNotificationModule__r.PortalNotificationSchedule__r.Contact__r.Email};
				mail.setToAddresses(toAddresses);
				mail.setReplyTo('noreply@taxcreditco.com');
				mail.setHtmlBody(emailBody);
				mail.setSubject('Tax Credit Co Email Digest');
				emailList.add(mail);
				pnsUpdateList.add(pncList[0].PortalNotificationModule__r.PortalNotificationSchedule__c);
				pnList.add(makePn(pncList[0].PortalNotificationModule__r.PortalNotificationSchedule__c));
				aList.add(makePnAttachment(mail));
			}
		}
		sendUpdateAndInsertMail(emailList, pnsUpdateList, pnList, aList);
	}
	/******************************/
	public void sendUpdateAndInsertMail(Messaging.SingleEmailMessage[] emailList, list<String> pnsUpdateList, list<PortalNotification__c> pnList, list<Attachment> aList){
		PortalNotification__c pn;
		Attachment a;		
		list<PortalNotificationSchedule__c> pnsList = [Select p.PreviousDigestDateSummary__c,
																									 p.NextDigestDate__c, p.Frequency__c, p.DigestType__c, 
																									 p.Contact__c 
																									 From PortalNotificationSchedule__c p
																									 where id in :pnsUpdateList];
		for(PortalNotificationSchedule__c pns : pnsList){
			updatePortalNotificationInfo(pns);
		}
		Messaging.SendEmailResult[] rs = Messaging.sendEmail(emailList);
		update pnsList;
		insert pnList;
		for(integer i=0; i<pnList.size(); i++){
				pn = pnList[i];
				a = aList[i];
				a.ParentId = pn.id;
		}
		insert aList;
																									 
	}
	/******************************/
	public string makeBodyText(){
		list<PortalNotificationContent__c> pncBodyList = new list<PortalNotificationContent__c>();
		//get all PNC where Module is body
		for(PortalNotificationContent__c pnc : pncList){
			if(pnc.PortalNotificationModule__r.ContentModule__c!=null && pnc.PortalNotificationModule__r.ContentModule__r.Name != null && pnc.PortalNotificationModule__r.ContentModule__r.Name.equalsIgnoreCase('body'))
				pncBodyList.add(pnc);
		}
		if(pncBodyList.size()==0)return '';
		else return orderBodyText(pncBodyList);
	}
	/******************************/
	public string orderBodyText(list<PortalNotificationContent__c> pncBodyList){
		String Intro ='';
		String Outro='';
		String Preamble='';
		String Footnote='';
		for(PortalNotificationContent__c pnc: pncBodyList){
			if(pnc.ContentType__c != null && pnc.ContentType__r.Name!=null && pnc.ContentType__r.Name.equalsIgnoreCase('intro'))
				Intro = pnc.contentText__c;
			if(pnc.ContentType__c != null && pnc.ContentType__r.Name!=null && pnc.ContentType__r.Name.equalsIgnoreCase('Outro'))
				outro = pnc.contentText__c;
			if(pnc.ContentType__c != null && pnc.ContentType__r.Name!=null && pnc.ContentType__r.Name.equalsIgnoreCase('Preamble'))
				Preamble = pnc.contentText__c;
			if(pnc.ContentType__c != null && pnc.ContentType__r.Name!=null && pnc.ContentType__r.Name.equalsIgnoreCase('Footnote'))
				Footnote = pnc.contentText__c;
		}
		return intro+outro+Preamble+'<div style="font-size: 80%;">'+Footnote+'</div>'+'<div style="height:15px;"></div>';
	}
	/******************************/
	public string makeScreeningText(list<PortalNotificationModule__c> pnmList,  list<list<PortalEmailDigestHelper.employeeDigestSubClass>> eList){
		//Screening Needed
		list<PortalNotificationModule__c> pnmScreeningList = new list<PortalNotificationModule__c>();
		//get all PNC where Module is screening
		for(PortalNotificationModule__c pnm : pnmList){
			if(pnm.ContentModule__c!=null && pnm.ContentModule__r.Name != null && pnm.ContentModule__r.Name.equalsIgnoreCase('Screening Needed'))
				pnmScreeningList.add(pnm);
		}
		if(pnmScreeningList.size()==0)return '';
		else return makeScreeningInfo(pnmScreeningList, eList);
	}
	/******************************/
	public string makeScreeningInfo(list<PortalNotificationModule__c> pnmScreeningList,  list<list<PortalEmailDigestHelper.employeeDigestSubClass>> eList){
		if(ahmSet == null) setupAHM( pnmScreeningList[0]);
		if(locationStats==null) generateLocationStats( pnmScreeningList[0]);
		if(locationStats==null) return '';
		
		if(eList == null){
			PortalEmailDigestHelper peh = new PortalEmailDigestHelper(locationStats);
			//map<String, list<PortalEmailDigestHelper.employeeDigestSubClass>> employeeStatsMap = peh.generateEmployeeMap(Date.today().addDays(-90), Date.today());
			Date sd = getStartDate('Screening Needed');
			map<String, list<PortalEmailDigestHelper.employeeDigestSubClass>> employeeStatsMap = peh.generateEmployeeMap(sd, Date.today());
			eList = peh.generateSingleEmployeeLists(employeeStatsMap);
			//system.assert(false, elist[0].size());
		}
		return makeScreeningInfoText(eList[0]);
	}
	/******************************/
	public string makeScreeningInfoText(list<PortalEmailDigestHelper.employeeDigestSubClass> screens){
		if(screens == null || screens.size()==0) return '';
		//system.assert(false, screens.size());
		String val = '<div style="font-family: Verdana, sans-serif;">';
		val+= header('SCREENING NEEDED', 'center');
		val+=makeBeginningText('Screening Needed');
		integer i =0;
		val+='<table style="background-color:white;width:100%; border: solid 1.5px darkgray; border-collapse: collapse; border: solid 1.5px darkgray;"><tr><th style="text-align:left;font-family: Verdana, sans-serif;border: solid 1.5px darkgray;">Employee Name</th><th style="text-align:center;font-family: Verdana, sans-serif;border: solid 1.5px darkgray;">SSN</th><th style="text-align:center; font-family: Verdana, sans-serif;border: solid 1.5px darkgray;">Hired</th></tr>';
		for(PortalEmailDigestHelper.employeeDigestSubClass es :screens){
			if(i == this.NUMBEROFROWS){
				break;
			}
			val += '<tr>';
			val += '<td style="background-color:white; text-align:left; border: solid 1.5px darkgray;"><span style="font-family: Verdana, sans-serif;">'+es.name+'</span></td>';

			if(es.ssn!=null && es.ssn.length()>4)
				val += '<td style="background-color:white; text-align:center; border: solid 1.5px darkgray;"><span style="font-family: Verdana, sans-serif;">***-**-'+es.ssn.substring(es.ssn.length()-4,  es.ssn.length())+'</span></td>';
			else
				val += '<td style="background-color:white; text-align:center; border: solid 1.5px darkgray;">—</td>';

			val += '<td style="background-color:white; text-align:center;border: solid 1.5px darkgray;"><span style="font-family: Verdana, sans-serif;">'+es.hiredDate+'</span></td>';
			val += '</tr>';
			i = i+1;
		}
		if(i==0) return '';
		val += '</table>';
		val+=makeEndingText('Screening Needed');
		val += '</div>';
		return val;
	}
	/******************************/
	public string makeDocumentText(list<PortalNotificationModule__c> pnmList,  list<list<PortalEmailDigestHelper.employeeDigestSubClass>> eList){
		list<PortalNotificationModule__c> pnmDocList = new list<PortalNotificationModule__c>();
		for(PortalNotificationModule__c pnm : pnmList){
			if(pnm.ContentModule__c!=null && pnm.ContentModule__r.Name != null && pnm.ContentModule__r.Name.equalsIgnoreCase('Documents Needed'))
				pnmDocList.add(pnm);
		}
		if(pnmDocList.size()==0)return '';
		else return makeDocumentInfo(pnmDocList, eList);
	}
	/******************************/
	public string makeDocumentInfo(list<PortalNotificationModule__c> pnmDocList, list<list<PortalEmailDigestHelper.employeeDigestSubClass>> eList){
		if(ahmSet == null) setupAHM(pnmDocList[0]);
		if(locationStats==null) generateLocationStats( pnmDocList[0]);
		if(locationStats==null) return '';
		if(eList == null){
			PortalEmailDigestHelper peh = new PortalEmailDigestHelper(locationStats);
			//map<String, list<PortalEmailDigestHelper.employeeDigestSubClass>> employeeStatsMap = peh.generateEmployeeMap(Date.today().addDays(-90), Date.today());
			Date sd = getStartDate('Documents Needed');
			map<String, list<PortalEmailDigestHelper.employeeDigestSubClass>> employeeStatsMap = peh.generateEmployeeMap(sd, Date.today());
			eList = peh.generateSingleEmployeeLists(employeeStatsMap);
		}
		return makeDocumentInfoText(eList[1]);
	}
	/******************************/
	public string makeDocumentInfoText(list<PortalEmailDigestHelper.employeeDigestSubClass> screens){
		//system.assert(false, screens.size());
		if(screens == null || screens.size() == 0) return '';
		String val = '<div style="font-family: Verdana, sans-serif;">';
		val+= header('DOCUMENTS NEEDED', 'center');
		val+= makeBeginningText('Documents Needed');
		val+='<table style="background-color:white;width:100%; border: solid 1.5px darkgray; border-collapse: collapse;border: solid 1.5px darkgray;"><tr><th style="text-align:left;font-family: Verdana, sans-serif;border: solid 1.5px darkgray;"><span style="font-family: Verdana, sans-serif;">Employee Name</span></th><th style="text-align:center; font-family: Verdana, sans-serif;border: solid 1.5px darkgray;">SSN</th><th style="text-align:left;border: solid 1.5px darkgray;"><span style="font-family: Verdana, sans-serif;">Hired</span></th><th style="border: solid 1.5px darkgray;"><span style="font-family: Verdana, sans-serif;">Documents Needed</span></th><th style="border: solid 1.5px darkgray;"><span style="font-family: Verdana, sans-serif;">Documents to Replace</span></th></tr>';
		integer i =0;
		for(PortalEmailDigestHelper.employeeDigestSubClass es :screens){
			if(i == this.NUMBEROFROWS){
				break;
			}
			val += '<tr>';
			val += '<td style="background-color:white; text-align:left; border: solid 1.5px darkgray;"><span style="font-family: Verdana, sans-serif;">'+es.name+'</span></td>';
			if(es.ssn!=null && es.ssn.length()>4)
				val += '<td style="background-color:white; text-align:center; border: solid 1.5px darkgray;"><span style="font-family: Verdana, sans-serif;">***-**-'+es.ssn.substring(es.ssn.length()-4,  es.ssn.length())+'</span></td>';
			else
				val += '<td style="background-color:white; text-align:center;">—</td>';

			val+= '<td style="background-color:white; text-align:left; border: solid 1.5px darkgray;"><span style="font-family: Verdana, sans-serif;">'+es.hiredDate+'</span></td>';
			val+='<td style="background-color:white; text-align:center; border: solid 1.5px darkgray;"><span style="font-family: Verdana, sans-serif;">'+es.dNeeded+'</span></td>';
			val+='<td style="background-color:white; text-align:center; border: solid 1.5px darkgray;"><span style="font-family: Verdana, sans-serif;">'+es.dReplace+'</span></td>';
				
			val += '</tr>';
			i = i+1;
		}
		val += '</table>';
		val +=makeEndingText('Documents Needed');
		val += '</div>';
		return val;
	}
	/******************************/
	public string makeComplianceSummary(list<PortalNotificationModule__c> pnmList){
		list<PortalNotificationModule__c> pnmCompList = new list<PortalNotificationModule__c>();
		for(PortalNotificationModule__c pnm : pnmList){
			if(pnm.ContentModule__c!=null && pnm.ContentModule__r.Name != null && pnm.ContentModule__r.Name.equalsIgnoreCase('Compliance Summary'))
				pnmCompList.add(pnm);
		}
		if(pnmCompList.size()==0)return '';
		else return makeCompInfo(pnmCompList);
	}
	/******************************/
	public string makeCompInfo(list<PortalNotificationModule__c> pnmDocList){
		
		if(ahmSet == null) setupAHM(pnmDocList[0]);
		if(locationStats==null) generateLocationStats(pnmDocList[0]);
		if(locationStats==null) return '';
		map <String, list<PortalExecutiveDashboardController.locationProgramWrapper>> rValFiltered = new map <String, list<PortalExecutiveDashboardController.locationProgramWrapper>>();
		list<PortalExecutiveDashboardController.locationProgramWrapper> locList;
		//setupMap with stat values
		set<String> programList = locationStats.keySet();
		for(String prog : programList){
			 locList = locationStats.get(prog);
			 if(locList != null&&locList.size()>0){
			 	//PortalScreeningComplianceHelper.setupPSC(locList, Date.today().addDays(-90), Date.today());
			 	Date sd = getStartDate('Compliance Summary');
			 	PortalScreeningComplianceHelper.setupPSC(locList, sd, Date.today());
			 	locList = filterOutZeros(locList);
			 	if(locList !=null && locList.size()>0) 
			 	 rValFiltered.put(prog, locList);
			 }			 	
		}
		locationStats = rValFiltered;
		return makeCompInfoText();
	}
	/******************************/
	public string makeCompInfoText(){
		if(locationStats==null || locationStats.size()==0) return '';
		String val='<div style="font-family: Verdana, sans-serif;">';
		val+=header('LOCATION STATISTICS', 'center');
		val+=makeBeginningText('Compliance Summary');
		list<String> progs = new list<String>();
		list<PortalExecutiveDashboardController.locationProgramWrapper> ll;
		progs.addAll(locationStats.keySet());
		if(progs == null || progs.size() == 0) return '';
		progs.sort();
		
		for(string program:progs){
			ll = locationStats.get(program);
			if(ll != null && ll.size()>0){
				 val += generateLocationProgramTable(program, ll);
			}
		}
		val+=makeEndingText('Compliance Summary');
		val+='</div>';
		return val;
	}
	/******************************/
	/***********************************************/
	public Attachment makePnAttachment(Messaging.SingleEmailMessage mail){
		Attachment a = new Attachment();
		a.Body =  blob.valueOf(mail.getHtmlBody());
		a.ContentType = 'html';
		a.Name = string.valueOf(Date.today())+'_emaildigest';
		return a;
	}
	/***********************************************/
	public PortalNotification__c makePn(String pnId){
		PortalNotification__c pn = new PortalNotification__c();
		pn.PortalNotificationSchedule__c = pnId;
		pn.DataStartDate__c = Date.today().adddays(-90);
		pn.DataEndDate__c = Datetime.now();
		pn.ContentBitGenerated__c = true;
		pn.LocationCountGenerated__c=0;
		pn.EmployeeCountGenerated__c=0;
		//pn.LocationCountGenerated__c = getLocCount(locationStats);
		//pn.EmployeeCountGenerated__c = getEmployeeCount(employeeStatsMap);
		//pn.FrequencyTextGenerated__c = p.Frequency__c;
		return pn;
	}
	/***********************************************/
	public void updatePortalNotificationInfo(PortalNotificationSchedule__c p){
		Date nextDate = Date.today();
			if(p.Frequency__c =='Daily') nextDate = nextDate.addDays(1);
			else if (p.Frequency__c=='Weekly')nextDate = nextDate.addDays(7);
			else if (p.Frequency__c =='Monthly')nextDate = nextDate.addMonths(1);
			else nextDate = nextDate.addMonths(3);
			p.NextDigestDate__c = nextDate;
			
			//check digest type
			if(p.DigestType__c == 'Last'){
				p.DigestType__c = 'Ended';
				p.NextDigestDate__c = null;
			}
			else
				p.DigestType__c = 'Continued';	
	}
	/***********************************/
	private string generateLocationProgramTable(String program, list<PortalExecutiveDashboardController.locationProgramWrapper> llList){
		String val = header('Program: '+program, 'center');
		val+= '<table style="border-collapse:collapse; background-color:white;width:100%;font-family: Verdana, sans-serif;border: solid 1.5px darkgray; border-collapse: collapse;"><tr><th style="text-align:left;border: solid 1.5px darkgray;"><span style="font-family: Verdana, sans-serif;">Location</span></th><th colspan="1" style="border: solid 1.5px darkgray;"><span style="font-family: Verdana, sans-serif;">Screening Compliance</span></th><th colspan="1" style ="border: solid 1.5px darkgray;"><span style="font-family: Verdana, sans-serif;">Document Compliance</span></th><th colspan="1"><span style="font-family: Verdana, sans-serif;">Qualification Rate</span></th></tr>';
		integer i = 0;
		for(PortalExecutiveDashboardController.locationProgramWrapper ll : llList){
			if(i==this.NUMBEROFROWS) break;
			val += '<tr>';
			//val += '<td style="background-color:white; text-align:left;"><a href="https://c.na1.visual.force.com/apex/PortalLocationEmployeeStats?locId='+ll.lp.location__c+'&startD=&endD=&prog='+ll.lp.Program__r.ShortName__c+'">'+ll.lp.location__r.Name+'</a></td>';
			val += '<td style="background-color:white; text-align:left; font-family: Verdana, sans-serif; border: solid 1.5px darkgray; width: 40%;"><span style="font-family: Verdana, sans-serif;">'+ll.lp.location__r.Name+'</span></td>';
			val += '<td style="background-color:white; text-align:center; font-family: Verdana, sans-serif; border: solid 1.5px darkgray;width: 20%;"><span style="font-family: Verdana, sans-serif; ">'+string.valueOf(ll.getScreeningCompliancePCNT())+'% ('+ll.PortalScreeningComplianceNum+'/'+ll.PortalScreeningComplianceDenom+')</span></td>';
			val += '<td style="background-color:white; text-align:center; font-family: Verdana, sans-serif; border: solid 1.5px darkgray;width: 20%;"><span style="font-family: Verdana, sans-serif;">'+string.valueOf(ll.getDocumentCompliancePCNT())+'% ('+ll.documentNum+'/'+ll.documentDenom+')</span></td>';
			val += '<td style="background-color:white; text-align:center; font-family: Verdana, sans-serif; border: solid 1.5px darkgray;width: 20%;"><span style="font-family: Verdana, sans-serif;">'+string.valueOf(ll.getQualificationRatePCNT())+'% ('+ll.PortalQualificationNum+'/'+ll.PortalScreeningComplianceDenom+')</span></td>';
			//val += '<td style="background-color:white;">0/'+ll.PortalQualificationNum+' - '+string.valueOf(ll.getDocumentCompliancePCNT())+'%</td>';
			val += '</tr>';
			i=i+1;
		}
		val+='</table>'+'<div style="height:15px;"></div>';
		return val;
	}
	/******************************/
	public list<PortalExecutiveDashboardController.locationProgramWrapper> filterOutZeros(list<PortalExecutiveDashboardController.locationProgramWrapper> locList){
		list<PortalExecutiveDashboardController.locationProgramWrapper> rVal = new list<PortalExecutiveDashboardController.locationProgramWrapper>();
		for(PortalExecutiveDashboardController.locationProgramWrapper lw : locList){
			if(lw.PortalScreeningComplianceDenom != null && lw.PortalScreeningComplianceDenom != 0) rVal.add(lw);
		}
		return rVal;
	}
	/***********************************************/
	public void setupAHM(PortalNotificationModule__c pnm){
		ahmSet = new Set<string>();
		list<String> childIdList;
		list <AccountHierarchyMember__c> childrenList;
		if(pnm.PortalNotificationSchedule__r.contact__r.AccountHierarchyMember__c == null &&(pnm.PortalNotificationSchedule__r.contact__r.ExecutiveAccessBit__c == null || pnm.PortalNotificationSchedule__r.contact__r.ExecutiveAccessBit__c == false)) return; 
		else{
			childrenList = [select id, ParentAccountHierarchyMember__c, Account__c 
											from AccountHierarchyMember__c
											where ParentAccountHierarchyMember__c = :pnm.PortalNotificationSchedule__r.contact__r.AccountHierarchyMember__c
											and Account__c = :pnm.PortalNotificationSchedule__r.contact__r.Account.id];
	    
	    while(childrenList != null && childrenList.size()>0){
		    childIdList = new list<String>();										
				for(AccountHierarchyMember__c ahm : childrenList){
					childIdList.add(ahm.id);
					ahmSet.add(ahm.id);
				}
				childrenList = [select id, ParentAccountHierarchyMember__c 
												from AccountHierarchyMember__c
												where ParentAccountHierarchyMember__c in :childIdList
												and Account__c = :pnm.PortalNotificationSchedule__r.contact__r.Account.id];										
	    }
		}
	}
	/******************************/
	public void generateLocationStats(PortalNotificationModule__c pnm){
		locationStats = new map <String, list<PortalExecutiveDashboardController.locationProgramWrapper>>();
		list<PortalExecutiveDashboardController.locationProgramWrapper> llList= new list<PortalExecutiveDashboardController.locationProgramWrapper>();
		list<PortalExecutiveDashboardController.locationProgramWrapper> locList;
		list<LocationProgram__c> ll = [Select Program__r.ShortName__c, Program__c, Location__c, Program__r.Name,
	                                Location__r.LongitudeCode__c,
	                                Location__r.LatitudeCode__c,
	                                Location__r.State__r.Name, Location__r.StreetAddressText__c, location__r.State__r.StateAbbr__c,
	                                Location__r.State__c, Location__r.Name, Location__r.LocationEID__c,
	                                Location__r.CityName__c, Location__r.AccountHierarchyMember__c
	                                From LocationProgram__c 
	                                where Location__r.AccountHierarchyMember__c in :ahmSet
	                                AND Location__r.Account__c = :pnm.PortalNotificationSchedule__r.contact__r.accountId
	                                order by Location__r.Name
	                                limit 1000//:max
	                                ]; 
		                             
		for(LocationProgram__c lp : ll){
			llList.add(new PortalExecutiveDashboardController.locationProgramWrapper(lp,'white'));
		}
		for(PortalExecutiveDashboardController.locationProgramWrapper lpw : llList){
			locList = locationStats.get(lpw.lp.Program__r.Name);//using program name rather than short_name
			if(locList == null)locList = new list<PortalExecutiveDashboardController.locationProgramWrapper>();
			locList.add(lpw);
			locationStats.put(lpw.lp.Program__r.Name, locList);//using program name rather than short_name
		} 
	}
	/***********************************/
	private string header(String header, String tAlign){
		String val = '<p style="width:100%; background-color:lightGrey; font-weight:bold; font-size:90%; text-align:'+tAlign+';font-family: Verdana, sans-serif;-webkit-margin-before: 0em;">';
		val+=header+'</p>';
		return val;
	}
	/***********************************/
	public list<PortalNotificationContent__c> makePNCList(list <string> pnsIds){
		return 														[ Select p.PortalNotificationModule__r.ContentModule__c,
																				 p.Data_StartDate__c, p.Data_days__c, 
       																	 p.PortalNotificationModule__r.ContentModule__r.Name,
       																	 p.PortalNotificationModule__r.PortalNotificationSchedule__c, 
       																	 p.PortalNotificationModule__r.PortalNotificationSchedule__r.DigestType__c, 
       																	 p.PortalNotificationModule__r.PortalNotificationSchedule__r.NextDigestDate__c,
       																	 p.PortalNotificationModule__r.Name, p.PortalNotificationModule__c, 
       																	 p.ContentType__c, p.ContentType__r.Name, 
       																	 p.ContentText__c,
       																	 p.PortalNotificationModule__r.PortalNotificationSchedule__r.Contact__c,
																				 p.PortalNotificationModule__r.PortalNotificationSchedule__r.Contact__r.AccountHierarchyMember__c, 
																				 p.PortalNotificationModule__r.PortalNotificationSchedule__r.Contact__r.Id, 
																				 p.PortalNotificationModule__r.PortalNotificationSchedule__r.Contact__r.ExecutiveAccessBit__c, 
																				 p.PortalNotificationModule__r.PortalNotificationSchedule__r.Contact__r.AccountId, 
																				 p.PortalNotificationModule__r.PortalNotificationSchedule__r.Contact__r.Account.Name, 
																				 p.PortalNotificationModule__r.PortalNotificationSchedule__r.Contact__r.Name, 
																				 p.PortalNotificationModule__r.PortalNotificationSchedule__r.Contact__r.Email, 
																				 p.PortalNotificationModule__r.PortalNotificationSchedule__r.Contact__r.Account.ShortName__c
       																	 From PortalNotificationContent__c p
																				 where PortalNotificationModule__r.PortalNotificationSchedule__c in :pnsIds];
	}
/******************************/
	public string makeBeginningText(string filter){
		list<PortalNotificationContent__c> pncTextList = new list<PortalNotificationContent__c>();
		//get all PNC where Module is body
		for(PortalNotificationContent__c pnc : pncList){
			if(pnc.PortalNotificationModule__r.ContentModule__c!=null && pnc.PortalNotificationModule__r.ContentModule__r.Name != null && pnc.PortalNotificationModule__r.ContentModule__r.Name.equalsIgnoreCase(filter))
				pncTextList.add(pnc);
		}
		if(pncTextList.size()==0)return '';
		else return orderBeginText(pncTextList);
	}
	/******************************/
	public string orderBeginText(list<PortalNotificationContent__c> pncTextList){
		String Intro ='';
		//String Outro='';
		String Preamble='';
		//String Footnote='';
		for(PortalNotificationContent__c pnc: pncTextList){
			if(pnc.ContentType__c != null && pnc.ContentType__r.Name!=null && pnc.ContentType__r.Name.equalsIgnoreCase('intro'))
				Intro = '<div style="height:15px;"></div>'+pnc.contentText__c;
			if(pnc.ContentType__c != null && pnc.ContentType__r.Name!=null && pnc.ContentType__r.Name.equalsIgnoreCase('Preamble'))
				Preamble = '<div style="height:15px;"></div>'+pnc.contentText__c;
		}
		return intro+Preamble+'<div style="height:15px;"></div>'+'<br />';
	}
	/******************************/	
		public string makeEndingText(string filter){
		list<PortalNotificationContent__c> pncTextList = new list<PortalNotificationContent__c>();
		//get all PNC where Module is body
		for(PortalNotificationContent__c pnc : pncList){
			if(pnc.PortalNotificationModule__r.ContentModule__c!=null && pnc.PortalNotificationModule__r.ContentModule__r.Name != null && pnc.PortalNotificationModule__r.ContentModule__r.Name.equalsIgnoreCase(filter))
				pncTextList.add(pnc);
		}
		if(pncTextList.size()==0)return '';
		else return orderEndText(pncTextList);
	}
	/******************************/
	public string orderEndText(list<PortalNotificationContent__c> pncTextList){
		//String Intro ='';
		String Outro='';
		//String Preamble='';
		String Footnote='';
		for(PortalNotificationContent__c pnc: pncTextList){
			if(pnc.ContentType__c != null && pnc.ContentType__r.Name!=null && pnc.ContentType__r.Name.equalsIgnoreCase('Outro'))
				Outro = '<div style="height:15px;"></div>'+pnc.contentText__c;
			if(pnc.ContentType__c != null && pnc.ContentType__r.Name!=null && pnc.ContentType__r.Name.equalsIgnoreCase('Footnote'))
				Footnote = '<div style="height:15px;"></div><div style="font-size: 80%;">'+pnc.contentText__c+'</div>';
		}
		return '<br />'+Outro+Footnote+'<div style="height:15px;"></div><br />';
	}
	/******************************/	
	public Date  getStartDate(string filter){
		list<PortalNotificationContent__c> pncdList = new list<PortalNotificationContent__c>();
		//get all PNC where Module is body
		for(PortalNotificationContent__c pnc : pncList){
			if(pnc.PortalNotificationModule__r.ContentModule__c!=null && pnc.PortalNotificationModule__r.ContentModule__r.Name != null && pnc.PortalNotificationModule__r.ContentModule__r.Name.equalsIgnoreCase(filter))
				pncdList.add(pnc);
		}
		if(pncdList.size()==0)return Date.today().addDays(-90);
		else return findStartDate(pncdList);
	}
	/******************************/
	public Date findStartDate(list<PortalNotificationContent__c> pncdList){
		for(PortalNotificationContent__c pnc: pncdList){
			if(pnc.Data_StartDate__c != null)
				return pnc.Data_StartDate__c;
			if(pnc.Data_days__c != null)
				return Date.today().addDays(-1*Integer.valueOf(pnc.Data_days__c));
		}
		return Date.today().addDays(-90);
	}
}