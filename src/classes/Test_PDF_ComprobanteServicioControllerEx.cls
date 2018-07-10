@isTest
public without sharing class Test_PDF_ComprobanteServicioControllerEx {
    
    private static Account cuentaPrincipal {get; set;}
	private static Account compania {get; set;}
	private static Tipo_Producto_CIA__c tipoProductoCIA {get; set;}
	private static Producto_CIA__c productoCIA {get; set;}
	private static ServiceContract poliza {get; set;}
	private static Case caso {get; set;}
	private static WorkType tipoTrabajo {get; set;}
	private static WorkOrder ordenTrabajo {get; set;}
	private static ServiceAppointment citaServicio {get; set;}
    private static WorkOrderLineItem lineaOrdenTrabajo {get; set;}
    private static WorkOrderLineItem lineaOrdenTrabajo2 {get; set;}
    private static Baremo__c baremo {get;set;}
	
	public static Attachment firmaCliente;
	public static Attachment firmaProfesional ;
	
	public static List<WorkOrderLineItem> woItems;
	
	
    private static void inicializarVariables(){
		Baipas.establecerVariableControl();
		cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('WORTEN', '1516013658675', 'X8157623Y');
		insert cuentaPrincipal;
		compania = Util_Tests.crearCuentaCompania('WORTEN','1018','X1198020L');
		insert compania;
		tipoProductoCIA = Util_Tests.crearTipoProductoCIA('SegurCaixa - HOGAR','01',compania.ID);
		insert tipoProductoCIA;
		productoCIA = Util_Tests.crearProductoCIA('KIT 107','12345678',tipoProductoCIA.Id);
		insert productoCIA;
		poliza = Util_Tests.crearPolizaContrato('2277393',compania.Id,cuentaPrincipal.Id,productoCIA.Id);
		insert poliza;
		Baremo__c baremo = new Baremo__c();
		baremo.BAR_LKP_Compania__c = compania.Id;
		baremo.BAR_SEL_Gremio__c = '21';
		insert baremo;
		//Crear Baremo Incl
  		Baremo_IEC__c nuevoBaremoI = new Baremo_IEC__c();
  		Baremo_IEC__c nuevoBaremoE = new Baremo_IEC__c();
  		Baremo_IEC__c nuevoBaremoC = new Baremo_IEC__c();
  		
  		nuevoBaremoI.BAR_IEC_LKP_Baremo__c = baremo.Id;
  		nuevoBaremoE.BAR_IEC_LKP_Baremo__c = baremo.Id;
  		nuevoBaremoC.BAR_IEC_LKP_Baremo__c = baremo.Id;
  		nuevoBaremoI.Name = 'a1Q9E000000yayq';
  		nuevoBaremoE.Name = 'a1Q9E000000yoyq';
  		nuevoBaremoC.Name = 'a1Q9E000000yuyq';
  		nuevoBaremoI.BAR_IEC_SEL_Tipo__c = 'Inclusión';
  		nuevoBaremoC.BAR_IEC_SEL_Tipo__c = 'Condición';
  		nuevoBaremoE.BAR_IEC_SEL_Tipo__c = 'Exclusión';
  		nuevoBaremoI.BAR_IEC_TXT_Texto__c = 	'Antes de que el profesional acuda a su domicilio es importante que Vd haya decidido los trabajos a presupuestar';
  		nuevoBaremoC.BAR_IEC_TXT_Texto__c = 	'Quality text here';
  		nuevoBaremoE.BAR_IEC_TXT_Texto__c = 	'Quality text here';
  		insert nuevoBaremoI;
  		insert nuevoBaremoE;
  		insert nuevoBaremoC;
		caso = Util_Tests.crearCasoB2B(poliza.Id, cuentaPrincipal.Id, compania.Id);
		caso.CAS_LKP_Baremo__c = baremo.Id;
		caso.CAS_SEL_Gremio_Principal__c = '21';
		insert caso;
		tipoTrabajo = Util_Tests.crearTipoTrabajo('Tipo de Trabajo por Defecto','21', 2);
		insert tipoTrabajo;
		ordenTrabajo = Util_Tests.crearOrdenTrabajo('19210.0','21',tipoTrabajo.Id,caso.Id);
		ordenTrabajo.AccountId = cuentaPrincipal.Id;
		ordenTrabajo.Status = '002';
		insert ordenTrabajo;
		datetime fechaInicio = datetime.newInstance(2018, 02, 21);
		datetime fechaVencimiento = datetime.newInstance(2018, 02, 24);
		citaServicio = Util_Tests.crearCitaServicio('MADRID', 'España', '28025','Madrid', 'CALLE Chimbo 22 2 B', fechaInicio, fechaVencimiento);
		citaServicio.Status = 'Pte. de asignar';
		citaServicio.ParentRecordId = ordenTrabajo.Id;
        citaServicio.ActualStartTime = datetime.newInstance(2018, 04, 02);
        citaServicio.ActualEndTime = datetime.newInstance(2018, 04, 02);
		insert citaServicio;
		ordenTrabajo.OTR_LKP_Primera_Cita__c = citaServicio.Id;
		update ordenTrabajo;
        lineaOrdenTrabajo = Util_Tests.crearNuevaPartidaTrabajo(ordenTrabajo.Id);
        insert lineaOrdenTrabajo;
        lineaOrdenTrabajo2 = Util_Tests.crearNuevaPartidaTrabajo(ordenTrabajo.Id);
        insert lineaOrdenTrabajo2;
        
        
        
        //Nuevo
        Attachment firmaCliente = new Attachment ();
        Attachment firmaProfesional = new Attachment ();
        EmailMessage emailm = new EmailMessage();
        emailm.FromAddress ='prueba@prueba.com';
        emailm.FromName = 'Prueba Name';
        //emailm.HtmlBody = '<html xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word" xmlns:m="http://schemas.microsoft.com/office/2004/12/omml" xmlns="http://www.w3.org/TR/REC-html40"> <head> <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"> <meta name="Generator" content="Microsoft Word 15 (filtered medium)"> <!--[if !mso]><style>v\:* {behavior:url(#default#VML);} o\:* {behavior:url(#default#VML);} w\:* {behavior:url(#default#VML);} .shape {behavior:url(#default#VML);} </style><![endif]--><style><!-- /* Font Definitions */ @font-face {font-family:"Cambria Math"; panose-1:2 4 5 3 5 4 6 3 2 4;} @font-face {font-family:Calibri; panose-1:2 15 5 2 2 2 4 3 2 4;} @font-face {font-family:Leelawadee; panose-1:2 11 5 2 4 2 4 2 2 3;} /* Style Definitions */ p.MsoNormal, li.MsoNormal, div.MsoNormal {margin:0cm; margin-bottom:.0001pt; font-size:11.0pt; font-family:"Calibri",sans-serif; mso-fareast-language:EN-US;} a:link, span.MsoHyperlink {mso-style-priority:99; color:#0563C1; text-decoration:underline;} a:visited, span.MsoHyperlinkFollowed {mso-style-priority:99; color:#954F72; text-decoration:underline;} span.EstiloCorreo17 {mso-style-type:personal-compose; font-family:"Leelawadee",sans-serif; color:windowtext; font-weight:normal; font-style:normal;} .MsoChpDefault {mso-style-type:export-only; font-family:"Calibri",sans-serif; mso-fareast-language:EN-US;} @page WordSection1 {size:612.0pt 792.0pt; margin:70.85pt 3.0cm 70.85pt 3.0cm;} div.WordSection1 {page:WordSection1;} --></style><!--[if gte mso 9]><xml> <o:shapedefaults v:ext="edit" spidmax="1026" /> </xml><![endif]--><!--[if gte mso 9]><xml> <o:shapelayout v:ext="edit"> <o:idmap v:ext="edit" data="1" /> </o:shapelayout></xml><![endif]--> </head> <body lang="ES" link="#0563C1" vlink="#954F72"> <div class="WordSection1"> <p class="MsoNormal"><span style="font-family:&quot;Leelawadee&quot;,sans-serif">FYI<o:p></o:p></span></p> <p class="MsoNormal"><span style="font-family:&quot;Leelawadee&quot;,sans-serif"><o:p>&nbsp;</o:p></span></p> <table class="MsoNormalTable" border="0" cellspacing="0" cellpadding="0" style="border-collapse:collapse"> <tbody> <tr> <td width="276" style="width:207.3pt;padding:0cm 5.4pt 0cm 5.4pt"> <p class="MsoNormal"><span style="font-size:9.0pt;mso-fareast-language:ES"><img width="262" height="127" id="Imagen_x0020_1" src="https://homeserve-es--PartCopy--c.cs87.content.force.com/servlet/servlet.FileDownload?file=00P8E000005DyqZ" alt="cid:image001.png@01D33DBB.5905D710"><o:p></o:p></span></p> </td> <td width="244" style="width:182.85pt;padding:0cm 5.4pt 0cm 5.4pt"> <p class="MsoNormal"><b><span lang="PT-BR" style="font-size:8.0pt;font-family:&quot;Arial&quot;,sans-serif;color:black;mso-fareast-language:ES">Cristian Trujillo</span></b><span lang="PT-BR" style="font-size:8.0pt;font-family:&quot;Times New Roman&quot;,serif;mso-fareast-language:ES"><o:p></o:p></span></p> <p class="MsoNormal"><span style="font-size:8.0pt;font-family:&quot;Arial&quot;,sans-serif;color:black;mso-fareast-language:ES">Av. Manoteras, 52. </span><span style="font-size:8.0pt;font-family:&quot;Times New Roman&quot;,serif;mso-fareast-language:ES"><o:p></o:p></span></p> <p class="MsoNormal"><span style="font-size:8.0pt;font-family:&quot;Arial&quot;,sans-serif;color:black;mso-fareast-language:ES">28050 Madrid</span><span style="font-size:8.0pt;font-family:&quot;Times New Roman&quot;,serif;mso-fareast-language:ES"><o:p></o:p></span></p> <p class="MsoNormal"><b><span style="font-size:8.0pt;font-family:&quot;Arial&quot;,sans-serif;color:black;mso-fareast-language:ES">Tel</span></b><span style="font-size:8.0pt;font-family:&quot;Arial&quot;,sans-serif;color:black;mso-fareast-language:ES">.: &#43;34 91 749 00 00 </span><span style="font-size:8.0pt;font-family:&quot;Times New Roman&quot;,serif;mso-fareast-language:ES"><o:p></o:p></span></p> <p class="MsoNormal"><span style="mso-fareast-language:ES"><a href="http://www.everis.com/"><span lang="EN-US" style="font-size:8.0pt;font-family:&quot;Arial&quot;,sans-serif;color:black">everis.com</span></a></span><span lang="EN-US" style="font-size:8.0pt;font-family:&quot;Arial&quot;,sans-serif;color:black;mso-fareast-language:ES"> | </span><span style="mso-fareast-language:ES"><a href="http://www.everis.cloud/"><span lang="EN-US" style="font-size:8.0pt;font-family:&quot;Arial&quot;,sans-serif;color:black">everis.cloud</span></a></span><span lang="EN-US" style="font-size:8.0pt;font-family:&quot;Arial&quot;,sans-serif;color:black;mso-fareast-language:ES"><o:p></o:p></span></p> <p class="MsoNormal"><span style="font-size:9.0pt;mso-fareast-language:ES"><o:p>&nbsp;</o:p></span></p> <p class="MsoNormal"><span style="font-size:9.0pt;mso-fareast-language:ES"><o:p>&nbsp;</o:p></span></p> </td> </tr> </tbody> </table> <p class="MsoNormal"><span style="mso-fareast-language:ES"><o:p>&nbsp;</o:p></span></p> <p class="MsoNormal"><o:p>&nbsp;</o:p></p> </div> <br> <hr> <font face="Arial" color="Gray" size="1"><br> AVISO DE CONFIDENCIALIDAD.<br> Este correo y la información contenida o adjunta al mismo es privada y confidencial y va dirigida exclusivamente a su destinatario. everis informa a quien pueda haber recibido este correo por error que contiene información confidencial cuyo uso, copia, reproducción o distribución está expresamente prohibida. Si no es Vd. el destinatario del mismo y recibe este correo por error, le rogamos lo ponga en conocimiento del emisor y proceda a su eliminación sin copiarlo, imprimirlo o utilizarlo de ningún modo.<br> <br> CONFIDENTIALITY WARNING.<br> This message and the information contained in or attached to it are private and confidential and intended exclusively for the addressee. everis informs to whom it may receive it in error that it contains privileged information and its use, copy, reproduction or distribution is prohibited. If you are not an intended recipient of this E-mail, please notify the sender, delete it and do not read, act upon, print, disclose, copy, retain or redistribute any portion of this E-mail.<br> </font> </body> </html>';
        emailm.Subject = 'prueba';
        emailm.TextBody = 'prueba';
        emailm.ToAddress = 'pruebato@prueba.com';
        emailm.parentId = caso.Id;
        insert emailm;
        firmaCliente.Name  = citaServicio.AppointmentNumber + Label.IMG_SUFIJO_FIRMA_CLIENTE;
        firmaProfesional.Name = citaServicio.AppointmentNumber + Label.IMG_SUFIJO_FIRMA_PROFESIONAL;
        firmaCliente.contentType = 'image/png';
        firmaProfesional.contentType = 'image/png';
        firmaProfesional.body =  Blob.valueof('<Base64 String>');
        firmaCliente.body  = Blob.valueof('<Base64 String>');
        firmaCliente.ParentId =emailm.Id;
        firmaProfesional.ParentId = emailm.Id;
        insert firmaCliente;
        insert firmaProfesional;
        
		woItems = new List<WorkOrderLineItem>();
		
		for (Integer i= 0 ; i<10 ; i++){
			WorkOrderLineItem lineItem = new WorkOrderLineItem();
			lineItem.WorkOrderId =  ordenTrabajo.Id ;
			lineItem.PAR_TXT_Baremo_Codigo__c = '1212';
			lineItem.Description = 'asdadasd';
			lineItem.PAR_NUM_Unidades__c = 15.0;
			lineItem.PAR_DIV_Precio_Unitario_Venta__c  = 12.5;
			lineItem.PAR_POR_Porcentaje_Imp_Cia_Cliente__c = 10.0;
			woItems.add(lineItem);
		}
		insert woItems; 
        
       
		//String firmaProfesional = cita.AppointmentNumber + Label.IMG_SUFIJO_FIRMA_PROFESIONAL;
        
	}
	
	@isTest
	public static void Testing(){
		inicializarVariables();
		test.startTest();
		
		ApexPages.currentPage().getParameters().put('idioma','ES');
        ApexPages.currentPage().getParameters().put('id',caso.Id);
        //new
        caso.CAS_DAT_Fecha_Ocurrencia__c = date.newInstance(2018, 04, 02);
        update caso;
		ApexPages.StandardController sc = new ApexPages.StandardController(caso);
		PDF_ComprobanteServicioControllerExt prueba = new PDF_ComprobanteServicioControllerExt(sc);
		test.stopTest();
		
		
		//casoActual.CAS_LKP_Baremo__r.BAR_LKP_Agrupador_Baremo__c 
	}
	
	
}