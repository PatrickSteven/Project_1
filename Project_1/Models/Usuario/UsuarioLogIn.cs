using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Project_1.Models
{
    public class UsuarioLogIn
    {

        [Display(Name = "Contraseña")]
        [DataType(DataType.Password)]
        [Required]
        public String password { get; set; }

        [Display(Name = "Nombre")]
        [DataType(DataType.Text)]
        [Required]
        public String nombre { get; set; }

        [HiddenInput]
        public string ReturnUrl { get; set; }
    }
}