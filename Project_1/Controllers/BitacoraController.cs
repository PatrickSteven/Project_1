using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Project_1.Models.Bitacora;
using Project_1.ViewModels.Bitacora;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Project_1.Models.Authentication;

namespace Project_1.Controllers
{
    [Authorize(Roles = Roles.administrador)]
    public class BitacoraController : Controller
    {
        // GET: Bitacora
        public ActionResult Index() 
        {
            var bitacoraViewModel = new BitacoraViewModel()
            {
                bitacoras = new List<Bitacora_de_Entidad>()
            
            };


            foreach (var idEntidad in TipoEntidad.entidad.Keys)
            {
                List<Bitacora> bitacoras = Bitacora_Conexion.select(idEntidad);
                var bitacoraDeEntidad = new Bitacora_de_Entidad()
                {
                    bitacoras = new List<Bitacora>()
                };

                var primeraEntidad = true;

                foreach (var bitacora in bitacoras)
                {

                    var jsonDespuesString = bitacora.jsonDespues.TrimStart(new char[] { '[' }).TrimEnd(new char[] { ']' });
                    var jsonAntesString = bitacora.jsonAntes.TrimStart(new char[] { '[' }).TrimEnd(new char[] { ']' });
                    bitacora.valoresJsonAntes = getValores(jsonAntesString);
                    bitacora.valoresJsonDespues = getValores(jsonDespuesString);
                    bitacoraDeEntidad.bitacoras.Add(bitacora);


                    var columnas = getColumnas(jsonDespuesString);
                    if (!columnas.Any())
                    {
                        columnas = getColumnas(jsonAntesString);
                    }

                    if (primeraEntidad)
                    {
                        bitacoraDeEntidad.columnas = columnas;
                        bitacoraDeEntidad.nombreEntidad = TipoEntidad.entidad[idEntidad];
                        primeraEntidad = false;
                    }

                }

                bitacoraViewModel.bitacoras.Add(bitacoraDeEntidad);
            }


            return View(bitacoraViewModel);
        }


        [NonAction]
        public List<string> getValores(string jsonString)
        {
            using (var reader = new JsonTextReader(new StringReader(jsonString)))
            {
                List<string> lista = new List<string>();
                var columna = true;
                while (reader.Read())
                {
                    if (reader.Value != null)
                    {
                        var value = (reader.Value);
                        if (columna)
                        {
                            columna = false;
                        }
                        else
                        {
                            lista.Add(value.ToString());
                            columna = true;
                        }

                    }

                }
                return lista;
            }
        }

        [NonAction]
        public List<string> getColumnas(string jsonString)
        {
            using (var reader = new JsonTextReader(new StringReader(jsonString)))
            {
                List<string> columnas = new List<string>();
                var columna = true;
                while (reader.Read())
                {
                    if (reader.Value != null)
                    {
                        var value = (reader.Value);
                        if (columna)
                        {
                            if (!columnas.Contains(value.ToString()))
                            {
                                columnas.Add(value.ToString());
                            }

                            columna = false;
                        }
                        else
                        {
                            columna = true;
                        }

                    }
                }
                return columnas;
            }
        }
    }
}