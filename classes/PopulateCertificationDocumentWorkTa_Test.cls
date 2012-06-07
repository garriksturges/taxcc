/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class PopulateCertificationDocumentWorkTa_Test {
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
    ProgramCategoryQualification__c pcq;
    ProgramCategoryPeriod__c pcp;
    ProgramCategory__c pc;  
    Area__c ar;  
    static testMethod void myUnitTest() {
    	PopulateCertificationDocumentWorkTa_Test t = new PopulateCertificationDocumentWorkTa_Test();
    	t.popuLateData();
    	test.startTest();
    	PopulateCertificationDocumentWorkTables pc = new PopulateCertificationDocumentWorkTables();
    	pc.Populate8850(t.pq);
    	//pc.PopulateEddRelease(t.pcq);
    	test.stopTest();
    }
    
    public void populateData(){
        a = new Account();
        a.Name = 'testa';
        insert a;
        
        ar = new Area__c();
        insert ar;
        
        emp = new Employee__c();
        emp.Account__c = a.id;
        emp.FirstName__c = 'test';
        emp.LastName__c = 'testington';
        emp.SSN__c = '000-00-1234';
        emp.BirthDate__c = Date.today().addYears(-30);
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
        insert ea;
        
        
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
        
        list<ProgramCategory__c> pcList = [select ProgramCategoryEID__c, id from ProgramCategory__c where ProgramCategoryEID__c != null];
        map<double, ProgramCategory__c> pcMap = new map<double, ProgramCategory__c>();
        for(ProgramCategory__c pc: pcList){
        	pcMap.put(pc.ProgramCategoryEID__c, pc);
        }
        
        list <ProgramCategoryPeriod__c> pcpList = new list<ProgramCategoryPeriod__c>();
        pcp = new ProgramCategoryPeriod__c();
        pcp.ProgramCategory__c = pcMap.get(65).id;
        pcp.StartDate__c = date.today().addDays(-40);
        pcp.EndDate__c = date.today();
        pcp.Area__c = ar.id;
        pcpList.add(pcp);//insert pcp;
        
        pcp = new ProgramCategoryPeriod__c();
        pcp.ProgramCategory__c = pcMap.get(66).id;
        pcp.StartDate__c = date.today().addDays(-40);
        pcp.EndDate__c = date.today();
        pcp.Area__c = ar.id;
        pcpList.add(pcp);
        
        pcp = new ProgramCategoryPeriod__c();
        pcp.ProgramCategory__c = pcMap.get(71).id;
        pcp.StartDate__c = date.today().addDays(-40);
        pcp.EndDate__c = date.today();
        pcp.Area__c = ar.id;
        pcpList.add(pcp);
        
        pcp = new ProgramCategoryPeriod__c();
        pcp.ProgramCategory__c = pcMap.get(69).id;
        pcp.StartDate__c = date.today().addDays(-40);
        pcp.EndDate__c = date.today();
        pcp.Area__c = ar.id;
        pcpList.add(pcp);
        
        pcp = new ProgramCategoryPeriod__c();
        pcp.ProgramCategory__c = pcMap.get(74).id;
        pcp.StartDate__c = date.today().addDays(-40);
        pcp.EndDate__c = date.today();
        pcp.Area__c = ar.id;
        pcpList.add(pcp);
        
        pcp = new ProgramCategoryPeriod__c();
        pcp.ProgramCategory__c = pcMap.get(64).id;
        pcp.StartDate__c = date.today().addDays(-40);
        pcp.EndDate__c = date.today();
        pcp.Area__c = ar.id;
        pcpList.add(pcp);
        
        pcp = new ProgramCategoryPeriod__c();
        pcp.ProgramCategory__c = pcMap.get(73).id;
        pcp.StartDate__c = date.today().addDays(-40);
        pcp.EndDate__c = date.today();
        pcp.Area__c = ar.id;
        pcpList.add(pcp);
        
        //PCPLIST
        insert pcpList;
        
        list<ProgramCategoryQualification__c> pcqList = new list <ProgramCategoryQualification__c>();
         
	      pcq = new ProgramCategoryQualification__c();
				pcq.Name = 'test';
				pcq.Survey__c = es.id;
				pcq.ProcessStage__c = qps.id;
				pcq.ProgramQualification__c = pq.id;
				pcq.ProgramCategoryPeriod__c = pcpList[0].id;
				pcqList.add(pcq);//insert pcq;
				
				pcq = new ProgramCategoryQualification__c();
				pcq.Name = 'test';
				pcq.Survey__c = es.id;
				pcq.ProcessStage__c = qps.id;
				pcq.ProgramQualification__c = pq.id;
				pcq.ProgramCategoryPeriod__c = pcpList[1].id;
				pcqList.add(pcq);
				
				pcq = new ProgramCategoryQualification__c();
				pcq.Name = 'test';
				pcq.Survey__c = es.id;
				pcq.ProcessStage__c = qps.id;
				pcq.ProgramQualification__c = pq.id;
				pcq.ProgramCategoryPeriod__c = pcpList[2].id;
				pcqList.add(pcq);//insert pcq;

				pcq = new ProgramCategoryQualification__c();
				pcq.Name = 'test';
				pcq.Survey__c = es.id;
				pcq.ProcessStage__c = qps.id;
				pcq.ProgramQualification__c = pq.id;
				pcq.ProgramCategoryPeriod__c = pcpList[3].id;
				pcqList.add(pcq);//insert pcq;
				
				pcq = new ProgramCategoryQualification__c();
				pcq.Name = 'test';
				pcq.Survey__c = es.id;
				pcq.ProcessStage__c = qps.id;
				pcq.ProgramQualification__c = pq.id;
				pcq.ProgramCategoryPeriod__c = pcpList[4].id;
				pcqList.add(pcq);
				
				pcq = new ProgramCategoryQualification__c();
				pcq.Name = 'test';
				pcq.Survey__c = es.id;
				pcq.ProcessStage__c = qps.id;
				pcq.ProgramQualification__c = pq.id;
				pcq.ProgramCategoryPeriod__c = pcpList[5].id;
				pcqList.add(pcq);
				
				pcq = new ProgramCategoryQualification__c();
				pcq.Name = 'test';
				pcq.Survey__c = es.id;
				pcq.ProcessStage__c = qps.id;
				pcq.ProgramQualification__c = pq.id;
				pcq.ProgramCategoryPeriod__c = pcpList[6].id;
				pcqList.add(pcq);								
				//PCQLIST
				insert pcqList;
				pcq = pcqList[0];
        /***/
				/***/
				/***/
				/***/
        /****************************************************/
        
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
          esa.EmployeeSurveyAnswerText__c = 'Yes';
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
          esa.EmployeeSurveyAnswerText__c = 'Natural Disaster';
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
          esa.EmployeeSurveyAnswerEID__c =45;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(45).id;
          esaL.add(esa);//insert esa;
          
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =55;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(55).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =56;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(56).id;
          esaL.add(esa);//insert esa;
          
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =46;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(46).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =47;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(47).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =7;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(7).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =9;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(9).id;
          esaL.add(esa);//insert esa;
          esa = new EmployeeSurveyAnswer__c();
          esa.EmployeeSurveyAnswerAmount__c = 4.2324;
          esa.EmployeeSurvey__c = es.id;
          esa.EmployeeSurveyAnswerEID__c =54;
          esa.EmployeeSurveyAnswerText__c = 'Yes';
          esa.SurveyQuestion__c = sqMap.get(54).id;
          esaL.add(esa);//insert esa;
          
          //ARF
          insert esaL;
    }
    
}