using System;
using System.Data.Common;
using System.Threading;
using System.Threading.Tasks;
using Azure.Core;
using Azure.Identity;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.OpenApi.Models;
using SimpleApiWithDatabase.Infrastructure;

namespace SimpleApiWithDatabase
{
    public class Startup
    {
        readonly string AllowSpecificOrigins = "_myAllowSpecificOrigins";

        public Startup(IConfiguration configuration, IWebHostEnvironment env)
        {
            Configuration = configuration;
            Env = env;
        }

        public IConfiguration Configuration { get; }
        public IWebHostEnvironment Env { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            var settingsSection = Configuration.GetSection("ApiSettings");
            var interimSettings = new ApiSettings();
            settingsSection.Bind(interimSettings);
            
            services.Configure<ApiSettings>(settingsSection);
            
            services.AddCors(options =>
            {
                Console.WriteLine($"Adding Cors for origins: {string.Join(',', interimSettings.Cors)}.");
                options.AddPolicy(name: AllowSpecificOrigins,
                    builder =>
                    {
                        foreach (var origin in interimSettings.Cors)
                        {
                            builder.WithOrigins(origin);
                        }
                    });
            });

            services.AddDbContext<PetsContext>((sp, bldr) =>
            {
                var settings = sp.GetService<IOptions<ApiSettings>>()!.Value;
                if (settings.ConnectionString == null)
                {
                    Console.WriteLine("No connection string detected. Defaulting to .\\sqlexpress");
                    bldr.UseSqlServer("Data Source=.\\SQLEXPRESS;Integrated Security=SSPI;Initial Catalog=TestDatabase;app=Migrations");
                }
                else
                {
                    Console.WriteLine($"Connection string detected. {settings.ConnectionString}");
                    bldr.UseSqlServer(settings.ConnectionString);
                }
                if (!Env.IsDevelopment())
                {
                    Console.WriteLine("Not Development Environment. Adding Aad Token interceptor for Database Context");
                    bldr.AddInterceptors(new GetAadTokenInterceptor(sp.GetService<ILogger<GetAadTokenInterceptor>>()));
                }
            });

            services.AddControllers();
            services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new OpenApiInfo { Title = "SimpleApiWithDatabase", Version = "v1" });
            });
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
                app.UseSwagger();
                app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "SimpleApiWithDatabase v1"));
            }

            app.UseHttpsRedirection();

            app.UseRouting();

            app.UseCors(AllowSpecificOrigins);

            app.UseAuthorization();

            app.UseEndpoints(endpoints => { endpoints.MapControllers(); });
        }
    }

    public class GetAadTokenInterceptor : DbConnectionInterceptor
    {
        private readonly ILogger<GetAadTokenInterceptor> _logger;

        public GetAadTokenInterceptor(ILogger<GetAadTokenInterceptor> logger)
        {
            _logger = logger;
        }
        
        public override async ValueTask<InterceptionResult> ConnectionOpeningAsync(DbConnection connection,
            ConnectionEventData eventData, InterceptionResult result,
            CancellationToken cancellationToken = new CancellationToken())
        {
            _logger.LogInformation("Fetching AAD Token");
            
            var cred = new DefaultAzureCredential();
            var token = await cred.GetTokenAsync(new TokenRequestContext(new[]
                { "https://database.windows.net/" }), cancellationToken);
            ((SqlConnection)connection).AccessToken = token.Token;

            _logger.LogInformation("Attached token to connection");
            return await base.ConnectionOpeningAsync(connection, eventData, result, cancellationToken);
        }

        public override InterceptionResult ConnectionOpening(DbConnection connection, ConnectionEventData eventData,
            InterceptionResult result)
        {
            _logger.LogInformation("Fetching AAD Token (sync)");

            var cred = new DefaultAzureCredential();
            var token =  cred.GetToken(new TokenRequestContext(new[]
                { "https://database.windows.net/" }));
            ((SqlConnection)connection).AccessToken = token.Token;

            _logger.LogInformation("Attached token to connection");
            return base.ConnectionOpening(connection, eventData, result);
        }
    }
}