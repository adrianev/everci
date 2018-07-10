<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Blanqueo_fecha_baja</fullName>
        <field>DPC_DAT_Fecha_Baja__c</field>
        <name>Blanqueo fecha baja</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Alarma Expiración Documento</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Documentos_Profesionales_Contrato__c.DPC_DAT_Fecha_Expiracion__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Alarma Expiración Documento. Faltan 30 días para la expiración de algún documento.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Alerta_expiracion_documento</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Documentos_Profesionales_Contrato__c.DPC_DAT_Fecha_Expiracion__c</offsetFromField>
            <timeLength>-30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Dar de baja profesional</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Documentos_Profesionales_Contrato__c.DPC_DAT_Fecha_Baja__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Actualiza un documento de profesional que ha expirado para dar de baja al profesional correspondiente</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Blanqueo_fecha_baja</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Documentos_Profesionales_Contrato__c.DPC_DAT_Fecha_Baja__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Profesional_Baja_Por_Expiración_Documento</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Documentos_Profesionales_Contrato__c.DPC_DAT_Fecha_Expiracion__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Un Profesional Contrato ha pasado a estado &quot;Baja Temporal&quot; al expirar alguno de sus documentos requeridos</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Profesional_Baja</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Documentos_Profesionales_Contrato__c.DPC_DAT_Fecha_Expiracion__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <tasks>
        <fullName>Alerta_expiracion_documento</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>-30</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Documentos_Profesionales_Contrato__c.DPC_DAT_Fecha_Expiracion__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>En Curso</status>
        <subject>Alerta Expiración Documento</subject>
    </tasks>
    <tasks>
        <fullName>Profesional_Baja</fullName>
        <assignedToType>owner</assignedToType>
        <description>La cuenta Profesional Contrato va ha pasar a estado &quot;Baja Temporal&quot; en los próximos días al expirar uno de sus documentos requeridos.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Documentos_Profesionales_Contrato__c.DPC_DAT_Fecha_Expiracion__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>En Curso</status>
        <subject>Profesional dado de Baja</subject>
    </tasks>
    <tasks>
        <fullName>Profesional_Vetado_RC</fullName>
        <assignedToType>owner</assignedToType>
        <description>La cuenta Profesional Contrato ha pasado a estafo &quot;Vetado&quot; al expirar uno de sus documentos requeridos (Recibo del Seguro de Responsabilidad Civil).</description>
        <dueDateOffset>30</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Documentos_Profesionales_Contrato__c.DPC_DAT_Fecha_Expiracion__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>En Curso</status>
        <subject>Profesional Vetado Recibo RC</subject>
    </tasks>
</Workflow>
