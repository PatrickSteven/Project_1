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
        public SqlMoney montoOriginal { get; set; }
        public SqlMoney saldo { get; set; }
        public SqlDecimal tasaInteres { get; set; }
        public int plazoOriginal { get; set; }
        public int plazoResta { get; set; }
        public SqlMoney cuota { get; set; }
        public DateTime insertedAt { get; set; }
        
    }
}