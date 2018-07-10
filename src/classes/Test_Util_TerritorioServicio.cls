@isTest
public without sharing class Test_Util_TerritorioServicio {

	private static ServiceTerritory st;
	private static Poblacion__c pc;
	private static Poblacion_CP__c pcp;
	private static Profesional_Gremio__c profesionalGremio;
	private static ServiceTerritoryMember miembro;

	static void inicializarVariables(){
		OperatingHours oh = new OperatingHours();
        oh.Name='horario de verano';
        insert oh;

        st=Util_Tests.crearTerritorioServicio('30002',oh.Id,'30002');
        st.IsActive = true;
        insert st;
        Account cuentaPrincipal = Util_Tests.crearCuentaB2BPpal('CuentaProf','1000023','U9164003G');
        cuentaPrincipal.type = Label.CUE_TIPO_CLIENTEFINAL;
		insert cuentaPrincipal;

		Account cuentaProfesional = Util_Tests.crearCuentaProfesionalContrato('PR000001','1024745','W4364779A', cuentaPrincipal.Id);
		cuentaProfesional.CUE_LKP_CuentaPrincipalProf__c = cuentaPrincipal.id;
		cuentaProfesional.CUE_SEL_Tipo_de_Profesional__c = '01';
		insert cuentaProfesional;
		cuentaProfesional.CUE_SEL_Estado__c = '02';
		update cuentaProfesional;

		Profile perfil = [SELECT Id FROM Profile WHERE Name = :Label.PERFIL_PROFESIONAL];
		system.debug('Perfiles<<>>'+perfil);
		User usuario = Util_Tests.nuevoUsuario('pruebas','pruebas','asdd@hotmail.com','pruebas','pruebas',perfil);
        insert usuario;

		profesionalGremio = new Profesional_Gremio__c();
		profesionalGremio.prg_lkp_cuenta_profesional__c = cuentaProfesional.Id;
		profesionalGremio.prg_num_lim_ot_en_curso__c = 3;
		profesionalGremio.prg_sel_gremio__c = '21';
		insert profesionalGremio;

	    ServiceResource recursoServicio = Util_Tests.crearRecursoServicio([SELECT CUE_TXT_Identificador__c FROM Account WHERE Id = :cuentaProfesional.id].get(0).CUE_TXT_Identificador__c+'_01_1','74749',cuentaProfesional.Id,usuario);
	    recursoServicio.isActive=true;
	    recursoServicio.RSE_LKP_Profesional_Gremio__c = profesionalGremio.Id;
	    update recursoServicio;

	    Datetime fecha = Datetime.newInstance(2018,03,05);
	    miembro = Util_Tests.crearMiembroTerritorioServicio(recursoServicio,st,'S',fecha);
	    insert miembro;

		pc=Util_Tests.crearPoblacion('Murcia','30');
        insert pc;

        pcp=Util_Tests.crearPoblacionCP('Águilas',pc.Id, st.Id, st.PostalCode);
        insert pcp;
	}

    @isTest static void test1(){  
    	inicializarVariables();
    	Set<Id> setTodosProfesionalesNUEVAS = new Set<Id>();
    	setTodosProfesionalesNUEVAS.add(miembro.id);
    	Set<Id> setTodosProfesionalesVIEJAS = new Set<Id>();
    	setTodosProfesionalesVIEJAS.add(miembro.id);
    	Set<Id> setTerritorioProfesionalNUEVAS = new Set<Id>();
    	setTerritorioProfesionalNUEVAS.add(st.id);
    	Set<Id> setTerritorioProfesionalVIEJAS = new Set<Id>();
    	setTerritorioProfesionalVIEJAS.add(st.id);
    	Set<String> setInTerritoryType = new Set<String>();
    	setInTerritoryType.add(miembro.TerritoryType);
    	Set<String> setNotInTerritoryType = new Set<String>();
    	setNotInTerritoryType.add(miembro.TerritoryType);

    	Util_TerritorioServicio.getSTMemberBySRAndServiceTerritory(setTodosProfesionalesNUEVAS,setTodosProfesionalesVIEJAS,setTerritorioProfesionalNUEVAS,setTerritorioProfesionalVIEJAS,setInTerritoryType,setNotInTerritoryType);

		Util_TerritorioServicio.cargarListaPoblacionPorCP(st.PostalCode);
		Set<String> stpc = new Set<String>();
		stpc.add(st.PostalCode);
		Util_TerritorioServicio.cargarListaSeleccionPoblacionPorCP(stpc);
		Util_TerritorioServicio.obtenerPoblacionSel(pcp.PCP_TXT_Identificador__c);
		Util_TerritorioServicio.obtenerProvinciaSel(pc.POB_TXT_Identificador__c);
		Set<String> setps = new Set<String>();
		setps.add(st.TDS_TXT_Identificador__c);
		Set<String> setPro = new Set<String>();
		setPro.add(pc.POB_TXT_Identificador__c);
		Util_TerritorioServicio.getMapaTerrActPorCP(setps);
		Util_TerritorioServicio.esCapitalDeProvincia(st.PostalCode);
		Util_TerritorioServicio.esCapitalDeProvincia('55555555555');
		Util_TerritorioServicio.getMiembrosFestivos(setps,setPro);
		Set<Id> idSetTServ = new Set<Id>();
		idSetTServ.add(st.id);
		Util_TerritorioServicio.getTerritorioServicioById(idSetTServ);
	}

}