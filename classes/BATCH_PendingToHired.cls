global class BATCH_PendingToHired implements Database.Batchable<sObject>{
  //this runs the batch
    global static void runBatch(){
      BATCH_PendingToHired b = new BATCH_PendingToHired ();
      b.setDefaultQuery();
      Database.executeBatch(b);
    }


    public String query{get; set;}
      
      global void setDefaultQuery(){
          this.query = 'Select Id, Status__c from Employment__c where Status__c=\'Pending\'';
          if(test.isRunningTest())this.query = 'Select Id, Status__c from Employment__c where Status__c=\'Pending\' limit 50';
      }
      
      
      global database.querylocator start(Database.BatchableContext BC){
              return Database.getQueryLocator(query);
      }
      
      global void execute(Database.BatchableContext BC, List<sObject> scope){
          List<Employment__c> obs = new List<Employment__c>();
          
          for(Employment__c s :(list<Employment__c>)scope){
              s.Status__c = 'Hired';
              obs.add(s);
          }
 
          update obs;
    }
   
      global void finish(Database.BatchableContext BC){
           
      }

    
    static testMethod void TEST_BATCH_PendingToHired () {
        test.startTest();
        BATCH_PendingToHired.runBatch();
        BATCH_PendingToHired b = new BATCH_PendingToHired ();
        b.setDefaultQuery();
        Database.executeBatch(b);
        test.stopTest();
    }
    

}