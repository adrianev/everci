@isTest
public with sharing class Test_AsyncMetadataService {
    
    @isTest static void testAsyncMetadataService(){
    	AsyncMetadataService.AsyncMetadataWebSvc constr1 = new AsyncMetadataService.AsyncMetadataWebSvc();
    	System.Continuation continuacion = new System.Continuation(120);
    	List<String> fullNames = new List<String>();
    	constr1.beginDeleteMetadata(continuacion,'tipo',fullNames);
    	
    	AsyncMetadataService.renameMetadataResponse_elementFuture constr2 = constr1.beginRenameMetadata(continuacion,'tipo','viejo','nuevo');
    	//MetadataService.SaveResult res1 = constr2.getValue();
    	
    	List<MetadataService.Metadata> metadata = new List<MetadataService.Metadata>();
    	AsyncMetadataService.updateMetadataResponse_elementFuture constr3 = constr1.beginUpdateMetadata(continuacion,metadata);
    	//MetadataService.SaveResult[] res2 = constr3.getValue();
    	
    	Double doble  = 1.0;
    	AsyncMetadataService.describeMetadataResponse_elementFuture constr4 = constr1.beginDescribeMetadata(continuacion,doble);
    	//MetadataService.DescribeMetadataResult res3 = constr4.getValue();
    	
    	AsyncMetadataService.checkDeployStatusResponse_elementFuture constr5 = constr1.beginCheckDeployStatus(continuacion,'idproceso',true);
    	//MetadataService.DeployResult res4 = constr5.getValue();
    	
    	AsyncMetadataService.checkRetrieveStatusResponse_elementFuture constr6 = constr1.beginCheckRetrieveStatus(continuacion,'idproceso',true);
    	//MetadataService.RetrieveResult res5 = constr6.getValue();
    	
    	MetadataService.RetrieveRequest retrieveRequest = new MetadataService.RetrieveRequest();
    	AsyncMetadataService.retrieveResponse_elementFuture constr7 = constr1.beginRetrieve_x(continuacion,retrieveRequest);
    	//MetadataService.AsyncResult res6 = constr7.getValue();
    	
    	AsyncMetadataService.cancelDeployResponse_elementFuture constr8 = constr1.beginCancelDeploy(continuacion, 'mensaje');
    	//MetadataService.CancelDeployResult res7 = constr8.getValue();
    	
    	AsyncMetadataService.deployRecentValidationResponse_elementFuture constr9 = constr1.beginDeployRecentValidation(continuacion, 'idValidacion');
    	//String res8 = constr9.getValue();
    	
    	AsyncMetadataService.describeValueTypeResponse_elementFuture constr10 = constr1.beginDescribeValueType(continuacion, 'tipo');
    	//MetadataService.DescribeValueTypeResult res9 = constr10.getValue();
    	
    	AsyncMetadataService.createMetadataResponse_elementFuture constr11 = constr1.beginCreateMetadata(continuacion,metadata);
    	//MetadataService.SaveResult[] res10 = constr11.getValue();
    	
    	MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();
    	AsyncMetadataService.deployResponse_elementFuture constr12 = constr1.beginDeploy(continuacion, 'zipFile',deployOptions);
    	//MetadataService.AsyncResult res11 = constr12.getValue();
    	
    	AsyncMetadataService.readMetadataResponse_elementFuture constr13 = constr1.beginReadMetadata(continuacion, 'tipo', fullNames);
    	//MetadataService.ReadResult res12 = constr13.getValue();
    	
    	AsyncMetadataService.upsertMetadataResponse_elementFuture constr14 = constr1.beginUpsertMetadata(continuacion,metadata);
    	//MetadataService.UpsertResult[] res13 = constr14.getValue();
    	
    	List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
    	AsyncMetadataService.listMetadataResponse_elementFuture constr15 = constr1.beginListMetadata(continuacion,queries,doble);
    	//MetadataService.FileProperties[] res14 = constr15.getValue();
    }
}