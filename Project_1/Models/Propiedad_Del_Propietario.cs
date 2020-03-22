using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Project_1.Models
{
    public class Propiedad_Del_Propietario
    {

        [Display(Name = "Numero de Finca")]
        [Required]
        public int numeroFinca { get; set; }

        [Display(Name = "Valor Doc Id")]
        [Required]
        public int valorDocId { get; set; }
    }
}