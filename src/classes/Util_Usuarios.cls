public without sharing class Util_Usuarios implements Queueable  {

    private List<User> listaUsuarios;
    
    public Util_Usuarios(List<User> listaUsuarios){
        this.listaUsuarios = listaUsuarios;
    }
    
   	public void execute(QueueableContext context) {
        update listaUsuarios;
    }
}