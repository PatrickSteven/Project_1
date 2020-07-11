using Project_1.Models.Recibo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Project_1.ViewModels.Recibo
{
    public class RecibosPorComprobanteViewModel
    {
        public List<ReciboPorComprobante> recibosPorComprobante { get; set; }
        public int total { get; set; }
        public DateTime fechaPago { get; set; }
    }
}