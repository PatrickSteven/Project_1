using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Project_1.Models;
using Project_1.Models.Concepto_De_Cobro_En_Propiedad;
using Project_1.ViewModels.Recibo;

namespace Project_1.ViewModels.Propiedad
{
    public class PropiedadDetailViewModel
    {
        public Models.Propiedad propiedad { get; set; }
        public Models.Concepto_De_Cobro_En_Propiedad.Concepto_De_Cobro_En_Propiedad CC_En_Propiedad { get; set; }
        public List<Models.Propietario> propietarios{ get; set; }
        public Propiedad_Del_Propietario PropiedadDelPropietario { get; set; }
        public List<Concepto_De_Cobro_En_Propiedad> CC_Fijo { get; set; }
        public List<Concepto_De_Cobro_En_Propiedad> CC_Consumo { get; set; }
        public List<Concepto_De_Cobro_En_Propiedad> CC_Intereses_Moratiorios { get; set; }
        public List<Concepto_De_Cobro_En_Propiedad> CC_Porcentaje { get; set; }
        public List<Models.Usuario> usuarios { get; set; }
        public ReciboViewModel recibos { get; set; }
        public List<Models.AP.AP> APs { get; set; }
    }
}
