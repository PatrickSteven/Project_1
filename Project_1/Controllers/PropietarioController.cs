using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Project_1.Models;
using Project_1.Models.Authentication;
using Project_1.Models.Propietario_Juridico;
using Project_1.Models.TipoDocId;
using Project_1.ViewModels;
using Project_1.ViewModels.Propietario;

namespace Project_1.Controllers
{
    [Authorize(Roles = Roles.administrador)]
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
        public PropietarioInsertViewModel PreparePropietarioInsertViewModel(Propietario _propietario = null, Propietario_Juridico _propietarioJuridico = null)
        {
            IEnumerable<TipoDocId> newtipoDocIdList = (IEnumerable<TipoDocId>)TipoDocId_Conexion.select();
            Propietario newpropietario;
            Propietario_Juridico newPropietarioJuridico;

            if (_propietario != null) newpropietario = _propietario;
            else newpropietario = new Propietario();

            if (_propietarioJuridico != null) newPropietarioJuridico = _propietarioJuridico;
            else newPropietarioJuridico = new Propietario_Juridico();

            PropietarioInsertViewModel propietarioTipoDocId = new PropietarioInsertViewModel()
            {
                propietario = newpropietario,
                tipoDocIdList = newtipoDocIdList,
                propietario_Juridico = newPropietarioJuridico
                
            };

            return propietarioTipoDocId;
        }

        //INSERT
        public ActionResult InsertForm()
        {
            return View(PreparePropietarioInsertViewModel());
        }

        public ActionResult Insert(PropietarioInsertViewModel propietarioInsert)
        {
            if (!ModelState.IsValid)
            {
                return View("InsertForm", PreparePropietarioInsertViewModel(propietarioInsert.propietario, propietarioInsert.propietario_Juridico));
            }

            var retval = Propietario_Conexion.Insert(propietarioInsert.propietario);
            if (ErrorCodes.errorCodes.ContainsKey(retval))
            {
                TempData["WarningMessage"] = ErrorCodes.errorCodes[retval];
                return View("InsertForm", PreparePropietarioInsertViewModel(propietarioInsert.propietario));
            }

            if (propietarioInsert.propietario.idDocId == propietarioInsert.cedulaJuridica)
            {
                propietarioInsert.propietario_Juridico.idPropietario = retval;
                var retval_propietarioJuridco = Propietario_Juridico_Conexion.Insert(propietarioInsert.propietario_Juridico);
                if (ErrorCodes.errorCodes.ContainsKey(retval_propietarioJuridco))
                {
                    TempData["WarningMessage"] = ErrorCodes.errorCodes[retval_propietarioJuridco];
                    return View("InsertForm", PreparePropietarioInsertViewModel(propietarioInsert.propietario, propietarioInsert.propietario_Juridico));
                }
            }
 

            TempData["SuccessfulMessage"] = "propietario agregado";
            return View("InsertForm", PreparePropietarioInsertViewModel());
        }


        //UPDATE
        [Route("Propietario/UpdateRedirect/{valorDocId}")]
        public ActionResult UpdateRedirect(int valorDocId)
        {
            var propietarioInsert = new PropietarioInsertViewModel();
            var propietario = Propietario_Conexion.SelectPropietario(valorDocId);
            Propietario_Juridico propietarioJuridico;

            if (propietario.idDocId == propietarioInsert.cedulaJuridica)
                propietarioJuridico = Propietario_Juridico_Conexion.SelectPropietario(valorDocId);
            else 
                propietarioJuridico = new Propietario_Juridico();

            propietarioInsert.propietario = propietario;
            propietarioInsert.propietario_Juridico = propietarioJuridico;
            propietarioInsert.tipoDocIdList = TipoDocId_Conexion.@select();
            
            return View("UpdateForm", propietarioInsert);
        }

        public ActionResult UpdateForm()
        {   
            return View(PreparePropietarioInsertViewModel());
        }

        public ActionResult Update(Propietario propietario)
        {
            if (!ModelState.IsValid)
            {
                return View("UpdateForm", PreparePropietarioInsertViewModel(propietario));
            }

            var retval = Propietario_Conexion.Update(propietario);
            if (ErrorCodes.errorCodes.ContainsKey(retval))
            {
                TempData["WarningMessage"] = ErrorCodes.errorCodes[retval];
                return View("UpdateForm", propietario);
            }

            TempData["SuccessfulMessage"] = "correctamente";
            return View("UpdateForm", PreparePropietarioInsertViewModel());
        }

        //DELETE
        [Route("Propietario/Delete/{valorDocId}")]
        [HttpPost]
        public void Delete(int valorDocId)
        {
            Propietario_Conexion.Delete(new Propietario() {valorDocId = valorDocId});
        }


        //DETAIL
        [Route("Propietario/Detail/{valorDocId}")]
        public ActionResult Detail(int valorDocId)
        {
            Propietario propietario = Propietario_Conexion.SelectPropietario(valorDocId);
            List<Propiedad> propiedades = Propiedad_del_Propietario_Conexion.SelectPropietarioDetail(valorDocId);
            PropietarioDetailViewModel propietarioDetail = new PropietarioDetailViewModel()
            {
                propiedades = propiedades,
                propietario = propietario
            };

            if (propietario.idDocId == TipoDocId.cedulaJuridica)
                propietarioDetail.propietarioJuridico = Propietario_Juridico_Conexion.SelectPropietario(valorDocId);

            return View(propietarioDetail);
        }


        
    }
}