using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using Project_1.Models;
using Project_1.Models.Propietario_Juridico;

namespace Project_1.ViewModels.Propietario
{
    public class PropietarioDetailViewModel
    {
        public Models.Propietario propietario { get; set; }
        public Propietario_Juridico propietarioJuridico { get; set; }
        public List<Models.Propiedad> propiedades { get; set; }
        public Propiedad_Del_Propietario PropiedadDelPropietario { get; set; }
    }
}