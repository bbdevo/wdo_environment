<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>wkitsm__ITSCCaseResolvedEmailAlert</fullName>
        <description>ITSC - Send email notification when a case is resolved</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>wkitsm__ITSCEmailNotifications/wkitsm__ITSCCaseResolved</template>
    </alerts>
    <alerts>
        <fullName>wkitsm__ITSCCaseStatusEmailAlert</fullName>
        <description>ITSC - Send email notification when a case status is changed</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>wkitsm__ITSCEmailNotifications/wkitsm__ITSCStatusChange</template>
    </alerts>
    <alerts>
        <fullName>wkitsm__ITSCNewCaseEmailAlert</fullName>
        <description>ITSC - Send email notification when a new case is created</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>wkitsm__ITSCEmailNotifications/wkitsm__ITSCNewCase</template>
    </alerts>
    <alerts>
        <fullName>wkitsm__MajorIncidentActionTeamNotificationAlert</fullName>
        <description>Major Incident Action Team Notification Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>wkitsm__ITSCEmailNotifications/wkitsm__ITSCMIUpdate</template>
    </alerts>
    <fieldUpdates>
        <fullName>ChangePriorityToHigh</fullName>
        <field>Priority</field>
        <literalValue>High</literalValue>
        <name>Changes the case priority to high.</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Approval_Status_to_Mgr_Approved</fullName>
        <field>Status</field>
        <literalValue>Approved by Manager</literalValue>
        <name>Set Approval Status to Mgr Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Approval_Status_to_Mgr_Rejected</fullName>
        <field>Status</field>
        <literalValue>Rejected by Manager</literalValue>
        <name>Set Approval Status to Mgr Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Case_Status_to_Denied</fullName>
        <field>Status</field>
        <literalValue>Denied</literalValue>
        <name>Set Case Status to Denied</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Case_Status_to_Working</fullName>
        <field>Status</field>
        <literalValue>In Progress</literalValue>
        <name>Set Case Status to Working</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status_to_Submitted</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Submitted to Manager</literalValue>
        <name>Update Approval Status to Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Status_to_Denied</fullName>
        <field>Status</field>
        <literalValue>Denied</literalValue>
        <name>Update Case Status to Denied</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Status_to_In_Progress</fullName>
        <field>Status</field>
        <literalValue>In Progress</literalValue>
        <name>Update Case Status to In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Status_to_Mgr_Review</fullName>
        <field>Status</field>
        <literalValue>Manager Review</literalValue>
        <name>Update Case Status to Mgr Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Rejected_by_Manager</fullName>
        <field>Status</field>
        <literalValue>Rejected by Manager</literalValue>
        <name>Update Status to Rejected by Manager</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_to_Approved</fullName>
        <field>Status</field>
        <literalValue>Approved by Manager</literalValue>
        <name>Update to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>wkitsm__Update_Change_Status_Approved</fullName>
        <field>Status</field>
        <literalValue>Approved</literalValue>
        <name>Update Change Status - Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>wkitsm__Update_Change_Status_RFC</fullName>
        <field>Status</field>
        <literalValue>Request for Change</literalValue>
        <name>Update Change Status - RFC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>wkitsm__Update_Change_Status_Rejected</fullName>
        <field>Status</field>
        <literalValue>Rejected</literalValue>
        <name>Update Change Status - Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>wkitsm__Update_Escalation</fullName>
        <field>IsEscalated</field>
        <literalValue>1</literalValue>
        <name>Update Escalation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>wkitsm__ITSC - Case Resolved</fullName>
        <actions>
            <name>wkitsm__ITSCCaseResolvedEmailAlert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>ITSC - Workflow rule when a case is resolved</description>
        <formula>AND(  NOT($Setup.wkitsm__ItscPublicSettings__c.wkitsm__DoesSkipWorkflowRules__c),   OR(   RecordType.DeveloperName=&apos;Incident&apos;,   RecordType.DeveloperName=&apos;Request&apos;  ),  ISPICKVAL(Status, &apos;Resolved&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>wkitsm__ITSC - Case Status Change</fullName>
        <actions>
            <name>wkitsm__ITSCCaseStatusEmailAlert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>ITSC - Workflow rule when a case status is changed</description>
        <formula>AND(  NOT($Setup.wkitsm__ItscPublicSettings__c.wkitsm__DoesSkipWorkflowRules__c),   OR(   RecordType.DeveloperName=&apos;Incident&apos;,   RecordType.DeveloperName=&apos;Request&apos;  ),  NOT(ISPICKVAL(Status, &apos;Resolved&apos;)),  ISCHANGED(Status) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>wkitsm__ITSC - New Case</fullName>
        <actions>
            <name>wkitsm__ITSCNewCaseEmailAlert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>ITSC - Workflow rule for new case creation</description>
        <formula>AND(   NOT($Setup.wkitsm__ItscPublicSettings__c.wkitsm__DoesSkipWorkflowRules__c),   OR(   RecordType.DeveloperName=&apos;Incident&apos;,   RecordType.DeveloperName=&apos;Request&apos;  ) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
