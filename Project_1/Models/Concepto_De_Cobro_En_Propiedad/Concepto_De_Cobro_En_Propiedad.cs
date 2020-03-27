using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Data.SqlTypes;
using System.Linq;
using System.Web;

namespace Project_1.Models.Concepto_De_Cobro_En_Propiedad
{
    public class Concepto_De_Cobro_En_Propiedad
    {
        

        // Concepto de Cobro

        [Display(Name = "Fecha Inicio")]
        [Required]
        public DateTime fechaInicio { get; set; }

        [Display(Name = "Fecha Fin")]
        [Required]
        public DateTime fechaFin { get; set; }

        [Display(Name = "Nombre Comprobamte de Pago")]
        [Required]
        public String nombreCC { get; set; }

        [Display(Name = "Tasa de Intereses Moratorios")]
        [Required]
        public int interesesMoratorios { get; set; }

        [Display(Name = "Dia de Cobro")]
        [Required]
        public int diaCobro { get; set; }

        [Display(Name = "Cantidad de dias Vencidos")]
        [Required]
        public int diaVencido { get; set; }

        [Display(Name = "Es Fijo")]
        [Required]
        public bool esFijo { get; set; }

        [Display(Name = "Es Recurrente")]
        [Required]
        public bool esRecurrete { get; set; }


        // CC_Fijo
        [Display(Name = "Monto")]
        public SqlMoney monto { get; set; }

        //CC_Consumo
        [Display(Name = "Valor")]
        public SqlMoney valor { get; set; }

        
        

        
        

        

        
    }
}