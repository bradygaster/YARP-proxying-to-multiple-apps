namespace Microsoft.Extensions.Configuration
{
    using Microsoft.ApplicationInsights.Channel;
    using Microsoft.ApplicationInsights.Extensibility;
    using Microsoft.Extensions.Configuration;

    public class ApplicationMapNodeNameInitializer : ITelemetryInitializer
    {
        public ApplicationMapNodeNameInitializer(IConfiguration configuration)
        {
            Name = configuration["ApplicationMapNodeName"];
        }

        public ApplicationMapNodeNameInitializer(string name)
        {
            Name = name;
        }

        public string Name { get; set; }

        public void Initialize(ITelemetry telemetry)
        {
            telemetry.Context.Cloud.RoleName = Name;
        }
    }
}

namespace Microsoft.Extensions.DependencyInjection
{
    using Microsoft.ApplicationInsights.Extensibility;
    using Microsoft.Extensions.Configuration;

    public static class ServiceCollectionExtensions
    {
        public static void AddApplicationMonitoring(this IServiceCollection services, string appName)
        {
            services.AddApplicationInsightsTelemetry(appName);
            services.AddSingleton<ITelemetryInitializer, ApplicationMapNodeNameInitializer>();
        }
    }
}
