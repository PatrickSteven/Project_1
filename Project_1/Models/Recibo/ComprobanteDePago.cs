﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Project_1.Models.Recibo
{
    public class ComprobanteDePago
    {
        public int idComprobante { get; set; }
        public DateTime fecha{ get; set; }
        public int total { get; set; }
    }
}