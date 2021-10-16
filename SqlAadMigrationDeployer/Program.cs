using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Azure.Core;
using Azure.Identity;
using Microsoft.Data.SqlClient;

namespace SqlAadMigrationDeployer
{
    class Program
    {
        static async Task Main(string[] args)
        {
            var sqlConnection = args[0];
            var scriptFile = args[1];

            var cred = new DefaultAzureCredential();
            var token = await cred.GetTokenAsync(new TokenRequestContext(new[]
                { "https://database.windows.net/" }));

            await using var connection = new SqlConnection(sqlConnection);
            connection.AccessToken = token.Token;
            await connection.OpenAsync();

            var parts = SplitSqlIntoBatches(await File.ReadAllTextAsync(scriptFile));
            await using var tran = await connection.BeginTransactionAsync();

            foreach (var part in parts)
            {
                var cmd = connection.CreateCommand();
                cmd.Transaction = (SqlTransaction)tran;
                cmd.CommandText = part;
            }

            await tran.CommitAsync();
            Console.WriteLine("Successfully run migration script");
        }

        /// <summary>
        /// Breaks a ef-core script into parts 
        /// </summary>
        /// <param name="batchedSql"></param>
        /// <returns></returns>
        /// <exception cref="NotImplementedException"></exception>
        private static IEnumerable<string> SplitSqlIntoBatches(string batchedSql)
        {
            string[] terminators = new[] { "BEGIN TRANSACTION;", "COMMIT;" };
            var nextPiece = new StringBuilder();
            foreach (var line in batchedSql.Split(Environment.NewLine))
            {
                if (terminators.Any(x => line.Equals(x, StringComparison.InvariantCultureIgnoreCase)))
                {
                    //ignore - we deal with transactions separately
                }
                else if (line.Equals("GO"))
                {
                    //terminator line. Return the sql if we have any
                    if (nextPiece.Length != 0)
                    {
                        yield return ReplaceVariables(nextPiece.ToString());
                        nextPiece = new StringBuilder();
                    }
                }
                else
                {
                    nextPiece.AppendLine(line);
                }
            }

            if (nextPiece.Length != 0)
            {
                yield return ReplaceVariables(nextPiece.ToString());
            }
        }

        private static string ReplaceVariables(string sql)
        {
            var regex = new Regex(@"\$\{\{\s*env\.([A-Za-z_0-9]+)\s*\}\}");
            var matches = regex.Matches(sql);
            foreach (Match match in matches)
            {
                var envVariableName = match.Groups[1].Captures[0].Value;
                var envVariableValue = Environment.GetEnvironmentVariable(envVariableName);
                sql = sql.Replace(match.Value, envVariableValue);
                Console.WriteLine($"Replacing environment variable ${envVariableName}");
            }

            return sql;
        }
    }
}