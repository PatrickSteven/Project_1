using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Project_1.Models;

namespace Project_1.ViewModels
{
    public class PropietarioIndexViewModel
    {
        public List<Models.Propietario> propietarios { get; set; }
        public Models.Propietario propietario { get; set; }
    }
}