using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using Project_1.Models;
using Project_1.Models.CustomValidations;
using Project_1.Models.Propietario_Juridico;
using Project_1.Models.TipoDocId;

namespace Project_1.ViewModels
{
    public class PropietarioInsertViewModel
    {
        public Models.Propietario propietario { get; set; }

        [Display(Name = "Responsable Fisico")]
        [PropietarioJuridicoValidation]
        public Propietario_Juridico propietario_Juridico { get; set; }
        public IEnumerable<TipoDocId> tipoDocIdList { get; set; }
        public bool isPropietario_Juridico { get; set; }

        public int cedulaJuridica = 2; //Id de cedula juridica en la tabla tipoDocId
    }
}