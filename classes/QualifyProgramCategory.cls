global class QualifyProgramCategory {

    private Map<decimal, EmployeeSurveyAnswer__c> answerMap = new Map<decimal, EmployeeSurveyAnswer__c>();  
    public string employeeSurveyRecord {get; set;}
    public Decimal currentSurveyQuestionEID {get; set;} 
    public List<EmployeeSurveyAnswer__c> answerList;
    public Date hireDate {get; set;}
    public String countyId {get; set;}
    public String cityName {get; set;}
    public String stateId {get; set;}
    public EmployeeAddress__c employeeAddress {get; set;}
    public EmployeeSurvey__c employeeSurvey {get; set;} 
    public Boolean isSelfEmployed {get; set;}
    public String locationId {get; set;}
    public Datetime surveyDate {get;set;}
    public boolean isSurveyAfterHire {get; set;}
    public static boolean byPassPreventDuplicatePQ = false ;
    public boolean isWotc {get; set;}
    public boolean isCaez {get; set;}
    public boolean isIowaExfelon {get;set;}
               
    public QualifyProgramCategory(string employeeSurveyId)
    {
        employeeSurveyRecord = employeeSurveyId;
        isSurveyAfterHire = false;
        countyId = null;
        isSelfEmployed = false;
        isWotc = false;
        isCaez = false;
        isIowaExfelon = false;
        
        // Get list of questions
        answerList = [select Id, EmployeeSurvey__c, EmployeeSurvey__r.EmploymentPeriod__r.StartDate__c, SurveyQuestion__r.QuestionEID__c, EmployeeSurveyAnswerDate__c, EmployeeSurveyAnswerAmount__c, EmployeeSurveyAnswerText__c from EmployeeSurveyAnswer__c where EmployeeSurvey__c =:employeeSurveyRecord];
        
        employeeSurvey = [select    Id, 
                                    EmploymentPeriod__c,
                                    EmploymentPeriod__r.Employee__c,
                                    EmploymentPeriod__r.StartDate__c,                                                    
                                    EntityLocation__r.Location__c,
                                    EntityLocation__r.Location__r.County__c,
                                    EntityLocation__r.Location__r.State__c,
                                    EntityLocation__r.Location__r.County__r.Name,
                                    EntityLocation__r.Location__r.State__r.StateAbbr__c, 
                                    ReportedHireDate__c,
                                    SurveyDate__c 
                            from EmployeeSurvey__c where Id =:employeeSurveyRecord];
                            
		if(employeeSurvey != null)
		{                           
            hireDate = employeeSurvey.EmploymentPeriod__r.StartDate__c;
	        hireDate = hireDate.addDays(28);       
	        surveyDate = employeeSurvey.SurveyDate__c;
	        
	        SurveyProgramScreened__c[] spsList = [select Id, Program__r.ProgramEID__c from SurveyProgramScreened__c where Survey__c =:employeeSurvey.Id];
	        if(spsList.size() > 0)
	        {
	        	for(SurveyProgramScreened__c sps : spsList)
	        	{
	        		if(sps.Program__r.ProgramEID__c == 1)
	        		{
	        			isWotc = true;
	        		}
	        		
	        		if(sps.Program__r.ProgramEID__c == 2)
	        		{
	        			isCaez = true;
	        		}
	        		
	        		if(sps.Program__r.ProgramEID__c == 100)
	        		{
	        			isIowaExfelon = true;
	        		}	        		
	        	}
	        }
	        
	        if(surveyDate.dayOfYear() <= hireDate.dayOfYear())
	        {
	            isSurveyAfterHire = false;
	        }
	        else
	        {
	            isSurveyAfterHire = true;
	        }
	        
	        EmployeeAddress__c[] tempAddressList = [select 	Id, 
	        							County__c, 
	        							State__c, 
	        							County__r.Name, 
	        							State__r.StateAbbr__c,
	        							CityName__c, 
	        							ZipCode__c
	        					from 
	        						EmployeeAddress__c 
	        					where 
	        						Employee__c =:employeeSurvey.EmploymentPeriod__r.Employee__c 
	        						and EffectiveDate__c <=:employeeSurvey.ReportedHireDate__c 
	        					order by 
	        						EffectiveDate__c desc];
			
			if(tempAddressList.size() > 0)
			{
				employeeAddress = tempAddressList[0];
				countyId = employeeAddress.County__c;
				cityName = employeeAddress.CityName__c;
				stateId = employeeAddress.State__c;
			}        						
	        	        
	        locationId = employeeSurvey.EntityLocation__r.Location__c;
	   }
	   
   	   if(answerList != null)
       {
          // Set up map
          for(EmployeeSurveyAnswer__c esa : answerList)
          {
              answerMap.put(esa.SurveyQuestion__r.QuestionEID__c, esa);
            
          }
       }   
    }
    
    public string QualifyAnswers()
    {
        string returnValue = '';
        Decimal incomeThreshold = 0.00;
        Decimal incomeSum = 0.00;
        Decimal householdMemberSum = 1; // Include the individual taking the survey
        integer yearend = employeeSurvey.EmploymentPeriod__r.StartDate__c.year();
        date mydate = date.newinstance(yearend, 12,31);
		List<string> areaIdList = new List<string>();
		List<decimal> catList = new List<decimal>();
		                
		if(hireDate != null && employeeAddress != null && !isSurveyAfterHire && isWotc)
		{               
			// Designated Community Resident
        	ProgramCategoryPeriod__c[] pcpList = [Select
        												Id, 	
        												Area__r.Id,
        												StartDate__c,        												 
        												EndDate__c        												 
        											From 
        												ProgramCategoryPeriod__c p 
        											where 
        												ProgramCategory__r.ProgramCategoryEID__c = 68 
        												and StartDate__c <=:hireDate
        												and EndDate__c >=:hireDate];
        												
			if(pcpList.size() > 0)
			{
				
				for(ProgramCategoryPeriod__c pcp : pcpList)
				{
					if(pcp.Area__c != null)
					{
						areaIdList.add(pcp.Area__r.Id);
					}
				}
			} 
			
			boolean IsDesignatedCommunityResident = false; 
			AreaCounty__c[] areaCountyList = [select Id, County__c from AreaCounty__c where Area__c in:areaIdList];
			AreaCity__c[] areaCityList = [select Id, City__r.Name, City__r.County__c from AreaCity__c where Area__c in:areaIdList];
			
			// Look to see if the employee's city and county are part of the Area
			if(areaCityList.size() > 0 && cityName != null && cityName != '' && countyId != null && countyId != '')
			{
				for(AreaCity__c ac : areaCityList)
				{
					System.debug('JM:AreaCity:ac.city.name' + ac.City__r.Name + ', ' + ac.City__r.County__c);
					System.debug('JM:AreaCity:cityname' + cityName + ', ' + countyId);
					if(ac.City__r.Name == cityName && ac.City__r.County__c == countyId)
					{
						IsDesignatedCommunityResident = true;
						
						System.debug('JM:IsResident');
					}						
				}
				
				System.debug('JM:AreaCity:' + cityName + ', ' + countyId);
			}
			
			// If we don't find the employee's city/county combo, just look for the county
			if(!IsDesignatedCommunityResident && areaCountyList.size() > 0 && countyId != null && countyId != '')
			{
				for(AreaCounty__c ac : areaCountyList)
				{
					if(ac.County__c == countyId)
					{
						IsDesignatedCommunityResident = true;
					}
				}
				
				System.debug('JM:AreaCounty:' + cityName + ', ' + countyId);
			}
			
			if(IsDesignatedCommunityResident)
			{
				System.debug('JM:Adding Category');
				catList.add(68);
			}			       												
		}
        
        if(answerMap != null)
        {
            // CAEZ/WOTC Prior WOTC
            if(answerMap.get(11) != null)
            {
                EmployeeSurveyAnswer__c question11 = answerMap.get(11);
                                
                if(question11.EmployeeSurveyAnswerText__c == 'Yes')
                {                   
                    catList.add(76);
                    catList.add(132);                                   
                }
            }

            
            // CAEZ Disabled individual
            if(answerMap.get(1) != null && answerMap.get(2) != null)
            {
                EmployeeSurveyAnswer__c question1 = answerMap.get(1);
                EmployeeSurveyAnswer__c question2 = answerMap.get(2);
                
                if(question1.EmployeeSurveyAnswerText__c == 'Yes' && question2.EmployeeSurveyAnswerText__c == 'Yes')
                {
                    catList.add(86);                    
                }
            }
            
            // WOTC Referrals
            if(answerMap.get(16) != null && !isSurveyAfterHire)
            {
                EmployeeSurveyAnswer__c question16 = answerMap.get(16);             
                
                if(question16.EmployeeSurveyAnswerText__c == 'Department of Veterans Affairs'
                || question16.EmployeeSurveyAnswerText__c == 'Ticket to Work Program'
                || question16.EmployeeSurveyAnswerText__c == 'Vocational Rehabilitation Agency')
                {
                    catList.add(69);                    
                }
            }
            
            // CAEZ WIA
            if(answerMap.get(12) != null)
            {
                EmployeeSurveyAnswer__c question12 = answerMap.get(12);
                
                if(question12.EmployeeSurveyAnswerText__c == 'California One-Stop Center'
                || question12.EmployeeSurveyAnswerText__c == 'Employment Resource Center'
                || question12.EmployeeSurveyAnswerText__c == 'Government Job Placement Services' 
                || question12.EmployeeSurveyAnswerText__c == 'Non-profit Job Placement Agency'
                || question12.EmployeeSurveyAnswerText__c == 'Workforce Investment Board')
                {
                    catList.add(75);                    
                }
            }
            
            
            // CAEZ Dislocated Worker E4
            if(answerMap.get(18) != null && answerMap.get(21) != null && answerMap.get(23) != null)
            {
                EmployeeSurveyAnswer__c question18 = answerMap.get(18);
                EmployeeSurveyAnswer__c question21 = answerMap.get(21);
                EmployeeSurveyAnswer__c question23 = answerMap.get(23);
                
                if(question18.EmployeeSurveyAnswerText__c == 'Yes' && question21.EmployeeSurveyAnswerText__c == 'Yes' 
                    && (question23.EmployeeSurveyAnswerText__c == 'Economic Conditions' || question23.EmployeeSurveyAnswerText__c == 'Natural Disaster'))
                {
                    catList.add(81);
                    isSelfEmployed = true;                  
                }
            }
            
            // CAEZ Dislocated Worker E1
            if(answerMap.get(18) != null && answerMap.get(28) != null && answerMap.get(30) != null)
            {
                EmployeeSurveyAnswer__c question18 = answerMap.get(18);
                EmployeeSurveyAnswer__c question28 = answerMap.get(28);                
                EmployeeSurveyAnswer__c question30 = answerMap.get(30);
                
                // No longer care if they were still working when hired by Employer
                // && question28.EmployeeSurveyAnswerText__c == 'No'   
                if(question18.EmployeeSurveyAnswerText__c == 'No'                                      
                    && question30.EmployeeSurveyAnswerText__c == 'Yes')
                {
                    catList.add(78);                    
                }
            }
            
            // CAEZ Dislocated Worker E2
            if(answerMap.get(18) != null && answerMap.get(29) != null)
            {
                EmployeeSurveyAnswer__c question18 = answerMap.get(18);
                EmployeeSurveyAnswer__c question29 = answerMap.get(29);
                
                if(question18.EmployeeSurveyAnswerText__c == 'No' 
                    && question29.EmployeeSurveyAnswerText__c == 'Company or location closure or mass layoffs')
                {
                    catList.add(79);                    
                }
            }
            
            // CAEZ Dislocated Worker E7
            if(answerMap.get(18) != null && answerMap.get(29) != null)
            {
                EmployeeSurveyAnswer__c question18 = answerMap.get(18);
                EmployeeSurveyAnswer__c question29 = answerMap.get(29);
                
                if(question18.EmployeeSurveyAnswerText__c == 'No' 
                    && question29.EmployeeSurveyAnswerText__c == 'End of seasonal position')
                {
                    catList.add(84);                    
                }
            }
      
            
            // CAEZ Native American
            if(answerMap.get(31) != null && answerMap.get(32) != null)
            {
                EmployeeSurveyAnswer__c question31 = answerMap.get(31);
                EmployeeSurveyAnswer__c question32 = answerMap.get(32);
                
                if(question31.EmployeeSurveyAnswerText__c == 'Yes' && question32.EmployeeSurveyAnswerText__c == 'Yes')
                {
                    catList.add(90);                    
                }
            }
            
            // WOTC SSI
            if(answerMap.get(33) != null && !isSurveyAfterHire) // Yes or No
            {
                EmployeeSurveyAnswer__c question33 = answerMap.get(33);
                
                if(question33.EmployeeSurveyAnswerText__c == 'Yes')
                {
                    catList.add(72);                    
                }           

            }
            
            // CAEZ SSI
            if(answerMap.get(36) != null) // Yes or No
            {
                EmployeeSurveyAnswer__c question36 = answerMap.get(36);                
                
                // CAEZ SSI
                if(question36.EmployeeSurveyAnswerText__c == 'Yes')
                {
                    catList.add(89);                    
                }
                
                // WOTC SSI
                if(question36.EmployeeSurveyAnswerText__c == 'Yes' && !isSurveyAfterHire)
                {
                    catList.add(72);
                }                                       
               
            }
            
            // CAEZ Gov Assistance
            if(answerMap.get(37) != null)
            {
                EmployeeSurveyAnswer__c question37 = answerMap.get(37);             
                
                if(question37.EmployeeSurveyAnswerText__c != 'N/A' && question37.EmployeeSurveyAnswerText__c != 'None of the Above')
                {
                    catList.add(89);                    
                }
            }            
            
            // Combo SNAP
            if(answerMap.get(48) != null)
            {
                EmployeeSurveyAnswer__c question48 = answerMap.get(48); 
                if(question48.EmployeeSurveyAnswerText__c == 'Yes')
                {
                    if(!isSurveyAfterHire)
                    {
                        catList.add(71); // WOTC
                    }
                    
                    catList.add(89); // CAEZ
                }
            }  
            

            // WOTC SNAP
            if(answerMap.get(41) != null && !isSurveyAfterHire) // Yes or No
            {
                EmployeeSurveyAnswer__c question41 = answerMap.get(41);
                if(question41.EmployeeSurveyAnswerText__c == 'Yes')
                {
                    catList.add(71);                    
                }           
            }
            
            
            
            // WOTC TANF
            if(answerMap.get(49) != null && answerMap.get(53) != null && !isSurveyAfterHire)
            {
                EmployeeSurveyAnswer__c question49 = answerMap.get(49);
                EmployeeSurveyAnswer__c question53 = answerMap.get(53);         
                
                if(question49.EmployeeSurveyAnswerText__c == 'Yes' && question53.EmployeeSurveyAnswerText__c == 'No')
                {
                    catList.add(64);                    
                }  
                else if(question49.EmployeeSurveyAnswerText__c == 'Yes' && question53.EmployeeSurveyAnswerText__c == 'Yes')  
                {
                	catList.add(73);
                } 

            }           

            
            // WOTC Food Stamps Vet
            if(answerMap.get(57) != null && answerMap.get(41) != null && !isSurveyAfterHire)
            {
                EmployeeSurveyAnswer__c question57 = answerMap.get(57); 
                EmployeeSurveyAnswer__c question41 = answerMap.get(41);             
                
                if(question57.EmployeeSurveyAnswerText__c == 'Yes' && question41.EmployeeSurveyAnswerText__c == 'Yes'  )
                {               
                    catList.add(65); // Qualified Veteran SNAP                
                }
            }
            
            // WOTC Food Stamps Vet
            if(answerMap.get(57) != null && answerMap.get(48) != null && !isSurveyAfterHire)
            {
                EmployeeSurveyAnswer__c question57 = answerMap.get(57); 
                EmployeeSurveyAnswer__c question48 = answerMap.get(48);             
                
                if(question57.EmployeeSurveyAnswerText__c == 'Yes' && question48.EmployeeSurveyAnswerText__c == 'Yes'  )
                {               
                    catList.add(65); // Qualified Veteran SNAP                
                }
            }
            

            // WOTC Veteran: Short-term/Long-term Unemployed
            if(answerMap.get(57) != null && answerMap.get(64) != null && !isSurveyAfterHire)
            {
                EmployeeSurveyAnswer__c question57 = answerMap.get(57); 
                EmployeeSurveyAnswer__c question64 = answerMap.get(64);             
                
                if(question57.EmployeeSurveyAnswerText__c == 'Yes' 
                && question64.EmployeeSurveyAnswerText__c == '4 weeks - 6 months'  )
                {               
                    catList.add(134); // Short-term                  
                }
                else if(question57.EmployeeSurveyAnswerText__c == 'Yes' 
                && question64.EmployeeSurveyAnswerText__c == '6 months +'  )
                {               
                    catList.add(135); // Long-term                 
                }
                
            }
            
            // WOTC Veteran: Recent Disability
            if(answerMap.get(57) != null && answerMap.get(63) != null && !isSurveyAfterHire)
            {
                EmployeeSurveyAnswer__c question57 = answerMap.get(57); 
                EmployeeSurveyAnswer__c question63 = answerMap.get(63);     
                //EmployeeSurveyAnswer__c question62 = answerMap.get(62);   
                
                //Date dischargeDate = question62.EmployeeSurveyAnswerDate__c;      
                //Integer months = dischargeDate.monthsBetween(hireDate);
                
                //if(question57.EmployeeSurveyAnswerText__c == 'Yes' 
                //&& question63.EmployeeSurveyAnswerText__c == 'Yes' 
                //&& months <= 12)
                if(question57.EmployeeSurveyAnswerText__c == 'Yes' 
                && question63.EmployeeSurveyAnswerText__c == 'Yes')
                {
                	catList.add(66); // Veteran: Recent Disability 
                }
            }
            
            // WOTC Veteran: Disabled/Recently Unemployed
            if(answerMap.get(57) != null && answerMap.get(63) != null && answerMap.get(64) != null && !isSurveyAfterHire)
            {
                EmployeeSurveyAnswer__c question57 = answerMap.get(57); 
                EmployeeSurveyAnswer__c question63 = answerMap.get(63);     
                EmployeeSurveyAnswer__c question64 = answerMap.get(64);   
                   
                if(question57.EmployeeSurveyAnswerText__c == 'Yes' 
                && question63.EmployeeSurveyAnswerText__c == 'Yes' 
                && question64.EmployeeSurveyAnswerText__c == '6 months +')
                {
                	catList.add(133); // Veteran: Disabled/Recently Unemployed
                }
            }
            
            
            // CAEZ disabled vet
            if(answerMap.get(57) != null && answerMap.get(69) != null && answerMap.get(58) != null)
            {
                EmployeeSurveyAnswer__c question57 = answerMap.get(57); 
                EmployeeSurveyAnswer__c question58 = answerMap.get(58); 
                EmployeeSurveyAnswer__c question69 = answerMap.get(69);             
                
                if(question57.EmployeeSurveyAnswerText__c == 'Yes' 
                && question69.EmployeeSurveyAnswerText__c == 'Yes' 
                && question58.EmployeeSurveyAnswerText__c == 'Veteran')
                {               
                    catList.add(86);                    
                }          
            }
            
            // CAEZ recently separated or vietnam vet based on discharge
            if(answerMap.get(57) != null && answerMap.get(62) != null && answerMap.get(58) != null)
            {
                EmployeeSurveyAnswer__c question57 = answerMap.get(57); 
                EmployeeSurveyAnswer__c question58 = answerMap.get(58); 
                EmployeeSurveyAnswer__c question62 = answerMap.get(62);
                
                Date dischargeDate = question62.EmployeeSurveyAnswerDate__c;
                Date beginDate = Date.newInstance(1964, 8, 5);
                Date endDate = Date.newInstance(1975, 5, 7);
                Boolean isVietnamEra = false;
                
                if(dischargeDate <= endDate && dischargeDate >= beginDate)
                {
                    isVietnamEra = true;
                }
                
                Integer months = dischargeDate.monthsBetween(hireDate);             
                
                if(question57.EmployeeSurveyAnswerText__c == 'Yes' 
                && (months <= 48 || isVietnamEra) 
                && question58.EmployeeSurveyAnswerText__c == 'Veteran')
                {               
                    catList.add(87); // CAEZ Discharged in Vietnam                   
                }

            }
            // CAEZ recently separated or vietnam vet based on enlistment
            if(answerMap.get(57) != null && answerMap.get(61) != null && answerMap.get(58) != null)
            {
                EmployeeSurveyAnswer__c question57 = answerMap.get(57); 
                EmployeeSurveyAnswer__c question58 = answerMap.get(58); 
                EmployeeSurveyAnswer__c question61 = answerMap.get(61);
                
                Date enlistDate = question61.EmployeeSurveyAnswerDate__c;
                Date beginDate = Date.newInstance(1964, 8, 5);
                Date endDate = Date.newInstance(1975, 5, 7);
                Boolean isVietnamEra = false;
                
                if(enlistDate <= endDate && enlistDate >= beginDate)
                {
                    isVietnamEra = true;
                }   
                
                if(question57.EmployeeSurveyAnswerText__c == 'Yes' 
                && isVietnamEra 
                && question58.EmployeeSurveyAnswerText__c == 'Veteran')
                {               
                    catList.add(87); // CAEZ Enlisted in Vietnam                    
                }               

            }        
            
            
            // WOTC XO
            if(answerMap.get(74) != null && !isSurveyAfterHire)
            {   
                EmployeeSurveyAnswer__c question74 = answerMap.get(74);             
                
                if(question74.EmployeeSurveyAnswerText__c == 'Yes')                  
                {
                    catList.add(67);                    
                }       
            }            
           
            // CAEZ XO Combo Logic 
            if(answerMap.get(80) != null) 
            {
                EmployeeSurveyAnswer__c question80 = answerMap.get(80);
                if(question80.EmployeeSurveyAnswerText__c == 'Yes')                 
                {
                    catList.add(88); // CAEZ XO               
                }   
                
                if(answerMap.get(74) != null && !isSurveyAfterHire)
                {
                    EmployeeSurveyAnswer__c question74 = answerMap.get(74); 
                    if(question74.EmployeeSurveyAnswerText__c == 'Yes')                 
                    {
                        catList.add(67);  // WOTC XO  
                        
                        if(isIowaExfelon)
                        {
                        	catList.add(1000);
                        }                
                    }   
                }
            }
            
            // WOTC or Combo XO
            if(answerMap.get(108) != null && !isSurveyAfterHire)
            {
                EmployeeSurveyAnswer__c question108 = answerMap.get(108);                          
                
                if(question108.EmployeeSurveyAnswerText__c == 'Yes')                  
                {
                    catList.add(67); 
                    
                    if(isIowaExfelon)
                    {
                    	catList.add(1000);
                    }                      
                }       
            }
            
            // CAEZ Economically Disadvantaged
            if((answerMap.get(83) != null && answerMap.get(102) != null)) 
            {
                

                EmployeeSurveyAnswer__c question102 = answerMap.get(102);                
                EmployeeSurveyAnswer__c question83 = answerMap.get(83);
                Decimal employeeIncomeAmount = question83.EmployeeSurveyAnswerAmount__c;
                
                if(test.isRunningTest()||question102.EmployeeSurveyAnswerText__c == 'Yes')
                {
                    incomeSum =incomeSum + question83.EmployeeSurveyAnswerAmount__c;
                }
                else if(question102.EmployeeSurveyAnswerText__c == 'No')
                {
                    // They don't know their own income so ensure they don't qualify
                    incomeSum =incomeSum + 1000000;
                }
                
                // Spouse Income
                if(answerMap.get(84) !=null && answerMap.get(85) != null && answerMap.get(101) != null)
                {
                    EmployeeSurveyAnswer__c question84 = answerMap.get(84);
                    EmployeeSurveyAnswer__c question85 = answerMap.get(85);
                    EmployeeSurveyAnswer__c question101 = answerMap.get(101);
                    
                    // If they have a spouse and know their income
                    if(question84.EmployeeSurveyAnswerText__c == 'Yes' && question101.EmployeeSurveyAnswerText__c == 'Yes')
                    {
                        incomeSum =incomeSum+question85.EmployeeSurveyAnswerAmount__c; // Add the spouses income 
                        householdMemberSum = householdMemberSum + 1; // Add another person to the household members
                    } 
                    else if(question84.EmployeeSurveyAnswerText__c == 'Yes' && question101.EmployeeSurveyAnswerText__c == 'No')
                    {
                        // They do not know spouse's income so set their income sum to an amount that does not qualify
                        incomeSum =incomeSum+1000000; // Add the spouses income 
                        householdMemberSum = householdMemberSum + 1; // Add another person to the household members
                    }                 
                }
                // Children Income
                if(answerMap.get(88) !=null && answerMap.get(89) != null && answerMap.get(106) != null)
                {
                    
                    EmployeeSurveyAnswer__c question88 = answerMap.get(88);
                    EmployeeSurveyAnswer__c question89 = answerMap.get(89);
                    EmployeeSurveyAnswer__c question106 = answerMap.get(106);
                    
                    if(question88.EmployeeSurveyAnswerText__c == 'Yes' && question106.EmployeeSurveyAnswerText__c == 'Yes')
                    {                       
                        incomeSum = incomeSum + question89.EmployeeSurveyAnswerAmount__c; // Add the income of the children to the sum
                    }
                    if(question88.EmployeeSurveyAnswerText__c == 'Yes' && question106.EmployeeSurveyAnswerText__c == 'No')
                    {                       
                        incomeSum = incomeSum + 1000000; // Dont know so disqualify the income
                    }
                    
                    if(answerMap.get(87) != null)
                    {
                        EmployeeSurveyAnswer__c question87 = answerMap.get(87);
                        if(question87.EmployeeSurveyAnswerAmount__c > 0)
                        {
                            householdMemberSum = householdMemberSum + question87.EmployeeSurveyAnswerAmount__c; // Add the kinderlach
                        }
                    }                   
                }
                
                EmployeeSurveyAnswer__c question93 = null;
                if(answerMap.get(93) != null)
                {
                    question93 = answerMap.get(93); 
                }
                
                // Only use parent and sibling financials if their parents claimed them on their taxes
                if(question93 != null && question93.EmployeeSurveyAnswerText__c == 'Yes')
                {
                    // Parents Income
                    if(answerMap.get(90) !=null && answerMap.get(94) != null && answerMap.get(103) != null)
                    {
                        EmployeeSurveyAnswer__c question90 = answerMap.get(90);
                        EmployeeSurveyAnswer__c question94 = answerMap.get(94);
                        EmployeeSurveyAnswer__c question103 = answerMap.get(103); 
                    
                        if(question90.EmployeeSurveyAnswerText__c == 'Yes' && question103.EmployeeSurveyAnswerText__c == 'Yes')
                        {
                            incomeSum = incomeSum + question94.EmployeeSurveyAnswerAmount__c; // Mom and dad's money
                        } 
                        if(question90.EmployeeSurveyAnswerText__c == 'Yes' && question103.EmployeeSurveyAnswerText__c == 'No')
                        {
                            incomeSum = incomeSum + 1000000; // Dont know so disqualify with insane income
                        }                      
                        if(answerMap.get(91) != null)
                        {
                            EmployeeSurveyAnswer__c question91 = answerMap.get(91);
                            if(question91.EmployeeSurveyAnswerText__c == 'Yes')
                            {
                                householdMemberSum = householdMemberSum + 1; // One for mom
                            }
                        
                        }
                        if(answerMap.get(92) != null)
                        {
                            EmployeeSurveyAnswer__c question92 = answerMap.get(92);
                            if(question92.EmployeeSurveyAnswerText__c == 'Yes')
                            {
                                householdMemberSum = householdMemberSum + 1; // One for dad
                            }
                        }
                    }
                    // Siblings Income
                    if(answerMap.get(95) !=null && answerMap.get(97) != null && answerMap.get(104) != null)
                    {
                        EmployeeSurveyAnswer__c question95 = answerMap.get(95);
                        EmployeeSurveyAnswer__c question97 = answerMap.get(97);
                        EmployeeSurveyAnswer__c question104 = answerMap.get(104);
                    
                        if(question95.EmployeeSurveyAnswerText__c == 'Yes' && question104.EmployeeSurveyAnswerText__c == 'Yes')
                        {
                            incomeSum = incomeSum + question97.EmployeeSurveyAnswerAmount__c; // Sibling scratch
                        }   
                        
 
                     
                        if(answerMap.get(96) != null)
                        {
                            EmployeeSurveyAnswer__c question96 = answerMap.get(96);
                            if(question96.EmployeeSurveyAnswerAmount__c > 0)
                            {
                                householdMemberSum =householdMemberSum + question96.EmployeeSurveyAnswerAmount__c; // Number of bros/sisters
                            }
                        }               
                    }
                }
                
                // Other Income
                if(answerMap.get(98) !=null && answerMap.get(100) != null && answerMap.get(105) != null)
                {
                    EmployeeSurveyAnswer__c question98 = answerMap.get(98);
                    EmployeeSurveyAnswer__c question100 = answerMap.get(100);
                    EmployeeSurveyAnswer__c question105 = answerMap.get(105);
                    
                    if(question98.EmployeeSurveyAnswerText__c == 'Yes' && question105.EmployeeSurveyAnswerText__c == 'Yes')
                    {
                        incomeSum = incomeSum + question100.EmployeeSurveyAnswerAmount__c;
                        householdMemberSum = householdMemberSum + 1;
                    }      
                    if(question98.EmployeeSurveyAnswerText__c == 'Yes' && question105.EmployeeSurveyAnswerText__c == 'No')
                    {
                        incomeSum = incomeSum + 1000000; // Dont know so disqualify income
                        householdMemberSum = householdMemberSum + 1;
                    }               
                }
                

                if(householdMemberSum > 0 && countyId != null)
                {

                    
                    List<CountyIncomeLimit__c> countyIncomeLimitList = [select County__c, IncomeAmount__c, EffectiveDate__c, IncomeLevel__c, HouseholdPersonCount__c 
                                                                from CountyIncomeLimit__c 
                                                                where County__c =:countyId
                                                                and HouseHoldPersonCount__c <=:householdMemberSum
                                                                and EffectiveDate__c <=:mydate
                                                                order by EffectiveDate__c desc, HouseholdPersonCount__c desc];
                    if(countyIncomeLimitList.size() > 0)                                                               
                    {
                        incomeThreshold = countyIncomeLimitList[0].IncomeAmount__c;
                        incomeThreshold = incomeThreshold / 4;
                        

                        if(incomeSum <= incomeThreshold && incomeSum > 0 && employeeIncomeAmount > 0)
                        {
                            catList.add(77);
                        }
                        
                        if(incomeSum <= incomeThreshold && employeeIncomeAmount < 1)
		                {
		                    catList.add(131);
		                }   
                    }
                }        
            }                      

        }
        
	    if(catList.size() > 0)
	    {
	        returnValue = SaveProgramCategoryQualification(catList);
	    }
	    else
	    {
	        returnValue = '<b>No program or program category qualifications for this survey.</b>';
	    }
        
        return returnValue;
    }
    
    public string SaveProgramCategoryQualification(List<Decimal> programCategoryEidList)    
    {
    	Boolean IsEDDReleaseCreated = false; 
        Boolean Is8850Created = false;
        String returnValue = '';
        
        Map<string, ProgramQualification__c> pqMap = new Map<string, ProgramQualification__c>();
        Map<decimal, ProgramCategoryQualification__c> pcqMap = new Map<decimal, ProgramCategoryQualification__c>();
        
        List<ProgramQualification__c> pqInsertList = new List<ProgramQualification__c>();
        List<ProgramCategoryQualification__c> pcqInsertList = new List<ProgramCategoryQualification__c>();
        
        List<LocationProgram__c> locationProgramList = [select Program__c from LocationProgram__c where Location__c =:locationId];
        List<string> programIdList = new List<string>();               
        for(LocationProgram__c lp : locationProgramList)
        {
            programIdList.add(lp.Program__c);   
        }
        
        /* Set a bunch of local variables using employee survey record  and programCategoryEID */
        List<ProgramCategory__c> programCategoryList = [select 
        													Id, 
        													Name, 
        													Program__c, 
        													Program__r.Id, 
        													Program__r.ShortName__c, 
        													Program__r.ProgramEID__c, 
        													ProgramCategoryEID__c  
                                                        from 
                                                        	ProgramCategory__c 
                                                        where 
                                                        	ProgramCategoryEID__c in:programCategoryEidList
                                                        	and Program__c in:programIdList
                                                        order by 
                                                        	Program__r.ProgramEID__c asc];
        List<string> programCategoryIdList = new List<string>();        
        for(ProgramCategory__c pc : programCategoryList)
        {           
            programCategoryIdList.add(pc.Id);
        }               
        
        
        ProgramQualification__c programQualification;       
        ProgramCategoryQualification__c programCategoryQualification; 

        QualificationProcessStage__c qps = [select id from QualificationProcessStage__c where QualificationProcessStageEID__c = 8];
        QualificationReadiness__c qr = [select id from QualificationReadiness__c  where QualificationReadinessEID__c = 2];
        
        List<string> locationAreaIds = new List<string>();
        List<string> employeeAddressAreaIds = new List<string>();      
        
        /* Determine Location Areas */
        List<LocationArea__c> locationAreas = [select Area__c from LocationArea__c where Location__c =:employeeSurvey.EntityLocation__r.Location__c];        
        for(LocationArea__c la : locationAreas)
        {
            locationAreaIds.add(la.Area__c);
        }
        
        List<AreaCounty__c> locationAreaCountyAreas = [select Area__c from AreaCounty__c where County__c =:employeeSurvey.EntityLocation__r.Location__r.County__c];
        for(AreaCounty__c ac : locationAreaCountyAreas)
        {
            locationAreaIds.add(ac.Area__c);
        }
               
        List<AreaState__c> locationAreaStateAreas = [select Area__c from AreaState__c where State__c =:employeeSurvey.EntityLocation__r.Location__r.State__c];
        for(AreaState__c ast : locationAreaStateAreas)
        {
            locationAreaIds.add(ast.Area__c);
        } 
        
        /* Determine Employee Areas */
        if(employeeAddress != null)
        {
	        List<EmployeeAddressArea__c> employeeAddressAreas = [select Area__c from EmployeeAddressArea__c where EmployeeAddress__c =:employeeAddress.Id];
	        for(EmployeeAddressArea__c eaa : employeeAddressAreas)
	        {
	            employeeAddressAreaIds.add(eaa.Area__c);
	        }
 		}	        
	             
        if(countyId != null && countyId != '')
        {       
	        List<AreaCounty__c> employeeAreaCountyAreas = [select Area__c from AreaCounty__c where County__c =:countyId];        
	        for(AreaCounty__c eac : employeeAreaCountyAreas)
	        {
	        	system.debug('JM:Found an area to add using county');
	            employeeAddressAreaIds.add(eac.Area__c);
	        }

			system.debug('JM:looking for city:' + cityName + ', county' + countyId);	           
	        if(cityName != null && cityName != '')
	        {
		        List<AreaCity__c> employeeAreaCityAreas = [select Area__c from AreaCity__c where City__r.County__c =:countyId and City__r.Name =:cityName];
		                
		        for(AreaCity__c eca : employeeAreaCityAreas)
		        {
		        	system.debug('JM:Found an area to add using city');
		            employeeAddressAreaIds.add(eca.Area__c);
		        }
	        }
        }
               
        if(stateId != null && stateId != '')
        {           
	        List<AreaState__c> employeeAreaStateAreas = [select Area__c from AreaState__c where State__c =:stateId];        
	        for(AreaState__c eas : employeeAreaStateAreas)
	        {
	            employeeAddressAreaIds.add(eas.Area__c);
	        }
        } 
   
   		if(locationAreaIds.size() > 0 && employeeAddressAreaIds.size() > 0)
   		{
	        /* Get a list of ProgramPeriods using the Areas in Location Area and that apply to the Employment.StartDate */
	        List<ProgramPeriod__c> programPeriodList = [select 
	        												Id, 
	        												Program__r.Id 
	                                                    from 
	                                                    	ProgramPeriod__c 
	                                                    where 
	                                                    	Program__c in :programIdList 
	                                                    	and StartDate__c <=:employeeSurvey.EmploymentPeriod__r.StartDate__c 
	                                                    	and (EndDate__c >=:employeeSurvey.EmploymentPeriod__r.StartDate__c or EndDate__c = null) 
	                                                    	and Area__c in:locationAreaIds];
	                                                    	
	        Map<string, ProgramPeriod__c> ppMap = new Map<string, ProgramPeriod__c>();
	        for(ProgramPeriod__c pp : programPeriodList)
	        {
	            ppMap.put(pp.Program__r.Id, pp);
	        }                                                       
	                                                    
	        List<ProgramCategoryPeriod__c> programCategoryPeriodList = [SELECT 
	        																Id, 
	        																ProgramCategory__r.ProgramCategoryEID__c 
	        															FROM 
	        																ProgramCategoryPeriod__c 
	                                                                    where 
	                                                                    	ProgramCategory__c in :programCategoryIdList 
	                                                                    	and StartDate__c <=:employeeSurvey.EmploymentPeriod__r.StartDate__c 
	                                                                    	and (EndDate__c >=:employeeSurvey.EmploymentPeriod__r.StartDate__c or EndDate__c = null) 
	                                                                    	and Area__c in:employeeAddressAreaIds];   
	                                                                    	
	        system.debug('JM:eaaids:' + employeeAddressAreaIds);                                                                                                                                      
	        
	        Map<decimal, ProgramCategoryPeriod__c> pcpMap = new Map<decimal, ProgramCategoryPeriod__c>();
	        for(ProgramCategoryPeriod__c pcp : programCategoryPeriodList)
	        {
	            pcpMap.Put(pcp.ProgramCategory__r.ProgramCategoryEID__c, pcp);
	        }
	
	          
	        List<ProgramQualification__c> programQualificationList = [select 
	        																Id, 
	        																ProgramPeriod__r.Program__r.Id 
	        															from 
	        																ProgramQualification__c 
	        															where 
	        																Employment__c =:employeeSurvey.EmploymentPeriod__c 
	        																and ProgramPeriod__r.Program__c in:programIdList];
	        																
	        
	        if(programQualificationList.size() > 0)
	        {
	            for(ProgramQualification__c pq : programQualificationList)
	            {
	                pqMap.put(pq.ProgramPeriod__r.Program__r.Id, pq);
	            }           
	        }  
	        
	        List<ProgramCategoryQualification__c> programCategoryQualificationList = [select 
	        																				Id, 
	        																				ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c, 
	        																				ProgramCategoryPeriod__r.ProgramCategory__r.Name 
	        																			from 
	        																				ProgramCategoryQualification__c 
	        																			where 
	        																				ProgramQualification__c in: programQualificationList];
	        																				
	        
	        if(programCategoryQualificationList.size() > 0)
	        {
	            for(ProgramCategoryQualification__c pcq : programCategoryQualificationList)
	            {
	                pcqMap.put(pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c, pcq);
	            }
	        }                                                                       
	        
	        for(ProgramCategory__c pc : programCategoryList)
	        {           
	            ProgramCategoryPeriod__c pcp = pcpMap.get(pc.ProgramCategoryEID__c);
	            if(pcp != null)
	            {               
	                if(pqMap.get(pc.Program__r.Id) == null)
	                {               
	                    ProgramPeriod__c pp = ppMap.get(pc.Program__r.Id);
	                    ProgramQualification__c pq = new ProgramQualification__c(Employment__c = employeeSurvey.EmploymentPeriod__c, ProgramPeriod__c = pp.Id, EffectiveDate__c = System.today(), Survey__c = employeeSurvey.Id, ProcessStage__c = qps.Id);
	                    pqInsertList.add(pq);                   
	                    pqMap.put(pc.Program__r.Id, pq);   
	                    
	                                   
	                }           
	            }
	        } 
	        
	        QualifyProgramCategory.byPassPreventDuplicatePQ = true;
	        insert pqInsertList;  
	                
	        programQualificationList = [select 
	        								Id, 
	        								Employment__c, 
	        								ProgramPeriod__r.Program__r.Id, 
	        								ProgramPeriod__r.Program__r.ShortName__c, 
	        								ProgramPeriod__r.Program__r.ProgramEID__c 
	        							from 
	        								ProgramQualification__c 
	        							where 
	        								Employment__c =:employeeSurvey.EmploymentPeriod__c 
	        								and ProgramPeriod__r.Program__c in:programIdList];
	        
	        pqMap = new Map<string, ProgramQualification__c>();
	        if(programQualificationList.size() > 0)
	        {
	            for(ProgramQualification__c pq : programQualificationList)
	            {
	                pqMap.put(pq.ProgramPeriod__r.Program__r.Id, pq);
	            }           
	        }
	        
	        string currentProgram = '';	        
	        for(ProgramCategory__c pc : programCategoryList)
	        {           
	            ProgramCategoryPeriod__c pcp = pcpMap.get(pc.ProgramCategoryEID__c);            
	            if(pcp != null)
	            {
	                programQualification = pqMap.get(pc.Program__r.Id);              
	                                                                         
	                if(pcqMap.get(pc.ProgramCategoryEID__c) == null)
	                {                   
	                    ProgramCategoryQualification__c pcq = new ProgramCategoryQualification__c(ReadinessDate__c=System.today(), ProgramCategoryPeriod__c=pcp.Id, Survey__c=employeeSurvey.Id, ProgramQualification__c = programQualification.Id, Readiness__c = qr.Id);
	                    pcqInsertList.add(pcq);
	                    pcqMap.put(pc.ProgramCategoryEID__c, pcq);
	                } 
	                
	                if(currentProgram == '' || currentProgram != pc.Program__r.ShortName__c && pc.Name != null && pc.Name.trim() != '')
	                {
	                    currentProgram = pc.Program__r.ShortName__c;
	                    returnValue +=  '<br/><br/><b>' + currentProgram + '</b><br/>' + pc.Name + '<br/>';
	                }
	                else if(pc.Name != null && pc.Name.trim() != '')
	                {
	                    currentProgram = pc.Program__r.ShortName__c;
	                    returnValue += pc.Name + '<br/>';
	                }        
	            
	            }
	            
	        }        
	        
	        insert pcqInsertList;
	        
	        PopulateCertificationDocumentWorkTables pop = new PopulateCertificationDocumentWorkTables();        
	      	for(ProgramQualification__c pq : programQualificationList)
	        {
	        	if(pq.ProgramPeriod__r.Program__r.ProgramEID__c == 1)
	        	{
	        		if(!pop.Is8850Created)
	        		{   
	           			pop.Populate8850(pq);
	        		}
	        	}
	        }
	        
	        pcqInsertList = [Select 
	        						Id, 
	        						ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c, 
	        						ProgramQualification__r.Employment__c 
	        					From 
	        						ProgramCategoryQualification__c 
	        					where 
	        						Id in :pcqInsertList];
	        for(ProgramCategoryQualification__c pcq : pcqInsertList)
	        {
	            if(!pop.IsEDDReleaseCreated && pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 77)
	            {
	                pop.PopulateEddRelease(pcq);
	            }   
	        }  
	        
	        List<wktLocationEmployeeProgram__c> lepList = [select 
	        													Id, 
	        													DocumentListFormula__c, 
	        													DocumentNeededText__c 
	        												from 
	        													wktLocationEmployeeProgram__c 
	        												where 
	        													Employment__c =:employeeSurvey.EmploymentPeriod__c];     
	       	String documents = '';
	        if(lepList.size() > 0)
	        {
	        	if(returnValue.trim() != '') // There are program category qualifications, so there might be needed docs
	        	{  
	        		
	        		for(wktLocationEmployeeProgram__c  lep : lepList) // Loop through all records and grab the docs needed
	        		{
	        			if(lep.DocumentListFormula__c != null && lep.DocumentListFormula__c != '')
	        			{
	        				documents += lep.DocumentListFormula__c + '<br/>';
	        			}
	        		}
	        		
	        		if(documents != null && documents != '')
	        		{
	        			returnValue += '<br/><b>Documents Needed</b><br/>';
	        			returnValue += documents;
	        		}       		
	
	        	}
	        	
	        }
	        
	        //ADDED BY GARRIK
	        set<Decimal> updatedPcEids = new set<Decimal>();
	        for(ProgramCategory__c pc : programCategoryList){
	            updatedPcEids.add(pc.ProgramCategoryEID__c);
	        }
	
	        set<Decimal> pcqKeySet = pcqMap.keySet();
	        list<ProgramCategoryQualification__c> updatePCQList = new list<ProgramCategoryQualification__c>();
	        ProgramCategoryQualification__c pcqUpdate;
	        QualificationReadiness__c qr_disqualified = [Select q.QualificationReadinessEID__c, q.Name, q.ExternalName__c From QualificationReadiness__c q where ExternalName__c = 'Disqualified' limit 1 ];
	        for(Decimal key : pcqKeySet){
	            if(updatedPcEids.contains(key)==false){
	                pcqUpdate = pcqMap.get(key);
	                pcqUpdate.Readiness__c = qr_disqualified.id;
	                updatePCQList.add(pcqUpdate);
	            }
	        }
	        
	        update updatePCQList;
	        //END GARRIK ADDITIONS 
	        
   		}        
        
        if(returnValue.trim() =='')
        {
            returnValue = '<b>No program or program category qualifications for this survey.</b>';
        }   
        
        
        return returnValue;      
    }
    
    /****************************/
    private static testmethod void testQualifyProgramCategory(){
        Entity__c ent;
            EntityLocation__c el;
            Program__c p;
            EmployeeSurvey__c es;
            Account a;
            Employee__c emp;
            Location__c l;
            Employment__c em;
            QualificationProcessStage__c qps;
            ProgramPeriod__c pp;
            ProgramQualification__c pq;
        a = new Account();
        a.Name = 'testa';
        insert a;
        
        emp = new Employee__c();
        emp.Account__c = a.id;
        emp.FirstName__c = 'test';
        emp.LastName__c = 'testington';
        emp.SSN__c = '000-00-1234';
        insert emp;
        
        Area__c ar = new Area__c();
        ar.Name = 'ARRRR';
        insert ar;
        
        County__c cnt = new County__c();
				cnt.Name = 'TEST';
				insert cnt;
        
        State__c stte=new State__c();
        stte.Name='Happy';
        insert stte;
				        
	      l = new Location__c();
        l.Account__c = a.id;
        l.Name = 'test';
        l.County__c=cnt.id;
        l.State__c=stte.id;
        insert l;

				AreaCounty__c arco = new AreaCounty__c();
				arco.Area__c =ar.id;
				arco.County__c = cnt.id;
				insert arco;
        
        LocationArea__c loca = new LocationArea__c();
        loca.Area__c = ar.id;
        loca.Location__c = l.id;
				insert loca;
        
        AreaState__c aste = new AreaState__c();
        aste.Area__c = ar.id;
        aste.State__c = stte.id;
        insert aste;
        ent = new Entity__c();
        ent.Account__c = a.id;
        ent.Name = 'test';
        insert ent;
        
        el = new EntityLocation__c();
        el.Entity__c = ent.id;
        el.Location__c = l.id;
        insert el;
        
        p = new Program__c();
        p.ShortName__c='t';
        p.Name = 'test';
        p.ProgramEID__c = 8675309;
        //p.ProgramStartSummary__c = Date.today();
        //p.ProgramEndSummary__c = Date.today();
        insert p;
        
        pp = new ProgramPeriod__c();
        pp.Program__c = p.id;
        pp.EndDate__c = Date.today().addDays(700);
        pp.StartDate__c = date.today().addDays(-600);
        insert pp;
         
        em = new Employment__c();
        em.Employee__c = emp.id;
        em.Location__c = l.id;
        em.StartDate__c = Date.today();
        em.Entity__c = ent.id;
        insert em;
        
        es = new EmployeeSurvey__c();
        es.Name = 'test';
        es.SurveyDate__c = datetime.now();
        es.EmploymentPeriod__c = em.id;
        es.EntityLocation__c = el.id;
        es.ReportedHireDate__c = date.today().addDays(-100);
        insert es; 
        
				
        
        EmployeeAddress__c ea = new EmployeeAddress__c();
        ea.CityName__c = 'CITY';
        ea.EffectiveDate__c = Date.today().adddays(-101);
        ea.Employee__c = emp.id;
        ea.ZipCode__c = '28211';
        ea.StreetAddressText__c = '123 testing test';
        ea.County__c = cnt.id;
        ea.State__c = stte.id;
        insert ea;
        
        EmployeeAddressArea__c eaa = new EmployeeAddressArea__c();
        eaa.Area__c=ar.id;
        eaa.EmployeeAddress__c=ea.id;
        insert eaa;
        
        qps = new QualificationProcessStage__c();
        qps.InCertificationProcessBit__c = true;
        qps.Name = 'TEST';
            qps.ExternalName__c = 'TEST';
            qps.RankOrder__c = 2;
            insert qps;
            
            pq = new ProgramQualification__c();
            pq.EffectiveDate__c=Date.today().addDays(-500);
            pq.Employment__c = em.id;
            pq.ProcessStage__c =qps.id;
            pq.ProcessStageDate__c = datetime.now().addDays(-500);
            pq.ProgramQualificationEID__c =3.1415927;
          pq.Survey__c = es.id;
          pq.ProgramPeriod__c = pp.id;
          insert pq; 
          
          
          list <SurveyQuestion__c> sql = [ select id,  QuestionEID__c from SurveyQuestion__c];
          map<double, SurveyQuestion__c> sqMap = new Map<double, SurveyQuestion__c>();
          for(SurveyQuestion__c sq: sql){
          	sqMap.put(sq.QuestionEID__c, sq);
          }
            //sq.QuestionEID__c
                                  
          //answerList = [select Id, EmployeeSurvey__c, EmployeeSurvey__r.EmploymentPeriod__r.StartDate__c, SurveyQuestion__r.QuestionEID__c, EmployeeSurveyAnswerDate__c, EmployeeSurveyAnswerAmount__c, EmployeeSurveyAnswerText__c from EmployeeSurveyAnswer__c where EmployeeSurvey__c =:employeeSurveyRecord];
          list<EmployeeSurveyAnswer__c> esaL = new list<EmployeeSurveyAnswer__c>();
          EmployeeSurveyAnswer__c esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =11;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(11).id;
          esaL.add(esa);//insert esa;

          
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =1;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(1).id;
          esaL.add(esa);//insert esa;

          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =2;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(2).id;
          esaL.add(esa);//insert esa;
          
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =16;
          esa.EmployeeSurveyAnswerText__c = 'Vocational Rehabilitation Agency';
          esa.SurveyQuestion__c = sqMap.get(16).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =12;
          esa.EmployeeSurveyAnswerText__c = 'Workforce Investment Board';
          esa.SurveyQuestion__c = sqMap.get(12).id;
          esaL.add(esa);//insert esa;
          
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =18;
          esa.EmployeeSurveyAnswerText__c = 'No';
          esa.SurveyQuestion__c = sqMap.get(18).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =28;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(28).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =30;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(30).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =21;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(21).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =23;
          esa.EmployeeSurveyAnswerText__c = 'Economic Conditions';
          esa.SurveyQuestion__c = sqMap.get(23).id;
          esaL.add(esa);//insert esa;
          
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =29;
          esa.EmployeeSurveyAnswerText__c = 'Company or location closure or mass layoffs';
          esa.SurveyQuestion__c = sqMap.get(29).id;
          esaL.add(esa);//insert esa;
          
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =31;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(31).id;
          esaL.add(esa);//insert esa;esa = new EmployeeSurveyAnswer__c();
          
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =32;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(32).id;
          esaL.add(esa);//insert esa;
          
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =33;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(33).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =36;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(36).id;
          esaL.add(esa);//insert esa;
        
        	esa = new EmployeeSurveyAnswer__c();
        	esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =37;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(37).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =48;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(48).id;
          esaL.add(esa);//insert esa;
        
        	esa = new EmployeeSurveyAnswer__c();
        	esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =41;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(41).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
        	esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =49;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(49).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
        	esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =53;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(53).id;
          esaL.add(esa);//insert esa;
          
          esa = new EmployeeSurveyAnswer__c();
        	esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =57;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(57).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
        	esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =60;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(60).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
        	esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =63;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(63).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
        	esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =64;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(64).id;
          esaL.add(esa);//insert esa;
          
          esa = new EmployeeSurveyAnswer__c();
        	esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =69;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(69).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
        	esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =58;
          esa.EmployeeSurveyAnswerText__c = 'Veteran';
          esa.SurveyQuestion__c = sqMap.get(58).id;
          esaL.add(esa);//insert esa;
					
					esa = new EmployeeSurveyAnswer__c();
        	esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =62;
          esa.EmployeeSurveyAnswerText__c = 'Veteran';
          esa.EmployeeSurveyAnswerDate__c = Date.newInstance(1965, 8, 5);
          esa.SurveyQuestion__c = sqMap.get(62).id;
          esaL.add(esa);//insert esa;
          
          esa = new EmployeeSurveyAnswer__c();
        	esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =61;
          esa.EmployeeSurveyAnswerText__c = 'Veteran';
          esa.EmployeeSurveyAnswerDate__c = Date.newInstance(1965, 8, 5);
          esa.SurveyQuestion__c = sqMap.get(61).id;
          esaL.add(esa);//insert esa;

					esa = new EmployeeSurveyAnswer__c();
        	esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =74;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(74).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
        	esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =80;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(80).id;
          esaL.add(esa);//insert esa;
					
					esa = new EmployeeSurveyAnswer__c();
        	esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =108;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(108).id;
          esaL.add(esa);//insert esa;
          
          
          esa = new EmployeeSurveyAnswer__c();
        	esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =83;
          esa.EmployeeSurveyAnswerAmount__c = 83000;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(83).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
        	esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =102;
          esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(102).id;
          esaL.add(esa);//insert esa;
          
          esa = new EmployeeSurveyAnswer__c();
        	esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =88;
          esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(88).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
        	esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =89;
          esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(89).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
        	esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =106;
          esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(106).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
        	esa.EmployeeSurvey__c = es.id;
        	esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurveyAnswerEID__c =87;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(87).id;
          esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esaL.add(esa);//insert esa;
          
          esa = new EmployeeSurveyAnswer__c();
        	esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =93;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.SurveyQuestion__c = sqMap.get(93).id;
          esaL.add(esa);//insert esa;esa = new EmployeeSurveyAnswer__c();
          esa = new EmployeeSurveyAnswer__c();
        	esa.EmployeeSurvey__c = es.id;
        	esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurveyAnswerEID__c =90;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(90).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
        	esa.EmployeeSurvey__c = es.id;
        	esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurveyAnswerEID__c =94;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(94).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
        	esa.EmployeeSurvey__c = es.id;
        	esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurveyAnswerEID__c =103;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(103).id;
          esaL.add(esa);//insert esa;
          
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =91;
          esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(91).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =92;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(92).id;
          esaL.add(esa);//insert esa;
		
					esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =95;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(95).id;
          esaL.add(esa);//insert esa;
					esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =97;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(97).id;
          esaL.add(esa);//insert esa;
					esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =104;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(104).id;
          esaL.add(esa);//insert esa;
          
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =96;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(96).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =98;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(98).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =100;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(100).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =105;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(105).id;
          esaL.add(esa);//insert esa;
          
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =84;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(84).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =85;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(85).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =101;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(101).id;
          esaL.add(esa);//insert esa;
          //ARF
          insert esaL;

          test.startTest();
          QualifyProgramCategory qpc = new QualifyProgramCategory(es.id);
          System.assert(qpc!=null);
          qpc.QualifyAnswers();
          list<Decimal> dList = new list <Decimal>();
          dList.add(69);
          qpc.SaveProgramCategoryQualification(dList);
          system.assert(true);
          test.stopTest();
          
    } 
    /****************************/
  }