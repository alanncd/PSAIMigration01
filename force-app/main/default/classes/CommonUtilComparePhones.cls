Global with sharing class CommonUtilComparePhones {
    
 	@InvocableMethod(label='Util Verify Phones Number in Campaing with Tracking Number')        
	Global static List<String> getCampaignbyPhoneNumber(List<String> value) {
        Map<String,String> campaignMap = new Map<String,String>();
       
        List<Campaign> campaigns = [Select Id, Name,smrtPhone_Number__c From Campaign Where IsActive=TRUE AND Lead_Sync__c=TRUE AND (smrtPhone_Number__c!=NULL OR smrtPhone_Number__c!='') WITH USER_MODE];
        for(Campaign cc:campaigns){
            
            campaignMap.put(cleanNumber(cc.smrtPhone_Number__c),cc.Id);
        
        }
        List<String> idx = new List<String>();
        for(String i:value){
			idx.add(campaignMap.get(cleanNumber(i))); 
        }
        
        if(idx !=NULL){
            
			List<Campaign> campaignsFound = [Select Id, Name,Lead_Sync__c,Lead_Source_Sync__c,smrtPhone_Number__c From Campaign Where Lead_Sync__c=TRUE AND ID IN:idx WITH USER_MODE];            
            if(campaignsFound.size()<>0){
				return idx;
            }
        }
        
		return null;
    }

    public static String cleanNumber(String num){
		String numeroDeTelefonoLimpio = num.replaceAll('[^0-9]', '');     
        if(numeroDeTelefonoLimpio.length()==11){
            if(numeroDeTelefonoLimpio.left(1)=='1'){
                numeroDeTelefonoLimpio = numeroDeTelefonoLimpio.right(10);
            }
        }
        
        return numeroDeTelefonoLimpio;
        
    }
}