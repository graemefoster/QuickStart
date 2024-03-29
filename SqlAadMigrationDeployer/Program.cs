﻿using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;

namespace SqlAadMigrationDeployer
{
    class Program
    {
        static async Task Main(string[] args)
        {
            var command = args[0];

            var sqlConnection = args[1];

            var printOutput = new StringBuilder();

            await using var connection = new SqlConnection(sqlConnection);
            connection.InfoMessage += (sender, eventArgs) => { printOutput.AppendLine(eventArgs.ToString()); };
            await connection.OpenAsync();

            await using var tran = await connection.BeginTransactionAsync();
            try
            {
                if (command == "migrate")
                {
                    var scriptFile = args[2];
                    var parts = SplitSqlIntoBatches(await File.ReadAllTextAsync(scriptFile));
                    foreach (var part in parts)
                    {
                        var cmd = connection.CreateCommand();
                        cmd.Transaction = (SqlTransaction)tran;
                        cmd.CommandText = part;
                        await cmd.ExecuteNonQueryAsync();
                    }
                } else if (command == "add-managed-identity")
                {
                    var applicationName = args[2];
                    var applicationId = args[3];
                    var role = args[4];
                    
                    Console.WriteLine($"Adding App {applicationName} with appId {applicationId} to role {role}");
                    
                    var cmd = connection.CreateCommand();
                    cmd.Transaction = (SqlTransaction)tran;

                    //Ignoring injection as the principal executing this is intended to be CI/CD and will have a high level of access.
                    cmd.CommandText = @$"
IF NOT EXISTS (SELECT name FROM [sys].[database_principals] WHERE name = N'{applicationName}' AND TYPE='E')
BEGIN
    CREATE USER [{applicationName}] WITH SID={FormatSqlByteLiteral(Guid.Parse(applicationId).ToByteArray())}, TYPE=E; 
END
EXEC sp_addrolemember '{role}', '{applicationName}'
";

                    await cmd.ExecuteNonQueryAsync();
                }

                await tran.CommitAsync();
                Console.WriteLine();
                Console.WriteLine("------------------------");
                Console.WriteLine(printOutput.ToString());
                Console.WriteLine("------------------------");
                Console.WriteLine();
                Console.WriteLine("Successfully run migration script");
            }
            catch (Exception)
            {
                try
                {
                    await tran.RollbackAsync();
                }
                catch
                {
                    //not much we can do here
                }

                Console.WriteLine();
                Console.WriteLine("------------------------");
                Console.WriteLine(printOutput.ToString());
                Console.WriteLine("------------------------");
                Console.WriteLine();
                Console.WriteLine("Failed to run migration script");
                throw;
            }
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
                var trimmed = line.Trim();
                if (terminators.Any(x => trimmed.Equals(x, StringComparison.InvariantCultureIgnoreCase)))
                {
                    //ignore - we deal with transactions separately
                }
                else if (trimmed.Equals("GO"))
                {
                    //terminator line. Return the sql if we have any
                    if (nextPiece.Length != 0)
                    {
                        Console.WriteLine($"Executing: {nextPiece.ToString()}");
                        yield return ReplaceVariables(nextPiece.ToString());
                        nextPiece = new StringBuilder();
                    }
                }
                else
                {
                    nextPiece.AppendLine(trimmed);
                }
            }

            if (nextPiece.Length != 0)
            {
                Console.WriteLine($"Executing: {nextPiece.ToString()}");
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
                Console.WriteLine($"Replacing environment variable {envVariableName}");
            }

            return sql;
        }
        
        /// <summary>
        /// https://github.com/MicrosoftDocs/sql-docs/issues/2323
        /// </summary>
        /// <param name="bytes"></param>
        /// <returns></returns>
        private static string FormatSqlByteLiteral(byte[] bytes)
        {
            var stringBuilder = new StringBuilder();
            stringBuilder.Append("0x");
            foreach (var @byte in bytes)
            {
                if (@byte < 16)
                {
                    stringBuilder.Append("0");
                }
                stringBuilder.Append(Convert.ToString(@byte, 16));
            }
            return stringBuilder.ToString();
        }
    }
}