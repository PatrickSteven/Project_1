using System;
using System.Collections.Generic;
using System.Configuration;
// imports
using System.Data;
using System.Data.SqlClient;

namespace Project_1.Models
{
    public class Propiedad_Conexion
    {
        public static int Insert(Propiedad propiedad)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;

                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPI_Propiedad";
                cmd.Parameters.Add("@numeroFinca", SqlDbType.Int).Value = propiedad.numeroFinca;
                cmd.Parameters.Add("@valor", SqlDbType.Money).Value = propiedad.valor;
                cmd.Parameters.Add("@direccion", SqlDbType.VarChar).Value = propiedad.direccion;
                cmd.Connection = connection;
                cmd.Parameters.Add("@retValue", System.Data.SqlDbType.Int).Direction = System.Data.ParameterDirection.ReturnValue;

                try
                {
                    connection.Open();
                    cmd.ExecuteNonQuery();
                    retval = (int)cmd.Parameters["@retValue"].Value;

                }
                catch (Exception ex)
                {
                    retval = -1;
                    throw;

                }
                finally
                {
                    connection.Close();
                }

                return retval; // execute not accomplish
            }
        }


        public static int Delete(int numeroFinca)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;

                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPD_Propiedad";
                cmd.Parameters.Add("@numeroFinca", SqlDbType.Int).Value = numeroFinca;
                cmd.Connection = connection;
                cmd.Parameters.Add("@retValue1", System.Data.SqlDbType.Int).Direction = System.Data.ParameterDirection.ReturnValue;

                try
                {
                    connection.Open();
                    cmd.ExecuteNonQuery();
                    retval = (int)cmd.Parameters["@retValue1"].Value;

                }
                catch (Exception ex)
                {
                    retval = -1;
                    throw;

                }
                finally
                {
                    connection.Close();
                }

                return retval; // execute not accomplish
            }
        }

        public static int Update(Propiedad propiedad)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                int retval;

                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPU_Propiedad";
                cmd.Parameters.Add("@numeroFinca", SqlDbType.Int).Value = propiedad.numeroFinca;
                cmd.Parameters.Add("@valor", SqlDbType.Money).Value = propiedad.valor;
                cmd.Parameters.Add("@direccion", SqlDbType.VarChar).Value = propiedad.direccion;
                cmd.Connection = connection;
                cmd.Parameters.Add("@retValue", System.Data.SqlDbType.Int).Direction = System.Data.ParameterDirection.ReturnValue;

                try
                {
                    connection.Open();
                    cmd.ExecuteNonQuery();
                    retval = (int)cmd.Parameters["@retValue"].Value;

                }
                catch (Exception ex)
                {
                    retval = -1;
                    throw;

                }
                finally
                {
                    connection.Close();
                }

                return retval; // execute not accomplish
            }
        }

        public static List<Propiedad> Select()
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPS_Propiedad";
                cmd.Connection = connection;
                var list = new List<Propiedad>();
                try
                {
                    connection.Open();
                    using (var reader = cmd.ExecuteReader())
                    {

                        while (reader.Read())
                            list.Add(new Propiedad()
                            {
                                numeroFinca = reader.GetInt32(0),
                                valor = (decimal) reader.GetSqlMoney(1),
                                direccion = reader.GetString(2)
                            });
                    }
                }
                catch (Exception ex)
                {
                    throw;

                }
                finally
                {
                    connection.Close();
                }

                return list; // execute not accomplish
            }
        }

        public static Propiedad SelectPropiedad(int numeroFinca)
        {
            using (SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["connection_DB"].ConnectionString))
            {
                SqlCommand cmd = new SqlCommand();
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "dbo.SPS_Propiedad_Detail";
                cmd.Parameters.Add("@numeroFinca", SqlDbType.Int).Value = numeroFinca;
                cmd.Connection = connection;
                var propiedad = new Propiedad();
                try
                {
                    connection.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        reader.Read();
                        propiedad.numeroFinca = reader.GetInt32(0);
                        propiedad.valor = (decimal) reader.GetSqlMoney(1);
                        propiedad.direccion = reader.GetString(2);
                    }
                }
                catch (Exception ex)
                {
                    throw;

                }
                finally
                {
                    connection.Close();
                }

                return propiedad; // execute not accomplish
            }
        }
    }
}