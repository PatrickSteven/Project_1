using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using Microsoft.Ajax.Utilities;
using Project_1.ViewModels;

namespace Project_1.Models.CustomValidations
{
    public class PropietarioJuridicoValidation : ValidationAttribute
    {
        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
        {
            var propietarioInsert = (PropietarioInsertViewModel) validationContext.ObjectInstance;

            if (propietarioInsert.propietario.idDocId == propietarioInsert.cedulaJuridica)
            {
                if (propietarioInsert.propietario_Juridico.responsable == null ||
                    propietarioInsert.propietario_Juridico.valorDocId == null ||
                    propietarioInsert.propietario_Juridico.idPropietario == null ||
                    propietarioInsert.propietario_Juridico.jIdDocId == null)
                {
                    return new ValidationResult("Debe ingresar todos los datos del responsable juridico");
                }
            }

            return ValidationResult.Success;
        }
    }
}