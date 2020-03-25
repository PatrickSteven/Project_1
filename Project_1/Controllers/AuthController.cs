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
        public ActionResult LogIn(UsuarioLogIn model)
        {
            if (!ModelState.IsValid) //Validate user model
            {
                return View();
            }

            //Validate user authentication
            if (model.nombre == "admin" && model.password == "password") 
            {
                var identity = new ClaimsIdentity(new[] {
                        new Claim(ClaimTypes.Name, model.nombre),
                        new Claim(ClaimTypes.Email, "a@b.com"),
                        new Claim(ClaimTypes.Country, "England")
                    },
                    "ApplicationCookie");

                //Sign in the cookie
                var ctx = Request.GetOwinContext();
                var authManager = ctx.Authentication;
                authManager.SignIn(identity);

                return Redirect(GetRedirectUrl(model.ReturnUrl));
            }

            
            // user auth failed
            ModelState.AddModelError("", "Invalid email or password");
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