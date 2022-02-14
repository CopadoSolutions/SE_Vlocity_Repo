<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Default_Requested_Completion_Date</fullName>
        <field>vlocity_cmt__RequestedCompletionDate__c</field>
        <formula>NOW() + (5/24/60)</formula>
        <name>Set Default Requested Completion Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Set Default Requested Completion Date</fullName>
        <actions>
            <name>Set_Default_Requested_Completion_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order.vlocity_cmt__RequestedCompletionDate__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Set Default Requested Completion Date</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
