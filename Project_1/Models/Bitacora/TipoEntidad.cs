using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Project_1.Models.Bitacora
{
    public class TipoEntidad
    {
        public readonly static Dictionary<int, string> entidad = new Dictionary<int, string>()
        {
            {1, "Propiedad"},
            {2, "Propietario"},
            {3, "Usuario"},
            {4, "Propiedad de propietario"},
            {5, "Propiedad de usuario"},
            {6, "Propietario juridico" },
            {7, "Concepto de cobro"}
        };
    }
}
