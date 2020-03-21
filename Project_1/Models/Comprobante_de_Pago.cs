using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Project_1.Models
{
    public class Comprobante_de_Pago
    {
        [DataType(DataType.DateTime)]
        public int fecha { get; set; }

        [RegularExpression("^[0-9]*$", ErrorMessage = "Total must be numeric")]
        public int total { get; set; }

        [RegularExpression("^[0-9]*$", ErrorMessage = "idPropiedad must be numeric")]
        public int idPropiedad { get; set; }
    }           
}