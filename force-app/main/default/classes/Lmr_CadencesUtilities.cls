public class Lmr_CadencesUtilities {
    
    public static String generateCronExpressionDays(Integer numberDays) {

        Datetime workTime = System.now().addDays(numberDays);
        String CRONEXP = '' + workTime.second() + ' ' + workTime.minute() + ' ' + workTime.hour()
                + ' ' + workTime.day() + ' ' + workTime.month() + ' ? ' + workTime.year();
    
     	return CRONEXP;
    }

    public static String generateCronExpressionHours(Integer numberDays) {

        Datetime workTime = System.now().addHours(numberDays);
        String CRONEXP = '' + workTime.second() + ' ' + workTime.minute() + ' ' + workTime.hour()
                + ' ' + workTime.day() + ' ' + workTime.month() + ' ? ' + workTime.year();
    
     	return CRONEXP;
    }

    public static String generateCronExpressionMinutes(Integer numberMinutes) {

        Datetime workTime = System.now().addMinutes(numberMinutes);
        String CRONEXP = '' + workTime.second() + ' ' + workTime.minute() + ' ' + workTime.hour()
                + ' ' + workTime.day() + ' ' + workTime.month() + ' ? ' + workTime.year();
    
     	return CRONEXP;
    }



}