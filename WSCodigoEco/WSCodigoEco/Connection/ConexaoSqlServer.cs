using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace WSCodigoEco.Connection
{
    public class ConexaoSqlServer
    {
        private const string mstrConexao = "Server=DESKTOP-D0FLHRO; Database=CodigoEco; Trusted_Connection=Yes;";
        SqlConnection mcnn;

        public SqlConnection Conectar()
        {
            mcnn = new SqlConnection(mstrConexao);
            mcnn.Open();

            return mcnn;
        }

        public String ExecutarProcedure(string pcmdComando, string pstrParametros)
        {
            string lstrRetorno;

            using(SqlCommand lcmd = new SqlCommand(pcmdComando, mcnn))
            {
                lcmd.CommandType = CommandType.StoredProcedure;
                lcmd.Parameters.AddWithValue("@pjsParametros", pstrParametros);
                lcmd.Parameters.Add("@pJson", SqlDbType.NVarChar, -1).Direction = ParameterDirection.Output;

                lcmd.ExecuteNonQuery();

                lstrRetorno = lcmd.Parameters["@pJson"].Value.ToString();
            }

            return lstrRetorno;
        }

        public void Desconectar()
        {
            mcnn.Close();
            mcnn.Dispose();
        }
    }
}