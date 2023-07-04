/**
 * @File Name          : ExecuteBulkShiftJob.cls
 * @Description        :
 * @Author             : Shawn Butters (butters@salesforce.com)
 * @Group              :
 * @Last Modified By   : Shawn Butters (butters@salesforce.com)
 * @Last Modified On   : 07-29-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    5/30/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class ExecuteBulkShiftJob {

    public static void makeMagic() {

        Date startdate =  Date.newInstance(2020, 06, 01);
        Date enddate = Date.newInstance(2020, 08, 29);

        String q_DemoServiceTerritories =
            'SELECT CreatedById, CreatedDate, Description, FSL__Hide_Emergency_Map__c, FSL__Internal_SLR_Geolocation__c, FSL__NumberOfServicesToDripFeed__c, FSL__Service_Cluster_Min_Size__c, FSL__Service_Cluster_Proximity__c, FSL__System_Jobs__c, FSL__TerritoryLevel__c, GeocodeAccuracy, Id, IsActive, IsDeleted, LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, Name, OperatingHoursId, OwnerId, ParentTerritoryId, SystemModstamp, TopLevelTerritoryId, TypicalInTerritoryTravelTime, wkfsl__Facility_Type__c, wkfsl__Location__r.Name, wkfsl__Maximum_Occupancy__c FROM ServiceTerritory';

        Id batchInstanceId = Database.executeBatch(new BTW_BatchShiftCreation(q_DemoServiceTerritories, startdate, enddate));
        System.debug(batchInstanceId);
        //'SELECT ServiceResourceId FROM ServiceTerritoryMember WHERE ServiceTerritoryId IN(\'0Hh5w000000HmdNCAS\',\'0Hh5w000000HmdOCAS\',\'0Hh5w000000HmdPCAS\',\'0Hh5w000000HmdwCAC\',\'0Hh5w000000HmdxCAC\',\'0Hh5w000000HmdQCAS\',\'0Hh5w000000HmdzCAC\',\'0Hh5w000000HmdyCAC\',\'0Hh5w000000HmcFCAS\',\'0Hh5w000000HmbyCAC\',\'0Hh5w000000HmdRCAS\',\'0Hh5w000000Hme0CAC\',\'0Hh5w000000HmbzCAC\',\'0Hh5w000000Hmc0CAC\',\'0Hh5w000000Hme1CAC\',\'0Hh5w000000HmdSCAS\',\'0Hh5w000000HmdTCAS\',\'0Hh5w000000Hme2CAC\',\'0Hh5w000000Hmc1CAC\',\'0Hh5w000000Hmc2CAC\',\'0Hh5w000000Hme3CAC\',\'0Hh5w000000Hme4CAC\',\'0Hh5w000000Hme5CAC\',\'0Hh5w000000HmdsCAC\',\'0Hh5w000000HmdtCAC\',\'0Hh5w000000HmduCAC\',\'0Hh5w000000HmdvCAC\',\'0Hh5w000000HmdqCAC\',\'0Hh5w000000HmcDCAS\',\'0Hh5w000000HmcECAS\',\'0Hh5w000000HmdrCAC\',\'0Hh5w000000HmdCCAS\',\'0Hh5w000000Hme6CAC\',\'0Hh5w000000HmdUCAS\',\'0Hh5w000000Hme7CAC\',\'0Hh5w000000HmdECAS\',\'0Hh5w000000Hmd0CAC\',\'0Hh5w000000HmcxCAC\',\'0Hh5w000000Hmd6CAC\',\'0Hh5w000000HmdDCAS\',\'0Hh5w000000HmdMCAS\')';

        //List<ServiceTerritory> stList = [SELECT Id FROM ServiceTerritory WHERE Id IN('0Hh5w000000HmdNCAS','0Hh5w000000HmdOCAS','0Hh5w000000HmdPCAS','0Hh5w000000HmdwCAC','0Hh5w000000HmdxCAC','0Hh5w000000HmdQCAS','0Hh5w000000HmdzCAC','0Hh5w000000HmdyCAC','0Hh5w000000HmcFCAS','0Hh5w000000HmbyCAC','0Hh5w000000HmdRCAS','0Hh5w000000Hme0CAC','0Hh5w000000HmbzCAC','0Hh5w000000Hmc0CAC','0Hh5w000000Hme1CAC','0Hh5w000000HmdSCAS','0Hh5w000000HmdTCAS','0Hh5w000000Hme2CAC','0Hh5w000000Hmc1CAC','0Hh5w000000Hmc2CAC','0Hh5w000000Hme3CAC','0Hh5w000000Hme4CAC','0Hh5w000000Hme5CAC','0Hh5w000000HmdsCAC','0Hh5w000000HmdtCAC','0Hh5w000000HmduCAC','0Hh5w000000HmdvCAC','0Hh5w000000HmdqCAC','0Hh5w000000HmcDCAS','0Hh5w000000HmcECAS','0Hh5w000000HmdrCAC','0Hh5w000000HmdCCAS','0Hh5w000000Hme6CAC','0Hh5w000000HmdUCAS','0Hh5w000000Hme7CAC','0Hh5w000000HmdECAS','0Hh5w000000Hmd0CAC','0Hh5w000000HmcxCAC','0Hh5w000000Hmd6CAC','0Hh5w000000HmdDCAS','0Hh5w000000HmdMCAS')];
        //Set<ServiceTerritory> stSet = new Set<ServiceTerritory>();
        //stSet.addAll(stList);

        // RUN BATCH
        //Id batchInstanceId = Database.executeBatch(new BTW_BatchShiftCreation(stSet, startdate, enddate));
        //System.debug(batchInstanceId);

        /**
        for(ServiceTerritory st: stSet){
            Id batchInstanceId = Database.executeBatch(new BTW_BatchShiftCreation(st.Id,startdate,enddate));
            System.debug(batchInstanceId);
        }
         */
    }

}