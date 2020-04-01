using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Project_1.Models;

namespace Project_1.ViewModels.Usuario
{
    public class UsuarioDetailViewModel
    {
        public List<Models.Propiedad> propiedades { get; set; }
        public Usuario_de_Propiedad usuario_de_propiedad { get; set; }
        public string nombre { get; set; }
    }
}