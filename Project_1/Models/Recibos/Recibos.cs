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

namespace Project_1.Models.Recibos
{
    public class Recibos
    {
        [Display(Name = "id")]
        
        public int id { get; set; }

        [Display(Name = "Fecha")]
        [Required]
        public DateTime fecha { get; set; }

        [Display(Name = "Fecha de Vencimiento")]
        [Required]
        public DateTime fechaVencimiento { get; set; }

        [Display(Name = "Monto")]
        [Required]
        public int monto { get; set; }

        [Display(Name = "Pendiente")]
        [Required]
        public bool esPendiente { get; set; }

        [Display(Name = "Concepto de Cobro")]
        [Required]
        public String nombreCC { get; set; }

        [Display(Name = "Numero de Finca")]
        [Required]
        public int numeroFinca { get; set; }

        [Display(Name = "Id de Comprobante de Pago")]
        [Required]
        public int idComprobantePago { get; set; }
    }
}