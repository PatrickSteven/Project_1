using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Project_1.Models.Propietario_Juridico
{
    public class Propietario_Juridico
    {   
        [Display(Name = "Nombre del responsable")]
        public string responsable { get; set; }
        [Display(Name = "Documento")]
        public double valorDocId { get; set; }
        public int  jIdDocId { get; set; }
        public int idPropietario { get; set; }
    }
}