using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Project_1.Models;

namespace Project_1.ViewModels
{
    public class PropietarioIndexViewModel
    {
        public List<Propietario> propietarios { get; set; }
        public Propietario propietario { get; set; }
    }
}