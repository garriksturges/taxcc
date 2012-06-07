public with sharing class PortalLocationEmployeeStatsController {
        
        public string locationID	{get; set;}
        private list<wktLocationEmployeeProgram__c> wktList;
        private set<String>qualifiedEmploymentSet;
        private date startDate;
        private date endDate;
        private integer max;
        public string startDateFilter            {get; set;}
    	public string endDateFilter              {get; set;}
        public Location__c loc                    {get; set;}
        public list<Selectoption> programOptions                  {get; set;}
        public string selectedProgram                                                                   {get; set;}
        public list<EmployeeWrapper> employeeList                 {get; set;}
        public integer rStart	{get;set;}
    	public integer rEnd		{get;set;}
    	public integer rCount	{get;set;}
    	private integer subMax=300;
    	public string programShortName	{get; set;}
        
        /*************************************/
        public PortalLocationEmployeeStatsController(){
        				max = 25;
        				string incrMax = ApexPages.currentPage().getParameters().get('max');
            		if (incrMax!=null) max = integer.valueOf(incrMax); 
            		if(max>1000) max = 1000;
            		string startD = ApexPages.currentPage().getParameters().get('startD');
            		string endD =ApexPages.currentPage().getParameters().get('endD');
            		selectedProgram=ApexPages.currentPage().getParameters().get('prog');
            		if(startD != null && endD != null){
            			this.startDateFilter = startD;
            			this.endDateFilter = endD;
            		}
            
            
                setupLocation();
                setupProgramInfo();
                setupWKTList();
                setupQualifiedEmploymentsSet();
                setupListOfEmployees();
                //setupStatLists();  
                
                if(this.startDateFilter != null && this.endDateFilter != null && employeeList != null && employeeList.size()>0)
            			this.dateScreen();   
        }
        /*************************************/
        private void setupListOfEmployees(){
                employeeList = new list<EmployeeWrapper>();
                for(wktLocationEmployeeProgram__c wkt :wktList){
                        employeeList.add(new EmployeeWrapper(wkt, 'white', locationID, qualifiedEmploymentSet.contains(wkt.Employment__c), selectedProgram));
                }
        }
        
        /*************************************/
        public void updateEmployeeList(){
                setupWKTList();
                setupQualifiedEmploymentsSet();
                setupListOfEmployees();
        }
        /*************************************/
        public void DateScreen(){
        	list<Date> dates = checkDates();
        	startDate = dates[0];
        	endDate = dates[1];
        	setupWKTList();
          setupQualifiedEmploymentsSet();
          setupListOfEmployees();
        }
        /*************************************************************************************************/
    		private list<Date>checkDates(){
		        list<Date> dates = new list<Date>();
		        if(this.startDateFilter == null || this.endDateFilter == null){
		                dates.add(null);
		                dates.add(null);
		        }
		        else{
		                try{
		                Date startd = date.parse(this.startDateFilter);
		                date endd = date.parse(this.endDateFilter);
		                dates.add(startd);
		                dates.add(endd);
		                }
		                catch(exception e){
		                        dates.clear();
		                        dates.add(null);
		                        dates.add(null);
		                }
		        }
		        return dates;
		    }
        /*************************************/
        public void nextPage(){
        	list<wktLocationEmployeeProgram__c> wktListN;
            if(wktList != null || wktList.size()>0) {
            if(startDate != null && endDate != null){
            	wktListN = [Select SurveyLocation__c, Program__c, Program__r.shortName__c, Employment__c,
                        Employee__r.LastName__c, Employee__r.FirstName__c, Employee__r.clientEmployeeId__c,
                        Employee__r.SSN__c, Employment__r.Location__r.Name, SurveyLocation__r.Name, 
                        ProgramStartDate__c, ProgramName__c, ProgramEndDate__c, SurveyDate__c, Employment__r.Location__c,
                        HireLocation__c, HireDate__c, Employee__c, Employment__r.Status__c,
                        QualificationProcessStage__r.ExternalName__c, QualificationProcessStage__c,
                        DocumentReplacementNeededText__c, DocumentReceivedText__c, DocumentNeededText__c,
                        ActionItemFormula__c, ProgramQualification__r.ProcessStage__r.ExternalName__c
                        From wktLocationEmployeeProgram__c w 
                        where (Employment__r.Location__c = :locationId
                        or SurveyLocation__c = :locationId)
                        //and (Program__c = :selectedProgram or Program__c = null)
                        and Employee__r.LastName__c > :wktList[wktList.size()-1].Employee__r.LastName__c
                        and HireDate__c >= :startDate
 												and HireDate__c <= :endDate
                        order by Employee__r.LastName__c
                        limit :subMax];
            }
            else{
	            wktListN = [Select SurveyLocation__c, Program__c, Program__r.shortName__c, Employment__c,
                        Employee__r.LastName__c, Employee__r.FirstName__c, Employee__r.clientEmployeeId__c,
                        Employee__r.SSN__c, Employment__r.Location__r.Name, SurveyLocation__r.Name, 
                        ProgramStartDate__c, ProgramName__c, ProgramEndDate__c, SurveyDate__c, Employment__r.Location__c,
                        HireLocation__c, HireDate__c, Employee__c, Employment__r.Status__c,
                        QualificationProcessStage__r.ExternalName__c, QualificationProcessStage__c,
                        DocumentReplacementNeededText__c, DocumentReceivedText__c, DocumentNeededText__c,
                        ActionItemFormula__c, ProgramQualification__r.ProcessStage__r.ExternalName__c
                        From wktLocationEmployeeProgram__c w 
                        where (Employment__r.Location__c = :locationId
                        or SurveyLocation__c = :locationId)
                        //and (Program__c = :selectedProgram or Program__c = null)
                        and Employee__r.LastName__c > :wktList[wktList.size()-1].Employee__r.LastName__c
                        order by Employee__r.LastName__c
                        limit :subMax];
            }
                if(wktListN!=null && wktListN.size()>0){
                		wktList = wktListN;
                		filterWKTList();
                    setupQualifiedEmploymentsSet();
                    setupListOfEmployees();
                        
                    rStart = rStart+max;
           				if(wktList.size()<max)rEnd = rStart+wktList.size()-1;
           				else rEnd = rStart+max-1;
           				
                }
            }
        }
        /*************************************/
        public void previousPage(){
        	list<wktLocationEmployeeProgram__c> wktListN;
            if(wktList != null || wktList.size()>0){
            if(startDate !=null && endDate != null){
            	wktListN = [Select SurveyLocation__c, Program__c, Program__r.shortName__c, Employment__c,
	                            Employee__r.LastName__c, Employee__r.FirstName__c, Employee__r.clientEmployeeId__c,
	                            Employee__r.SSN__c, Employment__r.Location__r.Name, SurveyLocation__r.Name, 
	                            ProgramStartDate__c, ProgramName__c, ProgramEndDate__c, SurveyDate__c, Employment__r.Location__c,
	                            HireLocation__c, HireDate__c, Employee__c, Employment__r.Status__c,
	                            QualificationProcessStage__r.ExternalName__c, QualificationProcessStage__c,
	                            DocumentReplacementNeededText__c, DocumentReceivedText__c, DocumentNeededText__c,
	                            ActionItemFormula__c, ProgramQualification__r.ProcessStage__r.ExternalName__c
	                            From wktLocationEmployeeProgram__c w 
	                            where (Employment__r.Location__c = :locationId
	                            or SurveyLocation__c = :locationId)
	                            //and (Program__c = :selectedProgram or Program__c = null)
	                            and Employee__r.LastName__c < :wktList[0].Employee__r.LastName__c
	                            and HireDate__c >= :startDate
 															and HireDate__c <= :endDate
	                            order by Employee__r.LastName__c DESC
	                            limit :subMax];
            }
            else{
	            wktListN = [Select SurveyLocation__c, Program__c, Program__r.shortName__c, Employment__c,
	                            Employee__r.LastName__c, Employee__r.FirstName__c, Employee__r.clientEmployeeId__c,
	                            Employee__r.SSN__c, Employment__r.Location__r.Name, SurveyLocation__r.Name, 
	                            ProgramStartDate__c, ProgramName__c, ProgramEndDate__c, SurveyDate__c, Employment__r.Location__c,
	                            HireLocation__c, HireDate__c, Employee__c, Employment__r.Status__c,
	                            QualificationProcessStage__r.ExternalName__c, QualificationProcessStage__c,
	                            DocumentReplacementNeededText__c, DocumentReceivedText__c, DocumentNeededText__c,
	                            ActionItemFormula__c, ProgramQualification__r.ProcessStage__r.ExternalName__c
	                            From wktLocationEmployeeProgram__c w 
	                            where (Employment__r.Location__c = :locationId
	                            or SurveyLocation__c = :locationId)
	                            //and (Program__c = :selectedProgram or Program__c = null)
	                            and Employee__r.LastName__c < :wktList[0].Employee__r.LastName__c
	                            order by Employee__r.LastName__c DESC
	                            limit :subMax];
            }	                            
            if(wktListN!=null && wktListN.size()>0){
            		wktList = wktListN;
                filterWKTList();
                wktListN = new list <wktLocationEmployeeProgram__c>();
            		for(Integer i = wktList.size()-1; i>=0;i--){
            			wktListN.add(wktList[i]);
            		}
                wktList = wktListN;
                setupQualifiedEmploymentsSet();
                setupListOfEmployees();
                rStart = rStart - max;
           			rEnd = rStart+max-1;
            }
           }
        }
        /*************************************/
        private void setupQualifiedEmploymentsSet(){
                list<String> eIds = employmentIdList();
                list<ProgramQualification__c> pqList = [Select ProgramPeriod__r.Program__c, ProgramPeriod__c, Name, Employment__c 
														From ProgramQualification__c 
														where ProgramPeriod__r.Program__c = :selectedProgram
                                                        and Employment__c in :eIds];
                qualifiedEmploymentSet= new set<String>();
                for(ProgramQualification__c pq:pqList){
                        qualifiedEmploymentSet.add(pq.Employment__c);
                }
        }
        /***************************************/
        private list<String> employmentIdList(){
                list<string> rVal = new list<string>();
                for(wktLocationEmployeeProgram__c wkt :wktList){
                        rVal.add(wkt.Employment__c);
                }
                return rVal;
        }
        /*************************************/
        private void setupProgramInfo(){
                list<LocationProgram__c> lpList = [Select Program__r.MaximumLifetimeBenefitAmount__c,
                                                                                                                                                         Program__r.ShortName__c,Program__c, Location__c 
                                                                                                                                                         From LocationProgram__c 
                                                                                                                                                         where location__c = :locationId];
                map<String, LocationProgram__c> pMap = new map<String, LocationProgram__c>();
                for(LocationProgram__c lp : lpList){
                        pMap.put(lp.Program__r.ShortName__c, lp);
                }
                setupProgramListAndSetSelected(pMap);
        }
        /*************************************/
        private void setupProgramListAndSetSelected(map<string, LocationProgram__c> pMap){
			        set<String> keyset = pMap.keySet();
					    list<String> programList = new list<String>();
					    programList.addAll(keyset);
					    programList.sort();
					    
					    
					    boolean programSet = false;
					    if(this.selectedProgram != null && keyset.contains(this.selectedProgram)){
					        programSet = true;
					    	selectedProgram = pMap.get(selectedProgram).Program__c;
					    }
					    Decimal d;
					    programOptions = new list<Selectoption>();
					  	for(string s: programList){
					        programOptions.add(new SelectOption(pMap.get(s).Program__c,s));
			        
			        if(d == null && !programSet){
			            this.selectedProgram = pMap.get(s).Program__c;
			            d = pMap.get(s).Program__r.MaximumLifetimeBenefitAmount__c;
			        }
			        else if(pMap.get(s).Program__r.MaximumLifetimeBenefitAmount__c>d && !programSet){
			            this.selectedProgram = pMap.get(s).Program__c;
			            d = pMap.get(s).Program__r.MaximumLifetimeBenefitAmount__c;
			        }
			    }
        }
        /*************************************/
        private void setupWKTList(){
        	rStart=0;
        	rEnd = 1;
        	rCount =0;
             if(startDate != null && endDate !=null){
             		if(!test.isrunningTest()){
             		          list<AggregateResult> agresult = [select count_distinct(Employee__c)cnt From wktLocationEmployeeProgram__c 
	                        where (Employment__r.Location__c = :locationId
	                        or SurveyLocation__c = :locationId)
	                        and (Program__c = :selectedProgram or Program__c = null)
	                        and HireDate__c >= :startDate
 													and HireDate__c <= :endDate
	                        ];
	            	rCount=Integer.valueOf(agresult[0].get('cnt'));
             	}
             	else{
             		rCount=50000;
             	}
             	wktList = [Select SurveyLocation__c, Program__c, Program__r.shortName__c, Employment__c,
	                        Employee__r.LastName__c, Employee__r.FirstName__c, Employee__r.clientEmployeeId__c,
	                        Employee__r.SSN__c, Employment__r.Location__r.Name, SurveyLocation__r.Name, 
	                        ProgramStartDate__c, ProgramName__c, ProgramEndDate__c, SurveyDate__c, Employment__r.Location__c,
	                        HireLocation__c, HireDate__c, Employee__c, Employment__r.Status__c,
	                        QualificationProcessStage__r.ExternalName__c, QualificationProcessStage__c,
	                        DocumentReplacementNeededText__c, DocumentReceivedText__c, DocumentNeededText__c,
	                        ActionItemFormula__c, ProgramQualification__r.ProcessStage__r.ExternalName__c
	                        From wktLocationEmployeeProgram__c w 
	                        where (Employment__r.Location__c = :locationId
	                        or SurveyLocation__c = :locationId)
	                        //and (Program__c = :selectedProgram or Program__c = null)
	                        and HireDate__c >= :startDate
 													and HireDate__c <= :endDate
	                        order by Employee__r.LastName__c
	                        limit :subMax];
             }
             else{ 
          			try{
          				if(!test.isrunningTest()){
			           		list<AggregateResult> agresult = [select count_distinct(Employee__c)cnt From wktLocationEmployeeProgram__c 
			                    where (Employment__r.Location__c = :locationId
					                or SurveyLocation__c = :locationId)
					                //and (Program__c = :selectedProgram or Program__c = null)
					                ];
										rCount=Integer.valueOf(agresult[0].get('cnt'));
          				}
          				else	rCount = 50000;
          			}
          			catch(Exception e){
          				rCount = 1000;
          			}
								wktList	= [Select SurveyLocation__c, Program__c, Program__r.shortName__c, Employment__c,
	                        Employee__r.LastName__c, Employee__r.FirstName__c, Employee__r.clientEmployeeId__c,
	                        Employee__r.SSN__c, Employment__r.Location__r.Name, SurveyLocation__r.Name, 
	                        ProgramStartDate__c, ProgramName__c, ProgramEndDate__c, SurveyDate__c, Employment__r.Location__c,
	                        HireLocation__c, HireDate__c, Employee__c, Employment__r.Status__c,
	                        QualificationProcessStage__r.ExternalName__c, QualificationProcessStage__c,
	                        DocumentReplacementNeededText__c, DocumentReceivedText__c, DocumentNeededText__c,
	                        ActionItemFormula__c, ProgramQualification__r.ProcessStage__r.ExternalName__c
	                        From wktLocationEmployeeProgram__c w 
	                        where (Employment__r.Location__c = :locationId
	                        or SurveyLocation__c = :locationId)
	                        //and (Program__c = :selectedProgram or Program__c = null)
	                        order by Employee__r.LastName__c
	                        limit :subMax
	                        ];
             }	
             
             filterWKTList();  
             if(wktList!=null && wktList.size()>0 && wktList[0].Program__c !=null &&  wktList[0].Program__r.shortName__c !=null)programShortName =wktList[0].Program__r.shortName__c;
            rStart = 1;
            if(rCount<max) rEnd = rStart+rCount-1;
            else rEnd = rEnd+max-1;                      
        }
        /*************************************/
        private void filterWKTList(){
        	map<String, wktLocationEmployeeProgram__c> wktMap= new Map<String, wktLocationEmployeeProgram__c>();
					wktLocationEmployeeProgram__c cWkt;
        	list<wktLocationEmployeeProgram__c> newWktList = new list<wktLocationEmployeeProgram__c>();
        	for(wktLocationEmployeeProgram__c wkt : wktList){
        		cWkt = wktMap.get(wkt.Employee__c);
        		if(cWkt == null) wktMap.put(wkt.Employee__c, wkt);
        		else if(wkt.Program__c == selectedProgram) wktMap.put(wkt.Employee__c, wkt);
        	}
        	for(wktLocationEmployeeProgram__c wkt : wktList){
        		cWkt = wktMap.get(wkt.Employee__c);
        		if(cWkt != null && cWkt.id == Wkt.id) newWktList.add(wkt);
        		if(newWktList.size()>=max) break;
        	}
        	wktList = newWktList;
        }
        /*************************************/ 
        private void setupLocation(){
          locationID = Apexpages.currentPage().getParameters().get('locId');
			    if(locationId == null)
			        return;
			    list <Location__c> llist = [select Name, id from Location__c where id = :locationID];
			    if(llist!=null && llist.size()>0)
			        loc = llist[0];
        }
        /*************************************/
        /*************/
    public class EmployeeWrapper{
        public String lastName{get; set;}
        public String firstName{get; set;}
        public String clientEmployeeId{get; set;}
        public String ssn {get; set;}
        public String id{get; set;}
        public String screen {get; set;}
        public String qualified {get; set;}
        public string documentation {get; set;}
        public string background{get; set;}
        public string transferStatus {get;set;}
        public string hireDate	{get;set;}
        public string dNeeded	{get; set;}
        public string dReplace {get; set;}
        public string dReceived	{get; set;}
        public string empStatus		{get; set;}
		public string certStatus		{get; set;}
		public string qualTasks		{get; set;}
        //DocumentReplacementNeededText__c, DocumentReceivedText__c, DocumentNeededText__c
        
        private string selectedProgram;
        
        public EmployeeWrapper(wktLocationEmployeeProgram__c e, string bg, string locationID, boolean qual, String sp){
        	selectedProgram = sp;
        	if(e.HireDate__c != null) hireDate = e.HireDate__c.format();
        	else hireDate = 'n/a';
            if(e.Employee__r.SSN__c !=null && e.Employee__r.SSN__c.length()>=4)
                ssn = e.Employee__r.SSN__c.substring(e.Employee__r.SSN__c.length()-4, e.Employee__r.SSN__c.length());
            else
                ssn = 'none';
            lastName = e.Employee__r.LastName__c;
            firstName = e.Employee__r.FirstName__c;
            clientEmployeeId = e.Employee__r.clientEmployeeId__c;
            id = e.Employee__c;
            background = bg;
            //screened?
            screen = checkScreened(e);
            //qualified?
            if(qual) qualified = 'Yes';
            else qualified = 'No';
            //documentation?
            if (e.QualificationProcessStage__c == null || e.QualificationProcessStage__r.ExternalName__c == null) documentation = '—';
            else documentation = e.QualificationProcessStage__r.ExternalName__c;
            //transfer status
            transferStatus = transferValue(e, locationID);
            //DOCS
            //if(e.DocumentReplacementNeededText__c == null || e.DocumentReplacementNeededText__c == '') dReplace = '—';
            //else dReplace = e.DocumentReplacementNeededText__c;
            //if(e.DocumentReceivedText__c == null || e.DocumentReceivedText__c == '') dReceived = '—';
            //else dReceived = e.DocumentReceivedText__c;
            //if(e.DocumentNeededText__c == null || e.DocumentNeededText__c == '') dNeeded = '—';
            //else dNeeded = e.DocumentNeededText__c;
            
            if(e.Employment__r.Status__c == null || e.Employment__r.Status__c == '') empStatus = '—';
            else empStatus = e.Employment__r.Status__c;
            if(e.ProgramQualification__r.ProcessStage__r.ExternalName__c == null || e.ProgramQualification__r.ProcessStage__r.ExternalName__c == '') certStatus = '—';
            else certStatus = e.ProgramQualification__r.ProcessStage__r.ExternalName__c;
            if(e.ActionItemFormula__c == null || e.ActionItemFormula__c == '') qualTasks = '—';
            else qualTasks = e.ActionItemFormula__c;
        }
        
        /****/
        private string checkScreened(wktLocationEmployeeProgram__c wkt){
        	//check for unscreened
	        if(wkt.Program__c == null || wkt.Program__c != selectedProgram) return 'Unscreened'; 
          	boolean ok = true;
	        //check for WOTC
	        if('WOTC'.equalsIgnoreCase(wkt.program__r.shortName__c)){
            ok = false;
            if(wkt.HireDate__c != null && wkt.SurveyDate__c != null && wkt.HireDate__c >= wkt.SurveyDate__c.Date()){
                    ok = true;
            }
	        }
	        //check if Valid
	       // if(wkt.SurveyDate__c <= Datetime.now() && wkt.Employment__r.Location__c == wkt.SurveyLocation__c && ok) return 'Screened';
	       	if(wkt.Employment__r.Location__c != null && wkt.SurveyLocation__c != null && wkt.Employment__r.Location__c != wkt.SurveyLocation__c && wkt.SurveyLocation__c != selectedProgram) return 'Screened at '+wkt.SurveyLocation__r.Name;
	       	if(ok) return 'Screened';
	        else return 'Invalid';
	        
	                                                    
       }
       /****/
       private string transferValue(wktLocationEmployeeProgram__c wkt, string locationID){
       	if(wkt.Employment__r.Location__c == wkt.SurveyLocation__c || wkt.SurveyLocation__c == null) return '—';
       	else if(wkt.Employment__r.Location__c != wkt.SurveyLocation__c && wkt.Employment__r.Location__c == locationID) return 'From: '+wkt.SurveyLocation__r.Name;//'In';
       	else if(wkt.Employment__r.Location__c != wkt.SurveyLocation__c && wkt.SurveyLocation__c == locationID) return 'To: '+wkt.Employment__r.Location__r.Name;//Out';
       	else return '--';
       }
       /****/
    }
    /*************/
    /*
    public list<EmployeeWrapper> validList                        {get; set;}
                public list<EmployeeWrapper> transferOut                  {get; set;}
                public list<EmployeeWrapper> invalidScreens       {get; set;}
                public list<EmployeeWrapper> transferIn                           {get; set;}
                public list<EmployeeWrapper> notHired                                     {get; set;}
                public list<EmployeeWrapper> unscreened                           {get; set;}
        */
    /*************************************
        private void setupStatLists(){
                //valid list    
                setupValidList();
                //transfer out
                setupTransferOut();
                //incorrect
                setupInvalidScreens();
                //transfer in
                setupTransferIn();
                //not hired
                setupNotHired();
                //unscreened    
                setupUnscreened();      
        }
        /***************************************
        private void setupUnscreened(){
                unscreened = new list<EmployeeWrapper>();
                String color = 'white';
                for(wktLocationEmployeeProgram__c wkt: wktList){
                        if(wkt.SurveyLocation__c == null){
                                unscreened.add(new EmployeeWrapper(wkt, color, locationID));
        if(color == 'white')
            color = 'lightgrey';
        else
            color = 'white';
        }
                }
                
        }
        /*************************************
        private void setupNotHired(){
                notHired = new list<EmployeeWrapper>();
                String color = 'white';
                for(wktLocationEmployeeProgram__c wkt: wktList){
                        if(wkt.Employment__r.Status__c == 'Pending'){
                                notHired.add(new EmployeeWrapper(wkt, color, locationID));
        if(color == 'white')
            color = 'lightgrey';
        else
            color = 'white';
        }
                }
        }
        /*************************************
        private void setupTransferIn(){
                transferIn = new list<EmployeeWrapper>();
                String color = 'white';
                for(wktLocationEmployeeProgram__c wkt: wktList){
                        if(wkt.Employment__r.Location__c != wkt.SurveyLocation__c && wkt.Employment__r.Location__c == locationID){
                                transferIn.add(new EmployeeWrapper(wkt, color, locationID));
        if(color == 'white')
            color = 'lightgrey';
        else
            color = 'white';
        }
                }
        }
        /*************************************
        private void setupInvalidScreens(){
                invalidScreens = new list<EmployeeWrapper>();
                String color = 'white';
                boolean add = false;
                for(wktLocationEmployeeProgram__c wkt: wktList){
                        add = false;
                        //check for WOTC
        if('WOTC'.equalsIgnoreCase(wkt.program__r.shortName__c)){
                if(wkt.HireDate__c != null && wkt.SurveyDate__c != null && wkt.HireDate__c < wkt.SurveyDate__c.Date()){
                        add=true;
                }
        }
        //see if invalid
                        if(wkt.SurveyDate__c > Datetime.now() || add){
                                invalidScreens.add(new EmployeeWrapper(wkt, color, locationID));
        if(color == 'white')
            color = 'lightgrey';
        else
            color = 'white';
        }
                }
        }
        /*************************************
        private void setupTransferOut(){
                transferOut = new list<EmployeeWrapper>();
                boolean ok = true;
                String color = 'white';
                for(wktLocationEmployeeProgram__c wkt: wktList){
                        ok = true;
                        //check for WOTC
        if('WOTC'.equalsIgnoreCase(wkt.program__r.shortName__c)){
                ok = false;
                if(wkt.HireDate__c != null && wkt.SurveyDate__c != null && wkt.HireDate__c >= wkt.SurveyDate__c.Date()){
                        ok = true;
                }
        }
        //check transfer out and valid
                        if(wkt.Employment__r.Location__c != wkt.SurveyLocation__c && wkt.SurveyLocation__c == locationID && wkt.SurveyDate__c <= Datetime.now() && ok){
                                transferOut.add(new EmployeeWrapper(wkt, color, locationID));
        if(color == 'white')
            color = 'lightgrey';
        else
            color = 'white';
        }
                }
        }
        /*************************************
        private void setupValidList(){
                validList = new list<EmployeeWrapper>();
                String color = 'white'; 
                boolean ok = true;
    for(wktLocationEmployeeProgram__c wkt: wktList){
        ok = true;
        //check for WOTC
        if('WOTC'.equalsIgnoreCase(wkt.program__r.shortName__c)){
                ok = false;
                if(wkt.HireDate__c != null && wkt.SurveyDate__c != null && wkt.HireDate__c >= wkt.SurveyDate__c.Date()){
                        ok = true;
                }
        }
        //check if Valid
        if(wkt.SurveyDate__c <= Datetime.now() && wkt.Employment__r.Location__c == wkt.SurveyLocation__c && ok){
        validList.add(new EmployeeWrapper(wkt, color, locationID));
        if(color == 'white')
            color = 'lightgrey';
        else
            color = 'white';
        }
    }
        }
        */
}