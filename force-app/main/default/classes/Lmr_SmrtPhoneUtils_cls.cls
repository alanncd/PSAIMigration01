public with sharing class Lmr_SmrtPhoneUtils_cls {
  public static String buildMessage(String msgBody, String obj, String objId) {
    List<String> blackListStr = new List<String>{
      'owner.firstname',
      'account.firstname',
      'owner.phone'
    };

    Pattern pt = Pattern.compile('\\{\\!([a-z|A-Z|0-9].*?)\\}'); // {}
    msgBody = msgBody.replace('Lead.', '');
    msgBody = msgBody.replace('Opportunity.', '');
    msgBody = msgBody.replace('Contact.', '');
    msgBody = msgBody.replace('Left_Main__Interested_Buyers__c.', '');
    msgBody = msgBody.replace('Left_Main__Transactions__c.', '');
    msgBody = msgBody.replace('Transactions__c.', '');
    msgBody = msgBody.replace('Interested_Buyers__c.', '');

    Matcher m = pt.matcher(msgBody);
    List<String> names = new List<String>();
    Map<String, String> mapFields = new Map<String, String>();
    String Query = QUERY_SELECT;
    while (m.find()) {
      names.add(m.group());
      String myfield = m.group().removeStart('{!').replace('}', '');
      mapFields.put(m.group(), myfield);
      if (!Query.contains(myfield)) {
        Query += myfield + ', ';
      }
    }
 //   Query += 'Id ' + String.escapeSingleQuotes(QUERY_FROM) + String.escapeSingleQuotes(obj) + String.escapeSingleQuotes(QUERY_WHERE) + ' id = \'' +String.escapeSingleQuotes(objId) +'\'';
 // Aplicar String.escapeSingleQuotes a obj y objId
Query += 'Id FROM ' + String.escapeSingleQuotes(obj) + 
         ' WHERE Id = \'' + String.escapeSingleQuotes(objId) + '\'';

 //Query = String.escapeSingleQuotes(Query);

   	
 system.debug('error:1::'+Query);
	system.debug('error:2::'+string.escapeSingleQuotes(Query));      
    sObject sobj = Database.query(Query);
    for (String key : mapFields.keySet()) {
      String val = mapFields.get(key);

      if (!blackListStr.contains(val)) {
        //Ignore Fields blackList owner.firstname
        if (msgBody.contains(key)) {
          if (sobj.get(val) != null) {
            //(String)
            msgBody = msgBody.replace(key, sobj.get(val) + ''); //(String)
          } else {
            msgBody = msgBody.replace(key, '');
          }
        }
      }
    }
    return msgBody;
  }
  public static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix) {
    String objectName = '';
    try {
      //Get prefix from record ID
      //This assumes that you have passed at least 3 characters
      String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0, 3);

      //Get schema information
      Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

      //Loop through all the sObject types returned by Schema
      for (Schema.SObjectType stype : gd.values()) {
        String sobjectName = '' + stype;

        Schema.DescribeSObjectResult r = stype.getDescribe();
        String prefix = r.getKeyPrefix();
        //Check if the prefix matches with requested prefix-x
        if (prefix != null && prefix.equals(myIdPrefix)) {
          objectName = r.getName();
          // Remove '' prefix if present
          if (objectName.startsWith('')) {
            objectName = objectName.substring(''.length());
          }
          break;
        }
          
        if (
          !(sobjectName == 'Lead' ||
          sobjectName == 'Contact' ||
          sobjectName == 'Account' ||
          sobjectName == 'Opportunity')
        )
          continue;
      }
    } catch (Exception e) {
      System.debug(e);
    }
    return objectName;
  }


  private static final String QUERY_SELECT = 'SELECT ';
  private static final String QUERY_WHERE = ' WHERE ';
  private static final String QUERY_FROM = ' FROM ';
  private static final String QUERY_LIMIT = ' LIMIT ';
  private static final String SECURITY_ENFORCED = ' WITH SECURITY_ENFORCED';

  //input details that comes to apex from flow
  public class FlowInputs {
    @InvocableVariable
    public String recordId;

    @InvocableVariable
    public Integer daysToSchedule;

    @InvocableVariable
    public String nameTemplate;
  }
}