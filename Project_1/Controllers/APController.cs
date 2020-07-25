using Project_1.Models.AP;
using Project_1.ViewModels.AP;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Web;
using System.Web.Mvc;

namespace Project_1.Controllers
{
    public class APController : Controller
    {
        public ActionResult MostrarAP(List<int> idsRecibos, int numeroFinca, int meses)
        {
            
            AP ap = AP_Conexion.MostrarAP(numeroFinca, meses, idsRecibos);
            String markup = "<div>";

            markup += String.Format(@"
                        <p>
                        <h5>Monto: <span class='badge badge-danger'> {0}</span> </h5>
                        <h5>Intereses: <span class='badge-info'> {1}</span> </h5>
                        <h5>Cuota: <span class='badge badge-info'> {2}</span> </h5>
                        <h5>Plazo: <span class='badge badge-info'> {3}</span> </h5>
                        </p>",
                        ap.montoOriginal,
                        ap.tasaInteres,
                        ap.cuota,
                        ap.plazoOriginal
                        );

            markup += "</div>";
            return Content(markup);
            }

        [Route("AP/{id}/{numeroFinca}")]
        public ActionResult Index(int id, int numeroFinca)
        {
            APViewModel movimientos = new APViewModel()
            {
                APs = AP_Conexion.SelectMovimientos(id),
                numeroFinca = numeroFinca
            };

            return View(movimientos);
        }
        public void CrearAP(List<int> idsRecibos, int numeroFinca, int meses)
        {
            AP_Conexion.CrearAP(numeroFinca, meses, idsRecibos);
        }


    }
}