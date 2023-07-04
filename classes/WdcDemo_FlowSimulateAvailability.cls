/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-05-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   11-05-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class WdcDemo_FlowSimulateAvailability {
    public WdcDemo_FlowSimulateAvailability() {

    }

    @InvocableMethod
    public static List<Results> doStuff() {
        Results[] response = new Results[0];
        
        return response;
    }

    public class Results {
        @InvocableVariable (label='Data processing output' description='The results of WdcDemo_FlowControllerInterface method invocations' required=true)
        public Boolean isSuccess;
    }
}