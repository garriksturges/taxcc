global class PortalEmailDigestListCreate {
	public Attachment a;
	public PortalNotification__c pn;
	public Datetime prevDate;
	public Messaging.SingleEmailMessage[] emailList;
	public list <PortalNotificationSchedule__c>pNotificationList;
	public list<PortalNotification__c> pnList;
	public list<Attachment> attachments;
	/***********************************************/
	public PortalEmailDigestListCreate(){
		emailList = new List<Messaging.SingleEmailMessage>();
		pNotificationList = new list<PortalNotificationSchedule__c>();
		pnList = new list<PortalNotification__c>();
		attachments = new list<Attachment>();
	}
	/***********************************************/
	public void sendUpdateAndInsertInfo(){
			Messaging.sendEmail(emailList);
			update pNotificationList;
			insert pnList;
			for(integer i=0; i<pnList.size(); i++){
				pn = pnList[i];
				a = attachments[i];
				a.ParentId = pn.id;
			}
			insert attachments;
		}
	/***********************************************/
	public void addToLists(PortalNotificationSchedule__c p){
		//setup Dates
		p.NextDigestDate__c = date.today();
		prevDate = setupSendingDates(p);
		//prevDate = prevDate.addYears(-91); //FOR TESTING!!!!!!!
		//map of program to location statistics
		map  <string, list<PortalExecutiveDashboardController.locationProgramWrapper>> locationStats = generateLocationMapStatistics(p, prevDate);//programList);
		//map of program to employees
		PortalEmailDigestHelper peh = new PortalEmailDigestHelper(locationStats);
		map<String, list<PortalEmailDigestHelper.employeeDigestSubClass>> employeeStatsMap = peh.generateEmployeeMap(prevDate.Date(), p.NextDigestDate__c);
		list<list<PortalEmailDigestHelper.employeeDigestSubClass>> eList = peh.generateSingleEmployeeLists(employeeStatsMap);
		//generateEmails
		portalEmailsCreator pec = new portalEmailsCreator(p, locationStats,eList);// employeeStatsMap);
		Messaging.SingleEmailMessage mail = pec.createEmail();
		emailList.add(mail);
		//update contact/employee send dates
		updatePortalNotificationInfo(p);
		pn = makePn(p, mail, prevDate, locationStats, employeeStatsMap);
		a = new Attachment();
		a.Body =  blob.valueOf(mail.getHtmlBody());
		a.ContentType = 'html';
		a.Name = string.valueOf(Date.today())+'_emaildigest';
		attachments.add(a);			
		pnList.add(pn);
		pNotificationList.add(p);
	}	
	/***********************************************/
	public PortalNotification__c makePn(PortalNotificationSchedule__c p, Messaging.SingleEmailMessage mail, Datetime prevDate,
		map <string, list<PortalExecutiveDashboardController.locationProgramWrapper>> locationStats, map<String, list<PortalEmailDigestHelper.employeeDigestSubClass>> employeeStatsMap ){
		PortalNotification__c pn = new PortalNotification__c();
		pn.PortalNotificationSchedule__c = p.id;
		pn.DataStartDate__c = prevDate;
		pn.DataEndDate__c = Datetime.now();
		if(mail.getHtmlBody().contains('There has been no tax incentive screening activity as of'))
			pn.ContentBitGenerated__c = false;
		else
			pn.ContentBitGenerated__c = true;
		pn.LocationCountGenerated__c = getLocCount(locationStats);
		pn.EmployeeCountGenerated__c = getEmployeeCount(employeeStatsMap);
		//pn.FrequencyTextGenerated__c = p.Frequency__c;
		return pn;
	}
	/***********************************************/
	public integer getEmployeeCount(map<String, list<PortalEmailDigestHelper.employeeDigestSubClass>> employeeStatsMap){
		if(employeeStatsMap == null) return 0;
		list<PortalEmailDigestHelper.employeeDigestSubClass> el;
		integer rVal = 0;
		Set<String> keys = employeeStatsMap.keySet();
		if(keys == null || keys.size()==0) return 0;
		for (string key:keys){
			el = employeeStatsMap.get(key);
			if(el!=null) rVal = rVal + el.size();
		}
		return rVal;
	}
	/***********************************************/
	public integer getLocCount(map <string, list<PortalExecutiveDashboardController.locationProgramWrapper>> locationStats){
		integer rVal =0;
		list<PortalExecutiveDashboardController.locationProgramWrapper> ll;
		Set<String> keys = locationStats.keySet();
		if (keys == null||keys.size()==0) return 0;
		for(String key: keys){
			ll=locationStats.get(key);
			if(ll!=null) rVal = rVal + ll.size();
		}
		return rVal;
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
	/***********************************************/
	public Datetime setupSendingDates(PortalNotificationSchedule__c p){
		//p.NextDigestDate__c = Date.today();
		Datetime prevDate = Datetime.now();
		return prevDate.addYears(-90);///CHANGE THIS FOR TESTING!!!!!!!
		if(p.Frequency__c =='Daily') return prevDate.addDays(-1);
		else if (p.Frequency__c=='Weekly')return prevDate.addDays(-7);
		else if (p.Frequency__c =='Monthly')return prevDate.addMonths(-1);
		else return prevDate.addMonths(-3);
	}
	/***********************************************/
	public set<String> setupAHMSet(PortalNotificationSchedule__c p){
		set<String> ahmSet = new Set<string>();
		list<String> childIdList;
		list <AccountHierarchyMember__c> childrenList;
		if(p.contact__r.AccountHierarchyMember__c == null &&(p.contact__r.ExecutiveAccessBit__c == null || p.contact__r.ExecutiveAccessBit__c == false)) return ahmSet; 
		
		childrenList = [select id, ParentAccountHierarchyMember__c, Account__c 
										from AccountHierarchyMember__c
										where ParentAccountHierarchyMember__c = :p.contact__r.AccountHierarchyMember__c
										and Account__c = :p.contact__r.Account.id];
    
    while(childrenList != null && childrenList.size()>0){
	    childIdList = new list<String>();										
			for(AccountHierarchyMember__c ahm : childrenList){
				childIdList.add(ahm.id);
				ahmSet.add(ahm.id);
			}
			childrenList = [select id, ParentAccountHierarchyMember__c 
											from AccountHierarchyMember__c
											where ParentAccountHierarchyMember__c in :childIdList
											and Account__c = :p.contact__r.Account.id];										
    }
		return ahmSet;
	}
	/***********************************************/
	public list<PortalExecutiveDashboardController.locationProgramWrapper> getLocationList(set<String>ahmSet, PortalNotificationSchedule__c p){
		list<PortalExecutiveDashboardController.locationProgramWrapper> rVal = new list<PortalExecutiveDashboardController.locationProgramWrapper>();
		     list<LocationProgram__c> ll = [Select Program__r.ShortName__c, Program__c, Location__c, Program__r.Name,
                                        Location__r.LongitudeCode__c,
                                        Location__r.LatitudeCode__c,
                                        Location__r.State__r.Name, Location__r.StreetAddressText__c, location__r.State__r.StateAbbr__c,
                                        Location__r.State__c, Location__r.Name, Location__r.LocationEID__c,
                                        Location__r.CityName__c, Location__r.AccountHierarchyMember__c
                                        From LocationProgram__c 
                                        where Location__r.AccountHierarchyMember__c in :ahmSet
                                        AND Location__r.Account__c = :p.contact__r.accountId
                                        order by Location__r.Name
                                        limit 1000//:max
                                        ]; 
		for(LocationProgram__c lp : ll){
			rVal.add(new PortalExecutiveDashboardController.locationProgramWrapper(lp,'white'));
		} 
		return rVal;
	}
	/***********************************************/
	public map <string, list<PortalExecutiveDashboardController.locationProgramWrapper>> generateLocationMapStatistics(PortalNotificationSchedule__c p, Datetime prevDate){//, list<String> programList){
		map <String, list<PortalExecutiveDashboardController.locationProgramWrapper>> rVal = new map <String, list<PortalExecutiveDashboardController.locationProgramWrapper>>();
		map <String, list<PortalExecutiveDashboardController.locationProgramWrapper>> rValFiltered = new map <String, list<PortalExecutiveDashboardController.locationProgramWrapper>>();
		list<PortalExecutiveDashboardController.locationProgramWrapper> locList;
		Date sd = prevDate.Date();
		Date ed =p.NextDigestDate__c;
		//setup AHMSet
		set<String> ahmSet = setupAHMSet(p);
		//get location list
		list<PortalExecutiveDashboardController.locationProgramWrapper> llList = getLocationList(ahmSet, p);
		//setup initial map
		for(PortalExecutiveDashboardController.locationProgramWrapper ll : llList){
			locList = rVal.get(ll.lp.Program__r.Name);//using program name rather than short_name
			if(locList == null)locList = new list<PortalExecutiveDashboardController.locationProgramWrapper>();
			locList.add(ll);
			rVal.put(ll.lp.Program__r.Name, locList);//using program name rather than short_name
		}
		//setupMap with stat values
		set<String> programList = rVal.keySet();
		for(String prog : programList){
			 locList = rVal.get(prog);
			 if(locList != null){
			 	PortalScreeningComplianceHelper.setupPSC(locList, sd, ed);
			 	locList = filterOutZeros(locList); //LINES TO COMMENT OUT FOR MARNELLO TESTING
			 	if(locList !=null && locList.size()>0) //THIS ONE TOO
			 	 rValFiltered.put(prog, locList);
			 }			 	
		}
	return rValFiltered;
	}
	/***********************************************/
	public list<PortalExecutiveDashboardController.locationProgramWrapper> filterOutZeros(list<PortalExecutiveDashboardController.locationProgramWrapper> locList){
		list<PortalExecutiveDashboardController.locationProgramWrapper> rVal = new list<PortalExecutiveDashboardController.locationProgramWrapper>();
		for(PortalExecutiveDashboardController.locationProgramWrapper lw : locList){
			if(lw.PortalScreeningComplianceDenom != null && lw.PortalScreeningComplianceDenom != 0) rVal.add(lw);
		}
		return rVal;
	}
	/***********************************************/
	public static testMethod void testLCreator() {
      BATCH_EmailDigest_TEST t = new BATCH_EmailDigest_TEST();
      t.insertInfo();
			list <PortalNotificationSchedule__c> pList = [ Select  p.NextDigestDate__c, p.Frequency__c, p.DigestType__c, p.Contact__c,
						p.Contact__r.AccountHierarchyMember__c,  p.Contact__r.Id, p.Contact__r.ExecutiveAccessBit__c, p.Contact__r.AccountId, 
						p.Contact__r.Account.Name, p.Contact__r.Name, p.Contact__r.Email, p.Contact__r.Account.ShortName__c
						From PortalNotificationSchedule__c p
						where id = :t.p.id];
      test.startTest();
     	PortalEmailDigestListCreate lc = new PortalEmailDigestListCreate();
      for(PortalNotificationSchedule__c port: pList){
      	lc.addToLists(port);
      }
      lc.sendUpdateAndInsertInfo();
      portalEmailsCreator pec = new portalEmailsCreator(pList[0], null, null);
      pec.emptyBodyTest();
      test.stopTest();
    }
}