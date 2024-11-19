public class TwnsqrUpdateController {
    
    public String recAddress;
    public Boolean initialized = false;
    public Boolean initialized1 = false;
    public Boolean showToast{get;set;}
    public String errorMsg{get;set;}
    List<Lead> leadRecList = new List<Lead>();
    List<Opportunity> oppRecList = new List<Opportunity>();
    List<Transactions__c> transactionList = new List<Transactions__c>();
    //public Decimal buyBoxes {get;set;}
    public Decimal contacts {get;set;}
    public String lastResponse {get;set;}
    public String objectName  {
        get;
        set{
            objectName = value;
            if(!initialized){
                initialized = true;
                getData();
            }
        }
    }
    public String recordId  {
        get;
        set{
            recordId = value;
            if(!initialized1){
                initialized1 = true;
                getData();
            }
        }
    }
    
    public void getData(){
        showToast = false;
        errorMsg = ' ';
        system.debug(objectName+' In constructor '+ recordId);
        if(objectName != null && recordId != null){
            if(objectName == 'Lead'){
                String query = 'SELECT Id,of_Buy_Boxes__c,of_Contacts__c,Last_Update__c,Address FROM '+ objectName +
                    ' WHERE Id = ' + '\''+ recordId + '\'';
                leadRecList = Database.query(query);
            }
            else if(objectName == 'Opportunity'){
                String query = 'SELECT Id,of_Buy_Boxes__c,of_Contacts__c,Last_Update__c,Address_1__c FROM '+ objectName 
                    + ' WHERE Id = ' + '\''+ recordId + '\'';
                oppRecList = Database.query(query);
            }
            else if(objectName == 'Transactions__c'){
                String query = 'SELECT Id,of_Buy_Boxes__c,of_Contacts__c,Last_Update__c,'+
                    'Left_Main_Address__c FROM '
                    + objectName + ' WHERE Id = ' + '\''+ recordId + '\'';
                transactionList = Database.query(query);
            }
            if(leadRecList.size() > 0){
                //this.buyBoxes = leadRecList[0].of_Buy_Boxes__c;
                this.contacts = leadRecList[0].of_Contacts__c;
                this.lastResponse = leadRecList[0].Last_Update__c != null ? leadRecList[0].Last_Update__c.format('MM/dd/yyyy h:mm a') : null; 
                if(leadRecList[0].Address != null){
                    Address add = leadRecList[0].Address;
                    recAddress='';
                    if(add.getStreet() != null){
                        recAddress +=  add.getStreet() + ' ';
                    }
                    if(add.getCity() != null){
                        recAddress +=  add.getCity() + ' ';
                    }
                    if(add.getState() != null){
                        recAddress +=  add.getState() + ' ';
                    }
                    if(add.getPostalCode() != null){
                        recAddress +=  add.getPostalCode() + ' ';
                    }
                    if(add.getCountry() != null){
                        recAddress +=  add.getCountry();
                    }
                }
            }
            else if(oppRecList.size() > 0){
                //this.buyBoxes = oppRecList[0].of_Buy_Boxes__c;
                this.contacts = oppRecList[0].of_Contacts__c;
                this.lastResponse = oppRecList[0].Last_Update__c != null ? oppRecList[0].Last_Update__c.format('MM/dd/yyyy h:mm a') : null;
                recAddress = oppRecList[0].Address_1__c;
            }
            else if(transactionList.size() > 0){
                //this.buyBoxes = transactionList[0].of_Buy_Boxes__c;
                this.contacts = transactionList[0].of_Contacts__c;
                this.lastResponse = transactionList[0].Last_Update__c != null ? transactionList[0].Last_Update__c.format('MM/dd/yyyy h:mm a') : null;
                recAddress = transactionList[0].Left_Main_Address__c.replace('\n','');
            }    
        }
    }
    
    public void hideToast(){
        showToast = false;
    }
    
    public void getTwnsqrUpdate(){
        if(String.isEmpty(recAddress)) {
            showToast = true;
            errorMsg = 'Address can\'t be blank.';
        }
        else{
            system.debug(recAddress.replace('\n',''));
            Http h = new Http();
            String jsonString =  '{"query": "query MyQuery($queries: [MatchingDemandInput!]!) { MatchingDemands(queries: $queries) '+
                '{ args { address addressFormatted } success error contacts}}","variables": {"queries": [{"address": "' + recAddress +'"}]}}';
            
            Twnsqr_Details__mdt reqDetails = [SELECT Endpoint__c, Token__c FROM Twnsqr_Details__mdt LIMIT 1]; 
            
            // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
            HttpRequest req = new HttpRequest();
            req.setEndpoint(reqDetails.Endpoint__c);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization',reqDetails.Token__c);
            req.setBody(jsonString);
            req.setTimeout(80000);
            system.debug('jsonString--'+jsonString);
            // Send the request, and return a response
            HttpResponse res = h.send(req);
            system.debug(res.getStatusCode() +'--'+  res.getBody());
            TwnsqrResponseWrapper resWrapper = (TwnsqrResponseWrapper) System.JSON.deserialize(res.getBody(), TwnsqrResponseWrapper.class);
            
            if(resWrapper != null && resWrapper.data != null){
                if( resWrapper.data.MatchingDemands[0].success){
                    if(leadRecList.size() > 0)
                        leadRecList[0].of_Contacts__c = resWrapper.data.MatchingDemands[0].contacts;  
                    else if(oppRecList.size() > 0)
                        oppRecList[0].of_Contacts__c = resWrapper.data.MatchingDemands[0].contacts;  
                    else if(transactionList.size() > 0)
                        transactionList[0].of_Contacts__c = resWrapper.data.MatchingDemands[0].contacts;                 
                }
                else{
                    showToast = true;
                    errorMsg = 'No results found for this address.Please check your address.';
                    System.debug('error----  '+resWrapper.data.MatchingDemands[0].error);
                }
                if(leadRecList.size() > 0){
                    leadRecList[0].Last_Update__c = System.now();
                    update leadRecList[0];
                    lastResponse = leadRecList[0].Last_Update__c.format('MM/dd/yyyy h:mm a');
                    contacts =	leadRecList[0].of_Contacts__c;  
                }
                else if(oppRecList.size() > 0){
                    oppRecList[0].Last_Update__c = System.now();
                    update oppRecList[0];
                    lastResponse = oppRecList[0].Last_Update__c.format('MM/dd/yyyy h:mm a');
                    contacts =	oppRecList[0].of_Contacts__c;  
                }
                else if(transactionList.size() > 0){
                    transactionList[0].Last_Update__c = System.now();
                    update transactionList[0];
                    //buyBoxes =	transactionList[0].of_Buy_Boxes__c;  
                    lastResponse = transactionList[0].Last_Update__c.format('MM/dd/yyyy h:mm a');
                    contacts =	transactionList[0].of_Contacts__c;  
                }
            }
        }
    }
}