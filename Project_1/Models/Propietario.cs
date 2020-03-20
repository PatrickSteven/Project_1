using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Project_1.Models
{
    public class Propietario
    {
        public String nombre { get; set; }
        public int valorDocId { get; set; }
        public int idDocId { get; set; }

        Propietario(String nombre, int valorDocId, int idDocId)
        {
            this.nombre = nombre;
            this.valorDocId = valorDocId;
            this.idDocId = idDocId;
        }

    }
}