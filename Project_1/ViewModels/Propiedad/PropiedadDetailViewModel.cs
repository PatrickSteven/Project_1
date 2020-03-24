using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Project_1.Models;

namespace Project_1.ViewModels.Propiedad
{
    public class PropiedadDetailViewModel
    {
        public Models.Propiedad propiedad { get; set; }
        public List<Models.Propietario> propietarios{ get; set; }

        public Propiedad_Del_Propietario PropiedadDelPropietario { get; set; }
    }
}
