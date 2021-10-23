using System;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.Identity.Web;
using Microsoft.OpenApi.Models;
using SimpleApiWithDatabase.Infrastructure;

namespace SimpleApiWithDatabase
{
    public class Startup
    {
        readonly string AllowSpecificOrigins = "_myAllowSpecificOrigins";
        readonly string AllowAuthorisation = "_allowAuthorisation";

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
                            builder = builder.WithOrigins(origin);
                        }

                        builder.WithHeaders("authorization");
                    });
            });

            services.AddDbContext<PetsContext>((sp, bldr) =>
            {
                var settings = sp.GetService<IOptions<ApiSettings>>()!.Value;
                if (settings.ConnectionString == null)
                {
                    Console.WriteLine("No connection string detected. Defaulting to .\\sqlexpress");
                    bldr.UseSqlServer(
                        "Data Source=.\\SQLEXPRESS;Integrated Security=SSPI;Initial Catalog=TestDatabase;app=Migrations");
                }
                else
                {
                    Console.WriteLine($"Connection string detected. {settings.ConnectionString}");
                    bldr.UseSqlServer(settings.ConnectionString);
                }

                if (!Env.IsDevelopment())
                {
                    Console.WriteLine("Not Development Environment. Adding Aad Token interceptor for Database Context");
                    bldr.AddInterceptors(new GetAadTokenInterceptor(
                        sp.GetService<ILogger<GetAadTokenInterceptor>>(),
                        sp.GetService<IOptions<ApiSettings>>()));
                }
            });

            services.AddControllers();
            services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new OpenApiInfo { Title = "SimpleApiWithDatabase", Version = "v1" });
            });

            services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
                .AddMicrosoftIdentityWebApi(Configuration);
            
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

            app.UseAuthentication();
            app.UseAuthorization();

            app.UseEndpoints(endpoints => { endpoints.MapControllers(); });
        }
    }
}