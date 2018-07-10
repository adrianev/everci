<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Actualizar_OTR_DAT_Fecha_Hora_Cambio_Sem</fullName>
        <description>se añade 1 seg a la fecha para que salte el trg de wo</description>
        <field>OTR_DAT_Fecha_Hora_Cambio_semaforo__c</field>
        <name>Actualizar OTR_DAT_Fecha_Hora_Cambio_</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Actualizar_estado_Orden_Trabajo</fullName>
        <description>Se actualiza el Estado de la WO</description>
        <field>Status</field>
        <literalValue>501</literalValue>
        <name>Actualizar estado WO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Actualizar_estado_WO</fullName>
        <description>Se actualiza el Estado de la WO a Revisado</description>
        <field>Status</field>
        <literalValue>501</literalValue>
        <name>Actualizar estado WO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Actualizar_subestado_Orden_Tr</fullName>
        <description>Se actualiza el subestado de la Orden de Trabajo</description>
        <field>OTR_SEL_Subestado__c</field>
        <literalValue>Revisado Automáticamente sin intervención gestor</literalValue>
        <name>Actualizar subestado WO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Actualizar_subestado_WO</fullName>
        <description>Se actualiza el subestado de la WO</description>
        <field>OTR_SEL_Subestado__c</field>
        <literalValue>08</literalValue>
        <name>Actualizar subestado WO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Blanquear_Fecha_Generar_Tarea</fullName>
        <field>OTR_DAT_Generar_Tarea_Semaforo__c</field>
        <name>Blanquear Fecha Generar Tarea</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Company_Wokflow</fullName>
        <field>CAS_TXT_WF_Compania__c</field>
        <formula>Case.CAS_LKP_Compania__r.Name</formula>
        <name>Company Wokflow</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Fecha_cierre_de_servicio</fullName>
        <field>OTR_DAT_Fecha_Cierre_servicio__c</field>
        <formula>NOW()</formula>
        <name>Fecha cierre de servicio</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Limpiar_Fecha_Despertar</fullName>
        <field>OTR_DAT_Fecha_Despertar__c</field>
        <name>Limpiar Fecha Despertar</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OT_Estado_Inactivo</fullName>
        <field>Status</field>
        <literalValue>997</literalValue>
        <name>OT Estado Inactivo</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>actualizacion_estado_WO</fullName>
        <field>Status</field>
        <literalValue>501</literalValue>
        <name>actualización estado WO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>actulizar_valor_fecha_semaforo</fullName>
        <field>OTR_DAT_Fecha_Hora_Cambio_semaforo__c</field>
        <name>actulizar valor fecha semaforo</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>fecha_revision</fullName>
        <field>OTR_DAT_Fecha_revision__c</field>
        <formula>NOW()</formula>
        <name>fecha revisión</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>AvisoLimiteTiempoEstado</fullName>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.OTR_DAT_Fecha_Despertar__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.Status</field>
            <operation>notEqual</operation>
            <value>888</value>
        </criteriaItems>
        <description>Genera tarea cuando se cumple la fecha estimada cambio de estado del servicio</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Limpiar_Fecha_Despertar</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Fecha_de_para_cuando_vencida</name>
                <type>Task</type>
            </actions>
            <offsetFromField>WorkOrder.OTR_DAT_Fecha_Despertar__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Comunidad - Mapear Compañia</fullName>
        <actions>
            <name>Company_Wokflow</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow para mapear el campo Company y hacerlo visible en el Sharing Rules</description>
        <formula>(!ISNULL(Case.CAS_LKP_Compania__c)) &amp;&amp; CAS_TXT_WF_Compania__c &lt;&gt; Case.CAS_LKP_Compania__r.Name</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Fecha Despertar Servicio Dormido</fullName>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.OTR_DAT_Fecha_Despertar__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.Status</field>
            <operation>equals</operation>
            <value>888</value>
        </criteriaItems>
        <description>Cuando llegue la fecha de despertar de una WO Inactiva pendiente de cliente, se genera una tarea al gestor de la WO y se cambia el estado a inactiva</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Limpiar_Fecha_Despertar</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>OT_Estado_Inactivo</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>AvisoServicioDormido</name>
                <type>Task</type>
            </actions>
            <offsetFromField>WorkOrder.OTR_DAT_Fecha_Despertar__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Fecha Vencimiento Paracuando Servicio</fullName>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.OTR_DAT_Fecha_Despertar__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.Status</field>
            <operation>notEqual</operation>
            <value>888</value>
        </criteriaItems>
        <description>Cuando llegue la fecha de paracuando de una WO, se genera una tarea al gestor de la WO.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Limpiar_Fecha_Despertar</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Fecha_estimacion_desbloqueo_vencida</name>
                <type>Task</type>
            </actions>
            <offsetFromField>WorkOrder.OTR_DAT_Fecha_Despertar__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Revision_DeclaracionResponsable</fullName>
        <active>false</active>
        <criteriaItems>
            <field>WorkOrder.Status</field>
            <operation>equals</operation>
            <value>701</value>
        </criteriaItems>
        <description>Manda una tarea al gestor del caso si la Declaración Responsable se ha generado de forma correcta.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Tarea Semaforo</fullName>
        <active>true</active>
        <criteriaItems>
            <field>WorkOrder.OTR_DAT_Generar_Tarea_Semaforo__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Blanquear_Fecha_Generar_Tarea</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>WorkOrder.OTR_DAT_Generar_Tarea_Semaforo__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>creacion de eventos E21</fullName>
        <active>true</active>
        <description>cuando el campo wo.OTR_DAT_Fecha_Hora_Cambio_semaforo__c &gt; que NOW() se lanzará un job que cree el evento E21 y vaya actualizandolo dia a dia</description>
        <formula>OTR_DAT_Fecha_Hora_Cambio_semaforo__c != null</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>actulizar_valor_fecha_semaforo</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>WorkOrder.OTR_DAT_Fecha_Hora_Cambio_semaforo__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>revisión automática WO</fullName>
        <active>true</active>
        <description>Cuando son asistencias contado, hay albarán adjunto y el importe de la suma de sus partidas es menor que 2000€ se cambiará el estado de la WO a Revisado automáticamente a las 48 horas</description>
        <formula>IF(CASE(Case.CAS_LKP_Procedencia__r.Name,
&quot;555001&quot;, &quot;true&quot;,
&quot;103601&quot;, &quot;true&quot;,
&quot;104201&quot;, &quot;true&quot;,
&quot;103501&quot;, &quot;true&quot;,
&quot;507503&quot;, &quot;true&quot;,
&quot;103101&quot;, &quot;true&quot;,
&quot;507101&quot;, &quot;true&quot;,
&quot;101701&quot;, &quot;true&quot;,
&quot;104301&quot;, &quot;true&quot;,
&quot;900001&quot;, &quot;true&quot;,
&quot;900006&quot;, &quot;true&quot;,
&quot;503002&quot;, &quot;true&quot;,
&quot;508104&quot;, &quot;true&quot;,
&quot;540102&quot;, &quot;true&quot;,
&quot;103301&quot;, &quot;true&quot;,
&quot;103401&quot;, &quot;true&quot;,
&quot;530301&quot;, &quot;true&quot;,
&quot;103701&quot;, &quot;true&quot;,
&quot;104001&quot;, &quot;true&quot;,
&quot;502401&quot;, &quot;true&quot;,
&quot;100801&quot;, &quot;true&quot;,
&quot;102101&quot;, &quot;true&quot;,
&quot;104101&quot;, &quot;true&quot;,
&quot;530401&quot;, &quot;true&quot;,
&quot;102301&quot;, &quot;true&quot;,
&quot;104701&quot;, &quot;true&quot;,
&quot;103001&quot;, &quot;true&quot;,
&quot;511102&quot;, &quot;true&quot;,
&quot;101801&quot;, &quot;true&quot;,
&quot;104401&quot;, &quot;true&quot;,
&quot;104501&quot;, &quot;true&quot;,
&quot;507505&quot;, &quot;true&quot;,
&quot;554002&quot;, &quot;true&quot;,
&quot;&quot;
)= &quot;true&quot;, AND( 
OTR_FOR_Tipo_de_Caso__c = &quot;Asistencia&quot;,
OTR_RES_Liquidar_prof_AI__c &lt; 2000,
TEXT(Status) = &quot;994&quot;),false
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Actualizar_subestado_WO</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>actualizacion_estado_WO</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>WorkOrder.LastModifiedDate</offsetFromField>
            <timeLength>48</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <tasks>
        <fullName>AvisoServicioDormido</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>5</priority>
        <protected>false</protected>
        <status>En Curso</status>
        <subject>Avisar a cliente por fecha límite de servicio dormido</subject>
    </tasks>
    <tasks>
        <fullName>Fecha_de_para_cuando_vencida</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>5</priority>
        <protected>false</protected>
        <status>En Curso</status>
        <subject>Fecha de para cuando vencida</subject>
    </tasks>
    <tasks>
        <fullName>Fecha_estimacion_desbloqueo_vencida</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>10</priority>
        <protected>false</protected>
        <status>En Curso</status>
        <subject>Fecha estimación desbloqueo vencida</subject>
    </tasks>
    <tasks>
        <fullName>cita_servicio_workOrder</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>WorkOrder.OTR_DAT_Fecha_Hora_Tarea_Sin_Cita__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>En Curso</status>
        <subject>Asignación cita de servicio a servicio</subject>
    </tasks>
</Workflow>
