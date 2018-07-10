@isTest
public without sharing class Test_Util_AsignacionPropCaso {

    public static ReservarCita reservarCita  {get; set;} 
    private static Account compania;
    private static Account cuenta;
    private static Tipo_Producto_CIA__c tipoProducto;
    private static Producto_CIA__c producto;
    private static ServiceContract sv;
    private static Case caso;
    private static Procedencia__c procedencia;
    private static User newUser;
    private static Account cuentaDireccion;
    private static GroupMember gm;
    private static Id idPropietario;
    
    private static void inicializarVariables(boolean estadoVariableIdRolDuranteEjecucion){
        compania = Util_Tests.crearCuentaCompania('compania', '1018','X1234567X');
        compania.type = '01';
        insert compania;
        
        cuenta = Util_Tests.crearCuentaB2BPpal('cuenta', '1458','X1134567X');
        cuenta.type = '01';
        cuenta.CUE_LKP_Cuenta_principal__c = compania.Id;
        insert cuenta;
        
        tipoProducto = Util_Tests.crearTipoProductoCIA('tipo', '01', compania.Id);
        insert tipoProducto;
        
        producto = Util_Tests.crearProductoCIA('producto', '292', tipoProducto.Id);
        insert producto;
        
        sv = Util_Tests.crearPolizaContrato('poliza', compania.Id, cuenta.Id, producto.Id);
        
        procedencia = Util_Tests.crearProcedencia(0.0, 0.0, 0.0, 0.0, 0.0, cuenta.Id, '545687', 'CAS_Solicitud_de_Servicio_B2B_B2B2C;CAS_Servicio_B2B_B2B2C');
        insert procedencia;
        
        Buzon_CIA__c buzon = new Buzon_CIA__c();
        buzon.BUZ_LKP_Cuenta__c = compania.Id;
        buzon.BUZ_SEL_Tipo_Programa__c = '02;03';
        buzon.BUZ_EMA_Direccion__c = 'ser@ser.com';
        buzon.Name = 'buzon';
        insert buzon;
        
        Profile p=[SELECT Id FROM Profile WHERE Name = :Label.PERFIL_ADMINISTRADOR];
        
        newUser = new User();
        newUser.FirstName = 'Manolo';
        newUser.LastName = 'tena';
        newUser.Email = 'manolo@manolo.com';
        newUser.Alias = 'Manolo';
        newUser.ProfileId = p.Id;
        newUser.Username = 'john784poi@acme7.com';
        newUser.CommunityNickname = 'pepe';
        newUser.TimeZoneSidKey = 'Europe/Paris';
        newUser.LocaleSidKey = system.UserInfo.getLocale();
        newUser.EmailEncodingKey = 'ISO-8859-1';
        newUser.LanguageLocaleKey = 'es';
        newUser.IsActive=true;

        insert newUser;
        
        system.runAs(newUser){
            
            //g=new Group();
            //insert g;
            List<GroupMember> listaMiembrosGrupos;
            
            String stringQuery='SELECT GroupId, UserOrGroupId FROM GroupMember WHERE UserOrGroupId IN (SELECT Id FROM ';
            
            if(estadoVariableIdRolDuranteEjecucion == null){
                stringQuery+='User';
            }else{
                stringQuery+='Group ';
                if(estadoVariableIdRolDuranteEjecucion){
                    stringQuery+= 'WHERE RelatedId != null';
                }else{
                    stringQuery+= 'WHERE RelatedId = null';
                }
            }
            stringQuery+=')';
            
            listaMiembrosGrupos=Database.query(stringQuery);
            
            List<ID> listaIdsGrupos=new List<ID>();
            for(GroupMember gm:listaMiembrosGrupos){
                if(!listaIdsGrupos.contains(gm.GroupId))
                    listaIdsGrupos.add(gm.GroupId);
            }

            try{
                idPropietario=[SELECT Id FROM Group WHERE Id IN :listaIdsGrupos AND Type = 'Queue' LIMIT 1].get(0).Id;
            }catch(ListException e){
                idPropietario=[SELECT Id FROM Group WHERE Id IN :listaIdsGrupos LIMIT 1].get(0).Id;
            }
            
            /*gm=new GroupMember();
            gm.GroupId=g.Id;
            gm.UserOrGroupId=newUser.Id;
            
            insert gm;*/
            
            cuentaDireccion=Util_Tests.crearCuentaB2BPpal('Name', '1234563', 'X4455667X');
            cuentaDireccion.Type=Label.CUE_TIPO_DIRECCION;
            insert cuentaDireccion;
                
            caso = Util_Tests.crearCasoB2B(sv.Id, cuentaDireccion.Id, compania.Id);
        
        }
    }
    
    @isTest static void testAsignarPropietarioCasoSinUsuariosSinCasoAsociado(){
        inicializarVariables(null);
        runAsignarPropietarioCaso(false);
    }
    
    @isTest static void testAsignarPropietarioCasoConUsuariosSinCasoAsociado(){
        inicializarVariables(null);
        runAsignarPropietarioCaso(true);
    }
    
    @isTest static void testAsignarPropietarioCasoRolNulo(){
        inicializarVariables(false);
        runAsignarPropietarioCaso(true);
    }
    
        @isTest static void testAsignarPropietarioCasoRolNoNulo(){
        inicializarVariables(true);
        runAsignarPropietarioCaso(true);
    }
    
    private static void runAsignarPropietarioCaso(boolean HayUsuariosSinCasos){
                
        
        system.runAs(newUser){
            caso.CAS_SEL_Encuestador__c = 'Servitelco';
            caso.CAS_LKP_Compania__c = compania.Id;
            caso.CAS_EMA_Solicitud_Email__c = 'sera@sera.com';      
            caso.CAS_LKP_Procedencia__c = procedencia.Id;
            caso.CreatedDate = system.now();
            caso.OwnerId = idPropietario;
            caso.Status = Label.CAS_ESTADO_NUEVO;
            caso.CAS_LKP_Cliente_contable_cliente__c=cuentaDireccion.Id;
            
            Test.startTest();
            if(!hayUsuariosSinCasos){
                List<GroupMember> usuariosEnGrupo=[SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId = :caso.OwnerId];
                List<Case> casosAInsertar=new List<Case>();
                for(GroupMember g:usuariosEnGrupo){
                    Case c=new Case();
                    c.OwnerId=g.UserOrGroupId;
                    c.Status=Label.CAS_ESTADO_NUEVO;
                    c.AccountId = cuenta.Id;
                	c.CAS_LKP_Compania__c = compania.Id;
                    casosAInsertar.add(c);
                }

                insert casosAInsertar;
            }
            
            try{
                insert caso;
        
                caso.Status = Label.CAS_ESTADO_EN_CURSO;
                update caso;
            }catch(DmlException e){}
            
            Test.stopTest();
        }
    }
}