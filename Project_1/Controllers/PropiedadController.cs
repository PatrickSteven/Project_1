using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Project_1.Models;
using Project_1.ViewModels;

namespace Project_1.Controllers
{
    public class PropiedadController : Controller
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
        [Route("Propiedad/Update/{numeroFinca}/{valor}/{direccion}")]
        public ActionResult UpdateRedirect(int numeroFinca, int valor, string direccion)
        {
            var propiedad = new Propiedad()
            {
                numeroFinca = numeroFinca,
                valor = valor,
                direccion = direccion
            };

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
        public void Delete(int numeroFinca)
        {
            var code = Propiedad_Conexion.Delete(numeroFinca);
        }


    }
}