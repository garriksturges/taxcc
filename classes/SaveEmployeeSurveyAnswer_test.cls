public with sharing class SaveEmployeeSurveyAnswer_test {
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
            
     public void makeData(){
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
    }
    static testMethod void myUnitTest() {
    		SaveEmployeeSurveyAnswer_test t = new SaveEmployeeSurveyAnswer_test();
    		t.makeData();
    		
        SaveEmployeeSurveyAnswer plugin = new SaveEmployeeSurveyAnswer();
        Map<String,Object> inputParams = new Map<String,Object>();
    		
    		//String employeeSurveyId = (String)request.inputParameters.get('EmployeeSurveyId');  
        inputParams.put('EmployeeSurveyId', t.es.id);
        
        //Decimal surveyQuestionEid = Decimal.valueOf((String)request.inputParameters.get('SurveyQuestionEID'));  
        inputParams.put('SurveyQuestionEID', '11');
        
        //String textAnswer = (String)request.inputParameters.get('TextAnswer');
        inputParams.put('TextAnswer', 'Yes');
        
        //Datetime datetimeAnswer = (Datetime)request.inputParameters.get('DateAnswer');                   
        inputParams.put('DateAnswer', Datetime.now().addDays(-200));
        
        //Decimal numericAnswer = (Decimal)request.inputParameters.get('NumericAnswer');
        inputParams.put('NumericAnswer', 3.45);

				Process.PluginRequest request = new Process.PluginRequest(inputParams);           
        
        plugin.invoke(request);
        plugin.describe();
    
    }

}