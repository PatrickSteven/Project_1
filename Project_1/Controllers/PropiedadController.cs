using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Web;
using System.Web.Mvc;
using System.Web.UI.WebControls;
using Project_1.Models;
using Project_1.Models.Authentication;
using Project_1.Models.Concepto_De_Cobro_En_Propiedad;
using Project_1.Models.Coneptos_De_Cobro;
using Project_1.ViewModels;
using Project_1.ViewModels.Propiedad;

namespace Project_1.Controllers
{
    [Authorize(Roles = Roles.administrador)]
    public class PropiedadController : AppController
    {
        // GET: Propiedad
        //Select Propiedad

        public ActionResult Index()
        {

            List<Propiedad> listPropiedades = Propiedad_Conexion.Select();
            PropiedadIndexViewModel propiedadIndex = new PropiedadIndexViewModel()
            {
                propiedades = listPropiedades
            };

            return View(propiedadIndex);
        
        }

        //Insertar Propiedad 
        public ActionResult InsertForm()
        {
            Propiedad propiedad = new Propiedad();
            return View(propiedad);
        }

        [HttpPost]
        public ActionResult Insert(Propiedad propiedad)
        {
            if (!ModelState.IsValid)
            {
                return View("InsertForm", propiedad);
            }

            var retval = Propiedad_Conexion.Insert(propiedad);
            if (ErrorCodes.errorCodes.ContainsKey(retval))
            {
                TempData["WarningMessage"] = ErrorCodes.errorCodes[retval];
                return View("InsertForm", propiedad);
            }

            TempData["SuccessfulMessage"] = "propiedad agregada";
            return View("InsertForm", new Propiedad());
        }


        //Update Propiedad
        [Route("Propiedad/UpdateRedirect/{numeroFinca}")]
        public ActionResult UpdateRedirect(int numeroFinca)
        {
            var propiedad = new Propiedad();
            return View("UpdateForm", propiedad);
        }

        [Route("Propiedad/UpdateForm/")]
        public ActionResult UpdateForm()
        {   
            return View(new Propiedad());
        }

        public ActionResult Update(Propiedad propiedad)
        {
            if (!ModelState.IsValid)
            {
                return View("UpdateForm", propiedad);
            }

            var retval = Propiedad_Conexion.Update(propiedad);
            if (ErrorCodes.errorCodes.ContainsKey(retval))
            {
                TempData["WarningMessage"] = ErrorCodes.errorCodes[retval];
                return View("UpdateForm", propiedad);
            }

            TempData["SuccessfulMessage"] = "correctamente";
            return View("UpdateForm", propiedad);
        }


        //Delete Propiedad
        [Route("Propiedad/Delete/{numeroFinca}")]
        //[HttpPost]
        public void Delete(int numeroFinca)
        {
            var code = Propiedad_Conexion.Delete(numeroFinca);
        }

        [Route("Propiedad/Detail/{numeroFinca}")]
        public ActionResult Detail(int numeroFinca)
        {
            Propiedad propiedad = Propiedad_Conexion.SelectPropiedad(numeroFinca);
            List<Propietario> propietarios = Propiedad_del_Propietario_Conexion.SelectPropiedadDetail(numeroFinca);

            List<Concepto_De_Cobro_En_Propiedad> CC_Fijo = Concepto_De_Cobro_En_Propiedad_Conexion.Select(numeroFinca, Tipo_CC.Fijo);
            List<Concepto_De_Cobro_En_Propiedad> CC_Consumo = Concepto_De_Cobro_En_Propiedad_Conexion.Select(numeroFinca, Tipo_CC.Consumo);
            List<Concepto_De_Cobro_En_Propiedad> CC_Intereses_Moratiorios = Concepto_De_Cobro_En_Propiedad_Conexion.Select(numeroFinca, Tipo_CC.Intereses_Moratorios);
            List<Usuario> usuarios = Usuario_de_Propiedad_Conexion.SelectPropiedadDetail(numeroFinca);

            PropiedadDetailViewModel propiedadDetail = new PropiedadDetailViewModel()
            {
                propiedad = propiedad,
                propietarios = propietarios,
                CC_Fijo = CC_Fijo,
                CC_Consumo =  CC_Consumo,
                CC_Intereses_Moratiorios = CC_Intereses_Moratiorios,
                usuarios = usuarios
            };

            return View(propiedadDetail);
        }
        

    }
}