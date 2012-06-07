global class PopulateCertificationDocumentWorkTables
{
    public Boolean Is8850Created {get; set;}
    public Boolean IsEDDReleaseCreated {get; set;}
    
    
    Set<Id> pqIds = new Set<Id>();
    Set<Id> pcqIds = new Set<Id>();
    Set<Id> qcsIds = new Set<Id>();
    Set<Id> qualRoleStepIds = new Set<Id>();
    Set<Id> qualDocStepIds = new Set<Id>();

    wktDocument8850__c wktdoc8850;
    wktDocumentEDDRelease__c wktdocEDD;
    boolean chkDate =  false;
    
    
    public PopulateCertificationDocumentWorkTables()
    {
        Is8850Created = false;
        IsEDDReleaseCreated = false;
    }
    
    global void Populate8850(ProgramQualification__c programQualification)
    {   
        
        boolean isVetSnap = false;
        boolean isSnap = false;
        boolean isVetUnemployed = false;
        boolean isVetDisabled = false;
        boolean isVetRecent = false;
        boolean isTanf = false;
        boolean isSSI = false;
        boolean isVet = false;
        boolean isReferral = false;
     
        ProgramQualification__c pq = [select Id, Employment__c, Employment__r.Employee__c, Employment__r.Employee__r.Name, Employment__r.Entity__c, Employment__r.Employee__r.BirthDate__c, Employment__r.StartDate__c, Employment__r.JobTitleName__c, Employment__r.InitialHourlyRateAmount__c, Survey__c, Survey__r.EntityLocation__r.Location__c  From ProgramQualification__c p where Id =: programQualification.Id];   
        EmployeeAddress__c[] empaddr = [select Id from EmployeeAddress__c where Employee__c =: pq.Employment__r.Employee__c order by EffectiveDate__c desc];


        wktdoc8850 = new wktDocument8850__c();
        wktdoc8850.Employment__c = pq.Employment__c;
        wktdoc8850.EmployeeSurvey__c = pq.Survey__c;
        wktdoc8850.Employee__c = pq.Employment__r.Employee__c;
        
        string entStructureId = null;
        
        // Set Emp Address Record
        if(empaddr.size()>0)
        {
            wktdoc8850.EmployeeAddress__c = empaddr[0].Id;
        }        
        
             EntityStructure__c[] entStructure = [select Id from EntityStructure__c where EntityName__c =: pq.Employment__r.Entity__c];
        if(entStructure.size() > 0)
        {
            wktdoc8850.EntityStructure__c = entStructure[0].Id;
        }
                
        List<EmployeeSurveyAnswer__c> empSurveyAnswerList = [select Id, SurveyQuestion__r.QuestionEID__c, EmployeeSurveyAnswerText__c, EmployeeSurveyAnswerDate__c, EmployeeSurveyAnswerAmount__c from EmployeeSurveyAnswer__c where EmployeeSurvey__c =: pq.Survey__c];
        Map<decimal, EmployeeSurveyAnswer__c> answerMap = new Map<decimal,EmployeeSurveyAnswer__c>();
        if(empSurveyAnswerList.size() > 0)
        {
            for(EmployeeSurveyAnswer__c ans : empSurveyAnswerList)
            {
                answerMap.put(ans.SurveyQuestion__r.QuestionEID__c, ans);       
            }
        }
        
        // Set Location
        wktdoc8850.Location__c = pq.Survey__r.EntityLocation__r.Location__c;
        

        Date hireDate = pq.Employment__r.StartDate__c;
        Date birthDate = pq.Employment__r.Employee__r.BirthDate__c;

        // Days between Hire date and Birthday Over 16 under 40
       
        if(birthDate.daysBetween(hireDate) < 14600 
        && birthDate.daysBetween(hireDate) > 5840)
        {
            wktdoc8850.Over16Under40Bit__c = true;
        }
       
        
        // Position is null set to Staff
        if(pq.Employment__r.JobTitleName__c == null || pq.Employment__r.JobTitleName__c.trim() =='')
        {
            wktdoc8850.PositionGenerated__c = 'Staff';
        }
        else
        {
            wktdoc8850.PositionGenerated__c = pq.Employment__r.JobTitleName__c;
        }
        
        // Wage is null or 0.00 set to 9.00
        if(pq.Employment__r.InitialHourlyRateAmount__c == null || pq.Employment__r.InitialHourlyRateAmount__c ==0.00)
        {
            wktdoc8850.HourlyWageAmountGenerated__c = 9.00;
        }
        else
        {
            wktdoc8850.HourlyWageAmountGenerated__c = pq.Employment__r.InitialHourlyRateAmount__c;
        } 
 
       
        for(ProgramCategoryQualification__c pcq : [Select Id, ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c,ProgramCategoryPeriod__r.ProgramCategory__r.Name, ProgramCategoryPeriod__c From ProgramCategoryQualification__c where ProgramQualification__c =: programQualification.Id])
        {                           
            if(pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 132.0)
            {
                wktdoc8850.CheckBoxOne__c = 'True'; // Conditional cert
                wktdoc8850.ResdentialTargetedGroupCategory__c = 4.0;
            }
            if((pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 64)             
            || (pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 65)
            ||(pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 67)
            || (pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 69)  
            ||(pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 71)
            ||(pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 72)
            ||(pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 134))
            {
                wktdoc8850.CheckBoxTwo__c = 'True'; // TANF, Vet SNAP, VRA, SNAP, XO, SSI, Vet Short-term Unemployed
            }  
            if(pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 135.0)
            {
                wktdoc8850.CheckBoxThree__c = 'True'; // Vet Long-term Unemployed
            }               
            if(pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 66.0)
            {
                wktdoc8850.CheckBoxFour__c = 'True'; // Vet Recent Disability
            }   
            if(pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 133.0)
            {
                wktdoc8850.CheckBoxFive__c = 'True'; // Vet Disabled/Recently Unemployed
            }
            if(pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 73.0)
            {
                wktdoc8850.CheckboxLongTermTANFYesBit__c = true; // Long-term TANF
            }
            
            // RRC
            if(pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 68)
            {
                wktdoc8850.CheckboxRRCYesBit__c = true; 
            }
            
            
            // Veteran SNAP
            if(pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 65.0)
            {
                wktdoc8850.CheckboxVeteranSNAPYesBit__c = true;
                isVet = true;
                isVetSnap = true;
                if(answerMap.get(45) != null) //Primary Recipient Name
                {
                    EmployeeSurveyAnswer__c question45 = answerMap.get(45);
                    wktdoc8850.VeteranSNAPPrimaryRecipientNameGenerated__c = question45.EmployeeSurveyAnswerText__c;
                }
                if(answerMap.get(46) != null && answerMap.get(47) != null) //City and State
                {
                    EmployeeSurveyAnswer__c question46 = answerMap.get(46);
                    EmployeeSurveyAnswer__c question47 = answerMap.get(47);
                    wktdoc8850.VeteranSNAPCityStateGenerated__c = question46.EmployeeSurveyAnswerText__c + ', ' + question47.EmployeeSurveyAnswerText__c;
                }
            }
            
            // Qualified Veteran
            if(pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 65.0
            || pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 66.0
            || pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 133.0
            || pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 134.0
            || pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 135.0)
            {
                isVet = true;
                
                if(pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 66.0
                || pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 133.0)
                {
                    isVetDisabled = true;
                    wktdoc8850.CheckboxVeteranDisabilityYesBit__c = true;
                }
                if(pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 133.0
                || pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 134.0
                || pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 135.0)
                {
                    isVetUnemployed = true;
                    wktdoc8850.CheckboxVeteranUnemployedYesBit__c = true;
                }
                if(pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 66.0) // Must be recent
                {
                    isVetRecent = true;
                    wktdoc8850.CheckboxVeteranRecentYesBit__c = true;
                }
            }
            
            if(!isVet)
            {
                wktdoc8850.CheckboxVeteranNoBit__c = true;
            }
            else
            {
                wktdoc8850.CheckboxVeteranYesBit__c = true;
            }
            
            // Qualified SNAP
            if(pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 71.0)
            {
                isSnap = true;
                
                wktdoc8850.CheckboxSNAPRecipientYesBit__c = true;
                
                if(answerMap.get(45) != null) //Primary Recipient Name
                {
                    EmployeeSurveyAnswer__c question45 = answerMap.get(45);
                    wktdoc8850.SNAPPrimaryRecipientNameGenerated__c = question45.EmployeeSurveyAnswerText__c;
                }
                if(answerMap.get(46) != null && answerMap.get(47) != null) //City and State
                {
                    EmployeeSurveyAnswer__c question46 = answerMap.get(46);
                    EmployeeSurveyAnswer__c question47 = answerMap.get(47);
                    wktdoc8850.SNAPCityStateGenerated__c = question46.EmployeeSurveyAnswerText__c + ', ' + question47.EmployeeSurveyAnswerText__c;
                }        
            }
            // Qualified Referral
            if(pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 69.0)
            {
                isReferral = true;
                
                wktdoc8850.CheckboxVRAYesBit__c = true;
                
                if(answerMap.get(16) != null) // Referral Agency
                {
                    EmployeeSurveyAnswer__c question16 = answerMap.get(16);
                    if(question16.EmployeeSurveyAnswerText__c == 'Department of Veterans Affairs')
                    {
                        wktdoc8850.CheckboxDVAYesBit__c = true;
                    }
                    else if(question16.EmployeeSurveyAnswerText__c == 'Ticket to Work Program')
                    {
                        wktdoc8850.CheckboxTTWYesBit__c = true;
                    }
                }
            }
            
            // Qualified TANF
            if(pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 64.0)
            {
                isTanf = true;              
                wktdoc8850.CheckboxTANFYesBit__c = true;
                
                if(answerMap.get(54) != null) //Primary Recipient Name
                {
                    EmployeeSurveyAnswer__c question54 = answerMap.get(54);
                    wktdoc8850.TANFPrimaryRecipientNameGenerated__c = question54.EmployeeSurveyAnswerText__c;
                }
                if(answerMap.get(55) != null && answerMap.get(56) != null) //City and State
                {
                    EmployeeSurveyAnswer__c question55 = answerMap.get(55);
                    EmployeeSurveyAnswer__c question56 = answerMap.get(56);
                    wktdoc8850.TANFCityStateGenerated__c = question55.EmployeeSurveyAnswerText__c + ', ' + question56.EmployeeSurveyAnswerText__c;
                }
            }
            
            // Qualified Long Term TANF
            if(pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 73.0)
            {
                isTanf = true;              
                wktdoc8850.CheckboxLongTermTANFYesBit__c = true;
                
                if(answerMap.get(54) != null) //Primary Recipient Name
                {
                    EmployeeSurveyAnswer__c question54 = answerMap.get(54);
                    wktdoc8850.TANFPrimaryRecipientNameGenerated__c = question54.EmployeeSurveyAnswerText__c;
                }
                if(answerMap.get(55) != null && answerMap.get(56) != null) //City and State
                {
                    EmployeeSurveyAnswer__c question55 = answerMap.get(55);
                    EmployeeSurveyAnswer__c question56 = answerMap.get(56);
                    wktdoc8850.TANFCityStateGenerated__c = question55.EmployeeSurveyAnswerText__c + ', ' + question56.EmployeeSurveyAnswerText__c;
                }
            }
            // Qualified XO
            if(pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 67.0)
            {                               
                wktdoc8850.CheckboxFelonYesBit__c = true;
                wktdoc8850.CheckboxStateConvictionYesBit__c = true;
            }
            
            // Worked for Employer Before
            if(answerMap.get(7) != null && answerMap.get(9) != null)
            {
                EmployeeSurveyAnswer__c question7 = answerMap.get(7);
                EmployeeSurveyAnswer__c question9 = answerMap.get(9);
                
                if(question7.EmployeeSurveyAnswerText__c == 'Yes')
                {
                    wktdoc8850.CheckboxWorkedEmployerBeforeYesBit__c = true;
                    wktdoc8850.LastDateOfEmploymentGenerated__c = question9.EmployeeSurveyAnswerDate__c;
                }
                else
                {
                    wktdoc8850.CheckboxWorkedEmployerBeforeNoBit__c = true;
                }
            }
            
            
             // Veteran SNAP
            if(pcq.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 72.0)
            {
                wktdoc8850.CheckboxSSIRecipientYesBit__c = true;            
            }
            
        }
        
        //wktdoc8850.CongaWorkflowTrigger__c = true;
                    
        insert wktdoc8850;       
      
      
        Is8850Created = true;               
    }
    
    global void PopulateEddRelease(ProgramCategoryQualification__c pcq)
    {
        
        wktdocEDD = new wktDocumentEDDRelease__c();
        Employment__c empnt = [select Id, (select Id, Name From wktDocumentEDDRelease__r), (select Id, Name, SurveyDate__c, ReportedHireDate__c, SurveySource__c, EmployeeSurveyEID__c From Surveys__r) from Employment__c where Id =: pcq.ProgramQualification__r.Employment__c];
                
        if(empnt.wktDocumentEDDRelease__r.size() == 0)
        { 
            Date hiredate = empnt.Surveys__r[0].ReportedHireDate__c; 
            Date enddate = Date.newInstance(hiredate.year(), 1 + hiredate.month() + math.mod(3 - math.mod(hiredate.month(), 3), 3), 1);
            
            wktdocEDD.Employment__c = empnt.Id;
            wktdocEDD.EmployeeSurvey__c = empnt.Surveys__r[0].Id;                  
            wktdocEDD.DataEndDate__c = enddate;
            wktdocEDD.DataStartDate__c = enddate.addYears(-1);
            wktdocEDD.CongaWorkflowTrigger__c = true;
                        
            insert wktdocEDD;  
                        
            IsEDDReleaseCreated = true;
        }
        

        IsEDDReleaseCreated = true;
    }

}