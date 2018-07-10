/**
* Clase de respuesta cuando se devuelve una lista de órdenes de trabajo
* Se utiliza en la clase "Rest_ConsultaCaso" 
*
* @author everis
* @version 1.0
*/
global without sharing class Rest_WorkOrder_RP {
	public String WorkOrderNumber{get;set;}
	public String Status{get;set;}
	public String estadoServicioLiteral{get;set;}
	public String IdOrdenTrabajo{get;set;}
	public DateTime OTR_DAT_Fecha_cambio_estado{get;set;}
	public String OTR_SEL_Gremio{get;set;}
	public String gremioLiteral{get;set;}
	public DateTime StartDate{get;set;}
	public DateTime StopStartDate{get;set;}
	public Date OTR_DAT_Fecha_Primera_Cita{get;set;}
	public String OTR_SEL_Rango_Primera_Cita{get;set;}
	public Date OTR_DAT_Fecha_Ultima_Cita{get;set;}
	public String OTR_SEL_Rango_Ultima_Cita{get;set;}
	public String AppointmentNumber{get;set;}
	public String IdFactura{get;set;}
	public String FAC_TXT_Numero_factura{get;set;}
	public Double OTR_RES_Importe_partidas{get;set;}
}