using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

namespace Project_1.Controllers
{
    public class RecibosController : Controller
    {
        // GET: Recibos

        [Route("Recibos/{numeroFinca}/{cc}/")]
        public ActionResult Index(int numeroFinca, String cc)
        {   
            //Mostrar Informacion del concepto de cobro
            //SI es agua mostrar si hay algun corte
            //Recibos Pendientes 
            //SI es agua mostrar recibo de reconexion cuando ya no hayan recibos pendientes
            //Recibos pagados
            return View();
        }
    }
}