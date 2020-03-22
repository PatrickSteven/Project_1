using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Project_1.Models
{
    public class Usuario_de_Propiedad
    {
        [Display(Name = "Nombre")]
        [Required]
        public String nombre { get; set; }

        [Display(Name = "Numero de Finca")]
        [Required]
        public int numeroFinca { get; set; }
    }
}