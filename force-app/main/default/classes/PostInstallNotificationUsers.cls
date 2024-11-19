global with sharing class PostInstallNotificationUsers implements InstallHandler{
    
        global void onInstall (InstallContext context)
    {
Messaging.CustomNotification singleNotification = new Messaging.CustomNotification();
singleNotification.setBody('It’s here! A new Left Main package upgrade - Featuring Cadences! Click here to read more details & watch launch video');
singleNotification.setTitle('LeftMain REI');
singleNotification.setSenderId(Userinfo.getUserId());
CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Left_Main_Notification'];
singleNotification.setNotificationTypeId(type.id);
ContentDocument documentId = [Select Id,Title From ContentDocument where Title='Post-deploy steps cadences'];
singleNotification.setTargetId(documentId.Id); 
        
List<User> listUsers = [Select Id From User where isActive = true and profile.name ='System Administrator' WITH USER_MODE];
Set<String> listUser = new Set<String>();

If(listUsers.size()>0){
        for(User userIteration : listUsers){
            listUser.add(userIteration.Id);
        }
        singleNotification.send(listUser);
        }
    }
}