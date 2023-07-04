/**
 * @description       :
 * @author            : Shawn Butters (butters@salesforce.com)
 * @last modified on  : 10-16-2020
 * @last modified by  : Shawn Butters (butters@salesforce.com)
 * Modifications Log
 * Ver   Date         Author                                   Modification
 * 1.0   10-16-2020   Shawn Butters (butters@salesforce.com)   Initial Version
**/
public with sharing class WdcDemo_FlowControllerInterface {
    public WdcDemo_FlowControllerInterface() {

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