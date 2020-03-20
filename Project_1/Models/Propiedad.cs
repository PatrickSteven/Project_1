using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Project_1.Models
{
    public class Propiedad
    {
        public int numeroFinca { get; set; }
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