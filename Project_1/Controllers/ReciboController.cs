using Project_1.Models.Recibo;
using Project_1.ViewModels.Recibo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
namespace Project_1.Controllers
{
    public class ReciboController : Controller
    {
        // GET: Recibos

        [Route("Recibo/{numeroFinca}/{nombreConceptoCobro}/")]
        public ActionResult Index(int numeroFinca, String nombreConceptoCobro)
        {
            var reciboViewModel = new ReciboViewModel()
            {
                nombreConceptoCobro = nombreConceptoCobro,
                numeroFinca = numeroFinca,
                recibosPendientes = Recibo_Conexion.Select(numeroFinca, nombreConceptoCobro, EstadoRecibo.PENDIENTE),
                recibosPagados = Recibo_Conexion.Select(numeroFinca, nombreConceptoCobro, EstadoRecibo.PAGADO),
                comprobantesDePago = Recibo_Conexion.SelectComprobantePago(numeroFinca, nombreConceptoCobro)
            };

            //Mostrar Informacion del concepto de cobro
            //SI es agua mostrar si hay algun corte
            //Recibos Pendientes 
            //SI es agua mostrar recibo de reconexion cuando ya no hayan recibos pendientes
            //Recibos pagados
            return View(reciboViewModel);
        }
    }
}