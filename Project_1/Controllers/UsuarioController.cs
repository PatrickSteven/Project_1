using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Project_1.Models.Authentication;

namespace Project_1.Controllers
{
    [Authorize(Roles = Roles.administrador)]
    public class UsuarioController : Controller
    {
        // GET: Usuario
        public ActionResult Index()
        {   
            return View();
        }
    }
}