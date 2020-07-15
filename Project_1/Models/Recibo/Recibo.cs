using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;


//@fecha date,
//@fechaVencimiento date,
//@monto int,
//@esPendiente bit,
//@nombreCC NVARCHAR(50),
//@numeroFinca int,
//@idComprobantePago int = null

namespace Project_1.Models.Recibo
{
    public class Recibo
    {
        public int idConceptoCobro{ get; set; }
        public int monto{ get; set; }
        public DateTime fecha { get; set; }
        public DateTime fechaVencimiento { get; set; }
        
    }
}