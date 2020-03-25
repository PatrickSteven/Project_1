using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Project_1.Models
{
    public static class ErrorCodes
    {
        public readonly static Dictionary<int, string> errorCodes = new Dictionary<int, string>()
        {

            { -1  , "Error de conexion con la base de datos"},
            { -11 , "Propietario ya registrado en la base de datos"},
            { -12 , "Propietario no registrado en la base de datos"},
            { -13 , "Propiedad ya registrada en la base de datos"},
            { -14 , "Resoponsable Juridico ya registrado en la base de datos"},
            { -15 , "Responsable Juridico no encontrado" },
            { -16 , "El propietario ya posee esta propiedad"},
            { -17, "Propiedad no encontrada en la base de datos" },
            { -100, "Nombre de usuario o contraseña incorrecta"},
            { -101, "Nombre de usuario ya existe en la base de datos" }


        };



    }
}