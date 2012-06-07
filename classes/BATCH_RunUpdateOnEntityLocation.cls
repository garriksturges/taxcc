global class BATCH_RunUpdateOnEntityLocation implements Database.Batchable<sObject>{

    global static void runBatch(){
      BATCH_RunUpdateOnEntityLocation b = new BATCH_RunUpdateOnEntityLocation ();
      b.setDefaultQuery();
      Database.executeBatch(b);
    }


    public String query{get; set;}
      
      global void setDefaultQuery(){
          this.query = 'Select EntityLocationEID__c From EntityLocation__c';
          if(test.isRunningTest()) this.query = 'Select EntityLocationEID__c From EntityLocation__c limit 50';
      }
      
      global database.querylocator start(Database.BatchableContext BC){
              return Database.getQueryLocator(query);
      }
      
      global void execute(Database.BatchableContext BC, List<sObject> scope){
          List<EntityLocation__c> obs = new List<EntityLocation__c>();
            decimal sd;
          
          for(EntityLocation__c s :(list<EntityLocation__c>)scope){
              sd = s.EntityLocationEID__c ;
              s.EntityLocationEID__c = sd;
              obs.add(s);
          }
 
          update obs;
    }
   
      global void finish(Database.BatchableContext BC){
           
      }

    
    static testMethod void TEST_BATCH_RunUpdateOnEntityLocation() {
    		test.startTest();
        BATCH_RunUpdateOnEntityLocation.runBatch();
        test.stopTest();
    }
    

}