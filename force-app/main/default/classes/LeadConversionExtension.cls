public with sharing class LeadConversionExtension {

    public static List<Sobject> getQueryNeeded(String queryNeeded){
        
        List<Sobject> listSobject = Database.query(queryNeeded);

        return listSobject;
    }
}