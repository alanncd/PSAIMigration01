public with sharing class QuickBooksController implements Schedulable {
  private static QuickBooks_Config__mdt QuickBooksMTDT = FetchQuickBookDetail();
  public static String org_Id = QuickBooksMTDT.Org_Id__c;
  public static Double minorVersion = QuickBooksMTDT.Minor_Version__c;
  public static String accountName = QuickBooksMTDT.Account_Name__c;

  // Get quick book detail from metadata
 
  private static QuickBooks_Config__mdt FetchQuickBookDetail() {
    LeftMain_SecurityUtils.checkRead(
      QuickBooks_Config__mdt.SObjectType,
      new List<String>{
        'Org_Id__c',
        'Label',
        'Minor_Version__c',
        'Account_Name__c'
      }
    );
    String qbName = Test.isRunningTest()
      ? 'QuickBooks Config Demo'
      : 'QuickBooks Config';
    QuickBooks_Config__mdt QuickBooksMTDT = [
      SELECT Org_Id__c, Minor_Version__c, Account_Name__c
      FROM QuickBooks_Config__mdt
      WHERE Label = :qbName
      WITH USER_MODE
      LIMIT 1
    ];
    return QuickBooksMTDT;
  }
  //To get purchase from QuickBook
  public static PurchaseWrapper getPurchase(String daysbefore) {

    String qry = '';
    if (daysbefore != 'LastQuarter' && daysbefore != 'CurrentQuarter') {
      String LastUpdatedTime = String.valueOf(
        Date.today().addDays(Integer.valueOf(daysbefore))
      );

      //string qry = EncodingUtil.urlEncode('select * from Purchase where MetaData.LastUpdatedTime > \'2020-09-19T15:28:48-05:00\'', 'UTF-8');
      qry = EncodingUtil.urlEncode(
        'select * from Purchase where MetaData.LastUpdatedTime > \'' +
          LastUpdatedTime +
          '\' STARTPOSITION 1 MAXRESULTS 1000 ',
        'UTF-8'
      );
    } else if (daysbefore == 'LastQuarter') {
      qry = querylastquarter();
    } else if (daysbefore == 'CurrentQuarter') {
      qry = currentQuarterQuery();
    }
    String url =
      'callout:QuickBooks/v3/company/' +
      org_Id +
      '/query?query=' +
      qry +
      '&minorversion=\'' +
      minorVersion +
      '\'';
    Map<String, String> headersMap = new Map<String, String>();
    headersMap.put('Accept', 'application/json');
    HttpResponse response = QuickBooksServiceClass.makeHttpRequest(
      url,
      'GET',
      headersMap,
      ''
    );
    PurchaseWrapper purchaseWrapObj = new PurchaseWrapper();
    if (response == null) {
      return purchaseWrapObj;
    }
    if (response.getStatusCode() == 200) {
      purchaseWrapObj = (PurchaseWrapper) JSON.deserialize(
        response.getBody(),
        PurchaseWrapper.class
      );
    }
    purchaseWrapObj.status = String.valueOf(response.getStatusCode());
    return purchaseWrapObj;
  }
  public static String getVendorsAndExpensesReuSed(String days) {
    //Map<String, Vendor__c> vendorsMaptoInsert = new Map<String, Vendor__c>();
    Map<String, Id> vendorsMap = new Map<String, Id>();
    List<String> accountNameList;

    if (String.isNotBlank(accountName)) {
      accountNameList = accountName.split(',');
    } else {
      accountNameList = new List<String>();
    }

    PurchaseWrapper purchaseWrapObj = getPurchase(days);

    if (
      purchaseWrapObj.status == '200' &&
      purchaseWrapObj.QueryResponse != null &&
      purchaseWrapObj.QueryResponse.Purchase != null
    ) {
      LeftMain_SecurityUtils.checkObjectIsReadable(Vendor__c.SObjectType);
      LeftMain_SecurityUtils.checkObjectIsInsertable(Vendor__c.SObjectType);
      LeftMain_SecurityUtils.checkObjectIsUpdateable(Vendor__c.SObjectType);
        

      Map<String, Vendor__c> vendorsMaptoInsert = fetchVendors(
        accountNameList,
        purchaseWrapObj.QueryResponse.Purchase
      );
        
      Set<String> newVendorIdSet = new Set<String>();
      for (Vendor__c vendorObj : vendorsMaptoInsert.values()) {
        newVendorIdSet.add(vendorObj.ID__c);
      }

      if (vendorsMaptoInsert.values().size() > 0) {
        try {
            system.debug('***123****'+vendorsMaptoInsert);
          Map<String, String> vendorsUNIqueMap = new Map<String, String>();
          Map<String, Vendor__c> vendorsUniqueMaptoInsert = new Map<String, Vendor__c>();
          List<Vendor__c> vendorList = [
            SELECT Id, Name, ID__c
            FROM Vendor__c
            WHERE Id__c IN :newVendorIdSet
            WITH USER_MODE
            LIMIT 10000
          ];
          for (Vendor__c vendorObj : vendorList) {
            if (vendorObj.Id__c != null) {
              vendorsUNIqueMap.put(vendorObj.Id__c, vendorObj.Id);
            }
          }

          for (Vendor__c vendorObj : vendorsMaptoInsert.values()) {
            if (!vendorsUNIqueMap.containsKey(vendorObj.Id__c)) {
              vendorsUniqueMaptoInsert.put(vendorObj.Id__c, vendorObj);
            }
          }
		  List<Vendor__c> newListVenders = new List<Vendor__c>();
          if (vendorsUniqueMaptoInsert.values().size() > 0) {
            SObjectAccessDecision decision1 = Security.stripInaccessible(AccessType.CREATABLE, vendorsUniqueMaptoInsert.values());
            Database.upsert(newListVenders = decision1.getRecords(),Vendor__c.ID__c,AccessLevel.System_mode);
          }
          for (Vendor__c vendor : newListVenders) {
            vendorsMap.put(vendor.Id__c, vendor.Id);
          }
        } catch (DmlException e) {
          purchaseWrapObj.status = 'Error';
        }
      }

      List<PurchaseWrapper.Purchase> newexpensesList = fetchExpenses(
        accountNameList,
        purchaseWrapObj.QueryResponse.Purchase
      );
      if (newexpensesList.size() > 0) {
        String response = createExpenseRecords(
          newexpensesList,
          vendorsMap,
          days
        );
        if (response.equals('Error')) {
          purchaseWrapObj.status = 'Error';
        }
      }
    }
    return purchaseWrapObj.status;
  }

  // This Method will create vendor and expense records
  @AuraEnabled
  public static String getVendorsAndExpenses(String days) {
    return getVendorsAndExpensesReuSed(days);
  }

  @future(callout=true)
  public static void getVendorsAndExpensesCallout(String days) {
    getVendorsAndExpensesReuSed(days);
  }

  // Fetch those vendors whose already in org and create new vendors which are not in org.
  public static Map<String, Vendor__c> fetchVendors(
    List<String> accountNameList,
    List<PurchaseWrapper.Purchase> PurchaseList
  ) {
    Set<String> newVendorIdSet = new Set<String>();
    for (PurchaseWrapper.Purchase purchase : PurchaseList) {

      if (purchase.EntityRef != null) {
        newVendorIdSet.add(purchase.EntityRef.value);
      }
      if (purchase.EntityRef != null && purchase.Line != null) {
        for (PurchaseWrapper.Line purchaseLine : purchase.Line) {
 
          Double tA = purchase.TotalAmt != null
            ? Decimal.valueOf(purchase.TotalAmt)
            : 0;
          if (purchaseLine.AccountBasedExpenseLineDetail == null) {}
          if (
            purchaseLine.AccountBasedExpenseLineDetail != null &&
            accountNameList.contains(purchaseLine.AccountBasedExpenseLineDetail.AccountRef.name)
          ) {
            newVendorIdSet.add(purchase.EntityRef.value);
            break;
          }
        }
      }
    }
    List<Vendor__c> vendorList = [
      SELECT Id, Name, ID__c
      FROM Vendor__c
      WHERE Id__c IN :newVendorIdSet
      WITH USER_MODE
      LIMIT 10000
    ];
    Map<String, String> vendorsUNIqueMap = new Map<String, String>();
    for (Vendor__c vendorObj : vendorList) {
      if (vendorObj.Id__c != null) {
        vendorsUNIqueMap.put(vendorObj.Id__c, vendorObj.Id);
      }
    }

    LeftMain_SecurityUtils.checkInsert(
      Vendor__c.SObjectType,
      new List<String>{ 'Name' }
    );

    Map<String, Vendor__c> vendorsMaptoInsert = new Map<String, Vendor__c>();
    if (accountNameList.size() > 0) {
      Set<String> uniqueSet = new Set<String>();
      for (PurchaseWrapper.Purchase purchase : PurchaseList) {
        if (purchase.EntityRef != null && purchase.Line != null) {
          for (PurchaseWrapper.Line purchaseLine : purchase.Line) {

            if (purchaseLine.AccountBasedExpenseLineDetail != null && accountNameList.contains( purchaseLine.AccountBasedExpenseLineDetail.AccountRef.name)) {

              if (!vendorsUNIqueMap.containsKey(purchase.EntityRef.value) && !uniqueSet.contains(purchase.EntityRef.value)) {

                uniqueSet.add(purchase.EntityRef.value);
                vendorsMaptoInsert.put(purchase.EntityRef.value,new Vendor__c(Name = purchase.EntityRef.name,ID__c = purchase.EntityRef.value));
                break;
              }
            }
          }
        }
      }
    } else {
      //Create vendor
      Set<String> uniqueSet = new Set<String>();
      for (PurchaseWrapper.Purchase purchase : PurchaseList) {

        if (purchase.EntityRef != null) {
          if (
            !vendorsUNIqueMap.containsKey(purchase.EntityRef.value) &&
            !uniqueSet.contains(purchase.EntityRef.value)
          ) {
              
            uniqueSet.add(purchase.EntityRef.value);
            vendorsMaptoInsert.put(
              purchase.EntityRef.value,
              new Vendor__c(
                Name = purchase.EntityRef.name,
                ID__c = purchase.EntityRef.value
              )
            );
          }
        }
      }
    }
    return vendorsMaptoInsert;
  }

  public static List<PurchaseWrapper.Purchase> fetchExpenses(
    List<String> accountNameList,
    List<PurchaseWrapper.Purchase> PurchaseList
  ) {
    List<PurchaseWrapper.Purchase> newexpensesList = new List<PurchaseWrapper.Purchase>();
    if (accountNameList.size() > 0) {
      for (PurchaseWrapper.Purchase purchase : PurchaseList) {
        if (purchase.Line != null) {
          for (PurchaseWrapper.Line purchaseLine : purchase.Line) {
            newexpensesList.add(purchase);

          }
        }
      }
    } else {
      for (PurchaseWrapper.Purchase purchase : PurchaseList) {
        newexpensesList.add(purchase);
      }
    }
    return newexpensesList;
  }

  //To create expense records
  public static String createExpenseRecords(
    List<PurchaseWrapper.Purchase> expenses,
    Map<String, Id> vendorsMap,
    String days
  ) {
    String defaultVendorId = getVendorId();
    String response = 'Success';

    Map<String, String> expenseExistingParentMap = new Map<String, String>();
    Set<String> UniquePurchaseIdSet = new Set<String>();

    for (PurchaseWrapper.Purchase purchase : expenses) {
      if (String.isNotBlank(purchase.Id)) {
        UniquePurchaseIdSet.add(purchase.Id);
      }
    }

    List<Expense__c> ExpenseList = [
      SELECT Name, Id, Payee__c, Id__c
      FROM Expense__c
      WHERE Id__c IN :UniquePurchaseIdSet AND Payee__c != NULL
      WITH USER_MODE
      LIMIT 10000
    ];
    //All Vendors Map
    Map<String, Id> AllVendorsMap = new Map<String, Id>();
    List<Vendor__c> allVendorList = [
      SELECT Id, ID__c
      FROM Vendor__c
      WITH USER_MODE
      LIMIT 10000
    ];
    for (Vendor__c avl : allVendorList) {
      AllVendorsMap.put(avl.ID__c, avl.Id);
    }

    for (Expense__c expenseObj : ExpenseList) {
      expenseExistingParentMap.put(expenseObj.Id__c, expenseObj.Payee__c);
    }

    LeftMain_SecurityUtils.checkInsert(
      Expense__c.SObjectType,
      new List<String>{
        'Date__c',
        'Id__c',
        'Total_Amount__c',
        'Payment_Type__c',
        'Category__c',
        'Doc_Number__c',
        'Memo__c',
        'Payee__c'
      }
    );

    LeftMain_SecurityUtils.checkUpdate(
      Expense__c.SObjectType,
      new List<String>{
        'Date__c',
        'Id__c',
        'Total_Amount__c',
        'Payment_Type__c',
        'Doc_Number__c',
        'Memo__c',
        'Category__c'
      }
    );
    
    Map<String, Expense__c> expenseMap = new Map<String, Expense__c>();
    if (expenses.size() > 0) {
      for (PurchaseWrapper.Purchase purchase : expenses) {
          
        if (String.isNotBlank(purchase.Id)) {

          Expense__c expense = new Expense__c();
          expense.Id__c = purchase.Id;
          expense.Date__c = purchase.TxnDate != null ? purchase.TxnDate : null;
          expense.Total_Amount__c = purchase.TotalAmt != null
            ? Decimal.valueOf(purchase.TotalAmt)
            : 0;
          expense.Payment_Type__c = purchase.PaymentType;

          if (purchase.Line != null) {
            for (PurchaseWrapper.Line purchaseLine : purchase.Line) {
              if (purchaseLine.AccountBasedExpenseLineDetail != null) {
                expense.Category__c = purchaseLine.AccountBasedExpenseLineDetail.AccountRef.name;
              }
            }
          }
          expense.Doc_Number__c = String.isNotBlank(purchase.DocNumber)
            ? purchase.DocNumber
            : '';
          expense.Memo__c = String.isNotBlank(purchase.PrivateNote)
            ? purchase.PrivateNote
            : '';
          if (
            String.isNotBlank(purchase.Id) &&
            expenseExistingParentMap.containsKey(purchase.Id)
          ) {
            expense.Payee__c = expenseExistingParentMap.get(purchase.Id);
          } else if (
            purchase.EntityRef != null &&
            vendorsMap.containsKey(purchase.EntityRef.value)
          ) {
            expense.Payee__c = vendorsMap.get(purchase.EntityRef.value);
          } else if (
            purchase.EntityRef != null &&
            AllVendorsMap.containsKey(purchase.EntityRef.value)
          ) {
            expense.Payee__c = AllVendorsMap.get(purchase.EntityRef.value);
          } else {
            expense.Payee__c = defaultVendorId;
          }
          expenseMap.put(purchase.Id, expense);
        }
      }
    }
    if (expenseMap.values().size() > 0) {
      try {
        LeftMain_SecurityUtils.checkUpdate(Expense__c.SObjectType,new List<String> {'Id__c','Date__c','Total_Amount__c','Payment_Type__c','Category__c','Doc_Number__c','Memo__c','Payee__c'});
        LeftMain_SecurityUtils.checkInsert(Expense__c.SObjectType,new List<String> {'Id__c','Date__c','Total_Amount__c','Payment_Type__c','Category__c','Doc_Number__c','Memo__c','Payee__c'});

        List<Expense__c> listExpenses = new List<Expense__c>();
        listExpenses.addAll(expenseMap.values());
        SObjectAccessDecision decision2 = Security.stripInaccessible(AccessType.CREATABLE, listExpenses);
        Database.upsert(listExpenses = decision2.getRecords(),Expense__c.Id__c,AccessLevel.System_mode);
      } catch (DmlException e) {
        System.debug('e : ' + e.getMessage());
        response = 'Error';
      }
    }
    return response;
  }

  // Insert vendor and get there Record Id.
  public static String getVendorId() {
    LeftMain_SecurityUtils.checkRead(
      Vendor__c.SObjectType,
      new List<String>{ 'ID', 'Name' }
    );

    LeftMain_SecurityUtils.checkInsert(
      Vendor__c.SObjectType,
      new List<String>{ 'Name', 'ID__c' }
    );
    List<Vendor__c> vendorList = [
      SELECT ID
      FROM Vendor__c
      WHERE Name = 'Default Vendor'
      WITH USER_MODE
      LIMIT 1
    ];
    if (vendorList.size() > 0)
      return vendorList[0].Id;
    else {
      Vendor__c vc = new Vendor__c(
        Name = 'Default Vendor',
        ID__c = 'Default Vendor'
      );
      LeftMain_SecurityUtils.checkInsert(Vendor__c.SObjectType,new List<String> {'Name','ID__c'});
      List<Vendor__c> listVendors = new List<Vendor__c>();
      listVendors.add(vc);
      SObjectAccessDecision decision3 = Security.stripInaccessible(AccessType.CREATABLE, listVendors);
      Database.insert(listVendors = decision3.getRecords());

      return listVendors[0].Id;
    }
  }

  @AuraEnabled
  public static void refreshVendorData() {
    Database.executeBatch(new VendorRefreshBatch(), 200);
  }

  public void execute(SchedulableContext sc) {
    QuickBooksController.getVendorsAndExpensesCallout('-1');
  }

  @InvocableMethod(label='get Checked Quickbook Job')
  public static List<Boolean> checkedQuickbookScheduler() {
    List<Boolean> result = new List<Boolean>();
    List<CronTrigger> lCronTrigger = [
      SELECT
        Id,
        CronExpression,
        CronJobDetailId,
        CronJobDetail.Name,
        StartTime,
        State,
        EndTime
      FROM CronTrigger
      WHERE
        (CronJobDetail.Name = 'get Quickbooks Job'
        OR CronJobDetail.Name = 'Refresh Vendor Batch')
        AND EndTime = NULL
        WITH USER_MODE
    ];
    result.add((lCronTrigger.size() > 1));

    return result;
  }
  public static String currentQuarterQuery() {
    // Get the current date
    Date today = Date.today();

    // Determine the current quarter
    Integer currentQuarter = (Integer) Math.ceil(today.month() / 3.0);

    // Determine the start date of the current quarter
    Date startOfQuarter;
    if (currentQuarter == 1) {
      startOfQuarter = Date.newInstance(today.year(), 1, 1);
    } else if (currentQuarter == 2) {
      startOfQuarter = Date.newInstance(today.year(), 4, 1);
    } else if (currentQuarter == 3) {
      startOfQuarter = Date.newInstance(today.year(), 7, 1);
    } else {
      // Quarter 4
      startOfQuarter = Date.newInstance(today.year(), 10, 1);
    }

    // Build the query string with data up to the current date
    /*String query = EncodingUtil.urlEncode(
      'select * from Purchase where MetaData.LastUpdatedTime >= \'' +
        String.valueOf(startOfQuarter) +
        '\' AND MetaData.LastUpdatedTime <= \'' +
        String.valueOf(today) +
        '\' STARTPOSITION 1 MAXRESULTS 1000 ',
      'UTF-8'
    );*/
	String query = EncodingUtil.urlEncode(
      'select * from Purchase where MetaData.LastUpdatedTime >= \'' +
        String.valueOf(startOfQuarter) +
        '\' AND MetaData.LastUpdatedTime <= \'' +
        String.valueOf(today) + 'T23:59:59' +
        '\' STARTPOSITION 1 MAXRESULTS 1000 ',
      'UTF-8'
    );
    return query;
  }

  public static String queryLastQuarter() {
    // Calculate the start date of the last quarter
    Date today = Date.today();
    Integer currentQuarter = (Integer) Math.ceil(today.month() / 3.0);

    // Determine the start month of the last quarter
    Integer startMonth = (currentQuarter - 2) > 0
      ? (currentQuarter - 2) * 3 + 1
      : 10;
    Integer startYear = (currentQuarter - 2) > 0
      ? today.year()
      : today.year() - 1;
    Date startOfLastQuarter = Date.newInstance(startYear, startMonth, 1);

    // Calculate the last day of the last quarter
    Date lastDayOfLastQuarter = startOfLastQuarter.addMonths(3).addDays(-1);

    // Build the query string
    String query = EncodingUtil.urlEncode(
      'SELECT * FROM Purchase WHERE MetaData.LastUpdatedTime > \'' +
        String.valueOf(startOfLastQuarter) +
        '\' AND MetaData.LastUpdatedTime <= \'' +
        String.valueOf(lastDayOfLastQuarter) + 'T23:59:59' +
        '\' STARTPOSITION 1 MAXRESULTS 1000 ',
      'UTF-8'
    );
    return query;
  }
}