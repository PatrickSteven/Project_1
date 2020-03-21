﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Project_1.Models
{
    public class Propiedad
    {
        [Display(Name = "Numero de Finca")]
        [Required]
        public int numeroFinca { get; set; }
        
        [Display(Name = "Valor")]
        [Required]
        public int valor { get; set; }

        [Display(Name = "Direccion")]
        [Required]
        public String direccion { get; set; }

    }
}