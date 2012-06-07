/***************************************************************************************************************
Class Name : Calculate WOTC
Created By : Srikanth Pothuraj
Created Date : 10/19/2011
Description : 
Recent Modifications Made :
****************************************************************************************************************/
public class CalculateWOTC  
{
	
	//Set<Id> pqIds = new Set<Id>();
	List<ProgramQualification__c> lstProgQual = new List<ProgramQualification__c>();
	string tempId = null;
	integer counter =0;    
	Set<String> empIds = new Set<String>();
	Map<String, Set<String>> mapProgEmpl = new Map<String, Set<String>>();
	map<id,double> mapQualCredValue = new map<id,double>(); 
		
	public void CalculateWOTCCredit(Decimal ProgramId, Set<String> EmploymentIds)
	{ 
		String pcqForDeletion = '';
		
		// get all Employments with the given Employment Ids        
		List<Employment__c>  employments   = [Select Id, (Select Id From Credits__r), Entity__r.Id,Name,StartDate__c, (Select Id, Name, EndDate__c, StartDate__c,HoursSummary__c, WageAmount__c From Wages__r order by EndDate__c), 
											(Select Id, Name, Employment__c , ProgramPeriod__c, ProgramPeriod__r.Program__r.ProgramEID__c From ProgramQualifications__r) From Employment__c where Id IN: EmploymentIds];
	
		
		
		//Loop thru all Employments       
		for(Employment__c emp : employments)
		{
			//pqIds = new Set<Id>();
		
			integer CumulativeDays = 0; 
		
			Date FirstCreditStartDate =  emp.StartDate__c;
			Date EstimatedCreditEndDate = FirstCreditStartDate.addYears(1).addDays(-1);
			Date EstimatedCreditEndDateLTAssist = FirstCreditStartDate.addYears(2);
			List<Credit__c> lstCredit = new List<Credit__c>(); 
			List<Credit__c> updCredit = new List<Credit__c>();
			List<Credit__c> lstTempCredit = new List<Credit__c>();          
			Set<Date> EndDatesArray = new Set<Date>(); 
			List<Date> EndDatesList = new List<Date>(); 
			
			List<ProgramQualification__c> pq = [Select Id, (Select Id From Credits__r) From ProgramQualification__c where Employment__c  =: emp.Id and ProgramPeriod__r.Program__r.ProgramEID__c =:ProgramId limit 1]; 
							
			if(emp.Credits__r.size()>0)
				delete emp.Credits__r; 
			
			if(pq.size()>0) 
			{
				
				List<ProgramCategoryQualification__c>  programCategoryQualList = [Select ProgramQualification__r.Name, ProgramQualification__r.Id, ProgramQualification__c, ProgramCategoryPeriod__c, ProgramCategoryPeriod__r.ProgramCategory__r.Program__c,
																			ProgramCategoryPeriod__r.ProgramCategory__r.Program__r.ProgramEID__c, ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c, ProgramCategoryPeriod__r.ProgramCategory__r.Name, Name, Id From ProgramCategoryQualification__c 
																			where ProgramQualification__r.Id =: pq[0].Id order by ProgramCategoryPeriod__r.ProgramCategory__r.Program__c];
					

								
										
				//If the first wage period starts later than the beginning of the employment start date, 
				//add the missing days to the cumulative day count and If this is the first wage record  
					if(emp.Wages__r.size() > 0  && emp.Wages__r[0].StartDate__c > emp.StartDate__c)
				CumulativeDays = emp.StartDate__c.daysBetween(emp.Wages__r[0].StartDate__c) + 1;  
				
				// Query thru entity to get Fiscal Year Enddate for this Employment
				Entity__c enty = [Select Id, (Select Id, FiscalYearEndDate__c From EntityEntityFiscalyears__r where FiscalYearEndDate__c >=: FirstCreditStartDate order by FiscalYearEndDate__c) From Entity__c where Id =:emp.Entity__r.Id];
					
				// Loop thru all PCQ             
				for(ProgramCategoryQualification__c prg : programCategoryQualList)
				{                                
					// Logic to calculate Credit based on above obtained Total Hours and Cumulative Wages 
					// under a particular Employment based on Tier 1 or Tier 2

					decimal CumulativeWages=0;
					integer RemainingDays = 0;                     
					integer wageDays = 0;            
					decimal TotalHours = 0;
					decimal ProratedHours = 0;
					Set<Id> lstWageIds = new Set<Id>();
					Date LastCreditEndDate;                                      


					decimal Credit = 0; 
					decimal tempCumWages = 0;
					integer CreditStartYear = 0; 
					Date CalenderYearEnd;
					EndDatesArray = new Set<Date>(); 
					EndDatesList = new List<Date>();            
					lstTempCredit = new List<Credit__c>(); 

					decimal tempCredit =0;
					decimal tempFirstyrWages = 0; 
					decimal tempSecondyrWages = 0; 
					integer CreditStartYear1 = 0;  
					integer CreditStartYear2 = 0; 
					Date CalenderYearEnd1;
					Date CalenderYearEnd2;
					Date tempLastCreditEndDate;
					Set<Id> lstLTwageIds = new Set<Id>();
					decimal FirstYearLTHours = 0;
					decimal SecondYrLTHours = 0;
					decimal TotalLTHours = 0;
					decimal ProratedLTHours = 0;
					decimal CumulativeLTWages=0;
					decimal FirstYearWagesLT = 0;
					decimal SecondYearWagesLT = 0;

					double TempCredSum = 0;
					decimal tempFirstYrCredit = 0;
					decimal tempSecondYrCredit = 0;
					
					if (prg.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 73.0)
					{                           
						for(Wage__c wge : emp.Wages__r)
						{ 
							if(wge.StartDate__c >=  FirstCreditStartDate)
							{
								System.debug('EstimatedCreditEndDateLTAssist::::'+EstimatedCreditEndDateLTAssist);
								System.debug('wge.EndDate__c::::'+wge.EndDate__c);
										
								if(EstimatedCreditEndDateLTAssist > wge.EndDate__c)
										lstLTwageIds.Add(wge.Id);
										
										
								else if(wge.StartDate__c <= EstimatedCreditEndDateLTAssist && EstimatedCreditEndDateLTAssist <= wge.EndDate__c)
								{
									lstLTwageIds.remove(wge.Id);
									System.debug('lstLTwageIds:::'+lstLTwageIds);
									List<Hour__c> hr = [Select Id,HourAmount__c from Hour__c where Wage__c =: wge.Id AND Wage__r.StartDate__c <=: EstimatedCreditEndDateLTAssist AND Wage__r.EndDate__c >=: EstimatedCreditEndDateLTAssist];
									
									if(hr.size() >0) 
									{
										decimal hours = hr[0].HourAmount__c;
										System.debug('hours::::'+ hours);
										
										ProratedLTHours = ((hours/ (wge.EndDate__c.daysBetween(wge.StartDate__c) +1)) *(EstimatedCreditEndDateLTAssist.daysBetween(wge.StartDate__c) + 1));
										
										System.debug('ProratedLTHours::::'+ ProratedLTHours);
										
										TotalLTHours += ProratedLTHours;
										
										System.debug('TotalLTHours::::'+ TotalLTHours);
									}   
									break;
								}
							}
						}
						
						for(Hour__c hr : [Select Id,HourAmount__c from Hour__c where Wage__c in: lstLTwageIds])
						{
							TotalLTHours = TotalLTHours + hr.HourAmount__c;
						}
									
								
						for(Wage__c wge : emp.Wages__r)
						{                                
							wageDays = wge.StartDate__c.daysBetween(wge.EndDate__c) + 1; 
								
							// CumulativeDays =  CumulativeDays + wageDays;
																
							
							if(EstimatedCreditEndDate > wge.EndDate__c)
							{
								FirstYearWagesLT = FirstYearWagesLT + wge.WageAmount__c;
								
								LastCreditEndDate = wge.EndDate__c;
								System.debug('FirstYearWagesLT in IF::::'+ FirstYearWagesLT);
							}
							else if(wge.StartDate__c < EstimatedCreditEndDate && EstimatedCreditEndDate <= wge.EndDate__c)
							{
								RemainingDays = wge.StartDate__c.daysBetween(EstimatedCreditEndDate) + 1 ;
								FirstYearWagesLT = FirstYearWagesLT + ((wge.WageAmount__c / wageDays) * RemainingDays) ;                          
								LastCreditEndDate = FirstCreditStartDate.addDays(364);                      
								System.debug('FirstYearWagesLT in Else::::'+ FirstYearWagesLT);   

								if(EstimatedCreditEndDateLTAssist > wge.EndDate__c)
								{
									SecondYearWagesLT = SecondYearWagesLT + wge.WageAmount__c - ((wge.WageAmount__c / wageDays) * RemainingDays);
									
									LastCreditEndDate = wge.EndDate__c;
									System.debug('SecondYearWagesLT in IF::::'+ SecondYearWagesLT);
								}
								else if(EstimatedCreditEndDate <= EstimatedCreditEndDateLTAssist && EstimatedCreditEndDateLTAssist <= wge.EndDate__c)
								{
									RemainingDays = EstimatedCreditEndDate.daysBetween(EstimatedCreditEndDateLTAssist) ;
									SecondYearWagesLT = SecondYearWagesLT + ((wge.WageAmount__c / wageDays) * RemainingDays) ;                          
									LastCreditEndDate = FirstCreditStartDate.addYears(2).addDays(-1);                      
									System.debug('SecondYearWagesLT in Else::::'+ SecondYearWagesLT);     
									
								}
								
								System.debug('SecondYearWagesLT %%%%%%'+ SecondYearWagesLT); 
								continue;
							}
							else if(EstimatedCreditEndDateLTAssist > wge.EndDate__c)
							{
								SecondYearWagesLT = SecondYearWagesLT + wge.WageAmount__c;
								
								LastCreditEndDate = wge.EndDate__c;
								System.debug('SecondYearWagesLT in IF::::'+ SecondYearWagesLT);
							}
							else if(wge.StartDate__c <= EstimatedCreditEndDateLTAssist && EstimatedCreditEndDateLTAssist <= wge.EndDate__c)
							{
								RemainingDays = wge.StartDate__c.daysBetween(EstimatedCreditEndDateLTAssist) ;
								SecondYearWagesLT = SecondYearWagesLT + ((wge.WageAmount__c / wageDays) * RemainingDays) ;                          
								LastCreditEndDate = FirstCreditStartDate.addYears(2).addDays(-1);                      
								System.debug('SecondYearWagesLT in Else::::'+ SecondYearWagesLT);      
								break;
							}
																			
						}
							
				
						TotalHours = TotalLTHours;
						tempFirstyrWages = FirstYearWagesLT; 
						tempSecondyrWages = SecondYearWagesLT; 
						
						if(TotalHours >= 120 && TotalHours < 400)
						{
							if(tempFirstyrWages > 10000)
									tempFirstyrWages = 10000;
																			
							tempFirstYrCredit = (0.25)*tempFirstyrWages;
							Credit = (0.25)*tempFirstyrWages;
						}
						
						else if ( TotalHours >= 400 )
						{
							if(tempFirstyrWages > 10000)
									tempFirstyrWages = 10000;
									
							tempCredit = (0.40)*tempFirstyrWages;
							tempFirstYrCredit = (0.40)*tempFirstyrWages;
							
							if(tempSecondyrWages > 10000)
								tempSecondyrWages = 10000;
							
							tempSecondYrCredit = (0.50)*tempSecondyrWages ; 
							System.debug('tempSecondYrCredit:::'+tempSecondYrCredit);
							Credit = tempCredit + (0.50)*tempSecondyrWages ;    
						}
									
						System.debug('CreditLT:::'+Credit);
									
						CreditStartYear1 = FirstCreditStartDate.year();
						
						CalenderYearEnd1 = Date.newInstance(CreditStartYear1, 12, 31);   
				
			
						System.debug('FirstCreditStartDate::::::::::'+FirstCreditStartDate);
						if(FirstCreditStartDate.daysBetween(LastCreditEndDate) >= 365)
						{
								tempLastCreditEndDate = FirstCreditStartDate.addyears(1);
													
													
								if(enty.EntityEntityFiscalyears__r.size() > 0 && enty.EntityEntityFiscalyears__r[0].FiscalYearEndDate__c < tempLastCreditEndDate)
									{
										EndDatesArray.add(enty.EntityEntityFiscalyears__r[0].FiscalYearEndDate__c);
									}
								if(CalenderYearEnd1 < tempLastCreditEndDate) 
									{
										EndDatesArray.add(CalenderYearEnd1);
									}
							
							EndDatesArray.add(EstimatedCreditEndDate);
							
							CreditStartYear2 = tempLastCreditEndDate.addDays(1).year();      
							CalenderYearEnd2 = Date.newInstance(CreditStartYear2, 12, 31);
										
							if(enty.EntityEntityFiscalyears__r.size() > 1 && enty.EntityEntityFiscalyears__r[1].FiscalYearEndDate__c != null && enty.EntityEntityFiscalyears__r[1].FiscalYearEndDate__c < LastCreditEndDate)
							{
								EndDatesArray.add(enty.EntityEntityFiscalyears__r[1].FiscalYearEndDate__c);
							}
							if(CalenderYearEnd2 <= LastCreditEndDate) 
							{
								EndDatesArray.add(CalenderYearEnd2);
							}      
							
							if(enty.EntityEntityFiscalyears__r.size() > 2 && enty.EntityEntityFiscalyears__r[2].FiscalYearEndDate__c != null && enty.EntityEntityFiscalyears__r[2].FiscalYearEndDate__c < LastCreditEndDate)
							{
								EndDatesArray.add(enty.EntityEntityFiscalyears__r[2].FiscalYearEndDate__c);
							}   
									
							System.debug('CalenderYearEnd1::::' +CalenderYearEnd1);
							System.debug('CalenderYearEnd2::::' +CalenderYearEnd2);
						}								
						else
						{                                       
							CreditStartYear1 = FirstCreditStartDate.year();
							
							CalenderYearEnd1 = Date.newInstance(CreditStartYear1, 12, 31);
							
													
							if(enty.EntityEntityFiscalyears__r.size() > 0 && enty.EntityEntityFiscalyears__r[0].FiscalYearEndDate__c < LastCreditEndDate)
							{
								EndDatesArray.add(enty.EntityEntityFiscalyears__r[0].FiscalYearEndDate__c);
							}
							if(CalenderYearEnd1 < LastCreditEndDate) 
							{
								EndDatesArray.add(CalenderYearEnd1);
							}
						}
								
						EndDatesArray.add(LastCreditEndDate);
						System.debug('EndDatesArray:::' +EndDatesArray);
						EndDatesList.addall(EndDatesArray);
						
						EndDatesList.sort();
									
						System.debug('EndDatesArray:::' +EndDatesArray);
							
						System.debug('FirstCreditStartDate::::::::::'+FirstCreditStartDate);
						Date PreviousEndDate = FirstCreditStartDate.addDays(-1);
						TempCredSum = 0;
								
						// For Each EndDates obtained enter seperate Credit Record
						for (Date enddate : EndDatesList)
						{
												
							Date StartDate = PreviousEndDate.addDays(1);
							Credit__c crd = new Credit__c();
							
							crd.StartDate__c =  StartDate;
							crd.EndDate__c = enddate;
							if(Credit > 0)
							{
								if (StartDate > EstimatedCreditEndDate)
								{
									crd.CreditAmount__c = (tempSecondYrCredit / (EstimatedCreditEndDate.daysBetween(LastCreditEndDate))) * (StartDate.daysBetween(enddate)+1);
									
									//crd.CreditAmount__c = (Credit / (FirstCreditStartDate.daysBetween(LastCreditEndDate)+1)) * (StartDate.daysBetween(enddate)+1);
								}
								
								else
								{
									if(LastCreditEndDate > EstimatedCreditEndDate )
									crd.CreditAmount__c = (tempFirstYrCredit / (FirstCreditStartDate.daysBetween(EstimatedCreditEndDate)+1)) * (StartDate.daysBetween(enddate)+1);
									
									else
									crd.CreditAmount__c = (tempFirstYrCredit / (FirstCreditStartDate.daysBetween(LastCreditEndDate)+1)) * (StartDate.daysBetween(enddate)+1);
								}
								
							}
							else
							{ 
								crd.CreditAmount__c = 0; 
							}   
							TempCredSum +=  crd.CreditAmount__c;                      
							crd.ProgramCategory__c = prg.ProgramCategoryPeriod__r.ProgramCategory__c;
							crd.ProgramQualification__c = prg.ProgramQualification__c;
							crd.EmploymentPeriodGenerated__c = emp.Id;                      
							System.debug('crd.ProgramCategory__c' +crd.ProgramCategory__c);
							
							if(crd.CreditAmount__c > 0)
								lstTempCredit.add(crd);    
																			
							PreviousEndDate = enddate;
						} 
					}                
					else
					{   
								
						for(Wage__c wge : emp.Wages__r)
						{ 
							if(wge.StartDate__c >=  FirstCreditStartDate)
							{
								if(EstimatedCreditEndDate >= wge.EndDate__c)
										lstWageIds.Add(wge.Id);
										
								else if(wge.StartDate__c < EstimatedCreditEndDate && EstimatedCreditEndDate <= wge.EndDate__c)
								{
									lstWageIds.remove(wge.Id);
									System.debug('lstWageIds:::'+lstWageIds);
									List<Hour__c> hr = [Select Id,HourAmount__c from Hour__c where Wage__c =: wge.Id AND Wage__r.StartDate__c <=: EstimatedCreditEndDate AND Wage__r.EndDate__c >=: EstimatedCreditEndDate];
									
									if(hr.size() >0) 
									{
										decimal hours = hr[0].HourAmount__c;
										System.debug('hours::::'+ hours);
										
										ProratedHours = ((hours/ (wge.EndDate__c.daysBetween(wge.StartDate__c) +1)) *(EstimatedCreditEndDate.daysBetween(wge.StartDate__c) + 1));
										
										System.debug('ProratedHours::::'+ ProratedHours);
										
										TotalHours += ProratedHours;
										
										System.debug('TotalHours::::'+ TotalHours);
									}   
									break;
								}                           
							}
						}
										
						for(Hour__c hr : [Select Id,HourAmount__c from Hour__c where Wage__c in: lstWageIds])
						{
							TotalHours = TotalHours + hr.HourAmount__c;
						}
						
						// Loop thru all wages  under particular employments to get
						// Cumulative wages and Total Hours  
						for(Wage__c wge : emp.Wages__r)
						{                                
							wageDays = wge.StartDate__c.daysBetween(wge.EndDate__c) + 1; 
								
							// CumulativeDays =  CumulativeDays + wageDays;
							
							if(EstimatedCreditEndDate >= wge.EndDate__c)
							{
								CumulativeWages = CumulativeWages + wge.WageAmount__c;
								
								LastCreditEndDate = wge.EndDate__c;
								System.debug('CumulativeWages in IF::::'+ CumulativeWages);
							}							
							else if(wge.StartDate__c < EstimatedCreditEndDate && EstimatedCreditEndDate <= wge.EndDate__c)
							{
								RemainingDays = wge.StartDate__c.daysBetween(EstimatedCreditEndDate) ;
								CumulativeWages = CumulativeWages + ((wge.WageAmount__c / wageDays) * RemainingDays) ;                          
								LastCreditEndDate = FirstCreditStartDate.addDays(364);                      
								System.debug('CumulativeWages in Else::::'+ CumulativeWages);      
								break;
							}										
						}   
								
						tempCumWages = CumulativeWages;
						
						if (TotalHours >= 120 && TotalHours < 400)
						{
							if(prg.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 66.0)
							{
								if(tempCumWages > 12000)
									tempCumWages = 12000;
								
								Credit = (0.25)* tempCumWages ;
								System.debug('Qualified Veteran Credit:::' +Credit);
							}
							else if(prg.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 70.0)
							{
								if(tempCumWages > 3000)
									tempCumWages = 3000;
								
								Credit = (0.25)* tempCumWages ;
							}
							else 
							{
								if(tempCumWages > 6000)
									tempCumWages = 6000;
								
								Credit = (0.25)* tempCumWages ;
								System.debug('Credit:::' +Credit);
							}			
						}                   
						else if( TotalHours >= 400 )
						{
							System.debug('Prog Category:::' +prg.ProgramCategoryPeriod__r.ProgramCategory__r.Name);
							
							if(prg.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 66.0)
							{
								if(tempCumWages > 12000)
									tempCumWages = 12000;
								
								Credit = (0.4)* tempCumWages ;
								System.debug('Qualified veteran Credit:::' +Credit);
							}
							
							else if(prg.ProgramCategoryPeriod__r.ProgramCategory__r.ProgramCategoryEID__c == 70.0)
							{
								if(tempCumWages > 3000)
									tempCumWages = 3000;
								
								Credit = (0.4)* tempCumWages ;
							}
							
							else 
							{
								if(tempCumWages > 6000)
									tempCumWages = 6000;
								
								Credit = (0.4)* tempCumWages ;
								System.debug('Credit:::' +Credit);
							}
							
						}
									
						// Divide the periods for Credit Start Year, Fiscal Year or Calendar Year
						CreditStartYear = FirstCreditStartDate.year();
						
						CalenderYearEnd = Date.newInstance(CreditStartYear, 12, 31);
						
												
						if(enty.EntityEntityFiscalyears__r.size() > 0 && enty.EntityEntityFiscalyears__r[0].FiscalYearEndDate__c < LastCreditEndDate)
						{
							EndDatesArray.add(enty.EntityEntityFiscalyears__r[0].FiscalYearEndDate__c);
						}
						if(CalenderYearEnd < LastCreditEndDate) 
						{
							EndDatesArray.add(CalenderYearEnd);
						}
															
									
						EndDatesArray.add(LastCreditEndDate);
				
						EndDatesList.addall(EndDatesArray);
						
						EndDatesList.sort();
									
						System.debug('EndDatesArray:::' +EndDatesArray);
							
						Date PreviousEndDate = FirstCreditStartDate.addDays(-1);
						TempCredSum = 0;
									
						// For Each EndDates obtained enter seperate Credit Record
						for (Date enddate : EndDatesList)
						{
							System.debug('PreviousEndDate::))))'+PreviousEndDate);                   
							Date StartDate = PreviousEndDate.addDays(1);
							
							Credit__c crd = new Credit__c();
							
							crd.StartDate__c =  StartDate;
							crd.EndDate__c = enddate;
							if(Credit > 0)
							{
								crd.CreditAmount__c = (Credit / (FirstCreditStartDate.daysBetween(LastCreditEndDate)+1)) * (StartDate.daysBetween(enddate)+1); 
							}
							else
							{ 
								crd.CreditAmount__c = 0; 
							}   
								TempCredSum +=  crd.CreditAmount__c;                      
								crd.ProgramCategory__c = prg.ProgramCategoryPeriod__r.ProgramCategory__c;
								crd.ProgramQualification__c = prg.ProgramQualification__c;
								crd.EmploymentPeriodGenerated__c = emp.Id;                      
								System.debug('crd.ProgramCategory__c' +crd.ProgramCategory__c);
								
								if(crd.CreditAmount__c > 0)
									lstTempCredit.add(crd);    
																				
								PreviousEndDate = enddate;
						} 
									
					}
					
					System.debug('CumulativeWages::::'+ CumulativeWages);
					System.debug('TotalHours::::'+ TotalHours);
			
					System.debug('TempCredSum::::' +TempCredSum);
					
					double CredSum = 0;
					string strPositions ='';
					string qualification = '';
					for(integer Counter =lstCredit.size()-1; Counter>=0;Counter--){                     
						if(ProgramId == prg.ProgramCategoryPeriod__r.ProgramCategory__r.Program__r.ProgramEID__c){
							CredSum +=  lstCredit[Counter].CreditAmount__c;
							strPositions += Counter+';';
						}
					}
					if(mapQualCredValue.get(prg.ProgramCategoryPeriod__r.ProgramCategory__r.Program__c)!=null)
					{                                            
						if( CredSum < TempCredSum){
							if(strPositions!=''){
								for(string Pos:strPositions.split(';')){
									if(Pos!='')
										lstCredit.remove(integer.valueof(Pos));
								}
							}                           
							lstCredit.addAll(lstTempCredit);                            
						}
					}
					else
					{  
						lstCredit.addAll(lstTempCredit);                        
						mapQualCredValue.put(prg.ProgramCategoryPeriod__r.ProgramCategory__r.Program__c, TempCredSum);                        
					}
					
					System.debug('lstCredit::::' +lstCredit);    
				} 
				
				if(lstCredit.size() > 0)       
				{
					try
					{
						ProcessorControl.inFutureContext = false;
						insert lstCredit;													
					}
					catch(Exception e){}
				}
			}
		}  
	}
}