using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Project_1.Models
{
    public class Usuario
    {
        [Display(Name = "Tipo de Usuario")]
        [Required]
        public String tipoUsuario { get; set; }

        [Display(Name = "Contrasena")]
        [Required]
        public String password { get; set; }

        [Display(Name = "Nombre")]
        [Required]
        public String nombre { get; set; }
    }
}