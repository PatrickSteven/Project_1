using System;
using System.Collections.Generic;


namespace Project_1.Models.Bitacora
{
    public class Bitacora
    {
        public int idTipoEntidad { get; set; }
        public int idEntidad { get; set; }
        public string jsonAntes { get; set; }
        public string jsonDespues { get; set; }
        public DateTime  insertedAt { get; set; }
        public string insertedBy { get; set; }
        public string insertedIn { get; set; }

        public List<string> valoresJsonAntes { get; set; }
        public List<string> valoresJsonDespues { get; set; }
    }
}