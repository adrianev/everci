<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Se_avisa</fullName>
        <description>Se avisa al Gerente de Operaciones que se inicia el Proceso de Aprobación</description>
        <protected>false</protected>
        <recipients>
            <recipient>eaguerad.homeserve@everis.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Email_de_aprobacion_evento</template>
    </alerts>
    <fieldUpdates>
        <fullName>Estado_Aprobado</fullName>
        <field>EV_AB_SEL_Estado__c</field>
        <literalValue>02</literalValue>
        <name>Estado Aprobado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Estado_Rechazado</fullName>
        <field>EV_AB_SEL_Estado__c</field>
        <literalValue>03</literalValue>
        <name>Estado Rechazado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Evento_Rechazado</fullName>
        <field>EV_AB_SEL_Estado__c</field>
        <literalValue>03</literalValue>
        <name>Evento Rechazado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Evento_Rechazado2</fullName>
        <field>EV_AB_SEL_Estado__c</field>
        <literalValue>03</literalValue>
        <name>Evento Rechazado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <tasks>
        <fullName>Evento_Rechazado</fullName>
        <assignedTo>ggonzaji.homeserve@everis.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>Debe revisar el evento nuevamente</description>
        <dueDateOffset>10</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>En Curso</status>
        <subject>Evento Rechazado</subject>
    </tasks>
    <tasks>
        <fullName>Evento_Rechazado2</fullName>
        <assignedTo>ggonzaji.homeserve@everis.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>10</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>En Curso</status>
        <subject>Evento Rechazado</subject>
    </tasks>
    <tasks>
        <fullName>Evento_Rechazado3</fullName>
        <assignedTo>plastra.homeserve@everis.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>10</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>En Curso</status>
        <subject>Evento Rechazado</subject>
    </tasks>
    <tasks>
        <fullName>Evento_Rechazado4</fullName>
        <assignedTo>ggonzaji.homeserve@everis.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>10</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>En Curso</status>
        <subject>Evento Rechazado</subject>
    </tasks>
    <tasks>
        <fullName>Flujo_Aprobacion_Eventos</fullName>
        <assignedTo>plastra.homeserve@everis.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>10</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>En Curso</status>
        <subject>Flujo Aprobación Eventos</subject>
    </tasks>
    <tasks>
        <fullName>Pendiente_de_Aprobaci_n_Evento</fullName>
        <assignedTo>ggonzaji.homeserve@everis.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>10</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>En Curso</status>
        <subject>Pendiente de Aprobación Evento</subject>
    </tasks>
    <tasks>
        <fullName>Pendiente_de_Aprobacion_Evento2</fullName>
        <assignedTo>plastra.homeserve@everis.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>10</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>En Curso</status>
        <subject>Pendiente de Aprobación Evento</subject>
    </tasks>
    <tasks>
        <fullName>Pendiente_de_Aprobacion_Evento3</fullName>
        <assignedTo>ggonzaji.homeserve@everis.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>10</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>En Curso</status>
        <subject>Pendiente de Aprobación Evento</subject>
    </tasks>
    <tasks>
        <fullName>Pendiente_de_Aprobacion_Evento5</fullName>
        <assignedTo>plastra.homeserve@everis.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>10</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>En Curso</status>
        <subject>Pendiente de Aprobación Evento</subject>
    </tasks>
</Workflow>
