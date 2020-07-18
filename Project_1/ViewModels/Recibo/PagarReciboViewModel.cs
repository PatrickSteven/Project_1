using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Project_1.ViewModels.Recibo
{
    public class PagarReciboViewModel
    {
        public List<int> idsRecibos { get; set; }
        public List<Project_1.Models.Recibo.Recibo> recibos { get; set; }
    }
}