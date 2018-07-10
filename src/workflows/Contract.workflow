<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>WF_FU_Status_finalizado</fullName>
        <field>Status</field>
        <literalValue>Finalizado</literalValue>
        <name>Status: finalizado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Contrato pasa a finalizado</fullName>
        <actions>
            <name>WF_FU_Status_finalizado</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Cuando llegue la fecha de fin del contrato, pondremos el contrato como finalizado</description>
        <formula>EndDate =  TODAY()</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
