global class WdcDemo_WellnessRecalcBatchable implements Database.Batchable<SObject> {

    global final String query = 'SELECT Id FROM Location';

    // final member variable for status
    private static final String WELLNESS_FACT_STATUS = 'NOT PROCESSED';

    global WdcDemo_WellnessRecalcBatchable () {
        //default constructor
    }

    global WdcDemo_WellnessRecalcBatchable ( String q ) {
        this.query = q;
    }

    global Database.QueryLocator start(Database.BatchableContext BC_START) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC_EXEC, List<SObject> scope) {

        if(scope == null) return;

        // instantiate new list for insertion later
        List<wkcc__LocationWellnessStaging__c> lLocWellnessToInsert = new List<wkcc__LocationWellnessStaging__c>();

        // Begin primary logic
        if(scope[0] instanceof Schema.Location) {

            // convert to list of ids
            List<Id> lLocationIds = new List<Id>();
            for(Schema.Location loc : (List<Schema.Location>)scope) {
                lLocationIds.add(loc.Id);
            }

            // delete staged welleness using list of ids in query
            Database.delete([SELECT Id FROM wkcc__LocationWellnessStaging__c]);

            // delete all wellness facts as they are about to be recalculated
            Database.delete([SELECT Id FROM wkcc__LocationWellnessFact__c]);

            // create new staging records and insert them
            for(Schema.Location loc : (List<Schema.Location>)scope) {
                lLocWellnessToInsert.add( new wkcc__LocationWellnessStaging__c(
                        wkcc__Location__c = loc.Id,
                        wkcc__JobStatus__c = WELLNESS_FACT_STATUS,
                        wkcc__ExternalId__c = loc.Id + ',' + WELLNESS_FACT_STATUS
                    )
                );

            }
        }
        else {

            throw new System.SerializationException('Data in scope is not of the correct type.');
        }
        // end logical processing

        // create new location wellness facts that will cause re-calculation
        if( lLocWellnessToInsert != null ) {
            Database.insert(lLocWellnessToInsert);
        }
    }
    // end execute

    global void finish(Database.BatchableContext BC_FIN) {
        //implement me
    }

}