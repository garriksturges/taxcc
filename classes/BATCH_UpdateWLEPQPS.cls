global class BATCH_UpdateWLEPQPS implements Database.Batchable<sObject>{
  //this runs the batch
    global static void runBatch(){
      BATCH_UpdateWLEPQPS  b = new BATCH_UpdateWLEPQPS ();
      b.setDefaultQuery();
      Database.executeBatch(b);
    }


    public String query{get; set;}
      
      global void setDefaultQuery(){
          this.query = 'Select Id, QualificationProcessStage__c, QPSFormula__c from wktLocationEmployeeProgram__c where QualificationProcessStage__c = null';
          if(test.isRunningTest())this.query = 'Select Id, QualificationProcessStage__c, QPSFormula__c from wktLocationEmployeeProgram__c where QualificationProcessStage__c = null limit 50';
      }
      
      
      global database.querylocator start(Database.BatchableContext BC){
              return Database.getQueryLocator(query);
      }
      
      global void execute(Database.BatchableContext BC, List<sObject> scope){
          List<wktLocationEmployeeProgram__c > obs = new List<wktLocationEmployeeProgram__c >();
          
          for(wktLocationEmployeeProgram__c  s :(list<wktLocationEmployeeProgram__c >)scope){
              s.QualificationProcessStage__c = s.QPSFormula__c;
              obs.add(s);
          }
 
          update obs;
    }
   
      global void finish(Database.BatchableContext BC){
           
      }

    
    static testMethod void TEST_BATCH_UpdateWLEPQPS () {
        test.startTest();
        BATCH_UpdateWLEPQPS.runBatch();
        BATCH_UpdateWLEPQPS b = new BATCH_UpdateWLEPQPS();
        b.setDefaultQuery();
        Database.executeBatch(b);
        test.stopTest();
    }
    

}