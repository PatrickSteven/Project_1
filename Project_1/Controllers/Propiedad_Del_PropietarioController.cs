using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Antlr.Runtime;
using Project_1.Models;
using Project_1.Models.Authentication;

namespace Project_1.Controllers
{
    [Authorize(Roles = Roles.administrador)]
    public class Propiedad_Del_PropietarioController : Controller
    {   
        [Route("PropiedadDelPropietario/Despropiar/{numeroFinca}/{valorDocId}")]
        [HttpPost]
        public void Despropiar(int numeroFinca, double valorDocId)
        {
            var propiedadDelPropietario = new Propiedad_Del_Propietario()
            {
                numeroFinca = numeroFinca,
                valorDocId = valorDocId
            };

            Propiedad_del_Propietario_Conexion.Delete(propiedadDelPropietario);
            //if (ErrorCodes.errorCodes.ContainsKey(retval)) return false;
            //else return true;
        }

        [Route("PropiedadDelPropietario/Apropiar/{numeroFinca}/{valorDocId}")]
        [HttpPost]
        public string Apropiar(int numeroFinca, double valorDocId)
        {
            if (!ModelState.IsValid)
            {
                return "Todos los campos son obligatorios";
            }

            int retval = Propiedad_del_Propietario_Conexion.Insert(new Propiedad_Del_Propietario() { numeroFinca = numeroFinca, valorDocId = valorDocId });

            if (ErrorCodes.errorCodes.ContainsKey(retval))
            {
                return ErrorCodes.errorCodes[retval];
            }

            return "Propiedad agregada!";
        }
    }
}