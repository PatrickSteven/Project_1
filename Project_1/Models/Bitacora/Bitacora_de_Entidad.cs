using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Project_1.Models.Bitacora
{
    public class Bitacora_de_Entidad
    {
        public string nombreEntidad { get; set; }
        public List<string> columnas { get; set; }
        public List<Bitacora> bitacoras { get; set; }
    }
}