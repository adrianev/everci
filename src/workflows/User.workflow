<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Temporary_access_to_the_user</fullName>
        <field>IsActive</field>
        <literalValue>0</literalValue>
        <name>Temporary access to the user</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Temp Access for Oracle Support</fullName>
        <active>false</active>
        <criteriaItems>
            <field>User.Username</field>
            <operation>equals</operation>
            <value>federico.palacios@oracle.com</value>
        </criteriaItems>
        <description>Acceso temporal a soporte de Oracle para revisión integración CPQ</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Temporary_access_to_the_user</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>User.LastModifiedDate</offsetFromField>
            <timeLength>72</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
