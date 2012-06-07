public class TESTDATA_makeEmailNotificationData {
	public list<Language__c> lList;
	public list<Audience__c> aList;
	public list<ContentType__c> ctList;
	public list<ContentModule__c> cmList;

	public TESTDATA_makeEmailNotificationData(){}
	
	public void makeRequiredData(){
		//Languages
		lList = new list<Language__c>();
		Language__c l = new Language__c();
		l.Name = 'English';
		l.LanguageEID__c = 1;
		if(test.isRunningTest()) l.LanguageEID__c+=30000.78;
		lList.add(l);
		
		l = new Language__c();
		l.Name = 'Spanish';
		l.LanguageEID__c = 2;
		if(test.isRunningTest()) l.LanguageEID__c+=30000.78;
		lList.add(l);
		
		insert lList;
		
		//Audience
		aList = new list<Audience__c>();
		Audience__c a = new Audience__c();
		a.AudienceEID__c = 1;
		if(test.isRunningTest()) a.AudienceEID__c+=30000.78;
		a.Name = 'Employee';
		aList.add(a);

		a = new Audience__c();
		a.AudienceEID__c = 2;
		a.Name = 'Location Manager';
		if(test.isRunningTest()) a.AudienceEID__c+=30000.78;
		aList.add(a);
		
		a = new Audience__c();
		a.AudienceEID__c = 3;
		a.Name = 'District Manager';
		if(test.isRunningTest()) a.AudienceEID__c+=30000.78;
		aList.add(a);		
	
		a = new Audience__c();
		a.AudienceEID__c = 4;
		a.Name = 'Executive';
		if(test.isRunningTest()) a.AudienceEID__c+=30000.78;
		aList.add(a);
		
		a = new Audience__c();
		a.AudienceEID__c = 5;
		if(test.isRunningTest()) a.AudienceEID__c+=30000.78;
		a.Name = 'All';
		aList.add(a);
		
		insert aList;
		
		//ContentType
		ctList = new list<ContentType__c>();
		ContentType__c ct = new ContentType__c();
		ct.ContentTypeEID__c = 1;
		if(test.isRunningTest()) ct.ContentTypeEID__c+=30000.78;
		ct.Name = 'Intro';
		ctList.add(ct);
		
		ct = new ContentType__c();
		ct.ContentTypeEID__c = 2;
		if(test.isRunningTest()) ct.ContentTypeEID__c+=30000.78;
		ct.Name = 'Outro';
		ctList.add(ct);
		
		ct = new ContentType__c();
		ct.ContentTypeEID__c = 3;
		if(test.isRunningTest()) ct.ContentTypeEID__c+=30000.78;
		ct.Name = 'Preamble';
		ctList.add(ct);
		
		ct = new ContentType__c();
		ct.ContentTypeEID__c = 4;
		if(test.isRunningTest()) ct.ContentTypeEID__c+=30000.78;
		ct.Name = 'Footnote';
		ctList.add(ct);
		
		insert ctList;
		
		//ContentModules
		cmList = new list<ContentModule__c>();
		ContentModule__c cm = new ContentModule__c();
		cm.ContentModuleEID__c =1;
		if(test.isRunningTest()) cm.ContentModuleEID__c+=30000.78;
		cm.Name = 'Body';
		cmList.add(cm);
		
		cm = new ContentModule__c();
		cm.ContentModuleEID__c =2;
		if(test.isRunningTest()) cm.ContentModuleEID__c+=30000.78;
		cm.Name = 'Screening Needed';
		cmList.add(cm);
		
		cm = new ContentModule__c();
		cm.ContentModuleEID__c =3;
		if(test.isRunningTest()) cm.ContentModuleEID__c+=30000.78;
		cm.Name = 'Documents Needed';
		cmList.add(cm);
		
		cm = new ContentModule__c();
		cm.ContentModuleEID__c =4;
		if(test.isRunningTest()) cm.ContentModuleEID__c+=30000.78;
		cm.Name = 'Compliance Summary';
		cmList.add(cm);
		
		insert cmList;
	}
	
	private static testmethod void test(){
		TESTDATA_makeEmailNotificationData td = new TESTDATA_makeEmailNotificationData();
		td.makeRequiredData();
	}
}