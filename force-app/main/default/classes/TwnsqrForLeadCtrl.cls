public class TwnsqrForLeadCtrl {
    
    public List<Id> selectedRecordIds{get;set;}
    public List<Lead> selLeads = new List<Lead>();
    public Boolean showToast{get;set;}
    public String errorMsg{get;set;}
    
    public TwnsqrForLeadCtrl(ApexPages.StandardSetController cntlr){
        try{
            selectedRecordIds = new List<Id>();
            selLeads = cntlr.getSelected(); //get selected records from account list view
            for(Lead ld : selLeads) {
                selectedRecordIds.add(ld.Id);  
            }
            System.debug(selectedRecordIds);
            if(selectedRecordIds.isEmpty()){
                showToast = true;
                errorMsg = 'Please select atleast one record.';
            }
            
        }
        catch(Exception err){
            system.debug(err.getMessage());
        }
    }  
    public PageReference hideToast(){
        showToast = false;
        Schema.DescribeSObjectResult SObjectSchema =  Lead.SObjectType.getDescribe();
        String currentViewUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/o/Lead/list?filterName=Recent';
        PageReference newPage =  New Pagereference(currentViewUrl);     
        newPage.setRedirect(true);
        return newPage;
    }  
    
    public void getTwnsqrUpdate(){
        if(!selectedRecordIds.isEmpty()){
            List<Lead> leadRecordList = [SELECT Id,of_Buy_Boxes__c,of_Contacts__c,Last_Update__c,Address 
                                          FROM Lead
                                          WHERE Id In : selectedRecordIds];
            String addressData ='';
            if(!leadRecordList.isEmpty()){
                for(Integer i = 0; i < leadRecordList.size(); i++){
                    if(leadRecordList[i].Address != null){
                        Address add = leadRecordList[i].Address;
                        String recAddress='';
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
                        if(i == leadRecordList.size()-1 ){
                            addressData += '{"address" : "'+recAddress+'","idempotencyKey" : "'+ leadRecordList[i].Id+'"}';
                        }
                        else{
                            addressData += '{"address" : "'+recAddress+'","idempotencyKey" : "'+ leadRecordList[i].Id+'"},';
                        }  
                    }
                }
            }
            if(String.isEmpty(addressData)) {
                showToast = true;
                errorMsg = 'Address can\'t be blank.';
            }
            else{
                Http h = new Http();
                
                String jsonString =  '{"query": "query MyQuery($queries: [MatchingDemandInput!]!) { MatchingDemands(queries: $queries) '+
                    '{ args { address addressFormatted idempotencyKey} success error contacts buyBoxes }}","variables": {"queries": [' + addressData +']}}';
                
                Twnsqr_Details__mdt reqDetails = [SELECT Endpoint__c, Token__c FROM Twnsqr_Details__mdt LIMIT 1]; 
                
                // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
                HttpRequest req = new HttpRequest();
                req.setEndpoint(reqDetails.Endpoint__c);
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization',reqDetails.Token__c);
                req.setBody(jsonString);
                req.setTimeout(80000);
                
                // Send the request, and return a response
                HttpResponse res = h.send(req);
                TwnsqrResponseWrapper resWrapper = (TwnsqrResponseWrapper) System.JSON.deserialize(res.getBody(), TwnsqrResponseWrapper.class);
                List<sObject> listToUpdate = new List<sObject>();
                
                if(resWrapper != null){
                    for(Integer i=0; i< resWrapper.data.MatchingDemands.size(); i++) {
                        for(Integer j=0; j < leadRecordList.size(); j++) {
                            if(leadRecordList[j].id == resWrapper.data.MatchingDemands[i].args.idempotencyKey){
                                if(resWrapper.data.MatchingDemands[i].buyBoxes != null){ 
                                    leadRecordList[j].of_Buy_Boxes__c = resWrapper.data.MatchingDemands[i].buyBoxes;              
                                }
                                if(resWrapper.data.MatchingDemands[i].contacts != null){
                                    leadRecordList[j].of_Contacts__c = resWrapper.data.MatchingDemands[i].contacts;  
                                }
                                leadRecordList[j].Last_Update__c = System.now();
                                listToUpdate.add(leadRecordList[j]);
                            }
                        }     
                    }
                    if(!listToUpdate.isEmpty()){
                        try {
                            update listToUpdate;
                        } catch(Exception e) {
                            System.debug('error');
                        }
                        showToast = true;
                        errorMsg = 'Records Updated Successfully.';
                    }
                } 
            } 
        }
    }
}