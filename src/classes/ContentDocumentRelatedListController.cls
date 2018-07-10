public without sharing class ContentDocumentRelatedListController{

   	public List<EntradaDocumento> contentDocumentList {get; set;}
    public String selected{get; set;}
    public List<String> dynamiclist{get; set;}
    public Id deleteContentDocument{get; set;}
    private Account acc;
    public Id adjuntoId{get; set;}
    public Boolean isNew{get; set;}
    public Boolean isList{get; set;}
    public String newType{get; set;}
    public String newDescription{get; set;}
    public Date newDateExpiration{get; set;}
    public Account newAccount{get; set;}
    public boolean displayPopup {get; set;}     
    transient  ContentVersion adjunto;
    public List<SelectOption> itemsTypes {get; set;}

    public ContentVersion getAdjunto(){
        if(adjunto == null) adjunto = new ContentVersion();
            return adjunto;
        }
  

    
    public ContentDocumentRelatedListController(ApexPages.StandardController stdc){
        
        acc = (Account) stdc.getRecord();
        newAccount = new Account();
        isNew = false;
        isList = true;
        contentDocumentList = new List<EntradaDocumento>();
        itemsTypes = Util_ContentVersion.inicializarListaTiposContentVersion();
        rellenarListaDocumentos(acc);
    }

    public void rellenarListaDocumentos(Account account){
        List<ContentDocumentLink> contentDocumentLink = [
            SELECT contentDocumentId, contentDocument.Title 
            FROM ContentDocumentLink WHERE LinkedEntityId = :account.Id and isDeleted = false
        ];
        
        
        Map<Id, String> mapContentdocument = new Map<Id, String>();
        
        for(ContentDocumentLink ContDoc: contentDocumentLink){
            mapContentdocument.put(ContDoc.contentDocumentId, ContDoc.Id);
        }
        
        
        List<ContentVersion> contentVersionList = new List<ContentVersion>([
            SELECT  CreatedById,ContentDocumentId,CreatedDate,Description,DOC_DAT_Asociacion_Documentacion__c,DOC_DAT_Fecha_Expiracion__c,DOC_SEL_Tipo_Documento__c,DOC_TXT_Descripcion_Adicional__c,FileExtension,FileType,Title
            FROM    ContentVersion
            WHERE   ContentDocumentId = :mapContentdocument.keySet() and isDeleted = false]);
        
        List<ContentDocument> contentDocumentList1 = new List<ContentDocument>([SELECT LatestPublishedVersionId, Id 
                                                                           FROM ContentDocument WHERE ID = :mapContentdocument.keySet() and isDeleted = false]);
        
        String tipoDoc;
        Date dt;
        for(ContentVersion cont : contentVersionList){
            
            if(cont.DOC_SEL_Tipo_Documento__c == null || cont.DOC_SEL_Tipo_Documento__c == ''){
                tipoDoc = 'sin documento';
            }else{
                tipoDoc = cont.DOC_SEL_Tipo_Documento__c;
            }
             
            for(ContentDocument cd: contentDocumentList1){
                if(cd.Id == cont.ContentDocumentId && cd.LatestPublishedVersionId == cont.id){
                    contentDocumentList.add(new EntradaDocumento(cont.Title, cont.Id,
                                                        cont.DOC_DAT_Fecha_Expiracion__c, tipoDoc, cont.CreatedDate, cont.CreatedById,
                                                        cont.Description, cont.DOC_DAT_Asociacion_Documentacion__c, cont.DOC_TXT_Descripcion_Adicional__c,
                                                        cont.FileExtension, cont.FileType, cd.Id));
                
                }
            }
            
        }
       
    }
    
     public Pagereference goToUser(){
        String ids= ApexPages.currentPage().getParameters().get('creadoPor');     
        PageReference neweditcont = new PageReference('/'+ids+'?retURL=/');
        neweditcont.setRedirect(true);
        return neweditcont;
    }

    public void openNuevo(){
       isNew = true;
       isList = false;
    }

    public void cancelNuevo(){
        isNew = false;
        isList = true;
        newDescription = null;
        newAccount = new Account();
        newType = null;
        newDateExpiration = null;
    }
    
    public void modifyDocument(){
        String idRegistro = ApexPages.currentPage().getParameters().get('idRegistro');
        for(EntradaDocumento ent: contentDocumentList){
            if(idRegistro == ent.idRegistro){
                ent.isModify = true;
                break;
            }
        }
    }


    public void saveNewDocument(){

        ContentVersion contVer = [SELECT ID FROM ContentVersion WHERE ID = :adjuntoId];
        contVer.DOC_DAT_Fecha_Expiracion__c = newAccount.CUE_DAT_Fecha_Transpaso_Fianza__c;
        contVer.DOC_SEL_Tipo_Documento__c = newType;
        contVer.Description = newDescription;

        update contVer;

        ContentDocument contentDoc = new ContentDocument();

        contentDoc = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :adjuntoId];

         system.debug('<<<<<<<<<<<<contentDoc>>>>>>>>>' +contentDoc.id);
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.ContentDocumentId = ContentDoc.Id;
        contentLink.ShareType = 'V';
        contentLink.LinkedEntityId = acc.Id;

        insert contentLink;

        newDescription = null;
        newAccount = new Account();
        newType = null;
        newDateExpiration = null;
        isNew = false;
        isList = true;

        contentDocumentList = new List<EntradaDocumento>();
        rellenarListaDocumentos(acc);
        
        

    }
    
    public void cancelModifyDocument(){
        String idRegistro = ApexPages.currentPage().getParameters().get('idRegistro');
        for(EntradaDocumento ent: contentDocumentList){
            if(idRegistro == ent.idRegistro){
                ent.isModify = false;
                break;
            }
        }
    }
    
    public void saveDocument(){
        
        
        String idRegistro = ApexPages.currentPage().getParameters().get('idRegistro');
        String fecha = Apexpages.currentPage().getParameters().get('fechaExpiracion');
        Date fechaExp;
        String TypeSelection;        
        String descripcion;
        for(EntradaDocumento ed: contentDocumentList){
            if(ed.idRegistro == idRegistro){
                fechaExp = ed.cuenta.CUE_DAT_Fecha_Transpaso_Fianza__c;
                TypeSelection = ed.tipo;
                descripcion = ed.descripcionLarga;
            }
        }
        ContentVersion contVersion = new ContentVersion();
        contVersion.DOC_DAT_Fecha_Expiracion__c = fechaExp;
        contVersion.DOC_SEL_Tipo_Documento__c = TypeSelection;
        contVersion.Description = descripcion;
        contVersion.Id = idRegistro;
        system.debug('contVersion.Id ' + contVersion.Id);
        update contVersion;
        
        contentDocumentList = new List<EntradaDocumento>();
        rellenarListaDocumentos(acc);
        
        
    }

 
    public class EntradaDocumento {
        public String titulo {get; set;}
        public Id idRegistro {get; set;}
        public Date fechaExpiracion {get; set;}
        public String tipo {get; set;}
        public String fechaCreacion {get; set;}
        public Id creadoPor{get; set;}
        public String descripcion{get; set;}
        public Datetime fechaAsociacionDocumento {get; set;}
        public String descripcionAdicional{get; set;}
        public String extension{get; set;}
        public String tipoFila {get; set;}
        public Id idContentDocument {get; set;}
        public String NameCreator {get; set;}
        public String fechaExpiracionSt {get; set;}
        public String tituloLargo{get; set;}
        public Boolean isModify {get; set;}
        public String descripcionLarga{get; set;}
        public String nombreLargo{get; set;}
        public Account cuenta{get; set;}
        public Id ContentDocumentId{get; set;}
        public String descripcionTipo{get; set;}
        
        
        public EntradaDocumento(String titulo, Id idRegistro, Date fechaExpiracion, String tipo, Datetime fechaCreacion, Id creadoPor,
                               String descripcion, Datetime fechaAsociacionDocumento, String descripcionAdicional, String extension, String tipoFila, Id ContentDocumentId){
                   
                    String creacion;
					Datetime datet;
					String fechaExpiracionSt;
                    String tituloLargo = titulo;
                    string descripcionTipo;
                    String nombre;
                    String nombreLargo;
                    String descripcionLarga = descripcion;
                    List<SelectOption>  items = Util_ContentVersion.inicializarListaTiposContentVersion();

                    system.debug('<<<<<<<<<<<ContentDocumentId>>>>>>>>>' + ContentDocumentId);

					if(fechaCreacion != null){
						creacion = fechaCreacion.formatGmt('dd/MM/yyyy');
						datet = fechaExpiracion;
					  }
					if(datet != null){
						fechaExpiracionSt = datet.formatGmt('dd/MM/yyyy');
					}
                     
                    if(titulo != null && titulo.length() > 30){                        
                        titulo = titulo.substring(0, 30);  
                        titulo = titulo +'...';
                    }
                    
                    User us = [SELECT Name FROM User WHERE Id = :creadoPor]; 
                    nombreLargo = us.Name;
                    
                    if(us.Name != null && us.Name.length() > 30){                        
                        nombre = us.Name.substring(0, 30); 
                        nombre = nombre + '...';
                                       
                    }else{
                        nombre = us.Name;
                    }
                                   
                    if(descripcion != null && descripcion.length() > 40){
                        descripcion = descripcion.substring(0, 40);
                        descripcion = descripcion + '...';
                    }
                    for(SelectOption op: items){
                        if(op.getValue() == tipo){
                            descripcionTipo = op.getLabel();
                        }
                    }              
                    this.titulo = titulo;
                    this.tituloLargo = tituloLargo;
                    this.tipo = tipo;
                    this.idRegistro = idRegistro;
                    this.fechaExpiracion = fechaExpiracion;
                    this.fechaExpiracionSt = fechaExpiracionSt;
                    this.fechaCreacion = creacion;
                    this.creadoPor = creadoPor;
                    this.NameCreator = nombre;
                    this.nombreLargo = nombreLargo;
                    this.descripcion = descripcion;
                    this.descripcionLarga = descripcionLarga;
                    this.fechaAsociacionDocumento = fechaAsociacionDocumento;
                    this.descripcionAdicional = descripcionAdicional;
                    this.extension = extension;
                    this.tipoFila = tipoFila;
                    this.idContentDocument = ContentDocumentId;
                    this.isModify = false;
                    this.cuenta = new Account();
                    this.descripcionTipo = descripcionTipo;
                    this.ContentDocumentId = ContentDocumentId;
        }
    }

    public void closePopup() {        
        displayPopup = false;    
    }     
    public void showPopup() {  
        String idRegistro = ApexPages.currentPage().getParameters().get('idRegistro');
        adjuntoId =  idRegistro;    
        displayPopup = true;    
    }

    public void deleteRow(){
        for(EntradaDocumento ent: contentDocumentList){
            if(adjuntoId == ent.idRegistro){
                deleteContentDocument = ent.ContentDocumentId;
                break;
            }
        }
        ContentDocument contDoc = new ContentDocument();
        contDoc.Id = deleteContentDocument;
        delete contDoc;

        isNew = false;
        isList = true;

        contentDocumentList = new List<EntradaDocumento>();
        rellenarListaDocumentos(acc);
        closePopup();

    }
}