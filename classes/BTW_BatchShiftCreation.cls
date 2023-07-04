/**
 * @File Name          : BTW_BatchShiftCreation.cls
 * @Description        :
 * @Author             : Shawn Butters (butters@salesforce.com)
 * @Group              :
 * @Last Modified By   : Shawn Butters (butters@salesforce.com)
 * @Last Modified On   : 07-29-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    5/31/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
global class BTW_BatchShiftCreation implements Database.Batchable<sObject>{
    global final Date startTimeframe;
    global final Date endTimeframe;
    //global final String serviceTerritoryId;
    //global final Set<ServiceTerritory> serviceTerritoriesSet;
    global final String query;

    global BTW_BatchShiftCreation(String q, Date s, Date e){
        startTimeframe=s;
        endTimeframe=e;
        //serviceTerritoryId=st;
        //serviceTerritoriesSet = i_stSet;
        query = q; //query to get all service territories in scope
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
            //'select id,name from serviceresource where id in '+
            //'(select serviceresourceid from serviceterritorymember where serviceterritoryid=\''+serviceTerritoryId+'\')'

            //---> Hard coded query to return all service resources only at demo locations/service territories under California in the facility hierarchy
           // 'SELECT Id,Name FROM ServiceResource WHERE Id IN'+
	      //      '(SELECT ServiceResourceId FROM ServiceTerritoryMember WHERE ServiceTerritoryId IN(\'0Hh5w000000HmdNCAS\',\'0Hh5w000000HmdOCAS\',\'0Hh5w000000HmdPCAS\',\'0Hh5w000000HmdwCAC\',\'0Hh5w000000HmdxCAC\',\'0Hh5w000000HmdQCAS\',\'0Hh5w000000HmdzCAC\',\'0Hh5w000000HmdyCAC\',\'0Hh5w000000HmcFCAS\',\'0Hh5w000000HmbyCAC\',\'0Hh5w000000HmdRCAS\',\'0Hh5w000000Hme0CAC\',\'0Hh5w000000HmbzCAC\',\'0Hh5w000000Hmc0CAC\',\'0Hh5w000000Hme1CAC\',\'0Hh5w000000HmdSCAS\',\'0Hh5w000000HmdTCAS\',\'0Hh5w000000Hme2CAC\',\'0Hh5w000000Hmc1CAC\',\'0Hh5w000000Hmc2CAC\',\'0Hh5w000000Hme3CAC\',\'0Hh5w000000Hme4CAC\',\'0Hh5w000000Hme5CAC\',\'0Hh5w000000HmdsCAC\',\'0Hh5w000000HmdtCAC\',\'0Hh5w000000HmduCAC\',\'0Hh5w000000HmdvCAC\',\'0Hh5w000000HmdqCAC\',\'0Hh5w000000HmcDCAS\',\'0Hh5w000000HmcECAS\',\'0Hh5w000000HmdrCAC\',\'0Hh5w000000HmdCCAS\',\'0Hh5w000000Hme6CAC\',\'0Hh5w000000HmdUCAS\',\'0Hh5w000000Hme7CAC\',\'0Hh5w000000HmdECAS\',\'0Hh5w000000Hmd0CAC\',\'0Hh5w000000HmcxCAC\',\'0Hh5w000000Hmd6CAC\',\'0Hh5w000000HmdDCAS\',\'0Hh5w000000HmdMCAS\'))'
        //);
    }
    global void execute(Database.BatchableContext bc, List<ServiceTerritory> scope){
        System.debug('****number of Service Territories:'+scope.size());
        System.debug('dump of scope ==   ' +scope.toString());

        // instantiate insert collection
        List<Shift> l_ShiftsToInsert = new List<Shift>();

        // instantiate map to load for each service territory the ServiceTerritoryMemberId <> ServiceResource
        //Map<String, Map<Id,SObject> > m_STtoSR = new Map<String, Map<Id,SObject> >();

        // unique all STs, prep for SOQL
        Set<Id> s_STs = new Set<Id>();
        // load the set with service territory ids
        for(ServiceTerritory st : scope) {
            s_STs.add(st.Id);
        }
        // build a mapping of the service territory members based on SR primary-key
        List<ServiceTerritoryMember> l_STM = [SELECT ServiceResourceId,ServiceTerritoryId,TerritoryType FROM ServiceTerritoryMember WHERE ServiceTerritoryId IN :s_STs AND TerritoryType = 'P' AND ServiceResourceId != null AND ServiceTerritoryId != null];

        // mapping of service resource to their service territory based on *primary* membership
        Map<Id,Id> m_SRtoST = new Map<Id,Id>();

        // reverse-lookup mapping for validation when creating shifts
        Map<Id,ServiceTerritoryMember> m_SRtoSTMReverseLookup = new Map<Id,ServiceTerritoryMember>();

        for(ServiceTerritoryMember stm : l_STM) {
            m_SRtoST.put(stm.ServiceResourceId, stm.ServiceTerritoryId);
            m_SRtoSTMReverseLookup.put(stm.ServiceResourceId, stm);
        }
        // Get all of the service resources for those service territories in SCOPE
        List<ServiceResource> l_SRs = [SELECT Id,Name,wkfsl__Employee__r.Id FROM ServiceResource WHERE Id IN(SELECT ServiceResourceId FROM ServiceTerritoryMember WHERE ServiceTerritoryId IN :s_STs) AND IsActive = true];

        // loop over all service resources we have collected from the service territories in scope
        for(ServiceResource sr : l_SRs) {
            //iterate over each day to create a shift
            Date currentDate = startTimeFrame.addDays(-1);

            // #DEBUG: Service Resource Identifier for reference
            System.debug('Service Resource Id = ' +sr.Id);
            System.debug('SRtoST territory id = ' +m_SRtoST.get(sr.Id)+ '    SRtoSTReverLookup territory id = ' +m_SRtoSTMReverseLookup.get(sr.Id).ServiceTerritoryId);

            // if the territory id is null, or if it doesn't match the Service Territory Membership for the Service Resource in context -- skip this Service Resource and don't add the shift
            //|| m_SRtoSTMReverseLookup.get(sr.Id).ServiceTerritoryId != m_SRtoST.get(sr.Id)
            if( m_SRtoST.get(sr.Id) == null || m_SRtoSTMReverseLookup.get(sr.Id).ServiceTerritoryId != m_SRtoST.get(sr.Id) ) {
                System.debug('ASDF123 Skipping this Service Resource = ' +sr.Id);
                continue;
            }

            while(currentDate<endTimeFrame){
                System.debug('Top of the while loop. Start Time, End Time, Current Date:  ' +startTimeFrame+ ' | ' +endTimeFrame+ ' | ' +currentDate);

                // forward one day from the last day
                currentDate=currentDate.addDays(1);

                // skip weekends
                DateTime this_DateTime = DateTime.newInstance(currentDate.year(), currentDate.month(), currentDate.day());
                String this_DayOfTheWeek = this_DateTime.format('EEEE');

                System.debug('----> this_DayOfTheWeek == ' +this_DayOfTheWeek);

                if(this_DayOfTheWeek == 'Saturday' || this_DayOfTheWeek == 'Sunday') {
                    System.debug('Found a weekend! = ' +this_DayOfTheWeek+ '   currentDate = ' +currentDate);
                    continue;
                }

                //randomly skipping days to have variation of shift patters
                Integer randomNumber = Integer.valueof((Math.random() * 10));
                if(randomNumber > 7){
                    continue;
                }

                Shift shft = new Shift();
                shft.ServiceResourceId=sr.Id;
                //shft.ServiceTerritoryId = m_SRtoST.get(sr.Id);
                //System.debug('Creating shift with following parameters: shft.ServiceResourceId = ' +shft.ServiceResourceId+ '  || shft.ServiceTerritoryId = ' +shft.ServiceTerritoryId+ '  ||||  Does shft.ServiceTerritoryId match ServiceTerritoryMember Lookup Id for this ServiceResource? = ' +m_SRtoSTMReverseLookup.get(shft.ServiceResourceId).ServiceTerritoryId );
                shft.StartTime= Datetime.newInstance(currentDate.year(), currentDate.month(), currentDate.day(), Utils_Random.generateRandomFromRange(7, 10), 0, 0);
                shft.EndTime=Datetime.newInstance(currentDate.year(), currentDate.month(), currentDate.day(), Utils_Random.generateRandomFromRange(13, 18), 0, 0);

                // fix shifts that are too long
                while( shft.EndTime.hour() - shft.StartTime.hour() > 10 ) {
                    System.debug('Too Long... Trimming shift length, Start Time =   ' +shft.StartTime+ '\n End Time = ' +shft.EndTime);
                    shft.EndTime = shft.EndTime.addHours(-1);
                }

                // fix shifts that are too short
                while( shft.EndTime.hour() - shft.StartTime.hour() < 7 ) {
                    System.debug('Too Short... Bulking shift length, Start Time =   ' +shft.StartTime+ '\n End Time = ' +shft.EndTime);
                    shft.EndTime = shft.EndTime.addHours(1);
                }

                shft.Status='Confirmed';
                shft.TimeSlotType = 'Normal';
                l_ShiftsToInsert.add(shft);
            }//While all days
        }//for all resources
        insert l_ShiftsToInsert;

    }//execute
    global void finish(Database.BatchableContext bc){

    }
}