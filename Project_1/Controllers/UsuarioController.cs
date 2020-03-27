using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Project_1.Models;
using Project_1.Models.Authentication;
using Project_1.ViewModels;

namespace Project_1.Controllers
{
    [Authorize(Roles = Roles.administrador)]
    public class UsuarioController : Controller
    {
        // GET: Usuario
        public ActionResult Index()
        {
            var usuarios = new UsuarioIndexViewModel()
            {
                usuarios = Usuario_Conexion.@select()
            };

            return View(usuarios);
        }

        public ActionResult InsertForm()
        {
            return View(new Usuario());
        }

        [HttpPost]
        public ActionResult Insert(Usuario usuario)
        {
            if (!ModelState.IsValid)
            {
                return View("InsertForm", usuario);
            }

            int retval = Usuario_Conexion.Insert(usuario);
            if (ErrorCodes.errorCodes.ContainsKey(retval))
            {
                TempData["WarningMessage"] = ErrorCodes.errorCodes[retval];
                return View("InsertForm", usuario);
            }

            TempData["SuccessfulMessage"] = "Usuario agregado";
            return View("InsertForm", new Usuario());
        }

        [Route("Usuario/Delete/{nombre}")]
        public void Delete(string nombre)
        {
            Usuario_Conexion.Delete(nombre);
        }

        public ActionResult Detail(string nombre)
        {
            return View();
        }
    }
}