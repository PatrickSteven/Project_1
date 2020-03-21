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
                TempData["ReturnMessage"] = ErrorCodes.errorCodes[retval];
                return View("InsertForm", propiedad);
            }

            TempData["ReturnMessage"] = "Propiedad Agregada";
            return View("InsertForm", propiedad);
        }


        //Update Propiedad
       
        public ActionResult UpdateForm(Propiedad propiedad)
        {   
            return View(propiedad);
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
                TempData["ReturnMessage"] = ErrorCodes.errorCodes[retval];
                return View("UpdateForm", propiedad);
            }

            TempData["ReturnMessage"] = "Propiedad Actualizada";
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