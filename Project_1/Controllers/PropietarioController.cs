using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Project_1.Models;
using Project_1.Models.TipoDocId;
using Project_1.ViewModels;

namespace Project_1.Controllers
{
    public class PropietarioController : Controller
    {
        // GET: Propietario
        public ActionResult Index()
        {
            List<Propietario> propietariosList = Propietario_Conexion.Select();
            PropietarioIndexViewModel propietarioIndexViewModel = new PropietarioIndexViewModel()
            {
                propietarios = propietariosList
            };
            return View(propietarioIndexViewModel);
        }

        [NonAction]
        public PropietarioTipoDocIdViewModel PreparePropietarioTipoDocIdViewModel(Propietario _propietario = null)
        {
            IEnumerable<TipoDocId> newtipoDocIdList = (IEnumerable<TipoDocId>)TipoDocId_Conexion.select();
            Propietario newpropietario;
            if (_propietario != null) newpropietario = _propietario;
            else newpropietario = new Propietario();
            
            PropietarioTipoDocIdViewModel propietarioTipoDocId = new PropietarioTipoDocIdViewModel()
            {
                propietario = newpropietario,
                tipoDocIdList = newtipoDocIdList
            };

            return propietarioTipoDocId;
        }

        public ActionResult InsertForm()
        {
            return View(PreparePropietarioTipoDocIdViewModel());
        }

        public ActionResult Insert(Propietario propietario)
        {
            if (!ModelState.IsValid)
            {
                return View("InsertForm", PreparePropietarioTipoDocIdViewModel(propietario));
            }

            var retval = Propietario_Conexion.Insert(propietario);
            if (ErrorCodes.errorCodes.ContainsKey(retval))
            {
                TempData["WarningMessage"] = ErrorCodes.errorCodes[retval];
                return View("InsertForm", PreparePropietarioTipoDocIdViewModel(propietario));
            }

            TempData["SuccessfulMessage"] = "propiedad agregada";
            return View("InsertForm", PreparePropietarioTipoDocIdViewModel());
        }

        public ActionResult UpdateRedirect()
        {
            return View("Index");
        }

        public ActionResult Updateform()
        {
            return View("Index");
        }

        public ActionResult Update()
        {
            return View("Index");
        }
    }
}