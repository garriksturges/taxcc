global class BATCH_RunUpdateOnEmployee implements Database.Batchable<sObject>{
	//this runs the batch
    global static void runBatch(){
      BATCH_RunUpdateOnEmployee b = new BATCH_RunUpdateOnEmployee ();
      b.setDefaultQuery();
      Database.executeBatch(b);
    }


    public String query{get; set;}
      
      global void setDefaultQuery(){
          this.query = 'Select FirstName__c From Employee__c';
          if(test.isRunningTest())this.query = 'Select FirstName__c From Employee__c limit 50';
      }
      
      
      global database.querylocator start(Database.BatchableContext BC){
              return Database.getQueryLocator(query);
      }
      
      global void execute(Database.BatchableContext BC, List<sObject> scope){
          List<Employee__c> obs = new List<Employee__c>();
            string sd;
          
          for(Employee__c s :(list<Employee__c>)scope){
              sd = s.FirstName__c ;
              s.FirstName__c = sd;
              obs.add(s);
          }
 
          update obs;
    }
   
      global void finish(Database.BatchableContext BC){
           
      }

    
    static testMethod void TEST_BATCH_RunUpdateOnEmployee() {
    		test.startTest();
        BATCH_RunUpdateOnEmployee.runBatch();
        BATCH_RunUpdateOnEmployee b = new BATCH_RunUpdateOnEmployee ();
      	b.setDefaultQuery();
      	Database.executeBatch(b);
        test.stopTest();
    }
    

}