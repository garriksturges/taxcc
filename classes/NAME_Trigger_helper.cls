public with sharing class NAME_Trigger_helper {

    private map<String, Integer> fieldsMap; 
    private  Integer maxLength;
    private list<String> orderList;
    /**********************************/
    public NAME_Trigger_helper(map<String, Integer> fm, list<String> ol, Integer space){
        //this.orderList = ol;
        //this.fieldsMap = fm;
        this.maxLength = space-ol.size();
        trimWhiteSpace(ol, fm);
    }
    /**********************************/
    private void trimWhiteSpace(list<String> ol, map<String, integer>fm){
        orderList = new list<String>();
        fieldsMap = new map<String, Integer>();
        String newS;
        for(String k : ol){
            newS = k;
            //newS = k.replace('\'', '');
            orderList.add(newS.trim());
            fieldsMap.put(newS.trim(), fm.get(k));
        }
    }
    /**********************************/
    public String generateName(){
        integer totalSize = this.calculateTotalSize();
        if(totalSize == maxLength) return generateString();
        else{
            adjustMapLengths(totalSize);
            String rVal = generateString();
            return rVal;
        }
    }
    /**********************************/
    private String generateString(){
        String returnVal = '';
        String addVal;
        Integer max;
        for(String f:orderList){
            max = fieldsMap.get(f);
            if(f.length() <= max) addVal = f;
            else addVal = f.substring(0, max);
            if(returnVal.length() ==0) returnVal = addVal;
            else returnVal = returnVal +'|'+addVal;
        }
        return returnVal;
    }
    /**********************************/
    private integer calculateTotalSize(){
        Integer total = 0;
        //total = orderList.size()-1;
        Integer max;
        for(String f : orderList){
            max = fieldsMap.get(f);
            if(f.length()<max){
                total = total + f.length();
                fieldsMap.put(f, f.length()); 
            }
            else total = total + max;
        }
        //System.debug('!!!!!!!!!!!!!! TOTAL SIZE : '+total);       
        return total;
    }
    /**********************************/
    private void adjustMapLengths(integer totalSize){
        Integer ts = totalSize;
        while( ts < maxLength){
            ts=lengthenMapFields(ts);
        }
    }
    /**********************************/
    private integer lengthenMapFields(Integer ts){
        Integer totalSize = ts;
        Integer currentLength;
        
        for(String f : orderList){
            totalSize = calculateTotalSize();
            currentLength = fieldsMap.get(f);
            if(currentLength < f.length() && totalSize < maxLength){
                fieldsMap.put(f, currentLength +1);
            }
        }
        //System.debug('!!!!!!!!! EXTRA SPACE: '+totalSize);
        if(totalSize == ts) return maxLength;
        else return totalSize;
    }
    /**********************************/

    @istest
    private static void testCredit(){
        
        Program__c p = new Program__c();
        p.Name = 'pro'; 
        insert p;
        
        ProgramCategory__c pc = new ProgramCategory__c();
        pc.Program__c = p.id;
        pc.Name = 'proCat';
        insert pc;
        
        
        Account a = new Account();
        a.Name = 'account';
        insert a;
        
        Employee__c empl = new Employee__c();
        empl.FirstName__c = 'name';
        empl.LastName__c = 'lName';
        empl.SSN__c = '000-00-1234';
        empl.Account__c = a.id;
        insert empl;
        
        Entity__c ent = new Entity__c();
        ent.Account__c = a.id;
        insert ent;
        
        Employment__c emp = new Employment__c();
        emp.StartDate__c = date.today();
        emp.Employee__c = empl.id;
        emp.Entity__c = ent.id;
        insert emp;
        
        ProgramPeriod__c pp = new ProgramPeriod__c();
        pp.StartDate__c = Date.today().addDays(-4000);
        pp.EndDate__c = Date.today().addDays(4000);
        pp.Program__c = p.id;
        insert pp;
        
        
        ProgramQualification__c pq = new ProgramQualification__c();
        pq.ProgramPeriod__c = pp.id; 
        //pq.Name = 'proQual';
        pq.Employment__c = emp.id;
        insert pq;
        
        
        Credit__c c = new Credit__c();
        c.ProgramCategory__c = pc.id;
        c.ProgramQualification__c = pq.id;
        c.StartDate__c = Date.today();
        c.EndDate__c = Date.today();
        insert c;
        c= [select Name from credit__c where id = :c.Id];
        system.assert(c.Name!=null);
        
        Credit__c c2 = new Credit__c();
        c2.ProgramCategory__c = pc.id;
        c2.ProgramQualification__c = pq.id;
        c2.StartDate__c = Date.today();
        insert c2;              
    }
    /*********/
    @istest
    private static void testAgency(){
        Agency__c ag = new Agency__c();
        ag.Name = 'booger';
        insert ag;
        
        State__c state = new State__c();
        state.Name = 'test';
        state.StateAbbr__c = 'tt';
        insert state;
        
        AgencyAddress__c aa = new AgencyAddress__c();
        aa.Agency__c = ag.id;
        aa.State__c = state.id;
        aa.StreetAddressText__c = '123123123';
        aa.CityName__c = 'test';
        insert aa;
        aa = [select name from AgencyAddress__c where id = :aa.id];
        System.debug('!!!!!!!!!: '+aa.Name);
        system.assert(aa.Name.contains('booger'));
    }
    /*********/
    @istest
    private static void testEmployeeAddress(){
        Account a = new Account();
        a.Name = 'account';
        insert a;
        
        Employee__c empl = new Employee__c();
        empl.FirstName__c = 'Hector';
        empl.LastName__c = 'lName';
        empl.SSN__c = '000-00-1234';
        empl.Account__c = a.id;
        insert empl;
        
        State__c state = new State__c();
        state.Name = 'test';
        state.StateAbbr__c = 'tt';
        insert state;

        EmployeeAddress__c ea = new EmployeeAddress__c();
        ea.Employee__c = empl.id;
        ea.State__c = state.id;
        ea.StreetAddressText__c = 'sdlfkjsdlkf';
        ea.CityName__c = 'sldkfjsdlkf';
        ea.ZipCode__c = '28211';
        insert ea;
        ea = [select name from EmployeeAddress__c where id = :ea.id];
        system.assert(ea.Name.contains('Hector'));

    }
    /*********/
    @istest
    private static void EmployeeSurvey(){
        Account a = new Account();
        a.Name = 'account';
        insert a;
        
        Employee__c empl = new Employee__c();
        empl.FirstName__c = 'Hector';
        empl.LastName__c = 'lName';
        empl.SSN__c = '000-00-1234';
        empl.Account__c = a.id;
        insert empl;
        
        Entity__c ent = new Entity__c();
        ent.Account__c = a.id;
        insert ent;
        
        Employment__c emp = new Employment__c();
        emp.StartDate__c = date.today();
        emp.Employee__c = empl.id;
        emp.Entity__c = ent.id;
        insert emp;
    
        Location__c loc= new Location__c();
        loc.Account__c = a.id;
        insert loc;
        
        EntityLocation__c el = new EntityLocation__c();
        el.Location__c =  loc.Id;
        el.Entity__c = ent.id;
        insert el;
    
        EmployeeSurvey__c es = new EmployeeSurvey__c();
        es.EntityLocation__c = el.id;
        es.EmploymentPeriod__c = emp.id;
        es.SurveyDate__c = Datetime.now();
        insert es;
        es = [select name from EmployeeSurvey__c where id = :es.Id];
        System.assert(es.Name != null);
    }
    /*********/
    @istest
    private static void EmploymentTest(){
        Account a = new Account();
        a.Name = 'account';
        insert a;
        
        Employee__c empl = new Employee__c();
        empl.FirstName__c = 'Hector';
        empl.LastName__c = 'lName';
        empl.SSN__c = '000-00-1234';
        empl.Account__c = a.id;
        insert empl;
        
        Entity__c ent = new Entity__c();
        ent.Account__c = a.id;
        insert ent;
        
        Employment__c emp = new Employment__c();
        emp.StartDate__c = date.today();
        emp.Employee__c = empl.id;
        emp.Entity__c = ent.id;
        insert emp;
        emp = [select Name from employment__c where id = :emp.id];
        System.assert(emp.Name.contains('Hector'));
    }
    /*********/
    @istest
    private static void testEntityAgreement(){
        Account a = new Account();
        a.Name = 'account';
        insert a;
        
        Entity__c ent = new Entity__c();
        ent.Account__c = a.id;
        insert ent;
        
        Agency__c ag = new Agency__c();
        ag.Name = 'agency123';
        insert ag;
        
        EntityAgreement__c ea = new EntityAgreement__c();
        ea.Agency__c = ag.id;
        ea.Entity__c = ent.id;
        ea.AgreementType__c = 'Power of Attorney';
        ea.StartDate__c = Date.today();
        ea.EndDate__c = Date.today().addDays(400);
        insert ea;
        ea = [select Name from EntityAgreement__c where id = :ea.Id];
        system.assert(ea.Name.contains('agency123'));
        
        EntityAgreement__c ea2 = new EntityAgreement__c();
        ea2.Agency__c = ag.id;
        ea2.Entity__c = ent.id;
        ea2.AgreementType__c = 'Pre-authorization';
        ea2.StartDate__c = Date.today();
        insert ea2;
        ea2 = [select Name from EntityAgreement__c where id = :ea2.Id];
        system.assert(ea2.Name.contains('agency123'));
        
    }
    /*********/
    @istest
    private static void testEntityFiscalYear(){
        Account a = new Account();
        a.Name = 'account';
        insert a;
        
        Entity__c ent = new Entity__c();
        ent.Account__c = a.id;
        ent.Name = 'arfarfarf arf';
        insert ent;

        EntityFiscalyear__c ef = new EntityFiscalyear__c();
        ef.entity__c = ent.id;
        ef.FiscalYearEndDate__c = Date.today();
        insert ef;
        ef = [select Name from EntityFiscalyear__c where id = :ef.Id];
        System.assert(ef.Name.contains('arf'));
    }
    /*********/
    @istest
    private static void testEntityLocation(){
        Account a = new Account();
        a.Name = 'account';
        insert a;
        
        Entity__c ent = new Entity__c();
        ent.Account__c = a.id;
        ent.Name = 'arfarfarf arf';
        insert ent;
        
        Location__c loc= new Location__c();
        loc.Account__c = a.id;
        insert loc;
        
        EntityLocation__c el = new EntityLocation__c();
        el.Entity__c = ent.id;
        el.Location__c = loc.id;
        insert el;
        el = [select Name from EntityLocation__c where id = :el.id];
        System.assert(el.Name.contains('arfarf'));  
    }
    /*********/
    @istest
    private static void testEntityStructure(){
        Account a = new Account();
        a.Name = 'account';
        insert a;
        
        Entity__c ent = new Entity__c();
        ent.Account__c = a.id;
        ent.Name = 'arfarfarf arf';
        insert ent;
        
        State__c state = new State__c();
        state.Name = 'test';
        state.StateAbbr__c = 'tt';
        insert state;
        
        EntityStructure__c es = new EntityStructure__c();
        es.EntityName__c = ent.id;
        es.State__c = state.id;
        es.EntityType__c = 'awesome';
        es.FederalTaxId__c = '123456789';
        es.StateTaxId__c = '987654321';
        insert es;
        es = [select Name from EntityStructure__c where id = :es.Id];
        System.assert(es.Name.contains('12-3456789'));
    }
    /*********/
    @istest
    private static void testHour(){
        Account a = new Account();
        a.Name = 'account';
        insert a;
        
        Employee__c empl = new Employee__c();
        empl.FirstName__c = 'name';
        empl.LastName__c = 'lName';
        empl.SSN__c = '000-00-1234';
        empl.Account__c = a.id;
        insert empl;
        
        Entity__c ent = new Entity__c();
        ent.Account__c = a.id;
        insert ent;
        
        Employment__c emp = new Employment__c();
        emp.StartDate__c = date.today().addDays(-1001);
        emp.Employee__c = empl.id;
        emp.Entity__c = ent.id;
        insert emp;
        
        Wage__c w = new Wage__c();
        w.EmploymentPeriod__c = emp.id;
        w.StartDate__c = date.today().adddays(-1000);
        w.EndDate__c = date.today();
        w.WageAmount__c = 22;
        insert w;
        
        Location__c loc= new Location__c();
        loc.Account__c = a.id;
        loc.Name = 'booger';
        insert loc;
        
        Hour__c h = new Hour__c();
        h.Wage__c = w.id;
        h.Location__c = loc.id;
        h.HourAmount__c = 58;
        insert h;
        h = [select Name from Hour__c where id = :h.id];
        System.assert(h.Name.contains('booger'));
    }   
    /*********/
    @istest
    private static void testlocationProgram(){
        Account a = new Account();
        a.Name = 'account';
        insert a;
        
        Program__c p = new Program__c();
        p.Name = 'pro'; 
        insert p;
        
        Location__c loc= new Location__c();
        loc.Account__c = a.id;
        loc.Name = 'booger';
        insert loc;
        
        LocationProgram__c lp = new LocationProgram__c();
        lp.Program__c = p.id;
        lp.Location__c = loc.id;
        lp.StartDate__c = Date.today().addDays(-500);
        lp.EndDate__c = Date.today();
        insert lp;
        lp = [Select Name from LocationProgram__c where id = :lp.id];
        System.assert(lp.Name.contains('booger'));
    }
    /*********/
    @istest
    private static void testProgramCategoryPeriod(){
        Program__c p = new Program__c();
        p.Name = 'pro'; 
        insert p;
        
        ProgramCategory__c pc = new ProgramCategory__c();
        pc.Program__c = p.id;
        pc.Name = 'proCat';
        insert pc;
        
        Area__c ar = new Area__c();
        ar.Name = 'arearg';
        insert ar;
        
        ProgramCategoryPeriod__c pcp = new ProgramCategoryPeriod__c();
        pcp.ProgramCategory__c = pc.id;
        pcp.Area__c = ar.id;
        pcp.StartDate__c = Date.today().addDays(-1000);
        pcp.EndDate__c = Date.today();
        insert pcp;
        pcp = [select Name from ProgramCategoryPeriod__c where id = :pcp.id];
        system.assert(pcp.Name.contains('proCat'));
    }
    /*********/
    @istest
    private static void testProgramCategoryQualification(){
        Account a = new Account();
        a.Name = 'account';
        insert a;
        
        Employee__c empl = new Employee__c();
        empl.FirstName__c = 'name';
        empl.LastName__c = 'lName';
        empl.SSN__c = '000-00-1234';
        empl.Account__c = a.id;
        insert empl;
        
        Entity__c ent = new Entity__c();
        ent.Account__c = a.id;
        insert ent;
        
        Employment__c emp = new Employment__c();
        emp.StartDate__c = date.today();
        emp.Employee__c = empl.id;
        emp.Entity__c = ent.id;
        insert emp;
        
        Program__c p = new Program__c();
        p.Name = 'pro'; 
        insert p;
        
        ProgramCategory__c pc = new ProgramCategory__c();
        pc.Program__c = p.id;
        pc.Name = 'proCat';
        insert pc;
        
        Area__c ar = new Area__c();
        ar.Name = 'arearg';
        insert ar;
        
        ProgramPeriod__c pp = new ProgramPeriod__c();
        pp.StartDate__c = Date.today().addDays(-4000);
        pp.EndDate__c = Date.today().addDays(4000);
        pp.Program__c = p.id;
        insert pp;
        
        ProgramCategoryPeriod__c pcp = new ProgramCategoryPeriod__c();
        pcp.ProgramCategory__c = pc.id;
        pcp.Area__c = ar.id;
        pcp.StartDate__c = Date.today().addDays(-1000);
        pcp.EndDate__c = Date.today();
        insert pcp;
        
        ProgramQualification__c pq = new ProgramQualification__c();
        pq.ProgramPeriod__c = pp.id; 
        //pq.Name = 'proQual';
        pq.Employment__c = emp.id;
        pq.EffectiveDate__c = Date.today().addDays(-1000);
        insert pq;
        
        ProgramCategoryQualification__c pcq = new ProgramCategoryQualification__c();
        pcq.ProgramQualification__c = pq.id;
        pcq.ProgramCategoryPeriod__c = pcp.id;
        insert pcq;
        pcq = [select Name from ProgramCategoryQualification__c where id = :pcq.id];
        System.assert(pcq.Name!=null, pcq.Name);
    }
    /*********/
    @istest
    private static void testProgramPeriod(){
        Area__c ar = new Area__c();
        ar.Name = 'arearg';
        insert ar;
        
        Program__c p = new Program__c();
        p.Name = 'pro'; 
        insert p;
        
        Agency__c ag = new Agency__c();
        ag.Name = 'booger';
        insert ag;
        
        ProgramPeriod__c pp = new ProgramPeriod__c();
        pp.StartDate__c = Date.today().addDays(-4000);
        pp.EndDate__c = Date.today().addDays(4000);
        pp.Program__c = p.id;
        pp.Area__c = ar.id;
        pp.Agency__c = ag.id;
        insert pp;
        pp = [select Name from ProgramPeriod__c where id = :pp.id];
        System.assert(pp.Name.contains('arearg'));
    }
    /*********/
    @istest
    private static void testProgramQualification(){
        Account a = new Account();
        a.Name = 'account';
        insert a;
        
        Employee__c empl = new Employee__c();
        empl.FirstName__c = 'name';
        empl.LastName__c = 'lName';
        empl.SSN__c = '000-00-1234';
        empl.Account__c = a.id;
        insert empl;
        
        Entity__c ent = new Entity__c();
        ent.Account__c = a.id;
        insert ent;
        
        Employment__c emp = new Employment__c();
        emp.StartDate__c = date.today();
        emp.Employee__c = empl.id;
        emp.Entity__c = ent.id;
        insert emp;
        
        Program__c p = new Program__c();
        p.Name = 'pro'; 
        insert p;
        
        ProgramCategory__c pc = new ProgramCategory__c();
        pc.Program__c = p.id;
        pc.Name = 'proCat';
        insert pc;
        
        Area__c ar = new Area__c();
        ar.Name = 'arearg';
        insert ar;
        
        ProgramPeriod__c pp = new ProgramPeriod__c();
        pp.StartDate__c = Date.today().addDays(-4000);
        pp.EndDate__c = Date.today().addDays(4000);
        pp.Program__c = p.id;
        insert pp;
        
        ProgramCategoryPeriod__c pcp = new ProgramCategoryPeriod__c();
        pcp.ProgramCategory__c = pc.id;
        pcp.Area__c = ar.id;
        pcp.StartDate__c = Date.today().addDays(-1000);
        pcp.EndDate__c = Date.today();
        insert pcp;
        
        ProgramQualification__c pq = new ProgramQualification__c();
        pq.ProgramPeriod__c = pp.id; 
        //pq.Name = 'proQual';
        pq.Employment__c = emp.id;
        pq.EffectiveDate__c = Date.today().addDays(-1000);
        insert pq;
        pq = [select Name from ProgramQualification__c where id = :pq.id];
        System.assert(pq.Name != null);
    }
    /*********/
    @istest
    private static void testWage(){
        Account a = new Account();
        a.Name = 'account';
        insert a;
        
        Employee__c empl = new Employee__c();
        empl.FirstName__c = 'name';
        empl.LastName__c = 'lName';
        empl.SSN__c = '000-00-1234';
        empl.Account__c = a.id;
        insert empl;
        
        Entity__c ent = new Entity__c();
        ent.Account__c = a.id;
        ent.Name='ja';
        insert ent;
        
        Employment__c emp = new Employment__c();
        emp.StartDate__c = date.today().addDays(-1001);
        emp.Employee__c = empl.id;
        emp.Entity__c = ent.id;
        insert emp;
        
        Wage__c w = new Wage__c();
        w.EmploymentPeriod__c = emp.id;
        w.StartDate__c = date.today().adddays(-1000);
        w.EndDate__c = date.today();
        w.WageAmount__c = 22;
        insert w;
        w = [select Name from Wage__c where id = :w.id];
        System.assert(w.Name.contains('name'));
        
    }
}
/*
String v1 = 'See, Michael Andrey';
String v2 = 'Olympia Convalescent Hospital';
String v3 = 'Olympia Convalescent Hospital';
string v4 = '9/16/11';
Map <String, integer> m = new Map<String, Integer>();
m.put(v1, 22);
m.put(v2, 22);
m.put(v3, 22);
m.put(v4, 8);
list<String> o = new list<String>(); o.add(v1); o.add(v2); o.add(v3); o.add(v4);
NAME_Trigger_helper h= new NAME_Trigger_helper(m, o, 80);
String val = h.generateName();
System.debug('!!!!!!!!!!!!!!!!!!'+val.length() + '   '+val);        
*/