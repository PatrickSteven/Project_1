using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Project_1.Models;
using Project_1.Models.TipoDocId;

namespace Project_1.ViewModels
{
    public class PropietarioTipoDocIdViewModel
    {
        public Propietario propietario { get; set; }
        public IEnumerable<TipoDocId> tipoDocIdList { get; set; }
    }
}