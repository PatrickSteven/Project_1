using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Project_1.Models
{
    public class Propietario
    {   
        [Display(Name = "Nombre")]
        [Required]
        public String nombre { get; set; }

        [Display(Name = "Valor de Documento")]
        [Required]
        public double valorDocId { get; set; }

        [Display(Name = "Tipo de Documento")]
        [Required]
        public int idDocId { get; set; }

        [Display(Name = "Tipo de Documento")]
        public string nombreDocId { get; set; }

        [Required]
        public int activo { get; set; }


    }
}