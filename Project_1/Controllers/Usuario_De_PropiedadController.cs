using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using Project_1.Models;
using Project_1.Models.Authentication;

namespace Project_1.Controllers
{
    [Authorize(Roles = Roles.administrador)]
    public class Usuario_De_PropiedadController : Controller
    {
        [Route("UsuarioDePropiedad/DesuscribirPropiedad/{nombre}/{numeroFinca}")]
        public bool DesuscribirPropiedad(string nombre, int numeroFinca)
        {
            int retval = Usuario_de_Propiedad_Conexion.Delete(new Usuario_de_Propiedad()
            {
                nombre = nombre,
                numeroFinca = numeroFinca
            });

            if (ErrorCodes.errorCodes.ContainsKey(retval))
            {
                return false;
            }

            return true;

        }

        [Route("UsuarioDePropiedad/SuscribirPropiedad/{nombre}/{numeroFinca}")]
        public string SuscribirPropiedad(string nombre, int numeroFinca)
        {
            int retval = Usuario_de_Propiedad_Conexion.Insert(new Usuario_de_Propiedad()
            {
                numeroFinca = numeroFinca,
                nombre = nombre
            });

            if (ErrorCodes.errorCodes.ContainsKey(retval))
            {
                return ErrorCodes.errorCodes[retval];
            }

            return "Propiedad suscrita!";

        }
    }
}