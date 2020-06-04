/* 
* Apex Schedulable that calls Apex Batch to create and update Parent Afilliation Records
*
* 12/07/2018    Michael Steptoe (Sleek)
*/

global class AQCMU_scheduleCalcParentAffiliation implements Schedulable {
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new AQCMU_CalcParentAffiliation(), 400);
    }
}