using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Project_1.Models.Recibo
{
    public class ReciboPorComprobante
    {
        public string nombreConceptoCobro { get; set; }
        public int diaDeCobro { get; set; }
        public DateTime fecha { get; set; }
        public DateTime fechaVencimiento { get; set; }
        public double tasaInteresMoratorio { get; set; }
        public long monto { get; set; }
        public String metodoPago { get; set; }

        public readonly static Dictionary<int, String> metodosPago = new Dictionary<int, String>()
        {
            {1 , "Arreglo Pago" },
            {0 , "Pago regular" }
        };

    }
}