using System;
using System.Threading.Tasks;
using Microsoft.AspNet.Identity;
using Microsoft.Owin;
using Microsoft.Owin.Security.Cookies;
using Owin;

[assembly: OwinStartup(typeof(Project_1.Startup))]

namespace Project_1
{
    public class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            //Use cookie based authentication
            app.UseCookieAuthentication(new CookieAuthenticationOptions()
            {
                AuthenticationType = DefaultAuthenticationTypes.ApplicationCookie, //"ApplicationCookie"
                LoginPath = new PathString("/auth/login") //Where will be redirected when the app returns 401

            });
        }
    }
}
