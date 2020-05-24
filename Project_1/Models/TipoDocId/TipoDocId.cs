using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Project_1.Models.TipoDocId
{
    public class TipoDocId
    {
        public int id { get; set; }
        public string nombre{ get; set; }

        public static readonly int cedulaJuridica = 4;
    }
}