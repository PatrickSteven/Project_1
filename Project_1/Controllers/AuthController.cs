using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Web;
using System.Web.Mvc;
using Project_1.Models;

namespace Project_1.Controllers
{
    [AllowAnonymous]
    public class AuthController : Controller
    {
        [HttpGet]
        public ActionResult LogIn(string returnUrl)
        {
            var model = new UsuarioLogIn()
            {
                ReturnUrl = returnUrl
            };

            return View(model);
        }

        [HttpPost]
        public ActionResult LogIn(UsuarioLogIn usuarioLogin)
        {
            if (!ModelState.IsValid) //Validate user model
            {
                return View();
            }

            //Validate user authentication
            //Si el valor retornado por la validacion del usuario no esta contenida en el diccionario de errores
            int retval = Usuario_Conexion.Validate(usuarioLogin);
            if (!ErrorCodes.errorCodes.ContainsKey(retval)) 
            {   
                //Ahora buscamos en la base de datos al usuario correspondiente 
                Usuario usuario = Usuario_Conexion.Detail(usuarioLogin);
                var identity = new ClaimsIdentity(new[] {
                        new Claim(ClaimTypes.Name, usuario.nombre),
                        new Claim(ClaimTypes.Role, usuario.tipoUsuario),
                    },
                    "ApplicationCookie");

                //Sign in the cookie
                var ctx = Request.GetOwinContext();
                var authManager = ctx.Authentication;
                authManager.SignIn(identity);

                return Redirect(GetRedirectUrl(usuarioLogin.ReturnUrl));
            }

            
            // user auth failed
            ModelState.AddModelError("", ErrorCodes.errorCodes[retval]); //Return Error String
            return View();
        }
        
        private string GetRedirectUrl(string returnUrl)
        {
            if (string.IsNullOrEmpty(returnUrl) || !Url.IsLocalUrl(returnUrl))
            {
                return Url.Action("index", "home");
            }

            return returnUrl;
        }

        //Log Out
        public ActionResult LogOut()
        {   
            var ctx = Request.GetOwinContext();
            var authManager = ctx.Authentication;

            //sign out the cookie from the user
            authManager.SignOut("ApplicationCookie");
            return RedirectToAction("Index", "Home");
        }
    }

}