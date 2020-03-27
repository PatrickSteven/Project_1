﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Project_1.Models;
using Project_1.Models.Concepto_De_Cobro_En_Propiedad;

namespace Project_1.ViewModels.Propiedad
{
    public class PropiedadDetailViewModel
    {
        public Models.Propiedad propiedad { get; set; }
        public List<Models.Propietario> propietarios{ get; set; }
        public Propiedad_Del_Propietario PropiedadDelPropietario { get; set; }
        public List<Concepto_De_Cobro_En_Propiedad> CC_Fijo { get; set; }
        public List<Concepto_De_Cobro_En_Propiedad> CC_Consumo { get; set; }
        public List<Concepto_De_Cobro_En_Propiedad> CC_Intereses_Moratiorios { get; set; }
    }
}
