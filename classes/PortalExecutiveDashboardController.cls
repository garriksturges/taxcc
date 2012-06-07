public with sharing class PortalExecutiveDashboardController {
    public String accountId {get; set;}
    public String accountHierarchyMemberId {get; set;}
    public List<AccountHierarchyMember__c> accountHierarchyMemberList {get; set;}    
    public String currentParentId {get; set;}
    public String debugText {get; set;}
    public String goUpLevel {get; set;}
    public String parentAccountHierarchyMemberId {get; set;}
    public String previousAccountHierarchyMemberId {get; set;}        
    public boolean showUpLevel {get; set;}  
    public boolean executiveAccessBit {get; set;}
    
    /****** added by garrik ********/
    public integer rStart	{get;set;}
    public integer rEnd		{get;set;}
    public integer rCount	{get;set;}
    public string screenRatio           {get; set;}
    public string screenRatioN           {get; set;}
    public string screenRatioD           {get; set;}
    public string screenRatioDM           {get; set;}
    public string screenRatioExcel {get; set;}
    public string screenPercent {get; set;}
    public string qualRatio             {get; set;}
    public string qualRatioExcel {get; set;}
    public string qualPercent   {get; set;} 
    public string qualQ					{get;set;}
    public string qualUQ				{get;set;} 
    public string docRatio		{get;set;}
    public string docRatioN		{get;set;}
    public string docRatioD		{get;set;}
    public string docRatioDM		{get;set;}
    public string docRatioExcel	{get;set;}
    public string docPercent	{get;set;}                                                                           
    public string startDateFilter            {get; set;}
    public string endDateFilter              {get; set;} 
    public boolean okToSetup                 {get; set;}
    public string accountName                {get; set;}
    public String userACM;
    public boolean  showListNotMap           {get; set;}
    public list<String>  joeLatAndLongs                                                                           {get; set;}
    public list<String>  joeMarkers                                                                 {get; set;}
    public integer joeZoom                      {get; set;}
    private set<String> ahmSet;
    public boolean showLocationList     {get; set;}
        private string contactId;
        private map<string, list<Location__c>> programMap;
    public list<Selectoption> programs                  {get; set;}
    public string selectedProgram;
    public string getselectedProgram()                  {return selectedProgram;}
    public void  setSelectedProgram(string val) {selectedProgram = val;} 
    public list<locationProgramWrapper> locationList                {get; set;}
    public list <LevelWrapper> lwList                       {get; set;}
    public string selectedMemberId; 
    public string getselectedMemberId()                 {return this.selectedMemberId;}
    public void setselectedMemberId(String val) {this.selectedMemberId = val;}
    public integer  locationListSize {get; set;}
    public integer max;
    /*****************/
    public class LevelWrapper{
        public string levelId                                                       {get; set;}
        public string levelName                                                 {get; set;}
        public list <AccountHierarchyMember__c> ahmList {get; set;}
        public list <Selectoption> soList                               {get; set;}
        public string selectVal;                                                //{get; set;}
        public string getselectVal(){return selectVal;}
        public void setselectVal(String val){selectVal = val;}
        public LevelWrapper(String ln, String id, list<AccountHierarchyMember__c> al){
            levelId = id;
            levelName = ln;
            ahmList = al;
            setupSOList();
        }
        private void setupSOList(){
            soList = new list<SelectOption>();
            soList.add(new Selectoption('--Select--','--Select--'));
            for(AccountHierarchyMember__c ahm : ahmList){
                soList.add(new Selectoption(ahm.Id, ahm.AccountHierarchyMemberLabelName__c));
            }
        } 
    }
    
    /*****************/
    public class locationProgramWrapper{
        public LocationProgram__c lp                                                                     {get; set;}
        public string background                                                                                         {get; set;}
        public integer ValidScreens                                                                      {get; set;}
        public integer ScreenTransfersOut                                                        {get; set;}
        public integer ScreenTransfersIn                                                         {get; set;}
        public integer InvalidScreens                                                            {get; set;}
        public integer NotHiredScreens                                                           {get; set;}
        public integer Unscreened                                                                                        {get; set;}
        public integer PortalScreeningCompliance                         {get; set;}
        public Integer PortalScreeningComplianceNum      {get; set;}
        public Integer PortalScreeningComplianceDenom    {get; set;}
        public Integer PortalQualificationNum                                    {get; set;}
        public Integer portalQualificationRate                           {get; set;}
        public Integer documentNum {get; set;}
        public Integer documentDenom {get; set;}
        public string  locationId;
        public locationProgramWrapper(LocationProgram__c l, string bg){
            lp = l;
            background = bg;
        }
        
        public integer getScreening(){
        	Integer i =validScreens+ScreenTransfersOut;
        	return i;
        }
        
        public integer getScreeningCompliancePCNT(){
        	if(PortalScreeningComplianceDenom == 0) return 0;
        	double d = (double.valueOf(PortalScreeningComplianceNum)/double.valueOf(PortalScreeningComplianceDenom))*100;        	
        	return d.intValue();
        }
        
        public integer getQualificationRatePCNT(){
        	if(PortalScreeningComplianceDenom == 0)return 0;
        	double d  = (double.valueOf(PortalQualificationNum)/double.valueOF(PortalScreeningComplianceDenom))*100;
        	//d = d/2;
        	return d.intValue();
        }
		
				public integer getDocumentCompliancePCNT(){
					if(documentDenom ==0) return 0;
					double d = (double.valueOf(documentNum)/double.valueOf(documentDenom))*100;
					return d.intValue();
				}        
    }
    /*************************************************************************************************/
    public PortalExecutiveDashboardController(){
            okToSetup = false;
            showListNotMap = true;
            joeZoom = 4;
            
            max = 7;
            string incrMax = ApexPages.currentPage().getParameters().get('max');
            if (incrMax!=null) max = integer.valueOf(incrMax);
            if(max>1000) max = 1000;
            
            string startD = ApexPages.currentPage().getParameters().get('startD');
            string endD =ApexPages.currentPage().getParameters().get('endD');
            selectedProgram = ApexPages.currentPage().getParameters().get('prog');
            if(startD != null && endD != null){
            		this.startDateFilter = startD;
            		this.endDateFilter = endD;
            }
            
            showLocationList = false;
            try{
            //ContactId = ApexPages.currentPage().getParameters().get('id');
            ContactId = [Select u.Contact.FirstName, u.Contact.LastName, u.ContactId From User u where id =:Userinfo.getUserId()].contactId;
            Contact contact = [select AccountId, Account.Name,  AccountHierarchyMember__c, ExecutiveAccessBit__c from Contact where Id =:ContactId];            
            accountName=contact.Account.Name;
            accountId = contact.AccountId;
            userACM = contact.AccountHierarchyMember__c;
            executiveAccessBit = contact.ExecutiveAccessBit__c;
            
            /*Changed by Jason 101711 - now looking for ExecutiveAccessBit__c to be true in case contact has full executive access.*/
            if(contact != null && (userACM != null|| executiveAccessBit) && accountId != null)
                okToSetup = true;
            
            }
            catch(exception e){     
                        //system.assert(false, e);
                //!!!!!!! FOR DEVELOPMENT                                               
                /*if(userinfo.getProfileId() == '00e30000001iwE7AAI'){
	                accountId ='001V00000059hs9';//'0013000000qKxqHAAS';//<--Ascent Media Group'0013000000qKxmUAAS';//<--Survey Data'0013000000qKxdW';//<--Starbucks  
	                //userACM = 'a07S00000029ZNjIAM';//--California State
	                Account accountObject = [SELECT Id, Name FROM Account WHERE Id =:accountId];
	                accountName = accountObject.Name;
	                okToSetup = true;
                }*/
                
            }
            
            if(okToSetup){
            	setupTopNode();
            	if(lwList!=null && lwList.size()>0){
              	LevelWrapper lw = lwList[lwList.size()-1];
                if((lw.selectVal == null ||lw.selectVal == '--Select--') && lw.soList.size()==2){
                	lw.selectVal=lw.soList[1].getValue();
                  updateNodeList();
                }
             	}
            	if(this.startDateFilter != null && this.endDateFilter != null && locationList != null && locationList.size()>0)
            		this.dateScreen();
            }
           //checkForCookies();
    }
    /*************************************************************************************************/
    public string getDisplayValue(){
    	if(this.selectedProgram == 'WOTC')return 'table-cell';
        else return 'none';
    }
    /*************************************************************************************************/
    public Pagereference expandedLocationSetup(){
    		Pagereference pr = checkForCookies();
    		if (pr!=null) return pr;
        showListNotMap = true;
        max = 30;
        String param = Apexpages.currentPage().getParameters().get('levelIds');
        if(param!=null){
	        list <String> levelIds = param.split(':', 0);
	        //for(String val:levelIds){
	        for(integer i=0; i<lwList.size(); i++){
	                        
	            if(levelIds[i] == '--Select--'||levelIds[i] == 'null')
	                break;
	            lwList[i].selectVal = levelIds[i];
	            this.updateNodeList();
	        }
        }
        return null;
    }
    /*************************************************************************************************/
    private void addCookies(){
    	string levelIds = '';
      for(LevelWrapper lw : lwList){
      	levelIds += lw.selectVal+':';
      }
      Cookie cook = new Cookie('levelIds',levelIds,null,-1,false);
      ApexPages.currentPage().setCookies(new Cookie[]{cook});
    }
    /*************************************************************************************************/
    private Pagereference checkForCookies(){
    	String param = Apexpages.currentPage().getParameters().get('levelIds');
    	Cookie cook = ApexPages.currentPage().getCookies().get('levelIds');
    	if(param == null && cook != null && cook.getValue()!='') {
    		Pagereference pr = Apexpages.currentPage();
    		String levelIds = cook.getValue();
        pr.getParameters().put('levelIds',levelIds.substring(0, levelIds.length()-1));
        pr.setRedirect(true);
        cook = new Cookie('levelIds','',null,-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{cook});
        return pr;
    	}
    	else return null;
    }
    /*************************************************************************************************/
    public Pagereference expandedLocationLink(){
        string levelIds = '';
        for(LevelWrapper lw : lwList){
            levelIds += lw.selectVal+':';
        }
        Pagereference pr = new Pagereference('/apex/PortalExpandedlocationlist');//?levelIds='+levelIds.substring(0, levelIds.length()-1));
        pr.getParameters().put('id', contactId);
        pr.getParameters().put('levelIds',levelIds.substring(0, levelIds.length()-1));
        pr.getParameters().put('startD',this.startDateFilter);
        pr.getParameters().put('endD',this.endDateFilter);
        pr.getParameters().put('prog',this.selectedProgram);
        pr.setRedirect(true);
        return pr;
    }
    
    /*************************************************************************************************/
    private void calculateTotalStats(){
                /*
            public string screenRatio           {get; set;}
            public string screenPercent {get; set;}
            public string qualRatio             {get; set;}
            public string qualPercent   {get; set;}     
            */
            integer screenNum = 0;
            integer screenDenom =0;
            integer qualNum = 0;
            integer docNum = 0;
            integer docDenom =0;
            
            for(locationProgramWrapper lw: locationList){
                screenNum+=lw.PortalScreeningComplianceNum;
                screenDenom += lw.PortalScreeningComplianceDenom;
                qualNum+=lw.PortalQualificationNum;
            		docNum += lw.documentNum;
            		docDenom += lw.documentDenom;
            }
                screenRatio = string.valueOf(screenNum)+'%2F'+string.valueOf(screenDenom);
                screenRatioN = string.valueOf(screenNum);
                screenRatioD = string.valueOf(roundToFifty(screenDenom));
                screenRatioDM = string.valueOf(screenDenom-screenNum);
                screenRatioExcel = string.valueOf(screenNum)+'/'+string.valueOf(screenDenom);
                if(Double.valueOf(screenDenom)==0)ScreenPercent='0';
                else screenPercent = string.valueOf(Integer.valueOf(100*(double.valueOf(screenNum)/Double.valueOf(screenDenom))));
                
                
                qualRatio = string.valueOf(qualNum)+'%2F'+string.valueOf(screenDenom);
                qualRatioExcel = string.valueOf(qualNum)+'/'+string.valueOf(screenDenom);
                //qualQ = string.valueOf(integer.valueOf(qualNum / 2));
                qualQ = string.valueOf(integer.valueOf(qualNum));
                system.debug('TCC qualq' + qualQ);
                //qualUQ = string.valueOf(integer.valueOf(screenDenom - (qualNum/2)));
                qualUQ = string.valueOf(integer.valueOf(screenDenom - (qualNum)));
                system.debug('TCC qualuq' + qualUQ);
                if(screenDenom == 0) qualPercent ='0';
                else qualPercent= string.valueOf(Integer.valueOf(100*(double.valueOf(qualNum)/Double.valueOf(screenDenom))));
                
                // DEMO
                //qualPercent = string.valueOf(integer.valueOf((double.valueOf(qualPercent) / 2)));
                
                
                system.debug('TCC qual num:' + string.valueOf(qualNum));
                system.debug('TCC screen denom:' + string.valueOf(screenDenom));
                
                docRatio = string.valueOf(docNum)+'%2F'+string.valueOf(docDenom);
                docRatioN =string.valueOf(docNum);
                docRatioD=string.valueOf(roundToFifty(docDenom));
                docRatioDM = string.valueOf(docDenom - docNum);
                docRatioExcel = string.valueOf(docNum)+'/'+string.valueOf(docDenom);
                if(docDenom == 0) docPercent ='0';
                else docPercent= string.valueOf(Integer.valueOf(100*(double.valueOf(docNum)/Double.valueOf(docDenom))));
    }
    /*************************************************************************************************/
    private integer roundToFifty(Integer val){
    	integer rVal = 0;
    	boolean b = true;
    	while(b){
    		rVal =  rVal +50;
    		if(rVal > val) b =false;
    	}
    	return rVal;
    }
    /*************************************************************************************************/
    public void previousLLPage(){
        if(locationList==null || locationList.size() == 0)
            return;
        string lastNameInList = locationList[0].lp.location__r.Name;
        list<LocationProgram__c> ll = [Select Program__r.ShortName__c, Program__c,  Location__c, 
                                                                Location__r.LongitudeCode__c,
                                                                Location__r.LatitudeCode__c,
                                                                Location__r.State__r.Name, Location__r.StreetAddressText__c, location__r.State__r.StateAbbr__c,
                                                                Location__r.State__c, Location__r.Name, Location__r.LocationEID__c,
                                                                Location__r.CityName__c, Location__r.AccountHierarchyMember__c
                                                                From LocationProgram__c 
                                                                where Location__r.AccountHierarchyMember__c in :ahmSet
                                                                AND Location__r.Account__c = :accountId
                                                                and Program__r.ShortName__c =:this.selectedProgram
                                                                and location__r.Name < :lastNameInList 
                                                                order by Location__r.Name
                                                                limit :max
                                                                ]; 
                                                                
            
        system.debug('TCC selected' + this.selectedProgram);                                                    
        if(ll!=null && ll.size()>0)  {
	        locationList = new list<locationProgramWrapper>();
	        integer endVal = max;
	        if(ll.size() < max)
	            endVal = ll.size();
	        String color = 'white'; 
	        for(Integer i=0; i<endVal; i++){
	            locationList.add(new locationProgramWrapper(ll[i], color));
	            if(color == 'white')
	                color ='white';//'lightgrey';
	            else
	                color = 'white';
	        }
	       list<Date> dates = checkDates();
	       PortalScreeningComplianceHelper.setupPSC(locationList, dates[0], dates[1]);
	       calculateTotalStats();
	       
	       rStart = rStart - max;
           rEnd = rStart+max-1;
       }
    }
    /*************************************************************************************************/
    public void nextLLPage(){
        if(locationList==null || locationList.size() == 0)
            return;
        string lastNameInList = locationList[locationList.size()-1].lp.location__r.Name;
        list<LocationProgram__c> ll = [Select Program__r.ShortName__c, Program__c, Location__c, 
                                                                Location__r.LongitudeCode__c,
                                                                Location__r.LatitudeCode__c,
                                                                Location__r.State__r.Name, Location__r.StreetAddressText__c, location__r.State__r.StateAbbr__c,
                                                                Location__r.State__c, Location__r.Name, Location__r.LocationEID__c,
                                                                Location__r.CityName__c, Location__r.AccountHierarchyMember__c
                                                                From LocationProgram__c 
                                                                where Location__r.AccountHierarchyMember__c in :ahmSet
                                                                AND Location__r.Account__c = :accountId
                                                                and Program__r.ShortName__c =:this.selectedProgram
                                                                and location__r.Name > :lastNameInList 
                                                                order by Location__r.Name
                                                                limit :max
                                                                ]; 
        if(ll!=null && ll.size()>0){
                                                                   
	        locationList = new list<locationProgramWrapper>();
	        integer endVal = max;
	        if(ll.size() < max)
	            endVal = ll.size();
	        String color = 'white'; 
	        for(Integer i=0; i<endVal; i++){
	            locationList.add(new locationProgramWrapper(ll[i], color));
	            if(color == 'white')
	                color = 'white';//'lightgrey';
	            else
	                color = 'white';
	        }
	       list<Date> dates = checkDates();
	       PortalScreeningComplianceHelper.setupPSC(locationList, dates[0], dates[1]);
	       calculateTotalStats();
	       
	       rStart = rStart+max;
           rEnd = rStart+endVal-1;
       }
    }
    /*************************************************************************************************/
    public void setupLocationList(){
        /**/
                                                                         //this.programMap.get(selectedProgram);
	  rCount = 0;
	  rStart = 0;
	  rEnd=0;
      list<LocationProgram__c> ll = [Select Program__r.ShortName__c, Program__c, Location__c, 
                                                                Location__r.LongitudeCode__c,
                                                                Location__r.LatitudeCode__c,
                                                                Location__r.State__r.Name, Location__r.StreetAddressText__c, location__r.State__r.StateAbbr__c,
                                                                Location__r.State__c, Location__r.Name, Location__r.LocationEID__c,
                                                                Location__r.CityName__c, Location__r.AccountHierarchyMember__c
                                                                From LocationProgram__c 
                                                                where Location__r.AccountHierarchyMember__c in :ahmSet
                                                                AND Location__r.Account__c = :accountId
                                                                and Program__r.ShortName__c =:this.selectedProgram
                                                                order by Location__r.Name
                                                                limit 1000//:max
                                                                ];                                                                 
        //setupJoeInfo(ll);    
        locationList = new list<locationProgramWrapper>();
        if(ll!=null){
            rCount =      [Select count() From LocationProgram__c 
						   where Program__r.ShortName__c =:this.selectedProgram 
                           and Location__r.Account__c = :accountId
                           and Location__r.AccountHierarchyMember__c in :ahmSet];
            rStart = 1;
            if(rCount<max) rEnd = rStart+rCount-1;
            else rEnd = rEnd+max-1;
            
            integer endVal = max;
            if(ll.size() < max)
                endVal = ll.size();
            String color = 'white'; 
            for(Integer i=0; i<endVal; i++){
                locationList.add(new locationProgramWrapper(ll[i], color));
                if(color == 'white')
                    color = 'white';//'lightgrey';
                else
                    color = 'white';
            }
        }
        else{
            locationListSize=0;
        }
        
        
        if(locationList.size() >0){
            this.showLocationList = true;
            list<Date> dates = checkDates();
            PortalScreeningComplianceHelper.setupPSC(locationList, dates[0], dates[1]);
            calculateTotalStats();
        }
        else this.showLocationList = false;
        setupJoeInfo(locationList);
        
    }
    /*************************************************************************************************/
    public void dateScreen(){
        list<Date> dates = checkDates();
       PortalScreeningComplianceHelper.setupPSC(locationList, dates[0], dates[1]);
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
    /*************************************************************************************************/
    public void switchShowListNotMap(){
        showListNotMap = (!showListNotMap);
    }
    /*************************************************************************************************/
    private void setupJoeInfo(list<locationProgramWrapper> lpList){//list <LocationProgram__c> lpList){
        if(lwList.size()==1)
            joeZoom = 3;
        else if(lwList.size()==2)
            joeZoom = 4;
        else if(lwList.size()==3)   
            joeZoom = 6;
        else if(lwList.size()>3)
            joeZoom = 7;
        else 
            joeZoom = 4;
        
        joeLatAndLongs = new list<String>();
        joeMarkers = new list<String>();
        for(locationProgramWrapper lw :lpList){//locationProgram__c lp :lpList){
            LocationProgram__c l = lw.lp;
            string longtd;
            string lattd;
            if(l.location__r.LongitudeCode__c !=null && l.location__r.LatitudeCode__c !=null){
                longtd = String.valueOf(l.location__r.LongitudeCode__c);
                lattd = string.valueOf(l.location__r.LatitudeCode__c);

                joeLatAndLongs.add('var latlng'+string.valueof(joeLatAndLongs.size())+' = new google.maps.LatLng('+lattd+','+longtd+');');
                joeMarkers.add('var contentString'+l.id+'=\'<div><h2>'+l.location__r.Name+'</h2><table><tr><td>Address:</td><td>'+l.Location__r.StreetAddressText__c+'</td></tr><tr><td>City:</td><td>'+l.Location__r.CityName__c+'</td></tr><tr><td>State:</td><td>'+l.Location__r.State__r.Name+'</td></tr><tr><td><h2>Compliance</h2></td><td></td></tr><tr><td>Screening:</td><td><h2>'+lw.getScreeningCompliancePCNT()+'%</h2></td></tr><tr><td>Document:</td><td><h2>'+lw.getDocumentCompliancePCNT()+'%</h2></td></tr><tr><td>Qualification:</td><td><h2>'+lw.getQualificationRatePCNT()+'%</h2></td></tr></table></div>\';'
                                                                                +'var infowindow'+l.id+' = new google.maps.InfoWindow({content: contentString'+l.id+', maxWidth:100});'
                                                                                +'var marker'+l.id+' = new google.maps.Marker({position: latlng'+string.valueof(joeLatAndLongs.size()-1)+', map: map, title:\''+l.location__r.Name+'\'});'
                                                                                +'google.maps.event.addListener(marker'+l.id+', \'click\', function() {infowindow'+l.id+'.open(map,marker'+l.id+');});');
            }
        }
        //var marker = new google.maps.Marker({position: myLatlng,map: map, title:"Hello World!"});
        //var latlng = new google.maps.LatLng(37.0,-100.0);
            if(joeLatAndLongs.size()==0){   
                joeLatAndLongs.add('var latlng'+string.valueof(joeLatAndLongs.size())+' = new google.maps.LatLng(37.0001, -100.0001);');    
            //joeMarkers.add('var marker'+string.valueof(joeLatAndLongs.size())+' = new google.maps.Marker({position: latlng'+string.valueof(joeLatAndLongs.size()-1)+', map: map, title:\'NO LOCATIONS MAPPED\'});');
            }
    
    }
    /*************************************************************************************************/
    private void setupProgramList(){
        programs = null;

        //get all Programs
        map<String, Decimal> programMaxMap =new map<String, Decimal>();
        ahmSet = getAhmIdSet();
        if(ahmSet == null || ahmSet.size() == 0)
            return;
        list<AggregateResult> arlist = [Select Program__r.ShortName__c
                                                                        From LocationProgram__c where Location__r.Account__c = :accountId
                                                                        and  Location__r.AccountHierarchyMember__c in :ahmSet
                                                                        group by Program__r.ShortName__c];
        list<string> programNames = new list<String>();
        for(AggregateResult ag:arlist){
            programNames.add(String.valueOf(ag.get('ShortName__c')));
        }   
            
        list<Program__c> pList =[select shortName__c, MaximumLifetimeBenefitAmount__c from Program__c where shortName__c in :programNames];
        for(Program__c p:pList){
            programMaxMap.put(p.shortName__c, p.MaximumLifetimeBenefitAmount__c);
        }                                               
                
        setupProgramListAndSetSelected(programMaxMap);
        setupLocationList();
    }
    /*************************************************************************************************/
    private void setupProgramListAndSetSelected(map<string, Decimal> programMaxMap){
        set<String> keyset = programMaxMap.keySet();
        list<String> programList = new list<String>();
        programList.addAll(keyset);
        programList.sort();
        
        
        boolean programSet = false;
        if(this.selectedProgram != null && keyset.contains(this.selectedProgram))
            programSet = true;
        
        Decimal d;
        programs = new list<Selectoption>();
        for(string s: programList){
            programs.add(new SelectOption(s,s));
            
            if(d == null && !programSet){
                this.selectedProgram = s;
                d = programMaxMap.get(s);
            }
            else if(programMaxMap.get(s)>d && !programSet){
                this.selectedProgram = s;
                d = programMaxMap.get(s);
            }
        }
    }
    /*************************************************************************************************/    
    public set<String> getAhmIdSet(){
        set<String> ahmSet = new set<String>();
        if(lwList[0].getselectVal() == '--Select--' || lwList[0].getselectVal() == null)
            return ahmSet;
        integer i;
        for(i=1; i<lwList.size(); i++){
            if(lwList[i].selectVal == null || lwList[i].selectVal == '--Select--')
                break;
        }
        if(i>=lwList.size()){
            ahmSet.add(lwList[lwList.size()-1].getselectVal());
            return ahmSet;
        }
        else{
            return getLowerLevelsForProgram(i);
        }   
    }
    /*************************************************************************************************/
    private set<String> getLowerLevelsForProgram(Integer i){
        set<String> returnVal = new set<String>();
        for(selectOption so : lwList[i].soList){
            if(so.getValue()!='--Select--')
                returnVal.add(so.getValue());
        }

        Set<String> addingSet = new set<String>();
        addingSet.addAll(returnVal);
        while(addingSet != null){
            addingSet = getIdsBelow(addingSet);
            if(addingSet!=null)
                returnVal.addAll(addingSet);
        }
        return returnVal;
    }
    /*************************************************************************************************/
    private set<String> getIdsBelow(set<String> parentSet){
        list<AccountHierarchyMember__c> aList = [select id, ParentAccountHierarchyMember__c 
                                                                                        from AccountHierarchyMember__c
                                                                                        where ParentAccountHierarchyMember__c in :parentSet];
            if(aList != null && aList.size()>0){
                set<String> returnVal = new set<String>();
                for(AccountHierarchyMember__c a : aList){
                    returnVal.add(a.Id);
                }
                return returnVal;
            }
            else{
                return null;
            }                                                                                       
    }
    /*************************************************************************************************/
    public void setupTopNode(){
            list<AccountHierarchyMember__c> ahmList;
            if(userACM !=null){
                 ahmList = [Select ParentAccountHierarchyMember__c, Name, Id, AccountHierarchyMemberName__c,
                                        AccountHierarchyMemberLabelName__c, AccountHierarchyLevel__c, AccountHierarchyLevel__r.AccountHierarchyLevelLabelName__c 
                                        From AccountHierarchyMember__c 
                                        where id =:userACM 
                                        and Account__c = :accountId];
            }
            else{
                ahmList = [Select ParentAccountHierarchyMember__c, Name, Id, AccountHierarchyMemberName__c,
                                    AccountHierarchyMemberLabelName__c, AccountHierarchyLevel__c, AccountHierarchyLevel__r.AccountHierarchyLevelLabelName__c 
                                    From AccountHierarchyMember__c 
                                    where ParentAccountHierarchyMember__c = null 
                                    and Account__c = :accountId];
            }                                                                                                    
            if(ahmList != null && ahmList.size()>0){
                string levelName = ahmList[0].AccountHierarchyLevel__r.AccountHierarchyLevelLabelName__c;
                string levelId = ahmList[0].AccountHierarchyLevel__c;
                lwList = new list <LevelWrapper>();
                lwList.add(new LevelWrapper(levelName, levelId,  ahmList));
            }
    }
    /*************************************************************************************************/
    public void updateNodeList(){
        if(lwList[0].selectVal == '--Select--'){
            setupTopNode();
            showLocationList =false;
        }
        else{
            integer listNum = findChangeLevel();
            if(listNum == -1)
                bottomLWListAdd();
            else{
                changeMiddleList(listNum);
            }
        }
        LevelWrapper lw = lwList[lwList.size()-1];
        if((lw.selectVal == null ||lw.selectVal == '--Select--') && lw.soList.size()==2){
            lw.selectVal=lw.soList[1].getValue();
                updateNodeList();
        }
        else{
            setupProgramList();
        }
   			addCookies();
    }
    /*************************************************************************************************/
    private void changeMiddleList(Integer num){
        integer i = lwList.size()-1;
        while(i!=num){
            lwList.remove(i);
            i=i-1;
        }
        bottomLWListAdd();      
    }
    /*************************************************************************************************/
    private integer findChangeLevel(){
        string parentVal = lwList[0].selectVal;
        integer i;
        for(i=1; i<lwList.size(); i++){
            if(parentVal=='--Select--'){
                i = i-1;
                break;
            }
            else if(lwList[i].ahmList[0].ParentAccountHierarchyMember__c != parentVal)
                break;
            else
                parentVal = lwList[i].selectVal;    
        }
        if(i<lwList.size())
            return i-1;
        else
         return -1;
    }
    /*************************************************************************************************/
    private void bottomLWListAdd(){
        integer lastNum = lwList.size()-1;
        string memberId = lwList[lastNum].selectVal;
        bottomListChange(memberId);
        
    }
    /*************************************************************************************************/
    private void bottomListChange(string memberId){
        list <AccountHierarchyMember__c> ahlList = [Select ParentAccountHierarchyMember__c, Name, Id, AccountHierarchyMemberName__c,
                                                                                                 AccountHierarchyMemberLabelName__c, AccountHierarchyLevel__c, AccountHierarchyLevel__r.AccountHierarchyLevelLabelName__c 
                                                                                                 From AccountHierarchyMember__c 
                                                                                                 Where ParentAccountHierarchyMember__c = :memberId
                                                                                                 order by AccountHierarchyMemberLabelName__c
                                                                                                 limit 999];
        if(ahlList != null && ahlList.size()>0){
            addNewBottomNode(ahlList);
        }
    }
    /*************************************************************************************************/
    private void addNewBottomNode(list <AccountHierarchyMember__c> ahlList){
            string levelName = ahlList[0].AccountHierarchyLevel__r.AccountHierarchyLevelLabelName__c;
            string levelId = ahlList[0].AccountHierarchyLevel__c;
            lwList.add(new LevelWrapper(levelName, levelId, ahlList));      
    }
    /*************************************************************************************************/
}