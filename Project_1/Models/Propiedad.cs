using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
// imports
using System.ComponentModel.DataAnnotations;


namespace Project_1.Models
{
    public class Propiedad
    {

        [RegularExpressionAttribute("^[0-9]*$", ErrorMessage = "numeroFinca must be numeric")]
        public int numeroFinca { get; set; }

        [RegularExpressionAttribute("^[0-9]*$", ErrorMessage = "Valor must be numeric")]
        public int valor { get; set; }


        public String direccion { get; set; }

        Propiedad(int numeroFinca, int valor, String direccion)
        {
            this.numeroFinca = numeroFinca;
            this.valor = valor;
            this.direccion = direccion;
        }

    }
}