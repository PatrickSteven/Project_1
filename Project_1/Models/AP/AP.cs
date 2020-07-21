using System;
using System.Collections.Generic;
using System.Data.SqlTypes;
using System.Linq;
using System.Web;

namespace Project_1.Models.AP
{
    public class AP
    {
        public int idComprobante { get; set; }
        public decimal montoOriginal { get; set; }
        public decimal saldo { get; set; }
        public decimal tasaInteres { get; set; }
        public int plazoOriginal { get; set; }
        public int plazoResta { get; set; }
        public decimal cuota { get; set; }
        public DateTime insertedAt { get; set; }
        
    }
}