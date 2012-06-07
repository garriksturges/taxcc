global class BATCH_RunUpdateOnProgramQualification implements Database.Batchable<sObject>{

        global static void runBatch(){
            BATCH_RunUpdateOnProgramQualification b = new BATCH_RunUpdateOnProgramQualification();
            b.setDefaultQuery();
            Database.executeBatch(b);
        }


        public String query{get; set;}
        
        global void setDefaultQuery(){
            this.query = 'Select EffectiveDate__c From ProgramQualification__c';
            if(test.isRunningTest()) this.query = 'Select EffectiveDate__c From ProgramQualification__c limit 100';
        }
        
        global database.querylocator start(Database.BatchableContext BC){
                return Database.getQueryLocator(query);
        }
        
        global void execute(Database.BatchableContext BC, List<sObject> scope){
            List<ProgramQualification__c> obs = new List<ProgramQualification__c>();
            Date sd;
            
            for(ProgramQualification__c s :(list<ProgramQualification__c>)scope){
                sd = s.EffectiveDate__c;
                s.EffectiveDate__c = sd;
                obs.add(s);
            }
 
            update obs;
        }
     
        global void finish(Database.BatchableContext BC){
             
        }

    static testMethod void TEST_BATCH_RunUpdateOnProgramQualification() {
        test.startTest();
        BATCH_RunUpdateOnProgramQualification.runBatch();
        test.stopTest();
    }
}