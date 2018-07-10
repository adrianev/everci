<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Marcar_check_baja</fullName>
        <field>CUE_CAS_Dada_de_Baja__c</field>
        <literalValue>1</literalValue>
        <name>Marcar check baja</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>WFU_Fecha_de_baja</fullName>
        <description>Actualizamos el campo fecha baja con la fecha en la que se marca el check dado de baja</description>
        <field>CUE_DAT_Fecha_Baja__c</field>
        <formula>DATETIMEVALUE(TODAY())</formula>
        <name>Fecha de baja</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Padre_de_Baja</fullName>
        <active>false</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cliente B2B/B2B2C principal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.CUE_CAS_Dada_de_Baja__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.CUE_CAS_Activado__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>cuando el padre esta inactivo o de baja los hijos estarán tambien de baja</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
