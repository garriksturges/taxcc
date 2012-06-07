global class BATCH_RunUpdateOnEmployment implements Database.Batchable<sObject>{

    global static void runBatch(){
      BATCH_RunUpdateOnEmployment b = new BATCH_RunUpdateOnEmployment ();
      b.setDefaultQuery();
      Database.executeBatch(b);
    }


    public String query{get; set;}
      
      global void setDefaultQuery(){
          this.query = 'Select StartDate__c From Employment__c';
          if(test.isRunningTest()) this.query = 'Select StartDate__c From Employment__c limit 50';
      }
      
      
      global database.querylocator start(Database.BatchableContext BC){
              return Database.getQueryLocator(query);
      }
      
      global void execute(Database.BatchableContext BC, List<sObject> scope){
          List<Employment__c> obs = new List<Employment__c>();
            date sd;
          
          for(Employment__c s :(list<Employment__c>)scope){
              sd = s.StartDate__c ;
              s.StartDate__c = sd;
              obs.add(s);
          }
 
          update obs;
    }
   
      global void finish(Database.BatchableContext BC){
           
      }

    
    static testMethod void TEST_BATCH_RunUpdateOnEmployment() {
    		test.startTest();
        BATCH_RunUpdateOnEmployment.runBatch();
        test.stopTest();
    }
    

}