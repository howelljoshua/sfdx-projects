public class CMU_UpdateGivingTotalsSchedule implements Schedulable {

    public void execute(SchedulableContext schedulableContext) {
        String batchCode = CMU_UpdateGivingTotalsBatch.BATCH_CODE;
        CMU_BatchConfig.Settings batchSettings = CMU_BatchConfig.getSettings(batchCode);

        if (batchSettings.isEnabled) {
            CMU_UpdateGivingTotalsBatch updateGivingTotals = new CMU_UpdateGivingTotalsBatch();
            Database.executeBatch(updateGivingTotals, batchSettings.batchSize);
        }
    }

}