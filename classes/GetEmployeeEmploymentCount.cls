global class GetEmployeeEmploymentCount implements Process.Plugin{

    global Process.PluginResult invoke(Process.PluginRequest request){
    
        
        String employeeRecord = (String)request.inputParameters.get('EmployeeRecord');
        String entityRecord = (String)request.inputParameters.get('EntityRecord');        
        String employmentReferenceNumber = '';
        Integer employmentCount = 0;
        String employmentSFID = '';
        
       	employmentCount = [select count() from Employment__c where Entity__c =:entityRecord and Employee__c =:employeeRecord]; 
       	
       	if(employmentCount > 0)
       	{
       		// Look for one with a survey project
       		Employment__c[] employment = [select Id, ReferenceID__c from Employment__c where Entity__c =:entityRecord and Employee__c =:employeeRecord and SurveyProject__c != null order by StartDate__c desc];
			if(employment.size() > 0)
			{				
       			employmentReferenceNumber = employment[0].ReferenceID__c;
       			employmentSFID = employment[0].Id;
			}
			else
			{
				// Look for one without survey project
				employment = [select Id, ReferenceID__c from Employment__c where Entity__c =:entityRecord and Employee__c =:employeeRecord order by StartDate__c desc];				
				if(employment.size() > 0)
				{					
       				employmentReferenceNumber = employment[0].ReferenceID__c;
       				employmentSFID = employment[0].Id;					
				}
			}       		
       	}
       	   
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('EmploymentCount', employmentCount);
        result.put('EmploymentReferenceNumber', employmentReferenceNumber);
        result.put('EmploymentSFID', employmentSFID);
        
        return new Process.PluginResult(result);    
    }
    
    global Process.PluginDescribeResult describe(){
        
        Process.PluginDescribeResult  result = new Process.PluginDescribeResult();
        
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter('EmployeeRecord', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('EntityRecord', Process.PluginDescribeResult.ParameterType.STRING, true)
        };
        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>{
            new Process.PluginDescribeResult.OutputParameter('EmploymentCount', Process.PluginDescribeResult.ParameterType.INTEGER),
            new Process.PluginDescribeResult.OutputParameter('EmploymentReferenceNumber', Process.PluginDescribeResult.ParameterType.STRING),
            new Process.PluginDescribeResult.OutputParameter('EmploymentSFID', Process.PluginDescribeResult.ParameterType.STRING)
        };
        
        return result;
            
    }
    

    
    public static testMethod void GetEmployeeEmploymentCount_TEST(){
        	SurveyProgramScreened__c sps;
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
			 ProgramCategory__c pc;
			 DocumentRequirement__c dr;
			 DocumentInstruction__c di;
			 DocumentStep__c ds;
			 DocumentOption__c doco;
			 DocumentSource__c dsource;
			 Documenttype__c dt;
			 ProgramCategoryPeriod__c pcp;
			 ProgramCategoryQualification__c pcq;
				a = new Account();
	    	a.Name = 'testa';
	    	insert a;
	    	
	    	emp = new Employee__c();
	    	emp.Account__c = a.id;
	    	emp.FirstName__c = 'test';
	    	emp.LastName__c = 'testington';
	    	emp.SSN__c = '000-00-1234';
	    	
	    	insert emp;
	    	
	      l = new Location__c();
	    	l.Account__c = a.id;
	    	l.Name = 'test';
	    	
	    	ent = new Entity__c();
	    	ent.Account__c = a.id;
	    	ent.Name = 'test';
	    	insert ent;
	    	
	    	el = new EntityLocation__c();
	    	el.Entity__c = ent.id;
	    	el.Location__c = l.id;
	    	
	    	p = new Program__c();
	    	p.ShortName__c='t';
	    	p.Name = 'test';
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
	    	es.EmploymentPeriod__c = em.id;
	    	es.EntityLocation__c = el.id;
	    	es.SurveyDate__c = datetime.now();
	    	es.ReportedHireDate__c = date.today().addDays(-100);
	    	insert es; 
	    	
	    	sps = new SurveyProgramScreened__c();
	      sps.Survey__c = es.id;
	      sps.Program__c = p.id;
	      insert sps;
	    	
	    	qps = new QualificationProcessStage__c();
	    	qps.InCertificationProcessBit__c = true;
	    	qps.Name = 'TEST';
				qps.ExternalName__c = 'TEST';
				qps.RankOrder__c = 2;
				qps.QualificationProcessStageEID__c =8.8;
				insert qps;
			
				pq = new ProgramQualification__c();
				pq.Employment__c = em.id;
				pq.ProcessStage__c = qps.id;
				pq.ProcessStageDate__c = Datetime.now().addDays(-100);
				pq.ProgramPeriod__c = pp.id;
				pq.ProgramQualificationEID__c = 123123.23;
				pq.Survey__c =  es.id;
				insert pq;
				
				pc = new ProgramCategory__c();
				pc.Name = 'testpc';
				pc.ProgramCategoryDescriptionText__c='testing stuff';
				pc.ProgramCategoryCode__c = 'yellow';
				pc.RankOrder__c = 2.0;
				pc.Program__c = p.id;
				insert pc;
			
				dr = new DocumentRequirement__c();
				dr.Name = 'test';
				dr.SortOrder__c = 1;
				dr.Program__c = p.id;
				dr.ProgramCategory__c = pc.id;
				insert dr;		
				
				di = new DocumentInstruction__c();
				di.Audience__c = 'Employee';
				di.Language__c = 'English';
				di.InstructionSummaryText__c = 'some text';
				di.DocumentRequirement__c = dr.id;
				insert di;	
				
				ds = new DocumentStep__c();

				ds.Name = 'test';
				ds.QualificationProcessStage__c = qps.id;
				ds.StepOrder__c = 1.0;
				ds.DocumentRequirement__c = dr.id;
				insert ds;
	
				dSource = new DocumentSource__c();
				dsource.DocumentSourceEID__c = 1.0;
				dSource.Name = 'test';
				insert dSource;
				
				dt = new Documenttype__c();
				dt.DescriptionText__c ='test';
				dt.DocumentationStage__c = 'test';
				dt.DocumentSource__c = dsource.id;
				dt.DocumentTypeAbbr__c ='t';
				dt.Name = 'test';
				dt.SortOrder__c = 1;
				dt.Usage__c = 'test';
				insert dt;
				
				doco = new DocumentOption__c();
				doco.DocumentStep__c = ds.id;
				doco.DocumentType__c = dt.id;
				insert doco;
				
				QualificationReadiness__c qr = new QualificationReadiness__c();
				qr.QualificationReadinessEID__c = 2.2;
				qr.RankOrder__c = 3.1415667;
				insert qr;
				
				QualificationReadiness__c qr2 = new QualificationReadiness__c();
				qr2.QualificationReadinessEID__c = 3.12333;
				qr2.RankOrder__c = 3.1415667;
				qr2.ExternalName__c = 'Disqualified';
				insert qr2;

				QualificationProcessStage__c qps2 = new QualificationProcessStage__c();
				qps2.InCertificationProcessBit__c = true;
	    	qps2.Name = 'TEST';
				qps2.ExternalName__c = 'TEST';
				qps2.QualificationProcessStageEID__c = 22.3445;
				qps2.RankOrder__c = 3.142343242;
				insert qps2;
				
				pcq = new ProgramCategoryQualification__c();
				pcq.Name = 'test';
				pcq.Survey__c = es.id;
				pcq.ProcessStage__c = qps.id;
				pcq.ProgramQualification__c = pq.id;
				insert pcq;
				
				SurveyQuestion__c sq = new SurveyQuestion__c();
				sq.QuestionEID__c = 5.3;
				insert sq;
           
                                  
          //answerList = [select Id, EmployeeSurvey__c, EmployeeSurvey__r.EmploymentPeriod__r.StartDate__c, SurveyQuestion__r.QuestionEID__c, EmployeeSurveyAnswerDate__c, EmployeeSurveyAnswerAmount__c, EmployeeSurveyAnswerText__c from EmployeeSurveyAnswer__c where EmployeeSurvey__c =:employeeSurveyRecord];
          EmployeeSurveyAnswer__c esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =16;
          esa.EmployeeSurveyAnswerText__c = 'No';
          esa.SurveyQuestion__c = sq.id;
          insert esa;
          
				EmployeeAddress__c ea = new EmployeeAddress__c();
        ea.CityName__c = 'CITY';
        ea.EffectiveDate__c = Date.today().adddays(-101);
        ea.Employee__c = emp.id;
        ea.ZipCode__c = '28211';
        ea.StreetAddressText__c = '123 testing test';
        insert ea;
        
        test.startTest();
        GetEmployeeEmploymentCount plugin = new GetEmployeeEmploymentCount();
        Map<String,Object> inputParams = new Map<String,Object>();

        InputParams.put('EmployeeRecord', emp.id);
        InputParams.put('EntityRecord', ent.id);

        Process.PluginRequest request = new Process.PluginRequest(inputParams);           
        
        plugin.invoke(request);
        plugin.describe();
        test.stopTest();
    }
    
    
}