using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Project_1.Models
{
    public class Comprobante_de_Pago
    {

        [Display(Name = "Fecha")]
        [DataType(DataType.DateTime)]
        [Required]
        public int fecha { get; set; }

        [Display(Name = "Total")]
        [Required]
        public int total { get; set; }

        [Display(Name = "Id Propiedad")]
        [Required]
        public int idPropiedad { get; set; }
    }           
}