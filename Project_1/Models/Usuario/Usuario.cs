using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Project_1.Models
{
    public class Usuario
    {
        [Display(Name = "Tipo de Usuario")]
        [DataType(DataType.Text)]
        [Required]
        public String tipoUsuario { get; set; }

        [Display(Name = "Contrasena")]
        [DataType(DataType.Password)]
        [Required]
        public String password { get; set; }

        [Display(Name = "Nombre")]
        [DataType(DataType.Text)]
        [Required]
        public String nombre { get; set; }
    }
}