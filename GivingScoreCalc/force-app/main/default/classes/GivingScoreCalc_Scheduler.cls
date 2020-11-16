global class GivingScoreCalc_Scheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        GivingScoreCalc g = new GivingScoreCalc();
        database.executebatch(g,50);
    }
}