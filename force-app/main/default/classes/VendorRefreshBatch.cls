public with sharing class VendorRefreshBatch implements Database.Batchable<sObject>, Schedulable {
  public Database.QueryLocator start(Database.BatchableContext BC) {
    LeftMain_SecurityUtils.checkRead(
      Vendor__c.SObjectType,
      new List<String>{
        'Id',
        'Name',
        'Transactions__c',
        'Total_Project_Profit__c',
        'Leads__c',
        'Opportunities__c',
        'Vendor_Lead_Source__c'
      }
    );
    return Database.getQueryLocator(
      'SELECT Id, Duration__c, Name,Vendor_Lead_Source__c, Transactions__c, Total_Project_Profit__c, Leads__c, Opportunities__c FROM Vendor__c  LIMIT 5000000'
    );
  }

  public void execute(Database.BatchableContext BC, List<Vendor__c> scope) {
    try {
      refreshRecords(scope);
    } catch (Exception e) {
      System.debug('log');
    }
  }

  public void finish(Database.BatchableContext BC) {
  }

  public void refreshRecords(List<Vendor__c> vendorList) {
    Set<String> vendorsSet = new Set<String>();
    List<Vendor__c> vendorListToUpdate = new List<Vendor__c>();

    LeftMain_SecurityUtils.checkRead(
      Period.SObjectType,
      new List<String>{ 'EndDate', 'type', 'StartDate', 'Number' }
    );
    Period currentQuarter = [
      SELECT EndDate, type, StartDate, Number
      FROM Period
      WHERE type = 'Quarter' AND StartDate = THIS_FISCAL_QUARTER
      LIMIT 50000
    ];

    LeftMain_SecurityUtils.checkRead(
      Vendor__c.SObjectType,
      new List<String>{
        'Id',
        'Duration__c',
        'Name',
        'Transactions__c',
        'Total_Project_Profit__c',
        'Leads__c',
        'Opportunities__c'
      }
    );

    for (Vendor__c vendor : vendorList) {
      String vendorName = String.isNotBlank(vendor.Vendor_Lead_Source__c)
        ? vendor.Vendor_Lead_Source__c.toLowerCase()
        : vendor.Name.toLowerCase();
      vendorsSet.add(vendorName);
    }
    // Update Vendor field values.
    if (vendorsSet.size() > 0) {
      Map<String, List<AggregateResult>> leadsMap = VendorTriggerHandler.getGroupedRecords(
        VendorTriggerHandler.fetchRecords('', 'Lead', 'LeadSource', vendorsSet)
      );
      Map<String, List<AggregateResult>> opportunityMap = VendorTriggerHandler.getGroupedRecords(
        VendorTriggerHandler.fetchRecords(
          '',
          'Opportunity',
          'LeadSource',
          vendorsSet
        )
      );
      Map<String, List<AggregateResult>> transactionMap = VendorTriggerHandler.getGroupedRecords(
        VendorTriggerHandler.fetchRecords(
          'Project_Wholesale_Profit__c',
          'Transactions__c',
          'Lead_Source__c',
          vendorsSet
        )
      );

      for (Vendor__c vendor : vendorList) {
        Boolean flag = false;
        String vendorName = String.isNotBlank(vendor.Vendor_Lead_Source__c)
          ? vendor.Vendor_Lead_Source__c.toLowerCase()
          : vendor.Name.toLowerCase();
        if (vendor.Duration__c == 'Monthly') {
          if (leadsMap.containsKey(vendorName)) {
            VendorTriggerHandler.RecordWrapper record = VendorTriggerHandler.getMonthlyRecordCount(
              leadsMap.get(vendorName),
              false
            );
            if (vendor.Leads__c != record.count) {
              vendor.Leads__c = record.count;
              flag = true;
            }
          }
          if (opportunityMap.containsKey(vendorName)) {
            VendorTriggerHandler.RecordWrapper record = VendorTriggerHandler.getMonthlyRecordCount(
              opportunityMap.get(vendorName),
              false
            );
            if (vendor.Opportunities__c != record.count) {
              vendor.Opportunities__c = record.count;
              flag = true;
            }
          }

          if (transactionMap.containsKey(vendorName)) {
            VendorTriggerHandler.RecordWrapper record = VendorTriggerHandler.getMonthlyRecordCount(
              transactionMap.get(vendorName),
              true
            );
            if (vendor.Transactions__c != record.count) {
              vendor.Transactions__c = record.count;
              vendor.Total_Project_Profit__c = record.profit / record.count;
              flag = true;
            }
          }
        } else if (vendor.Duration__c == 'Quarterly') {
          if (leadsMap.containsKey(vendorName)) {
            VendorTriggerHandler.RecordWrapper record = VendorTriggerHandler.getQuarterlyRecordCount(
              currentQuarter.Number,
              leadsMap.get(vendorName),
              false
            );
            if (vendor.Leads__c != record.count) {
              vendor.Leads__c = record.count;
              flag = true;
            }
          }

          if (opportunityMap.containsKey(vendorName)) {
            VendorTriggerHandler.RecordWrapper record = VendorTriggerHandler.getQuarterlyRecordCount(
              currentQuarter.Number,
              opportunityMap.get(vendorName),
              false
            );
            if (vendor.Opportunities__c != record.count) {
              vendor.Opportunities__c = record.count;
              flag = true;
            }
          }

          if (transactionMap.containsKey(vendorName)) {
            VendorTriggerHandler.RecordWrapper record = VendorTriggerHandler.getQuarterlyRecordCount(
              currentQuarter.Number,
              transactionMap.get(vendorName),
              true
            );
            if (vendor.Transactions__c != record.count) {
              vendor.Transactions__c = record.count;
              vendor.Total_Project_Profit__c = record.profit / record.count;
              flag = true;
            }
          }
        } else if (vendor.Duration__c == 'Yearly') {

          if (leadsMap.containsKey(vendorName)) {
            VendorTriggerHandler.RecordWrapper record = VendorTriggerHandler.getYearlyRecordCount(
              leadsMap.get(vendorName),
              false
            );
            if (vendor.Leads__c != record.count) {
              vendor.Leads__c = record.count;
              flag = true;
            }
          }

          if (opportunityMap.containsKey(vendorName)) {
            VendorTriggerHandler.RecordWrapper record = VendorTriggerHandler.getYearlyRecordCount(
              opportunityMap.get(vendorName),
              false
            );
            if (vendor.Opportunities__c != record.count) {
              vendor.Opportunities__c = record.count;
              flag = true;
            }
          }

          if (transactionMap.containsKey(vendorName)) {
            VendorTriggerHandler.RecordWrapper record = VendorTriggerHandler.getYearlyRecordCount(
              transactionMap.get(vendorName),
              true
            );
            if (vendor.Transactions__c != record.count) {
              vendor.Transactions__c = record.count;
              vendor.Total_Project_Profit__c = record.profit / record.count;
              flag = true;
            }
          }
        }
        if (
          vendor.Duration__c == null ||
          !transactionMap.containsKey(vendorName) ||
          !opportunityMap.containsKey(vendorName) ||
          !leadsMap.containsKey(vendorName)
        ) {
          if (
            vendor.Leads__c != 0 &&
            (vendor.Duration__c == null || !leadsMap.containsKey(vendorName))
          ) {
            vendor.Leads__c = 0;
            flag = true;
          }
          if (
            vendor.Opportunities__c != 0 &&
            (vendor.Duration__c == null ||
            !opportunityMap.containsKey(vendorName))
          ) {
            vendor.Opportunities__c = 0;
            flag = true;
          }
          if (
            vendor.Transactions__c != 0 &&
            (vendor.Duration__c == null ||
            !transactionMap.containsKey(vendorName))
          ) {
            vendor.Transactions__c = 0;
            vendor.Total_Project_Profit__c = 0;
            flag = true;
          }
        }
        if (flag) {
          vendorListToUpdate.add(vendor);
        }
      }
    }

    if (vendorListToUpdate.size() > 0) {


      LeftMain_SecurityUtils.checkUpdate(
        Vendor__c.SObjectType,
        new List<String>{
          'Duration__c',
          'Name',
          'Transactions__c',
          'Total_Project_Profit__c',
          'Leads__c',
          'Opportunities__c'
        }
      );

      SObjectAccessDecision decision2 = Security.stripInaccessible(AccessType.UPDATABLE, vendorListToUpdate);
      List<Database.SaveResult> myResult = Database.update(vendorListToUpdate = decision2.getRecords(),AccessLevel.System_mode);
    }
  }

  public void execute(SchedulableContext sc) {
    VendorRefreshBatch batch = new VendorRefreshBatch();
    Database.executeBatch(batch, 200);
  }
}