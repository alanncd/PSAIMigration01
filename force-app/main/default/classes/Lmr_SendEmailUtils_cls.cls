public with sharing class Lmr_SendEmailUtils_cls {
    public static String generateCronExpression(Integer numberDays) {

        Datetime workTime = System.now().addDays(numberDays);
        String CRONEXP = '' + workTime.second() + ' ' + workTime.minute() + ' ' + workTime.hour()
                + ' ' + workTime.day() + ' ' + workTime.month() + ' ? ' + workTime.year();
        
        return CRONEXP;
    
    }
      
}