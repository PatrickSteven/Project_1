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

            if (reciboViewModel.recibosPendientes.Any())
            {
                reciboViewModel.idConceptoCobro = reciboViewModel.recibosPendientes[0].idConceptoCobro;
            }

            //Mostrar Informacion del concepto de cobro
            //SI es agua mostrar si hay algun corte
            //Recibos Pendientes 
            //SI es agua mostrar recibo de reconexion cuando ya no hayan recibos pendientes
            //Recibos pagados
            return View(reciboViewModel);
        }

        [Route("Recibo/Pagar/{numeroFinca}/{idConceptoCobro}/{nombreCC}")]
        public ActionResult Pagar(int numeroFinca, int idConceptoCobro, string nombreCC)
        {
            var retvalue = Recibo_Conexion.PagarRecibos(numeroFinca, idConceptoCobro);
            return RedirectToAction("Index", new {numeroFinca = numeroFinca, nombreConceptoCobro = nombreCC});
        }

        [Route("Recibo/RecibosPorComprobante/{idComprobante}/{dia}/{mes}/{anno}/{numeroFinca}/{total}")]
        public ActionResult RecibosPorComprobante(int idComprobante, string dia, string mes, string anno, int numeroFinca, int total)
        {   
            if(dia.Length < 2)
            {
                dia = "0" + dia;
            }

            string val = String.Format("{0}.{1}.{2} 00:00:00", dia,mes,anno);

            DateTime fechaPago = DateTime.ParseExact(val, "dd.M.yyyy hh:mm:ss", null);

            var recibosPorComprobanteViewModel = new RecibosPorComprobanteViewModel()
            {
                total = total,
                fechaPago = fechaPago,
                recibosPorComprobante = Recibo_Conexion.SelectReciboPorComprobante(idComprobante, fechaPago, numeroFinca)
            };

            return View(recibosPorComprobanteViewModel);
        }

    }
}