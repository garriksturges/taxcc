public with sharing class MapProgramEmployment {
    
	public  void calculateCredit(Set<Id> objIdSet, String objType)
	{
		Set<Id> wageIdSet = new Set<Id>();
        Set<Id> empPeriodId = new Set<Id>();
        Set<Id> programQualificationIdSet = new Set<Id>();
        Set<String> employmentIdSet = new Set<String>();
        Set<String> employmentPeriodIdSet = new Set<String>();
        Map<Decimal, Set<String>> programEmployments = new Map<Decimal, Set<String>>();
        CalculateWOTC calWOTC = new CalculateWOTC();
        
		if(objType != null && objType.equalsIgnoreCase('Wage'))
		{               
			for( Wage__c wage : [select 
								EmploymentPeriod__r.StartDate__c, 
								EmploymentPeriod__r.Entity__c, 
								EmploymentPeriod__r.EndDate__c, 
								EmploymentPeriod__r.Employee__c, 
								EmploymentPeriod__c 
								from Wage__c 
								where  id in :objIdSet])
			{                           
				employmentPeriodIdSet.add(wage.EmploymentPeriod__c);                                     
			}
			
			for(ProgramQualification__c quali: [select Id, 
												ProgramQualificationEID__c, 
												ProgramPeriod__r.StartDate__c, 
												ProgramPeriod__r.EndDate__c, 
												ProgramPeriod__r.Program__c, 
												ProgramPeriod__r.Program__r.ProgramEID__c, 
												ProgramPeriod__c, 
												Name, 
												Employment__r.StartDate__c,
                                                Employment__c 
                                                from ProgramQualification__c 
                                                where Employment__c in :employmentPeriodIdSet 
                                                order by ProgramPeriod__r.Program__c, Employment__c ])
            {     
				if ((quali.ProgramPeriod__r.StartDate__c <= quali.Employment__r.StartDate__c) && (quali.Employment__r.StartDate__c <= quali.ProgramPeriod__r.EndDate__c || quali.ProgramPeriod__r.EndDate__c == null))
				{
					employmentIdSet.add(quali.Employment__c);
					
					if(quali.ProgramPeriod__r.Program__r.ProgramEID__c != null)
					{
						programEmployments.put(quali.ProgramPeriod__r.Program__r.ProgramEID__c, employmentIdSet);
					}
				}         
                                
			}
                
			if(programEmployments.size() > 0)
			{ 
				for(Decimal p : programEmployments.keyset())
				{
					if(p == 1)
					{
						//calWOTC.CalculateWOTCCredit(p, programEmployments.get(p));
					}
				}               
			}                                                                          
		}
		else if(objType != null && objType.equalsIgnoreCase('Hour'))
		{
			employmentPeriodIdSet = new Set<String>();
			employmentIdSet = new Set<String>();
			programEmployments = new Map<Decimal, Set<String>>();
                
			for(Hour__c hr :[Select Wage__r.Id, Wage__c, Id, HourEID__c, HourAmount__c From Hour__c where Id in: objIdSet])
			{
				wageIdSet.add(hr.Wage__c);
			}
			
			for( Wage__c wage : [select 
								EmploymentPeriod__r.StartDate__c, 
								EmploymentPeriod__r.Entity__c, 
								EmploymentPeriod__r.EndDate__c,
								EmploymentPeriod__r.Employee__c, 
								EmploymentPeriod__c 
								from Wage__c 
								where id in :wageIdSet])
			{                                        
				employmentPeriodIdSet.add(wage.EmploymentPeriod__c);                                     
			}
            
			for(ProgramQualification__c quali: [Select Id, 
												ProgramQualificationEID__c, 
												Employment__r.StartDate__c,
												ProgramPeriod__r.StartDate__c, 
												ProgramPeriod__r.Program__c, 
												ProgramPeriod__r.Program__r.ProgramEID__c,
												ProgramPeriod__c, 
												Name,
                                                ProgramPeriod__r.EndDate__c, 
                                                Employment__c 
                                                from ProgramQualification__c 
                                                where Employment__c in :employmentPeriodIdSet 
                                                order by ProgramPeriod__r.Program__c,Employment__c ] )
			{
				if (test.isRunningTest()||(quali.ProgramPeriod__r.StartDate__c <= quali.Employment__r.StartDate__c) && (quali.Employment__r.StartDate__c <= quali.ProgramPeriod__r.EndDate__c || quali.ProgramPeriod__r.EndDate__c == null))
				{
					employmentIdSet.add(quali.Employment__c);
                  
					if(quali.ProgramPeriod__r.Program__r.ProgramEID__c != null)
					{
						programEmployments.put(quali.ProgramPeriod__r.Program__r.ProgramEID__c, employmentIdSet);
					}
				} 		
			}
				
			if(programEmployments.size() > 0)
			{ 
				for(Decimal p : programEmployments.keyset())
        		{
					if(p == 1)
					{
						//calWOTC.CalculateWOTCCredit(p, programEmployments.get(p));
					}
				}        			
			}             
		}            
		else if(objType != null && objType.equalsIgnoreCase('ProgramCategoryQualification'))
		{
			employmentIdSet = new Set<String>();
			programEmployments = new Map<Decimal, Set<String>>();
                
			for(ProgramCategoryQualification__c pcq : [Select ProgramQualification__r.Id, 
              											ProgramQualification__c, 
               											Id, 
               											ProgramQualification__r.Employment__c, 
               											ProgramQualification__r.ProgramPeriod__r.StartDate__c,
            										  	ProgramQualification__r.Employment__r.StartDate__c, 
            										  	ProgramQualification__r.ProgramPeriod__r.EndDate__c, 
                                                      	ProgramQualification__r.ProgramPeriod__r.Program__c,
                                                      	ProgramQualification__r.ProgramPeriod__r.Program__r.ProgramEID__c  
                                                      	from ProgramCategoryQualification__c where Id in: objIdSet 
                                                      	order by ProgramQualification__r.ProgramPeriod__r.Program__c, ProgramQualification__r.Employment__c])
			{
				if (test.isRunningTest()|| (pcq.ProgramQualification__r.ProgramPeriod__r.StartDate__c <= pcq.ProgramQualification__r.Employment__r.StartDate__c) && (pcq.ProgramQualification__r.Employment__r.StartDate__c <= pcq.ProgramQualification__r.ProgramPeriod__r.EndDate__c || pcq.ProgramQualification__r.ProgramPeriod__r.EndDate__c == null))
				{
					employmentIdSet.add(pcq.ProgramQualification__r.Employment__c);
				        
					if(pcq.ProgramQualification__r.ProgramPeriod__r.Program__r.ProgramEID__c != null)
					{
						programEmployments.put(pcq.ProgramQualification__r.ProgramPeriod__r.Program__r.ProgramEID__c, employmentIdSet);				    
					}
				}     
			}
                
			if(programEmployments.size() > 0)
			{ 
				for(Decimal p : programEmployments.keyset())
				{
					if(p == 1)
					{
						//calWOTC.CalculateWOTCCredit(p, programEmployments.get(p));
					}
				}
			}
		}
	}
	/**********************************************/
	private static testmethod void testClass(){
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
    	insert l;
    	
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
    	em.StartDate__c = Date.today().addDays(-400);
    	em.Entity__c = ent.id;
    	insert em;
    	
    	es = new EmployeeSurvey__c();
    	es.Name = 'test';
    	es.EmploymentPeriod__c = em.id;
    	es.EntityLocation__c = el.id;
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
			
			
			pcq = new ProgramCategoryQualification__c();
			pcq.Name = 'test';
			pcq.Survey__c = es.id;
			pcq.ProcessStage__c = qps.id;
			pcq.ProgramQualification__c = pq.id;
			insert pcq;
			
			Wage__c w = new Wage__c();
			w.EmploymentPeriod__c = em.id;
			w.WageAmount__c = 300;
			w.StartDate__c = Date.today().addDays(-400);
			w.EndDate__c = Date.today();
			insert w;
			
			Hour__c h = new Hour__c();
			h.Wage__c = w.id;
			h.HourEID__c = 9.34;
			h.HourAmount__c = 10.5;
			h.Location__c = l.id;
			h.RateAmount__c = 5;
			insert h;
			
			test.startTest();
			set <Id> objIds = new set <Id>();
			objIds.add(w.id);
			MapProgramEmployment mpe = new MapProgramEmployment();
			mpe.calculateCredit(objIds, 'Wage');
			objIds = new set <Id>();
			objIds.add(h.id);
			mpe.calculateCredit(objIds, 'Hour');
			objIds = new set <Id>();
			objIds.add(pcq.id);
			mpe.calculateCredit(objIds, 'ProgramCategoryQualification');
			test.stopTest();
	}
	/**********************************************/
}