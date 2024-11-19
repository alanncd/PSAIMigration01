global without sharing class PostInstallScript implements InstallHandler{

    global void onInstall (InstallContext context)
    {
        try{
        //data for cadences, we have to separate for big data
        new PostInstallDeleteProcess().onInstall(context);
        new PostInstallScriptCadences().onInstall(context);
        new PostInstallScriptCadences2().onInstall(context);
        new PostInstallScriptCadences3().onInstall(context);
       new PostInstallScriptCadences4().onInstall(context);
        new PostInstallScriptCadences5().onInstall(context);
        new PostInstallScriptCadences6().onInstall(context);
       	new PostInstallScriptCadences7().onInstall(context);
        new PostInstallScriptCadences8().onInstall(context);
        new PostInstallScriptCadences9().onInstall(context);
        new PostInstallScriptCadences10().onInstall(context);
        new PostInstallScheduledJob().onInstall(context);
            if(Test.isRunningTest()){
              new PostInstallNotificationUsers().onInstall(context);

            }
        }catch(Exception e){
            
        }
        // post notification to users
        //new PostInstallNotificationUsers().onInstall(context);
    }
}