public with sharing class AddLicenseController {
    
    public String leftMainUrl { get; set; }	
    public String orgId { get; set; }
    
    public AddLicenseController () {
        leftMainUrl = getLeftMainUrl ();
        orgId = UserInfo.getOrganizationId ();
    }
    
    private string getLeftMainUrl () {
        List <Add_License_Setting__mdt >  urlSettings  = [ 
            SELECT Left_Main_Url__c
            FROM Add_License_Setting__mdt LIMIT 50000];
        
        if ( urlSettings.isEmpty() ) {
            throw new QueryException ('Please check your Add License Setting');      
        } else {
        	return urlSettings[0].Left_Main_Url__c;
        }
        
    }
}