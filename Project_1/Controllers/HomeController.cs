using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.UI;

namespace Project_1.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPI_Propiedad";
                cmd.Parameters.Add("@numeroFinca", SqlDbType.Int).Value = 5254;
                cmd.Parameters.Add("@valor", SqlDbType.Int).Value = 10000;
                cmd.Parameters.Add("@Direccion", SqlDbType.VarChar).Value = "La Berga";
                cmd.Connection = connection;
                
                String message;
                
                try
                {
                    connection.Open();
                    object result = cmd.ExecuteScalar();
                    message = "Dato Insertado" + result.ToString();

                }
                catch (Exception ex)
                {
                    message = ex.Message;
                    Console.WriteLine(ex);
                    throw;

                }
                finally
                {
                    connection.Close();
                    
                }
                return Content(message);
            }
        }

        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }
    }
}