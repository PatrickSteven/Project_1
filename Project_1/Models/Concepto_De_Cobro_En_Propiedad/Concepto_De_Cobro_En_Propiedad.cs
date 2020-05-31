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

        [Display(Name = "Numero de Finca")]
        [Required]
        public int numeroFinca { get; set; }

        [Display(Name = "Fecha Leido")]
        [Required]
        public DateTime fechaLeido { get; set; }

        [Display(Name = "Nombre Comprobamte de Pago")]
        [Required]
        public String nombreCC { get; set; }

        [Display(Name = "Tasa de Intereses Moratorios")]
        [Required]
        public float interesesMoratorios { get; set; }

        [Display(Name = "Dia de Cobro")]
        [Required]
        public int diaCobro { get; set; }

        [Display(Name = "Cantidad de dias Vencidos")]
        [Required]
        public int diasVencidos { get; set; }

        [Display(Name = "Es Fijo")]
        [Required]
        public string esFijo { get; set; }

        [Display(Name = "Es Recurrente")]
        [Required]
        public string esRecurrente { get; set; }

        // CC_Fijo
        [Display(Name = "Monto")]
        public int monto { get; set; }

        //CC_Consumo
        [Display(Name = "Valor")]
        public float valor { get; set; }

    }
}