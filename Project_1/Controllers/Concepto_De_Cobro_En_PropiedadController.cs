using Project_1.Models;
using Project_1.Models.Authentication;
using Project_1.Models.Concepto_De_Cobro_En_Propiedad;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Project_1.Controllers
{
    [Authorize(Roles = Roles.administrador)]
    public class Concepto_De_Cobro_En_PropiedadController : Controller
    { 
        [Route("CCEnPropiedad/Delete/{numeroFinca}/{CC_Nombre}")]
        public void Delete(int numeroFinca, string CC_Nombre)
        {
            Concepto_De_Cobro_En_Propiedad_Conexion.Delete(new Concepto_De_Cobro_En_Propiedad
            {
                numeroFinca = numeroFinca,
                nombreCC = CC_Nombre
            });
        }

        [Route("CCEnPropiedad/Insert/{numeroFinca}/{CC_Nombre}")]
        public string Insert(int numeroFinca, string CC_Nombre)
        {
            int retval = Concepto_De_Cobro_En_Propiedad_Conexion.Insert(new Concepto_De_Cobro_En_Propiedad
            {
                numeroFinca = numeroFinca,
                nombreCC = CC_Nombre
            });

            if (ErrorCodes.errorCodes.ContainsKey(retval))
            {
                return ErrorCodes.errorCodes[retval];
            }

            return "Concepto de cobro agregado!";
        }
    }
}