@isTest
public class LmrReportByRole_tst {

    @isTest
    public static void getReports(){
        List<Report> listReports = [SELECT Id, Name, DeveloperName, FolderName FROM Report Limit 1];
        List<Report> lisReportsMethod = LmrReportByRole_ctr.getReports();
        
       	system.assertEquals(listReports.size(), lisReportsMethod.size());

    }
        @isTest
    public static void moveNotesAndFilesHelper(){
        String variableSend = MoveNotesandFilesHelper.moveRecords('test');
        
       	system.assertEquals(variableSend, 'test');

    }
    
}