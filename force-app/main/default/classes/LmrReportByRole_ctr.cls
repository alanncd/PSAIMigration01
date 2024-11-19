public with sharing class LmrReportByRole_ctr {

    @AuraEnabled(cacheable=true)
    public static List<Report> getReports(){

        return [SELECT Id, Name, DeveloperName, FolderName FROM Report WITH USER_MODE LIMIT 10000];
    }
}