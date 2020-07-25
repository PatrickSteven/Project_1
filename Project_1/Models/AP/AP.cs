using System;
using System.Collections.Generic;
using System.Data.SqlTypes;
using System.Linq;
using System.Web;

namespace Project_1.Models.AP
{
    public class AP
    {
        public int id { get; set; }
        public int idComprobante { get; set; }
        public long montoOriginal { get; set; }
        public long saldo { get; set; }
        public SqlDecimal tasaInteres { get; set; }
        public int plazoOriginal { get; set; }
        public int plazoResta { get; set; }
        public long cuota { get; set; }
        public long amortizacion { get; set; }
        public long interes { get; set; }
        public DateTime insertedAt { get; set; }
        public int totalRecibos{ get; set; }
        public DateTime fecha { get; set; }
    }
}