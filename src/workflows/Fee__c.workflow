<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Change_owner</fullName>
        <field>OwnerId</field>
        <lookupValue>Queue_Test</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Fee Assignment</fullName>
        <actions>
            <name>Change_owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Fee__c.Test_Picklist__c</field>
            <operation>equals</operation>
            <value>4</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
