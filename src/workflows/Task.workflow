<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Modificar_campo_Public</fullName>
        <field>IsVisibleInSelfService</field>
        <literalValue>1</literalValue>
        <name>Modificar campo Public</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Comunidad - Registro llamada público</fullName>
        <actions>
            <name>Modificar_campo_Public</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.TaskSubtype</field>
            <operation>equals</operation>
            <value>Llamada</value>
        </criteriaItems>
        <description>Las tareas de registro de llamadas se hacen públicas por defecto para que puedan ser visualizadas en la comunidad</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
