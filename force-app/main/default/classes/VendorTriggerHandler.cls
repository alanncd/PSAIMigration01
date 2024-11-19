public with sharing class VendorTriggerHandler {
    
    public static void updateVendor(List<Vendor__c> newVendorList, Map<Id, Vendor__c> oldVendorMap, Boolean isUpdate) {
        System.debug('updateVendor');
        LeftMain_SecurityUtils.checkRead(Vendor__c.SObjectType,new List<String> {
            'Id',
                'Duration__c',
                'Name',
                'Transactions__c',
                'Total_Project_Profit__c',
                'Leads__c',
                'Opportunities__c' 
                });
        Set<String> vendorsSet = new Set<String>(); 
		Set<Id> vendorsIdSet = new Set<Id>();         
        List<Vendor__c> updateVendorList = new List<Vendor__c>();
        
        LeftMain_SecurityUtils.checkRead(Period.SObjectType,new List<String> {
            'EndDate',
                'type',
                'StartDate',
                'Number'
                });
        Period currentQuarter = [SELECT EndDate,type, StartDate, Number FROM Period WHERE type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER WITH USER_MODE LIMIT 50000];

            
        sObject leadsObj = Schema.getGlobalDescribe().get('Lead').newSObject() ;
        String leadfield     = 'LeadSource';
        Set<String> leadRelatedLeadSourceValueSet = VendorTriggerHandler.getPickListValues(leadsObj,leadfield);

        sObject OpportunitysObj = Schema.getGlobalDescribe().get('Opportunity').newSObject() ;
        String Opportunityfield     = 'LeadSource';
        Set<String> OpportunityRelatedLeadSourceValueSet = VendorTriggerHandler.getPickListValues(OpportunitysObj,Opportunityfield);

        //Transaction
        Boolean trxObj1 = doesObjectExist('Transactions__c');
        String varObjectTrx='Left_Main__Transactions__c';
        String varFieldTrx='Left_Main__Lead_Source__c';
        if(trxObj1){varObjectTrx='Transactions__c';
                    varFieldTrx='Lead_Source__c';
                   }
        
        sObject TransactionssObj = Schema.getGlobalDescribe().get(varObjectTrx).newSObject() ;
        String Transactionsfield = varFieldTrx;
        Set<String> TransactionsRelatedLeadSourceValueSet = VendorTriggerHandler.getPickListValues(TransactionssObj,Transactionsfield);


        Set<String> leadSourceValueSet = new Set<String> ();
        if(leadRelatedLeadSourceValueSet.size() > 0 && !leadRelatedLeadSourceValueSet.isEmpty()){
            leadSourceValueSet.addAll(leadRelatedLeadSourceValueSet);
        }
        if(OpportunityRelatedLeadSourceValueSet.size() > 0 && !OpportunityRelatedLeadSourceValueSet.isEmpty()){
            leadSourceValueSet.addAll(OpportunityRelatedLeadSourceValueSet);
        }
        if(TransactionsRelatedLeadSourceValueSet.size() > 0 && !TransactionsRelatedLeadSourceValueSet.isEmpty()){
            leadSourceValueSet.addAll(TransactionsRelatedLeadSourceValueSet);
        }
		for(Vendor__c vendor : newVendorList) {
            String vendorName = String.isNotBlank(vendor.Vendor_Lead_Source__c) ? vendor.Vendor_Lead_Source__c.toLowerCase() : vendor.Name.toLowerCase();
            if((!(isUpdate) && vendor.Duration__c != NULL )|| (oldVendorMap != NULL && oldVendorMap.containsKey(vendor.Id) && oldVendorMap.get(vendor.Id).get('Duration__c') != vendor.Duration__c)) {
                vendorsSet.add(vendorName);
                updateVendorList.add(vendor);
				vendorsIdSet.add(vendor.Id);       
            }
        }                   
        if(vendorsSet.size() > 0) {       
            //Get total amount related to Duration Picklist
			Map<String,String> mapOfYearlyAmountMap= ExpenseTriggerHandler.getAggregatedAmountOfVendors('Yearly',vendorsIdSet);
            Map<String,String> mapOfMonthlyAmountMap = ExpenseTriggerHandler.getAggregatedAmountOfVendors('Monthly',vendorsIdSet);
            Map<String,String> mapOfQuaterlyAmountMap = ExpenseTriggerHandler.getAggregatedAmountOfVendors('Quaterly',vendorsIdSet);            
            Map<String,String> mapOfLastYearAmountMap = ExpenseTriggerHandler.getAggregatedAmountOfVendors('LastYear',vendorsIdSet);
            Map<String,String> mapOfLastQuaterAmountMap = ExpenseTriggerHandler.getAggregatedAmountOfVendors('LastQuarter',vendorsIdSet);
            Map<String,String> mapOfLastMonthAmountMap = ExpenseTriggerHandler.getAggregatedAmountOfVendors('LastMonth',vendorsIdSet);
            Map<String,String> mapOfAllTimeAmountMap = ExpenseTriggerHandler.getAggregatedAmountOfVendors('AllTime',vendorsIdSet);
            
            
            Map<String, List<AggregateResult>> leadsMap = getGroupedRecords(fetchRecords('','Lead', 'LeadSource', vendorsSet));
            Map<String, List<AggregateResult>> opportunityMap = getGroupedRecords(fetchRecords('','Opportunity', 'LeadSource', vendorsSet));
            Map<String, List<AggregateResult>> transactionMap = getGroupedRecords(fetchRecords('Sum_ProjectedAndFlipProfit__c','Transactions__c', 'Lead_Source__c', vendorsSet)); //Project_Wholesale_Profit__c
            
            
            for(Vendor__c vendor : updateVendorList) {
                String vendorName = String.isNotBlank(vendor.Vendor_Lead_Source__c) ? vendor.Vendor_Lead_Source__c.toLowerCase() : vendor.Name.toLowerCase();
                //Clear old values
                vendor.Leads__c = 0;
                vendor.Opportunities__c = 0; 
                vendor.Transactions__c = 0;
                vendor.Total_Project_Profit__c = 0;
                // find Lead, Opportunities and Transactions Count
                if(vendor.Duration__c == 'Monthly') {
                    
                    if(leadsMap.containsKey(vendorName)) {
                        RecordWrapper record = getMonthlyRecordCount(leadsMap.get(vendorName), false);
                        vendor.Leads__c = record.count;
                    } 
                    
                    if(opportunityMap.containsKey(vendorName)) {
                        RecordWrapper record = getMonthlyRecordCount(opportunityMap.get(vendorName), false);
                        vendor.Opportunities__c = record.count;
                    }
                    
                    if(transactionMap.containsKey(vendorName)) {
                        RecordWrapper record = getMonthlyRecordCount(transactionMap.get(vendorName), true);
                        vendor.Transactions__c = record.count;
                        if(record.count > 0)
                            vendor.Total_Project_Profit__c = record.profit;// / record.count;
                    }
                    vendor.Total_Cost_Duration__c = mapOfMonthlyAmountMap.get(String.valueOf(vendor.Id)) != null ? Decimal.valueOf(mapOfMonthlyAmountMap.get(String.valueOf(vendor.Id))) : 0;
                } else if(vendor.Duration__c == 'Quarterly') {
                    
                    if(leadsMap.containsKey(vendorName)) {
                        RecordWrapper record = getQuarterlyRecordCount(currentQuarter.Number, leadsMap.get(vendorName), false);
                        vendor.Leads__c = record.count;
                    } 
                    
                    if(opportunityMap.containsKey(vendorName)) {
                        RecordWrapper record = getQuarterlyRecordCount(currentQuarter.Number, opportunityMap.get(vendorName), false);
                        vendor.Opportunities__c = record.count;
                    } 
                    
                    if(transactionMap.containsKey(vendorName)) {
                        RecordWrapper record = getQuarterlyRecordCount(currentQuarter.Number, transactionMap.get(vendorName), true);
                        vendor.Transactions__c = record.count;
                        if(record.count > 0)
                            vendor.Total_Project_Profit__c = record.profit;// / record.count;
                    } 
					vendor.Total_Cost_Duration__c = mapOfQuaterlyAmountMap.get(String.valueOf(vendor.Id)) != null ? Decimal.valueOf(mapOfQuaterlyAmountMap.get(String.valueOf(vendor.Id))) : 0;                    
                } else if(vendor.Duration__c == 'Yearly') {
                    
                    if(leadsMap.containsKey(vendorName)) {
                        RecordWrapper record = getYearlyRecordCount(leadsMap.get(vendorName), false);
                        vendor.Leads__c = record.count;
                    }
                    
                    if(opportunityMap.containsKey(vendorName)) {
                        RecordWrapper record = getYearlyRecordCount(opportunityMap.get(vendorName), false);  
                        vendor.Opportunities__c = record.count;    
                    }
                    
                    if(transactionMap.containsKey(vendorName)) {
                        RecordWrapper record = getYearlyRecordCount(transactionMap.get(vendorName), true);
                        vendor.Transactions__c = record.count;
                        if(record.count > 0)
                            vendor.Total_Project_Profit__c = record.profit;// / record.count;
                    }
					vendor.Total_Cost_Duration__c = mapOfYearlyAmountMap.get(String.valueOf(vendor.Id)) != null ? Decimal.valueOf(mapOfYearlyAmountMap.get(String.valueOf(vendor.Id))) : 0;                    
                }else if(vendor.Duration__c == 'Last Year'){
                    vendor.Total_Cost_Duration__c = mapOfLastYearAmountMap.get(String.valueOf(vendor.Id)) != null ? Decimal.valueOf(mapOfLastYearAmountMap.get(String.valueOf(vendor.Id))) : 0;                    
                    if(leadsMap.containsKey(vendorName)) {
                        RecordWrapper record = getLastYearRecordCount(leadsMap.get(vendorName), false);
                        vendor.Leads__c = record.count;
                    }          
                    if(opportunityMap.containsKey(vendorName)) {
                        RecordWrapper record = getLastYearRecordCount(opportunityMap.get(vendorName), false);  
                        vendor.Opportunities__c = record.count;    
                    }
                    
                    if(transactionMap.containsKey(vendorName)) {
                        RecordWrapper record = getLastYearRecordCount(transactionMap.get(vendorName), true);
                        vendor.Transactions__c = record.count;
                        if(record.count > 0)
                            vendor.Total_Project_Profit__c = record.profit;// / record.count;  
                    }
                } 
                else if(vendor.Duration__c == 'Last Quarter'){

                    if(leadsMap.containsKey(vendorName)) {
                        RecordWrapper record = getLastQuarterRecordCount(currentQuarter.Number, leadsMap.get(vendorName), false);
                        vendor.Leads__c = record.count;
                    } 
                    
                    if(opportunityMap.containsKey(vendorName)) {
                        RecordWrapper record = getLastQuarterRecordCount(currentQuarter.Number, opportunityMap.get(vendorName), false);
                        vendor.Opportunities__c = record.count;
                    } 
                    
                    if(transactionMap.containsKey(vendorName)) {
                        RecordWrapper record = getLastQuarterRecordCount(currentQuarter.Number, transactionMap.get(vendorName), true);
                        vendor.Transactions__c = record.count;
                        if(record.count > 0)
                            vendor.Total_Project_Profit__c = record.profit;
                    } 
                    vendor.Total_Cost_Duration__c = mapOfLastQuaterAmountMap.get(String.valueOf(vendor.Id)) != null ? Decimal.valueOf(mapOfLastQuaterAmountMap.get(String.valueOf(vendor.Id))) : 0;                    
                }
                else if(vendor.Duration__c == 'Last Month'){
                     // Last Month
                    if(leadsMap.containsKey(vendorName)) {
                        RecordWrapper record = getLastMonthRecordCount(leadsMap.get(vendorName), false);
                        vendor.Leads__c = record.count;
                    } 
                    
                    if(opportunityMap.containsKey(vendorName)) {
                        RecordWrapper record = getLastMonthRecordCount(opportunityMap.get(vendorName), false);
                        vendor.Opportunities__c = record.count;
                    } 
                    
                    if(transactionMap.containsKey(vendorName)) {
                        RecordWrapper record = getLastMonthRecordCount(transactionMap.get(vendorName), true);
                        vendor.Transactions__c = record.count;
                        if(record.count > 0)
                            vendor.Total_Project_Profit__c = record.profit; // record.count;
                    } 
                    vendor.Total_Cost_Duration__c = mapOfLastMonthAmountMap.get(String.valueOf(vendor.Id)) != null ? Decimal.valueOf(mapOfLastMonthAmountMap.get(String.valueOf(vendor.Id))) : 0;                    
                }                
                else if(vendor.Duration__c == 'All Time'){
                    system.debug('vendor.Duration__cvendor.Duration__c'+vendor.Duration__c);
                     // All Time
                    if(leadsMap.containsKey(vendorName)) {
                        RecordWrapper record = getAlTimeRecordCount(leadsMap.get(vendorName), false);
                        vendor.Leads__c = record.count;
                    } 
                    
                    if(opportunityMap.containsKey(vendorName)) {
                        RecordWrapper record = getAlTimeRecordCount(opportunityMap.get(vendorName), false);
                        vendor.Opportunities__c = record.count;
                    } 
                    	
                    if(transactionMap.containsKey(vendorName)) {
                        RecordWrapper record = getAlTimeRecordCount(transactionMap.get(vendorName), true);
                        vendor.Transactions__c = record.count;
                        if(record.count > 0)
                            vendor.Total_Project_Profit__c = record.profit;
                    } 
                    vendor.Total_Cost_Duration__c = mapOfAllTimeAmountMap.get(String.valueOf(vendor.Id)) != null ? Decimal.valueOf(mapOfAllTimeAmountMap.get(String.valueOf(vendor.Id))) : 0;                    
                }                
            }
        }
    }
    
    // This method will group record by lead source, calender month, calander quarter and calander year
    public static List<AggregateResult> fetchRecords(String profitField, String objectName, String leadSource, Set<String> vendorNames) {
        //Here we will modify the Start Date according the Customer
		String CreatedDateField='CreatedDate'; //Default Value
        VendorDynamicFields__c setting = VendorDynamicFields__c.getOrgDefaults();
        if (setting <> null){
        	if(objectName=='Opportunity'){
	            if(VendorDynamicFields__c.getOrgDefaults().OpportunityCreatedDate__c<>NULL){CreatedDateField=VendorDynamicFields__c.getOrgDefaults().OpportunityCreatedDate__c;}
	        }else if(objectName=='Transactions__c'){
	            if(VendorDynamicFields__c.getOrgDefaults().TransactionCreatedDate__c<>NULL){CreatedDateField=VendorDynamicFields__c.getOrgDefaults().TransactionCreatedDate__c;}
	        }else{
                if(VendorDynamicFields__c.getOrgDefaults().LeadCreatedDate__c<>NULL){CreatedDateField=VendorDynamicFields__c.getOrgDefaults().LeadCreatedDate__c;}
	        }
         }

        String query = 'SELECT Count(ID) ct, CALENDAR_YEAR('+CreatedDateField+') cy, CALENDAR_MONTH('+CreatedDateField+') cm, '+leadSource+' ls,CALENDAR_QUARTER('+CreatedDateField+') cq';
        if(String.isNotBlank(profitField)) {
            query = query + ', SUM('+profitField+') pr';
        } 
        List<AggregateResult> recordList = Database.query(string.escapeSingleQuotes(query+' FROM '+objectName+' WHERE '+leadSource+' IN : vendorNames GROUP BY '+leadSource+', CALENDAR_YEAR('+CreatedDateField+'), CALENDAR_MONTH('+CreatedDateField+'), CALENDAR_QUARTER('+CreatedDateField+') LIMIT 50000'));
        return recordList;
    }
    
    
    public static Map<String, List<AggregateResult>> getGroupedRecords(List<AggregateResult> aggregatesList) {
        Map<String, List<AggregateResult>> groupedRecordsMap = new Map<String, List<AggregateResult>>();
        for(AggregateResult record : aggregatesList) {
            if(groupedRecordsMap.containsKey(String.valueOf(record.get('ls')).toLowerCase())) {
                List<AggregateResult> values = groupedRecordsMap.get(String.valueOf(record.get('ls')).toLowerCase());
                values.add(record);
                groupedRecordsMap.put(String.valueOf(record.get('ls')).toLowerCase(), values);
            } else {
                groupedRecordsMap.put(String.valueOf(record.get('ls')).toLowerCase(), new List<AggregateResult>{record});
            }            
        }
        return groupedRecordsMap;
    }
    
    // This method will get current monthly record count for Transaction
    public static RecordWrapper getMonthlyRecordCount(List<AggregateResult> aggregateList, Boolean getProfit) {
        RecordWrapper record = new RecordWrapper();
        for(AggregateResult monthlyRec : aggregateList) {
            if(Integer.valueOf(monthlyRec.get('cm')) == System.today().month() && Integer.valueOf(monthlyRec.get('cy'))==System.today().year()) {
                record.count = record.count + Integer.valueOf(monthlyRec.get('ct'));
                if(getProfit){
                    record.profit = record.profit + (Decimal)monthlyRec.get('pr');
                }
            }            
        }
        return record;
    }
    
    // This method will get current quarterly record count for records
    public static RecordWrapper getQuarterlyRecordCount(Integer currentQuarter, List<AggregateResult> aggregateList, Boolean getProfit) {
        RecordWrapper record = new RecordWrapper();
        for(AggregateResult quarterlyRec : aggregateList) {
            if(currentQuarter == Integer.valueOf(quarterlyRec.get('cq')) && Integer.valueOf(quarterlyRec.get('cy'))==System.today().year() ) {
                record.count = record.count + Integer.valueOf(quarterlyRec.get('ct'));
                if(getProfit){
                    record.profit = record.profit + (Decimal)quarterlyRec.get('pr');
                }
            }            
        }
        return record;
    }
    
    // This method will get current yearly record count for records
    public static RecordWrapper getYearlyRecordCount(List<AggregateResult> aggregateList, Boolean getProfit) {
        RecordWrapper record = new RecordWrapper();
        for(AggregateResult yearlyRec : aggregateList) {
            if(System.today().year() == Integer.valueOf(yearlyRec.get('cy'))) {
            record.count = record.count + Integer.valueOf(yearlyRec.get('ct'));
            if(getProfit){
                record.profit = record.profit + (Decimal)yearlyRec.get('pr');
            }
           }
        }
        return record;
    }
    // This method will get All Time record count for records
    public static RecordWrapper getAlTimeRecordCount(List<AggregateResult> aggregateList, Boolean getProfit) {
        //ALL TIME 
        //aggregateList
        system.debug('aggregateListaggregateList'+aggregateList);
        RecordWrapper record = new RecordWrapper();
        for(AggregateResult yearlyRec : aggregateList) {
            record.count = record.count + Integer.valueOf(yearlyRec.get('ct'));
            if(getProfit){
                record.profit = record.profit + (Decimal)yearlyRec.get('pr');
            }
        }
        return record;
    }    
    // This method will get Last month record count for Transaction 22/6/22
    public static RecordWrapper getLastMonthRecordCount(List<AggregateResult> aggregateList, Boolean getProfit) {
        Integer lastMonth=System.today().month();
        Integer yearTosearch=System.today().year();
        if(System.today().month()==1){lastMonth=12;
        }else{lastMonth=System.today().month()-1;
		}
        RecordWrapper record = new RecordWrapper();
        for(AggregateResult monthlyRec : aggregateList) {
            if(Integer.valueOf(monthlyRec.get('cm')) == lastMonth && Integer.valueOf(monthlyRec.get('cy'))==yearTosearch) {
                record.count = record.count + Integer.valueOf(monthlyRec.get('ct'));
                if(getProfit){
                    record.profit = record.profit + (Decimal)monthlyRec.get('pr');
                }
            }            
        }
        return record;
    }    
    // This method will get last quarter
        public static RecordWrapper getLastQuarterRecordCount(Integer currentQuarter, List<AggregateResult> aggregateList, Boolean getProfit) {
        RecordWrapper record = new RecordWrapper();
            Integer lastQuarter=0;
            Integer yearTosearch=0;
            if(currentQuarter==1){lastQuarter=4;
                                  yearTosearch=System.today().year()-1; 
            }else{lastQuarter=currentQuarter-1;
                  yearTosearch=System.today().year();
                 }

        for(AggregateResult quarterlyRec : aggregateList) {
            if(lastQuarter == Integer.valueOf(quarterlyRec.get('cq')) && Integer.valueOf(quarterlyRec.get('cy'))==yearTosearch ) {
                record.count = record.count + Integer.valueOf(quarterlyRec.get('ct'));
                if(getProfit){
                    record.profit = record.profit + (Decimal)quarterlyRec.get('pr');
                }
            }            
        }
        return record;
        }
    // This method will get last year
        public static RecordWrapper getLastYearRecordCount(List<AggregateResult> aggregateList, Boolean getProfit) {
        RecordWrapper record = new RecordWrapper();
        for(AggregateResult lastYearRec : aggregateList) {
            if(Integer.valueOf(lastYearRec.get('cy')) == (System.today().year()-1)) {
                record.count = record.count + Integer.valueOf(lastYearRec.get('ct'));
                if(getProfit){
                    record.profit = record.profit + (Decimal)lastYearRec.get('pr');
                }
            }            
        }
        return record;
    } 
    public Class RecordWrapper {
        public Integer count = 0;
        public Decimal profit = 0;
    }

    public static Set <String> getPickListValues(sObject objObject, string fld) {
		Set<String > options = new Set<String >  ();
		Schema.sObjectType objType = objObject.getSObjectType();
		Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
		Map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
		List < Schema.PicklistEntry > values = fieldMap.get(fld).getDescribe().getPickListValues();

		for (Schema.PicklistEntry f: values) {
			options.add(f.getLabel());
		}
		
		System.debug(options);
		if (options.isEmpty()) {
			return null;
		} else {
			return options;
		}
	}
     // Method to check if an object exists
    public static Boolean doesObjectExist(String objectApiName) {
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        return globalDescribe.containsKey(objectApiName);
    }

}