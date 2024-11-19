public with sharing class ExpenseTriggerHandler {
    public static Boolean flag = true;
    
    public static void updateExpenses(List<Expense__c> newVendorList) {

        // Validate Read and Update permissions before proceeding
    if (!Schema.sObjectType.Vendor__c.isUpdateable() || 
    !Schema.sObjectType.Vendor__c.isAccessible() ||
    !Schema.sObjectType.Vendor__c.fields.Duration__c.isAccessible() || 
    !Schema.sObjectType.Vendor__c.fields.Total_Cost_Duration__c.isUpdateable()) {
        throw new AuraHandledException('The user doesn\'t have the appropriate permissions to perform this operation.');
        
    }

        Map<Id,List<Expense__c>> mapOfVendersWithExpenses = new Map<Id,List<Expense__c>>();
        Map<Vendor__c,String> mapOfVendersWithDuration = new Map<Vendor__c,String>();
        for(expense__c expence : newVendorList){
            if(!mapOfVendersWithExpenses.containsKey(expence.Payee__c)){
                mapOfVendersWithExpenses.put(expence.Payee__c,new List<Expense__c>{expence});
            }else{
                mapOfVendersWithExpenses.get(expence.Payee__c).add(expence);
            }  
        }
        Map<String,String> mapOfYearlyDuration = getAggregatedAmountOfVendors('Yearly',mapOfVendersWithExpenses.KeySet());
        Map<String,String> mapOfMonthlyDuration = getAggregatedAmountOfVendors('Monthly',mapOfVendersWithExpenses.KeySet());
        Map<String,String> mapOfQuaterlyDuration = getAggregatedAmountOfVendors('Quaterly',mapOfVendersWithExpenses.KeySet());
        Map<String,String> mapOfLastYearDuration = getAggregatedAmountOfVendors('LastYear',mapOfVendersWithExpenses.KeySet());
        Map<String,String> mapOfLastQuarterDuration = getAggregatedAmountOfVendors('LastQuarter',mapOfVendersWithExpenses.KeySet());
        Map<String,String> mapOfLastMonthDuration = getAggregatedAmountOfVendors('LastMonth',mapOfVendersWithExpenses.KeySet());
        Map<String,String> mapOfAllTimeDuration = getAggregatedAmountOfVendors('AllTime',mapOfVendersWithExpenses.KeySet());
        
        for(Vendor__c vendor : [SELECT Id,Duration__c FROM Vendor__c WHERE Id IN : mapOfVendersWithExpenses.KeySet() WITH SECURITY_ENFORCED]){
            system.debug('vendor '+vendor);
            if(!mapOfVendersWithDuration.containsKey(vendor)){
                
                mapOfVendersWithDuration.put(vendor,vendor.Duration__c);
            }
        }
        for(Vendor__c vendor : mapOfVendersWithDuration.KeySet()){
            system.debug('mapOfVendersWithDuration.get(vendor)'+mapOfVendersWithDuration.get(vendor));
            if(mapOfVendersWithDuration.get(vendor) == 'Yearly'){
                vendor.Total_Cost_Duration__c = mapOfYearlyDuration.get(String.valueOf(vendor.Id)) != null ? Decimal.valueOf(mapOfYearlyDuration.get(String.valueOf(vendor.Id))) : 0;   
            }
            else if(mapOfVendersWithDuration.get(vendor) == 'Monthly'){
                vendor.Total_Cost_Duration__c = mapOfMonthlyDuration.get(String.valueOf(vendor.Id)) != null ? Decimal.valueOf(mapOfMonthlyDuration.get(String.valueOf(vendor.Id))) : 0; 
            }
            else if(mapOfVendersWithDuration.get(vendor) == 'Quarterly'){
                vendor.Total_Cost_Duration__c = mapOfQuaterlyDuration.get(String.valueOf(vendor.Id)) != null ? Decimal.valueOf(mapOfQuaterlyDuration.get(String.valueOf(vendor.Id))) : 0;
            }
            else if(mapOfVendersWithDuration.get(vendor) == 'Last Month'){
                vendor.Total_Cost_Duration__c = mapOfLastMonthDuration.get(String.valueOf(vendor.Id)) != null ? Decimal.valueOf(mapOfLastMonthDuration.get(String.valueOf(vendor.Id))) : 0;
            }                        
            else if(mapOfVendersWithDuration.get(vendor) == 'Last Quarter'){
                vendor.Total_Cost_Duration__c = mapOfLastQuarterDuration.get(String.valueOf(vendor.Id)) != null ? Decimal.valueOf(mapOfLastQuarterDuration.get(String.valueOf(vendor.Id))) : 0;
            }              
            else if(mapOfVendersWithDuration.get(vendor) == 'Last Year'){
                vendor.Total_Cost_Duration__c = mapOfLastYearDuration.get(String.valueOf(vendor.Id)) != null ? Decimal.valueOf(mapOfLastYearDuration.get(String.valueOf(vendor.Id))) : 0;
            }  
            else if(mapOfVendersWithDuration.get(vendor) == 'All Time'){
                vendor.Total_Cost_Duration__c = mapOfAllTimeDuration.get(String.valueOf(vendor.Id)) != null ? Decimal.valueOf(mapOfAllTimeDuration.get(String.valueOf(vendor.Id))) : 0;
            }
            else{
                vendor.Total_Cost_Duration__c = 0;
            }
        }
        List<Vendor__c> listToUpdate = new List<Vendor__c>(mapOfVendersWithDuration.KeySet());
        flag = false;
        if(listToUpdate.size() > 0){
            update listToUpdate;
        }
    }
    // To Return Map Of Vendor With AggregateResult 
    public static Map<String,String> getAggregatedAmountOfVendors(String duration,Set<Id> setOfVendors){
        List<AggregateResult> aggregatedAmount = new List<AggregateResult>();
        Map<String,String> mapOfVendorWithResult = new Map<String,String>();
        if(duration == 'Yearly'){
            Integer currentYear =  System.Today().year();
            aggregatedAmount  = [SELECT SUM(Total_Amount__c) total,Payee__c Id FROM expense__c WHERE Payee__c IN : setOfVendors AND CALENDAR_YEAR(Date__c) =: currentYear WITH USER_MODE GROUP BY Payee__c];           
        }
        else if(duration == 'Monthly'){
            Integer currentYear =  System.Today().year();
            Integer currentMonth = System.Today().Month();
            aggregatedAmount  = [SELECT SUM(Total_Amount__c) total,Payee__c Id FROM expense__c WHERE Payee__c IN : setOfVendors AND CALENDAR_Month(Date__c) =: currentMonth  AND CALENDAR_YEAR(Date__c) =: currentYear WITH USER_MODE GROUP BY Payee__c];
        }
        else if(duration=='LastYear'){
            Integer lastYear =  System.Today().year() -1;
            system.debug('Last Year'+lastYear);
			aggregatedAmount  = [SELECT SUM(Total_Amount__c) total,Payee__c Id FROM expense__c WHERE Payee__c IN : setOfVendors AND CALENDAR_YEAR(Date__c) = :lastYear WITH USER_MODE  GROUP BY Payee__c];            
            System.debug('Result Year:>:'+aggregatedAmount);
        }
        else if(duration=='LastQuarter'){
            Integer currentYear =  System.Today().year();
            Integer lastYear =  System.Today().year() -1;
            Integer searchYear=0;
            Integer quarter = date.today().month()/3;
            Integer lastquarter=0;
            if(quarter==0){
                lastquarter=4;
                searchYear=lastYear;
            }else{
                lastquarter=quarter;
                searchYear=currentYear;                
            }
            system.debug('LastQuarter: '+lastquarter+' & Last Year: '+searchYear);
			aggregatedAmount  = [SELECT SUM(Total_Amount__c) total,Payee__c Id FROM expense__c WHERE Payee__c IN : setOfVendors AND CALENDAR_QUARTER(Date__c) =: lastquarter  AND CALENDAR_YEAR(Date__c) =: searchYear WITH USER_MODE GROUP BY Payee__c];            
            System.debug('Result Quarter:>:'+aggregatedAmount);
        }
        else if(duration=='LastMonth'){
            Integer currentYear =  System.Today().year();
            Integer lastYear =  System.Today().year() -1;
            Integer searchYear=0;
            Integer month = date.today().month();
            Integer lastmonth=0;
            if(month==1){
                lastmonth=12;
                searchYear=lastYear;
            }else{
                lastmonth=month-1;
                searchYear=currentYear;                
            }
            system.debug('LastMonth: '+lastmonth+' & Last Year: '+searchYear);
			aggregatedAmount  = [SELECT SUM(Total_Amount__c) total,Payee__c Id FROM expense__c WHERE Payee__c IN : setOfVendors AND CALENDAR_Month(Date__c) =: lastmonth  AND CALENDAR_YEAR(Date__c) =: searchYear WITH USER_MODE GROUP BY Payee__c];            
            System.debug('Result LastMonth:>:'+aggregatedAmount);
        }
        else if(duration=='AllTime'){
			aggregatedAmount  = [SELECT SUM(Total_Amount__c) total,Payee__c Id FROM expense__c WHERE Payee__c IN : setOfVendors WITH USER_MODE GROUP BY Payee__c];            
            System.debug('Result All Time:>:'+aggregatedAmount);
        }        
        else{
            aggregatedAmount  = [SELECT SUM(Total_Amount__c) total,Payee__c Id FROM expense__c WHERE Payee__c IN : setOfVendors AND Date__c = THIS_FISCAL_QUARTER WITH USER_MODE  GROUP BY Payee__c];
        }
        for(AggregateResult record : aggregatedAmount) {
            if(!mapOfVendorWithResult.containsKey(String.valueOf(record.get('Id')))){
                mapOfVendorWithResult.put(String.valueOf(record.get('Id')),String.valueOf(record.get('total')));
            }
        }
        system.debug('>>>>>>>>>>>>'+mapOfVendorWithResult);
        return mapOfVendorWithResult;
    }
    
}