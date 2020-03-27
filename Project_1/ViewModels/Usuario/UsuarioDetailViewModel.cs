using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Project_1.ViewModels.Usuario
{
    public class UsuarioDetailViewModel
    {
        public Models.Usuario usuario { get; set; }
        public List<Models.Propiedad> propiedades { get; set; }
    }
}