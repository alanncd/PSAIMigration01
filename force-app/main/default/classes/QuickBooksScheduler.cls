global class QuickBooksScheduler implements Schedulable, Database.AllowsCallouts {
    global void execute(SchedulableContext sc) {
        //QuickBooksController qbc = new QuickBooksController(); 
        QuickBooksController.getVendorsAndExpenses('-10');
    }
 }