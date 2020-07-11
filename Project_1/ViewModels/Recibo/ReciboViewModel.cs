using Project_1.Models.Recibo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services.Description;

namespace Project_1.ViewModels.Recibo
{
    public class ReciboViewModel
    {
        public string nombreConceptoCobro { get; set; }
        public int numeroFinca { get; set; }
        public List<Project_1.Models.Recibo.Recibo> recibosPendientes { get; set; }
        public List<Project_1.Models.Recibo.Recibo> recibosPagados { get; set; }
        public List<ComprobanteDePago> comprobantesDePago { get; set; }
    }
}