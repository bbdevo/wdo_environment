trigger SDO_Service_Case_EinsteinAgent on Case (before insert, after insert, before update) {
    if(System.isBatch()) return;
    
    if(Trigger.isBefore){ 
        for(Case c: Trigger.New){
            System.debug(c);
            SDO_Service_CaseClassificationHelper.createRecommendations(c);
        }
    }
    
    if(Trigger.isAfter){
        for(Case c: Trigger.new){
            if(Trigger.isAfter){
                SDO_Service_EinsteinAgentTriggerHelper.createRecommendations(c.Id);
            }
        }
    }
}