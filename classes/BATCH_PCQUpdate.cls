global class BATCH_PCQUpdate implements Database.Batchable<sObject>{

        global static void runBatch(){
            BATCH_PCQUpdate b = new BATCH_PCQUpdate();
            b.setDefaultQuery();
            Database.executeBatch(b);
        }


        public String query{get; set;}
        
        global void setDefaultQuery(){
            this.query = 'Select p.Name From ProgramCategoryQualification__c p';
            if(test.isRunningTest()) this.query = 'Select p.Name From ProgramCategoryQualification__c p limit 100';
        }
        
        global database.querylocator start(Database.BatchableContext BC){
                return Database.getQueryLocator(query);
        }
        
        global void execute(Database.BatchableContext BC, List<sObject> scope){
            String N;
            list<ProgramCategoryQualification__c> pcqL = new list <ProgramCategoryQualification__c>();
            for(ProgramCategoryQualification__c pcq: (list<ProgramCategoryQualification__c>)scope){
            	N = pcq.Name;
            	pcq.Name = N;
            	pcqL.add(pcq);
            }
            update pcqL;
            
        }
     
        global void finish(Database.BatchableContext BC){
             
        }

    static testMethod void BATCH_PCQUpdate() {
        test.startTest();
        BATCH_PCQUpdate.runBatch();
        test.stopTest();
    }

}